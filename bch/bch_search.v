///-------------------------------------------
///
///-------------------------------------------
module bch_search
#(
parameter C_IDWIDTH = 31,
parameter C_ERR_NUM = 4,
parameter C_SYNWIDTH = C_IDWIDTH * C_ERR_NUM
)
(
input       [C_SYNWIDTH-1:0]    I_syndromes,

);
