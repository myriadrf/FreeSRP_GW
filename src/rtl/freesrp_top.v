module freesrp_top(
    // Clock & reset signals
    input          EXT_CLK, // 100 MHz clock input
    input          RESET, // Active low reset
	
    // Misc. GPIO
    inout   [7:0]  GPIO,
    output  [3:0]  LED,
    
    // FX3 signals
    output         FX3_RX,
    input          FX3_TX,
    output         GPIF_CLK,
    inout   [31:0] GPIF_DQ,
    inout   [12:0] GPIF_CTL,
    
    // AD9364 signals
    output         XCVR_SPI_ENB,
    output         XCVR_SCLK,
    output         XCVR_MOSI,
    input          XCVR_MISO,
    input          XCVR_CLK_OUT,
    input          XCVR_DATA_CLK,
    output         XCVR_FB_CLK,
    output         XCVR_RESET,
    input          XCVR_RX_FRAME,
    output         XCVR_TX_FRAME,
    output         XCVR_ENABLE,
    output         XCVR_TXNRX,
    output         XCVR_SYNC_IN,
    input   [11:0] XCVR_DATA_P0,
    output  [11:0] XCVR_DATA_P1,
    output         RX_BAND_A,
    output         RX_BAND_B,
    output         RX_BAND_C,
    output         TX_BAND_A,
    output         TX_BAND_B
);
    
    
    // Microblaze Clock
    wire clk_100;
    BUFG ext_clk(
        .I(EXT_CLK),
        .O(clk_100)
    );
    
    // GPIF clock
    wire gpif_clk;
    gpif_clk_gen gpif_clk_gen_inst(
        .clk_in1(clk_100),
        .clk_out_gpif(gpif_clk)
    );
    
    
    
    //////////////////////////
    // Microblaze Processor //
    //////////////////////////
    
    wire [31:0] mb_gpio0_out;
    wire [31:0] mb_gpio1_out;
    
    wire xcvr_spi_ss;
    wire xcvr_spi_sck;
    wire xcvr_spi_mosi;
    wire xcvr_spi_miso;
    
    wire xcvr_reset;
    
    wire driver_ready;
    wire driver_error;
    wire datapath_enable;
    wire datapath_flush;
    wire datapath_reset;
    
    assign XCVR_RESET = mb_gpio0_out[14];
    
    assign driver_ready = mb_gpio1_out[0];
    assign driver_error = mb_gpio1_out[4];
    assign datapath_enable = mb_gpio1_out[1];
    assign datapath_flush = mb_gpio1_out[2];
    assign datapath_reset = mb_gpio1_out[3];
    
    assign BANDSEL_RX_A = mb_gpio1_out[5];
    assign BANDSEL_RX_B = mb_gpio1_out[6];
    assign BANDSEL_RX_C = mb_gpio1_out[7];
    assign BANDSEL_TX_A = mb_gpio1_out[8];
    assign BANDSEL_TX_B = mb_gpio1_out[9];
    
    
    assign GPIO[0] = XCVR_CLK_OUT;
    assign LED[3] = datapath_enable;
    
    mb_subsystem mb(
        .Clk(clk_100),
        .reset_rtl(RESET),
        .usb_uart_rxd(FX3_TX),
        .usb_uart_txd(FX3_RX),
        .debug_uart_rxd(GPIO[6]),
        .debug_uart_txd(GPIO[7]),
        .xcvr_spi_ss_o(XCVR_SPI_ENB),
        .xcvr_spi_sck_o(XCVR_SCLK),
        .xcvr_spi_io0_o(XCVR_MOSI),
        .xcvr_spi_io1_i(XCVR_MISO),
        .gpio_0_tri_o(mb_gpio0_out),
        .gpio_1_tri_o(mb_gpio1_out)
    );
    
    
    /////////////////////
    // RX and TX FIFOs //
    /////////////////////
    
    wire xcvr_clk; // Wordclock from AD9364
    
    wire rx_fifo_read_empty;         // Data to be transmitted over GPIF is available
    wire [23:0] rx_fifo_read_data;   // Data to be sent via GPIF (24bit for 2*12bit for I and Q)
    wire rx_fifo_read_en;            // Enable reading from FIFO
    
    wire rx_fifo_write_full;         // FIFO is full and cannot accept data from transceiver
    wire [23:0] rx_fifo_write_data;  // Data from transceiver, to be stored in FIFO (24bit for 2*12bit for I and Q)
    wire rx_fifo_write_en;           // Enable writing to FIFO
    
    
    wire tx_fifo_read_empty;         // Data for transceiver is not available
    wire [23:0] tx_fifo_read_data;   // Data to be transmitted with the tranciver (24bit for 2*12bit for I and Q)
    wire tx_fifo_read_en;            // Enable reading from FIFO
    
    (* mark_debug = "true" *)        // Mark signal to be watched by debugger
    wire tx_fifo_write_full;         // Data from GPIF cannot be accepted, FIFO is full
    wire [23:0] tx_fifo_write_data;  // Data from GPIF
    (* mark_debug = "true" *)
    wire tx_fifo_write_en;           // Enable writing to FIFO
    
    
    wire [11:0] rx_fifo_rd_count;    // The amount of Words stored (and can be read) in the rx fifo
    wire [11:0] rx_fifo_wr_count;    // The amount of free Words (and can be written) in the rx fifo
    wire [11:0] tx_fifo_rd_count;    // The amount of Words stored (and can be read) in the rx fifo
    wire [11:0] tx_fifo_wr_count;    // The amount of free Words (and can be written) in the rx fifo

    fifo_subsystem fifos(
        .RX_FIFO_READ_empty(rx_fifo_read_empty),
        .RX_FIFO_READ_rd_data(rx_fifo_read_data),
        .RX_FIFO_READ_rd_en(rx_fifo_read_en),
        .RX_FIFO_WRITE_full(rx_fifo_write_full),
        .RX_FIFO_WRITE_wr_data(rx_fifo_write_data),
        .RX_FIFO_WRITE_wr_en(rx_fifo_write_en),
        .TX_FIFO_READ_empty(tx_fifo_read_empty),
        .TX_FIFO_READ_rd_data(tx_fifo_read_data),
        .TX_FIFO_READ_rd_en(tx_fifo_read_en),
        //.TX_FIFO_READ_rd_en(0),
        .TX_FIFO_WRITE_full(tx_fifo_write_full),
        .TX_FIFO_WRITE_wr_data(tx_fifo_write_data),
        .TX_FIFO_WRITE_wr_en(tx_fifo_write_en),
        .fifo_rst((!RESET)/* | datapath_reset*/),
        .gpif_data_clk(gpif_clk),
        .xcvr_data_clk(xcvr_clk),
        .rx_rd_count(rx_fifo_rd_count),
        .rx_wr_count(rx_fifo_wr_count),
        .tx_rd_count(tx_fifo_rd_count),
        .tx_wr_count(tx_fifo_wr_count)
    );
    
    
    //////////////////////
    // AD9364 Interface //
    //////////////////////
    
    (* mark_debug = "true" *) 
    wire xcvr_rx_enable;
    (* mark_debug = "true" *) 
    wire xcvr_tx_enable;
    
    assign XCVR_ENABLE = xcvr_rx_enable;
    assign XCVR_TXNRX = xcvr_tx_enable;
    assign XCVR_SYNC_IN = 0;
    
    assign LED[0] = xcvr_rx_enable;
    assign LED[1] = xcvr_tx_enable;
    
    wire xcvr_fb_clk;
    assign XCVR_FB_CLK = xcvr_fb_clk;
    
    assign GPIO[1] = xcvr_clk;
    assign GPIO[2] = XCVR_RX_FRAME;
    assign GPIO[3] = XCVR_DATA_P0[3];
    assign GPIO[4] = XCVR_DATA_P0[8];
    assign GPIO[5] = XCVR_DATA_P0[11];
    
    wire tx_fifo_enough_data;
    assign tx_fifo_enough_data = tx_fifo_rd_count > 12'd256;
    
    // AD9364 physical interface
    ad9364_dev_if ad9364_if(
      .l_clk(xcvr_clk),
      .rx_enable(xcvr_rx_enable),
      .tx_enable(xcvr_tx_enable),
      .rx_clk_in(XCVR_DATA_CLK),
      .rx_frame_in(XCVR_RX_FRAME),
      .rx_data_in(XCVR_DATA_P0),
      .tx_clk_out(xcvr_fb_clk),
      .tx_frame_out(XCVR_TX_FRAME),
      .tx_data_out(XCVR_DATA_P1),
      // Data in/out
      .adc_write_en(rx_fifo_write_en),
      .adc_data(rx_fifo_write_data),
      .dac_read_en(tx_fifo_read_en),
      .dac_data(tx_fifo_read_data),
      // Enable datapath
      .enable_datapath(datapath_enable),
      // RX/TX enable
      .rx_write_allowed(!rx_fifo_write_full),
      .tx_read_allowed(!tx_fifo_read_empty),
      .tx_start_allowed(tx_fifo_enough_data)
    );
    
    
    ////////////////////////////
    // GPIF II FIFO interface //
    ////////////////////////////
    
    wire [1:0] faddr;
    assign GPIF_CTL[12] = faddr[0];
    assign GPIF_CTL[11] = faddr[1];
    
    wire rx_fifo_enough_data; // Used to inform the GPIF master state machine that there is enough data to fill the FX3's buffer (no short packets)
    assign rx_fifo_enough_data = rx_fifo_rd_count > 12'd256;
    
    (* mark_debug = "true" *)
    wire tx_fifo_enough_space;
    assign tx_fifo_enough_space = tx_fifo_wr_count < 12'd3840;
    
    wire [3:0] gpif_dbg_state; // > /dev/null
    
    gpif_wrapper gpif_if(
        .reset_b(RESET),
        .clk(gpif_clk),
        .faddr(faddr),
        .fdata(GPIF_DQ),
        .slrd_b(GPIF_CTL[3]),
        .slwr_b(GPIF_CTL[1]),
        .sloe_b(GPIF_CTL[2]),
        .slcs_b(GPIF_CTL[0]),
        .flaga_b(GPIF_CTL[4]),
        .flagb_b(GPIF_CTL[5]),
        .flagc_b(GPIF_CTL[6]),
        .flagd_b(GPIF_CTL[8]),
        .pktend_b(GPIF_CTL[7]),
        .clk_out(GPIF_CLK),
        .rx_data_in(rx_fifo_read_data),
        .rx_data_available(!rx_fifo_read_empty),
        .rx_transfer_start_allowed(rx_fifo_enough_data),
        .rx_data_read_en(rx_fifo_read_en),
        .tx_data_out(tx_fifo_write_data),
        .tx_write_allowed(!tx_fifo_write_full),
        .tx_transfer_start_allowed(tx_fifo_enough_space),
        .tx_data_write_en(tx_fifo_write_en),
        .dbg_state(gpif_dbg_state) // Debug
    );
endmodule
