`timescale 1ns / 1ps

module uart_tb();
    reg clk;
    reg rx_test_clk = 0;
    reg reset = 0;
    reg uart_rx = 1;
    wire uart_tx;
    wire uart_debug_tx;
    wire [7:0] rx_data;
    wire rx_data_valid;
    wire rx_sample_clock;
    wire [31:0] gpio;
    wire [7:0] tx_data;
    wire tx_data_valid;
    wire tx_data_wr_clk;
    wire uart_debug_wr_clk;
    wire [7:0] uart_debug_data;
    wire uart_debug_data_valid;
    
    parameter RX_TEST_DIVIDER = 864; // 115200 baud
    parameter SPACING = 0; // spacing between transmissions (1 = time it takes for one bit to be transmitted)
    
    reg gpio_input_test_value = 1;
    assign gpio[5] = gpio_input_test_value;
    
    // Reset and generate clock
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat(4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end
    
    reg [15:0] test_divider_counter = 16'd0;
    
    always @(posedge clk) begin
        // TODO: generate UART data, divide down clk to 115200 kHz
        if(test_divider_counter < RX_TEST_DIVIDER) begin
            test_divider_counter <= test_divider_counter + 2;
        end else begin
            test_divider_counter <= 16'd0;
            rx_test_clk = ~rx_test_clk;
        end
    end
    
    reg [9:0] test_data;
    
    initial begin
        test_data[0] = 0; // Start bit
        test_data[9] = 1; // Stop bit
        
        //test_data[8:6] = 3'd2; // GPIO HIGH command
        //test_data[5:1] = 3'd5; // Which GPIO to set HIGH
        
        //test_data[8:6] = 3'd0; // GPIO input command
        //test_data[5:1] = 3'd5; // Which GPIO to read
        
        //test_data[8:6] = 3'd4; // XCVR SPI write command
        //test_data[5:1] = 3'd5; // Number of data bytes
        
        test_data[8:6] = 3'd3; // XCVR SPI read command
        test_data[5:1] = 3'd5; // Number of data bytes
        
        //test_data[8:6] = 3'd5; // Debug UART output command
        //test_data[5:1] = 3'd3; // Number of data bytes
    end
    
    reg [15:0] data_counter = 16'd0;
    
    always @(posedge rx_test_clk) begin
        if(data_counter <= 16'd9) begin
            uart_rx <= test_data[data_counter];
        end else begin
            uart_rx <= 1;
        end
        
        if(data_counter == 16'd9 + SPACING) begin
            data_counter <= 16'd0;
        end else begin
            data_counter <= data_counter + 1;
        end
    end
    
    // Print data received by uart
    always @(posedge rx_data_valid) begin
        $display("rx_data = %b", rx_data);
    end
    
    fx3_uart_if #(.CLK_DIVISOR(54)) uart_if(
        clk,
        reset,
        rx_sample_clock,
        uart_rx,
        rx_data,
        rx_data_valid
    );
    
    uart_tx fx3_tx(
        reset,
        tx_data_wr_clk,
        uart_tx,
        tx_data, // Data to send
        tx_data_valid  // Read data when this goes high
    );
    
    uart_tx debug_tx(
        reset,
        uart_debug_wr_clk,
        uart_debug_tx,
        uart_debug_data, // Data to send
        uart_debug_data_valid  // Read data when this goes high
    );
    
    wire mosi;
    reg miso;
    wire spi_clk;
    wire spi_en_b;
    
    wire spi_data_clk;
    
    wire [7:0] xcvr_rx_data;
    wire xcvr_rx_data_rd_en;
    wire xcvr_rx_empty;
    
    wire [7:0] spi_write_data;
    wire spi_write_data_wr_en;
    
    wire [7:0] spi_read_data;
    wire spi_read_data_rd_en;
    wire spi_read_empty;
    
    wire [4:0] xcvr_bytes_to_read;
    
    wire xcvr_tx_data_wr_clk;
    wire xcvr_tx_data_wr_en;  // FIFO write enable
    wire [7:0] xcvr_tx_data;  // Data to be written
    wire xcvr_tx_data_valid;  // For multi-byte SPI transfers: This will go high when all required bytes to be written to SPI are available in FIFO
    
    spi_fifo_subsystem spi_fifos(
        .RX_FIFO_READ_empty(xcvr_rx_empty),
        .RX_FIFO_READ_rd_data(xcvr_rx_data),
        .RX_FIFO_READ_rd_en(xcvr_rx_data_rd_en),
        .RX_FIFO_WRITE_full(xcvr_rx_full),
        .RX_FIFO_WRITE_wr_data(spi_write_data),
        .RX_FIFO_WRITE_wr_en(spi_write_data_wr_en),
        .TX_FIFO_READ_empty(spi_read_empty),
        .TX_FIFO_READ_rd_data(spi_read_data),
        .TX_FIFO_READ_rd_en(spi_read_data_rd_en),
        .TX_FIFO_WRITE_full(spi_write_full),
        .TX_FIFO_WRITE_wr_data(xcvr_tx_data),
        .TX_FIFO_WRITE_wr_en(xcvr_tx_data_wr_en),
        .fifo_rst(reset),
        .spi_clk(spi_data_clk),
        .uart_clk(xcvr_tx_data_wr_clk)
    );
    
    spi_if xcvr_spi(
        reset,
        clk,
        
        mosi,
        miso,
        spi_clk,
        spi_en_b,
        
        spi_data_clk,
        
        spi_read_data,
        !spi_read_empty,
        xcvr_tx_data_valid,
        spi_read_data_rd_en,
        
        xcvr_bytes_to_read,
        spi_write_data,
        spi_write_data_wr_en
    );
    
    fx3_if_router fx3_router(
        reset,
        rx_sample_clock,
        rx_data,
        rx_data_valid,
        tx_data_wr_clk,
        tx_data,
        tx_data_valid,
        uart_debug_wr_clk,
        uart_debug_data,
        uart_debug_data_valid,
        gpio,
        xcvr_tx_data_wr_clk, // Clock for FIFO
        xcvr_tx_data_wr_en,  // FIFO write enable
        xcvr_tx_data,  // Data to be written
        xcvr_tx_data_valid,  // For multi-byte SPI transfers: This will go high when all required bytes to be written to SPI are available in FIFO
        xcvr_rx_data_rd_clk,
        xcvr_rx_data_rd_en,
        xcvr_rx_data,
        xcvr_bytes_to_read,
        !xcvr_rx_empty
    );

endmodule
