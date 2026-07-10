// PC Register for the Pipeline
// pc_reg.sv
// 30 June 2026
// Added i_en for stall signal - 10 July 2026

module pc_reg(
    input logic i_clk,
    input logic i_reset_n,
    input logic i_en,  // Stall 
    input logic [31:0] i_pc_next,
    output logic [31:0] o_pc
);

always_ff @(posedge i_clk) begin
    if(!i_reset_n) o_pc <= 32'd0;
    else if(i_en) o_pc <= i_pc_next; 
    // else hold current value 
end

endmodule
