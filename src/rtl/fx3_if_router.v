module fx3_if_router(
    input reset,
    
    // UART RX interface
    input uart_sample_clock,
    input [7:0] uart_rx_data,
    input uart_rx_data_valid,
    
    // UART TX interface
    output uart_tx_data_wr_clk,     // 16x oversampled clock for UART
    output reg [7:0] uart_tx_data,
    output reg uart_tx_data_valid,
    
    // UART TX debug
    output uart_debug_wr_clk,       // 16x oversampled clock for UART
    output reg [7:0] uart_debug_data,
    output reg uart_debug_data_valid,
    
    // GPIO interface
    inout [31:0] gpio,
    
    // XCVR SPI TX interface (for FIFO)
    output xcvr_tx_data_wr_clk, // Clock for FIFO
    output reg xcvr_tx_data_wr_en,  // FIFO write enable
    output reg [7:0] xcvr_tx_data,  // Data to be written
    output reg xcvr_tx_data_valid_d2,  // For multi-byte SPI transfers: This will go high when all required bytes to be written to SPI are available in FIFO
    
    // XCVR SPI RX interface -- FIFO should be FWFT
    output xcvr_rx_data_rd_clk,
    output reg xcvr_rx_data_rd_en,
    input [7:0] xcvr_rx_data,
    output reg [5:0] xcvr_bytes_to_read, // Number of data bytes to be received over SPI and transmitted over UART to FX3
    input xcvr_rx_data_valid
);

localparam CMD_GPIO_INPUT = 3'd0,
           CMD_GPIO_OUTPUT_HIGH = 3'd1,
           CMD_GPIO_OUTPUT_LOW = 3'd2,
           CMD_XCVR_SPI_READ = 3'd3,
           CMD_XCVR_SPI_WRITE = 3'd4,
           CMD_UART_DEBUG = 3'd5;

reg uart_rx_data_read = 0; // Gets set to 1 after reading uart_rx_data: prevents reading same data multiple times
reg [4:0] rx_num_data = 5'd0; // Number of data bytes to be received and forwarded over SPI

reg [4:0] debug_num_data = 5'd0;

wire [3:0] rx_header_cmd;
wire [4:0] rx_header_payload;
assign rx_header_cmd = uart_rx_data[7:5];
assign rx_header_payload = uart_rx_data[4:0];

reg xcvr_tx_data_valid;
reg xcvr_tx_data_valid_d;

// GPIO
reg [31:0] gpio_is_output = 32'd0; // Bits set to 1 identify GPIOs set to output
reg [31:0] gpio_output_values = 32'd0;

generate
    genvar i;
    for(i = 0; i < 32; i = i+1) begin
        assign gpio[i] = gpio_is_output[i] ? gpio_output_values[i] : 'dz;
    end
endgenerate

assign xcvr_tx_data_wr_clk = ~uart_sample_clock; // Make FIFO read TX data at center of cycle
assign xcvr_rx_data_rd_clk = ~uart_sample_clock;
assign uart_tx_data_wr_clk = ~uart_sample_clock;
assign uart_debug_wr_clk = ~uart_sample_clock;

always @(posedge uart_sample_clock, posedge reset) begin
    if(reset) begin
        uart_rx_data_read <= 0;
        rx_num_data <= 5'd0; 
        xcvr_bytes_to_read <= 5'd0;
        debug_num_data <= 5'd0;
        uart_tx_data_valid <= 0;
        uart_tx_data <= 8'd0;
        uart_debug_data_valid <= 0;
        uart_debug_data <= 8'd0;
        gpio_is_output <= 32'd0;
        xcvr_tx_data <= 8'd0;
        xcvr_tx_data_wr_en <= 0;
        xcvr_tx_data_valid <= 0;
        xcvr_tx_data_valid_d <= 0;
        xcvr_tx_data_valid_d2 <= 0;
    end else begin
        xcvr_tx_data_wr_en <= 0;
        xcvr_tx_data_valid <= 0;
        uart_tx_data_valid <= 0;
        uart_debug_data_valid <= 0;
        xcvr_tx_data_valid_d <= xcvr_tx_data_valid;
        xcvr_tx_data_valid_d2 <= xcvr_tx_data_valid_d;
        
        if(uart_rx_data_valid && !uart_rx_data_read) begin
            uart_rx_data_read <= 1;
            
            if(rx_num_data == 5'd0 && debug_num_data == 5'd0) begin
                // No data words to be read, so this must be a header
                case(rx_header_cmd)
                    CMD_GPIO_INPUT: begin
                        gpio_is_output[rx_header_payload] <= 0;
                        uart_tx_data <= gpio[rx_header_payload];
                        uart_tx_data_valid <= 1;
                    end
                    CMD_GPIO_OUTPUT_HIGH: begin
                        gpio_is_output[rx_header_payload] <= 1;
                        gpio_output_values[rx_header_payload] <= 1;
                    end
                    CMD_GPIO_OUTPUT_LOW: begin
                        gpio_is_output[rx_header_payload] <= 1;
                        gpio_output_values[rx_header_payload] <= 0;
                    end
                    CMD_XCVR_SPI_READ: begin
                        xcvr_bytes_to_read <= rx_header_payload;
                    end
                    CMD_XCVR_SPI_WRITE: begin
                        rx_num_data <= rx_header_payload;
                    end
                    CMD_UART_DEBUG: begin
                        debug_num_data <= rx_header_payload;
                    end
                    default: begin
                        // Ignore command with unknown ID
                    end
                endcase
            end else if (rx_num_data > 5'd0) begin
                // There is data to be forwarded to SPI
                
                xcvr_tx_data <= uart_rx_data;
                xcvr_tx_data_wr_en <= 1;
                
                if(rx_num_data - 1 == 0) begin
                    xcvr_tx_data_valid <= 1;
                end
                
                rx_num_data <= rx_num_data - 1;
            end else if (debug_num_data > 5'd0) begin
               // There is data to be forwarded to the UART debug port
               
               uart_debug_data <= uart_rx_data;
               uart_debug_data_valid <= 1;
               
               debug_num_data <= debug_num_data - 1;
            end
        end else if(!uart_rx_data_valid) begin
            uart_rx_data_read <= 0;
        end
        
        if(xcvr_rx_data_valid && xcvr_bytes_to_read > 5'd0) begin
            xcvr_rx_data_rd_en <= 1;
            uart_tx_data <= xcvr_rx_data;
            uart_tx_data_valid <= 1;
            xcvr_bytes_to_read <= xcvr_bytes_to_read - 1;
        end else begin
            xcvr_rx_data_rd_en <= 0;
        end
    end
end

endmodule