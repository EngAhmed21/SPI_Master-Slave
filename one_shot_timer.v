/*
    This is the design of the one shot timer
*/

module one_shot_timer #(parameter FINAL_VALUE = 9) (
    input clk, rst_n,
    output done
    );
    localparam N_BITS = $clog2(FINAL_VALUE + 1);
    reg [N_BITS - 1 : 0] Q_next, Q_reg;
    
    always @(posedge clk) begin
        if(!rst_n)
            Q_reg <= 'd0;
        else
            Q_reg <= Q_next; 
    end    
    
    /*  It is an one-shot timer, so its value won't return to 0
        unless the reset signal is asserted.  */
    always @(*) begin
        if (done) 
            Q_next = Q_reg; 
        else
            Q_next = Q_reg + 1;
    end
    
    assign done = (Q_reg == FINAL_VALUE);
endmodule
