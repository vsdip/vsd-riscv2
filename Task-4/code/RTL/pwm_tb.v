`timescale 1ns/1ps

module pwm_tb;

    reg         clk;
    reg         resetn;
    reg         pwm_write;
    reg  [3:0]  pwm_addr;
    reg  [31:0] pwm_wdata;

    wire [31:0] pwm_rdata;
    wire        pwm_out;

    // DUT
    pwm DUT (
        .clk(clk),
        .resetn(resetn),
        .pwm_write(pwm_write),
        .pwm_addr(pwm_addr),
        .pwm_wdata(pwm_wdata),
        .pwm_rdata(pwm_rdata),
        .pwm_out(pwm_out)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Register addresses
    localparam CTRL   = 4'h0;
    localparam PERIOD = 4'h4;
    localparam DUTY   = 4'h8;
    localparam STATUS = 4'hC;

    // Register write task
    task write_reg;
        input [3:0] addr;
        input [31:0] data;
        begin
            @(negedge clk);
            pwm_addr  = addr;
            pwm_wdata = data;
            pwm_write = 1'b1;

            @(negedge clk);
            pwm_write = 1'b0;

            $display("WRITE: addr=%02x data=%08x", addr, data);
        end
    endtask

    initial begin
        clk       = 1'b0;
        resetn    = 1'b0;
        pwm_write = 1'b0;
        pwm_addr  = 4'b0;
        pwm_wdata = 32'b0;

        // Reset
        #20;
        resetn = 1'b1;

        // Configure PWM
        write_reg(PERIOD, 32'd8);
        write_reg(DUTY,   32'd2);
        write_reg(CTRL,   32'd1);     // Enable

        // Observe PWM
        $display("PWM TEST START");

        repeat (20) begin
            @(posedge clk);
            #1;
            $display("TIME=%0t COUNT=%0d PWM_OUT=%b STATUS=%08x",
                     $time,
                     DUT.counter,
                     pwm_out,
                     pwm_rdata);
        end

        // Disable
        write_reg(CTRL, 32'd0);

        #20;

        $display("PWM TEST COMPLETE");
        $finish;
    end

endmodule
