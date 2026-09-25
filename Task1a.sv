//TOP MODULE
module top (
    input  logic       clk_50MHz,
    input  logic       reset_n,
    input  logic [4:0] pulse_width,
    output logic       clk_5MHz,
    output logic       clk_500Hz,
    output logic       pwm_signal
);

    frequency_scaling u_frequency_scaling (
        .clk_50MHz (clk_50MHz),
        .reset_n   (reset_n),
        .clk_5MHz  (clk_5MHz)
    );

    pwm_generator u_pwm_generator (
        .clk_5MHz    (clk_5MHz),
        .reset_n     (reset_n),
        .pulse_width (pulse_width),
        .clk_500Hz   (clk_500Hz),
        .pwm_signal  (pwm_signal)
    );

endmodule

//PWM GENERATOR
module pwm_generator (
    input  logic       clk_5MHz,
    input  logic       reset_n,
    input  logic [4:0] pulse_width,
    output logic       clk_500Hz,
    output logic       pwm_signal
);

    localparam int TICK_COUNT        = 500;
    localparam int COUNTS_PER_PERIOD = 20;

    logic [8:0] tick_cnt;
    logic       tick;

    always_ff @(posedge clk_5MHz or negedge reset_n) begin
        if (!reset_n) begin
            tick_cnt <= '0;
            tick     <= 1'b0;
        end else if (tick_cnt == TICK_COUNT - 1) begin
            tick_cnt <= '0;
            tick     <= 1'b1;
        end else begin
            tick_cnt <= tick_cnt + 1'b1;
            tick     <= 1'b0;
        end
    end

    logic [4:0] pwm_cnt;

    always_ff @(posedge clk_5MHz or negedge reset_n) begin
        if (!reset_n) begin
            pwm_cnt <= '0;
        end else if (tick) begin
            if (pwm_cnt == COUNTS_PER_PERIOD - 1)
                pwm_cnt <= '0;
            else
                pwm_cnt <= pwm_cnt + 1'b1;
        end
    end

    always_ff @(posedge clk_5MHz or negedge reset_n) begin
        if (!reset_n) begin
            clk_500Hz  <= 1'b0;
            pwm_signal <= 1'b0;
        end else begin
            clk_500Hz  <= (pwm_cnt < (COUNTS_PER_PERIOD / 2));
            pwm_signal <= (pwm_cnt < pulse_width);
        end
    end

endmodule

//FREQUENCY SACLING 

module frequency_scaling (
    input  logic clk_50MHz,
    input  logic reset_n,
    output logic clk_5MHz
);

    localparam int HALF_PERIOD = 5;

    logic [2:0] cnt;

    always_ff @(posedge clk_50MHz or negedge reset_n) begin
        if (!reset_n) begin
            cnt      <= '0;
            clk_5MHz <= 1'b0;
        end else if (cnt == HALF_PERIOD - 1) begin
            cnt      <= '0;
            clk_5MHz <= ~clk_5MHz;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

endmodule


