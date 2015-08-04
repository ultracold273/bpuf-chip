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
parameter MODE_BITS = 3,
parameter MEAS_COUNT = 20
)
(
// Outside controller
input                               I_clk,
input [MODE_BITS-1:0]               I_mode,
input                               I_start,
input                               I_en,
// All module needs it
output                              O_clk,
// signals interact with meas.v
input                               I_meas_v,
output reg                          O_meas_rst,
// signals interact with encoder_wrapper.v
output reg                          O_enc_en,
output reg                          O_enc_start,
input                               I_enc_ready,
// signals interact with decoder_wrapper.v
output reg                          O_dec_en,
output reg                          O_dec_start,
input                               I_dec_ready,
// signals that indicate all have been finished
output                              O_ready
);

localparam ENCODE = 1;
localparam DECODE = 2;

reg S_start_d;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_start_d <= 0;
    end else begin
        S_start_d <= I_start;
    end
end

reg S_start_up;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_start_up <= 0;
    end else if (S_start_d == 0 && I_start == 1) begin
        S_start_up <= 1;
    end else begin
        S_start_up <= 0;
    end
end

/* Reset Signal Generation */
reg [MEAS_COUNT-1:0] S_meas_rst_count;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_meas_rst_count <= 0;
    end else if (S_start_up) begin
        S_meas_rst_count <= 0;
    end else begin
        S_meas_rst_count <= S_meas_rst_count + 1;
    end
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_meas_rst <= 0;
    end else if (S_start_up || (&S_meas_rst_count)) begin
        O_meas_rst <= 1;
    end else begin
        O_meas_rst <= 0;
end

reg S_meas_fin;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_meas_fin <= 0;
    end else if (I_meas_v) begin
        S_meas_fin <= 1;
    end
end

reg start_mode_begin;
always @(posedge I_clk) begin
    if (!I_en) begin
        O_enc_en <= 0;
        O_dec_en <= 0;
        start_mode_begin <= 0;
    end else if (S_meas_fin) begin
        if（I_mode == ENCODE) begin
            O_enc_en <= 1;
        end else if (I_mode == DECODE) begin
            O_dec_en <= 1;
        end
        start_mode_begin <= 1;
    end
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_enc_start <= 0;
        O_dec_start <= 0;
    end else if (start_mode_begin) begin
        if (I_mode == ENCODE) begin
            O_enc_start <= 1;
        end else if (I_mode == DECODE) begin
            O_dec_start <= 1;
        end
    end
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_ready <= 0;
    end else if (I_enc_ready || I_dec_ready) begin
        O_ready <= 1;
    end
end
endmodule
