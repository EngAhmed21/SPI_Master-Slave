/*
    This is the testbench of the slave interface
*/

module SPI_Slave_tb ();
    localparam ADDR_SIZE = 8;

    reg clk, rst_n, SS_n, MOSI, tx_valid;
    reg [ADDR_SIZE - 1 : 0] tx_data;
    wire MISO, rx_valid;
    wire [(ADDR_SIZE - 1) + 2 : 0] rx_data;

    SPI_Slave #(.ADDR_SIZE(ADDR_SIZE)) uut (.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .MOSI(MOSI),
     .tx_valid(tx_valid), .tx_data(tx_data), .MISO(MISO), .rx_valid(rx_valid), .rx_data(rx_data));

    localparam CLK_PERIOD = 10;
    always
        #(CLK_PERIOD / 2)   clk = ~clk;

    integer i;
    reg [ADDR_SIZE + 1 : 0] addr;
    initial begin
        clk = 1'b1;         rst_n = 1'b0;
        SS_n = 1'b1;        MOSI = 1'b0;
        tx_valid = 1'b0;    tx_data = 0;
        
        @(negedge clk)  rst_n = 1'b1;

        @(negedge clk)  SS_n = 1'b0;
        repeat (2) begin
            @(negedge clk)  MOSI = 1'b0;
            @(negedge clk);
            addr [ADDR_SIZE + 1 : ADDR_SIZE] = 2'b00;
            addr [ADDR_SIZE - 1 : 0] = $random;
            for (i = 10; i > 0; i = i - 1) begin
                MOSI = addr[i - 1];
                #(CLK_PERIOD);
            end

            repeat(2)   @(negedge clk);
            MOSI = 1'b1;

            repeat(2)   @(negedge clk);
            addr [ADDR_SIZE + 1 : ADDR_SIZE] = 2'b10;
            addr [ADDR_SIZE - 1 : 0] = $random;
            for (i = 10; i > 0; i = i - 1) begin
                MOSI = addr[i - 1];
                #(CLK_PERIOD); 
            end

            repeat(2)   @(negedge clk);
            MOSI = 1'b1;

            repeat(2)   @(negedge clk);
            addr [ADDR_SIZE + 1 : ADDR_SIZE] = 2'b11;
            addr [ADDR_SIZE - 1 : 0] = $random;
            tx_valid = 1'b1;
            tx_data = $random;
            for (i = 10; i > 0; i = i - 1) begin
                MOSI = addr[i - 1];
                #(CLK_PERIOD); 
            end

            repeat(10)  @(negedge clk);
        end
        $stop;
    end
endmodule
