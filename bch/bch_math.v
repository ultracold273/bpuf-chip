///------------------------------------------------
///
///------------------------------------------------
module bch_math_mul
#(
parameter C_INWIDTH = 31,
parameter C_POLY_PRIM = 31'h????
)
(
input                                   I_clk,
input       [C_INWIDTH-1:0]             I_Multiplicant，
input       [C_INWIDTH-1:0]             I_Multiplier,
input                                   I_Mult_v,
output reg  [C_INWIDTH-1:0]             O_Prod,
output                                  O_Prod_v
);

reg [C_INWIDTH-1:0] S_Multiplicant;
reg [C_INWIDTH-1:0] S_Multiplier;

always @(posedge I_clk) begin
    if (I_Mult_v) begin
        S_Multiplier <= I_Multiplier;
    end
    else begin
        S_Multiplier = S_Multiplier << 1;
    end
end

always @(posedge I_clk) begin
    if (I_Mult_v) begin
        S_Multiplicant <= I_Multiplicant;
    end
end

genvar i;
always @(posedge I_clk) begin
    for (i = 1;i < C_INWIDTH;i = i + 1) begin
        O_Prod[i] <= (S_Multiplier[C_INWIDTH-1] & S_Multiplicant[i]) ^
                    (O_Prod[C_INWIDTH-1] & C_POLY_PRIM[i]) ^
                    (O_Prod[i - 1]);
    end
    O_Prod[0] <= (S_Multiplier[C_INWIDTH-1] & S_Multiplicant[0]) ^
                (O_Prod[C_INWIDTH-1] & C_POLY_PRIM[0]);
end
endmodule
