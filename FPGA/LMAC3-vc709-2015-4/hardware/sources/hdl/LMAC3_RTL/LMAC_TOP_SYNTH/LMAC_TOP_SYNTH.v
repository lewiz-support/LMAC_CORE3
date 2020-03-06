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
//

// synopsys translate_off
`timescale 1ns/10ps
// synopsys translate_on

module LMAC_TOP_SYNTH (

    input              clk,                //i-1, clk
    input              reset_,             //i-1, reset_

    // Interface to TX PATH
	input              	tx_mac_wr,          // i-1
(* KEEP = "TRUE" *)	input  [255 : 0]    tx_mac_data,		   // i-64
(* KEEP = "TRUE" *)	output	           	tx_mac_full,		   // o-1
    output [12 : 0]    	tx_mac_usedw,       // o-13
		
    // Interface to RX PATH
(* KEEP = "TRUE" *)    output [255 : 0]	   	rx_mac_data,
(* KEEP = "TRUE" *)    output [ 31 : 0]	   	rx_mac_ctrl,
    output 			   		rx_mac_empty,
    input			   		rx_mac_rd,

    //for pattern search (I/F to RX Path/EXTR)
    input		       cs_fifo_rd_en,		//i-1
    output		       cs_fifo_empty,		//o-1

    output [63 : 0]	   ipcs_fifo_dout,		

    //input			   xgmii_reset_,		//i-1   
(* KEEP = "TRUE" *)     output [255 : 0]    cgmii_txd,			//o-256
(* KEEP = "TRUE" *)     output [ 31 : 0]    cgmii_txc,			//o32
(* KEEP = "TRUE" *)         input  [255 : 0]    cgmii_rxd,			//i-256
(* KEEP = "TRUE" *)         input  [ 31 : 0]    cgmii_rxc,			//i-32
    //input[ 1 : 0]    xgmii_led_,		    //i-2

    output		       xauiA_linkup,		// to LED on board 
        
    // From central decoder
    input  [15 : 0]	   host_addr_reg,
    input  [ 3 : 0]	   SYS_ADDR,
            
    // From mac_register
    input			   fail_over,
    input  [31 : 0]	   fmac_ctrl,
    input  [31 : 0]	   fmac_ctrl1,

    input			   fmac_rxd_en	,

    input  [31 : 0]	   mac_pause_value,		// [31:16] = tx_pause_value to send a pause frame, [15:0] = rx_pause_value (not implement)
    input  [47 : 0]	   mac_addr0,			// mac_addr to check in non-promiscuous mode

    input			   reg_rd_start,

    output			   reg_rd_done_out,		

            
    output [31 : 0]	   FMAC_REGDOUT,
    output			   FIFO_OV_IPEND,
	
	input [2:0] 		fmac_speed
	
	
		

);


reg 		mode_10G  ;
reg 		mode_25G  ;
reg 		mode_40G  ;
reg 		mode_50G  ;
reg 		mode_100G ;


	always@(posedge clk)
		begin
			case (fmac_speed)
			
			3'b000: begin
					mode_10G <= 1'b1;
					mode_25G <= 1'b0;
					mode_40G <= 1'b0;
					mode_50G <= 1'b0;
					mode_100G <= 1'b0;
					end
			3'b001: begin
					mode_10G <= 1'b0;
					mode_25G <= 1'b1;
					mode_40G <= 1'b0;
					mode_50G <= 1'b0;
					mode_100G <= 1'b0;
					end
			3'b010: begin
					mode_10G <= 1'b0;
					mode_25G <= 1'b0;
					mode_40G <= 1'b1;
					mode_50G <= 1'b0;
					mode_100G <= 1'b0;
					end
			3'b011: begin
					mode_10G <= 1'b0;
					mode_25G <= 1'b0;
					mode_40G <= 1'b0;
					mode_50G <= 1'b1;
					mode_100G <= 1'b0;
					end
			default: begin
					mode_10G <= 1'b0;
					mode_25G <= 1'b0;
					mode_40G <= 1'b0;
					mode_50G <= 1'b0;
					mode_100G <= 1'b1;
					end
			endcase
		end
		




LMAC_CORE_TOP LMAC_CORE_TOP	(
		
		// Clocks and Reset
		.clk              (clk),					// i-1		250 Mhz		// changed to 156.25 MHz- 7 june 2018				clk,					// i-1, Depends on the speed_mode             
		.xA_clk           (clk),					// i-1		156.25 Mhz                                              		xA_clk,					// i-1, Depends on the speed_mode        
		.reset_           (reset_),					// i-1, FMAC specific reset (also follows PCIE RST)		            		reset_,					// i-1, FMAC specific reset              
		                    	                                                                                        		                                                     
		.mode_10G         (mode_10G),  	      	 		//i-1, speed modes: 10G selected                                    		mode_10G,  		   		//i-1                              
		.mode_25G         (mode_25G),   				//i-1,                                                              		mode_25G,   		    //i-1                              
		.mode_40G 		  (mode_40G),     				//i-1         
		.mode_50G         (mode_50G),      				//i-1,                                                              		mode_40G, 		        //i-1                            
		.mode_100G        (mode_100G),   				//i-1,                                                              		mode_50G,               //i-1                        
		                		                                                                                        		//mode_100G,   		    //i-1                             
		.TCORE_MODE	      (1'b0),			        //i-1,	                                                            		TCORE_MODE	,	      	//i-1, Always tie to 1	          
		// Interface to TX PATH                                                                                                                                                
		.tx_mac_wr        (tx_mac_wr),				// i-1                                                              		// Interface to TX PATH                              
		.tx_mac_data      (tx_mac_data),			// i-64                                                             		tx_mac_wr,				// i-1                                 
		.tx_mac_full      (tx_mac_full),			// o-1                                                              		tx_mac_data,			// i-256                              
		.tx_mac_usedw     (tx_mac_usedw),			// o-13                                                             		tx_mac_full,			// o-1                                
		                                                                                                                		//tx_mac_usedw,			// o-13                              
		// Interface to RX PATH                                                                                         		                                                     
		.rx_mac_data      (rx_mac_data),			// o-64                                                             		// Interface to RX PATH                              
		.rx_mac_ctrl      (rx_mac_ctrl),			// o-8, rsvd, pkt_end, pkt_start                                    		rx_mac_data,			// o-256                              
		.rx_mac_empty     (rx_mac_empty),			// o-1                                                              		rx_mac_ctrl,			// o-32, rsvd, pkt_end, pkt_start     
		.rx_mac_rd        (rx_mac_rd),				// i-1                                                              		rx_mac_empty,			// o-1                               
		                                                                                                                		//rx_mac_rd,				// i-1                                 
		//for field debug   	                                                                                        		                                                     
		.rx_mac_full_dbg  (),		            //o-1                                                                   		//for field debug                                    
		.rx_mac_usedw_dbg (),		            //o-12                                                                  		rx_mac_full_dbg,		//o-1                              
		                                                                                                                		//rx_mac_usedw_dbg,		//o-12                            
		//for pre_CS/parser (I/F to RX Path/EXTR)                                                                       		                                                     
		.cs_fifo_rd_en 	  (cs_fifo_rd_en),		//i-1                                                                   		//for pre_CS/parser (I/F to RX Path/EXTR)            
		.cs_fifo_empty 	  (cs_fifo_empty),		//o-1                                                                   		cs_fifo_rd_en 	,		//i-1                              
		.ipcs_fifo_dout	  (ipcs_fifo_dout),	    //o-64                                                                  		cs_fifo_empty 	,		//o-1                              
		                                                                                                                		//ipcs_fifo_dout	,	    //o-64                          
		// Xaui/PHY A Interface                                                                                         		                                                     
		.cgmii_reset_     (1'b0),    		    //i-1                                                                   		//CGMII-signals                                      
        .cgmii_txd        (cgmii_txd),			//o-256                                                                  		cgmii_reset_  ,			//i-1			                           
        .cgmii_txc        (cgmii_txc),			//o-32                                                                          cgmii_txd ,	            //o-256                
                                                                                                                                //cgmii_txc ,	            //o-32                 
		.cgmii_rxd	      (cgmii_rxd),			//i-64                                                                                                                         
        .cgmii_rxc        (cgmii_rxc),			//i-8                                                                   		cgmii_rxd	,	       	//i-256                          
        .cgmii_led_       (2'b0),			    //i-2                                                                           cgmii_rxc ,	            //i-32                 
		                                                                                                                        //cgmii_led_ ,	        //i-2                     
		.xauiA_linkup     (xauiA_linkup),       // o-1, link up for either 10G or 10G mode                              		                                                     
		                                                                                                                		//xauiA_linkup,			//o-1	                               
		// From central decoder                                                                                         		                                                     
		.host_addr_reg    (host_addr_reg),   	// i-16                                                                 		// From central decoder                              
		.SYS_ADDR         (SYS_ADDR),			//i-4, system assigned addr for the FMAC                                		host_addr_reg,			// i-16                             
		                                                                                                                		//SYS_ADDR,				//i-4, system assigned addr for the FMAC
		// From mac_register                                                                                            		                                                     
		.fail_over        (fail_over),			// i-1                                                                  		// From mac_register                                 
		.fmac_ctrl        (fmac_ctrl),			// i-32                                                                 		fail_over,				// i-1                                 
		.fmac_ctrl1       (fmac_ctrl1),			// i-32                                                                 		fmac_ctrl,				// i-32                                
		                    	                                                                                        		//fmac_ctrl1,				// i-32                               
		.fmac_rxd_en      (fmac_rxd_en),		//i-1, 13jul11                                                          		                    	                                
		                                                                                                                		//fmac_rxd_en	,			//i-1, 13jul11                       
		.mac_pause_value  (mac_pause_value),	// i-32                                                                 		                                                     
		.mac_addr0        (mac_addr0),    		// i-48                                                                 		mac_pause_value,		// i-32                            
		                                                                                                                		//mac_addr0, 				// i-48                               
		.reg_rd_start     (reg_rd_start),		// i-1	                                                                		                                                     
				                                                                                                        		//reg_rd_start,			// i-1	                              
		.reg_rd_done_out  (reg_rd_done_out),	// o-1		                                                            		                                                     
		                    	                                                                                        		//reg_rd_done_out,		// i-1		                           
		.FMAC_REGDOUT     (FMAC_REGDOUT),		// o-32                                                                 		                                                     
		.FIFO_OV_IPEND    (FIFO_OV_IPEND)		// o-1                                                                  		FMAC_REGDOUT,			// o-32                              
		                                                                                                                		//FIFO_OV_IPEND			// o-1                               
		);

		
endmodule
