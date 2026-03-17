module signature_compare (
    input  clk,                    // Optional for registered mode
    input  enable,                 
    input  [7:0] signature,
    input  registered_mode,        // 1: registered output, 0: combinational
    output wire pass_comb,         
    output reg  pass_reg        
);

    parameter GOLDEN_SIGNATURE = 8'h55;
    wire [7:0] sig_gated;
    assign sig_gated = enable ? signature : 8'h00;
    
    // Early evaluation (short-circuit on first mismatch)
    wire byte_match;
    assign byte_match = (sig_gated == GOLDEN_SIGNATURE);
    assign pass_comb = byte_match & enable;
    

    always @(posedge clk) begin
        if (registered_mode && enable)
            pass_reg <= pass_comb;
        else if (!enable)
            pass_reg <= 1'b0;
    end
    
 
    // synthesis attribute pass_reg low_power_register true

endmodule

