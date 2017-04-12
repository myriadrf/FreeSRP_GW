`timescale 1ns / 1ps

module gpif_tb();
    
    reg clk, reset_b;
    wire [31:0] fdata;
    wire [1:0] faddr;
    wire slrd_b, slwr_b, sloe_b, slcs_b;
    reg flaga_b = 1, flagb_b = 1, flagc_b = 1, flagd_b = 1;
    wire pktend_b;
    wire clk_out;
    
    // Reset and generate clock
    initial begin
        clk = 1'b0;
        reset_b = 1'b0;
        repeat(4) #10 clk = ~clk;
        reset_b = 1'b1;
        forever #10 clk = ~clk;
    end

    gpif_wrapper gpif(
        reset_b,
        clk,
        faddr,
        fdata,
        slrd_b,
        slwr_b,
        sloe_b,
        slcs_b,
        flaga_b,
        flagb_b,
        flagc_b,
        flagd_b,
        pktend_b,
        clk_out
    );
endmodule