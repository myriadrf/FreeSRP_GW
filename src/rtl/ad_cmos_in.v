`timescale 1ns / 1ps

module ad_cmos_in(
    // DDR clock
    clk,

    // DDR data input
    data_in,
    
    // Outputs (see UG471, page 109 - Input DDR)
    data_posedge,
    data_negedge
    
    );
    
    input   clk;
    
    input   data_in;
    
    output  data_posedge;
    output  data_negedge;
    
    IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),
        .INIT_Q1 (1'b0),
        .INIT_Q2 (1'b0),
        .SRTYPE ("ASYNC"))
    i_rx_data_iddr (
        .CE (1'b1),
        .R (1'b0),
        .S (1'b0),
        .C (clk),
        .D (data_in),
        .Q1 (data_posedge),
        .Q2 (data_negedge));
endmodule
