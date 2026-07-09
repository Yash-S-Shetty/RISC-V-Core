// Testbench for Load Extend Module
// tb_load_extend.sv
// 1 July 2026

module tb_load_extend;
logic [2:0] tb_i_funct3; // LB/LBU/LH/LHU/LW
logic [1:0] tb_i_addr;   // Lower two bits of address for byte offset
logic [31:0] tb_i_mem_rdata; // From memory
logic [31:0] tb_o_load_data; // The Final Load Value


load_extend DUT(
    .i_funct3(tb_i_funct3),
    .i_addr(tb_i_addr),
    .i_mem_rdata(tb_i_mem_rdata),
    .o_load_data(tb_o_load_data)
);

initial begin
    $dumpfile("sim/tb_load_extend.vcd");
    $dumpvars(0, tb_load_extend);
end

task check_ld_ex(
    input logic [2:0] t_i_funct3, 
    input logic [1:0] t_i_addr, 
    input logic [31:0] t_i_mem_rdata, 
    input logic [31:0] t_exp_result
    );
    
    tb_i_funct3 = t_i_funct3;
    tb_i_addr = t_i_addr;
    tb_i_mem_rdata =  t_i_mem_rdata;
    #10;
    if (tb_o_load_data === t_exp_result) $display (" TEST PASSED ");
    else $display (" TEST FAILED ");
endtask

initial begin
    // Case 1: LW - word pass-through, offset 0
    check_ld_ex(3'b010, 2'b00, 32'hDEADBEEF, 32'hDEADBEEF);

    // Case 2: LH - positive halfword, offset 0, zero upper bits
    check_ld_ex(3'b001, 2'b00, 32'h00007FFF, 32'h00007FFF);

    // Case 3: LH - negative halfword, offset 0, sign-extend check
    check_ld_ex(3'b001, 2'b00, 32'h00008000, 32'hFFFF8000);

    // Case 4: LH - negative halfword, offset 2 (upper lane), sign-extend check
    check_ld_ex(3'b001, 2'b10, 32'hFFFF0000, 32'hFFFFFFFF);

    // Case 5: LHU - halfword zero-extend, offset 0
    check_ld_ex(3'b101, 2'b00, 32'h00008000, 32'h00008000);

    // Case 6: LHU - halfword zero-extend, offset 2
    check_ld_ex(3'b101, 2'b10, 32'hFFFF0000, 32'h0000FFFF);

    // Case 7: LB - positive byte, offset 0
    check_ld_ex(3'b000, 2'b00, 32'h0000007F, 32'h0000007F);

    // Case 8: LB - negative byte, offset 0, sign-extend check
    check_ld_ex(3'b000, 2'b00, 32'h00000080, 32'hFFFFFF80);

    // Case 9: LB - negative byte, offset 1
    check_ld_ex(3'b000, 2'b01, 32'h00008000, 32'hFFFFFF80);

    // Case 10: LB - negative byte, offset 2
    check_ld_ex(3'b000, 2'b10, 32'h00800000, 32'hFFFFFF80);

    // Case 11: LB - negative byte, offset 3 (top lane)
    check_ld_ex(3'b000, 2'b11, 32'h80000000, 32'hFFFFFF80);

    // Case 12: LBU - byte zero-extend, offset 3
    check_ld_ex(3'b100, 2'b11, 32'h80000000, 32'h00000080);

    $finish;
end

endmodule