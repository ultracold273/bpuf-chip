///------------------------------------
///
///------------------------------------
`timescale 1ns/100ps
module meas_osc
#(
parameter C_DWIDTH = 24               // output counter size
)
(
input                     I_osc     , // input oscillation
input                     I_rst     , // input reset signal
output reg  [C_DWIDTH-1:0]  O_data // output counter in a predefined time interval
);

reg [C_DWIDTH-1:0]  S_int_count;
wire gated_osc;

assign gated_osc = I_rst & I_osc;

always @(negedge I_rst or posedge gated_osc) begin
    if (!I_rst) begin
        S_int_count <= 0;
        O_data <= S_int_count;
    end
    else begin
        S_int_count <= S_int_count + 1;
    end
end
endmodule
