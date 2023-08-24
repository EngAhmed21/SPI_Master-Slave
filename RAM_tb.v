/*
    The testbench of RAM
*/

module RAM_tb ();
    localparam MEM_DEPTH = 256;
    localparam ADDR_SIZE = 8;

    reg clk, rst_n, rx_valid;
    reg [ADDR_SIZE + 1 : 0] din;
    wire tx_valid;
    wire [ADDR_SIZE - 1 : 0] dout;

    RAM #(.MEM_DEPTH(MEM_DEPTH), .ADDR_SIZE(ADDR_SIZE)) M1 (.clk(clk), .rst_n(rst_n),
    .rx_valid(rx_valid), .din(din), .tx_valid(tx_valid), .dout(dout));

    localparam CLK_PERIOD = 10;
    always
        #(CLK_PERIOD / 2)   clk = ~clk;
    
    initial begin
        clk = 1'b1;         rst_n = 1'b0;
        rx_valid = 1'b0;    din = 0;

        // The RAM is initialized as mem[index] = index % 32
        $readmemh("memory_initial_content.dat", M1.mem, 0, 255);

        @(negedge clk)  rst_n = 1'b1;
        
        repeat(5)@(negedge clk)  din = $random;
        
        @(negedge clk)  rx_valid = 1'b1;
        repeat(30)@(negedge clk)  din = $random;
        $stop;
    end
endmodule
