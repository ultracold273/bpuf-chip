///-----------------------------------------
///
///-----------------------------------------
module meas
#(
parameter C_IOSCNUM = 48,
parameter C_IOSCDWIDTH = 24,
parameter C_OIDWIDTH = 24,
parameter C_MEMDATAWIDTH = 8,
parameter C_MEMADDRWIDTH = 24,
parameter C_MEMSTADDR = 0
)
(
input                               I_osc_rst,
input       [C_IOSCNUM-1:0]         I_osc,
input                               I_sclk,
input       [C_MEMDATAWIDTH-1:0]    I_mem_data,
output reg  [C_MEMADDRWIDTH-1:0]    O_mem_addr,
output reg  [C_OIDWIDTH-1:0]        O_prim_id
);

localparam C_SELWIDTH = C_MEMDATAWIDTH;
wire [C_IOSCNUM*C_IOSCDWIDTH-1:0]   S_osc_data;
wire [C_IOSCDWIDTH-1:0] S_mux_data_1;
wire [C_IOSCDWIDTH-1:0] S_mux_data_2;
wire S_comp;

reg [C_SELWIDTH-1:0] S_mux_sel_1;
reg [C_SELWIDTH-1:0] S_mux_sel_2;
reg sclk;

genvar i;
integer j;

for(i = 0;i < C_IOSCNUM;i = i + 1) begin: gen_meas_osc
    meas_osc #(.C_DWIDTH(C_IOSCDWIDTH)) m(
        .I_osc(I_osc[i]),
        .I_rst(I_osc_rst),
        .O_data(S_osc_data[i*C_IOSCDWIDTH+:C_IOSCDWIDTH])
    );
end

meas_mux #(.C_INUM(C_IOSCNUM), .C_IDWIDTH(C_IOSCDWIDTH), .C_ISWIDTH(C_SELWIDTH)) mux1(
    .I_data(S_osc_data),
    .I_sel(S_mux_sel_1),
    .O_data(S_mux_data_1)
);

meas_mux #(.C_INUM(C_IOSCNUM), .C_IDWIDTH(C_IOSCDWIDTH), .C_ISWIDTH(C_SELWIDTH)) mux2(
    .I_data(S_osc_data),
    .I_sel(S_mux_sel_2),
    .O_data(S_mux_data_2)
);

meas_comp #(.C_IWIDTH(C_IOSCDWIDTH)) comp(
    .I_comp1(S_mux_data_1),
    .I_comp2(S_mux_data_2),
    .O_res(S_comp)
);

reg [10:0] _cnt_bit_num;
reg [2:0] _cnt_seq;


always @(posedge I_sclk or negedge I_osc_rst) begin
    if (!I_osc_rst) begin
        _cnt_bit_num <= 0;
        _cnt_seq <= 0;
        O_mem_addr <= C_MEMSTADDR;
    end
    else if (_cnt_bit_num < C_OIDWIDTH) begin
        if (_cnt_seq == 0) begin
            /*O_mem_addr <= O_mem_addr + 1;*/
            _cnt_seq <= _cnt_seq + 1;
        end
        else if (_cnt_seq == 1) begin
            S_mux_sel_1 <= I_mem_data;
            O_mem_addr <= O_mem_addr + 1;
            _cnt_seq <= _cnt_seq + 1;
        end
        else if (_cnt_seq == 2) begin
            S_mux_sel_2 <= I_mem_data;
            O_mem_addr <= O_mem_addr + 1;
            _cnt_seq <= _cnt_seq + 1;
        end
        else if (_cnt_seq == 3) begin
            sclk <= 1;
            _cnt_seq <= _cnt_seq + 1;
        end
        else if (_cnt_seq == 4) begin
            sclk <= 0;
            _cnt_seq <= 0;
            _cnt_bit_num <= _cnt_bit_num + 1;
        end
    end
end

always @(posedge sclk) begin
    for(j = 1;j < C_OIDWIDTH;j = j + 1) begin
        O_prim_id[j] <= O_prim_id[j-1];
    end
    O_prim_id[0] <= S_comp;
end
endmodule
