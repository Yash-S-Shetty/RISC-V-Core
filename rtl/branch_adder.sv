// Branch Adder
// branch_adder.sv
// 1 July 2026
// Covers Branches and JAL

module branch_adder(
    input logic [31:0] i_pc,
    input logic [31:0] i_imm,
    output logic [31:0] o_branch_target
);

assign o_branch_target = i_pc + i_imm;

endmodule