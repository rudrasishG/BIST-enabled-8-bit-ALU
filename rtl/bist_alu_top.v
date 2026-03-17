module bist_alu_top (
    input  clk,
    input  reset,
    input  bist_start,
    
    // Normal operation inputs
    input  [7:0] a,
    input  [7:0] b,
    input  [2:0] op,
    input  normal_enable,       
    
    // Power inputs
    input  power_mode,           // 1: active, 0: sleep
    input  bist_power_enable,    
    
    
    output [7:0] y,
    output bist_done,
    output bist_pass
);

    wire [7:0] lfsr_out;
    wire [7:0] lfsr_gated;
    wire [7:0] alu_a, alu_b;
    wire [7:0] alu_y;
    wire [7:0] alu_y_retention;
    wire [7:0] signature;
    wire [7:0] signature_gated;
    wire bist_active;
    wire bist_clk_en;
    
    // Global clock 
    wire global_clk_en;
    assign global_clk_en = (bist_active | normal_enable) & power_mode;
    //testing force opcode to add since and gives 00 sig
    wire [2:0] alu_op;
    assign alu_op = bist_active ? 3'b000: op;
    
    // Input MUX with isolation
    wire [7:0] a_isolated, b_isolated;
    assign a_isolated = (normal_enable & !bist_active) ? a : 8'h00;
    assign b_isolated = (normal_enable & !bist_active) ? b : 8'h00;
    
    assign alu_a = bist_active ? lfsr_gated : a_isolated;
    assign alu_b = bist_active ? ~lfsr_gated : b_isolated;
    
    // DUT instantiation
    alu u_alu (
        .clk          (clk),
        .en           (global_clk_en),
        .a            (alu_a),
        .b            (alu_b),
        //changed op to add for now
        .op           (alu_op),
        .power_mode   (power_mode),
        .y            (alu_y),
        .y_retention  (alu_y_retention)
    );
    
    // lfsr
    randgen u_randgen (
        .clk        (clk),
        .reset      (reset),
        .enable     (bist_clk_en),
        .power_mode (bist_power_enable & power_mode),
        .rnd        (lfsr_out),
        .rnd_gated  (lfsr_gated)
    );
    
    // misr
    misr u_misr (
        .clk             (clk),
        .reset           (reset),
        .enable          (bist_clk_en),
        .power_mode      (bist_power_enable & power_mode),
        .data_in         (alu_y),
        .signature       (signature),
        .signature_gated (signature_gated)
    );
    
    // controller
    bist_controller u_ctrl (
        .clk          (clk),
        .reset        (reset),
        .start        (bist_start),
        .power_enable (bist_power_enable & power_mode),
        .bist_active  (bist_active),
        .done         (bist_done),
        .bist_clk_en  (bist_clk_en)
    );
    
    // sig compare
    signature_compare u_cmp (
        .clk             (clk),
        .enable          (bist_done),
        .signature       (signature),
        .registered_mode (1'b1),  // Use registered output
        .pass_comb       (),
        .pass_reg        (bist_pass)
    );
    
    assign y = power_mode ? alu_y : alu_y_retention;
    
    /* synthesis attribute u_randgen power_domain "PD_BIST"
     u_misr power_domain "PD_BIST"
     u_ctrl power_domain "PD_BIST"
     u_cmp power_domain "PD_BIST"
     u_alu power_domain "PD_CORE"*/

endmodule

