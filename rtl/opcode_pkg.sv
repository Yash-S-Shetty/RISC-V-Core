package opcode_pkg;    
    localparam logic [6:0] OP       = 7'b0110011; // Reg-Reg 
    localparam logic [6:0] OP_IMM   = 7'b0010011; // Reg-Immediate
    localparam logic [6:0] LUI      = 7'b0110111; // Load Upper Immediate
    localparam logic [6:0] AUIPC    = 7'b0010111; // Add Upper Immediate to PC
    localparam logic [6:0] JAL      = 7'b1101111; // Jump and Link - J-TYPE
    localparam logic [6:0] JALR     = 7'b1100111; // Jump and Link Register - I-TYPE
    localparam logic [6:0] BRANCH   = 7'b1100011; // Branch 
    localparam logic [6:0] LOAD     = 7'b0000011; // Load
    localparam logic [6:0] STORE    = 7'b0100011; // Store
    localparam logic [6:0] MISC_MEM = 7'b0001111; // Fence
    localparam logic [6:0] SYSTEM   = 7'b1110011; // ECALL / EBREAK
endpackage