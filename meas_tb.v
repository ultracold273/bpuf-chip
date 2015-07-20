///---------------------------------------------------
///
///---------------------------------------------------
module meas_tb;

parameter C_IOSCNUM = 48;
parameter C_IOSCDWIDTH = 24;
parameter C_OIDWIDTH = 24;
parameter C_MEMDATAWIDTH = 8;
parameter C_MEMADDRWIDTH = 24;

// Inputs
reg                             I_osc_rst;
reg     [C_IOSCNUM-1:0]         I_osc;
reg                             I_sclk;
reg     [C_MEMDATAWIDTH-1:0]    I_mem_data;
// Outputs
wire    [C_MEMADDRWIDTH-1:0]    O_mem_addr;
wire    [C_OIDWIDTH-1:0]        O_prim_id;
// Instantiate the Unit Under Test
meas uut (
    .I_osc_rst(I_osc_rst),
    .I_osc(I_osc)
);

mem mm (
    .I_data(),
    .I_addr(O_mem_addr),
    .O_data(I_mem_data),
    .I_wrclk()
);
