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

module axis2fib_txctrl (
	clk,						//i-1, Depends on the speed of the device
	reset_,        				//i-1, Active Low
                            	
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
	                			
	//BCNT to txwbcnt_fifo  	
	wr2_txwbcnt_fifo,			//o-64, wbcnt value 
	txwbcnt_wrreq, 				//o-1, request to write to wr_fifo in bridge		
	txwbcnt_wrempty,  			//i-1, write data fifo in bridge is empty
	txwbcnt_wrfull,				//i-1, indicates wr_fifo is full
	txwbcnt_wrusedw,			//i-9, wrusedw -number of locations filled in fifo	
	                        	
	//DATA to txdata_fifo   	
	wr2_txdata_fifo,			//o-256, write data to wr_fifo in bridge		
	txdata_wrreq, 				//o-1, request to write to wr_fifo in bridge		
	txdata_wrempty,  			//i-1, write data fifo in bridge is empty
	txdata_wrfull,				//i-1, indicates wr_fifo is full
	txdata_wrusedw,				//i-11, wrusedw -number of locations filled in fifo	
			                	
	test						//o-1 debug

	);

	parameter 				ADDR_WIDTH  = 32;						//default
	parameter 				DATA_WIDTH 	= 256;
	parameter 				DATA_PTR 	= 10;
	parameter 				BCNT_WIDTH 	= 64;
	parameter 				BCNT_PTR 	= 8;
	
	input      								clk;			   		//i-1, Dpends on the speed of the device
	input      								reset_;             	//i-1
	
	//Main Signals		
	input									tx_mac_aclk; 			//i-1, TX clock.                                     
	input		[DATA_WIDTH-1 : 0]			tx_axis_mac_tdata;		//i-256, Write data.                          
	input									tx_axis_mac_tvalid;		//i-1, Signal to show if the data is valid.          
	input									tx_axis_mac_tlast;		//i-1, Signal to show the last data byte or quadword.
	input									tx_axis_mac_tuser;		//i-1, Error signal.                                 
	input		[31 : 0]					tx_axis_mac_tstrb;		//i-32, To show how many bytes of the data is valid.  
	output	reg								tx_axis_mac_tready;		//o-1, Indicates if the slave is ready.              
	
	//Sideband Signals	
	input									tx_ifg_delay;			//i-1, Control signal for configurable interframe gap                                                           
	output	reg								tx_collision;			//o-1, Asserted by the Ethernet MAC core. Any transmission in progress should be aborted. 0 in full-duplex mode.
	output	reg								tx_retransmit;			//o-1, Aborted frame to be retransmitted. 0 in full-duplex mode.                                                
	output	reg	[31 : 0]					tx_statistics_vector;   //o-32,A statistics vector that gives information on the last frame transmitted.                                
	output	reg								tx_statistics_valid;	//o-1, Asserted at end of frame transmission, indicating that the tx_statistics_vector is valid.                
	
	//wbcnt to txwbcnt_fifo
	output 	reg	[BCNT_WIDTH-1 :0]	    	wr2_txwbcnt_fifo;		//0-64, wbcnt value                   
	output 	reg								txwbcnt_wrreq; 			//o-1, request to write to wr_fifo in bridge		
	input									txwbcnt_wrempty; 		//i-1, write data fifo in bridge is empty
	input									txwbcnt_wrfull;			//i-1, indicates wr_fifo is full
	input		[BCNT_PTR :0]				txwbcnt_wrusedw;		//i-4,  wrusedw -number of locations filled in fifo
		
	//data to txdata_fifo                
	output reg 	[DATA_WIDTH-1 : 0] 			wr2_txdata_fifo;		//o-256, write data to wr_fifo in bridge	
	input      								txdata_wrempty;     	//i-1, write data fifo in bridge is empty 
	output reg								txdata_wrreq;			//o-1, request to write to wr_fifo in bridge
	input									txdata_wrfull;			//i-1, indicates wr_fifo is full
	input		[DATA_PTR : 0]				txdata_wrusedw;			//i-4,  wrusedw -number of locations filled in fifo
	
	output 	  								test;					//o-1 debug
		
	reg			[BCNT_WIDTH-1 : 0]	    	bcnt;                	//Byte count of the transmit data

	//=========== State Machine ===============
	//State Machine for Write
	reg		[4:0] 	axis_wr_state;									//state variable
	
	wire			axis_wr_idle_st;								//Idle State
	wire			axis_wr_data_st;								//Data State
	wire			axis_wr_bcnt_st;								//ByteCount State
		
	parameter [4:0]       
			AXIS_WR_IDLE		= 	5'h1,  
			AXIS_WR_DATA		= 	5'h2, 
			AXIS_WR_BCNT	    = 	5'h4;		
		
	assign	axis_wr_idle_st  = 	axis_wr_state[0];   
	assign  axis_wr_data_st  = 	axis_wr_state[1];
	assign	axis_wr_bcnt_st  =	axis_wr_state[2];             
	    
	
	assign	test = 1'b0;
	
	always @ (posedge clk) begin
		if (!reset_) begin
		
			tx_axis_mac_tready	<=	1'b0;
			bcnt				<=	32'd0;
			txdata_wrreq		<=	1'b0;
			txwbcnt_wrreq		<=	1'b0;
			wr2_txdata_fifo		<=	tx_axis_mac_tdata;
			wr2_txwbcnt_fifo	<=	32'd0;
			
			tx_collision			<=	1'b0;
			tx_retransmit			<=	1'b0;
			tx_statistics_vector	<=	32'b0;   
			tx_statistics_valid		<=	1'b0;
			
		end 
		
		else 			
			case(axis_wr_state)										//State Machine execution
				
				AXIS_WR_IDLE: begin                                 //In Idle state
					tx_axis_mac_tready	<=	(txdata_wrusedw < 16'd960);		//should be able to take atleast one full-sized packet
					bcnt				<=	32'b0;
					txdata_wrreq		<=	1'b0;
					txwbcnt_wrreq		<=	1'b0;
					wr2_txwbcnt_fifo	<=	32'b0;
			    end
			    
			    AXIS_WR_DATA: begin									//In data State
			    									
			    	tx_axis_mac_tready <= (tx_axis_mac_tready & tx_axis_mac_tvalid & tx_axis_mac_tlast) ? 1'b0 :  	//make it zero if last_data
											tx_axis_mac_tready;									      				//Recirculate
									
					if(tx_axis_mac_tready & tx_axis_mac_tvalid) begin						  //Byte Count Calculation
						if (tx_axis_mac_tstrb[23:0] == 24'hffffff) begin
							case(tx_axis_mac_tstrb[31:24])      
							 	8'h01 	: 	bcnt	<=	bcnt + 32'd25;  
							    8'h03 	:	bcnt	<=	bcnt + 32'd26; 
							    8'h07 	:	bcnt	<=	bcnt + 32'd27; 
							    8'h0f 	:	bcnt	<=	bcnt + 32'd28; 
							    8'h1f 	:	bcnt	<=	bcnt + 32'd29; 
							    8'h3f 	:	bcnt	<=	bcnt + 32'd30; 
							    8'h7f 	:	bcnt	<=	bcnt + 32'd31; 
							    8'hff	:	bcnt	<= 	bcnt + 32'd32; 
								default	:	bcnt	<=	bcnt + 32'd24;    
							endcase
						end
						else if(tx_axis_mac_tstrb[15:0] == 16'hffff) begin
							case(tx_axis_mac_tstrb[23:16])
							 	8'h01 	: 	bcnt	<=	bcnt + 32'd17; 
							    8'h03 	:	bcnt	<=	bcnt + 32'd18; 
							    8'h07 	:	bcnt	<=	bcnt + 32'd19; 
							    8'h0f 	:	bcnt	<=	bcnt + 32'd20; 
							    8'h1f 	:	bcnt	<=	bcnt + 32'd21; 
							    8'h3f 	:	bcnt	<=	bcnt + 32'd22; 
							    8'h7f 	:	bcnt	<=	bcnt + 32'd23; 
							    8'hff	:	bcnt	<= 	bcnt + 32'd24; 
								default	:	bcnt	<=	bcnt + 32'd16;
							endcase
						end
						else if(tx_axis_mac_tstrb[7:0] == 8'hff) begin
							case(tx_axis_mac_tstrb[15:8])
								8'h01 	: 	bcnt	<=	bcnt + 32'd9;	
							    8'h03 	:	bcnt	<=	bcnt + 32'd10; 
							    8'h07 	:	bcnt	<=	bcnt + 32'd11; 
							    8'h0f 	:	bcnt	<=	bcnt + 32'd12; 
							    8'h1f 	:	bcnt	<=	bcnt + 32'd13; 
							    8'h3f 	:	bcnt	<=	bcnt + 32'd14; 
							    8'h7f 	:	bcnt	<=	bcnt + 32'd15; 
							    8'hff	:	bcnt	<= 	bcnt + 32'd16; 
							    default	:	bcnt	<=	bcnt + 32'd8;
							endcase
						end
						else begin
							case(tx_axis_mac_tstrb[7:0])
								8'h01 	: 	bcnt	<=	bcnt + 32'd1;
								8'h03 	:	bcnt	<=	bcnt + 32'd2;
								8'h07 	:	bcnt	<=	bcnt + 32'd3;
								8'h0f 	:	bcnt	<=	bcnt + 32'd4;
								8'h1f 	:	bcnt	<=	bcnt + 32'd5;
								8'h3f 	:	bcnt	<=	bcnt + 32'd6;
								8'h7f 	:	bcnt	<=	bcnt + 32'd7;
								8'hff	:	bcnt	<= 	bcnt + 32'd8;
								default	:	bcnt	<=	bcnt + 32'd0;
							endcase
						end  
					
						txdata_wrreq <= (tx_axis_mac_tready & tx_axis_mac_tvalid & !txdata_wrfull) ? 1'b1:		//Write Signal to Data Fifo when tvalid is high
									1'b0;
									
						wr2_txdata_fifo <= (tx_axis_mac_tready & tx_axis_mac_tvalid & !txdata_wrfull) ? tx_axis_mac_tdata :		//Data written in the fifo      
                                       wr2_txdata_fifo;
					end
				end
			 
				AXIS_WR_BCNT: begin									//Byte Count State					
					txwbcnt_wrreq <= (!txwbcnt_wrreq && !txwbcnt_wrfull) ? 1'b1 : 		//Write signal to byte count fifo
							1'b0;
					
					wr2_txwbcnt_fifo <= bcnt;						//ByteCount to be written
							
					txdata_wrreq <= 1'b0;
				end
            
			endcase
	
	end
	
always @ (posedge clk) begin
	if(!reset_) begin
		axis_wr_state <= AXIS_WR_IDLE ; 
	end
	else begin
		if (axis_wr_idle_st)
			axis_wr_state <= (txdata_wrusedw < 16'd960)? AXIS_WR_DATA : AXIS_WR_IDLE;
			
		if (axis_wr_data_st)
			axis_wr_state <= (tx_axis_mac_tlast) ? AXIS_WR_BCNT :
						AXIS_WR_DATA;
							
		if (axis_wr_bcnt_st)
			axis_wr_state <= AXIS_WR_IDLE;
	end
end


//============== Simulation ONLY =======================//
//synopsys translate_off                                  
		                                                         
reg [64*8-1:0] ascii_axis_wr_state;                          
	                                                          
always@(axis_wr_state) begin                                                     
		case(axis_wr_state)                                         
	    	AXIS_WR_IDLE		:  	ascii_axis_wr_state = "AXIS_WR_IDLE";        
			AXIS_WR_DATA		:  	ascii_axis_wr_state = "AXIS_WR_DATA";          
			AXIS_WR_BCNT		:	ascii_axis_wr_state = "AXIS_WR_BCNT";            
		endcase
end	
//synopsys translate_on		                                                       
endmodule	