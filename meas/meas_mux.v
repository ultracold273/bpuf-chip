///------------------------------------
///
///------------------------------------
`include "include/clog2.vh"
module meas_mux
#(
parameter C_INUM = 48,  // input number
parameter C_IDWIDTH = 24,    // the input data width
parameter C_ISWIDTH = clog2(C_INUM)     // the input selection width
)
(
input           [C_INUM*C_IDWIDTH-1:0]  I_data,     // bit line of all inputs
input           [C_ISWIDTH-1:0]         I_sel,          // selection
output          [C_IDWIDTH-1:0]         O_data
);

genvar i;
for (i = 0;i < C_IDWIDTH;i = i + 1) begin
    assign O_data[i] = I_data[C_IDWIDTH * I_sel + i];
end

endmodule
