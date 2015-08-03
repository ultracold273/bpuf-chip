/*
 * A Testbench of the Wrapper for BCH Encoder
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Encoder Module comes from Russ Dill
 *
 * Encodes the bits and save the ecc bits to outside memory
 */

`include "../bch_verilog/bch_params.vh"
`include "../bch_verilog/bch_defs.vh"

module test_bch_wrapper_encode();
localparam DATA_BITS = 5;
localparam ERROR_BITS = 3;
localparam P = bch_params(DATA_BITS, ERROR_BITS);
localparam BITS = 1;
localparam MEM_ADDR = 4;
localparam MEM_AD_B = 5;
localparam MEM_DA_B = 8;

reg clk;
wire [MEM_AD_B-1:0] mem_waddr;
wire [MEM_DA_B-1:0] mem_wdata;
wire mem_wen;
reg start;
reg en;
reg [DATA_BITS-1:0] data;
wire ready;
bch_wrapper_encoder #(P, DATA_BITS, ERROR_BITS, BITS, MEM_ADDR, MEM_AD_B, MEM_DA_B) u_en (
    .I_clk(clk),
    .I_data(data),
    .I_start(start),
    .I_en(en),
    .O_mem_waddr(mem_waddr),
    .O_mem_wdata(mem_wdata),
    .O_wen(mem_wen),
    .O_ready(ready)
);

wire [MEM_DA_B-1:0] mem_out;
syn_mem #(MEM_AD_B, MEM_DA_B) u_mem (
    .I_clk(clk),
    .I_wen(mem_wen),
    .I_wdata(mem_wdata),
    .I_addr(mem_waddr),
    .O_data(mem_out)
);

initial begin
    clk <= 0;
    data <= 0;
    en <= 0;
    start <= 0;
    #6;
    en <= 1;
    #10;
    data <= 10;
    start <= 1;
end

always begin
    #5 clk <= ~clk;
end
endmodule
