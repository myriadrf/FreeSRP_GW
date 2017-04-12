module gpif_wrapper(
	input reset_b,            // Active low reset input
	input clk,                // Clock input
	// GPIF signals
	output [1:0] faddr,  
	inout [31:0] fdata,
	output slrd_b,                 
	output slwr_b,
	output sloe_b,
	output slcs_b,                 
	input flaga_b,
	input flagb_b,
	input flagc_b,
	input flagd_b,
	output pktend_b,          // output pkt end
	output clk_out,           // output clk 100 Mhz and 180 phase shift
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

(* mark_debug = "true" *) reg [31:0] fdata_d;

wire [31:0] data_out;
//reg [31:0] data_out_d;
(* mark_debug = "true" *) wire [1:0] fifo_address;   
(* mark_debug = "true" *) reg [1:0] fifo_address_d;   
(* mark_debug = "true" *) wire slrd;
(* mark_debug = "true" *) wire slcs;
(* mark_debug = "true" *) wire slwr;
(* mark_debug = "true" *) wire sloe;
reg slrd_d;
reg slcs_d;       
reg slwr_d;
reg sloe_d;
wire flaga;
wire flagb;
wire flagc;
wire flagd;
(* mark_debug = "true" *) reg flaga_d;
(* mark_debug = "true" *) reg flagb_d;
(* mark_debug = "true" *) reg flagc_d;
(* mark_debug = "true" *) reg flagd_d;
(* mark_debug = "true" *) wire pktend;
//reg pktend_d;

wire reset;

// output signal assignment
//TODO:figure this out: assign faddr = fifo_address_d;
assign faddr = fifo_address;
//assign fdata = (slwr_d) ? data_out_d : 32'dz;	
//TODO:figure this out: assign fdata = (slwr_d) ? data_out : 32'dz;
assign fdata = (slwr) ? data_out : 32'dz;

//TODO:figure this out: assign slrd_b = ~slrd_d;
assign slwr_b = ~slwr_d;
//TODO:figure this out: assign sloe_b = ~sloe_d;
assign slcs_b = ~slcs_d;
assign sloe_b = ~sloe;
assign slrd_b = ~slrd;

assign flaga = ~flaga_b;
assign flagb = ~flagb_b;
assign flagc = ~flagc_b;
assign flagd = ~flagd_b;
//assign pktend_b = ~pktend_d;
assign pktend_b = ~pktend;

assign reset = ~reset_b;

// GPIF clock (180 deg phase shifted clk)
ODDR gpif_oddr(
    .D1(1'b0),
    .D2(1'b1),
    .C(clk),
    .Q(clk_out),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0)
);

slave_fifo_2b gpif_if(
    .reset(reset),
    .clk(clk),
    // GPIF signals
    .data_in(fdata_d),
    .data_out(data_out),
    .fifo_addr(fifo_address),
    .rx_buf_full(flaga_d),
    .rx_buf_partial(flagb_d),
    .tx_buf_empty(flagc_d),
    .tx_buf_partial(flagd_d),
    .slrd(slrd),
    .sloe(sloe),
    .slwr(slwr),
    .slcs(slcs),
    .pktend(pktend),
    // Data FIFO signals
    .rx_data_in(rx_data_in),
    .rx_data_available(rx_data_available),
    .rx_transfer_start_allowed(rx_transfer_start_allowed), 
    .rx_data_read_en(rx_data_read_en),
    .tx_data_out(tx_data_out),
    .tx_write_allowed(tx_write_allowed),
    .tx_transfer_start_allowed(tx_transfer_start_allowed),
    .tx_data_write_en(tx_data_write_en),
    // Debug
    .dbg_state(dbg_state)
);

always @(posedge clk, posedge reset) begin
	if(reset) begin 
		flaga_d <= 1'd1;
		flagb_d <= 1'd1;
		flagc_d <= 1'd1;
		flagd_d <= 1'd1;
		
		fdata_d <= 32'd0;		
		fifo_address_d <= 2'd0;
		
		slrd_d <= 1'b0;
		sloe_d <= 1'b0;
		slwr_d <= 1'b0;
		slcs_d <= 1'b0;
		//pktend_d <= 1'b0;
	end else begin
		flaga_d <= flaga;
		flagb_d <= flagb;
		flagc_d <= flagc;
		flagd_d <= flagd;
		
		fdata_d <= fdata;
		fifo_address_d <= fifo_address;
		//data_out_d <= data_out;
		
		slrd_d <= slrd;
		sloe_d <= sloe;
		slwr_d <= slwr;
		slcs_d <= slcs;
		//pktend_d <= pktend;
	end	
end
   
endmodule