// PC Increment/Adder 
// pc_adder.sv
// 1 July 2026

module pc_adder(
    input logic [31:0] i_pc,
    output logic [31:0] o_pc_plus_4
);

assign o_pc_plus_4 = i_pc + 32'd4;

endmodule