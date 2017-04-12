create_clock -period 10.000 -waveform {0.000 5.000} [get_ports EXT_CLK]
create_generated_clock -name GPIF_CLK -source [get_pins gpif_if/gpif_oddr/C] -divide_by 1 -invert -add -master_clock clk_out_gpif_gpif_clk_gen [get_ports GPIF_CLK]
#create_clock -period 16.667 -name GPIF_virtual

create_clock -period 16.276 -waveform {0.000 8.138} [get_ports XCVR_FB_CLK]
create_clock -period 16.276 -waveform {0.000 8.138} [get_ports XCVR_DATA_CLK]

set_clock_groups -asynchronous -group EXT_CLK -group {XCVR_DATA_CLK XCVR_FB_CLK clk_56_ad9364_fake_clk} -group GPIF_CLK

# GPIO and LEDs
set_false_path -from * -to [get_ports LED*]
set_false_path -from * -to [get_ports GPIO*]

# GPIF II
#74 MHz: create_clock -period 13.571 -name VIRTUAL_clk_out_gpif_gpif_clk_gen -waveform {0.000 6.786}
create_clock -period 12.5 -name VIRTUAL_clk_out_gpif_gpif_clk_gen -waveform {0.000 6.25}
#86 MHz: create_clock -period 11.6667 -name VIRTUAL_clk_out_gpif_gpif_clk_gen -waveform {0.000 5.8334}
set_input_delay -clock [get_clocks VIRTUAL_clk_out_gpif_gpif_clk_gen] -min -add_delay 0.21 [get_ports {GPIF_CTL[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out_gpif_gpif_clk_gen] -max -add_delay 8.34 [get_ports {GPIF_CTL[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out_gpif_gpif_clk_gen] -min -add_delay 2.21 [get_ports {GPIF_DQ[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out_gpif_gpif_clk_gen] -max -add_delay 9.34 [get_ports {GPIF_DQ[*]}]

#set_input_delay -clock [get_clocks GPIF_CLK] -clock_fall -min -add_delay 0.000 [get_ports {{GPIF_CTL[4]} {GPIF_CTL[5]} {GPIF_CTL[6]} {GPIF_CTL[8]}}]
#set_input_delay -clock [get_clocks GPIF_CLK] -clock_fall -max -add_delay 8.000 [get_ports {{GPIF_CTL[4]} {GPIF_CTL[5]} {GPIF_CTL[6]} {GPIF_CTL[8]}}]
#set_input_delay -clock [get_clocks GPIF_CLK] -clock_fall -min -add_delay 0.000 [get_ports {GPIF_DQ[*]}]
#set_input_delay -clock [get_clocks GPIF_CLK] -clock_fall -max -add_delay 8.000 [get_ports {GPIF_DQ[*]}]

set_multicycle_path -setup -from [get_ports {{GPIF_CTL[4]} {GPIF_CTL[5]} {GPIF_CTL[6]} {GPIF_CTL[8]}}] -to [get_clocks GPIF_CLK] 2

set_output_delay -clock [get_clocks GPIF_CLK] -min -add_delay -0.500 [get_ports {{GPIF_CTL[0]} {GPIF_CTL[1]} {GPIF_CTL[2]} {GPIF_CTL[3]} {GPIF_CTL[7]} {GPIF_CTL[11]} {GPIF_CTL[12]}}]
set_output_delay -clock [get_clocks GPIF_CLK] -max -add_delay 2.000 [get_ports {{GPIF_CTL[0]} {GPIF_CTL[1]} {GPIF_CTL[2]} {GPIF_CTL[3]} {GPIF_CTL[7]} {GPIF_CTL[11]} {GPIF_CTL[12]}}]
set_output_delay -clock [get_clocks GPIF_CLK] -min -add_delay -0.500 [get_ports {GPIF_DQ[*]}]
set_output_delay -clock [get_clocks GPIF_CLK] -max -add_delay 2.000 [get_ports {GPIF_DQ[*]}]

# AD9364 SPI
# TODO: This

#set_input_delay -clock XCVR_DATA_CLK -min 0 -max 1.5 [get_ports {XCVR_DATA_P0*}]
#set_input_delay -clock XCVR_DATA_CLK -min 0 -max 1.5 -clock_fall -add_delay [get_ports {XCVR_DATA_P0*}]

#set_input_delay -clock XCVR_DATA_CLK -min 0 -max 1 [get_ports XCVR_RX_FRAME]
#set_input_delay -clock XCVR_DATA_CLK -min 0 -max 1 -clock_fall -add_delay [get_ports XCVR_RX_FRAME]

#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 [get_ports {XCVR_DATA_P1*}]
#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 -clock_fall -add_delay [get_ports {XCVR_DATA_P1*}]

#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 [get_ports XCVR_ENABLE]
#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 -clock_fall -add_delay [get_ports XCVR_ENABLE]

#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 [get_ports XCVR_TXNRX]
#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 -clock_fall -add_delay [get_ports XCVR_TXNRX]

#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 [get_ports XCVR_TX_FRAME]
#set_output_delay -clock FB_DATA_CLK -min 1 -max 1 -clock_fall -add_delay [get_ports XCVR_ENABLE]