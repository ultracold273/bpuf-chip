/*
 * A Wrapper for BCH Decoder
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Encoder Module comes from Russ Dill
 *
 * NO memory access and decode the whole codeword
 */

//`include "../bch_verilog/log2.vh"
//`include "../bch_verilog/bch_params.vh"
`include "../bch_verilog/bch_defs.vh"
module bch_wrapper_decoder
#(
parameter [`BCH_PARAM_SZ-1:0] C_P = `BCH_SANE,
parameter C_I_DATABITS = 4,
parameter C_I_ERRORS = 3,
parameter C_BITS = 1
)
(
input                                   I_clk,
input                                   I_start,
input                                   I_en,
i(C_P)-1:0]         I_data,
output(C_P)-1:0]    O_data,
output reg                              O_ready
);

`include "../bch_verilog/bch.vh"
localparam REG_RATIO = 1;
wire syndrome_ready;
wire syndrome_start = syndrome_input_ready && syndrome_ready;

reg S_start_d;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_start_d <= 0;
    end else begin
        S_start_d <= I_start;
    end
end

reg syndrome_input_ready;
always @(posedge I_clk) begin
    if (!I_en) begin
        syndrome_input_ready <= 0;
    end else if (I_start == 1 && S_start_d == 0) begin
        syndrome_input_ready <= 1;
    end else begin
        syndrome_input_ready <= 0;
    end
end

reg [`BCH_N(C_P)-1:0] decode_buf;
always @(posedge I_clk) begin
    if (!I_en) begin
        decode_buf <= 0;
    end else if (I_start == 1 && S_start_d == 0) begin
        decode_buf <= I_data;
    end else if (!syndrome_ready || syndrome_start) begin
        decode_buf <= decode_buf << C_BITS;
    end
end

wire decode_in = decode_buf[`BCH_N(C_P)-1-:C_BITS];
wire [`BCH_SYNDROMES_SZ(C_P)-1:0] syndromes;
wire syndrome_done;

bch_syndrome #(C_P, C_BITS, REG_RATIO) u_bch_syndrome (
    .clk(I_clk),
    .start(syndrome_start),
    .ready(syndrome_ready),
    .ce(1'b1),
    .data_in(decode_in),
    .syndromes(syndromes),
    .done(syndrome_done)
);

wire key_ready;
wire [`BCH_SIGMA_SZ(C_P)-1:0] sigma;
wire ch_start;
wire [`BCH_ERR_SZ(C_P)-1:0] err_count;
bch_sigma_bma_serial #(C_P) u_bma (
    .clk(I_clk),
    .start(syndrome_done && key_ready),
    .ready(key_ready),
    .syndromes(syndromes),
    .sigma(sigma),
    .done(ch_start),
    .ack_done(1'b1),
    .err_count(err_count)
);

wire err_first;
wire [C_BITS-1:0] err;
bch_error_tmec #(C_P, C_BITS, REG_RATIO) u_error_tmec (
    .clk(I_clk),
    .start(ch_start),
    .sigma(sigma),
    .first(err_first),
    .err(err)
);

wire [C_BITS-1:0] err1;
wire err_first1;
bch_error_one #(C_P, C_BITS) u_error_one(
    .clk(I_clk),
    .start(ch_start),
    .sigma(sigma[0+:2*`BCH_M(C_P)]),
    .first(err_first1),
    .err(err1)
);

wire err_last;
wire err_valid;
bch_chien_counter #(C_P, C_BITS) u_chien_counter(
	.clk(I_clk),
	.first(err_first),
	.last(err_last),
	.valid(err_valid)
);

reg err_last_d;
always @(posedge I_clk) begin
    err_last_d <= err_last;
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_ready <= 0;
    end else if (err_last_d || O_ready) begin
        O_ready <= 1;
    end
end

reg [`BCH_K(C_P)-1:0] err_buf;

always @(posedge I_clk) begin
    if (err_first) begin
        err_buf <= err;
    end else if (err_valid) begin
        err_buf <= (err_buf << C_BITS) | err;
    end
end
/*
always @(posedge I_clk) begin
    if (err_first) begin
        err_buf <= err << (`BCH_DATA_BITS(C_P) - C_BITS);
    end else if (err_valid) begin
        err_buf <= (err << (`BCH_DATA_BITS(C_P) - C_BITS)) | (err_buf >> C_BITS);
    end
end
*/


always @(posedge I_clk) begin
    if (!I_en) begin
        O_data <= 0;
    end else if (err_last_d) begin
        O_data <= I_data[`BCH_N(C_P)-1-:`BCH_K(C_P)] ^ err_buf;
    end
end
endmodule
