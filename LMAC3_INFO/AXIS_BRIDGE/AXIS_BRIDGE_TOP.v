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

module AXIS_BRIDGE_TOP(

	clk,						//i-1, Depends on the speed of the device
	xA_clk,					    //i-1, Depends on the speed of the device
	reset_,        				//i-1
                            	
	//Main Signals		    	
	tx_mac_aclk, 				//i-1, TX clock.                                     
	tx_axis_mac_tdata,			//i-256, Write data.                          
	tx_axis_mac_tvalid,			//i-1, Signal to show if the data is valid.          
	tx_axis_mac_tlast,			//i-1, Signal to show the last data byte or quadword.
	tx_axis_mac_tuser,			//i-1, Error signal.                                 
	tx_axis_mac_tstrb,			//i-32, To show how many bytes of the data is valid.  
	tx_axis_mac_tready,			//o-1, Indicates if the slave is ready.              
	                        	
	//Sideband Signals	    	
	tx_ifg_delay,				//i-1, Control signal for configurable interframe gap                                                           
	tx_collision,				//o-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	tx_retransmit,				//o-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	tx_statistics_vector,   	//o-32,A statistics vector that gives information on the last frame transmitted.                                
	tx_statistics_valid,		//o-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid. 
	
	//Signals to AXIS Master
	rx_mac_aclk,				//i-1, RX clock. 
	rx_axis_mac_tdata,			//o-256 	 data signal of bridge module
    rx_axis_mac_tvalid,  		//o-1 	 signal to AXIS master indicating the data is valid
    rx_axis_mac_tlast,			//o-1 	 signal to AXIS Master saying end of data
    rx_axis_mac_tuser,			//o-1 	 error signal from FMAC
    rx_axis_filter_tuser,		//o-1 	 error signal from filter of FMAC
    rx_axis_mac_tstrb,			//o-32 	 Signal indicating valid bytes inside the qword transmitting
    rx_statistics_vector,		//o-27 	 information about current frame 
    rx_statistics_valid,		//o-1	 Signal indication the statistics vector is valid
    
	//Signals from AXIS Master
	rx_axis_mac_tready,			//i-1	signal indicating that AXIS master accepted data
	rx_axis_compatible_mode,	//i-1    signal to keep tready always one  
	                                            		
	//Signals from FMAC	                        		
	fib_tx_mac_usedw,			//i-13  Bit-wise OR the signal to use it as empty signal 
                                            		
	//Signals to FMAC	                    		
	fib_tx_mac_data,			//o-256	Data in of FMAC for tx path 
	fib_tx_mac_wr,				//o-1	Write enable signal of FMAC FIFO 

	//Signals from FMAC	
	fib_rx_mac_data_empty,		//i-1 	 signal from FMAC saying its FIFO is empty
	fib_rx_mac_pkt_data,		//i-256 	 data signal of FMAC module
    fib_rx_mac_ipcs_empty,  	//i-1 	 signal from IPCS FIFO in FMAC its empty
    fib_rx_mac_ipcs_data,		//i-64 	 data signal of IPCS FIFO from FMAC module
    
	//Signals to FMAC	
	fib_rx_mac_rd, 				//o-1 	 read signal 
	fib_rx_mac_ipcs_rd, 		//o-1 	 read signal 
    
	host_addr_in,				//i-16
	mac_regdout_in,             //i-32
	reg_rd_start_in,            //i-1 
	reg_rd_done_in,             //i-1 
	                                  
	host_addr_out,              //o-16
	mac_regdout_out,            //o-32
	reg_rd_start_out,           //o-1 
	reg_rd_done_out,            //o-1 
    
	test						//o-1 debug

);


	parameter 				ADDR_WIDTH  = 32;						//default
	parameter 				DATA_WIDTH 	= 256;
	parameter				STRB_WIDTH	= 32;
	parameter 				DATA_PTR 	= 10;
	parameter 				BCNT_WIDTH 	= 64;
	parameter 				BCNT_PTR 	= 8;	
	
	input      								clk;			   		//i-1, Depends on the speed of the device
	input									xA_clk;				    //i-1, Depends on the speed of the device
	input      								reset_;             	//i-1
	
	//Main Signals		
	input									tx_mac_aclk; 			//i-1, TX clock.                                     
	input		[DATA_WIDTH-1 : 0]			tx_axis_mac_tdata;		//i-256, Write data.                          
	input									tx_axis_mac_tvalid;		//i-1, Signal to show if the data is valid.          
	input									tx_axis_mac_tlast;		//i-1, Signal to show the last data byte or quadword.
	input									tx_axis_mac_tuser;		//i-1, Error signal.                                 
	input		[STRB_WIDTH-1 : 0]			tx_axis_mac_tstrb;		//i-32, To show how many bytes of the data is valid.  
	output									tx_axis_mac_tready;		//o-1, Indicates if the slave is ready.              
	
	//Sideband Signals	
	input									tx_ifg_delay;			//i-1, Control signal for configurable interframe gap                                                           
	output									tx_collision;			//o-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	output									tx_retransmit;			//o-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	output		[31 : 0]					tx_statistics_vector;   //o-32,A statistics vector that gives information on the last frame transmitted.                                
	output									tx_statistics_valid;	//o-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.  
	
	//Signals to AXIS Master
	input									rx_mac_aclk;	        //i-1, RX clock.    
	output		[DATA_WIDTH - 1:0]			rx_axis_mac_tdata;		//o-256, data signal of bridge module********
	output  								rx_axis_mac_tvalid;		//o-1, signal to AXIS master indicating the data is valid********
	output  								rx_axis_mac_tlast;		//o-1, signal to AXIS Master saying end of data
	output  								rx_axis_mac_tuser;		//o-1, error signal from FMAC
	output  								rx_axis_filter_tuser;	//o-1, error signal from filter of FMAC
	output  	[STRB_WIDTH - 1: 0] 		rx_axis_mac_tstrb;   	//o-32, Signal indicating valid bytes inside the qword transmitting
	output  	[28 - 1: 0]  				rx_statistics_vector;   //o-27, information about current frame 
	output  								rx_statistics_valid;	//o-1, Signal indication the statistics vector is valid
	    
	//Signals from AXIS Master	
	input									rx_axis_mac_tready;		//i-1, signal indicating that AXIS master accepted data
	input       							rx_axis_compatible_mode;//i-1, signal to keep tready always one
	
	input		[15 : 0]					host_addr_in;		    //i-16  
	input		[31 : 0]					mac_regdout_in;		    //i-32  
	input									reg_rd_start_in;	    //i-1   
	input									reg_rd_done_in;	        //i-1   
	     									                                
	output		[15 : 0]					host_addr_out;		    //o-16  
	output		[31 : 0]					mac_regdout_out;	    //o-32  
	output									reg_rd_start_out;	    //o-1   
	output									reg_rd_done_out;        //o-1   
	
	output									test;					//o-1, test              

	//wbcnt to txwbcnt_fifo
	wire		[BCNT_WIDTH-1 :0]	    	wr2_txwbcnt_fifo;		//64, wbcnt value                   
	wire									txwbcnt_wrreq; 			//1, request to write to wr_fifo in bridge		
	wire									txwbcnt_wrempty; 		//1, write data fifo in bridge is empty
	wire									txwbcnt_wrfull;			//1, indicates wr_fifo is full
	wire		[BCNT_PTR : 0]				txwbcnt_wrusedw;		//9,  wrusedw -number of locations filled in fifo
		
	//data to txdata_fifo                
	wire		[DATA_WIDTH-1 : 0] 			wr2_txdata_fifo;		//256, write data to wr_fifo in bridge	
	wire									txdata_wrempty;     	//1, write data fifo in bridge is empty 
	wire									txdata_wrreq;			//1, request to write to wr_fifo in bridge
	wire									txdata_wrfull;			//1, indicates wr_fifo is full
	wire		[DATA_PTR : 0]				txdata_wrusedw;			//11, wrusedw -number of locations filled in fifo
	
	//Signals from Write FIFOs	
	wire									rdempty_wf; 			//1, Empty signal of data FIFO	
	wire									rdempty_wcf;			//1, Empty signal of wrcnt FIFO
	wire		[DATA_WIDTH - 1 : 0]		dataout_wf;				//256, Dataout of data FIFO	 
	wire		[BCNT_WIDTH - 1 : 0]		dataout_wcf;			//64, Dataout of wrcnt FIFO (Byte count)

	//Signals to Write FIFOs	
	wire									rden_wf;				//1	read enable of data FIFO
	wire									rden_wcf;				//1	read enable of wrcnt FIFO
	
	//Signals from FMAC	
	input		[12:0]						fib_tx_mac_usedw;		//i-13  Bit-wise OR the signal to use it as empty signal 
	
	//Signals to FMAC
	output		[DATA_WIDTH - 1 : 0]		fib_tx_mac_data;		//o-256	Data in of FMAC for tx path 
	output									fib_tx_mac_wr;			//o-1	Write enable signal of FMAC FIFO 	
	
	//Signals to Read FIFOs	
	wire		             				wren_rf;					//1	write enable of data FIFO
	wire		              				wren_rcf;					//1	write enable of wrcnt FIFO
	wire		[DATA_WIDTH - 1:0]  		datain_rf;					//256 Datain of data FIFO	 
	wire		[BCNT_WIDTH - 1:0]			datain_rcf;					//64 Datain of wrcnt FIFO
		
	//Signals from Read FIFOs		
	wire									wrempty_rf; 				//1	Empty signal of data FIFO	
	wire									wrempty_rcf;				//1	Empty signal of rdcnt FIFO		
	wire		[10:0]						wrusedw_rf;					//11 Empty signal of rdcnt FIFO		
		
	//Signals from FMAC	
	input		             				fib_rx_mac_data_empty;		//i-1 signal from FMAC saying its Data FIFO is empty
	input 		[DATA_WIDTH - 1:0]			fib_rx_mac_pkt_data;		//i-256 data signal of FMAC module
	input				             		fib_rx_mac_ipcs_empty;		//i-1 signal from IPCS FIFO in FMAC its empty
	input 		[BCNT_WIDTH-1:0]			fib_rx_mac_ipcs_data;		//i-64 data signal of IPCS FIFO from FMAC module
	
	//Signals to FMAC
	output 	 				 				fib_rx_mac_rd; 				//o-1 read signal for FMAC data 
	output 	  								fib_rx_mac_ipcs_rd; 		//o-1 read signal for IPCS data 	
	
	//Signals to Read FIFOs
	wire 									rden_rf;					//1	read enable of data FIFO***********
	wire 									rden_rcf;					//1	read enable of rdcnt FIFO********		                                                            	
		                                                            	
	//Signals from Read FIFOs		                                	
	wire									rdempty_rf;					//1	Empty signal of data FIFO	********
	wire									rdempty_rcf;				//1	Empty signal of rdcnt FIFO************
	wire		[DATA_WIDTH - 1:0]			dataout_rf;					//256 Dataout of data FIFO	************
	wire		[BCNT_WIDTH - 1:0]			dataout_rcf;				//64 Dataout of rdcnt FIFO**************		
		
	//Signals to AXIS Master	
	wire 		[DATA_WIDTH - 1:0]			rx_axis_mac_tdata;			//256 data signal of bridge module********
	wire 		 							rx_axis_mac_tvalid;			//1 signal to AXIS master indicating the data is valid********
	wire 		 							rx_axis_mac_tlast;			//1 signal to AXIS Master saying end of data
	wire 		 							rx_axis_mac_tuser;			//1 error signal from FMAC
	wire 		 							rx_axis_filter_tuser;		//1 error signal from filter of FMAC
	wire 		[STRB_WIDTH-1: 0]		 	rx_axis_mac_tstrb;   		//32 Signal indicating valid bytes inside the qword transmitting
	wire 		[28 - 1: 0]  				rx_statistics_vector;   	//27 information about current frame 
	wire 		 							rx_statistics_valid;		//1 Signal indication the statistics vector is valid
	                                		
	//Signals from AXIS Master      		
	wire									rx_axis_mac_tready;			//1	signal indicating that AXIS master accepted data
	wire       								rx_axis_compatible_mode;    //1 signal to keep tready always one
	
	
	assign	test = 1'b0;
	

	axis2fib_txctrl axis2fib_txctrl(
	
	.clk 					(clk),						//i-1, 390.625MHz
	.reset_					(reset_),        			//i-1
                            	
	//Main Signals		    	
	.tx_mac_aclk 			(tx_mac_aclk), 				//i-1, TX clock.                                     
	.tx_axis_mac_tdata 		(tx_axis_mac_tdata),		//i-256, Write data.                          
	.tx_axis_mac_tvalid 	(tx_axis_mac_tvalid),		//i-1, Signal to show if the data is valid.          
	.tx_axis_mac_tlast 		(tx_axis_mac_tlast),		//i-1, Signal to show the last data byte or quadword.
	.tx_axis_mac_tuser 		(tx_axis_mac_tuser),		//i-1, Error signal.                                 
	.tx_axis_mac_tstrb 		(tx_axis_mac_tstrb),		//i-32, To show how many bytes of the data is valid.  
	.tx_axis_mac_tready 	(tx_axis_mac_tready),		//o-1, Indicates if the slave is ready.              
	                        	
	//Sideband Signals	    	
	.tx_ifg_delay 			(tx_ifg_delay),				//i-1, Control signal for configurable interframe gap                                                           
	.tx_collision 			(tx_collision),				//o-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	.tx_retransmit 			(tx_retransmit),			//o-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	.tx_statistics_vector 	(tx_statistics_vector),   	//o-32,A statistics vector that gives information on the last frame transmitted.                                
	.tx_statistics_valid 	(tx_statistics_valid),		//o-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.                
	                			
	//BCNT to txwbcnt_fifo  	
	.wr2_txwbcnt_fifo 		(wr2_txwbcnt_fifo),			//o-64, wbcnt value 
	.txwbcnt_wrreq 			(txwbcnt_wrreq), 			//o-1, request to write to wr_fifo in bridge		
	.txwbcnt_wrempty 		(txwbcnt_wrempty),  		//i-1, write data fifo in bridge is empty
	.txwbcnt_wrfull 		(txwbcnt_wrfull),			//i-1, indicates wr_fifo is full
	.txwbcnt_wrusedw 		(txwbcnt_wrusedw),			//i-9, wrusedw -number of locations filled in fifo	
	                        	
	//DATA to txdata_fifo   	
	.wr2_txdata_fifo 		(wr2_txdata_fifo),			//o-256, write data to wr_fifo in bridge		
	.txdata_wrreq 			(txdata_wrreq), 			//o-1, request to write to wr_fifo in bridge		
	.txdata_wrempty 		(txdata_wrempty),  			//i-1, write data fifo in bridge is empty
	.txdata_wrfull 			(txdata_wrfull),			//i-1, indicates wr_fifo is full
	.txdata_wrusedw 		(txdata_wrusedw),			//i-11, wrusedw -number of locations filled in fifo	
			                	
	.test 					()							//o-1 debug

	);
	
	
	txdata_fifo1024x256	#(.WIDTH (256),
					  	.DEPTH (1024),
					  	.PTR (10) )
 	txdata_fifo1024x256(
 	
	.reset_					(reset_),
	
	//Signals for WRITE
	.wrclk					(tx_mac_aclk),				// Clk to write data
	.wren					(txdata_wrreq),	    		// write enable
	.datain					(wr2_txdata_fifo),			// write data
	.wrfull					(txdata_wrfull),			// indicates fifo is full or not (To avoid overiding)
	.wrempty				(txdata_wrempty),			// indicates fifo is empty or not (to avoid underflow)
	.wrusedw				(txdata_wrusedw),			// wrusedw -number of locations filled in fifo
                                		                              		
	//Signals for READ      		
	.rdclk					(xA_clk),					// i-1, Clk to read data 125MHz
	.rden					(rden_wf),					// i-1, read enable of data FIFO
	.dataout				(dataout_wf),				// Dataout of data FIFO
	.rdfull					(),							// indicates fifo is full or not (To avoid overiding) (Not used)
	.rdempty				(rdempty_wf),				// indicates fifo is empty or not (to avoid underflow)
	.rdusedw				(),							// rdusedw -number of locations filled in fifo (not used )

	//Signals for TEST
	.dbg					()

	);


	txwbcnt_fifo256x64	#(.WIDTH (64),
					 	.DEPTH (256),
						.PTR (8))
 	txwbcnt_fifo256x64(
 	
	.reset_					(reset_),
	
	//Signals for WRITE
	.wrclk					(tx_mac_aclk),	 			// Clk to write data
	.wren					(txwbcnt_wrreq),			// write enable
	.datain					(wr2_txwbcnt_fifo),			// write data
	.wrfull					(txwbcnt_wrfull),			// indicates fifo is full or not (To avoid overiding)
	.wrempty				(txwbcnt_wrempty),			// indicates fifo is empty or not (to avoid underflow)
	.wrusedw				(txwbcnt_wrusedw),			// wrusedw -number of locations filled in fifo
                                		                                		
	//Signals for READ      		
	.rdclk					(xA_clk),					// Clk to read data	125MHz
	.rden					(rden_wcf),					// Read enable
	.dataout				(dataout_wcf),				// Read data
	.rdfull					(),							// indicates fifo is full or not (To avoid overiding) (Not used)
	.rdempty				(rdempty_wcf),				// indicates fifo is empty or not (to avoid underflow)
	.rdusedw				(),							// rdusedw -number of locations filled in fifo (Not used)
    
	//Signals for TEST
	.dbg					()

	);
		
	
	fib2fmac_txctrl fib2fmac_txctrl(
	
	.clk_fib 				(xA_clk),					//i-1	clock signal at FMAC frequency 125MHz
	.reset_ 				(reset_),					//i-1	global reset signal 	
                                                		                                         		
	//Signals from Write FIFOs	                		
	.rdempty_wf 			(rdempty_wf), 				//i-1	Empty signal of data FIFO	
	.rdempty_wcf 			(rdempty_wcf),				//i-1	Empty signal of wrcnt(byte count) FIFO
	.dataout_wf 			(dataout_wf),				//i-256	Dataout of data FIFO	 
	.dataout_wcf			(dataout_wcf),				//i-64	Dataout of wrcnt FIFO (actual count present in Higher 16 bits)
	                                            		
	//Signals to Write FIFOs
	.rden_wf				(rden_wf),					//o-1	read enable of data FIFO	                		
	.rden_wcf 				(rden_wcf),					//o-1	read enable of wrcnt FIFO  
	                                          		
	//Signals to FMAC	                        		
	.fib_tx_mac_usedw		(fib_tx_mac_usedw),			//i-13, used_word for TX_FIFO
	.fib_mac_data 			(fib_tx_mac_data),			//o-256	Data in of FMAC for tx path 
	.fib_mac_wr 			(fib_tx_mac_wr),			//o-1	Write enable signal of FMAC FIFO 
	
	//TEST signal		                        		
	.test 					() 							//o-1 	debug
		
	);
	
	//Start of AXIS RX code
	fmac2fib_rxctrl fmac2fib_rxctrl(
	
	.clk_fib 				(xA_clk),					//i-1	clock signal at FMAC frequency 125MHz
	.reset_ 				(reset_),					//i-1	global reset signal 	

	//Signals to Read FIFOs	
	.wren_rf 				(wren_rf),					//o-1	write enable of data FIFO
	.wren_rcf 				(wren_rcf),					//o-1	write enable of wrcnt FIFO
	.datain_rf 				(datain_rf),				//o-256	Datain of data FIFO	 
	.datain_rcf 			(datain_rcf),				//o-64	Datain of wrcnt FIFO
	
	//Signals from Read FIFOs		
	.wrempty_rf 			(wrempty_rf), 				//i-1	Empty signal of data FIFO	
	.wrempty_rcf 			(wrempty_rcf),				//i-1	Empty signal of rdcnt FIFO
	.wrusedw_rf 			(wrusedw_rf),				//i-11	write usedword of data FIFO
	
	//Signals from FMAC	
	.fib_rx_mac_data_empty 	(fib_rx_mac_data_empty),	//i-1 	 signal from FMAC saying its FIFO is empty
	.fib_rx_mac_pkt_data 	(fib_rx_mac_pkt_data),		//i-256 	 data signal of FMAC module
    .fib_rx_mac_ipcs_empty 	(fib_rx_mac_ipcs_empty),  	//i-1 	 signal from IPCS FIFO in FMAC its empty
    .fib_rx_mac_ipcs_data 	(fib_rx_mac_ipcs_data),		//i-64 	 data signal of IPCS FIFO from FMAC module
    
	//Signals to FMAC
	.fib_rx_mac_rd 			(fib_rx_mac_rd), 			//o-1 	 read signal 
	.fib_rx_mac_ipcs_rd 	(fib_rx_mac_ipcs_rd), 		//o-1 	 read signal 
	
	//TEST signal	
	.test 					() 							//o-1 	debug	
	
	);
	
	
	rxdata_fifo1024x256  #(.WIDTH (256),
						.DEPTH (1024),
					 	.PTR (10))
					 	
			rxdata_fifo1024x256 (
	
	.reset_					(reset_),
	
	//=== Signals for WRITE
	.wrclk					(xA_clk),					// Clk to write data
	.wren					(wren_rf),					// write enable
	.datain					(datain_rf),				// write data
	.wrfull					(),		 					// indicates fifo is full or not (To avoid overiding) (Not used)
	.wrempty				(wrempty_rf),				// indicates fifo is empty or not (to avoid underflow)
	.wrusedw				(wrusedw_rf),				// wrusedw -number of locations filled in fifo   (Not used)
                                		
                                		
	//=== Signals for READ      		
	.rdclk 					(rx_mac_aclk),				// Clk to read data
	.rden 					(rden_rf),					// Read enable
	.dataout				(dataout_rf),				// Read data
	.rdfull					(),							// indicates fifo is full or not (To avoid overiding)
	.rdempty				(rdempty_rf),				// indicates fifo is empty or not (to avoid underflow)
	.rdusedw				(),							// rdusedw -number of locations filled in fifo

	//=== Signals for TEST
	.dbg					()

	);


	rxrbcnt_fifo256x64  #(.WIDTH (64),
						.DEPTH (256),
						.PTR (8))
						
			rxrbcnt_fifo256x64 (
	
	.reset_					(reset_),
	
	//=== Signals for WRITE
	.wrclk					(xA_clk),		    		// Clk to write data
	.wren					(wren_rcf),					// write enable
	.datain					(datain_rcf),				// write data
	.wrfull					(),		 					// indicates fifo is full or not (To avoid overiding) (Not used)
	.wrempty				(wrempty_rcf),				// indicates fifo is empty or not (to avoid underflow)
	.wrusedw				(),							// wrusedw -number of locations filled in fifo  (Not used)
                                		
                                		
	//=== Signals for READ      		
	.rdclk					(rx_mac_aclk),				// Clk to read data
	.rden					(rden_rcf),					// Read enable
	.dataout				(dataout_rcf),				// Read data
	.rdfull					(),							// indicates fifo is full or not (To avoid overiding)
	.rdempty				(rdempty_rcf),				// indicates fifo is empty or not (to avoid underflow)
	.rdusedw				(),							// rdusedw -number of locations filled in fifo

	//=== Signals for TEST
	.dbg					()

	);
	
	
	
	axis2fib_rxctrl axis2fib_rxctrl(
	
	.rx_mac_aclk 			(rx_mac_aclk),					//i-1	clock signal at AXIS frequency
	.reset_ 				(reset_),						//i-1	global reset signal 	

	//Signals to Read FIFOs	
	.rden_rf 				(rden_rf),						//o-1	read enable of data FIFO
	.rden_rcf 				(rden_rcf),						//o-1	read enable of rdcnt FIFO
	
	
	//Signals from Read FIFOs		
	.rdempty_rf 			(rdempty_rf), 					//i-1	Empty signal of data FIFO	
	.rdempty_rcf 			(rdempty_rcf),					//i-1	Empty signal of rdcnt FIFO
	.dataout_rf 			(dataout_rf),					//i-256	Dataout of data FIFO	
	.dataout_rcf 			(dataout_rcf),					//i-64	Dataout of rdcnt FIFO
	
	
	//Signals to AXIS Master	
	.rx_axis_mac_tdata 		(rx_axis_mac_tdata),			//o-256 	 data signal of bridge module
    .rx_axis_mac_tvalid 	(rx_axis_mac_tvalid),  			//o-1 	 signal to AXIS master indicating the data is valid
    .rx_axis_mac_tlast 		(rx_axis_mac_tlast),			//o-1 	 signal to AXIS Master saying end of data
    .rx_axis_mac_tuser 		(rx_axis_mac_tuser),			//o-1 	 error signal from FMAC
    .rx_axis_filter_tuser 	(rx_axis_filter_tuser),			//o-1 	 error signal from filter of FMAC
    .rx_axis_mac_tstrb 		(rx_axis_mac_tstrb),			//o-32 	 Signal indicating valid bytes inside the qword transmitting
    .rx_statistics_vector 	(rx_statistics_vector),			//o-27 	 information about current frame 
    .rx_statistics_valid 	(rx_statistics_valid),			//o-1	 Signal indication the statistics vector is valid
    
	//Signals from AXIS Master
	.rx_axis_mac_tready 	(rx_axis_mac_tready),			//i-1	signal indicating that AXIS master accepted data
	.rx_axis_compatible_mode (rx_axis_compatible_mode),		//i-1    signal to keep tready always one
	
	//TEST signal	
	.test 					()								//o-1 	debug	
								
	);
	
	
	
	rif_if_bridge rif_if_bridge1(

		.fmac_clk				(xA_clk),           		//i, LMAC clock                                 
		.axis_clk				(clk),              		//i, AXI stream clock                           
		.reset_					(reset_),           		//i, reset                                      
		                                            		                                                
		.host_addr_in			(host_addr_in),     		//i-16, host address coming from AXI master     
		.mac_regdout_in			(mac_regdout_in),   		//i-32, MAC_REGDOUT coming from LMAC            
		.reg_rd_start_in		(reg_rd_start_in),  		//i, start siganl coming from AXI master        
		.reg_rd_done_in			(reg_rd_done_in),   		//i, done signal coming from LMAC               
		                                            		                                                
		.host_addr_out			(host_addr_out),    		//o-16, host address to be sent to the LMAC     
		.mac_regdout_out		(mac_regdout_out),  		//o-32, mac_regdout to be sent to the AXI master
		.reg_rd_start_out		(reg_rd_start_out), 		//o, start signal to be sent to the LMAC        
		.reg_rd_done_out		(reg_rd_done_out)   		//o, done signal to be sent to the AXI master   
								
	);



endmodule