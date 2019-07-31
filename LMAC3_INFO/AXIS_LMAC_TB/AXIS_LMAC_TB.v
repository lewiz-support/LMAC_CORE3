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

`timescale 1ns / 1ps

module AXIS_LMAC_TB();

	parameter 				ADDR_WIDTH  = 32;				//default
	parameter 				DATA_WIDTH 	= 256;
	parameter 				CTRL_WIDTH 	= 32;
	parameter 				DATA_PTR 	= 8;
	parameter 				BCNT_WIDTH 	= 64;
	parameter 				BCNT_PTR 	= 2;
	   
	                                 			
	// Clocks and Reset                             		
	reg 							clk; 		            //1, Depends on speed-modes
	reg 							reset_;                 //1 
	reg 							gen_en_wr;				//start write operation
                                                    		
	reg 							xA_clk;					//1, Depends on speed-modes

	//Tx Main Signals		
	reg								tx_mac_aclk; 			//1, TX clock.
	wire	[DATA_WIDTH-1 : 0]		tx_axis_mac_tdata;		//DATA_WIDTH, Write data.
	wire							tx_axis_mac_tvalid;		//1, Signal to show if the data is valid.
	wire							tx_axis_mac_tlast;		//1, Signal to show the last data byte or quadword.
	wire							tx_axis_mac_tuser;		//1, Error signal.
	wire	[CTRL_WIDTH-1 : 0]		tx_axis_mac_tstrb;		//CTRL_WIDTH, To show how many bytes of the data is valid.
	wire							tx_axis_mac_tready;		//1, Indicates if the slave is ready.
	
	//Tx Sideband Signals	
	wire							tx_ifg_delay;			//1, Control signal for configurable interframe gap
	wire							tx_collision;			//1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	wire							tx_retransmit;			//1, Aborted frame to be retransmitted. 0 in full-duplex mode.
	wire	[31 : 0]				tx_statistics_vector;   //32, A statistics vector that gives information on the last frame transmitted.
	wire							tx_statistics_valid;	//1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.
		
	//Rx Main Signals		
	reg								rx_mac_aclk; 			//1, RX clock.                                     
	wire	[DATA_WIDTH-1 : 0]		rx_axis_mac_tdata;		//DATA_WIDTH, Read data.                          
	wire							rx_axis_mac_tvalid;		//1, Signal to show if the data is valid.          
	wire							rx_axis_mac_tlast;		//1, Signal to show the last data byte or quadword.
	wire							rx_axis_mac_tuser;		//1, Error signal.                                 
	wire	[CTRL_WIDTH-1 : 0]		rx_axis_mac_tstrb;		//CTRL_WIDTH, To show how many bytes of the data is valid.  
	wire							rx_axis_mac_tready;		//1, If 1, Master is ready to accept data.              
	
	//Rx Sideband Signals	
	wire	[27 :  0]				rx_statistics_vector;   //28, A statistics vector that gives information on the last frame transmitted.                                
	wire							rx_statistics_valid;	//1, Asserted at end of frame transmission, indicating that the rx_statistics_vector is valid.                

	
	//cgmii interface
	wire	[DATA_WIDTH-1 : 0]		cgmii_txd;				//DATA_WIDTH
	wire 	[CTRL_WIDTH-1 : 0]		cgmii_txc;				//CTRL_WIDTH
	                    			                		
	wire	[DATA_WIDTH-1 : 0]		cgmii_rxd;				//DATA_WIDTH
	wire 	[CTRL_WIDTH-1 : 0]		cgmii_rxc;				//CTRL_WIDTH
	                    			                    	
	  
	//REG_IF signals                  			                    	
	wire 	[15 : 0]				host_addr_reg; 			//16
	reg 							fail_over; 				//1
	reg 	[31 : 0]				fmac_ctrl; 				//32
	reg 	[31 : 0]				fmac_ctrl1; 			//32
	reg 							fmac_rxd_en; 			//1		                    	
	reg 	[31 : 0]				mac_pause_value; 		//32
	reg 	[47 : 0]				mac_addr0; 				//48
	reg 	[ 3 : 0]				SYS_ADDR; 				//4, system assigned addr for the FMAC
	
	reg								TCORE_MODE;
	
	//rx_pkt_gen_sel
	reg								rx_pkt_gen_sel;			// if 1, rxd and rxc becomes the rx_pkt_gen data. if 0, rxd and rxc is loopback data i.e. txd and txc.
            	
	reg								rx_axis_compatible_mode;
	
    wire	[ 2 : 0]				fmac_speed = 3'b100;	//speed mode initialized to 100Gig.
    														//fmac_speed = 3'b000	-	10G
                                							//fmac_speed = 3'b001	-	25G
                                							//fmac_speed = 3'b010	-	40G
                                							//fmac_speed = 3'b011	-	50G
  															//fmac_speed = 3'b100	-	100G
                                							//fmac_speed = 3'b101	-	RSVD
                                							//fmac_speed = 3'b110	-	RSVD
                                							//fmac_speed = 3'b111	-	RSVD	
    
    
    reg 	[15 : 0] 				address;
    wire 	 	 					reg_rd_start;
    wire 	 	 					reg_rd_done_out;
    wire 	[31 : 0] 				FMAC_REGDOUT;
    reg 							start;
    wire 							rx_axis_filter_tuser;
                                                                          

	axi_stream_master axi_stream_master(

	.clk 					(clk),						//i-1, Depends on speed-modes
	.reset_ 				(reset_),        			//i-1
	.gen_en_wr 				(gen_en_wr),      			//i-1, to initiate the write transaction.

	//Main Signals		
	.tx_mac_aclk 			(tx_mac_aclk), 				//i-1, TX clock.                                     
	.tx_axis_mac_tdata 		(tx_axis_mac_tdata),		//o-DATA_WIDTH, Write data.                          
	.tx_axis_mac_tvalid 	(tx_axis_mac_tvalid),		//o-1, Signal to show if the data is valid.          
	.tx_axis_mac_tlast 		(tx_axis_mac_tlast),		//o-1, Signal to show the last data byte or quadword.
	.tx_axis_mac_tuser 		(tx_axis_mac_tuser),		//o-1, Error signal.                                 
	.tx_axis_mac_tstrb 		(tx_axis_mac_tstrb),		//o-CTRL_WIDTH, To show how many bytes of the data is valid.  
	.tx_axis_mac_tready 	(tx_axis_mac_tready),		//i-1, Indicates if the slave is ready.              
	
	//Sideband Signals	
	.tx_ifg_delay 			(tx_ifg_delay),				//o-1, Control signal for configurable interframe gap                                                           
	.tx_collision 			(tx_collision),				//i-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	.tx_retransmit 			(tx_retransmit),			//i-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	.tx_statistics_vector 	(tx_statistics_vector),   	//i-32,A statistics vector that gives information on the last frame transmitted.                                
	.tx_statistics_valid 	(tx_statistics_valid),		//i-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.                
	
	//Rx Main Signals		
	.rx_mac_aclk 			(rx_mac_aclk), 				//i-1, RX clock.                                     
	.rx_axis_mac_tdata 		(rx_axis_mac_tdata),		//i-DATA_WIDTH, Read data.                          
	.rx_axis_mac_tvalid 	(rx_axis_mac_tvalid),		//i-1, Signal to show if the data is valid.          
	.rx_axis_mac_tlast 		(rx_axis_mac_tlast),		//i-1, Signal to show the last data byte or quadword.
	.rx_axis_mac_tuser 		(rx_axis_mac_tuser),		//i-1, Error signal.                                 
	.rx_axis_mac_tstrb 		(rx_axis_mac_tstrb),		//i-CTRL_WIDTH, To show how many bytes of the data is valid.  
	.rx_axis_mac_tready 	(rx_axis_mac_tready),		//o-1, If 1, Master is ready to accept data.              
	
	//Rx Sideband Signals	
	.rx_statistics_vector 	(rx_statistics_vector),   	//o-32,A statistics vector that gives information on the last frame transmitted.                                
	.rx_statistics_valid 	(rx_statistics_valid),		//o-1, Asserted at end of frame transmission, indicating that the rx_statistics_vector is valid. 
	
	.rx_pkt_gen_sel 		(rx_pkt_gen_sel),			//i     
	
	.host_addr				(host_addr_reg),      		//o-16
	.reg_rd_start			(reg_rd_start),	            //o-1
	.reg_rd_done_out		(reg_rd_done_out),          //i-1
	.mac_regdout			(FMAC_REGDOUT),	            //i-1
	.start					(start),			        //i-1
	.address 				(address),                  //i-16
	
	.test 					()							//o-1 debug

	);
	
	AXIS_LMAC_TOP AXIS_LMAC_TOP(

	.clk 					(clk),			   		   	//i-1, Depends on speed-modes
	.reset_ 				(reset_),             	    //i-1
	
	.gen_en_wr 				(gen_en_wr),      			//i-1, to initiate the write transaction.
	
	.fmac_speed				(fmac_speed),				//i-3, decides the speed_mode
	
	//Signals from AXIS Master
	.tx_mac_aclk 			(tx_mac_aclk), 				//i-1, TX clock.                                            
	.tx_axis_mac_tdata 		(tx_axis_mac_tdata),		//i-DATA_WIDTH, Write data.                                 
	.tx_axis_mac_tvalid		(tx_axis_mac_tvalid),		//i-1, Signal to show if the data is valid.                 
	.tx_axis_mac_tlast 		(tx_axis_mac_tlast),		//i-1, Signal to show the last data byte or quadword.       
	.tx_axis_mac_tuser 		(tx_axis_mac_tuser),		//i-1, Error signal.                                        
	.tx_axis_mac_tstrb 		(tx_axis_mac_tstrb),		//i-CTRL_WIDTH, To show how many bytes of the data is valid.
	.tx_axis_mac_tready 	(tx_axis_mac_tready),		//o-1, Indicates if the slave is ready.                     
	
	.tx_ifg_delay 			(tx_ifg_delay),				//i-1, Control signal for configurable interframe gap                                                           
	.tx_collision 			(tx_collision),			    //o-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	.tx_retransmit 			(tx_retransmit),			//o-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	.tx_statistics_vector 	(tx_statistics_vector),     //o-32,A statistics vector that gives information on the last frame transmitted.                                
	.tx_statistics_valid 	(tx_statistics_valid),      //o-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.                
	
	//Signals to AXIS Master
	.rx_mac_aclk			(rx_mac_aclk),				//i-1, RX clock
	.rx_axis_mac_tdata 		(rx_axis_mac_tdata),		//o-DATA_WIDTH, data signal of bridge module
    .rx_axis_mac_tvalid 	(rx_axis_mac_tvalid),  		//o-1, signal to AXIS master indicating the data is valid
    .rx_axis_mac_tlast 		(rx_axis_mac_tlast),		//o-1, signal to AXIS Master saying end of data
    .rx_axis_mac_tuser 		(rx_axis_mac_tuser),		//o-1, error signal from FMAC
    .rx_axis_filter_tuser 	(rx_axis_filter_tuser),		//o-1, error signal from filter of FMAC
    .rx_axis_mac_tstrb 		(rx_axis_mac_tstrb),		//o-8, Signal indicating valid bytes inside the qword transmitting
    .rx_statistics_vector 	(rx_statistics_vector),		//o-27, information about current frame 
    .rx_statistics_valid 	(rx_statistics_valid),		//o-1, Signal indication the statistics vector is valid
    
	//Signals from AXIS Master
	.rx_axis_mac_tready 	(rx_axis_mac_tready),		//i-1, signal indicating that AXIS master accepted data
	.rx_axis_compatible_mode(rx_axis_compatible_mode),	//i-1, signal to keep tready always one  
	
	//port declaration of FMAC module
	.xA_clk 				(xA_clk),					// i-1, 156.25 Mhz except for 1G should be 125Mhz
	
	//cgmii signals
	.cgmii_txd 				(cgmii_txd),				//o-256
	.cgmii_txc 				(cgmii_txc),				//o-32
	           				     	                	
	.cgmii_rxd 				(cgmii_rxd),				//i-256
	.cgmii_rxc 				(cgmii_rxc),				//i-32
	                                                	
	.host_addr_reg 			(host_addr_reg), 	   		//i-16                                  
	.fail_over				(fail_over),	       		//i-1                                   
	.fmac_ctrl				(fmac_ctrl), 		   		//i-32                                  
	.fmac_ctrl1 			(fmac_ctrl1), 	   			//i-32                                  
	.fmac_rxd_en 			(fmac_rxd_en), 	   			//i-1, 13jul11		                        
	.mac_pause_value 		(mac_pause_value),   		//i-32                                  
	.mac_addr0 				(mac_addr0), 		   		//i-48                                  
	.SYS_ADDR 				(SYS_ADDR),		   			//i-4, system assigned addr for the FMAC
	
	.TCORE_MODE				(TCORE_MODE),				//i-1
	
	.reg_rd_start			(reg_rd_start),          	//i-1
	.reg_rd_done_out		(reg_rd_done_out),          //o-1
	.FMAC_REGDOUT			(FMAC_REGDOUT),	            //o-32
	                    	
	.test 					()					       	//o-1 TEST

	);
	
	
	phy_emulator_100G phy_emulator_100G(
	
	.x_clk 					(xA_clk),					//i-1
	.reset_ 				(reset_),					//i-1
	
	.fmac_speed				(fmac_speed),               //i-3
	                                            		
	.rx_pkt_gen_sel 		(rx_pkt_gen_sel),			//i-1
	
	//cgmii
	.cgmii_txd 				(cgmii_txd),         		//i-256
	.cgmii_txc 				(cgmii_txc),         		//i-32
	                		            		
   	.cgmii_rxd				(cgmii_rxd),				//o-256
   	.cgmii_rxc				(cgmii_rxc),				//o-32 
    
    .test 					()							//o-1 TEST
    
	);

		
	initial begin
	
		clk		 		<=	0;
		tx_mac_aclk		<=	0;
		rx_mac_aclk		<=	0;
		            	  		
		xA_clk 			<=	0;
		
	end

	//clocks for 100G, 50G, 25G: SET FOR DEFAULT
	always #0.64  	clk	 			<= ~clk; 			//781.25 MHz	(#number = period div by 2)
	always #0.64  	tx_mac_aclk		<= ~tx_mac_aclk; 	//781.25 MHz	
	always #0.64	rx_mac_aclk		<= ~rx_mac_aclk; 	//781.25 MHz		
	always #1.28 	xA_clk 			<= ~xA_clk; 		//390.625 MHz	(for 100G, 50G, 25G)

	//clocks for 40G
	//always #0.8	clk	 			<= ~clk; 			//625 MHz		(#number = period div by 2)
	//always #0.8	tx_mac_aclk		<= ~tx_mac_aclk;	//625 MHz	
	//always #0.8	rx_mac_aclk		<= ~rx_mac_aclk; 	//625 MHz	
	//always #1.6 	xA_clk 			<= ~xA_clk; 		//312.50 MHz	(for 40G)

	//clocks for 10G
	//always #1.6	clk	 			<= ~clk; 			//312.50 MHz	(#number = period div by 2)
	//always #1.6	tx_mac_aclk		<= ~tx_mac_aclk;	//312.50 MHz	
	//always #1.6	rx_mac_aclk		<= ~rx_mac_aclk; 	//312.50 MHz	
	//always #3.2 	xA_clk 			<= ~xA_clk; 		//156.25 MHz	(for 10G)

			
	//initialization
	initial begin
	
		reset_ 			<= 0;
		gen_en_wr		<= 0;
		
		rx_pkt_gen_sel	<= 0;
		
		#200 reset_ 	<= 1;
	
	end
	

	initial begin
	
		fail_over			<=	1'b0; 				//1	- bit
		fmac_ctrl			<=	32'h00000808;		//32
		fmac_ctrl1			<=	32'h000005ee;		//32
		fmac_rxd_en			<=	1'b1;				//1		                    	
		mac_pause_value		<=	32'hffff0000;		//32
		mac_addr0			<=	48'h001232004eaf;	//48
		SYS_ADDR			<=	4'h1;				//4
		
		TCORE_MODE			<=	1'b0;	            //1
		
		rx_axis_compatible_mode <= 	1'b1;			//1	
		
		start				<=	1'b1;               //1
		address				<=	16'h1028;			//16
		
	end
	
		
endmodule