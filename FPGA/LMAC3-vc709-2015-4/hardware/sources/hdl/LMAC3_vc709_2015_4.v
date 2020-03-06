//
// Copyright (C) 2018 LeWiz Communications, Inc. 
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with this library release; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
// 
// LeWiz can be contacted at:  support@lewiz.com
// or address:  
// PO Box 9276
// San Jose, CA 95157-9276
// www.lewiz.com
// 
//    Author: LeWiz Communications, Inc.
//    Language: Verilog


/*******************************************************************************
** � Copyright 2009 - 2014 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        
**  /   /          
** /___/   /\     
** \   \  /  \   Virtex-7 XT Connectivity Domain Targeted Reference Design
**  \___\/\___\ 
** 
**  Device: xc7vx690t
**  Version: 1.3
**  Reference: UG962
**     
*******************************************************************************
**
**  Disclaimer: 
**
**    This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**    requiring fail-safe performance, such as life-support or safety devices or systems, 
**    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**    or any other applications that could lead to death, personal injury, or severe property or 
**    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**    to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************/

`timescale 1ps / 1ps
(* CORE_GENERATION_INFO = "xt_connectivity_trd,xt_connectivity_trd_v1_3,{x_ipproduct=Vivado2014.3,v7_xt_conn_trd=2014.3}" *)
module LMAC3_vc709_2015_4 #
(
    parameter CNTWIDTH = 32,
    parameter NUM_LANES = 8
) (
      input                          sys_rst_n,    
     
      // 200MHz reference clock input
    input                          clk_ref_p,
    input                          clk_ref_n,
  `ifndef DMA_LOOPBACK
    //-SI5324 I2C programming interface
    	inout                          i2c_clk,
    	inout                          i2c_data,
    	output                         i2c_mux_rst_n,
    	output                         si5324_rst_n,
    	// 156.25 MHz clock in
    	input                          xphy_refclk_clk_p,
    	input                          xphy_refclk_clk_n,
  `endif
  `ifdef USE_XPHY
      // 10G PHY ports
    	(* KEEP = "TRUE" *) output       xphy0_txp,
    	(* KEEP = "TRUE" *) output       xphy0_txn,
    	(* KEEP = "TRUE" *) input        xphy0_rxp,
    	(* KEEP = "TRUE" *) input        xphy0_rxn,
    	 					output [3:0]                   sfp_tx_disable,   
  `endif // USE_PHY
    // Diagnostic LEDs
    output  [6:0]                  led,   
    input [2:0]						fmac_speed        

  );



  // ----------------
  // -- Parameters --
  // ----------------
  
  localparam  CORE_DATA_WIDTH         = 256;
  localparam  CORE_BE_WIDTH           = 32;
  localparam  CORE_REMAIN_WIDTH       = 8;

  localparam  AXIS_TDATA_WIDTH          = CORE_DATA_WIDTH;
  localparam  AXIS_TUSER_WIDTH          = 64;
  localparam  AXIS_TKEEP_WIDTH          = (AXIS_TDATA_WIDTH/8);  
  
  localparam  LED_CTR_WIDTH           = 26;   

  localparam  VENDOR_ID               = 16'h10EE; 
  localparam  DEVICE_ID               = 16'h7083; // V7-XT, x8, Gen3,
  localparam  DEVICE_SN               = 64'h0;
 

  // -------------------
  // -- Local Signals --
  // -------------------
  
  wire                                  clk_ref_200;
  wire                                  clk_ref_200_i;
  // Clock and Reset
  wire                                  sys_rst_n_c;
 
  reg     [LED_CTR_WIDTH-1:0]           led_ctr;
  reg     [LED_CTR_WIDTH-1:0]           phy_led_ctr;
//  reg                                   lane_width_error;
//  reg                                   link_speed_error;          

    // Ethernet related signal declarations
  wire                                  xphyrefclk_i;
  wire                                  xgemac_clk_156;
//  reg                                   core_reset;// = 1'b0;
  wire                                  xphy_gt0_tx_resetdone;
  wire                                  xphy_tx_fault;
   
`ifdef USE_XPHY

  	wire [4:0]                            xphy0_prtad;
  	wire                                  xphy0_signal_detect;
  	wire [7:0]                            xphy0_status;


`else
  	wire [0:0]                            xphy0_status = 'b0;

`endif


  wire                             [63:0]    cfg_dsn;


  //----------------------------------------------------------------------------------------------------------------//
  // EP Only                                                                                                        //
  //----------------------------------------------------------------------------------------------------------------//

  wire    [7:0]                         clk_period_in_ns;
  
  IBUF sys_rst_n_ibuf (

    .I      (sys_rst_n        ),
    .O      (sys_rst_n_c      )

);


    IBUFGDS #(
      .DIFF_TERM    ("TRUE"),
      .IBUF_LOW_PWR ("FALSE")
    ) diff_clk_200 (
      .I    (clk_ref_p  ),
      .IB   (clk_ref_n  ),
      .O    (clk_ref_200_i )  
    );

    BUFG u_bufg_clk_ref
    (
      .O (clk_ref_200),
      .I (clk_ref_200_i)
    );

  //- Clocking
  //wire [11:0]   device_temp;
  wire          clk50;
  reg [1:0]     clk_divide = 2'b00;


  always @(posedge clk_ref_200)
    clk_divide  <= clk_divide + 1'b1;

  BUFG buffer_clk50 (
    .I    (clk_divide[1]),
    .O    (clk50        )
  );

  
// Device Serial Number Capability

assign cfg_dsn                      = DEVICE_SN;

//+++++++++++++++++++++++++++++++++++++++++++++++++++

    // always use 250 MHz for GEN3
    assign clk_period_in_ns = 8'h4; 


  reg clk_stable = 1'b0;
  reg ic_rstdone  = 1'b0;
  reg [15:0] axi_ic_rst = 'd0;
                                                         

  `ifndef SIMULATION
    //-SI 5324 programming
    clock_control cc_inst (
      .i2c_clk        (i2c_clk        ),
      .i2c_data       (i2c_data       ),
      .i2c_mux_rst_n  (i2c_mux_rst_n  ),
      .si5324_rst_n   (si5324_rst_n   ),
      .rst            (~sys_rst_n_c     ),  
      .clk50          (clk50          )
    );
  `else
    assign i2c_clk        = 1'b1;
    assign i2c_data       = 1'b1;
    assign i2c_mux_rst_n  = 1'b1;
    assign si5324_rst_n   = 1'b1;
  `endif  

  wire sys_rst_n_sync_eth;

  wire sys_rst;
  
  // Synchronize perst_n to Ethernet clock
    synchronizer_simple #(.DATA_WIDTH (1)) sync_perst_to_ethclk
  (
    .data_in          (sys_rst_n_c),
    .new_clk          (xgemac_clk_156),
    .data_out         (sys_rst_n_sync_eth)
  );
  
  // Use async assert, synchronous deassert, active high
  assign sys_rst = ~sys_rst_n_c || ~sys_rst_n_sync_eth;
  
 
`ifdef BASE_ONLY
  //- Differential to Single-ended Clock conversion for 10G PHY
   IBUFDS_GTE2 xgphy_refclk_ibuf (
   
       .I      (xphy_refclk_clk_p),
       .IB     (xphy_refclk_clk_n),
       .O      (xphyrefclk_i  ),
       .CEB    (1'b0          ),
       .ODIV2  (              )   
   );

   BUFG xgphy_refclk_bufg (

      .I      (xphyrefclk_i),
      .O      (xgemac_clk_156  )
   );

   
   assign xphy_gt0_tx_resetdone = 1'b1;
   assign xphy_tx_fault = 1'b0;

`else // ! BASE_ONLY

`ifdef USE_XPHY
  `ifdef SIMULATION
  // Deliberately not driving to default value or assigning a value
  // It will be driven by the simulation testbench by dot reference
(* KEEP = "TRUE" *)      wire sim_speedup_control;
  `else
(* KEEP = "TRUE" *)    wire sim_speedup_control = 1'b0;
  `endif
 
  //- Network Path instance #0
  assign xphy0_prtad          = 5'd0;
  assign xphy0_signal_detect  = 1'b1;
  assign xphy_tx_fault        = 1'b0;

  network_path_shared #(
    .AXIS_TDATA_WIDTH                 (AXIS_TDATA_WIDTH            ),
    .AXIS_TKEEP_WIDTH                 (AXIS_TKEEP_WIDTH            ) 
  ) network_path_inst_0 (
    .xphy_refclk_p                    (xphy_refclk_clk_p),
    .xphy_refclk_n                    (xphy_refclk_clk_n),
    .xphy_txp                         (xphy0_txp),
    .xphy_txn                         (xphy0_txn),
    .xphy_rxp                         (xphy0_rxp),
    .xphy_rxn                         (xphy0_rxn),
    .txusrclk                         (	),
    .txusrclk2                        (	),
    .tx_resetdone                      (xphy_gt0_tx_resetdone),
    .areset_clk156                    (	),
    .gttxreset                        (	),
    .gtrxreset                        (	),
    .txuserrdy                        (	),
    .qplllock                         (	),
    .qplloutclk                       (	),
    .qplloutrefclk                    (	),
    .reset_counter_done               (	),
    .dclk                             (xgemac_clk_156),  
    .xphy_status                      (xphy0_status),
    .xphy_tx_disable                  (	),
    .signal_detect                    (xphy0_signal_detect),
    .tx_fault                          (xphy_tx_fault), 
    .prtad                            (xphy0_prtad),
    .clk156                           (xgemac_clk_156),
    .sys_rst                          (sys_rst),
    .sim_speedup_control              (sim_speedup_control),
    .fmac_speed							(fmac_speed)
  ); 



`endif   // USE_XPHY 
    //- Network instance ends
`endif  //! BASE_ONLY

// LEDs - Status
// ---------------
// Heart beat LED; flashes when primary PCIe core clock is present
//always @(posedge user_clk)
//begin
//    led_ctr <= led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
//end

always @(posedge xgemac_clk_156)
begin
    phy_led_ctr <= phy_led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end

`ifdef SIMULATION
// Initialize for simulation
initial
begin
    led_ctr = {LED_CTR_WIDTH{1'b0}};
    phy_led_ctr = {LED_CTR_WIDTH{1'b0}};
end
`endif


assign led[0] = 1'b0; 
assign led[1] = 1'b0;  // Flashes when user_clk is present
assign led[2] = 1'b0;
assign led[3] = 1'b0;
assign led[6] = 1'b0;
assign led[5] = 1'b0;
assign led[4] = 1'b0;

`ifdef USE_XPHY
  //- Disable Laser when unconnected on SFP+
  assign sfp_tx_disable = 4'b0000;
`endif

endmodule

