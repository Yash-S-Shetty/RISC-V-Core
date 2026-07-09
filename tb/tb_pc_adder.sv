// Testbench for PC Adder
// tb_pc_adder.sv
// 1 July 2026

module tb_pc_adder;
logic [31:0] tb_i_pc;
logic [31:0] tb_o_pc_plus_4;

pc_adder DUT(
    .i_pc(tb_i_pc),
    .o_pc_plus_4(tb_o_pc_plus_4)
);

initial begin
    $dumpfile("sim/tb_pc_adder.vcd");
    $dumpvars(0, tb_pc_adder);
end

initial begin
    tb_i_pc = 32'd0;
    #10;
    if (tb_o_pc_plus_4 === 32'd4) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'd16;
    #10;
    if (tb_o_pc_plus_4 === 32'd20) $display("PASS");
    else $display("FAIL");

    tb_i_pc = 32'hFFFFFFFF;
    #10;
    if (tb_o_pc_plus_4 === 32'd3) $display("PASS");
    else $display("FAIL");
end

endmodule
