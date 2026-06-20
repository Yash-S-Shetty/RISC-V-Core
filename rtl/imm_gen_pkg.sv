package imm_gen_pkg;    
    localparam logic [2:0] R_TYPE  = 3'b000; // Register
    localparam logic [2:0] I_TYPE  = 3'b001; // Immediate
    localparam logic [2:0] S_TYPE  = 3'b010; // Store
    localparam logic [2:0] B_TYPE  = 3'b011; // Branch
    localparam logic [2:0] U_TYPE  = 3'b100; // Upper Immediate
    localparam logic [2:0] J_TYPE  = 3'b101; // Jump
endpackage
