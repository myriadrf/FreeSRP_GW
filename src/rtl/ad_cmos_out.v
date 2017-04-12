`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2015 09:13:12 PM
// Design Name: 
// Module Name: ad_cmos_out
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ad_cmos_out(
        
        // DDR clock
        clk,
        
        // DDR data input
        data_posedge,
        data_negedge,
        
        // DDR output
        data_out
    );
    
    input   clk;
    
    input   data_posedge;
    input   data_negedge;
    
    output  data_out;
    
    ODDR #(
        .DDR_CLK_EDGE ("SAME_EDGE"),
        .INIT (1'b0),
        .SRTYPE ("ASYNC"))
    i_tx_data_oddr (
        .CE (1'b1),
        .R (1'b0),
        .S (1'b0),
        .C (clk),
        .D1 (data_posedge),
        .D2 (data_negedge),
        .Q (data_out));
endmodule
