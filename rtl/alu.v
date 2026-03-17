module alu (
    input  wire        clk,
    input  wire        en,        
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [2:0]  op,
    input  wire        power_mode,  // 1: active, 0: sleep
    output reg  [7:0]  y,
    output reg  [7:0]  y_retention  // retention register for sleep mode
);
    wire clk_en;
    assign clk_en = en & power_mode;
    wire [7:0] a_gated;
    wire [7:0] b_gated;
    
    assign a_gated = (en & power_mode) ? a : 8'h00;
    assign b_gated = (en & power_mode) ? b : 8'h00;
    
    /* Pipeline register for reduced delay
    reg [7:0] a_reg, b_reg;
    reg [2:0] op_reg;*/
    
    /*always @(posedge clk) begin
        if (clk_en) begin
            a_reg  <= a_gated;
            b_reg  <= b_gated;
            op_reg <= op;
        end
    end */ 
    
    always @(posedge clk) begin
        if (clk_en) begin
            case (op)
                3'b000: y <= a_gated + b_gated;       
                3'b001: y <= a_gated - b_gated;        
                3'b010: y <= a_gated & b_gated;        
                3'b011: y <= a_gated | b_gated;        
                3'b100: y <= a_gated ^ b_gated;        
                default: y <= 8'h00;
            endcase
        end
    end
    
    //retention reg
    always @(posedge clk) begin
        if (!power_mode) begin
            y_retention <= y;  // Save state before sleep
        end
    end
    /* Synthesis directives for low-power optimization
      attribute clk_en clock_gating_enable true
      attribute a_reg high_vt_cell true
      attribute b_reg high_vt_cell true */
endmodule
