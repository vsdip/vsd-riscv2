module gpio (
    input         clk,
    input         gpio_write,
    input  [3:0]  gpio_addr,
    input  [31:0] gpio_wdata,
    input  [31:0] gpio_in,

    output [31:0] gpio_rdata,
    output [31:0] gpio_out
);

    reg [31:0] gpio_data_reg;
    reg [31:0] gpio_dir_reg;

    // Register addresses
    localparam GPIO_DATA = 4'h0;
    localparam GPIO_DIR  = 4'h4;
    localparam GPIO_READ = 4'h8;

    // Write registers
    always @(posedge clk) begin
        if (gpio_write) begin
            case (gpio_addr)
                GPIO_DATA: gpio_data_reg <= gpio_wdata;
                GPIO_DIR : gpio_dir_reg  <= gpio_wdata;
            endcase
        end
    end

    // Output pins
    assign gpio_out = gpio_data_reg & gpio_dir_reg;

    // Read registers
    assign gpio_rdata =
        (gpio_addr == GPIO_DATA) ? gpio_data_reg :
        (gpio_addr == GPIO_DIR)  ? gpio_dir_reg  :
        (gpio_addr == GPIO_READ) ? ((gpio_data_reg & gpio_dir_reg) |
                                    (gpio_in & ~gpio_dir_reg)) :
                                    32'b0;

endmodule
