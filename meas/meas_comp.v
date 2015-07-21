///----------------------------------------------------
///
///----------------------------------------------------
module meas_comp
#(
parameter C_IWIDTH = 24
)
(
input       [C_IWIDTH-1:0]  I_comp1,
input       [C_IWIDTH-1:0]  I_comp2,
output                      O_res
);

assign O_res = (I_comp1 > I_comp2)?1:0;

endmodule
