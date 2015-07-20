///---------------------------------------------
///
///---------------------------------------------
module mem
#(
parameter C_WORDSIZE = 8,
parameter C_MEMSIZE = 4096,
parameter C_ADDRSIZE = clog2(C_MEMSIZE)
)
(
input           [C_WORDSIZE-1:0]    I_data,
input           [C_ADDRSIZE-1:0]    I_addr,
output          [C_WORDSIZE-1:0]    O_data,
input                               I_wrclk
);

reg [C_WORDSIZE-1:0] mem [C_MEMSIZE-1:0];

assign O_data = mem[I_addr];

always @(negedge I_wrclk) begin
    mem[I_addr] <= I_data;
end
endmodule
