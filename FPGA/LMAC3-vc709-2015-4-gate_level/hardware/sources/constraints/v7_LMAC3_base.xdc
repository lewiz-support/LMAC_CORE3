##
##
##
## Copyright (C) 2018 LeWiz Communications, Inc. 
## 
## This library is free software; you can redistribute it and/or
## modify it under the terms of the GNU Lesser General Public
## License as published by the Free Software Foundation; either
## version 2.1 of the License, or (at your option) any later version.
## 
## This library is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## Lesser General Public License for more details.
## 
## You should have received a copy of the GNU Lesser General Public
## License along with this library release; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
## 
## LeWiz can be contacted at:  support@lewiz.com
## or address:  
## PO Box 9276
## San Jose, CA 95157-9276
## www.lewiz.com
## 
##

###############################################################################
###############################################################################
create_clock -name mcb_clk_ref -period 5 [get_ports clk_ref_p]

# Bank: 38 - Byte 
set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_p}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk_ref_p}]
set_property PACKAGE_PIN H19 [get_ports {clk_ref_p}]

# Bank: 38 - Byte 
set_property VCCAUX_IO DONTCARE [get_ports {clk_ref_n}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {clk_ref_n}]
set_property PACKAGE_PIN G18 [get_ports {clk_ref_n}]

##GT Ref clk
set_property PACKAGE_PIN AH8 [get_ports xphy_refclk_clk_p]
set_property PACKAGE_PIN AH7 [get_ports xphy_refclk_clk_n]

# SFP TX Disable for 10G PHY
set_property PACKAGE_PIN AB41  [get_ports {sfp_tx_disable[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sfp_tx_disable[0]}]
set_property PACKAGE_PIN Y42  [get_ports {sfp_tx_disable[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sfp_tx_disable[1]}]
set_property PACKAGE_PIN AC38  [get_ports {sfp_tx_disable[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sfp_tx_disable[2]}]
set_property PACKAGE_PIN AC40  [get_ports {sfp_tx_disable[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {sfp_tx_disable[3]}]

##-------------------------------------
## LED Status Pinout   (bottom to top)
##-------------------------------------

set_property PACKAGE_PIN AM39  [get_ports {led[0]}]
set_property PACKAGE_PIN AN39  [get_ports {led[1]}]
set_property PACKAGE_PIN AR37  [get_ports {led[2]}]
set_property PACKAGE_PIN AT37  [get_ports {led[3]}]
set_property PACKAGE_PIN AR35  [get_ports {led[4]}]
set_property PACKAGE_PIN AP41  [get_ports {led[5]}]
set_property PACKAGE_PIN AP42  [get_ports {led[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[6]}]

set_property SLEW SLOW [get_ports led]
set_property DRIVE 4 [get_ports led]

#########################################################
# PCIe Constraints
#########################################################
##------------------------
## Clock and Reset Pinout
##------------------------

                                                      
# Reset                                               
                                                      
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]                                                      
set_property PACKAGE_PIN AV40 [get_ports sys_rst_n]   


## The constraint 'NODELAY' is not supported in this version of software. Hence not converted.
#set_property LOC AV35 [get_ports perst_n]
#set_property IOSTANDARD LVCMOS18 [get_ports perst_n]
#set_property PULLUP true [get_ports perst_n]

## 100 MHz Reference Clock
#set_property PACKAGE_PIN AB7 [get_ports pcie_clk_n]
#set_property PACKAGE_PIN AB8 [get_ports pcie_clk_p]


# Timing constraints
#create_clock -name sys_clk -period 10 [get_ports pcie_clk_p]


#create_generated_clock -name clk_125mhz_mux \
#                        -source [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] \
#                        -divide_by 1 \
#                        [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]
#
#create_generated_clock -name clk_250mhz_mux \
#                        -source [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] \
#                        -divide_by 1 -add -master_clock [get_clocks -of [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] \
#                        [get_pins ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]


#set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux -group clk_250mhz_mux

#set_false_path -to [get_pins {ext_clk.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*}]

set_false_path -from [get_ports sys_rst_n]

###-------------------------------------
##PMBUS LOC
###-------------------------------------
#set_property PACKAGE_PIN AW37  [get_ports pmbus_clk]
#set_property IOSTANDARD LVCMOS18 [get_ports pmbus_clk]
#set_property PACKAGE_PIN AY39  [get_ports pmbus_data]
#set_property IOSTANDARD LVCMOS18 [get_ports pmbus_data]
#set_property PACKAGE_PIN AV38  [get_ports pmbus_alert]
#set_property IOSTANDARD LVCMOS18 [get_ports pmbus_alert]

# 156.25 MHz clock control LOCs
set_property IOSTANDARD LVCMOS18 [get_ports i2c_clk]
set_property SLEW SLOW [get_ports i2c_clk]
set_property DRIVE 16 [get_ports i2c_clk]
set_property PULLUP TRUE [get_ports i2c_clk]
set_property PACKAGE_PIN AT35 [get_ports i2c_clk]

set_property IOSTANDARD LVCMOS18 [get_ports i2c_data]
set_property SLEW SLOW [get_ports i2c_data]
set_property DRIVE 16 [get_ports i2c_data]
set_property PULLUP TRUE [get_ports i2c_data]
set_property PACKAGE_PIN AU32 [get_ports i2c_data]

set_property IOSTANDARD LVCMOS18 [get_ports i2c_mux_rst_n]
set_property SLEW SLOW [get_ports i2c_mux_rst_n]
set_property DRIVE 16 [get_ports i2c_mux_rst_n]
set_property PACKAGE_PIN AY42 [get_ports i2c_mux_rst_n]

set_property IOSTANDARD LVCMOS18 [get_ports si5324_rst_n]
set_property SLEW SLOW [get_ports si5324_rst_n]
set_property DRIVE 16 [get_ports si5324_rst_n]
set_property PACKAGE_PIN AT36 [get_ports si5324_rst_n]

# Generated clock
create_generated_clock -name clk50 -source [get_ports clk_ref_p] -divide_by 4 [get_pins clk_divide_reg[1]/Q]
set clk156 [get_clocks -of_objects [get_pins network_path_inst_0/ten_gig_eth_pcs_pma_inst/refclk_p]]

#Domain crossing constraints
set_clock_groups -name async_mcb_xgemac -asynchronous \
  -group [get_clocks  mcb_clk_ref] \
  -group [get_clocks  $clk156]


set_clock_groups -name async_mig_pcie -asynchronous \
  -group [get_clocks -include_generated_clocks mcb_clk_ref] 
#  -group [get_clocks userclk2]

set_clock_groups -name async_mig_ref_clk50 -asynchronous \
   -group [get_clocks mcb_clk_ref] \
   -group [get_clocks clk50]

set_clock_groups -name async_clk50_pcie -asynchronous \
  -group [get_clocks clk50] 
#  -group [get_clocks userclk2]

set_clock_groups -name async_mig_xgemac -asynchronous \
  -group [get_clocks -include_generated_clocks mcb_clk_ref] \
  -group [get_clocks $clk156]

set_clock_groups -name async_userclk2_clk156 -asynchronous \
   -group [get_clocks  $clk156]
   #-group [get_clocks  userclk2] \

   
set_clock_groups -name async_xgemac_clk50 -asynchronous \
   -group [get_clocks $clk156] \
   -group [get_clocks clk50]


#set_clock_groups -asynchronous -group clk_125mhz_mux -group clk50 
#set_clock_groups -asynchronous -group clk_250mhz_mux -group clk50




