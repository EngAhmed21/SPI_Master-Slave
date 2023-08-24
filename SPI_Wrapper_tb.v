/*
    The testbench of the wrapper
*/

module SPI_Wrapper_tb ();
    localparam ADDR_SIZE = 8;
    localparam MEM_DEPTH = 256;

    reg clk, rst_n, SS_n, MOSI;
    wire MISO;

    SPI_Wrapper #(.ADDR_SIZE(ADDR_SIZE), .MEM_DEPTH(MEM_DEPTH)) uut (.clk(clk),
    .rst_n(rst_n), .SS_n(SS_n), .MOSI(MOSI), .MISO(MISO));

    localparam CLK_PERIOD = 10;
    always
        #(CLK_PERIOD / 2)   clk = ~clk;

    integer i;
    reg [ADDR_SIZE + 1 : 0] addr;
    initial begin
        clk = 1'b1;         rst_n = 1'b0;
        SS_n = 1'b1;        MOSI = 1'b0;

        $readmemh("memory_initial_content.dat", uut.MEMORY.mem, 0, 255);

        @(negedge clk)  rst_n = 1'b1;

        @(negedge clk)  SS_n = 1'b0;

        repeat(2)   @(negedge clk);
        addr = 10'b00_0000_0100;
        for (i = 10; i > 0; i = i - 1) begin
            MOSI = addr[i - 1];
            #(CLK_PERIOD);
        end 

        repeat(2)   @(negedge clk);
        MOSI = 1'b0;

        repeat(2)   @(negedge clk);
        addr = 10'b01_0001_0100;
        for (i = 10; i > 0; i = i - 1) begin
            MOSI = addr[i - 1];
        #(CLK_PERIOD);
        end

        repeat(2)   @(negedge clk);
        MOSI = 1'b1;

        repeat(2)   @(negedge clk);
        addr = 10'b10_0000_0100;
        for (i = 10; i > 0; i = i - 1) begin
            MOSI = addr[i - 1];
            #(CLK_PERIOD); 
        end

        repeat(2)   @(negedge clk);
        MOSI = 1'b1;

        repeat(2)   @(negedge clk);
        addr [ADDR_SIZE + 1 : ADDR_SIZE] = 2'b11;
        addr [ADDR_SIZE - 1 : 0] = $random;
        for (i = 10; i > 0; i = i - 1) begin
            MOSI = addr[i - 1];
            #(CLK_PERIOD); 
        end

        repeat(9)  @(negedge clk);
        $stop;
    end
endmodule
