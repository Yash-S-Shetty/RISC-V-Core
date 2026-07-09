// Store Mask Generator
// store_mask.sv
// 30 June 2026

module store_mask(
    input logic [2:0] i_funct3,
    input logic [1:0] i_addr,
    input logic [31:0] i_reg_data,
    output logic [31:0] o_mem_wdata,
    output logic [3:0] o_mem_wmask
);

always_comb begin
    // Pre Default
    o_mem_wdata = 32'd0;
    o_mem_wmask = 4'd0;
    unique case (i_funct3)
        3'b000  :   unique case (i_addr)
                        2'b00   :   begin
                                        o_mem_wdata = {24'd0, i_reg_data[7:0]};
                                        o_mem_wmask = 4'b0001;
                        end
                        2'b01   :   begin
                                        o_mem_wdata = {16'd0, i_reg_data[7:0], 8'd0};
                                        o_mem_wmask = 4'b0010;
                        end
                        2'b10   :   begin 
                                        o_mem_wdata = {8'd0, i_reg_data[7:0], 16'd0};
                                        o_mem_wmask = 4'b0100;
                        end
                        2'b11   :   begin 
                                        o_mem_wdata = {i_reg_data[7:0], 24'd0};
                                        o_mem_wmask = 4'b1000;
                        end
                        default :   begin  
                                        o_mem_wdata = 32'd0;
                                        o_mem_wmask = 4'd0;
                        end
        endcase
        3'b001  :   unique case (i_addr)
                        2'b00   :   begin   
                                        o_mem_wdata = {16'd0, i_reg_data[15:0]};
                                        o_mem_wmask = 4'b0011;
                        end
                        2'b10   :   begin
                                        o_mem_wdata = {i_reg_data[15:0], 16'd0};
                                        o_mem_wmask = 4'b1100;
                        end
                        default :   begin   
                                        o_mem_wdata = 32'd0;
                                        o_mem_wmask = 4'd0;
                        end
        endcase
        3'b010  :   begin   
                        o_mem_wdata = i_reg_data;
                        o_mem_wmask = 4'b1111;
        end
        default :   begin   
                        o_mem_wdata = 32'd0;
                        o_mem_wmask = 4'd0;
        end
    endcase
end
endmodule