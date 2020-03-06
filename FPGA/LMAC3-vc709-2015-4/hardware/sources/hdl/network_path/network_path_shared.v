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

//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information of Xilinx, Inc.
// and is protected under U.S. and international copyright and other
// intellectual property laws.
//
// DISCLAIMER
//
// This disclaimer is not a license and does not grant any rights to the
// materials distributed herewith. Except as otherwise provided in a valid
// license issued to you by Xilinx, and to the maximum extent permitted by
// applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
// FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
// IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
// MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
// and (2) Xilinx shall not be liable (whether in contract or tort, including
// negligence, or under any other theory of liability) for any loss or damage
// of any kind or nature related to, arising under or in connection with these
// materials, including for any direct, or any indirect, special, incidental,
// or consequential loss or damage (including loss of data, profits, goodwill,
// or any type of loss or damage suffered as a result of any action brought by
// a third party) even if such damage or loss was reasonably foreseeable or
// Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
//
// Xilinx products are not designed or intended to be fail-safe, or for use in
// any application requiring fail-safe performance, such as life-support or
// safety devices or systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any other
// applications that could lead to death, personal injury, or severe property
// or environmental damage (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and liability of any use of
// Xilinx products in Critical Applications, subject only to applicable laws
// and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
// AT ALL TIMES.

`timescale 1ps / 1ps

(* CORE_GENERATION_INFO = "network_path_shared,network_path_shared_v1_3,{x_ipproduct=Vivado2014.3,v7_xt_conn_trd=2014.3}" *)
module network_path_shared # (
    parameter RX_FIFO_CNT_WIDTH    =  13,
    parameter AXIS_TDATA_WIDTH  = 128, 
    parameter AXIS_TKEEP_WIDTH  = 16,
    parameter AXIS_XGEMAC_TDATA_WIDTH  = 64, 
    parameter ADDRESS_FILTER_EN = 1,
    parameter C_BASE_ADDRESS    = 32'h000,  
    parameter C_HIGH_ADDRESS    = 32'h07FF
)
(   
    input                            xphy_refclk_n,
    input                            xphy_refclk_p,
(* KEEP = "TRUE" *)         output                           xphy_txp, 
(* KEEP = "TRUE" *)         output                           xphy_txn, 
(* KEEP = "TRUE" *)         input                            xphy_rxp, 
(* KEEP = "TRUE" *)         input                            xphy_rxn, 
    output                           txusrclk, 
    output                           txusrclk2, 
//-Shared reset signals
    output                           areset_clk156,
    output                           gttxreset,   
    output                           gtrxreset,   
    output                           txuserrdy,
    output                           qplllock,
    output                           qplloutclk,
    output                           qplloutrefclk,
    output                           reset_counter_done,
    output                           tx_resetdone, 
    
//    input                            core_reset, 
    input                            tx_fault,
    input                            signal_detect,
    input [4 : 0]                    prtad,
    output                           xphy_tx_disable, 

    output [7:0]                     xphy_status,
    output                           clk156, 
    input                            dclk,
    input                            sys_rst,
    input                            sim_speedup_control,
    input [2:0]						fmac_speed
);


   //LEWIZ
   //`ifdef USE_XPHY
  //-10GBASE-R PHY Specific signals
(* KEEP = "TRUE" *)   wire [255 : 0]                             cgmii_txd_core;
(* KEEP = "TRUE" *)   wire [31 : 0]                              cgmii_txc_core;
(* KEEP = "TRUE" *)     wire [255 : 0]                           cgmii_rxd_core;
(* KEEP = "TRUE" *)     wire [31 : 0]                            cgmii_rxc_core;

  wire  xphy_resetdone;
	//`endif

  wire                                      drp_gnt;
  wire                                      drp_req;
  wire                                      drp_den_o;                                   
  wire                                      drp_dwe_o;
  wire [15 : 0]                             drp_daddr_o;                   
  wire [15 : 0]                             drp_di_o; 
  wire                                      drp_drdy_o;                
  wire [15 : 0]                             drp_drpdo_o;
  wire                                      drp_den_i;                                   
  wire                                      drp_dwe_i;
  wire [15 : 0]                             drp_daddr_i;                   
  wire [15 : 0]                             drp_di_i; 
  wire                                      drp_drdy_i;                
  wire [15 : 0]                             drp_drpdo_i;

  assign cgmii_rxd_core[255:64] = {192'h0707070707070707_0707070707070707_0707070707070707};
  assign cgmii_rxc_core[31:8] = {24'hFF_FF_FF};

//LEWIZ_MODULE_SIGNALS
    //Interface to TX PATH
	wire         		tx_mac_wr;       	//1
	wire	[255 : 0]	tx_mac_data;		//64
	wire	           	tx_mac_full;		//1
    wire  	[12 : 0]    tx_mac_usedw;    	//13
		
    //Interface to RX PATH
    wire 	[255 : 0]   	rx_mac_data;		//64
    wire			   	rx_mac_empty;   	//1
    wire 		   		rx_mac_rd;      	//1

    //for pattern search (I/F to RX Path/EXTR)
    wire	       		cs_fifo_rd_en;		//1
    wire		       	cs_fifo_empty;		//1
    wire 	[63 : 0]   	ipcs_fifo_dout;		//64
 

//LEWIZ_LPBK_MODULE FOR LMAC3
LPBK_MODULE LPBK_MODULE(                         
                                                
	.clk(clk156),				//i-1            
	.reset_(xphy_resetdone),     		//i-1   	
	                                             
    //Interface to TX PATH                      
	.tx_mac_wr(tx_mac_wr),       	//o-1    
	.tx_mac_data(tx_mac_data),		//o-64      
	.tx_mac_full(tx_mac_full),		//i-1        
    .tx_mac_usedw(tx_mac_usedw),    	//i-13
		                                         
    //Interface to RX PATH                      
    .rx_mac_data(rx_mac_data),		//i-64   
    .rx_mac_empty(rx_mac_empty),   	//i-1        
    .rx_mac_rd(rx_mac_rd),      	//o-1      
                                                
    //for pattern search (I/F to RX Path/EXTR)  
    .cs_fifo_rd_en(cs_fifo_rd_en),		//o-1    
    .cs_fifo_empty(cs_fifo_empty),		//i-1    
    .ipcs_fifo_dout(ipcs_fifo_dout)		//i-64	
                                                
);                                                                                                       

////LEWIZ_ETH_MAC - CORE3
LMAC_TOP_SYNTH LMAC_TOP_SYNTH (                                                                                                         
                                                                                                                                   
    .clk(clk156),                //i-1, clk                                                                              
    .reset_(xphy_resetdone),             //i-1, reset_                                                                           
                                                                                                                                   
    // Interface to TX PATH                                                                                                        
	.tx_mac_wr(tx_mac_wr),          // i-1                                                                                    
	.tx_mac_data(tx_mac_data),		   // i-64                                                                                      
	.tx_mac_full(tx_mac_full),		   // o-1                                                                                       
    .tx_mac_usedw(tx_mac_usedw),       // o-13                                                                                
		                                                                                                                            
    // Interface to RX PATH                                                                                                        
    .rx_mac_data(rx_mac_data),                                                                                              
    .rx_mac_ctrl(),                                                                                              
    .rx_mac_empty(rx_mac_empty),                                                                                                   
    .rx_mac_rd(rx_mac_rd),                                                                                                        
                                                                                                                                   
    //for pattern search (I/F to RX Path/EXTR)                                                                                     
    .cs_fifo_rd_en(cs_fifo_rd_en),		//i-1                                                                                       
    .cs_fifo_empty(cs_fifo_empty),		//o-1                                                                                       
                                                                                                                                   
    .ipcs_fifo_dout(ipcs_fifo_dout),		                                                                                           
                                                                                                                                   
    .cgmii_txd(cgmii_txd_core),			//o-256                                                                                      
    .cgmii_txc(cgmii_txc_core),			//o-32                                                                                       
    .cgmii_rxd(cgmii_rxd_core),			//i-256                                                                                      
    .cgmii_rxc(cgmii_rxc_core),			//i-32                                                                                       
                                                                                                                                   
    .xauiA_linkup(),		// to LED on board                                                                               
                                                                                                                                   
    // From central decoder                                                                                                        
    .host_addr_reg(16'h0),                                                                                              
    .SYS_ADDR(4'h1),                                                                                                   
                                                                                                                                   
    // From mac_register                                                                                                           
    .fail_over(1'b0),                                                                                                          
    .fmac_ctrl(32'h00000808),                                                                                                  
    .fmac_ctrl1(32'h000005ee),                                                                                                 
                                                                                                                                   
    .fmac_rxd_en(1'b1)	,                                                                                                       
                                                                                                                
    .mac_pause_value(32'hffff0000),		// [31:16] = tx_pause_value to send a pause frame, [15:0] = rx_pause_value (not implement)
	.mac_addr0(48'h001232004eaf),			// mac_addr to check in non-promiscuous mode                                            
                                                                     
    .reg_rd_start(1'b0),                                                                                                       
                                                                                                                                   
    .reg_rd_done_out(),		                                                                                                 
                                                                                                                                   
                                                                                                                                   
    .FMAC_REGDOUT(),                                                                                               
    .FIFO_OV_IPEND(),  
    .fmac_speed(fmac_speed)                                                                                                    
                                                                                                                                   
);                                                                                                                                 



  assign tx_resetdone = xphy_resetdone;
  // If no arbitration is required on the GT DRP ports then connect REQ to GNT
  // and connect other signals i <= o;
  assign drp_gnt = drp_req;
  assign drp_den_i = drp_den_o;
  assign drp_dwe_i = drp_dwe_o;
  assign drp_daddr_i = drp_daddr_o;                   
  assign drp_di_i = drp_di_o;
  assign drp_drdy_i = drp_drdy_o;
  assign drp_drpdo_i = drp_drpdo_o;
  
  ten_gig_eth_pcs_pma_ip_shared_logic_in_core ten_gig_eth_pcs_pma_inst (
      .refclk_n               (xphy_refclk_n),  		//i-1, (!clk = 156MHz),
      .refclk_p               (xphy_refclk_p),          //i-1, (clk = 156MHz)  
      //.core_clk156_out      (clk156), 
      .coreclk_out		      (clk156),  				//o-1
      .dclk                   (dclk),					//i-1, (clk_156) = buffered??? (NOT SURE)                                                                        
      .txusrclk_out           (txusrclk),               //o-1                                                                                                            
      .txusrclk2_out          (txusrclk2),              //o-1                                                                                                            
      .reset                  (sys_rst),                //i-1, (perst_sys_rst = ~perst_n_c || ~perst_n_sync_eth);	(perst_n_sync_eth <= perst_n_c); (perst_n_c = perst_n);
      //.areset_clk156_out    (areset_clk156),
      .areset_datapathclk_out (areset_clk156),			//o-1                                                                
      .gttxreset_out          (gttxreset),              //o-1                                                                
      .gtrxreset_out          (gtrxreset),              //o-1                                                                
      .txuserrdy_out          (txuserrdy),              //o-1                                                                
      .qplllock_out           (qplllock),               //o-1                                                                
      .qplloutclk_out         (qplloutclk),             //o-1                                                                
      .qplloutrefclk_out      (qplloutrefclk),          //o-1                                                                
      .reset_counter_done_out (reset_counter_done),     //o-1                                                                
      .xgmii_txd              (cgmii_txd_core[63:0]),         //i-64,	XGMII_INTERFACE with MAC_CORE            
      .xgmii_txc              (cgmii_txc_core[7:0]),         //i-8,	XGMII_INTERFACE with MAC_CORE                                  
      .xgmii_rxd              (cgmii_rxd_core[63:0]),         //o-64,	XGMII_INTERFACE with MAC_CORE                                
      .xgmii_rxc              (cgmii_rxc_core[7:0]),         //o-8,	XGMII_INTERFACE with MAC_CORE                                 
      .txp                    (xphy_txp),               //o-1, Loopback signals-                                             
      .txn                    (xphy_txn),               //o-1, 		-sent to rxp, rxn                                           
      .rxp                    (xphy_rxp),               //i-1, xphy_txp                                                      
      .rxn                    (xphy_rxn),               //i-1, xphy_txn                                                      
      .mdc                    (1'b0),                   //i-1,	MDIO_INTERFACE with MAC_CORE                                  
      .mdio_in                (1'b0),               	//i-1,	MDIO_INTERFACE with MAC_CORE                                  
      .mdio_out               (),                		//o-1,	MDIO_INTERFACE with MAC_CORE                                  
      .mdio_tri               (),                       //o-1,	MDIO_INTERFACE with MAC_CORE                                  
      .prtad                  (prtad),                  //i-5, = 5'd0;                                                       
      .core_status            (xphy_status),            //o-8                                                                
      .resetdone_out          (xphy_resetdone),         //o-1                                                                
      .signal_detect          (signal_detect),          //i-1, = 1'b1;                                                       
      .tx_fault               (tx_fault),               //i-1, = 1'b0;                                                       
      .drp_req                (drp_req),                //o-1, sent to drp_gnt                                               
      .drp_gnt                (drp_gnt),                //i-1, = drp_req                                                     
      .drp_den_o              (drp_den_o),              //o-1, sent to drp_den_i                                             
      .drp_dwe_o              (drp_dwe_o),              //o-1, sent to drp_dwe_i                                             
      .drp_daddr_o            (drp_daddr_o),            //o-16, sent to drp_daddr_i                                          
      .drp_di_o               (drp_di_o),               //o-16, sent to drp_di_i                                             
      .drp_drdy_o             (drp_drdy_o),             //o-1, sent to drp_drdy_i                                            
      .drp_drpdo_o            (drp_drpdo_o),            //o-16, sent to drp_drpdo_i                                          
      .drp_den_i              (drp_den_i),              //i-1, = drp_den_o                                                   
      .drp_dwe_i              (drp_dwe_i),              //i-1, = drp_dwe_o                                                   
      .drp_daddr_i            (drp_daddr_i),            //i-16, = drp_daddr_o                                                
      .drp_di_i               (drp_di_i),               //i-16, = drp_di_o                                                   
      .drp_drdy_i             (drp_drdy_i),             //i-1, = drp_drdy_o                                                  
      .drp_drpdo_i            (drp_drpdo_i),            //i-16, = drp_drpdo_o                                                
      .pma_pmd_type           (3'b101),                 //i-3, = 3'b101                                                      
      .tx_disable             (xphy_tx_disable),        //o-1                                                                
      .sim_speedup_control    (sim_speedup_control)     //i-1, It will be driven by the simulation testbench by dot reference
    );

endmodule
