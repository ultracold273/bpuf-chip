///------------------------------------------
/// Find the error locator polynomial
///------------------------------------------
module bch_errloc_poly
#(
parameter C_INDWIDTH = 31,
parameter C_ERR_NUM = 4,
parameter C_PRIM_POLY = ???,
parameter C_PRIMPOLY_ORDER = C_INDWIDTH
)
(
input                                                           I_clk,
input       [C_INDWIDTH * C_ERR_NUM - 1:0]                      I_syndromes,
input                                                           I_syndromes_v,
output      [C_INDWIDTH * C_ERR_NUM + C_INDWIDTH - 1:0]         O_error_loc_polys
);

reg [C_INDWIDTH * C_ERR_NUM - 1:0]                              S_syndromes_odd;
reg [C_INDWIDTH * C_ERR_NUM - 1:0]                              S_syndromes_even;
reg [C_INDWIDTH * C_ERR_NUM * 2 - 1:0]                          S_syndromes_all;

// Even Order Syndrome Generation
always @(posedge I_clk) begin
    if(I_syndromes_v) begin
        S_syndromes_odd = I_syndromes;
    end
end

endmodule
