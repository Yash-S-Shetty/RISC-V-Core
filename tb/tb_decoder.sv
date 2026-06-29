// Testbech for Decoder
// tb_decoder.sv
// 28 June 2026

`define CHECK_FIELD(field, name) \
        if (tb_o_``field``!== expected_t.``field``) begin \
            $display("FAIL [%s]: %s expected=%b got=%b", test_name, name, expected_t.``field``, tb_o_``field``); \
            test_pass = 1'b0; \
    end

import imm_gen_pkg::*;
import alu_pkg::*;
import opcode_pkg::*;

module tb_decoder;
logic [6:0] tb_i_opcode; // 7-bit Opcode
logic [2:0] tb_i_funct3; // funct3  
logic tb_i_funct7_b5; // Only the bit inst[30] 
logic [3:0] tb_o_alu_ctrl; // ALU operation selection
logic [2:0] tb_o_imm_sel; // Immediate type select
logic tb_o_alu_src; // 0 for rs2 and 1 for immediate
logic tb_o_reg_wr; // Register-file write enable
logic tb_o_mem_rd; // Data Memory Read
logic tb_o_mem_wr; // Data Memory Write
logic [1:0] tb_o_result_src; // 00 = ALU, 01=Mem 10=PC+4 11=PC+IMM
logic tb_o_jump; // Jump
logic tb_o_branch; // Branch
int pass_count = 0;
int fail_count = 0;
int total_tests = 0;

decoder DUT(
    .i_opcode(tb_i_opcode),
    .i_funct3(tb_i_funct3),
    .i_funct7_b5(tb_i_funct7_b5),
    .o_alu_ctrl(tb_o_alu_ctrl),
    .o_imm_sel(tb_o_imm_sel),
    .o_alu_src(tb_o_alu_src),
    .o_reg_wr(tb_o_reg_wr),
    .o_mem_rd(tb_o_mem_rd),
    .o_mem_wr(tb_o_mem_wr),
    .o_result_src(tb_o_result_src),
    .o_jump(tb_o_jump),
    .o_branch(tb_o_branch)
);

initial begin
    $dumpfile("sim/tb_decoder.vcd");
    $dumpvars(0, tb_decoder);
end

typedef struct packed{
    logic [3:0] alu_ctrl; // ALU operation selection
    logic [2:0] imm_sel; // Immediate type select
    logic alu_src; // 0 for rs2 and 1 for immediate
    logic reg_wr; // Register-file write enable
    logic mem_rd; // Data Memory Read
    logic mem_wr; // Data Memory Write
    logic [1:0] result_src; // 00 = ALU, 01=Mem 10=PC+4 11=PC+IMM
    logic jump; // Jump
    logic branch; // Branch 
} expected_outputs;

task check_decoder(
    input logic [6:0] t_i_opcode, // 7-bit Opcode
    input logic [2:0] t_i_funct3, // funct3  
    input logic t_i_funct7_b5, // Only the bit inst[30] 
    input expected_outputs expected_t,
    input string test_name,
    input logic check_alu // Needed to ignore ALU checks 
    );

    logic test_pass;
    test_pass = 1'b1;

    tb_i_opcode = t_i_opcode;
    tb_i_funct3 = t_i_funct3;
    tb_i_funct7_b5 = t_i_funct7_b5;

    #10;

    `CHECK_FIELD(reg_wr, "reg_wr")
    `CHECK_FIELD(mem_rd, "mem_rd")
    `CHECK_FIELD(mem_wr, "mem_wr")
    `CHECK_FIELD(result_src, "result_src")
    `CHECK_FIELD(jump, "jump")
    `CHECK_FIELD(branch, "branch")
    `CHECK_FIELD(imm_sel, "imm_sel")
    if (check_alu) begin
        `CHECK_FIELD(alu_ctrl, "alu_ctrl")
        `CHECK_FIELD(alu_src, "alu_src")
    end

    total_tests = total_tests + 1;
    if (test_pass) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

endtask

initial begin

// ---------------- OP (R-type) ----------------
check_decoder(OP, 3'b000, 1'b0, '{ALU_ADD,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "ADD",  1'b1);
check_decoder(OP, 3'b000, 1'b1, '{ALU_SUB,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SUB",  1'b1);
check_decoder(OP, 3'b001, 1'b0, '{ALU_SLL,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SLL",  1'b1);
check_decoder(OP, 3'b010, 1'b0, '{ALU_SLT,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SLT",  1'b1);
check_decoder(OP, 3'b011, 1'b0, '{ALU_SLTU, R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SLTU", 1'b1);
check_decoder(OP, 3'b100, 1'b0, '{ALU_XOR,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "XOR",  1'b1);
check_decoder(OP, 3'b101, 1'b0, '{ALU_SRL,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SRL",  1'b1);
check_decoder(OP, 3'b101, 1'b1, '{ALU_SRA,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SRA",  1'b1);
check_decoder(OP, 3'b110, 1'b0, '{ALU_OR,   R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "OR",   1'b1);
check_decoder(OP, 3'b111, 1'b0, '{ALU_AND,  R_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "AND",  1'b1);

// ---------------- OP_IMM (I-type ALU) ----------------
check_decoder(OP_IMM, 3'b000, 1'b0, '{ALU_ADD,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "ADDI",  1'b1);
check_decoder(OP_IMM, 3'b010, 1'b0, '{ALU_SLT,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SLTI",  1'b1);
check_decoder(OP_IMM, 3'b011, 1'b0, '{ALU_SLTU, I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SLTIU", 1'b1);
check_decoder(OP_IMM, 3'b100, 1'b0, '{ALU_XOR,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "XORI",  1'b1);
check_decoder(OP_IMM, 3'b110, 1'b0, '{ALU_OR,   I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "ORI",   1'b1);
check_decoder(OP_IMM, 3'b111, 1'b0, '{ALU_AND,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "ANDI",  1'b1);
check_decoder(OP_IMM, 3'b001, 1'b0, '{ALU_SLL,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SLLI",  1'b1);
check_decoder(OP_IMM, 3'b101, 1'b0, '{ALU_SRL,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SRLI",  1'b1);
check_decoder(OP_IMM, 3'b101, 1'b1, '{ALU_SRA,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "SRAI",  1'b1);

// ---------------- U-type / Jumps ----------------
check_decoder(LUI,   3'b000, 1'b0, '{ALU_PASS, U_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "LUI",   1'b1);
check_decoder(AUIPC, 3'b000, 1'b0, '{ALU_ADD,  U_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0}, "AUIPC", 1'b0); // alu fields don't-care
check_decoder(JAL,   3'b000, 1'b0, '{ALU_ADD,  J_TYPE, 1'b0, 1'b1, 1'b0, 1'b0, 2'b10, 1'b1, 1'b0}, "JAL",   1'b0); // alu fields don't-care
check_decoder(JALR,  3'b000, 1'b0, '{ALU_ADD,  I_TYPE, 1'b1, 1'b1, 1'b0, 1'b0, 2'b10, 1'b1, 1'b0}, "JALR",  1'b1);

// ---------------- BRANCH ----------------
check_decoder(BRANCH, 3'b000, 1'b0, '{ALU_SUB,  B_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1}, "BEQ",  1'b1);
check_decoder(BRANCH, 3'b001, 1'b0, '{ALU_SUB,  B_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1}, "BNE",  1'b1);
check_decoder(BRANCH, 3'b100, 1'b0, '{ALU_SLT,  B_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1}, "BLT",  1'b1);
check_decoder(BRANCH, 3'b101, 1'b0, '{ALU_SLT,  B_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1}, "BGE",  1'b1);
check_decoder(BRANCH, 3'b110, 1'b0, '{ALU_SLTU, B_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1}, "BLTU", 1'b1);
check_decoder(BRANCH, 3'b111, 1'b0, '{ALU_SLTU, B_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1}, "BGEU", 1'b1);

// ---------------- LOAD / STORE ----------------
check_decoder(LOAD,  3'b010, 1'b0, '{ALU_ADD, I_TYPE, 1'b1, 1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0}, "LOAD (LW rep)",  1'b1);
check_decoder(STORE, 3'b010, 1'b0, '{ALU_ADD, S_TYPE, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0}, "STORE (SW rep)", 1'b1);

// ---------------- MISC_MEM / SYSTEM (NOPs) ----------------
check_decoder(MISC_MEM, 3'b000, 1'b0, '{ALU_ADD, I_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "FENCE", 1'b1);
check_decoder(SYSTEM,   3'b000, 1'b0, '{ALU_ADD, I_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "ECALL/EBREAK", 1'b1);

// ---------------- default (illegal opcode) ----------------
check_decoder(7'b0000000, 3'b000, 1'b0, '{ALU_ADD, R_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0}, "ILLEGAL_OPCODE", 1'b1);

    $display("%0d/%0d tests passed", pass_count, total_tests);
    $finish;
end

endmodule
