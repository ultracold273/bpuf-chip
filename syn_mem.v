/*
 * A synchronuous memory Module
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Encoder Module comes from Russ Dill
 *
 * A memory interface
 */
module syn_mem
#(
parameter C_ADDRSIZE = 10,
parameter C_WORDSIZE = 8
)
(
input                               I_clk,
input                               I_wen,
input           [C_WORDSIZE-1:0]    I_wdata,
input           [C_ADDRSIZE-1:0]    I_addr,
input                               I_ext_wen,
input           [C_WORDSIZE-1:0]    I_ext_wdata,
input           [C_ADDRSIZE-1:0]    I_ext_addr,
output          [C_WORDSIZE-1:0]    O_ext_data,
output          [C_WORDSIZE-1:0]    O_data
);

localparam C_MEMSIZE = (1 << C_ADDRSIZE);
reg [C_WORDSIZE-1:0] mem [C_MEMSIZE-1:0];

always @(posedge I_clk) begin
    if (I_wen) begin
        mem[I_addr] <= I_wdata;
    end else if (I_ext_wen) begin
        mem[I_ext_addr] <= I_ext_wdata;
    end
end

assign O_data = mem[I_addr];
assign O_ext_data = mem[I_ext_addr];

endmodule
