/*
 * A Testbench of the Wrapper for BCH Encoder
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Encoder Module comes from Russ Dill
 *
 * Test the decoding the bits and auto-correction
 */

//`include "../bch_verilog/bch_defs.vh"
`include "../bch_verilog/bch_params.vh"

module test_bch_decoder_with_mem();
localparam DATA_BITS = 5;
localparam ERROR_BITS = 3;
localparam P = bch_params(DATA_BITS, ERROR_BITS);
localparam BITS = 1;
localparam MEM_ADDR = 4;
localparam MEM_AD_B = 5;
localparam MEM_DA_B = 8;

reg clk;
reg start;
reg en;
reg [DATA_BITS-1:0] data;

wire [MEM_AD_B-1:0] bch_mem_addr;
wire [MEM_DA_B-1:0] bch_mem_data;
wire ready;
wire [DATA_BITS-1:0] data_out;

bch_wrapper_decoder_mem #(P, DATA_BITS, ERROR_BITS, BITS, MEM_AD_B, MEM_DA_B, MEM_ADDR)
u_bch_wr_dec_mem (
    .I_clk(clk),
    .I_start(start),
    .I_en(en),
    .I_data(data),
    .I_mem_data(bch_mem_data),
    .O_data(data_out),
    .O_mem_addr(bch_mem_addr),
    .O_ready(ready)
);

reg [MEM_AD_B-1:0] ext_mem_addr;
reg [MEM_DA_B-1:0] wrdata;
wire [MEM_AD_B-1:0] mem_addr = (en)?bch_mem_addr:ext_mem_addr;
reg mem_wen;

syn_mem #(MEM_AD_B, MEM_DA_B) u_syn_mem (
    .I_clk(clk),
    .I_wen(mem_wen),
    .I_wdata(wrdata),
    .I_addr(mem_addr),
    .O_data(bch_mem_data)
);

initial begin
    clk <= 0;
    en <= 0;
    start <= 0;
    data <= 0;
    #10;
    mem_wen <= 1;
    #10;
    ext_mem_addr <= MEM_ADDR;
    wrdata <= 8'b01001101;
    #10;
    ext_mem_addr <= MEM_ADDR + 1;
    wrdata <= 8'b00000001;
    #10;
    mem_wen <= 0;
    #10;
    en <= 1;
    #10;
    start <= 1;
    data <= 5'b10101;
end

always begin
    #5 clk <= ~clk;
end

endmodule
