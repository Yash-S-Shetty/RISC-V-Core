package alu_pkg;    
    localparam logic [3:0] ALU_ADD  = 4'b0000; // Addition
    localparam logic [3:0] ALU_SUB  = 4'b0001; // Subtraction
    localparam logic [3:0] ALU_AND  = 4'b0010; // Bitwise AND
    localparam logic [3:0] ALU_OR   = 4'b0011; // Bitwise OR
    localparam logic [3:0] ALU_XOR  = 4'b0100; // Bitwise XOR
    localparam logic [3:0] ALU_SLL  = 4'b0101; // Shift Left Logical
    localparam logic [3:0] ALU_SRL  = 4'b0110; // Shift Right Logical
    localparam logic [3:0] ALU_SRA  = 4'b0111; // Shift Right Arithmetic
    localparam logic [3:0] ALU_SLT  = 4'b1000; // Set Less Than (signed)
    localparam logic [3:0] ALU_SLTU = 4'b1001; // Set Less Than Unsigned
    localparam logic [3:0] ALU_PASS = 4'b1010; // Passthrough i_rs2 (used for LUI)
endpackage
