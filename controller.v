/*
 * Generate the control signal for all modules on chip depending on the inputs
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 *
 * Include the Reset signal for meas.v
 * clock signal for bch related modules
 * control signals for memory module
 */

module control
#(
parameter MODE_BITS = 3
)
(
input                               I_clk,
input [MODE_BITS-1:0]               I_mode,
input                               I_en,
output reg                          O_meas_rst,
output                              O_ready
);

localparam LP_MEAS_COUNT = 20;

reg [LP_MEAS_COUNT-1:0] S_meas_rst_count;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_meas_rst_count <= 0;
    end else begin
        S_meas_rst_count <= S_meas_rst_count + 1;
    end
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_meas_rst <= 0;
    end else if (&S_meas_rst_count) begin
        O_meas_rst <= ~O_meas_rst;
    end
end



endmodule
