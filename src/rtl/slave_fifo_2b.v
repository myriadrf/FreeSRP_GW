module slave_fifo_2b (
    input reset, // Active high reset input
    input clk, // Clock input
    // GPIF signals
    input [31:0] data_in,
    output [31:0] data_out,
    output [1:0] fifo_addr,
    input rx_buf_full,
    input rx_buf_partial,
    input tx_buf_empty,
    input tx_buf_partial,
    output slrd,
    output sloe,
    output slwr,
    output slcs,
    output pktend,
    // Data FIFO signals
    input [23:0] rx_data_in,  // RX data input from transceiver FIFO
    input rx_data_available,  // FIFO is not empty
    input rx_transfer_start_allowed, // May start writing RX data to FX3
    output rx_data_read_en,   // Enable reading from RX FIFO
    output [23:0] tx_data_out,// TX data output to transceiver FIFO
    input tx_write_allowed,   // FIFO is not full
    input tx_transfer_start_allowed, // May start reading TX data from FX3
    output tx_data_write_en,  // Enable writing to TX FIFO
    // Debug
    output [3:0] dbg_state
    );
    
    // State machine
    localparam STATE_idle = 4'd0,
               STATE_rx_wait_buf_ready = 4'd1,
               STATE_rx_write = 4'd2,
               STATE_rx_write_finish = 4'd3,
               STATE_tx_wait_buf_ready = 4'd4,
               STATE_tx_wait_data_ready = 4'd5,
               STATE_tx_read = 4'd6,
               STATE_tx_read_finish = 4'd7,
               STATE_tx_read_finish_delay = 4'd8;
    
    (* mark_debug = "true" *) reg [3:0] current_state = STATE_idle;
    (* mark_debug = "true" *) reg [3:0] next_state;
    
    assign dbg_state = current_state;
    
    // FIFO buffer rx read enable/tx write enable
    assign rx_data_read_en = ((current_state == STATE_rx_write) || (current_state == STATE_rx_write_finish)) && (rx_data_available === 1);
    assign tx_data_write_en = ((current_state == STATE_tx_read) || (current_state == STATE_tx_read_finish)) && (tx_write_allowed === 1);
    
    /*reg rx_data_read_en_d = 1'b0;
    always @(posedge clk) begin
        rx_data_read_en_d <= rx_data_read_en;
    end
    
    wire rx_data_read_valid;
    assign rx_data_read_valid = rx_data_read_en & rx_data_read_en_d;*/
    
    // RX data (FIFO --> GPIF)
    reg [31:0] rx_data_reg = 32'd0;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            rx_data_reg <= 32'd0;
        end else if(rx_data_read_en) begin
            rx_data_reg[27:16] <= rx_data_in[23:12];
            rx_data_reg[11:0] <= rx_data_in[11:0];
        end else begin
            rx_data_reg <= rx_data_reg;
        end
    end
    
    // TX data (GPIF --> FIFO)
    reg [23:0] tx_data_reg = 24'd0;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tx_data_reg <= 24'd0;
        end else if(tx_data_write_en) begin
            tx_data_reg[23:12] <= data_in[27:16];
            tx_data_reg[11:0] <= data_in[11:0];
        end
    end
    
    // FX3 buffer address and data assignments based on state
    assign fifo_addr = ((current_state == STATE_tx_wait_buf_ready) ||
                        (current_state == STATE_tx_wait_data_ready) ||
                        (current_state == STATE_tx_read_finish) ||
                        (current_state == STATE_tx_read_finish_delay) ||
                        (current_state == STATE_tx_read)) ? 2'd3 : 2'd0;
                        
    assign data_out = ((current_state == STATE_rx_write) || (current_state == STATE_rx_write_finish)) ? rx_data_reg : 32'd0;
    assign tx_data_out = tx_data_reg;
    
    // Misc. signal assignments based on state
    assign slcs = 1; 
    assign pktend = ((current_state == STATE_rx_write) && (rx_data_available === 0));
    assign slwr = (current_state == STATE_rx_write) && (rx_data_available === 1);
    assign slrd = (/*(current_state == STATE_tx_wait_buf_ready) || */(current_state == STATE_tx_wait_data_ready) || (current_state == STATE_tx_read)/* || (current_state == STATE_tx_read_finish) || (current_state == STATE_tx_read_finish_delay)*/) && (tx_write_allowed === 1);
    assign sloe = ((current_state == STATE_tx_wait_buf_ready) || (current_state == STATE_tx_wait_data_ready) || (current_state == STATE_tx_read) || (current_state == STATE_tx_read_finish)/* || (current_state == STATE_tx_read_finish_delay)*/) && (tx_write_allowed === 1);
    
    reg rx_buf_partial_d = 0; // Delay partial flag by 1 clock cycle
    reg tx_buf_partial_d = 0;
    reg tx_buf_partial_d2 = 0;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            rx_buf_partial_d <= 0;
            tx_buf_partial_d <= 0;
            tx_buf_partial_d2 <= 0;
        end else begin
            rx_buf_partial_d <= rx_buf_partial;
            tx_buf_partial_d <= tx_buf_partial;
            tx_buf_partial_d2 <= tx_buf_partial_d;
        end
    end
    
    reg [4:0] tx_finish_delay_cnt = 0; // Delay on tx read finish
    always @(posedge clk) begin
        if((current_state == STATE_tx_read_finish_delay) || (current_state == STATE_tx_read_finish)) begin
            tx_finish_delay_cnt <= tx_finish_delay_cnt + 1'b1;
        end else begin
            tx_finish_delay_cnt <= 5'd0;
        end
    end
    
    reg [3:0] tx_wait_data_cnt = 0;
    always @(posedge clk) begin
        if(current_state == STATE_tx_wait_data_ready) begin
            tx_wait_data_cnt <= tx_wait_data_cnt + 1'b1;
        end else begin
            tx_wait_data_cnt <= 4'd0;
        end
    end
    
    reg [7:0] tx_read_cnt = 0;
    always @(posedge clk) begin
        if(current_state == STATE_tx_read) begin
            tx_read_cnt <= tx_read_cnt + 1'b1;
        end else begin
            tx_read_cnt <= 8'd0;
        end
    end
    
    (* mark_debug = "true" *) reg [11:0] read_op_count = 12'd0;
    //wire do_tx;
    //assign do_tx = read_op_count <= 12'd512;
    always @(posedge clk) begin
        if(current_state == STATE_tx_wait_buf_ready) begin
            read_op_count <= read_op_count + 1'b1;
        end else begin
            read_op_count <= read_op_count;
        end
    end
    
    //reg [11:0] read_length_cnt = 12'd0;
    
    
    // State machine combinational logic for state transitions
    always @(*) begin
        next_state = current_state;
        case(current_state)
            STATE_idle: begin
                // Transition to the rx_wait_buf_ready state if the FX3 rx buffer is not full
                // Transition to the tx_wait_buf_ready state if the FX3 tx buffer is not empty 
                if(!rx_buf_full & rx_data_available & rx_transfer_start_allowed) begin
                    next_state = STATE_rx_wait_buf_ready;
                end else if(/*!tx_buf_partial & */!tx_buf_empty & tx_write_allowed & tx_transfer_start_allowed/* & do_tx*/) begin
                    next_state = STATE_tx_wait_buf_ready;
                end
            end
            STATE_rx_wait_buf_ready: begin
                // Transistion to the write state if the FX3 rx buffer partial flag is not asserted
                if(!rx_buf_partial) next_state = STATE_rx_write;
            end
            STATE_rx_write: begin
                // Finish the write when the FX3 rx buffer fills up or there is no more data to be sent 
                //if(rx_buf_partial_d | pktend) next_state = STATE_rx_write_finish;
                if(rx_buf_partial | pktend) next_state = STATE_idle;
            end
            STATE_rx_write_finish: begin
                next_state = STATE_idle;
            end
            STATE_tx_wait_buf_ready: begin
                // Transition to the read state if the FX3 tx buffer partial flag is not asserted
                if(/*!tx_buf_partial_d*/1) next_state = STATE_tx_wait_data_ready;
            end
            STATE_tx_wait_data_ready: begin
                // Wait until data from FX3 is ready (compensate for flag latencies)
                if(tx_wait_data_cnt == 4'd2) next_state = STATE_tx_read;
            end
            STATE_tx_read: begin
                //if(tx_buf_partial_d) next_state = STATE_tx_read_finish;
                if(tx_buf_partial_d2) next_state = STATE_tx_read_finish;
                //if(tx_read_cnt == 8'd255) next_state = STATE_tx_read_finish;
                //if(tx_buf_partial) next_state = STATE_tx_read_finish_delay;
                //if(tx_buf_partial) next_state = STATE_idle;
            end
            STATE_tx_read_finish: begin
                //if(tx_finish_delay_cnt == 5'd5) next_state = STATE_tx_read_finish_delay;
                if(tx_finish_delay_cnt == 5'd2) next_state = STATE_tx_read_finish_delay;
            end
            STATE_tx_read_finish_delay: begin
                if(tx_finish_delay_cnt == 5'd4) next_state = STATE_idle;
            end
        endcase
    end
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            current_state <= STATE_idle;
        end else begin
            current_state <= next_state;
        end
    end
    
    /////////
    // ILA //
    /////////
    /*
    ila_0 ila_inst(
        .clk(clk),
        .probe0(data_in),
        .probe1(fifo_addr),
        .probe2(rx_buf_full),
        .probe3(rx_buf_partial),
        .probe4(tx_buf_empty),
        .probe5(tx_buf_partial),
        .probe6(slrd),
        .probe7(slwr),
        .probe8(sloe),
        .probe9(current_state),
        .probe10(pktend),
        .probe11(tx_write_allowed),
        .probe12(rx_data_available),
        .probe13(rx_data_read_en),
        .probe14(tx_data_write_en)
    );*/
    
endmodule