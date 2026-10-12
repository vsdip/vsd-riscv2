`timescale 1ns/1ps

module pwm_soc_tb;

    reg clk;
    reg resetn;

    wire [31:0] mem_addr;
    wire [31:0] mem_rdata;
    wire        mem_rstrb;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wmask;

    wire [31:0] RAM_rdata;
    wire [31:0] pwm_rdata;
    wire        pwm_out;

    Processor CPU (
        .clk(clk),
        .resetn(resetn),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb),
        .mem_wdata(mem_wdata),
        .mem_wmask(mem_wmask)
    );

    wire [29:0] mem_wordaddr = mem_addr[31:2];
    wire isIO  = mem_addr[22];
    wire isRAM = !isIO;
    wire mem_wstrb = |mem_wmask;

    Memory RAM (
        .clk(clk),
        .mem_addr(mem_addr),
        .mem_rdata(RAM_rdata),
        .mem_rstrb(isRAM & mem_rstrb),
        .mem_wdata(mem_wdata),
        .mem_wmask({4{isRAM}} & mem_wmask)
    );

    // PWM address map:
    // 0x30 CTRL
    // 0x34 PERIOD
    // 0x38 DUTY
    // 0x3C STATUS
    wire [3:0] io_addr = mem_wordaddr[3:0];

    wire pwm_sel =
        isIO &&
        (io_addr >= 4'd12) &&
        (io_addr <= 4'd15);

    wire pwm_valid = pwm_sel && mem_wstrb;

    wire [3:0] pwm_addr =
        {io_addr[1:0], 2'b00};

    pwm PWM (
        .clk(clk),
        .resetn(resetn),
        .pwm_write(pwm_valid),
        .pwm_addr(pwm_addr),
        .pwm_wdata(mem_wdata),
        .pwm_rdata(pwm_rdata),
        .pwm_out(pwm_out)
    );

    assign mem_rdata =
        isRAM   ? RAM_rdata :
        pwm_sel ? pwm_rdata :
                  32'b0;

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (pwm_valid)
            $display("PWM WRITE: addr=%h data=%h",
                     mem_addr, mem_wdata);

        if (mem_rstrb && pwm_sel)
            $display("PWM READ : addr=%h data=%h",
                     mem_addr, pwm_rdata);

        if (pwm_out)
            $display("PWM OUT HIGH: time=%0t", $time);
    end

    initial begin
        clk = 0;
        resetn = 0;

        #100;
        resetn = 1;

        #200000;

        $display("PWM CPU TEST TIMEOUT");
        $finish;
    end

endmodule
