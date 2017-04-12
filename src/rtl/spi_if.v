module spi_if(
    input reset,
    input clk_100,
    
    output reg mosi,
    input miso,
    output spi_clk,
    output reg spi_en_b,
    
    output data_clk,
    
    // FIFO read interface (for MOSI) -- FWFT please
    input [7:0] read_data,
    input read_data_valid,
    input read_data_start_reading, // Will start reading if read_data_valid is high and read_data_start_reading transitions to high
    output reg read_data_rd_en,
    
    // FIFO write interface (for MISO)
    input [4:0] bytes_to_read,
    output reg [7:0] write_data,
    output reg write_data_wr_en
);

    reg [4:0] divider_counter = 0;
    
    always @(posedge clk_100, posedge reset) begin
        if(reset) begin
            divider_counter <= 0;
        end else begin
            divider_counter <= divider_counter + 1;
        end
    end
    
    reg [7:0] word_to_transmit;
    reg word_to_transmit_available;
    reg [2:0] read_index;
    reg word_to_transmit_available_d; // word_to_transmit_available delayed by one divider_counter[0] cycle
    reg read_data_allowed; // Goes high after all the bytes to be transmitted at once have been written into the FIFO, goes low when the FIFO is empty
    assign data_clk = divider_counter[0];
    assign spi_clk = divider_counter[0] && (word_to_transmit_available_d || (bytes_to_read > 5'd0));
    
    always @(posedge data_clk, posedge reset) begin
        if(reset) begin
            word_to_transmit <= 8'd0;
            word_to_transmit_available <= 0;
            word_to_transmit_available_d <= 0;
            mosi <= 0;
            read_index <= 0;
            spi_en_b <= 1;
            read_data_allowed <= 0;
        end else begin
            if(read_data_start_reading) begin
                read_data_allowed <= 1;
            end
            
            if(read_data_allowed && !read_data_valid) begin
                read_data_allowed <= 0;
            end
            
            if((read_data_allowed || read_data_start_reading) && read_data_valid && !word_to_transmit_available) begin
                read_data_rd_en <= 1;
                word_to_transmit <= read_data;
                word_to_transmit_available <= 1;
                read_index <= 0;
            end else begin
                read_data_rd_en <= 0;
            end
            
            if(((read_data_allowed || read_data_start_reading) && read_data_valid && !word_to_transmit_available) || (bytes_to_read > 5'd0)) begin
                spi_en_b <= 0;
            end
            
            if(word_to_transmit_available) begin
                mosi <= word_to_transmit[read_index];
                
                if(read_index == 3'd7) begin
                    // This was the last bit, wait for next word
                    if(!read_data_valid) begin
                        word_to_transmit_available <= 0;
                    end else begin
                        read_data_rd_en <= 1;
                        word_to_transmit <= read_data;
                        word_to_transmit_available <= 1;
                    end
                end
                
                read_index <= read_index + 1;
            end else begin
                mosi <= 0;
            end
            
            if(!read_data_valid && !word_to_transmit_available && !word_to_transmit_available_d && bytes_to_read == 5'd0) begin
                spi_en_b <= 1;
            end
            
            word_to_transmit_available_d <= word_to_transmit_available;
        end
    end
    
    reg [2:0] miso_read_index;
    reg [7:0] read_byte;
    reg miso_byte_read;
    
    always @(negedge data_clk, posedge reset) begin
        if(reset) begin
            miso_read_index <= 3'd0; 
            read_byte <= 8'd0;
            miso_byte_read <= 0;
        end else begin
            if(bytes_to_read > 5'd0) begin
                read_byte[miso_read_index] <= miso;
                
                if(miso_read_index == 3'd7) begin
                    // This is the last bit
                    miso_byte_read <= 1;
                end else begin
                    miso_byte_read <= 0;
                end
                
                miso_read_index <= miso_read_index + 1;
            end
        end
    end
    
    always @(posedge data_clk, posedge reset) begin
        if(reset) begin
            write_data <= 8'd0;
        end else if(miso_byte_read) begin
            write_data <= read_byte;
            write_data_wr_en <= 1;
        end else begin
            write_data_wr_en <= 0;
        end
    end

endmodule