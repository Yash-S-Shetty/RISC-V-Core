// imm_gen.sv
// 19 June 2026
// Immediate Generator for RISC-V Core
// The instruction format is decided by the Control Unit
// Or the Opcode decoding is done by the Control Unit - imm_sel[2:0]

import imm_gen_pkg::*;

module imm_gen(
    input logic [31:0] i_inst,
    input logic [2:0] i_imm_sel,
    output logic [31:0] o_ext_imm
);

always_comb begin

    o_ext_imm = 32'b0;

    unique case (i_imm_sel)

        I_TYPE : o_ext_imm[31:0] = {{21{i_inst[31]}}, i_inst[30:20]}; 
        // Can be written as {{20{i_inst[31]}}, i_inst[31:20]};

        S_TYPE : o_ext_imm[31:0] = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]}; 
        // Can be written as {{20{i_inst[31]}}, i_inst[31:25], i_inst[11:7]};

        B_TYPE : o_ext_imm[31:0] = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0}; 
        // Can be written as {{19{i_inst[31]}}, i_inst[31], i_inst[7],i_inst[30:25], i_inst[11:8], 1'b0};

        U_TYPE : o_ext_imm[31:0] = {i_inst[31:12], 12'b0}; 

        J_TYPE : o_ext_imm[31:0] = {{12{i_inst[31]}}, i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0}; 
        // Can be written as {{11{i_inst[31]}}, i_inst[31], i_inst[19:12],i_inst[20], i_inst[30:21], 1'b0};

        R_TYPE  : o_ext_imm = 32'b0;  // R-type has no immediate field per spec — output unused

        default : o_ext_imm = 32'b0;  // Invalid/unused imm_sel encoding
    endcase

end

endmodule