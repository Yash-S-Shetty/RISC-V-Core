// 20 June 2026
// Testbench for imm_gen.sv
// tb_imm_gen.sv

import imm_gen_pkg::*;

module tb_imm_gen;
logic [31:0] tb_i_inst;
logic [2:0] tb_i_imm_sel;
logic [31:0] tb_o_ext_imm;

imm_gen DUT (.i_inst(tb_i_inst),
            .i_imm_sel(tb_i_imm_sel),
            .o_ext_imm(tb_o_ext_imm)
);

initial begin
    $dumpfile("sim/tb_imm_gen.vcd");
    $dumpvars(0, tb_imm_gen);
end

task check_imm(
input logic [31:0] inst,
input logic [2:0] imm_sel,
// input logic [31:0] ext_imm,
input logic [31:0] expected,
input string test_name
);

tb_i_inst = inst;
tb_i_imm_sel = imm_sel;
#5;
if (expected === tb_o_ext_imm) begin
    $display("Successful : Instruction=%b Immediate Select=%b Extended Immediate=%b Expected=%b Test Name=%s",
             inst, imm_sel, tb_o_ext_imm, expected, test_name);
end else begin
    $error("Fail : Instruction=%b Immediate Select=%b Extended Immediate=%b Expected=%b Test Name=%s",
           inst, imm_sel, tb_o_ext_imm, expected, test_name);
end

endtask

initial begin
    check_imm(32'h80012345, I_TYPE, 32'hFFFFF800, "I TYPE NEGATIVE");
    check_imm(32'h70012345, I_TYPE, 32'h00000700, "I TYPE POSITIVE");
    check_imm(32'h80FFF000, S_TYPE, 32'hFFFFF800, "S TYPE NEGATIVE");
    check_imm(32'h70FFF000, S_TYPE, 32'h00000700, "S TYPE POSITIVE");
    check_imm(32'b10000001111111111111000000000000, B_TYPE, 32'hFFFFF000, "B TYPE NEGATIVE");
    check_imm(32'b00000001111111111111000000000000, B_TYPE, 32'h00000000, "B TYPE ZERO");
    check_imm(32'h542306C5, B_TYPE, 32'h00000D4C, "B TYPE POSITIVE (MIXED)");
    check_imm(32'hABCDE123, U_TYPE, 32'hABCDE000, "U TYPE");
    check_imm(32'hAABAA4C2, J_TYPE, 32'hFFFAAAAA, "J TYPE NEGATIVE (MIXED)");
    check_imm(32'h5555BF84, J_TYPE, 32'h0005BD54, "J TYPE POSITIVE (MIXED)");
    check_imm(32'h12345678, R_TYPE, 32'h00000000, "R TYPE NO IMM");
    check_imm(32'h12345678, 3'b111, 32'h00000000, "INVALID IMM_SEL DEFAULT");
    $finish;
end

endmodule