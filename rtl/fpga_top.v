module fpga_top (
    input  wire        clk,              // onboard 50MHz osc, PIN_17
    
    // Buttons (active-low, pulled up internally)
    input  wire        rst_btn,
    input  wire        bist_btn,
    
    // DIP switches — all active-low (switch closed = 0, open = 1)
    // Wire each between GPIO pin and GND, enable internal pull-up
    input  wire [7:0]  sw_a,
    input  wire [7:0]  sw_b,
    input  wire [2:0]  sw_op,
    input  wire        sw_normal_enable,
    input  wire        sw_power_mode,
    input  wire        sw_bist_power_en,

    // LEDs — active-high, external via 330Ω to GND
    output wire [7:0]  led_y,
    output wire        led_bist_done,
    output wire        led_bist_pass
);

    // Invert active-low inputs
    wire reset            = ~rst_btn;
    wire bist_start       = ~bist_btn;
    wire [7:0] a          = ~sw_a;
    wire [7:0] b          = ~sw_b;
    wire [2:0] op         = ~sw_op;
    wire normal_enable    = ~sw_normal_enable;
    wire power_mode       = ~sw_power_mode;
    wire bist_power_enable = ~sw_bist_power_en;

    bist_alu_top #(
        .TEST_CYCLES (16'd50000)
    ) u_dut (
        .clk               (clk),
        .reset             (reset),
        .bist_start        (bist_start),
        .a                 (a),
        .b                 (b),
        .op                (op),
        .normal_enable     (normal_enable),
        .power_mode        (power_mode),
        .bist_power_enable (bist_power_enable),
        .y                 (led_y),
        .bist_done         (led_bist_done),
        .bist_pass         (led_bist_pass)
    );

endmodule