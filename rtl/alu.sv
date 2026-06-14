// alu.sv
// First RTL code for the RISC-V Project
// 12-Jun-2026 

import alu_pkg::*;

module alu (
    input  logic [31:0] i_rs1,      // Source register 1 (unsigned at port, cast when needed)
    input  logic [31:0] i_rs2,      // Source register 2 / immediate value
    input  logic [3:0]  i_alu_ctrl, // ALU operation select signal from decoder
    output logic [31:0] o_result,   // ALU computation result
    output logic        o_zero      // High when o_result == 0, used for branch decisions
);

    always_comb begin
        o_result = 32'b0; // Default prevents latch inference on missing cases

        unique case (i_alu_ctrl)
            ALU_ADD  : o_result = i_rs1 + i_rs2;                                        // ADD/ADDI: integer addition, overflow ignored per spec
            ALU_SUB  : o_result = i_rs1 - i_rs2;                                        // SUB: integer subtraction, overflow ignored per spec
            ALU_AND  : o_result = i_rs1 & i_rs2;                                        // AND/ANDI: bitwise and
            ALU_OR   : o_result = i_rs1 | i_rs2;                                        // OR/ORI: bitwise or
            ALU_XOR  : o_result = i_rs1 ^ i_rs2;                                        // XOR/XORI: bitwise xor
            ALU_SLL  : o_result = i_rs1 << i_rs2[4:0];                                  // SLL/SLLI: logical left shift, only lower 5 bits used per spec
            ALU_SRL  : o_result = i_rs1 >> i_rs2[4:0];                                  // SRL/SRLI: logical right shift, zeros fill upper bits
            ALU_SRA  : o_result = $signed(i_rs1) >>> i_rs2[4:0];                        // SRA/SRAI: arithmetic right shift, sign bit fills upper bits
            ALU_SLT  : o_result = ($signed(i_rs1) < $signed(i_rs2)) ? 32'b1 : 32'b0;   // SLT/SLTI: signed compare, writes 1 if rs1 < rs2
            ALU_SLTU : o_result = (i_rs1 < i_rs2) ? 32'b1 : 32'b0;                     // SLTU/SLTIU: unsigned compare, both operands treated as unsigned
            ALU_PASS : o_result = i_rs2;                                                 // LUI: upper immediate passed through, datapath zeroes lower 12 bits before sending
            default  : o_result = 32'b0;                                                 // Safety net for undefined ctrl values
        endcase
    end

    assign o_zero = (o_result == 32'b0); // Combinational flag, wired directly outside always_comb

endmodule
