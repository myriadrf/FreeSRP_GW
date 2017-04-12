module ad9364_dev_if(
    // physical interface (receive)
    input rx_clk_in,
    input rx_frame_in,
    input [11:0] rx_data_in,
    
    // physical interface (transmit)
    output tx_clk_out,
    output tx_frame_out,
    output [11:0] tx_data_out,
    
    // clock (common to both receive and transmit)
    output l_clk,
    
    // enable/disable datapath
    input enable_datapath,
    
    input rx_write_allowed,
    
    input tx_start_allowed,
    input tx_read_allowed,
    
    // receive data path interface
    output [23:0] adc_data,
    output adc_write_en,
    
    // transmit data path interface
    input [23:0] dac_data,
    output dac_read_en,
    
    // FDD RX/TX enable
    output rx_enable,
    output tx_enable
);
    
    genvar l_inst;
    
    (* mark_debug = "true" *) reg [11:0] rx_i_data;
    (* mark_debug = "true" *) reg [11:0] rx_q_data;
    assign adc_data = {rx_i_data, rx_q_data};
    
    (* mark_debug = "true" *) wire [11:0] tx_i_data;
    (* mark_debug = "true" *) wire [11:0] tx_q_data;
    assign tx_i_data = dac_data[23:12];
    assign tx_q_data = dac_data[11:0];
    
    reg rx_data_valid;
    
    // DATA_CLK global buffer and FB_CLK output
    BUFG i_clk_gbuf(
        .I(rx_clk_in),
        .O(l_clk)
    );
    
    /*ad_cmos_out i_tx_clk(
        .clk(l_clk),
        .data_posedge(1'b0),
        .data_negedge(1'b1),
        .data_out(tx_clk_out)
    );*/
    assign tx_clk_out = l_clk;
    
    // physical DDR RX interface (frame)
    wire rx_frame_pos;
    wire rx_frame_neg;
    
    ad_cmos_in i_rx_frame(
        .clk(l_clk),
        .data_in(rx_frame_in),
        .data_posedge(rx_frame_pos),
        .data_negedge(rx_frame_neg)
    );
    
    // physical DDR RX interface (data)
    wire [11:0] rx_data_pos; // Data clocked in at DDR clock positive edge
    wire [11:0] rx_data_neg; // Data clocked in at DDR clock negative edge
    
    generate
        for(l_inst = 0; l_inst <= 11; l_inst = l_inst + 1) begin: g_rx_data
            ad_cmos_in i_rx_data(
                .clk(l_clk),
                .data_in(rx_data_in[l_inst]),
                .data_posedge(rx_data_pos[l_inst]),
                .data_negedge(rx_data_neg[l_inst])
            );
        end
    endgenerate
    
    // physical DDR TX interface (frame)
    reg tx_frame_pos;
    reg tx_frame_neg;
    
    ad_cmos_out i_tx_frame(
        .clk(l_clk),
        .data_posedge(tx_frame_pos),
        .data_negedge(tx_frame_neg),
        .data_out(tx_frame_out)
    );
    
    // physical DDR TX interface (data)
    reg [11:0] tx_data_pos; // Data to be clocked in at DDR clock positive edge
    reg [11:0] tx_data_neg; // Data to be clocked in at DDR clock negative edge
    
    generate
        for(l_inst = 0; l_inst <= 11; l_inst = l_inst + 1) begin: g_tx_data
            ad_cmos_out i_tx_data (
                .clk(l_clk),
                .data_posedge(tx_data_pos[l_inst]),
                .data_negedge(tx_data_neg[l_inst]),
                .data_out(tx_data_out[l_inst])
            );
        end
    endgenerate
    
    // RX data path
    reg [11:0] rx_data_pos_d;
    reg [11:0] rx_data_neg_d;
    always @(posedge l_clk) begin
        rx_data_pos_d <= rx_data_pos;
        rx_data_neg_d <= rx_data_neg;
    end
    
    always @(posedge l_clk) begin
        if(rx_frame_pos == 1'b1) begin
            // Data clocked in at positive l_clk edge is I data
            rx_i_data <= rx_data_pos;
            rx_q_data <= rx_data_neg;
        end else begin
            // Data clocked in at positive l_clk edge is Q data
            rx_i_data <= rx_data_neg_d;
            rx_q_data <= rx_data_pos;
        end
    end
    
    // RX valid signal: Valid after 4 RX_FRAME transitions
    reg [1:0] rx_frame_d;
    wire [3:0] rx_frame_s;
    assign rx_frame_s = {rx_frame_d, rx_frame_pos, rx_frame_neg};
    always @(posedge l_clk) begin
        rx_frame_d[1] <= rx_frame_pos;
        rx_frame_d[0] <= rx_frame_neg;
    end
    
    always @(posedge l_clk) begin
        rx_data_valid <= ((rx_frame_s == 4'b1010) || (rx_frame_s == 4'b0101)) ? 1'b1 : 1'b0;
    end
    
    // Delay dac_read_en by one cycle (valid data available after one cycle)
    reg dac_read_en_d;
    always @(posedge l_clk) begin
        dac_read_en_d <= dac_read_en;
    end
    
    // TX data path
    always @(posedge l_clk) begin
        if(tx_enable) begin
            tx_frame_pos <= 1'b1;
            tx_frame_neg <= 1'b0;
            tx_data_pos <= tx_i_data;
            tx_data_neg <= tx_q_data;
        end else begin
            tx_frame_pos <= 1'b0;
            tx_frame_neg <= 1'b0;
            tx_data_pos <= 12'd0;
            tx_data_neg <= 12'd0;
        end
    end
    
    // Start reading when there's 256 words in the buffer (tx_start_allowed goes high),
    // but don't stop until the buffer is empty (tx_read_allowed goes low)
    reg tx_read_allowed_internal = 1'b0;
    
    always @(posedge l_clk) begin
        if(tx_start_allowed & ~dac_read_en) begin
            tx_read_allowed_internal <= 1'b1;
        end else if(dac_read_en) begin
            tx_read_allowed_internal <= 1'b1;
        end else begin
            tx_read_allowed_internal <= 1'b0;
        end
    end

    assign rx_enable = enable_datapath & rx_write_allowed;
    assign adc_write_en = rx_enable & rx_data_valid;
    
    assign dac_read_en = enable_datapath & tx_read_allowed & tx_read_allowed_internal;
    assign tx_enable = dac_read_en_d & dac_read_en;
    
endmodule