module RAM #(parameter MEM_DEPTH = 256, ADDR_SIZE = 8)(
    input clk, rst_n, rx_valid,
    input [ADDR_SIZE + 1 : 0] din,
    output tx_valid,
    output reg [ADDR_SIZE - 1 : 0] dout
);

    reg [ADDR_SIZE - 1 : 0] mem [0 : MEM_DEPTH - 1];
    reg [ADDR_SIZE - 1 : 0] write_addr, read_addr;
    reg tx_valid_en;
    wire timer8_done;

    always @(posedge clk) begin
        if (!rst_n) begin
            write_addr <= 0;
            read_addr <= 0;
            dout <= 0;
        end
        else if (rx_valid) 
            case (din [(ADDR_SIZE + 1) : (ADDR_SIZE)])
                2'b00:      write_addr <= din [ADDR_SIZE - 1 : 0];    
                2'b01:      mem [write_addr] <= din [ADDR_SIZE - 1 : 0];
                2'b10:      read_addr <= din [ADDR_SIZE - 1 : 0];
                2'b11:      dout <= mem [read_addr];
            endcase
    end

    /*  tx_valid_en is a FF that hold the value 1 for 8 clock cycles so the 
        SPI-Slave has the time to convert the parallel array dout(tx_data) 
        to a serial output (MISO).  */
    always @(posedge clk, negedge rst_n, posedge timer8_done) begin
        if ((!rst_n) || (timer8_done))
            tx_valid_en <= 0;
        else if (rx_valid && (din [(ADDR_SIZE + 1) : (ADDR_SIZE)] == 2'b11))
            tx_valid_en <= 1;
    end
    one_shot_timer #(.FINAL_VALUE(8)) timer_8 (.clk(clk), .rst_n(tx_valid_en), .done(timer8_done));    

    assign tx_valid = tx_valid_en;
endmodule