// PC Register for the Pipeline
// pc_reg.sv
// 30 June 2026

module pc_reg(
    input logic i_clk,
    input logic i_reset_n,
    input logic [31:0] i_pc_next,
    output logic [31:0] o_pc
);

always_ff @(posedge i_clk) begin
    if(!i_reset_n) o_pc <= 32'd0;  // Sync Active Low Reset
    else o_pc <= i_pc_next;
end

endmodule
