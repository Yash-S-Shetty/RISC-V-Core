// tb_alu.sv
// Testbench for the ALU module
// 13-Jun-2026

import alu_pkg::*;

module tb_alu;
logic [31:0] tb_i_rs1;      // Source register 1
logic [31:0] tb_i_rs2;      // Source register 2 / immediate value
logic [3:0]  tb_i_alu_ctrl; // ALU operation select signal
logic [31:0] tb_o_result;   // ALU computation result
logic        tb_o_zero;     // High when tb_o_result == 0
// logic [31:0] tb_exp_result;    // Expected Result
// logic        tb_exp_zero;      // Expected Zero
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

task check_alu(
    input logic [31:0] t_i_rs1, 
    input logic [31:0] t_i_rs2, 
    input logic [3:0] t_i_alu_ctrl, 
    input logic [31:0] t_exp_result, 
    input logic t_exp_zero);
    tb_i_rs1 = t_i_rs1;
    tb_i_rs2 = t_i_rs2;
    tb_i_alu_ctrl =  t_i_alu_ctrl;
    #10;
    if ((tb_o_result === t_exp_result) && (tb_o_zero === t_exp_zero)) begin
        total_tests += 1;
        pass_count += 1;
        $display (" TEST PASSED : ALU_Ctrl=%b rs1=%h rs2=%h Expected=%h Actual=%h Expected_zero=%b Actual_zero=%b",
         t_i_alu_ctrl, t_i_rs1, t_i_rs2, t_exp_result, tb_o_result, t_exp_zero, tb_o_zero);
    end
    else begin
        total_tests += 1;
        fail_count += 1;
        $display (" TEST FAILED : ALU_Ctrl=%b rs1=%h rs2=%h Expected=%h Actual=%h Expected_zero=%b Actual_zero=%b",
         t_i_alu_ctrl, t_i_rs1, t_i_rs2, t_exp_result, tb_o_result, t_exp_zero, tb_o_zero);
    end
endtask

 
initial begin
    $dumpfile("sim/tb_alu.vcd");
    $dumpvars(0, tb_alu);
end

// Test 
// Directed test cases for each ALU operation
initial begin
    #10;
    // Test Add 3 + 5
    /* tb_i_rs1 = 32'd3;
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
    end */

    // Test End for ADDITION 3 + 5
    check_alu(32'd3, 32'd5, ALU_ADD, 32'd8, 1'd0);
    // Corner Cases
    check_alu(32'hFFFFFFFF, 32'd1, ALU_ADD, 32'd0, 1'd1); // -1 + 1 = 0 or wrap around to 0
    check_alu(32'h7FFFFFFF, 32'd1, ALU_ADD, 32'h80000000, 1'd0); // Most Positive + 1 = Wrap around to most -ve or Not a corner case in unsigned
    check_alu(32'd0, 32'd0, ALU_ADD, 32'd0, 1'd1);

    // Test for SUBTRACTION 32 - 25
    check_alu(32'd32, 32'd25, ALU_SUB, 32'd7, 1'd0);
    //Corner Cases 
    check_alu(32'd0, 32'd1, ALU_SUB, 32'hFFFFFFFF, 1'd0); // 0 - 1 = -1
    check_alu(32'h80000000, 32'd1, ALU_SUB, 32'h7FFFFFFF, 1'd0); // Most Negative - 1 = Most +ve 
    check_alu(32'd0, 32'd0, ALU_SUB, 32'd0, 1'd1);
    
    // Test For Bitwise Logical AND 0110 & 1010
    check_alu(32'b0110, 32'b1010, ALU_AND, 32'b0010, 1'd0);
    // Corner Cases 
    check_alu(32'd0, 32'd0, ALU_AND, 32'd0, 1'd1);
    check_alu(32'hFFFFFFFF, 32'd0, ALU_AND, 32'd0, 1'd1);
    check_alu(32'hFFFFFFFF, 32'hFFFFFFFF, ALU_AND, 32'hFFFFFFFF, 1'd0);

    // Test For Bitwise Logical OR 0110 | 1010 
    check_alu(32'b0110, 32'b1010, ALU_OR, 32'b1110, 1'd0);
    // Corner Cases
    check_alu(32'd0, 32'd0, ALU_OR, 32'd0, 1'd1);
    check_alu(32'hFFFFFFFF, 32'd0, ALU_OR, 32'hFFFFFFFF, 1'd0);
    check_alu(32'hFFFFFFFF, 32'hFFFFFFFF, ALU_OR, 32'hFFFFFFFF, 1'd0);

    // Test for Bitwise Logical XOR 0110 ^ 1010
    check_alu(32'b0110, 32'b1010, ALU_XOR, 32'b1100, 1'd0);
    // Corner Cases
    check_alu(32'd0, 32'd0, ALU_XOR, 32'd0, 1'd1);
    check_alu(32'hFFFFFFFF, 32'd0, ALU_XOR, 32'hFFFFFFFF, 1'd0);
    check_alu(32'h12345678, 32'h12345678, ALU_XOR, 32'd0, 1'd1);

    // Test for Shift Left Logical SLL 5 << 2
    check_alu(32'd5, 32'd2, ALU_SLL, 32'd20, 1'd0);
    // Corner Cases 
    check_alu(32'h00000001, 32'd0,  ALU_SLL, 32'h00000001, 1'd0);
    check_alu(32'h00000001, 32'd1,  ALU_SLL, 32'h00000002, 1'd0);
    check_alu(32'h00000001, 32'd31, ALU_SLL, 32'h80000000, 1'd0);
    check_alu(32'h80000000, 32'd1,  ALU_SLL, 32'h00000000, 1'd1);
    check_alu(32'hFFFFFFFF, 32'd4,  ALU_SLL, 32'hFFFFFFF0, 1'd0);
    check_alu(32'h00000005, 32'd32, ALU_SLL, 32'h00000005, 1'd0);
    check_alu(32'h00000005, 32'd33, ALU_SLL, 32'h0000000A, 1'd0);

    // Test for Shift Right Logical SRL 13 >> 2
    check_alu(32'd13, 32'd2, ALU_SRL, 32'd3, 1'd0);
    // Corner Cases
    check_alu(32'h80000000, 32'd0,  ALU_SRL, 32'h80000000, 1'd0);
    check_alu(32'h80000000, 32'd1,  ALU_SRL, 32'h40000000, 1'd0);
    check_alu(32'h80000000, 32'd31, ALU_SRL, 32'h00000001, 1'd0);
    check_alu(32'hFFFFFFFF, 32'd4,  ALU_SRL, 32'h0FFFFFFF, 1'd0);
    check_alu(32'h00000001, 32'd1,  ALU_SRL, 32'h00000000, 1'd1);
    check_alu(32'h12345678, 32'd32, ALU_SRL, 32'h12345678, 1'd0);
    check_alu(32'h12345678, 32'd33, ALU_SRL, 32'h091A2B3C, 1'd0);

    // Test for Shift Right Arithmetic SRA 12 >>> 2
    check_alu(32'd12, 32'd2, ALU_SRA, 32'd3, 1'd0);
    // Corner Cases
    check_alu(32'h80000000, 32'd0,  ALU_SRA, 32'h80000000, 1'd0);
    check_alu(32'h0000000C, 32'd2,  ALU_SRA, 32'h00000003, 1'd0);
    check_alu(32'h80000000, 32'd1,  ALU_SRA, 32'hC0000000, 1'd0);
    check_alu(32'h80000000, 32'd31, ALU_SRA, 32'hFFFFFFFF, 1'd0);
    check_alu(32'hFFFFFFFF, 32'd1,  ALU_SRA, 32'hFFFFFFFF, 1'd0);
    check_alu(32'h7FFFFFFF, 32'd1,  ALU_SRA, 32'h3FFFFFFF, 1'd0);
    check_alu(32'h80000000, 32'd32, ALU_SRA, 32'h80000000, 1'd0);
    check_alu(32'h80000000, 32'd33, ALU_SRA, 32'hC0000000, 1'd0);


    // Test for Set Less Than SLT 13 < 2 and 2 < 13
    check_alu(32'd13, 32'd2, ALU_SLT, 32'd0, 1'd1);
    check_alu(32'd2, 32'd13, ALU_SLT, 32'd1, 1'd0);
    // Corner Cases
    check_alu(32'h12345678, 32'h12345678, ALU_SLT, 32'd0, 1'd1);
    check_alu(32'd1, 32'hFFFFFFFF, ALU_SLT, 32'd0, 1'd1);
    check_alu(32'hFFFFFFFF, 32'd1, ALU_SLT, 32'd1, 1'd0);

    // Test for Set Less Than Unsigned SLTU 13 < 2 and 2 < 13
    check_alu(32'd13, 32'd2, ALU_SLTU, 32'd0, 1'd1);
    check_alu(32'd2, 32'd13, ALU_SLTU, 32'd1, 1'd0);
    // Corner Cases
    check_alu(32'h12345678, 32'h12345678, ALU_SLTU, 32'd0, 1'd1);
    check_alu(32'd1, 32'hFFFFFFFF, ALU_SLTU, 32'd1, 1'd0);
    check_alu(32'hFFFFFFFF, 32'd1, ALU_SLTU, 32'd0, 1'd1);

    // Test for ALU Pass (For LUI) 2nd value (tb_i_rs2 is passed)
    check_alu(32'd13, 32'd12, ALU_PASS, 32'd12, 1'd0);
    check_alu(32'hFFFFFFFF, 32'h12345000, ALU_PASS, 32'h12345000, 1'd0);
    check_alu(32'hAAAAAAAA, 32'h00000000, ALU_PASS, 32'h00000000, 1'd1);
   
    // INVALID / DEFAULT TEST CASES
    check_alu(32'd10, 32'd20, 4'b1011, 32'd0, 1'd1);
    check_alu(32'hFFFFFFFF, 32'h12345678, 4'b1111, 32'd0, 1'd1);

$display("====================================");
$display("TOTAL TESTS = %0d", total_tests);
$display("PASSED      = %0d", pass_count);
$display("FAILED      = %0d", fail_count);
$display("====================================");

   #100 $finish;
end


endmodule