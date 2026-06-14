// tb_alu.sv
// Testbench for the ALU module
// 13-Jun-2026

import alu_pkg::*;

module alu_tb;
logic [31:0] tb_i_rs1;      // Source register 1
logic [31:0] tb_i_rs2;      // Source register 2 / immediate value
logic [3:0]  tb_i_alu_ctrl; // ALU operation select signal
logic [31:0] tb_o_result;   // ALU computation result
logic        tb_o_zero;     // High when tb_o_result == 0
logic [31:0] tb_exp_result;    // Expected Result
logic        tb_exp_zero;      // Expected Zero
int pass_count = 0;
int fail_count = 0;
int total_tests = 0;

alu dut (
    .i_rs1(tb_i_rs1), 
    .i_rs2(tb_i_rs2), 
    .i_alu_ctrl(tb_i_alu_ctrl), 
    .o_result(tb_o_result), 
    .o_zero(tb_o_zero)
);

initial begin
    $dumpfile("sim/alu_tb.vcd");
    $dumpvars(0, alu_tb);
end

// Test 
// Directed test cases for each ALU operation
initial begin
    // Test Add 3 + 5
    tb_i_rs1 = 32'd3;
    tb_i_rs2 = 32'd5;
    tb_i_alu_ctrl = ALU_ADD;
    tb_exp_result = 32'd8;
    tb_exp_zero = 1'd0;
    #10;
    if ((tb_o_result == tb_exp_result) && (tb_exp_zero == tb_o_zero)) begin
        total_tests += 1;
        pass_count += 1;
        $display (" TEST PASSED for 3 + 5 = 8");
    end
    else begin
        total_tests += 1;
        fail_count += 1;
        $display (" TEST FAILED for 3 + 5 = 8");
    end
end

initial #20 $finish;
endmodule