///---------------------------------------------------
///
///---------------------------------------------------
`timescale 1ns/100ps
module meas_tb;

parameter C_IOSCNUM = 10;
parameter C_IOSCDWIDTH = 9;
parameter C_OIDWIDTH = 5;
parameter C_MEMDATAWIDTH = 8;
parameter C_MEMADDRWIDTH = 5;

// Inputs
reg                             I_osc_rst;
reg     [C_IOSCNUM-1:0]         I_osc;
reg                             I_sclk;
wire     [C_MEMDATAWIDTH-1:0]    I_mem_data;
reg     [C_MEMDATAWIDTH-1:0]    I_data;
reg                             I_wrclk;
wire     [C_MEMADDRWIDTH-1:0]    I_addr;
// Internal Signals
reg     [C_MEMADDRWIDTH-1:0]    S_mem_addr;
reg                             S_ext_mem;
// Outputs
wire    [C_MEMADDRWIDTH-1:0]    O_mem_addr;
wire    [C_OIDWIDTH-1:0]        O_prim_id;
// Instantiate the Unit Under Test
meas #( .C_IOSCNUM(C_IOSCNUM),
        .C_IOSCDWIDTH(C_IOSCDWIDTH),
        .C_OIDWIDTH(C_OIDWIDTH),
        .C_MEMDATAWIDTH(C_MEMDATAWIDTH),
        .C_MEMADDRWIDTH(C_MEMADDRWIDTH))
uut (
    .I_osc_rst(I_osc_rst),
    .I_osc(I_osc),
    .I_sclk(I_sclk),
    .I_mem_data(I_mem_data),
    .O_mem_addr(O_mem_addr),
    .O_prim_id(O_prim_id)
);

mem #(  .C_WORDSIZE(C_MEMDATAWIDTH),
        .C_ADDRSIZE(C_MEMADDRWIDTH))
mm (
    .I_data(I_data),
    .I_addr(I_addr),
    .O_data(I_mem_data),
    .I_wrclk(I_wrclk)
);

assign I_addr = (S_ext_mem)?S_mem_addr:O_mem_addr;
//assign I_addr = O_mem_addr;

integer addr, j, i;
initial begin
    I_osc_rst = 1;
    S_ext_mem = 1;
    for (i = 0;i < C_IOSCNUM;i = i + 1) begin
        I_osc[i] = 0;
    end

	 #10 I_osc_rst = 0;

	 #20 I_osc_rst = 1;

    for (addr = 0;addr < C_OIDWIDTH * 2;addr = addr + 2) begin
        #2 S_mem_addr = addr; I_data = 0;
        #2 I_wrclk = 0;
        #2 I_wrclk = 1;
        #2 S_mem_addr = addr + 1; I_data = 1;
        #2 I_wrclk = 0;
        #2 I_wrclk = 1;
    end
    #2 S_ext_mem = 0;

	 #2000 $finish;
end

always begin
    #1000 I_osc_rst = 0;
	 #20 I_osc_rst = 1;
end

always @(posedge I_osc_rst) begin
    #50 I_sclk = 1;
    for(j = 0;j < 100;j = j + 1) begin
        #3 I_sclk = ~I_sclk;
    end
    I_sclk = 0;
end

always begin
    #1 I_osc[0] <= ~I_osc[0];
end

always begin
    #3 I_osc[1] <= ~I_osc[1];
end

always begin
    #5 I_osc[2] <= ~I_osc[2];
end

always begin
    #8 I_osc[3] <= ~I_osc[3];
end

always begin
    #4 I_osc[4] <= ~I_osc[4];
end

always begin
    #2 I_osc[5] <= ~I_osc[5];
end

always begin
    #5 I_osc[6] <= ~I_osc[6];
end

always begin
    #8 I_osc[7] <= ~I_osc[7];
end

always begin
    #4 I_osc[8] <= ~I_osc[8];
end

always begin
    #2 I_osc[9] <= ~I_osc[9];
end

endmodule
