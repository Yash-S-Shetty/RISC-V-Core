// Decoder Unit / Control Unit for RISC-V 
// decoder.sv
// 23 June 2026

import imm_gen_pkg::*;
import alu_pkg::*;
import opcode_pkg::*;

module decoder(
    input logic [6:0] i_opcode, // 7-bit Opcode
    input logic [2:0] i_funct3, // funct3  
    input logic i_funct7_b5, // Only the bit inst[30] 
    output logic [3:0] o_alu_ctrl, // ALU operation selection
    output logic [2:0] o_imm_sel, // Immediate type select
    output logic o_alu_src, // 0 for rs2 and 1 for immediate
    output logic o_reg_wr, // Register-file write enable
    output logic o_mem_rd, // Data Memory Read
    output logic o_mem_wr, // Data Memory Write
    output logic [1:0] o_result_src, // 00 = ALU, 01=Mem 10=PC+4 11=PC+IMM
    output logic o_jump, // Jump
    output logic o_branch // Branch
);

always_comb begin 
    // PRE Default
    o_alu_src = 1'b0;       // Register
    o_reg_wr = 1'b0;        // No Register Writeback
    o_mem_rd = 1'b0;        // No Memory Read
    o_mem_wr = 1'b0;        // No Memory Write
    o_result_src = 2'b00;   // 00 = ALU
    o_jump = 1'b0;          // No Jump
    o_branch = 1'b0;        // No Branch
    o_imm_sel = R_TYPE;     // No Immediate
    o_alu_ctrl = ALU_ADD;   // ALU_ADD
    
    unique case (i_opcode)
        OP      :   begin
                        o_alu_src = 1'b0;       // Register rs2 for Reg-Reg case
                        o_reg_wr = 1'b1;        // Register writeback 
                        o_mem_rd = 1'b0;        // No Memory Read
                        o_mem_wr = 1'b0;        // No Memory Write
                        o_result_src = 2'b00;   // From ALU 
                        o_jump = 1'b0;          // No Jump
                        o_branch = 1'b0;        // No Branch
                        o_imm_sel = R_TYPE;     // R_TYPE Instruction
                        unique case (i_funct3)
                            3'b000  :   unique case (i_funct7_b5) 
                                            1'b0 : o_alu_ctrl = ALU_ADD;
                                            1'b1 : o_alu_ctrl = ALU_SUB;
                                        endcase
                            3'b001  :   o_alu_ctrl = ALU_SLL;
                            3'b010  :   o_alu_ctrl = ALU_SLT;
                            3'b011  :   o_alu_ctrl = ALU_SLTU;
                            3'b100  :   o_alu_ctrl = ALU_XOR;
                            3'b101  :   unique case (i_funct7_b5) 
                                            1'b0 : o_alu_ctrl = ALU_SRL;
                                            1'b1 : o_alu_ctrl = ALU_SRA;
                                        endcase
                            3'b110  :   o_alu_ctrl = ALU_OR;
                            3'b111  :   o_alu_ctrl = ALU_AND;
                        endcase 
                    end
        OP_IMM  :   begin
                        o_alu_src = 1'b1;       // Immediate for Imm-Reg case
                        o_reg_wr = 1'b1;        // Register Writeback
                        o_mem_rd = 1'b0;        // No Memory Read
                        o_mem_wr = 1'b0;        // No Memory Write
                        o_result_src = 2'b00;   // From ALU
                        o_jump = 1'b0;          // No Jump
                        o_branch = 1'b0;        // No Branch
                        o_imm_sel = I_TYPE;     // I_TYPE Instruction
                        unique case (i_funct3)
                            3'b000  :   o_alu_ctrl = ALU_ADD;
                            3'b010  :   o_alu_ctrl = ALU_SLT;
                            3'b011  :   o_alu_ctrl = ALU_SLTU;
                            3'b100  :   o_alu_ctrl = ALU_XOR;
                            3'b110  :   o_alu_ctrl = ALU_OR;
                            3'b111  :   o_alu_ctrl = ALU_AND;
                            3'b001  :   o_alu_ctrl = ALU_SLL;
                            3'b101  :   unique case (i_funct7_b5) 
                                            1'b0 : o_alu_ctrl = ALU_SRL;
                                            1'b1 : o_alu_ctrl = ALU_SRA;
                                        endcase
                                endcase
                        end 
        LUI     :   begin
                        o_alu_src = 1'b1;       // Immediate 
                        o_reg_wr = 1'b1;        // Register Writeback
                        o_mem_rd = 1'b0;        // No Memory Read
                        o_mem_wr = 1'b0;        // No Memory Write
                        o_result_src = 2'b00;   // 00 = ALU (bypass from ALU)
                        o_jump = 1'b0;          // No Jump
                        o_branch = 1'b0;        // No Branch
                        o_imm_sel = U_TYPE;     // U_TYPE Immediate
                        o_alu_ctrl = ALU_PASS;  // ALU_PASS
                    end
        AUIPC   :   begin
                        // o_alu_src = 1'b1;        // No Use of ALU here
                        o_reg_wr = 1'b1;            // Register Writeback
                        o_mem_rd = 1'b0;            // No Memory Read
                        o_mem_wr = 1'b0;            // No Memory Write
                        o_result_src = 2'b11;       // 11 = PC+IMM From Branch adder
                        o_jump = 1'b0;              // No Jump
                        o_branch = 1'b0;            // No Branch
                        o_imm_sel = U_TYPE;         // U_TYPE Immediate
                        // o_alu_ctrl = ALU_ADD;    // No Use of ALU here
                    end
        JAL     :   begin
                        // o_alu_src = 1'b1;        // No Use of ALU here
                        o_reg_wr = 1'b1;            // Register Writeback
                        o_mem_rd = 1'b0;            // No Memory Read
                        o_mem_wr = 1'b0;            // No Memory Write
                        o_result_src = 2'b10;       // 10 = PC+4 from PC adder
                        o_jump = 1'b1;              // Jump
                        o_branch = 1'b0;            // No Branch
                        o_imm_sel = J_TYPE;         // J_TYPE Immediate
                        // o_alu_ctrl = ALU_ADD;    // No Use of ALU here
                    end
        JALR    :   begin
                        o_alu_src = 1'b1;           // Immediate
                        o_reg_wr = 1'b1;            // Register Writeback
                        o_mem_rd = 1'b0;            // No Memory Read
                        o_mem_wr = 1'b0;            // No Memory Write
                        o_result_src = 2'b10;       // 10 = PC+4 from PC Adder
                        o_jump = 1'b1;              // Jump
                        o_branch = 1'b0;            // No Branch
                        o_imm_sel = I_TYPE;         // I_TYPE Immediate
                        o_alu_ctrl = ALU_ADD;       // rs1+imm
                    end
        BRANCH  :   begin
                        o_alu_src = 1'b0;           // Not Immediate case
                        o_reg_wr = 1'b0;            // No register Writeback
                        o_mem_rd = 1'b0;            // No Read from memory
                        o_mem_wr = 1'b0;            // No write to memory
                        // o_result_src = 2'b00;    // No Writeback 
                        o_jump = 1'b0;              // No Jump
                        o_branch = 1'b1;            // Branch
                        o_imm_sel = B_TYPE;         // Immediate    
                        unique case (i_funct3)
                            3'b000  :   o_alu_ctrl = ALU_SUB;  // BEQ
                            3'b001  :   o_alu_ctrl = ALU_SUB;  // BNE
                            3'b100  :   o_alu_ctrl = ALU_SLT;  // BLT
                            3'b101  :   o_alu_ctrl = ALU_SLT;  // BGE
                            3'b110  :   o_alu_ctrl = ALU_SLTU; // BLTU
                            3'b111  :   o_alu_ctrl = ALU_SLTU; // BGEU
                        endcase
                    end
        LOAD    :   begin
                        o_alu_src = 1'b1;       // Immediate case
                        o_reg_wr = 1'b1;        // Writeback the Memory Data to the register
                        o_mem_rd = 1'b1;        // Read Load value from memory
                        o_mem_wr = 1'b0;        // No write to memory
                        o_result_src = 2'b01;   // Write-Back from memory
                        o_jump = 1'b0;          // No Jump
                        o_branch = 1'b0;        // No Branch
                        o_imm_sel = I_TYPE;     // Immediate type   
                        o_alu_ctrl = ALU_ADD;   // Effective address = rs1 + immediate
                        // Pass funct3 down the pipeline to handle LB, LH, LW, LBU, LHU 
                    end   
        STORE   :   begin
                        o_alu_src = 1'b1;       // Immediate case
                        o_reg_wr = 1'b0;        // No writeback to Register
                        o_mem_rd = 1'b0;        // No Memory Read
                        o_mem_wr = 1'b1;        // Write to memory
                        // o_result_src = 2'b00;   // No Write-Back
                        o_jump = 1'b0;          // No Jump
                        o_branch = 1'b0;        // No Branch
                        o_imm_sel = S_TYPE;     // Store Type Immediate    
                        o_alu_ctrl = ALU_ADD;   // Effective address = rs1 + immediate
                        // Pass funct3 down the pipeline to handle SB, SH, SW
                    end
        MISC_MEM:   begin
                        o_alu_src    = 1'b0;
                        o_reg_wr     = 1'b0;
                        o_mem_rd     = 1'b0;
                        o_mem_wr     = 1'b0;
                        o_result_src = 2'b00;
                        o_jump       = 1'b0;
                        o_branch     = 1'b0;
                        o_imm_sel    = I_TYPE;
                        o_alu_ctrl   = ALU_ADD;
                    end
        SYSTEM  :   begin
                        o_alu_src    = 1'b0;
                        o_reg_wr     = 1'b0;
                        o_mem_rd     = 1'b0;
                        o_mem_wr     = 1'b0;
                        o_result_src = 2'b00;
                        o_jump       = 1'b0;
                        o_branch     = 1'b0;
                        o_imm_sel    = I_TYPE;
                        o_alu_ctrl   = ALU_ADD;
                    end
        default :   begin    
                        o_alu_src    = 1'b0;
                        o_reg_wr     = 1'b0;
                        o_mem_rd     = 1'b0;
                        o_mem_wr     = 1'b0;
                        o_result_src = 2'b00;
                        o_jump       = 1'b0;
                        o_branch     = 1'b0;
                        o_imm_sel    = R_TYPE;
                        o_alu_ctrl   = ALU_ADD;
                    end
    endcase
end
endmodule



