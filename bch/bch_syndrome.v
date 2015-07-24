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
output reg      [C_INDWIDTH*C_ERR_NUM-1:0]      O_syndromes,
output                                          O_correct
);

reg [C_INDWIDTH*C_INDWIDTH*C_ERR_NUM-1:0]       S_matrix;

localparam [C_INDWIDTH*C_INDWIDTH*C_ERR_NUM-1:0] C_TRANS_MATRIX = F_Transform(0);

function [C_INDWIDTH-1:0] F_gen;
input [C_INDWIDTH-1:0] S_init;
input integer S_times;
integer i;
begin
	F_gen = S_init;
    for(i=0;i<S_times;i=i+1)
	begin
	    if(F_gen[C_INDWIDTH-1])
		    F_gen = (F_gen<<1) ^ C_PRIM_POLY[C_PRIMPOLY_ORDER-1:0];
		else
		    F_gen = (F_gen<<1);
	end
end
endfunction

function [C_INDWIDTH*C_INDWIDTH*C_ERR_NUM-1:0] F_Transform;
input integer red;
reg [C_INDWIDTH-1:0] S_reg;
integer i,j,k;
for (i = 0;i < C_ERR_NUM;i = i + 1) begin
	for (j = 0;j < C_INDWIDTH;j = j + 1) begin
		S_reg = F_gen(1, (2 * i + 1) * j);
		for (k = 0;k < C_INDWIDTH;k = k + 1) begin
			F_Transform[i * C_INDWIDTH * C_INDWIDTH + k * C_INDWIDTH + j] = S_reg[k];
		end
	end
end
endfunction

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

integer i,j;
for(i = 0;i < C_ERR_NUM;i = i + 1)
	for(j = 0;j < C_INDWIDTH; j = j + 1) begin
		assign O_syndrome[i * C_INDWIDTH + j] = ^(C_TRANS_MATRIX[i * C_INDWIDTH * C_INDWIDTH + j * C_INDWIDTH+:C_INDWIDTH] & I_codeword);
	end

assign O_correct = &(~O_syndromes);
endmodule
