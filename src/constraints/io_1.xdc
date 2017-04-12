####################################
##   FreeSRP by Lukas Lao Beyer   ##
##   http://electronics.kitchen   ##
##                                ##
##      Hardware constraints      ##
##   ----- FreeSRP Alpha -----    ##
####################################

## Misc config
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

## Reset button
set_property PACKAGE_PIN K13 [get_ports RESET]
set_property IOSTANDARD LVCMOS18 [get_ports RESET]

## Global clock (100 MHz)
set_property PACKAGE_PIN N14 [get_ports EXT_CLK]
set_property IOSTANDARD LVCMOS18 [get_ports EXT_CLK]

## Misc FX3 signals
set_property PACKAGE_PIN J14 [get_ports FX3_RX]
set_property PACKAGE_PIN J13 [get_ports FX3_TX]
set_property IOSTANDARD LVCMOS18 [get_ports {FX3_*}]

## GPIF
#### GPIF CLK
set_property PACKAGE_PIN C13 [get_ports GPIF_CLK]
set_property IOSTANDARD LVCMOS18 [get_ports GPIF_CLK]
#### GPIF INT
#set_property PACKAGE_PIN B15 [get_ports GPIF_INT]
#set_property IOSTANDARD LVCMOS18 [get_ports GPIF_INT]

#### GPIF CTL
set_property PACKAGE_PIN D15 [get_ports {GPIF_CTL[0]}]
set_property PACKAGE_PIN B16 [get_ports {GPIF_CTL[1]}]
set_property PACKAGE_PIN F14 [get_ports {GPIF_CTL[2]}]
set_property PACKAGE_PIN F15 [get_ports {GPIF_CTL[3]}]
set_property PACKAGE_PIN F12 [get_ports {GPIF_CTL[4]}]
set_property PACKAGE_PIN E11 [get_ports {GPIF_CTL[5]}]
set_property PACKAGE_PIN A15 [get_ports {GPIF_CTL[6]}]
set_property PACKAGE_PIN F13 [get_ports {GPIF_CTL[7]}]
set_property PACKAGE_PIN D13 [get_ports {GPIF_CTL[8]}]
set_property PACKAGE_PIN E13 [get_ports {GPIF_CTL[9]}]
set_property PACKAGE_PIN A14 [get_ports {GPIF_CTL[10]}]
set_property PACKAGE_PIN C14 [get_ports {GPIF_CTL[11]}]
set_property PACKAGE_PIN D14 [get_ports {GPIF_CTL[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {GPIF_CTL*}]

#### Pull down FX3 flags
set_property PULLDOWN TRUE [get_ports GPIF_CTL[4]]
set_property PULLDOWN TRUE [get_ports GPIF_CTL[5]]
set_property PULLDOWN TRUE [get_ports GPIF_CTL[6]]
set_property PULLDOWN TRUE [get_ports GPIF_CTL[8]]

#### GPIF DQ
set_property PACKAGE_PIN J15 [get_ports {GPIF_DQ[0]}]
set_property PACKAGE_PIN H11 [get_ports {GPIF_DQ[1]}]
set_property PACKAGE_PIN E12 [get_ports {GPIF_DQ[2]}]
set_property PACKAGE_PIN G11 [get_ports {GPIF_DQ[3]}]
set_property PACKAGE_PIN H12 [get_ports {GPIF_DQ[4]}]
set_property PACKAGE_PIN G12 [get_ports {GPIF_DQ[5]}]
set_property PACKAGE_PIN J16 [get_ports {GPIF_DQ[6]}]
set_property PACKAGE_PIN H14 [get_ports {GPIF_DQ[7]}]
set_property PACKAGE_PIN G15 [get_ports {GPIF_DQ[8]}]
set_property PACKAGE_PIN H13 [get_ports {GPIF_DQ[9]}]
set_property PACKAGE_PIN G16 [get_ports {GPIF_DQ[10]}]
set_property PACKAGE_PIN D16 [get_ports {GPIF_DQ[11]}]
set_property PACKAGE_PIN E16 [get_ports {GPIF_DQ[12]}]
set_property PACKAGE_PIN E15 [get_ports {GPIF_DQ[13]}]
set_property PACKAGE_PIN G14 [get_ports {GPIF_DQ[14]}]
set_property PACKAGE_PIN H16 [get_ports {GPIF_DQ[15]}]
set_property PACKAGE_PIN A13 [get_ports {GPIF_DQ[16]}]
set_property PACKAGE_PIN C11 [get_ports {GPIF_DQ[17]}]
set_property PACKAGE_PIN B12 [get_ports {GPIF_DQ[18]}]
set_property PACKAGE_PIN A12 [get_ports {GPIF_DQ[19]}]
set_property PACKAGE_PIN C12 [get_ports {GPIF_DQ[20]}]
set_property PACKAGE_PIN B11 [get_ports {GPIF_DQ[21]}]
set_property PACKAGE_PIN A10 [get_ports {GPIF_DQ[22]}]
set_property PACKAGE_PIN B15 [get_ports {GPIF_DQ[23]}]
set_property PACKAGE_PIN D9  [get_ports {GPIF_DQ[24]}]
set_property PACKAGE_PIN B14 [get_ports {GPIF_DQ[25]}]
set_property PACKAGE_PIN B9  [get_ports {GPIF_DQ[26]}]
set_property PACKAGE_PIN D8  [get_ports {GPIF_DQ[27]}]
set_property PACKAGE_PIN D11 [get_ports {GPIF_DQ[28]}]
set_property PACKAGE_PIN B10 [get_ports {GPIF_DQ[29]}]
set_property PACKAGE_PIN A9  [get_ports {GPIF_DQ[30]}]
set_property PACKAGE_PIN A8  [get_ports {GPIF_DQ[31]}]
set_property IOSTANDARD LVCMOS18 [get_ports {GPIF_DQ*}]

## AD9364 transceiver interface
##### XCVR_CTRL_IN
#set_property PACKAGE_PIN F3 [get_ports {XCVR_CTRL_IN[0]}]
#set_property PACKAGE_PIN E1 [get_ports {XCVR_CTRL_IN[1]}]
#set_property PACKAGE_PIN E3 [get_ports {XCVR_CTRL_IN[2]}]
#set_property PACKAGE_PIN D1 [get_ports {XCVR_CTRL_IN[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {XCVR_CTRL_IN*}]

##### XCVR_CTRL_OUT
#set_property PACKAGE_PIN G5 [get_ports {XCVR_CTRL_OUT[0]}]
#set_property PACKAGE_PIN C2 [get_ports {XCVR_CTRL_OUT[1]}]
#set_property PACKAGE_PIN D3 [get_ports {XCVR_CTRL_OUT[2]}]
#set_property PACKAGE_PIN C1 [get_ports {XCVR_CTRL_OUT[3]}]
#set_property PACKAGE_PIN B1 [get_ports {XCVR_CTRL_OUT[4]}]
#set_property PACKAGE_PIN F4 [get_ports {XCVR_CTRL_OUT[5]}]
#set_property PACKAGE_PIN H5 [get_ports {XCVR_CTRL_OUT[6]}]
#set_property PACKAGE_PIN C3 [get_ports {XCVR_CTRL_OUT[7]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {XCVR_CTRL_OUT*}]

#### XCVR_DATA_P0
set_property PACKAGE_PIN N4 [get_ports {XCVR_DATA_P0[0]}]
set_property PACKAGE_PIN J1 [get_ports {XCVR_DATA_P0[1]}]
set_property PACKAGE_PIN M2 [get_ports {XCVR_DATA_P0[2]}]
set_property PACKAGE_PIN H3 [get_ports {XCVR_DATA_P0[3]}]
set_property PACKAGE_PIN L3 [get_ports {XCVR_DATA_P0[4]}]
set_property PACKAGE_PIN H1 [get_ports {XCVR_DATA_P0[5]}]
set_property PACKAGE_PIN K2 [get_ports {XCVR_DATA_P0[6]}]
set_property PACKAGE_PIN G1 [get_ports {XCVR_DATA_P0[7]}]
set_property PACKAGE_PIN H2 [get_ports {XCVR_DATA_P0[8]}]
set_property PACKAGE_PIN J4 [get_ports {XCVR_DATA_P0[9]}]
set_property PACKAGE_PIN L2 [get_ports {XCVR_DATA_P0[10]}]
set_property PACKAGE_PIN G2 [get_ports {XCVR_DATA_P0[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XCVR_DATA_P0*}]

#### XCVR_DATA_P1
set_property PACKAGE_PIN N1 [get_ports {XCVR_DATA_P1[0]}]
set_property PACKAGE_PIN P3 [get_ports {XCVR_DATA_P1[1]}]
set_property PACKAGE_PIN N2 [get_ports {XCVR_DATA_P1[2]}]
set_property PACKAGE_PIN P4 [get_ports {XCVR_DATA_P1[3]}]
set_property PACKAGE_PIN R2 [get_ports {XCVR_DATA_P1[4]}]
set_property PACKAGE_PIN P5 [get_ports {XCVR_DATA_P1[5]}]
set_property PACKAGE_PIN E5 [get_ports {XCVR_DATA_P1[6]}]
set_property PACKAGE_PIN M5 [get_ports {XCVR_DATA_P1[7]}]
set_property PACKAGE_PIN H4 [get_ports {XCVR_DATA_P1[8]}]
set_property PACKAGE_PIN J3 [get_ports {XCVR_DATA_P1[9]}]
set_property PACKAGE_PIN J5 [get_ports {XCVR_DATA_P1[10]}]
set_property PACKAGE_PIN M1 [get_ports {XCVR_DATA_P1[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {XCVR_DATA_P1*}]

#### Misc transceiver control signals
##### SPI
set_property PACKAGE_PIN B4 [get_ports XCVR_SCLK]
set_property PACKAGE_PIN D5 [get_ports XCVR_MISO]
set_property PACKAGE_PIN A3 [get_ports XCVR_MOSI]
set_property PACKAGE_PIN A4 [get_ports XCVR_SPI_ENB]

##### Signal path selection
set_property PACKAGE_PIN R5 [get_ports RX_BAND_A]
set_property PACKAGE_PIN R3 [get_ports RX_BAND_B]
set_property PACKAGE_PIN T2 [get_ports RX_BAND_C]
set_property IOSTANDARD LVCMOS18 [get_ports {RX_BAND_*}]

set_property PACKAGE_PIN N3 [get_ports TX_BAND_A]
set_property PACKAGE_PIN T5 [get_ports TX_BAND_B]
set_property IOSTANDARD LVCMOS18 [get_ports {TX_BAND_*}]

##### Misc
set_property PACKAGE_PIN K3 [get_ports XCVR_RESET]

#set_property PACKAGE_PIN B2 [get_ports XCVR_EN_AGC]
set_property PACKAGE_PIN A2 [get_ports XCVR_SYNC_IN]

set_property PACKAGE_PIN K1 [get_ports XCVR_FB_CLK]
set_property PACKAGE_PIN F5 [get_ports XCVR_DATA_CLK]
set_property PACKAGE_PIN D4 [get_ports XCVR_CLK_OUT]

set_property PACKAGE_PIN K5 [get_ports XCVR_RX_FRAME]
set_property PACKAGE_PIN L4 [get_ports XCVR_TX_FRAME]

set_property PACKAGE_PIN G4 [get_ports XCVR_ENABLE]
set_property PACKAGE_PIN C4 [get_ports XCVR_TXNRX]

set_property IOSTANDARD LVCMOS18 [get_ports {XCVR_*}]

## LEDs
set_property PACKAGE_PIN P16 [get_ports {LED[0]}]
set_property PACKAGE_PIN N16 [get_ports {LED[1]}]
set_property PACKAGE_PIN M15 [get_ports {LED[2]}]
set_property PACKAGE_PIN M16 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED*}]

#### P10 connector (top row from left to right)
set_property PACKAGE_PIN C6 [get_ports {GPIO[0]}]
set_property PACKAGE_PIN D6 [get_ports {GPIO[1]}]
set_property PACKAGE_PIN B6 [get_ports {GPIO[2]}]
set_property PACKAGE_PIN A7 [get_ports {GPIO[3]}]
set_property PACKAGE_PIN B7 [get_ports {GPIO[4]}]
set_property PACKAGE_PIN E2 [get_ports {GPIO[5]}]
set_property PACKAGE_PIN B5 [get_ports {GPIO[6]}]
set_property PACKAGE_PIN A5 [get_ports {GPIO[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports GPIO*]

#### P7 expansion connector

##### Top row from left to right
set_property PACKAGE_PIN P15 [get_ports {EXPANSION[0]}]
set_property PACKAGE_PIN K12 [get_ports {EXPANSION[1]}]
set_property PACKAGE_PIN L14 [get_ports {EXPANSION[2]}]
set_property PACKAGE_PIN L13 [get_ports {EXPANSION[3]}]
set_property PACKAGE_PIN M14 [get_ports {EXPANSION[4]}]
set_property PACKAGE_PIN M12 [get_ports {EXPANSION[5]}]
set_property PACKAGE_PIN P14 [get_ports {EXPANSION[6]}]
set_property PACKAGE_PIN N13 [get_ports {EXPANSION[7]}]
set_property PACKAGE_PIN P13 [get_ports {EXPANSION[8]}]
set_property PACKAGE_PIN N12 [get_ports {EXPANSION[9]}]
set_property PACKAGE_PIN N11 [get_ports {EXPANSION[10]}]
set_property PACKAGE_PIN L5  [get_ports {EXPANSION[11]}]
set_property PACKAGE_PIN P11 [get_ports {EXPANSION[12]}]
set_property PACKAGE_PIN P10 [get_ports {EXPANSION[13]}]
set_property PACKAGE_PIN P9  [get_ports {EXPANSION[14]}]
set_property PACKAGE_PIN P8  [get_ports {EXPANSION[15]}]
set_property PACKAGE_PIN R6  [get_ports {EXPANSION[16]}]
set_property PACKAGE_PIN N6  [get_ports {EXPANSION[17]}]
set_property PACKAGE_PIN P6  [get_ports {EXPANSION[18]}]
set_property PACKAGE_PIN M6  [get_ports {EXPANSION[19]}]

##### Bottom row from left to right
set_property PACKAGE_PIN R16 [get_ports {EXPANSION[20]}]
set_property PACKAGE_PIN R15 [get_ports {EXPANSION[21]}]
set_property PACKAGE_PIN T15 [get_ports {EXPANSION[22]}]
set_property PACKAGE_PIN T14 [get_ports {EXPANSION[23]}]
set_property PACKAGE_PIN R13 [get_ports {EXPANSION[24]}]
set_property PACKAGE_PIN T13 [get_ports {EXPANSION[25]}]
set_property PACKAGE_PIN R12 [get_ports {EXPANSION[26]}]
set_property PACKAGE_PIN T12 [get_ports {EXPANSION[27]}]
set_property PACKAGE_PIN R11 [get_ports {EXPANSION[28]}]
set_property PACKAGE_PIN R10 [get_ports {EXPANSION[29]}]
set_property PACKAGE_PIN T10 [get_ports {EXPANSION[30]}]
set_property PACKAGE_PIN T9  [get_ports {EXPANSION[31]}]
set_property PACKAGE_PIN R8  [get_ports {EXPANSION[32]}]
set_property PACKAGE_PIN T8  [get_ports {EXPANSION[33]}]
set_property PACKAGE_PIN R7  [get_ports {EXPANSION[34]}]
set_property PACKAGE_PIN T7  [get_ports {EXPANSION[35]}]

set_property IOSTANDAD LVCMOS18 [get_ports EXPANSION*]

#### FPGA config
set_property CONFIG_MODE SPIx1 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 12 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

#### Other misc. stuff
set_operating_conditions -airflow 0
set_operating_conditions -heatsink low
