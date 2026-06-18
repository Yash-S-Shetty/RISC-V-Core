// Register File for the RISC-V Core
// regfile.sv
// 16 June 2026

module regfile(
    input logic i_clk,
    input logic i_wr_en, // Active High
    input logic i_rst_n, // Active Low
    input logic [4:0] i_rs1_address,
    input logic [4:0] i_rs2_address,
    input logic [4:0] i_rd_address,
    input logic [31:0] i_rd_wb,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data
);

logic [31:0] regfile [31:0];

always_ff @(posedge i_clk) begin
    if (!i_rst_n) for (int i=0; i<32; i++) regfile[i] <= 32'b0;
    else if (i_wr_en && (i_rd_address != 5'd0)) regfile[i_rd_address] <= i_rd_wb;
end

assign o_rs1_data = (i_rs1_address == 5'd0) ? 32'b0 : regfile[i_rs1_address];
assign o_rs2_data = (i_rs2_address == 5'd0) ? 32'b0 : regfile[i_rs2_address];

endmodule