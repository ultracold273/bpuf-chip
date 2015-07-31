/*
 * A Wrapper for BCH Encoder
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Encoder Module comes from Russ Dill
 *
 * Encodes the bits and save the ecc bits to outside memory
 */

`include "../bch_verilog/bch_defs.vh"

module bch_wrapper_encoder
#(
parameter [`BCH_PARAM_SZ-1:0] C_P = `BCH_SANE,
parameter C_I_DATABITS = 4,
parameter C_I_ERRORS = 3,
parameter C_BITS = 1,
parameter C_O_MEMADDR = ?
parameter C_MEM_ADDR_SIZE = 10,
parameter C_MEM_DATA_SIZE = 8
)
(
input                               I_clk,
input [`BCH_DATA_BITS(C_P)-1:0]     I_data,
input                               I_start,
input                               I_en,
output reg [C_MEM_ADDR_SIZE-1:0]    O_mem_waddr,
output reg [C_MEM_DATA_SIZE-1:0]    O_mem_wdata,
output reg                          O_wen,
output                              O_ready
);

localparam LP_D_BITS = `BCH_DATA_BITS(C_P);
localparam LP_E_BITS = `BCH_ECC_BITS(C_P);
localparam LP_MEM_CYCLE = LP_E_BITS / MEM_WBITS;

reg S_I_start_d;
always @(posedge I_clk) begin
    if(!I_en) begin
        S_I_start_d <= 0;
    end else begin
        S_I_start_d <= I_start;
    end
end

reg S_I_start_up;
always @(posedge I_clk) begin
    if(!I_en) begin
        S_I_start_up <= 0;
    end else if (S_I_start_d == 0 && I_start == 1) begin
        S_I_start_up <= 1;
    end else begin
        S_I_start_up <= 0;
    end
end

reg R_encode_start;
always @(posedge I_clk) begin
    if (!I_en) begin
        R_encode_start <= 0;
    end else if (S_I_start_up && R_encode_ready) begin
        R_encode_start <= 1;
    end else begin
        R_encode_start <= 0;
    end
end

reg R_encode_ce;
always @(posedge I_clk) begin
    R_encode_ce <= I_en;
end

wire W_encode_accepted = R_encode_ready & R_encode_start;
wire [C_BITS - 1:0] W_encode_data_in;
assign W_encode_data_in = (W_encode_accepted)? I_data[LP_D_BITS-1-:C_BITS]:S_data_in_buf[LP_D_BITS-1-:C_BITS];
wire [C_BITS - 1:0] W_encode_data_out;

reg [LP_D_BITS-1:0] S_data_in_buf;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_data_in_buf <= 0;
    end else if (W_encode_accepted) begin
        S_data_in_buf <= I_data << C_BITS;
    end else if (!W_encode_ready) begin
        S_data_in_buf <= S_data_in_buf << C_BITS;
    end
end

wire W_encode_ready;
wire W_encode_data_bits;
wire W_encode_ecc_bits;
wire W_encode_first;
wire W_encode_last;

reg [LP_E_BITS-1:0] R_ecc_out;
always @(posedge I_clk) begin
    if (!I_en) begin
        R_ecc_out <= 0;
    end else if (W_encode_ecc_bits) begin
        R_ecc_out <= R_ecc_out << C_BITS;
        R_ecc_out[C_BITS-1:0] <= W_encode_data_out;
    end
end

bch_encode #(C_P, C_BITS) u_bch_encode (
    .clk(I_clk),                              // Input
    .start(R_encode_start && R_encode_ready), // Input
    .ready(R_encode_ready),                   // Output
    .ce(R_encode_ce),                         // Input
    .data_in(encode_data_in),               // Input
    .data_out(encode_data_out),             // Output
    .data_bits(encode_data_bits),           // Output
    .ecc_bits(encode_ecc_bits),             // Output
    .first(encode_first),                   // Output
    .last(encode_last)                      // Output
);

reg R_encode_done;
reg S_encode_ready_d;
always @(posedge I_clk) begin
    S_encode_ready_d <= W_encode_ready;
end

always @(posedge I_clk) begin
    if (!I_en) begin
        R_encode_done <= 0;
    end else if (S_encode_ready_d == 0 && W_encode_ready == 1)  begin
        R_encode_done <= 1;
    end else begin
        R_encode_done <= 0;
    end
end

reg S_mem_wr_busy;
wire S_mem_wr_done;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_mem_wr_busy <= 0;
    end else if (R_encode_done) begin
        S_mem_wr_busy <= 1;
    end else if (S_mem_wr_done) begin
        S_mem_wr_busy <= 0;
    end
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_mem_waddr <= C_O_MEMADDR - 1;
    end else if (S_mem_wr_busy) begin
        O_mem_waddr <= O_mem_waddr + 1;
    end
end

always @(posedge I_clk) begin
    O_wen <= S_mem_wr_busy;
end

assign O_mem_wdata = 

endmodule
