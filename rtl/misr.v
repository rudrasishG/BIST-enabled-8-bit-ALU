module misr (
    input  clk,
    input  reset,
    input  enable,
    input  power_mode,         
    input  [7:0] data_in,
    output reg [7:0] signature,
    output [7:0] signature_gated 
);
    wire clk_en;
    wire [7:0] data_gated;
    
    assign clk_en = enable & power_mode;
    assign data_gated = (enable & power_mode) ? data_in : 8'h00;
    
    //reg [7:0] data_reg;
   // reg [7:0] shifted_sig;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            //data_reg <= 8'h00;
            //shifted_sig <= 8'h00;
            signature <= 8'h00;
        end else if (clk_en) begin
            //data_reg <= data_gated;
            //shifted_sig <= signature << 1;
            signature <= (signature << 1) ^ data_gated;
        end
    end
    
    assign signature_gated = (enable & power_mode) ? signature : 8'h00;
    
    /* Synthesis directives for low-power
     clk_en clock_gating_enable true
      signature high_vt_cell true
     data_reg medium_vt_cell true */
endmodule
