/*
    This is the design of the slave interface
*/

module SPI_Slave #(parameter ADDR_SIZE = 8)(
    input clk, rst_n, SS_n, MOSI, tx_valid,
    input [ADDR_SIZE - 1 : 0] tx_data,
    output reg MISO,
    output rx_valid,
    output reg [ADDR_SIZE + 1 : 0] rx_data
);
    // Declaring the states
    localparam IDLE = 3'b000;
    localparam CHK_CMD = 3'b001;
    localparam WRITE = 3'b010;
    localparam READ_ADD = 3'b011;
    localparam READ_DATA = 3'b100;

    /* 
        The following line is used in VIVADO to choose the encoding style.
        I used the sequential encoding style as it has the highest setup 
        slack which mean it makes you capable of using a clock with
        higher frequency than the other encoding styles.
    */
    (* fsm_encoding = "sequential" *)
    reg [2 : 0] cs, ns;

    // Declaring the internal signals
    wire timer10_done, timer8_done, timer10_rstn, timer8_rstn;
    reg read_data_sel, rx_valid_in_RD;
    reg [$clog2(ADDR_SIZE) - 1 : 0] parrallel_to_serial_ind;

    // Timers 
    assign timer10_rstn = (cs == WRITE) || (cs == READ_ADD) || (cs == READ_DATA);
    assign timer8_rstn = (cs == READ_DATA) && (timer10_done);
    one_shot_timer #(.FINAL_VALUE(10)) timer_10 (.clk(clk), .rst_n(timer10_rstn), .done(timer10_done));
    one_shot_timer #(.FINAL_VALUE(8)) timer_8 (.clk(clk), .rst_n(timer8_rstn), .done(timer8_done));
    
    // read_data_sel is the signal which determine if the next state is READ_ADD or READ_DATA
    always @(posedge clk) begin
        if (!rst_n)
            read_data_sel <= 0;
        else if (cs == READ_ADD)
            read_data_sel <= 1;
        else if (cs == READ_DATA)
            read_data_sel <= 0;
    end
    
    // next state
    always @(*) begin
        case (cs) 
            IDLE:       ns = (SS_n) ? IDLE : CHK_CMD;
            CHK_CMD:    
                if (SS_n)
                    ns = IDLE;
                else if (!MOSI)
                    ns = WRITE;
                else if (!read_data_sel)  
                    ns = READ_ADD;
                else 
                    ns = READ_DATA;
            WRITE:      
                if (SS_n || timer10_done)
                    ns = IDLE;
                else 
                    ns = WRITE;
            READ_ADD:   
                if (SS_n || timer10_done)
                    ns = IDLE;
                else
                    ns = READ_ADD;
            READ_DATA:  
                if (SS_n || timer8_done)
                    ns = IDLE;
                else 
                    ns = READ_DATA;
            default:    ns = IDLE;
        endcase
    end

    // current state
    always @(posedge clk) begin
        if (!rst_n) 
            cs <= IDLE;
        else
            cs <= ns;
    end

    /*  parrallel_to_serial_ind is used in indexing the parallel vector to assign the 
        correct value to the serial output.  */
    always @(posedge clk) begin
        if (!timer8_rstn)
            parrallel_to_serial_ind <= ADDR_SIZE - 1;
        else
            parrallel_to_serial_ind <= parrallel_to_serial_ind - 1;
    end

    /*  rx_valid_in_RD is used to allow rx_valid to be high in READ_DATA
        state for one clock period only.  */
    always @(posedge clk) begin
        if (!timer10_rstn)
            rx_valid_in_RD <= 0;
        else if (timer10_done)
            rx_valid_in_RD <= 1;
    end

    // outputs
    always @(posedge clk) begin
        if (!rst_n) begin
            MISO <= 0;
            rx_data <= 0;
        end
        else 
            if (((cs == WRITE) || (cs == READ_ADD) || (cs == READ_DATA)) && (!timer10_done))
                rx_data <= {rx_data[ADDR_SIZE : 0], MOSI};
            else if ((cs == READ_DATA) && (tx_valid) && (timer10_done) && (!timer8_done)) 
                MISO <= tx_data[parrallel_to_serial_ind];
    end
    assign rx_valid = (((cs == WRITE) || (cs == READ_ADD) || ((cs == READ_DATA)) && (!rx_valid_in_RD)) && (timer10_done));
endmodule
