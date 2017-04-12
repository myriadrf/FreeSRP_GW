module fx3_uart_if(
    input clk_100,
    input reset,
    
    output rx_sample_clock, // 16x oversampled
    
    input uart_rx,
    
    output [7:0] rx_data,
    output rx_data_valid
);
    // 8 bits, no parity, one stop bit
    
    
    parameter CLK_DIVISOR = 54; // 54 for 115200 baud; divisor is = clock frequency / (16 * baud rate)

    // Sample bit when this is high
    reg do_sample = 0;
    reg uart_rx_completed = 0;
    wire valid_data;
    
    // Divide clk_100 down to 16 times the baud rate (rx_clk)

    reg [15:0] div_counter = 0;
    reg rx_clk = 0;

    always @(posedge clk_100, posedge reset) begin
        if(reset) begin
            div_counter <= 16'd0;
            rx_clk = 0;
        end else begin
            if(div_counter >= CLK_DIVISOR) begin
                div_counter <= 16'd0;
                rx_clk <= ~rx_clk;
            end else begin
                div_counter <= div_counter + 2;
            end
        end
    end
    
    assign rx_sample_clock = rx_clk;
    
    // State machine for RX
    localparam STATE_idle = 4'd0,
               STATE_rx = 4'd1;
               
    reg [3:0] current_state = STATE_idle;
    reg [3:0] next_state;
    
    always @(*) begin
    next_state = current_state;
        case(current_state)
            STATE_idle: begin
               if(uart_rx == 0) next_state = STATE_rx;
            end
            STATE_rx: begin
               if(uart_rx_completed) next_state = STATE_idle;
            end
        endcase
    end
    
    always @(posedge rx_clk, posedge reset) begin
        if(reset) begin
            current_state <= STATE_idle;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Generate the RX port sampling tick in the center of a UART clock cycle
    
    reg [3:0] sample_counter = 0;
    
    always @(posedge rx_clk, posedge reset) begin
        if(reset || (current_state != STATE_rx)) begin
            sample_counter <= 4'd0;
            do_sample <= 0;
            uart_rx_completed <= 0;
        end else begin
            if(sample_counter == 4'd7) begin // Sample at the center of the clock cycle (at the eigth cycle of the 16x oversampling clock)
                do_sample <= 1;
            end else begin
                do_sample <= 0;
            end
            sample_counter <= sample_counter + 1;
        end
    end
    
    // Sample data
    
    reg [3:0] recv_bit_counter = 4'd0;
    reg [7:0] recv_data_bits = 4'd0;
    assign valid_data = recv_bit_counter <= 4'd9;
    assign rx_data_valid = recv_bit_counter >= 4'd9;
    assign rx_data = recv_data_bits;
    
    always @(posedge do_sample, posedge reset) begin
        if(reset) begin
            recv_bit_counter <= 4'd0;
            recv_data_bits <= 4'd0;
        end else begin
            recv_bit_counter <= recv_bit_counter + 1;
            if(recv_bit_counter == 4'd0) begin
                recv_data_bits <= 4'd0;
            end else if(recv_bit_counter >= 4'd1 && recv_bit_counter <= 4'd8) begin
                recv_data_bits[recv_bit_counter - 1] <= uart_rx;
            end else if(recv_bit_counter == 4'd9) begin
                recv_bit_counter <= 4'd0;
                uart_rx_completed <= 1;
            end
        end
    end

endmodule
