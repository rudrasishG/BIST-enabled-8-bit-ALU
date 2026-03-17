module bist_controller (
    input  clk,
    input  reset,
    input  start,
    input  power_enable,           // Global power enable
    output reg bist_active,
    output reg done,
    output wire bist_clk_en        
);

    parameter TEST_CYCLES = 16;

    reg [4:0] count;
    reg [4:0] count_gray;  // Gray counter for lower switching
    
    // State encoding
    localparam IDLE   = 2'b00;
    localparam ACTIVE = 2'b01;
    localparam DONE   = 2'b11;
    
    reg [1:0] state, next_state;
    
    // Clock gating for counter
    wire count_en;
    assign count_en = bist_active & power_enable;
    assign bist_clk_en = count_en;
    
    // Gray code conversion for counter 
    function [4:0] bin2gray;
        input [4:0] binary;
        begin
            bin2gray = binary ^ (binary >> 1);
        end
    endfunction
    
    function [4:0] gray2bin;
        input [4:0] gray;
        integer i;
        begin
            gray2bin[4] = gray[4];
            for (i = 3; i >= 0; i = i - 1)
                gray2bin[i] = gray2bin[i+1] ^ gray[i];
        end
    endfunction
    
    // State machine 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else if (power_enable) begin
            state <= next_state;
        end
    end
    
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = ACTIVE;
            end
            ACTIVE: begin
                if (count == TEST_CYCLES - 1)
                    next_state = DONE;
            end
            DONE: begin
                if (!start)
                    next_state = IDLE;  // Auto-reset when start deasserted
            end
            default: next_state = IDLE;
        endcase
    end
    
    // Output logic
    always @(*) begin
        bist_active = (state == ACTIVE);
        done = (state == DONE);
    end
    
    // Gray counter 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 5'd0;
            count_gray <= 5'd0;
        end else if (count_en) begin
            count <= count + 1;
            count_gray <= bin2gray(count + 1);
        end else if (state == IDLE) begin
            count <= 5'd0;
            count_gray <= 5'd0;
        end
    end
    
    // Synthesis directives
    // synthesis attribute state high_vt_cell true
    // synthesis attribute count_gray low_power_register true

endmodule

