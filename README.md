# FreeSRP FPGA

**Currently works with Vivado 2016.3**

The [FreeSRP](http://freesrp.org) is an open source platform for software defined radio. The hardware is based around the [Analog Devices AD9364](http://www.analog.com/en/products/rf-microwave/integrated-transceivers-transmitters-receivers/wideband-transceivers-ic/ad9364.html) transceiver covering 70 MHz - 6 Ghz with a sample rate of up to 61.44 MHz, an Xilinx Artix 7 FPGA and a USB 3.0 connection to stream data to a computer in real time.

This repository contains all the source code used in the FPGA design that runs on the FreeSRP's Artix 7 FPGA (XC7A50T-1FTG256C).

## Under construction

The current design allows the transceiver to be configured and data to be received, even at the full bandwidth. Transmitting and full-duplex operation is possible as well, but not yet at the full bandwidth.

## Getting started

You only need the source code in this repository if you want to make changes to the FreeSRP's FPGA design. To work with it, you need the latest [Xilinx Vivado Design Suite](http://www.xilinx.com/products/design-tools/vivado.html) (the free WebPack edition is fine) and the Xilinx SDK (should be included with Vivado).

First, compile the software that will run on the MicroBlaze:
```
xsdk -batch -source build_sdk.tcl
```

To open the FreeSRP Vivado project, run:
```
vivado -source build_project.tcl
```

You will now be able to launch synthesis and generate a bitstream ready to be loaded onto the FPGA.

## Note on the MicroBlaze

Currently, there is a MicroBlaze soft processor to handle interfacing with the AD9364. This is going to be eliminated soon, and the FX3 will run the code that is now being run by the MicroBlaze. This is why there is a bunch of ``fx3_router`` stuff in this repository -- when it's done, the "FX3 router" will receive packets from the FX3 over UART and route them to different interfaces (debug, AD9364 SPI, GPIO...) depending on what the FX3 wants. However, none of this is currently in use.
