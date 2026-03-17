module randgen (
    input  clk,
    input  reset,
    input  enable,
    input  power_mode,       
    output reg [7:0] rnd,
    output [7:0] rnd_gated    // Gated output to prevent downstream switching
);

    wire feedback;
    wire clk_en;
    
    assign clk_en = enable & power_mode;
    
    // Optimized feedback with balanced XOR tree
    // Reduces critical path and glitches
    wire xor_level1_a, xor_level1_b;
    assign xor_level1_a = rnd[7] ^ rnd[5];
    assign xor_level1_b = rnd[4] ^ rnd[3];
    assign feedback = xor_level1_a ^ xor_level1_b;
    
    // LFSR
    always @(posedge clk or posedge reset) begin
        if (reset)
            rnd <= 8'h01;   // non-zero seed
        else if (clk_en)
            rnd <= {rnd[6:0], feedback};
    end
    assign rnd_gated = (enable & power_mode) ? rnd : 8'h00;
    
    /* Synthesis directives for low-power optimization:
       clk_en clock_gating_enable true
       rnd high_vt_cell true */

endmodule
