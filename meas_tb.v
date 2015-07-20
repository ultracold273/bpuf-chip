///---------------------------------------------------
///
///---------------------------------------------------
module meas_tb;

parameter C_IOSCNUM = 10;
parameter C_IOSCDWIDTH = 24;
parameter C_OIDWIDTH = 24;
parameter C_MEMDATAWIDTH = 8;
parameter C_MEMADDRWIDTH = 24;

// Inputs
reg                             I_osc_rst;
reg     [C_IOSCNUM-1:0]         I_osc;
reg                             I_sclk;
reg     [C_MEMDATAWIDTH-1:0]    I_mem_data;
reg                             I_data;
reg                             I_wrclk;
// Outputs
wire    [C_MEMADDRWIDTH-1:0]    O_mem_addr;
wire    [C_OIDWIDTH-1:0]        O_prim_id;
// Instantiate the Unit Under Test
meas #( .C_IOSCNUM(C_IOSCNUM),
        .C_IOSCDWIDTH(C_IOSCDWIDTH),
        .C_OIDWIDTH(C_OIDWIDTH),
        .C_MEMDATAWIDTH(C_MEMDATAWIDTH),
        .C_MEMADDRWIDTH(C_MEMADDRWIDTH)) uut (
    .I_osc_rst(I_osc_rst),
    .I_osc(I_osc),
    .I_sclk(I_sclk),
    .I_mem_data(I_mem_data),
    .O_mem_addr(O_mem_addr),
    .O_prim_id(O_prim_id)
);

mem #() mm (
    .I_data(I_data),
    .I_addr(O_mem_addr),
    .O_data(I_mem_data),
    .I_wrclk(I_wrclk)
);

initial begin
    integer addr = 0;
    for (addr = 0;addr < C_OIDWIDTH;addr = addr + 1) begin
        write
    end
end

function write_mem

genvar i;
for (i = 0;i < C_IOSCNUM;i=i+1) begin
    always begin
        #(2*i) I_osc[i] <= ~I_osc[i]
    end
end

always begin
    #2000 I_osc_rst = ~I_osc_rst;
end

endmodule
