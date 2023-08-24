module one_shot_timer_tb();    
    localparam FINAL_VALUE = 9;
    
    reg clk, rst_n;
    wire done;
    
    one_shot_timer #(.FINAL_VALUE(FINAL_VALUE)) uut(.clk(clk), .rst_n(rst_n), .done(done));
    
    localparam CLK_PERIOD = 10;    
    always
        #(CLK_PERIOD / 2)    clk = ~clk;
    
    initial
    begin
        clk = 1'b1;     rst_n = 1'b0;
        @(negedge clk) rst_n = 1'b1;
        repeat (4) begin
            repeat(12) @(negedge clk);
            rst_n = 1'b0;
            @(negedge clk)  rst_n = 1'b1;
        end
        $stop;
    end
endmodule
