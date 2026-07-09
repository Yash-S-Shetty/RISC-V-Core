// tb_store_mask.sv
// 9 July 2026
// Testbench for Store Mask

module tb_store_mask;
logic [2:0] tb_i_funct3;
logic [1:0] tb_i_addr;
logic [31:0] tb_i_reg_data;
logic [31:0] tb_o_mem_wdata;
logic [3:0] tb_o_mem_wmask;
int pass_count = 0;
int fail_count = 0;

store_mask DUT(
    .i_funct3(tb_i_funct3),
    .i_addr(tb_i_addr),
    .i_reg_data(tb_i_reg_data),
    .o_mem_wdata(tb_o_mem_wdata),
    .o_mem_wmask(tb_o_mem_wmask)
);

initial begin
    $dumpfile("sim/tb_store_mask.vcd");
    $dumpvars(0, tb_store_mask);
end

task check_str_msk(
    input logic [2:0] t_i_funct3, 
    input logic [1:0] t_i_addr, 
    input logic [31:0] t_i_reg_data, 
    input logic [31:0] t_exp_wdata,
    input logic [3:0] t_exp_wmask,
    input string name
    );
    
    tb_i_funct3 = t_i_funct3;
    tb_i_addr = t_i_addr;
    tb_i_reg_data = t_i_reg_data;
    #10;
    
    if (tb_o_mem_wdata === t_exp_wdata && tb_o_mem_wmask === t_exp_wmask) begin
    pass_count++;
    $display("PASS: %s", name);
end else begin
    fail_count++;
    $display("FAIL: %s", name);
    $display("  Expected wdata=%h, wmask=%b", t_exp_wdata, t_exp_wmask);
    $display("  Got      wdata=%h, wmask=%b", tb_o_mem_wdata, tb_o_mem_wmask);
end
endtask

initial begin
    
    // SB - Store Byte (funct3 = 3'b000)
// Always stores reg_data[7:0], addr selects byte lane
check_str_msk(3'b000, 2'b00, 32'h807FABCD, 32'h000000CD, 4'b0001, "SB @ byte 0");
check_str_msk(3'b000, 2'b01, 32'h807FABCD, 32'h0000CD00, 4'b0010, "SB @ byte 1");
check_str_msk(3'b000, 2'b10, 32'h807FABCD, 32'h00CD0000, 4'b0100, "SB @ byte 2");
check_str_msk(3'b000, 2'b11, 32'h807FABCD, 32'hCD000000, 4'b1000, "SB @ byte 3");

// SH - Store Halfword (funct3 = 3'b001)
// Always stores reg_data[15:0], addr selects halfword lane
check_str_msk(3'b001, 2'b00, 32'h807FABCD, 32'h0000ABCD, 4'b0011, "SH @ halfword 0");
check_str_msk(3'b001, 2'b10, 32'h807FABCD, 32'hABCD0000, 4'b1100, "SH @ halfword 1");
check_str_msk(3'b001, 2'b01, 32'h12345678, 32'h00000000, 4'b0000, "SH misaligned @ 01");
check_str_msk(3'b001, 2'b11, 32'h12345678, 32'h00000000, 4'b0000, "SH misaligned @ 11");

// SW - Store Word (funct3 = 3'b010)
// Always stores full reg_data[31:0]
check_str_msk(3'b010, 2'b00, 32'hDEADBEEF, 32'hDEADBEEF, 4'b1111, "SW full word");
check_str_msk(3'b010, 2'b01, 32'hCAFEBABE, 32'hCAFEBABE, 4'b1111, "SW (addr ignored)");

// Edge cases 
check_str_msk(3'b000, 2'b00, 32'h00000000, 32'h00000000, 4'b0001, "SB zeros");
check_str_msk(3'b000, 2'b11, 32'hFFFFFFFF, 32'hFF000000, 4'b1000, "SB ones @ byte 3");
check_str_msk(3'b001, 2'b00, 32'hFFFFFFFF, 32'h0000FFFF, 4'b0011, "SH ones @ hw0");
check_str_msk(3'b001, 2'b10, 32'hFFFFFFFF, 32'hFFFF0000, 4'b1100, "SH ones @ hw1");
check_str_msk(3'b010, 2'b00, 32'hFFFFFFFF, 32'hFFFFFFFF, 4'b1111, "SW ones");

// Invalid opcodes
check_str_msk(3'b011, 2'b00, 32'h12345678, 32'h00000000, 4'b0000, "Invalid opcode 011");
check_str_msk(3'b100, 2'b00, 32'h12345678, 32'h00000000, 4'b0000, "Invalid opcode 100");
   
    $display("========== Summary ==========");
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", fail_count);

    $display("========== Tests Complete ==========");
    $finish;
end

endmodule