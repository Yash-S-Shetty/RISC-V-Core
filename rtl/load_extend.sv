// Load Extend Combinational Module to handle LB/LBU/LH/LHU/LW
// load_extend.sv
// 30 June 2026

module load_extend(
    input logic [2:0] i_funct3, // LB/LBU/LH/LHU/LW
    input logic [1:0] i_addr,   // Lower two bits of address for byte offset
    input logic [31:0] i_mem_rdata, // From memory
    output logic [31:0] o_load_data // The Final Load Value
);

always_comb begin
    // Pre Default
    o_load_data = 32'd0;
    unique case (i_funct3) 
        3'b000  :   unique case (i_addr) // LB - Sign Extend
                        2'b00   :   o_load_data = {{24{i_mem_rdata[7]}}, i_mem_rdata[7:0]};
                        2'b01   :   o_load_data = {{24{i_mem_rdata[15]}}, i_mem_rdata[15:8]};
                        2'b10   :   o_load_data = {{24{i_mem_rdata[23]}}, i_mem_rdata[23:16]};
                        2'b11   :   o_load_data = {{24{i_mem_rdata[31]}}, i_mem_rdata[31:24]};
                        default :   o_load_data = 32'd0;
        endcase
        3'b001  :   unique case (i_addr) // LH - Sign Extend
                        2'b00   :   o_load_data = {{16{i_mem_rdata[15]}}, i_mem_rdata[15:0]};
                        2'b10   :   o_load_data = {{16{i_mem_rdata[31]}}, i_mem_rdata[31:16]};
                        default :   o_load_data = 32'd0;
        endcase
        3'b010  :   o_load_data = i_mem_rdata;
        3'b100  :   unique case (i_addr) // LBU - Unsigned
                        2'b00   :   o_load_data = {24'd0, i_mem_rdata[7:0]};
                        2'b01   :   o_load_data = {24'd0, i_mem_rdata[15:8]};
                        2'b10   :   o_load_data = {24'd0, i_mem_rdata[23:16]};
                        2'b11   :   o_load_data = {24'd0, i_mem_rdata[31:24]};
                        default :   o_load_data = 32'd0;
        endcase
        3'b101  :   unique case (i_addr) // LHU - Unsigned
                        2'b00   :   o_load_data = {16'd0, i_mem_rdata[15:0]};
                        2'b10   :   o_load_data = {16'd0, i_mem_rdata[31:16]};
                        default :   o_load_data = 32'd0;
        endcase
        default :   o_load_data = 32'd0;
    endcase
end
endmodule
