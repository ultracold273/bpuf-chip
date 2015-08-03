/*
 * A Testbench of the Wrapper for BCH Encoder
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Encoder Module comes from Russ Dill
 *
 * Encodes the bits and save the ecc bits to outside memory
 */

`include "../bch_verilog/bch_defs.vh"
//`include "../bch_verilog/bch_params.vh"

module test_bch_wrapper_decode();
localparam DATA_BITS = 5;
localparam ERROR_BITS = 3;
localparam P = bch_params(DATA_BITS, ERROR_BITS);
localparam BITS = 1;
localparam MEM_ADDR = 4;
localparam MEM_AD_B = 5;
localparam MEM_DA_B = 8;

localparam ERROR_DATA = 15'b111000101001101;

reg clk;
reg start;
reg en;
reg [`BCH_CODE_BITS(P)-1:0] data_in;
wire [`BCH_DATA_BITS(P)-1:0] data_out;
wire ready;

bch_wrapper_decoder #(P, DATA_BITS, ERROR_BITS, BITS) u_dec (
    .I_clk(clk),
    .I_start(start),
    .I_en(en),
    .I_data(data_in),
    .O_data(data_out),
    .O_ready(ready)
);

initial begin
    clk <= 0;
    en <= 0;
    start <= 0;
    data_in <= 0;
    #6;
    en <= 1;
    #10;
    data_in <= ERROR_DATA;
    start <= 1;
end

always begin
    #5 clk = ~clk;
end
endmodule
