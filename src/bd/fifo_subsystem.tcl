
################################################################
# This is a generated script based on design: fifo_subsystem
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source fifo_subsystem_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a50tftg256-1
}


# CHANGE DESIGN NAME HERE
set design_name fifo_subsystem

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  set str_bd_folder $origin_dir/work/FreeSRP/FreeSRP.bd
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_msg_id "BD_TCL-110" "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_msg_id "BD_TCL-008" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_msg_id "BD_TCL-009" "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-111" "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-010" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-112" "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_msg_id "BD_TCL-113" "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-011" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_msg_id "BD_TCL-012" "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set RX_FIFO_READ [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:fifo_read_rtl:1.0 RX_FIFO_READ ]
  set RX_FIFO_WRITE [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:fifo_write_rtl:1.0 RX_FIFO_WRITE ]
  set TX_FIFO_READ [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:fifo_read_rtl:1.0 TX_FIFO_READ ]
  set TX_FIFO_WRITE [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:fifo_write_rtl:1.0 TX_FIFO_WRITE ]

  # Create ports
  set fifo_rst [ create_bd_port -dir I fifo_rst ]
  set gpif_data_clk [ create_bd_port -dir I -type clk gpif_data_clk ]
  set rx_rd_count [ create_bd_port -dir O -from 11 -to 0 rx_rd_count ]
  set rx_wr_count [ create_bd_port -dir O -from 11 -to 0 rx_wr_count ]
  set tx_rd_count [ create_bd_port -dir O -from 11 -to 0 tx_rd_count ]
  set tx_wr_count [ create_bd_port -dir O -from 11 -to 0 tx_wr_count ]
  set xcvr_data_clk [ create_bd_port -dir I -type clk xcvr_data_clk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {61440000} \
 ] $xcvr_data_clk

  # Create instance: rx_fifo_generator, and set properties
  set rx_fifo_generator [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 rx_fifo_generator ]
  set_property -dict [ list \
CONFIG.Data_Count_Width {12} \
CONFIG.Empty_Threshold_Assert_Value {4} \
CONFIG.Empty_Threshold_Negate_Value {5} \
CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
CONFIG.Full_Flags_Reset_Value {1} \
CONFIG.Full_Threshold_Assert_Value {4095} \
CONFIG.Full_Threshold_Negate_Value {4094} \
CONFIG.Input_Data_Width {24} \
CONFIG.Input_Depth {4096} \
CONFIG.Output_Data_Width {24} \
CONFIG.Output_Depth {4096} \
CONFIG.Performance_Options {First_Word_Fall_Through} \
CONFIG.Read_Data_Count {true} \
CONFIG.Read_Data_Count_Width {12} \
CONFIG.Use_Dout_Reset {true} \
CONFIG.Write_Data_Count {true} \
CONFIG.Write_Data_Count_Width {12} \
 ] $rx_fifo_generator

  # Create instance: tx_fifo_generator, and set properties
  set tx_fifo_generator [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.1 tx_fifo_generator ]
  set_property -dict [ list \
CONFIG.Data_Count_Width {12} \
CONFIG.Empty_Threshold_Assert_Value {2} \
CONFIG.Empty_Threshold_Negate_Value {3} \
CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
CONFIG.Full_Flags_Reset_Value {1} \
CONFIG.Full_Threshold_Assert_Value {4093} \
CONFIG.Full_Threshold_Negate_Value {4092} \
CONFIG.Input_Data_Width {24} \
CONFIG.Input_Depth {4096} \
CONFIG.Output_Data_Width {24} \
CONFIG.Output_Depth {4096} \
CONFIG.Read_Data_Count {true} \
CONFIG.Read_Data_Count_Width {12} \
CONFIG.Use_Dout_Reset {true} \
CONFIG.Write_Data_Count {true} \
CONFIG.Write_Data_Count_Width {12} \
 ] $tx_fifo_generator

  # Create interface connections
  connect_bd_intf_net -intf_net FIFO_READ_1 [get_bd_intf_ports RX_FIFO_READ] [get_bd_intf_pins rx_fifo_generator/FIFO_READ]
  connect_bd_intf_net -intf_net FIFO_READ_2 [get_bd_intf_ports TX_FIFO_READ] [get_bd_intf_pins tx_fifo_generator/FIFO_READ]
  connect_bd_intf_net -intf_net FIFO_WRITE_1 [get_bd_intf_ports TX_FIFO_WRITE] [get_bd_intf_pins tx_fifo_generator/FIFO_WRITE]
  connect_bd_intf_net -intf_net FIFO_WRITE_1_1 [get_bd_intf_ports RX_FIFO_WRITE] [get_bd_intf_pins rx_fifo_generator/FIFO_WRITE]

  # Create port connections
  connect_bd_net -net rd_clk_1 [get_bd_ports gpif_data_clk] [get_bd_pins rx_fifo_generator/rd_clk] [get_bd_pins tx_fifo_generator/wr_clk]
  connect_bd_net -net rst_1 [get_bd_ports fifo_rst] [get_bd_pins rx_fifo_generator/rst] [get_bd_pins tx_fifo_generator/rst]
  connect_bd_net -net rx_fifo_generator_rd_data_count [get_bd_ports rx_rd_count] [get_bd_pins rx_fifo_generator/rd_data_count]
  connect_bd_net -net rx_fifo_generator_wr_data_count [get_bd_ports rx_wr_count] [get_bd_pins rx_fifo_generator/wr_data_count]
  connect_bd_net -net tx_fifo_generator_rd_data_count [get_bd_ports tx_rd_count] [get_bd_pins tx_fifo_generator/rd_data_count]
  connect_bd_net -net tx_fifo_generator_wr_data_count [get_bd_ports tx_wr_count] [get_bd_pins tx_fifo_generator/wr_data_count]
  connect_bd_net -net wr_clk_1 [get_bd_ports xcvr_data_clk] [get_bd_pins rx_fifo_generator/wr_clk] [get_bd_pins tx_fifo_generator/rd_clk]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port xcvr_data_clk -pg 1 -y 170 -defaultsOSRD -right
preplace port TX_FIFO_WRITE -pg 1 -y 260 -defaultsOSRD
preplace port RX_FIFO_WRITE -pg 1 -y 80 -defaultsOSRD -right
preplace port TX_FIFO_READ -pg 1 -y 260 -defaultsOSRD -right
preplace port gpif_data_clk -pg 1 -y 170 -defaultsOSRD
preplace port fifo_rst -pg 1 -y 350 -defaultsOSRD
preplace port RX_FIFO_READ -pg 1 -y 80 -defaultsOSRD
preplace portBus rx_rd_count -pg 1 -y 20 -defaultsOSRD -left
preplace portBus rx_wr_count -pg 1 -y 20 -defaultsOSRD
preplace portBus tx_rd_count -pg 1 -y 320 -defaultsOSRD
preplace portBus tx_wr_count -pg 1 -y 310 -defaultsOSRD -left
preplace inst tx_fifo_generator -pg 1 -lvl 1 -y 300 -defaultsOSRD
preplace inst rx_fifo_generator -pg 1 -lvl 1 -y 110 -defaultsOSRD
preplace netloc FIFO_READ_2 1 0 2 210 210 600J
preplace netloc wr_clk_1 1 0 2 200 200 590J
preplace netloc tx_fifo_generator_wr_data_count 1 0 2 170J 390 580
preplace netloc rx_fifo_generator_rd_data_count 1 0 2 180J 10 580
preplace netloc rst_1 1 0 1 180
preplace netloc rd_clk_1 1 0 1 190
preplace netloc rx_fifo_generator_wr_data_count 1 1 1 600
preplace netloc tx_fifo_generator_rd_data_count 1 1 1 600
preplace netloc FIFO_WRITE_1 1 0 1 N
preplace netloc FIFO_WRITE_1_1 1 0 2 210 20 590J
preplace netloc FIFO_READ_1 1 0 1 180
levelinfo -pg 1 150 400 620 -top 0 -bot 400
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


