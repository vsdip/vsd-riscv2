module pwm (
    input         clk,
    input         resetn,

    input         pwm_write,
    input  [3:0]  pwm_addr,
    input  [31:0] pwm_wdata,

    output [31:0] pwm_rdata,
    output        pwm_out
);

    // Register map
    localparam PWM_CTRL   = 4'h0;
    localparam PWM_PERIOD = 4'h4;
    localparam PWM_DUTY   = 4'h8;
    localparam PWM_STATUS = 4'hC;

    // Registers
    reg [31:0] ctrl_reg;
    reg [31:0] period_reg;
    reg [31:0] duty_reg;

    // PWM counter
    reg [31:0] counter;

    wire enable   = ctrl_reg[0];
    wire polarity = ctrl_reg[1];

    // Register write logic
    always @(posedge clk) begin
        if (!resetn) begin
            ctrl_reg   <= 32'b0;
            period_reg <= 32'b1;
            duty_reg   <= 32'b0;
        end
        else if (pwm_write) begin
            case (pwm_addr)
                PWM_CTRL:   ctrl_reg   <= pwm_wdata;
                PWM_PERIOD: period_reg <= pwm_wdata;
                PWM_DUTY:   duty_reg   <= pwm_wdata;
                default: ;
            endcase
        end
    end

    // PWM counter
    always @(posedge clk) begin
        if (!resetn) begin
            counter <= 32'b0;
        end
        else if (!enable) begin
            counter <= 32'b0;
        end
        else if (period_reg <= 32'd1) begin
            counter <= 32'b0;
        end
        else if (counter >= period_reg - 1'b1) begin
            counter <= 32'b0;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    // PWM generation
    wire pwm_raw = (counter < duty_reg);

    assign pwm_out = enable ?
                     (polarity ? ~pwm_raw : pwm_raw) :
                     (polarity ? 1'b1 : 1'b0);

    // Register read logic
    assign pwm_rdata =
        (pwm_addr == PWM_CTRL)   ? ctrl_reg :
        (pwm_addr == PWM_PERIOD) ? period_reg :
        (pwm_addr == PWM_DUTY)   ? duty_reg :
        (pwm_addr == PWM_STATUS) ? {15'b0, counter[15:0], enable} :
                                   32'b0;

endmodule
