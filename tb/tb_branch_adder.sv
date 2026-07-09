// Testbench for Branch adder
// tb_branch_adder.sv
// 1 July 2026

module tb_branch_adder;
logic [31:0] tb_i_pc;
logic [31:0] tb_i_imm;
logic [31:0] tb_o_branch_target;

branch_adder DUT(
    .i_pc(tb_i_pc),
    .i_imm(tb_i_imm),
    .o_branch_target(tb_o_branch_target)
);

initial begin
    $dumpfile("sim/tb_branch_adder.vcd");
    $dumpvars(0, tb_branch_adder);
end

initial begin
    tb_i_pc = 32'd0;
    tb_i_imm = 32'd40;
    #10;
    if (tb_o_branch_target === 32'd40) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'd16;
    tb_i_imm = 32'd8;
    #10;
    if (tb_o_branch_target === 32'd24) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'd40;
    tb_i_imm = -32'sd8;
    #10;
    if (tb_o_branch_target === 32'd32) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'd40;
    tb_i_imm = 32'hFFFFFFFC;
    #10;
    if (tb_o_branch_target === 32'd36) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'd0;
    tb_i_imm = 32'hFFFFFFFC;
    #10;
    if (tb_o_branch_target === 32'hFFFFFFFC) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'd100;
    tb_i_imm = 32'd400;
    #10;
    if (tb_o_branch_target === 32'd500) $display("PASS");
    else $display("FAIL");
end
endmodule