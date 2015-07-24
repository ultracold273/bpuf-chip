///------------------------------------
///
///------------------------------------
module bch_encode
#(
parameter C_INDWIDTH = 24,
parameter C_ERR_NUM = 4,
parameter C_OCDWIDTH = F_GETCODELEN(0)
)
(
input       [C_INWIDTH-1:0]     I_data,
output      [C_OCDWIDTH-1:0]    O_codeword
);
function integer F_GETCODELEN;
input integer redudant;
integer m;
for (m = 3;m <=)
F_GETCODELEN = 2 ** m - 1;
endfunction
endmodule
