/*
 * Testbench for the synchronuous memory Module
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 *
 * A memory interface
 */

module test_syn_mem();

localparam ADDR_SIZE = 4;
localparam WORD_SIZE = 8;

reg clk;
reg wen;
reg [WORD_SIZE-1:0] wdata;
reg [ADDR_SIZE-1:0] addr;
wire [WORD_SIZE-1:0] rdata;

syn_mem #(ADDR_SIZE, WORD_SIZE) u_mem (
    .I_clk(clk),
    .I_wen(wen),
    .I_wdata(wdata),
    .I_addr(addr),
    .O_data(rdata)
);

integer i;
initial begin
    clk <= 0;
    wen <= 0;
    wdata <= 0;
    addr <= 0;
    #6;
    wen <= 1;
    #20;
    for (i = 0;i < 10;i = i + 1) begin
        #10 wdata <= i + 1;
        addr <= i;
    end

    #10;
    wen <= 0;
    for (i = 0;i < 20;i = i + 1) begin
        #10 addr <= i;
    end
end

always begin
    #5 clk <= ~clk;
end

endmodule
