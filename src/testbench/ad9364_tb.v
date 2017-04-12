`timescale 1ns / 1ps

module ad9364_tb();

    reg clk, reset_b;
    wire xcvr_l_clk;
    
    // TX data path signals
    reg xcvr_data_clk = 0;
    reg xcvr_rx_frame = 0;
    reg [11:0] xcvr_data_p0 = 0;
    
    // RX data path signals
    wire xcvr_fb_clk;
    wire xcvr_tx_frame;
    wire [11:0] xcvr_data_p1;
    
    // Decoded RX data
    wire [23:0] xcvr_adc_data;
    wire xcvr_adc_valid;
    
    // TX data to send
    wire [23:0] xcvr_dac_data;
    reg xcvr_dac_valid = 1'b1;
    
    // FDD RX/TX enable
    wire xcvr_rx_enable;
    wire xcvr_tx_enable;
    
    ad9364_dev_if ad9364_if(
        .rx_clk_in(!xcvr_data_clk),
        .rx_frame_in(xcvr_rx_frame),
        .rx_data_in(xcvr_data_p0),
        .tx_clk_out(xcvr_fb_clk),
        .tx_frame_out(xcvr_tx_frame),
        .tx_data_out(xcvr_data_p1),
        .l_clk(xcvr_l_clk),
        .adc_data(xcvr_adc_data),
        .adc_valid(xcvr_adc_valid),
        .dac_data(xcvr_dac_data),
        .rx_enable(xcvr_rx_enable),
        .tx_enable(xcvr_tx_enable)
    );
    
    // Reset and generate master 100MHz clock
    initial begin
        clk = 1'b0;
        reset_b = 1'b0;
        repeat(4) #10 clk = ~clk;
        reset_b = 1'b1;
        forever #10 clk = ~clk;
    end
    
    // Generate varying AD9364 DATA_CLK
    initial begin
        xcvr_data_clk = 1'b0;
        forever begin
            repeat(512) #16 xcvr_data_clk = ~xcvr_data_clk; // ~60MHz clock
            repeat(128) #40 xcvr_data_clk = ~xcvr_data_clk; // 25MHz clock
        end
    end
    
    // Generate RX_FRAME signal
    always @(posedge xcvr_data_clk) begin
        #8 xcvr_rx_frame <= 1;
    end
    
    always @(negedge xcvr_data_clk) begin
        #8 xcvr_rx_frame <= 0;
    end
    
    // Generate RX data
    reg [11:0] simulated_i_data = 12'b111100000000;
    reg [11:0] simulated_q_data = 12'b000000000000;
    always @(posedge xcvr_data_clk) begin
        simulated_i_data <= simulated_i_data + 1;
    end
    
    always @(posedge xcvr_data_clk) begin
        simulated_q_data <= simulated_q_data + 1;
    end
    
    assign xcvr_dac_data = {simulated_i_data, simulated_q_data};
    
    // I data (rx_frame high)
    always @(posedge xcvr_data_clk) begin
        #8 xcvr_data_p0 <= simulated_i_data;
    end
    // Q data (rx_frame low)
    always @(negedge xcvr_data_clk) begin
        #8 xcvr_data_p0 <= simulated_q_data;
    end
    
    // Simulate activity
    initial begin
        @(posedge reset_b);
    end

endmodule