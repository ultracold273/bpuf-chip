/*
 * A Testbench for controller.v
 * Generate the control signal for all modules on chip depending on the inputs
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 *
 * Include the Reset signal for meas.v
 * clock signal for bch related modules
 * control signals for memory module
 */
`include "../bch_verilog/bch_params.vh"

module test_controller_all();

/* Mutable Parameter */
localparam OSC_ELEM_NUM = 48;
localparam OSC_REG_WIDTH = 24;

localparam DATA_BITS = 24;
localparam ERROR_BITS = 3;

localparam MEM_ADDR_WIDTH = 6;
localparam MEM_DATA_WIDTH = 8;
localparam MEM_PAIR_ST_ADDR = 0;
localparam MEM_ECC_ST_ADDR = MEM_PAIR_ST_ADDR + 2 * DATA_BITS;

localparam CON_MODE_WIDTH = 2;
localparam CON_OSC_CNT_WIDTH = 20;

 /* Immutable Parameter */
localparam C_BITS = 1;

/* Local Parameter */
localparam C_P = bch_params(DATA_BITS, ERROR_BITS);

/* Temperary signals */
reg clk;
reg mode;
reg en;
reg start;

wire ready;

/* Output of controller */
wire i_clk;
wire i_meas_rst;
wire i_enc_en;
wire i_enc_start;
wire i_dec_en;
wire i_dec_start;

controller #(CON_MODE_WIDTH, CON_OSC_CNT_WIDTH) u_con (
    .I_clk(clk),
    .I_mode(mode),
    .I_start(start),
    .I_en(en),
    .O_clk(i_clk),
    .I_meas_v(meas_out_v),
    .O_meas_rst(i_meas_rst),
    .O_enc_en(i_enc_en),
    .O_enc_start(i_enc_start),
    .I_enc_ready(enc_out_ready),
    .O_dec_en(i_dec_en),
    .O_dec_start(i_dec_start),
    .I_dec_ready(dec_out_ready),
    .O_ready(ready)
);

/* Temperary Signals */
reg [OSC_ELEM_NUM-1:0] osc;

/* Output of meas */
wire [MEM_ADDR_WIDTH-1:0] meas_out_mem_addr;
wire [DATA_BITS-1:0] meas_out_id;
wire meas_out_v;

meas #(OSC_ELEM_NUM, OSC_REG_WIDTH, DATA_BITS,
    MEM_DATA_WIDTH, MEM_ADDR_WIDTH, MEM_PAIR_ST_ADDR) u_meas (
    .I_osc_rst(i_meas_rst),
    .I_osc(osc),
    .I_sclk(i_clk),
    .I_mem_data(mem_out_data),
    .O_mem_addr(meas_out_mem_addr),
    .O_prim_id(meas_out_id),
    .O_id_v(meas_out_v)
);

/* Temperary Signals */
wire [DATA_BITS-1:0] data_out;

/* Output of decoder wrapper */
wire [MEM_ADDR_WIDTH-1:0] dec_out_mem_addr;
wire dec_out_ready;

bch_wrapper_decoder_mem #(C_P, DATA_BITS, ERROR_BITS, C_BITS
    MEM_ADDR_WIDTH, MEM_DATA_WIDTH, MEM_ECC_ST_ADDR) u_decoder (
    .I_clk(i_clk),
    .I_start(i_dec_start),
    .I_en(i_dec_en),
    .I_data(meas_out_id),
    .I_mem_data(mem_out_data),
    .O_data(data_out),
    .O_mem_addr(dec_out_mem_addr),
    .O_ready(dec_out_ready)
);

/* Output of encoder wrapper */
wire [MEM_ADDR_WIDTH-1:0] enc_out_mem_addr;
wire [MEM_DATA_WIDTH-1:0] enc_out_mem_data;
wire enc_out_mem_wen;
wire enc_out_ready;

bch_wrapper_encoder #(C_P, DATA_BITS, ERROR_BITS, C_BITS
    MEM_ECC_ST_ADDR, MEM_ADDR_WIDTH, MEM_DATA_WIDTH) u_encoder (
    .I_clk(i_clk),
    .I_data(meas_out_id),
    .I_start(i_enc_start),
    .I_en(i_enc_en),
    .O_mem_waddr(enc_out_mem_addr),
    .O_mem_wdata(enc_out_mem_data),
    .O_wen(enc_out_mem_wen),
    .O_ready(enc_out_ready)
);

/* Output of synmem module */
wire [MEM_DATA_WIDTH-1:0] mem_out_data;

/* MUX of input address of synmem module */
wire [MEM_ADDR_WIDTH-1:0] mem_in_addr = (i_enc_en) ? (enc_out_mem_addr):(i_dec_en) ? (dec_out_mem_addr) : (meas_out_mem_addr);

syn_mem #(MEM_ADDR_WIDTH, MEM_DATA_WIDTH) u_syn_mem (
    .I_clk(i_clk),
    .I_wen(enc_out_mem_wen),
    .I_wdata(enc_out_mem_data),
    .I_addr(mem_in_addr),
    .O_data(mem_out_data)
);

initial begin
    clk <= 0;
    en <= 0;
    start <= 0;
    
end

always begin
    #5 clk <= ~clk;
end

endmodule
