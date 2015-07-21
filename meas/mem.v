///---------------------------------------------
///
///---------------------------------------------
module mem
#(
parameter C_WORDSIZE = 8,
parameter C_ADDRSIZE = 10,
parameter C_MEMSIZE = (1 << C_ADDRSIZE)
)
(
input           [C_WORDSIZE-1:0]    I_data,
input           [C_ADDRSIZE-1:0]    I_addr,
output reg      [C_WORDSIZE-1:0]    O_data,
input                               I_wrclk
);

reg [C_WORDSIZE-1:0] mem [C_MEMSIZE-1:0];

always @(I_addr) begin
    O_data <= mem[I_addr];
end

always @(negedge I_wrclk) begin
    mem[I_addr] <= I_data;
end
endmodule
