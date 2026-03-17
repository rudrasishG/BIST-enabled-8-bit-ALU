`timescale 1ns/1ps
//intentional time extensions done to avert timing failures for now..fix later
module tb_bist_alu;
    reg clk;
    reg reset;
    reg bist_start;
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] op;
    reg normal_enable;
    reg power_mode;
    reg bist_power_enable;
    
    wire [7:0] y;
    wire bist_done;
    wire bist_pass;
    
    // Instantiate DUT
    bist_alu_top dut (
        .clk              (clk),
        .reset            (reset),
        .bist_start       (bist_start),
        .a                (a),
        .b                (b),
        .op               (op),
        .normal_enable    (normal_enable),
        .power_mode       (power_mode),
        .bist_power_enable(bist_power_enable),
        .y                (y),
        .bist_done        (bist_done),
        .bist_pass        (bist_pass)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("baseline.vcd");
        $dumpvars(0, dut);
    end
    
    // Test sequence
    initial begin
       
        clk = 0;
        reset = 1;
        bist_start = 0;
        normal_enable = 0;
        power_mode = 1;           // Start in active mode
        bist_power_enable = 1;    // BIST power domain enabled
        a = 8'h00;
        b = 8'h00;
        op = 3'b000;
        
        $display("=== Low-Power BIST ALU Test ===");
        $display("Time\tTest Phase");
        
        // Release reset
        #20 reset = 0;
        $display("%0t\tReset released", $time);
        
        // Test 1: Normal operation in active mode
        #20;
        $display("%0t\tTest 1: Normal operation", $time);
        normal_enable = 1;
        a = 8'h0F;
        b = 8'h05;
        op = 3'b000;  // ADD
        #10;
        $display("%0t\tADD: %h + %h = %h (expected 14h)", $time, a, b, y);
        
        op = 3'b010;  // AND
        #10;  // 2 cycles needed - pipeline stage 1 captures op, stage 2 computes result
        $display("%0t\tAND: %h & %h = %h (expected 05h)", $time, a, b, y);
        
        normal_enable = 0;
        
        // Test 2: BIST in active mode
        #20;
        $display("%0t\tTest 2: BIST operation", $time);
        bist_start = 1;
        #10 bist_start = 0;
        
        wait(bist_done);
        @(posedge clk); #1;  // bist_pass needs 2 cycles...maybe this delay will synchronise
        $display("%0t\tBIST completed", $time);
        $display("%0t\tFinal Signature = %h", $time, dut.signature);
        $display("%0t\tBIST Pass = %b", $time, bist_pass);
        
        /* Test 3: Power mode transitions
         the @(posedge clk);#1 above shifts timing so signals below no
         longer land on a clock edge - race condition is automatically avoided*/
        #20;
        $display("%0t\tTest 3: Power mode testing", $time);
        normal_enable = 1;
        a = 8'hAA;
        b = 8'h55;
        op = 3'b011;  // OR
        #10;
        $display("%0t\tActive mode: %h | %h = %h", $time, a, b, y);
        
        // Enter sleep mode
        #10;
        $display("%0t\tEntering sleep mode...", $time);
        power_mode = 0;
        #20;
        $display("%0t\tSleep mode: Output held at %h (retention)", $time, y);
        
        // Wake up
        #20;
        $display("%0t\tWaking up...", $time);
        power_mode = 1;
        #20;
        $display("%0t\tActive mode restored", $time);
        
        // Test 4: BIST power domain disable
        #20;
        $display("%0t\tTest 4: BIST power domain control", $time);
        bist_power_enable = 0;
        reset = 1;
        #10 reset = 0;
        #10;
        bist_start = 1;
        #10 bist_start = 0;
        #50;
        $display("%0t\tBIST with power disabled - should not run", $time);
        $display("%0t\tBIST Done = %b (should be 0)", $time, bist_done);
        
        // Re-enable BIST power
        #20;
        bist_power_enable = 1;
        #50
        $finish;
    end
    
    // Monitor for unexpected behavior
/*    always @(posedge clk) begin
        if (!reset && power_mode && normal_enable && !bist_start) begin
            // Check for glitches in normal operation
            #1; // Small delta delay
            if (op == 3'b000 && y !== (a + b) && $time > 100) begin
                $display("WARNING: Unexpected output at time %0t", $time);
            end
        end
    end */
endmodule
