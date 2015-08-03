/*
 * Testbench for BCH Encoder and Decoder Modules
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Module comes from Russ Dill
 */
`timescale 1ns / 1ps

`include "../bch_verilog/bch_defs.vh"
`include "../bch_verilog/bch_params.vh"

module test_bch_verilog();

parameter T = 3;
parameter OPTION = "SERIAL";
parameter DATA_BITS = 5;
parameter BITS = 1;
parameter REG_RATIO = 1;
parameter SEED = 0;

parameter DATA_IN = 5'b00011;
localparam [`BCH_CODE_BITS(BCH_PARAMS)-1:0] ERROR_OCR = 15'h3000;

localparam BCH_PARAMS = bch_params(DATA_BITS, T);

reg clk;
reg rst;
reg start;
reg all_done;

initial begin
    clk <= 0;
    #1;
    rst <= 0;
    start <= 0;
    #15;
    rst <= 1;
    #5;
//    encode_ce <= 1;
    #5;
    start <= 1;
    #200;
end

always begin
    #5 clk = ~clk;
end

reg start_up;
reg start_d;
always @(posedge clk) begin
    if (!rst) begin
        start_d <= 0;
    end else begin
        start_d <= start;
    end
end

always @(posedge clk) begin
    if (!rst) begin
        start_up <= 0;
    end else if (start_d == 0 && start == 1) begin
        start_up <= 1;
    end else begin
        start_up <= 0;
    end
end

reg             encode_start;
//reg             encode_ce;
wire [BITS-1:0]  encode_data_in;
wire [BITS-1:0] encode_data_out;
wire            encode_ready;
wire            encode_data_bits;
wire            encode_ecc_bits;
wire            encode_first;
wire            encode_last;

always @(posedge clk) begin
    if (!rst) begin
        encode_start <= 0;
    end else if (start_up && encode_ready) begin
        encode_start <= 1;
    end else begin
        encode_start <= 0;
    end
end
//wire encode_accepted = encode_ready & encode_ce & encode_start;
wire encode_accepted = encode_ready & encode_start;
assign encode_data_in = (encode_accepted ? DATA_IN[BITS-1:0]:encode_buf[BITS-1:0]);
reg [DATA_BITS-1:0] encode_buf;
reg [`BCH_CODE_BITS(BCH_PARAMS)-1:0] encode_res_buf;

always @(posedge clk) begin
    if (!rst) begin
        encode_buf <= 0;
    end else if (encode_accepted) begin
        encode_buf <= #1 DATA_IN >> BITS;
    end else if (!encode_ready) begin
        encode_buf <= #1 encode_buf >> BITS;
    end
end

always @(posedge clk) begin
    if (encode_data_bits || encode_ecc_bits) begin
        encode_res_buf <= encode_res_buf << BITS;
        encode_res_buf[BITS-1:0] <= encode_data_out;
    end
end

reg encode_done;
reg encode_ready_d;
always @(posedge clk) begin
        encode_ready_d <= encode_ready;
end

always @(posedge clk) begin
    if (!rst) begin
        encode_done <= 0;
    end else if (encode_ready_d == 0 && encode_ready == 1) begin
        encode_done <= 1;
    end else begin
        encode_done <= 0;
    end
end


bch_encode #(BCH_PARAMS, BITS) u_bch_encode (
    .clk(clk),                              // Input
    .start(encode_start && encode_ready),    // Input
    .ready(encode_ready),                   // Output
    .ce(1'b1),                         // Input
    .data_in(encode_data_in),               // Input
    .data_out(encode_data_out),             // Output
    .data_bits(encode_data_bits),           // Output
    .ecc_bits(encode_ecc_bits),             // Output
    .first(encode_first),                   // Output
    .last(encode_last)                      // Output
);

reg [`BCH_CODE_BITS(BCH_PARAMS)-1:0] decode_buf;
always @(posedge clk) begin
    if (!rst) begin
        decode_buf <= 0;
    end else if (encode_done) begin
        decode_buf <= encode_res_buf ^ ERROR_OCR;
    end else if (!syndrome_ready || syndrome_input_ready) begin
        decode_buf <= decode_buf << BITS;
    end
end

reg syndrome_input_ready;
always @(posedge clk) begin
    if (!rst) begin
        syndrome_input_ready <= 0;
    end else begin
        syndrome_input_ready <= encode_done;
    end
end

wire syndrome_ready;
wire syndrome_start = syndrome_input_ready && syndrome_ready;
wire decode_in = decode_buf[`BCH_CODE_BITS(BCH_PARAMS)-1-:BITS];
//wire syndrome_start = encode_first && syndrome_ready;
//wire syndrome_ce = !syndrome_done || key_ready;
//wire syndrome_accepted = syndrome_start && syndrome_ce;
//wire decoder_in = encode_data_out;
wire [`BCH_SYNDROMES_SZ(BCH_PARAMS)-1:0] syndromes;
wire syndrome_done;

bch_syndrome #(BCH_PARAMS, BITS, REG_RATIO) u_bch_syndrome (
    .clk(clk),
    .start(syndrome_start),
    .ready(syndrome_ready),
    .ce(1'b1),
    .data_in(decode_in),
    .syndromes(syndromes),
    .done(syndrome_done)
);

wire key_ready;
wire [`BCH_SIGMA_SZ(BCH_PARAMS)-1:0] sigma;
wire ch_start;
wire [`BCH_ERR_SZ(BCH_PARAMS)-1:0] err_count;

bch_sigma_bma_serial #(BCH_PARAMS) u_bma (
    .clk(clk),
    .start(syndrome_done && key_ready),
    .ready(key_ready),
    .syndromes(syndromes),
    .sigma(sigma),
    .done(ch_start),
    .ack_done(1'b1),
    .err_count(err_count)
);

wire err_first;
wire [BITS-1:0] err;
bch_error_tmec #(BCH_PARAMS, BITS, REG_RATIO) u_error_tmec (
    .clk(clk),
    .start(ch_start),
    .sigma(sigma),
    .first(err_first),
    .err(err)
);

wire [BITS-1:0] err1;
wire err_first1;
bch_error_one #(BCH_PARAMS, BITS) u_error_one(
    .clk(clk),
    .start(ch_start),
    .sigma(sigma[0+:2*`BCH_M(BCH_PARAMS)]),
    .first(err_first1),
    .err(err1)
);

wire err_last;
wire err_valid;
bch_chien_counter #(BCH_PARAMS, BITS) u_chien_counter(
	.clk(clk),
	.first(err_first),
	.last(err_last),
	.valid(err_valid)
);

reg err_last_d;
always @(posedge clk) begin
    err_last_d <= err_last;
end

always @(posedge clk) begin
    if (!rst) begin
        all_done <= 0;
    end else if (err_last_d || all_done) begin
        all_done <= 1;
    end
end

reg [`BCH_DATA_BITS(BCH_PARAMS)-1:0] err_buf;
always @(posedge clk) begin
    if (err_first) begin
        err_buf <= err << (`BCH_DATA_BITS(BCH_PARAMS) - BITS);
    end else if (err_valid) begin
        err_buf <= (err << (`BCH_DATA_BITS(BCH_PARAMS) - BITS)) | (err_buf >> BITS);
    end
end
endmodule
