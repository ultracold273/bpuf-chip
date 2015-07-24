///-----------------------------------------------------
/// Calculate the syndrome of a codeword
///-----------------------------------------------------
module bch_syndrome
#(
parameter C_INDWIDTH = 31,
parameter C_ERR_NUM = 4,
)
(
input           [C_INDWIDTH-1:0]                I_codeword,
output reg      [C_ERR_NUM*C_INDWIDTH-1:0]      O_syndromes,
output                                          O_correct
);


function integer GETASIZE;
input integer a;
integer i;
begin
    for(i=1;(2**i)<=a;i=i+1)
      begin
      end
    GETASIZE = i;
end
endfunction

reg []
function F_Gen;

endmodule
