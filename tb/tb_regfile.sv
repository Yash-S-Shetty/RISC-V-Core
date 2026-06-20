// Testbench for regfile.sv
// tb_regfile.sv
// 18 June 2026

module tb_regfile;
    logic tb_i_clk;
    logic tb_i_wr_en; // Active High
    logic tb_i_rst_n; // Active Low
    logic [4:0] tb_i_rs1_address;
    logic [4:0] tb_i_rs2_address;
    logic [4:0] tb_i_rd_address;
    logic [31:0] tb_i_rd_wb;
    logic [31:0] tb_o_rs1_data;
    logic [31:0] tb_o_rs2_data;

regfile DUT (.i_clk(tb_i_clk), 
            .i_wr_en(tb_i_wr_en),
            .i_rst_n(tb_i_rst_n),
            .i_rs1_address(tb_i_rs1_address),
            .i_rs2_address(tb_i_rs2_address),
            .i_rd_address(tb_i_rd_address),
            .i_rd_wb(tb_i_rd_wb),
            .o_rs1_data(tb_o_rs1_data),
            .o_rs2_data(tb_o_rs2_data));

initial begin
    $dumpfile("sim/tb_regfile.vcd");
    $dumpvars(0, tb_regfile);
end

initial begin
    tb_i_clk = 1'b0;
    forever #5 tb_i_clk = ~tb_i_clk;
end

// No Task Based approach used
initial begin
    // Initialization
    tb_i_wr_en       = 1'b0;
    tb_i_rst_n       = 1'b0;
    tb_i_rs1_address = 5'd0;
    tb_i_rs2_address = 5'd0;
    tb_i_rd_address  = 5'd0;
    tb_i_rd_wb       = 32'd0;
    
    repeat (5) @(negedge tb_i_clk);
    tb_i_rst_n = 1'b1; // Reset Deasserted

    // Basic Write and Read Test
    @(negedge tb_i_clk) begin
        tb_i_rd_wb = 32'h12345678;
        tb_i_rd_address = 5'd5;
        tb_i_wr_en = 1'b1;
    end
    @(posedge tb_i_clk);
    @(negedge tb_i_clk) tb_i_wr_en = 1'b0;

    @(negedge tb_i_clk) begin
        tb_i_rd_wb = 32'h87654321;
        tb_i_rd_address = 5'd2;
        tb_i_wr_en = 1'b1;
    end
    @(posedge tb_i_clk);
    @(negedge tb_i_clk) tb_i_wr_en = 1'b0;

    @(negedge tb_i_clk) begin // Edge not needed for read as it is Async
        tb_i_rs1_address = 5'd5;
        tb_i_rs2_address = 5'd2;
    end
    #1;
    if (tb_o_rs1_data !== 32'h12345678) $error("FAILED: x5 mismatch");
    else $display("PASSED: x5 read");
    if (tb_o_rs2_data !== 32'h87654321) $error("FAILED: x2 mismatch");
    else $display("PASSED: x2 read");

    // x0 test

    @(negedge tb_i_clk) begin
        tb_i_rd_wb = 32'hFFFFFFFF;
        tb_i_rd_address = 5'd0;
        tb_i_wr_en = 1'b1;
    end
    @(posedge tb_i_clk);
    @(negedge tb_i_clk) tb_i_wr_en = 1'b0;
    
    @(negedge tb_i_clk) begin // Edge not needed for read as it is Async
        tb_i_rs1_address = 5'd0;
        tb_i_rs2_address = 5'd0;
    end
    #1;
    if (tb_o_rs1_data !== 32'd0) $error("FAILED: x0 check for rs1");
    else $display("PASSED: x0 check for rs1");
    if (tb_o_rs2_data !== 32'd0) $error("FAILED: x0 check for rs2");
    else $display("PASSED: x0 check for rs2");

    // Read-During-Write-Hazard
    @(negedge tb_i_clk) begin
        tb_i_rd_wb = 32'hAAAAAAAA;
        tb_i_rd_address = 5'd5;
        tb_i_rs1_address = 5'd5;
        tb_i_rs2_address = 5'd5;
        tb_i_wr_en = 1'b1;
    end

    #1;
    if (tb_o_rs1_data !== 32'h12345678) $error("FAILED: Read-During-Write-Hazard check for rs1 - PRE ");
    else $display("PASSED: Read-During-Write-Hazard check for rs1 - PRE");
    if (tb_o_rs2_data !== 32'h12345678) $error("FAILED: Read-During-Write-Hazard check for rs2 - PRE");
    else $display("PASSED: Read-During-Write-Hazard check for rs2 - PRE");
    
    @(posedge tb_i_clk);

    #1;
    if (tb_o_rs1_data !== 32'hAAAAAAAA) $error("FAILED: Read-During-Write-Hazard check for rs1 - POST");
    else $display("PASSED: Read-During-Write-Hazard check for rs1 - POST");
    if (tb_o_rs2_data !== 32'hAAAAAAAA) $error("FAILED: Read-During-Write-Hazard check for rs2 - POST");
    else $display("PASSED: Read-During-Write-Hazard check for rs2 - POST");

    @(negedge tb_i_clk) tb_i_wr_en = 1'b0;

    // Reset Behaviour
    @(negedge tb_i_clk) tb_i_rst_n = 1'b0;
    @(posedge tb_i_clk);
    @(negedge tb_i_clk) tb_i_rst_n = 1'b1;
    @(negedge tb_i_clk) begin
        tb_i_rs1_address = 5'd5;
        tb_i_rs2_address = 5'd2;
    end
    #1;
    if (tb_o_rs1_data !== 32'd0) $error("FAILED: Reset check for rs1");
    else $display("PASSED: Reset check for rs1");
    if (tb_o_rs2_data !== 32'd0) $error("FAILED: Reset check for rs2");
    else $display("PASSED: Reset check for rs2");
    

    // Write with wr_en disabled
    @(negedge tb_i_clk) begin
        tb_i_rd_wb = 32'h12345678;
        tb_i_rd_address = 5'd5;
        tb_i_wr_en = 1'b0;
    end
    @(posedge tb_i_clk);
    @(negedge tb_i_clk) tb_i_wr_en = 1'b0;

    @(negedge tb_i_clk) begin
        tb_i_rd_wb = 32'h87654321;
        tb_i_rd_address = 5'd2;
        tb_i_wr_en = 1'b0;
    end
    @(posedge tb_i_clk);
    @(negedge tb_i_clk) tb_i_wr_en = 1'b0;

    @(negedge tb_i_clk) begin // Edge not needed for read as it is Async
        tb_i_rs1_address = 5'd5;
        tb_i_rs2_address = 5'd2;
    end
    #1;
    if (tb_o_rs1_data !== 32'd0) $error("FAILED: x5 Write Error");
    else $display("PASSED: x5 read");
    if (tb_o_rs2_data !== 32'd0) $error("FAILED: x2 Write Error");
    else $display("PASSED: x2 read");

    $finish;
end

endmodule
