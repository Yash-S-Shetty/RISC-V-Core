// tb_pc_reg.sv
// 9 July 2026
// Testbench for PC Register

module tb_pc_reg;

logic tb_i_clk;
logic tb_i_reset_n;
logic [31:0] tb_i_pc_next;
logic [31:0] tb_o_pc;

int pass_count = 0;
int fail_count = 0;
int total_tests = 0;

pc_reg DUT (
    .i_clk(tb_i_clk),
    .i_reset_n(tb_i_reset_n),
    .i_pc_next(tb_i_pc_next),
    .o_pc(tb_o_pc)
);

// Clock generation
initial begin
    tb_i_clk = 1'b0;
    forever #5 tb_i_clk = ~tb_i_clk;
end

// Waveform dump
initial begin
    $dumpfile("sim/tb_pc_reg.vcd");
    $dumpvars(0, tb_pc_reg);
end

// Check task
task check_pc(input logic [31:0] expected, input string name);
    total_tests++;
    if (tb_o_pc === expected) begin
        pass_count++;
        $display("PASS: %s", name);
    end else begin
        fail_count++;
        $display("FAIL: %s (expected %h, got %h)", name, expected, tb_o_pc);
    end
endtask

// Test sequence
initial begin
    $display("========== PC Register Tests ==========");

    // Startup reset
    tb_i_reset_n = 1'b0;
    tb_i_pc_next = 32'h00000000;
    #10;
    check_pc(32'h00000000, "Startup reset clears PC");

    // Release reset
    tb_i_reset_n = 1'b1;
    #10;

    // Sequential PC loads
    tb_i_pc_next = 32'h00000000; #10; check_pc(32'h00000000, "PC = 0x0");
    tb_i_pc_next = 32'h00000004; #10; check_pc(32'h00000004, "PC = 0x4");
    tb_i_pc_next = 32'h00000008; #10; check_pc(32'h00000008, "PC = 0x8");
    tb_i_pc_next = 32'h0000000C; #10; check_pc(32'h0000000C, "PC = 0xC");

    // Jump to a far address
    tb_i_pc_next = 32'h80000000; #10; check_pc(32'h80000000, "PC jump to 0x80000000");

    // Jump to another address
    tb_i_pc_next = 32'h00000100; #10; check_pc(32'h00000100, "PC jump to 0x100");

    // Max address
    tb_i_pc_next = 32'hFFFFFFFF; #10; check_pc(32'hFFFFFFFF, "PC = 0xFFFFFFFF");

    // Reset mid-operation
    tb_i_reset_n = 1'b0;
    tb_i_pc_next = 32'h12345678;
    #10;
    check_pc(32'h00000000, "Reset clears PC mid-operation");

    // Release reset, resume normal load
    tb_i_reset_n = 1'b1;
    #10;
    tb_i_pc_next = 32'h00001000;
    #10;
    check_pc(32'h00001000, "PC = 0x1000 after reset release");

    $display("========== Summary ==========");
    $display("Total : %0d", total_tests);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", fail_count);
    $display("========== Tests Complete ==========");
    $finish;
end

endmodule