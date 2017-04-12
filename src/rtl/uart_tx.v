module uart_tx(
    input reset,
    
    input tx_clk, // 16x oversampled
    output reg uart_tx, // Actual UART TX output
    
    input [7:0] uart_data, // Data to send
    input uart_data_valid  // Read data when this goes high
);
    
    reg [9:0] tx_data = 8'd0;
    reg tx_data_read = 0;
    reg [3:0] tx_divider_counter = 0; // tx_clk is 16x oversampled, so it has to be divided down
    reg [3:0] tx_bit_index = 0; // keep track of which bit to send
    
    always @(posedge tx_clk, posedge reset) begin
        if(reset) begin
            uart_tx <= 1;
            tx_data <= 8'd0;
            tx_divider_counter <= 0;
            tx_bit_index <= 0;
        end else begin
            if(uart_data_valid && !tx_data_read) begin
                tx_data[0] <= 0; // Start bit
                tx_data[9] <= 1; // Stop bit
                tx_data[8:1] <= uart_data;
                tx_data_read <= 1;
                tx_divider_counter <= 0;
                tx_bit_index <= 0;
            end else if(tx_data_read && tx_divider_counter == 0 && tx_bit_index <= 4'd9) begin
                uart_tx <= tx_data[tx_bit_index];
                if(tx_bit_index == 4'd9) begin
                    tx_data_read <= 0; // Ready for next bit
                end
                tx_bit_index <= tx_bit_index + 1;
            end
            
            if(tx_data_read) begin
                tx_divider_counter <= tx_divider_counter + 1;
            end
        end
    end
endmodule