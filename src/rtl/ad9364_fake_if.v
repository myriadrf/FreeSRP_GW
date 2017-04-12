module ad9364_fake_if(
    input clk_100,
    output l_clk,
    
    // receive data path interface
    output [23:0] adc_data,
    output adc_write_en,
    
    // transmit data path interface
    input [23:0] dac_data,
    output dac_read_en,
    
    // enable/disable transceiver interface
    input enable,
    
    // enable/disable reading from FIFOs
    input rx_write_allowed,
    input tx_read_allowed,
    
    // FDD RX/TX enable to transceiver
    output rx_enable,
    output tx_enable
);

wire clk_61;
wire clk_31;
wire clk_12;

ad9364_fake_clk clk_gen(
    .clk_in1(clk_100),
    .clk_56(clk_56),
    .clk_31(clk_31),
    .clk_12(clk_12)
);

assign l_clk = clk_56;
//assign l_clk = clk_31;

// Synchronize enable signal to l_clk
(* ASYNC_REG = "TRUE" *) reg enable_meta = 0, enable_sync = 0;
always @(posedge l_clk) begin
    enable_meta <= enable;
    enable_sync <= enable_meta;
end

// DDS for fake data (3MHz tone)
wire [31:0] dds_data;
wire [15:0] dds_sin;
wire [15:0] dds_cos;
assign dds_sin = dds_data[31:16];
assign dds_cos = dds_data[15:0];

dds_compiler_0 dds(
    .aclk(l_clk),
    .m_axis_data_tdata(dds_data)
);

// RX datapath

reg [23:0] adc_data_reg;
assign adc_data = adc_data_reg;

assign adc_write_en = enable_sync & rx_write_allowed;
assign rx_enable = adc_write_en;

wire [23:0] fake_data;
reg [12:0] fake_i_data;
reg [12:0] fake_q_data;
assign fake_data[23:12] = fake_i_data;
assign fake_data[11:0] = fake_q_data;

always @(posedge l_clk) begin
    if(adc_write_en) begin
        adc_data_reg <= fake_data;
    end
end

always @(posedge l_clk) begin
    if(adc_write_en) begin
        //fake_i_data <= fake_i_data + 1'b1;
        fake_i_data <= dds_cos;
        //fake_q_data <= fake_q_data - 1'b1;
        fake_q_data <= dds_sin;
    end else begin
        fake_i_data <= 12'd0;
        fake_q_data <= 12'd0;
    end
end

// TX datapath

assign dac_read_en = enable_sync & tx_read_allowed;
assign tx_enable = dac_read_en;

endmodule
