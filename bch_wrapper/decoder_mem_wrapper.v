/*
 * A Wrapper for BCH Decoder and memory access
 *
 * Copyright 2015 - Lix Wei <ultracold273@outlook.com>
 * Decoder Module comes from Russ Dill
 *
 * Input codeword and access syndromes stored at memory
 */
`include "../bch_verilog/bch_defs.vh"
module bch_wrapper_decoder_mem
#(
parameter [`BCH_PARAM_SZ-1:0] C_P = `BCH_SANE,
parameter C_I_DATABITS = 4,
parameter C_I_ERRORS = 3,
parameter C_BITS = 1,
parameter C_MEM_ADDR_SIZE = 10,
parameter C_MEM_DATA_SIZE = 8,
parameter C_MEM_ST_ADDR = 0
)
(
input                               I_clk,
input                               I_start,
input                               I_en,
input [C_I_DATABITS-1:0]            I_data,
input [C_MEM_DATA_SIZE-1:0]         I_mem_data,
output [C_I_DATABITS-1:0]           O_data,
output reg [C_MEM_ADDR_SIZE-1:0]    O_mem_addr,
output                              O_ready
);

`include "../bch_verilog/bch.vh"
localparam LP_E_BITS = `BCH_ECC_BITS(C_P);
localparam LP_MEM_CYCLE = LP_E_BITS / C_MEM_DATA_SIZE + 1;

reg S_start_d;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_start_d <= 0;
    end else begin
        S_start_d <= I_start;
    end
end

reg S_mem_rd_start;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_mem_rd_start <= 0;
    end else if (S_start_d == 0 && I_start == 1) begin
        S_mem_rd_start <= 1;
    end else begin
        S_mem_rd_start <= 0;
    end
end

always @(posedge I_clk) begin
    if (!I_en) begin
        O_mem_addr <= 0;
    end else if (S_mem_rd_start) begin
        O_mem_addr <= C_MEM_ST_ADDR + LP_MEM_CYCLE - 1;
    end else if (S_mem_rd_busy) begin
        O_mem_addr <= O_mem_addr - 1;
    end
end

reg S_mem_rd_busy;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_mem_rd_busy <= 0;
    end else if (S_mem_rd_start) begin
        S_mem_rd_busy <= 1;
    end else if (W_mem_rd_done) begin
        S_mem_rd_busy <= 0;
    end
end

wire W_mem_rd_done = &S_mem_rd_count;

reg [`BCH_ECC_BITS(C_P)-1:0] R_ECC_in;
always @(posedge I_clk) begin
    if (!I_en) begin
        R_ECC_in <= 0;
    end else if (S_mem_rd_start) begin
        R_ECC_in <= 0;
    end else if (S_mem_rd_busy && !W_mem_rd_done) begin
    /*
        R_ECC_in <= R_ECC_in >> C_MEM_DATA_SIZE;
        // TODO: Here is not correct!!!
        R_ECC_in[`BCH_ECC_BITS(C_P)-1-:C_MEM_DATA_SIZE] <= I_mem_data;*/
        R_ECC_in <= R_ECC_in << C_MEM_DATA_SIZE;
        R_ECC_in[C_MEM_DATA_SIZE-1:0] <= I_mem_data;
    end
end

reg [LP_MEM_CYCLE-1:0] S_mem_rd_count;
always @(posedge I_clk) begin
    if (!I_en) begin
        S_mem_rd_count <= 0;
    end else if (S_mem_rd_start) begin
        S_mem_rd_count <= 0;
    end else if (S_mem_rd_busy) begin
        S_mem_rd_count <= {S_mem_rd_count, 1'd1};
    end
end

reg R_decoder_en;
always @(posedge I_clk) begin
    if (!I_en) begin
        R_decoder_en <= 0;
    end else begin
        R_decoder_en <= 1;
    end
end

wire [`BCH_CODE_BITS(C_P)-1:0] W_data = {I_data, R_ECC_in};

bch_wrapper_decoder #(C_P, C_I_DATABITS, C_I_ERRORS, C_BITS) u_wrapper_dec (
    .I_clk(I_clk),
    .I_start(W_mem_rd_done),
    .I_en(R_decoder_en),
    .I_data(W_data),
    .O_data(O_data),
    .O_ready(O_ready)
);

endmodule
