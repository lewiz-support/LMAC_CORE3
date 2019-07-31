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

module fib2fmac_txctrl(
	clk_fib,			//i-1	clock signal at FMAC frequency
	reset_,				//i-1	global reset signal 	
	
	//Signals from Write FIFOs
	rdempty_wf, 		//i-1	Empty signal of data FIFO	
	rdempty_wcf,		//i-1	Empty signal of wrcnt(byte count) FIFO
	dataout_wf,			//i-256	Dataout of data FIFO	 
	dataout_wcf,		//i-64	Dataout of wrcnt FIFO (actual count present in Higher 16 bits)
	
	//Signals to Write FIFOs
	rden_wf,			//o-1	read enable of data FIFO
	rden_wcf,			//o-1	read enable of wrcnt FIFO
	 
	//Signals to FMAC
	fib_tx_mac_usedw,   //i-13, used_word for TX_FIFO
	fib_mac_data,		//o-256	Data in of FMAC for tx path 
	fib_mac_wr,			//o-1	Write enable signal of FMAC FIFO 
	
	//TEST signal
	test 				//o-1 	debug		

);


parameter DATA_WIDTH = 256;
parameter BCNT_WIDTH = 64;


// PORT DECLARATIONS
input						clk_fib;			//i-1	clock signal at FMAC frequency
input						reset_;				//i-1	global reset signal 	
	                                        	
//Signals from Write FIFOs                  	
input						rdempty_wf; 		//i-1	Empty signal of data FIFO	
input						rdempty_wcf;		//i-1	Empty signal of wrcnt FIFO
input	[DATA_WIDTH - 1 :0]	dataout_wf;			//i-256	Dataout of data FIFO	 
input	[BCNT_WIDTH - 1 :0]	dataout_wcf;		//i-64	Dataout of wrcnt FIFO (Byte count)
	                                        	
//Signals to Write FIFOs                    	
output reg					rden_wf;			//o-1	read enable of data FIFO
output reg					rden_wcf;			//o-1	read enable of wrcnt FIFO

//Signals to FMAC
input	[12 : 0]			fib_tx_mac_usedw;	//i-13, used_word for TX_FIFO
output reg [DATA_WIDTH-1:0] fib_mac_data;		//o-256	Data in of FMAC for tx path 
output reg					fib_mac_wr;			//o-1	Write enable signal of FMAC FIFO 
                                            	
//TEST signal                               	
output						test; 				//o-1 	debug


// Variables
reg 	[DATA_WIDTH - 1 :0] dataout_wf_delay;	//delayed data out signal

reg		[63:0]				byte_cnt;			//store byte_cnt from the BCNT_FIFO
reg 						data_first;			//Signifies the first data for each packet


//State Machine to Control Data Write to FMAC
reg [3:0] wr_state;				//State Variable

wire wr_idle_st ;				//Idle State
wire wr_cnt_st ;				//Count State
wire wr_data_st;				//Data State

parameter [3:0] 
	WR_IDLE		= 4'h1, 		// Idle state
	WR_CNT		= 4'h2,			// Send cnt state
	WR_DATA		= 4'h4; 		// Send data state
	
assign 	wr_idle_st 		= wr_state[0];
assign 	wr_cnt_st 		= wr_state[1];
assign 	wr_data_st		= wr_state[2];

assign 	test = 1'b0;

	always @ (posedge clk_fib) begin
		if(!reset_) begin
			//initialization
			rden_wcf 			<= 1'b0;
			rden_wf  			<= 1'b0;
			fib_mac_data 		<= 256'd0;
			fib_mac_wr 			<= 1'b0;
			dataout_wf_delay	<= 256'd0;
			
			data_first			<= 1'b0;
			byte_cnt			<= 64'b0;
		end
		
		else begin
			
			//delayed data_out (used for shift and write)
			dataout_wf_delay <= dataout_wf;
					
			case(wr_state)
			
				WR_IDLE: begin
					//if DATA and BCNT FIFOs are not empty, start reading out
					rden_wcf		<= (!rdempty_wf & !rdempty_wcf & (fib_tx_mac_usedw < 16'd960));
							    	
					rden_wf			<= (!rdempty_wf & !rdempty_wcf & (fib_tx_mac_usedw < 16'd960));
						
					//initialize	    	
					byte_cnt		<= 64'b0;
					data_first		<= 1'b0;
					fib_mac_wr 		<= 1'b0;
					fib_mac_data	<= 256'b0;
				end
				
				WR_CNT: begin	//for 1 clk
					rden_wcf 		<= 1'b0;
					rden_wf 		<= 1'b1;	//keep reading (assuming atleast 2 Q-QWDs: more than 40 Bytes of data)
					data_first		<= 1'b1;	//signifies the first data for every packet.
				end
				
				WR_DATA: begin
					byte_cnt		<= (data_first)?	(dataout_wcf) :		//if first data, fill in the byte_cnt
										(byte_cnt <= 64'h20)?	64'b0 : 	//if other data, keep decrementing the bcnt.
										(byte_cnt - 64'h20);
						
					//assign data_first to low after one clock. 				
					data_first		<= 1'b0;
					
					fib_mac_wr 		<= (data_first)?	1'b1 :				//if first data, write to TX_FIFO
										(byte_cnt <= 64'h18)?	1'b0  :		//if byte_cnt is less than 'd24, stop writing to the TX_FIFO
										fib_mac_wr;
									
					fib_mac_data	<= (data_first)?	{dataout_wf[191:0], dataout_wcf} :	//if first data, write BCNT and then the pkt_data
										{dataout_wf[191:0], dataout_wf_delay[255:192]};		//otherwise, shift and write the data
						
					//if first data and small pkt(<64 Bytes), stop reading				
					if ((data_first) & (dataout_wcf <= 64'h40)) begin
						rden_wf			<= 1'b0;
					end
					//continue reading if next packets are available: skip IDLE_ST
					else if (!data_first & (byte_cnt <= 64'h18)) begin
						rden_wcf		<= (!rdempty_wf & !rdempty_wcf & (fib_tx_mac_usedw < 16'd960));							    	
						rden_wf			<= (!rdempty_wf & !rdempty_wcf & (fib_tx_mac_usedw < 16'd960));
					end
					//stop reading if byte_cnt is <= 'd96. (2 Q-QWDs (64 Bytes) already read in the first two states.)
					else if ((byte_cnt <= 64'h60) & (!data_first)) begin
						rden_wf			<= 1'b0;					
					end
					
				end
				
				default: begin
					byte_cnt		<= 64'b0;
					rden_wcf		<= 1'b0;
					rden_wf 		<= 1'b0;
					fib_mac_wr 		<= 1'b0;
					fib_mac_data	<= 256'b0;
				end
			endcase
		end						
    end
	
	always @ (posedge clk_fib) begin
		if(!reset_) begin		//go to idle state
			wr_state <= WR_IDLE;
		end
		else begin
			if(wr_idle_st)		//go to count state
				wr_state <= (!rdempty_wf & !rdempty_wcf & (fib_tx_mac_usedw < 16'd960)) ?  WR_CNT :
							WR_IDLE;
				
			if(wr_cnt_st)		//go to data state
				wr_state <= WR_DATA;
						
			if(wr_data_st)		//go to idle state
				wr_state <= (data_first)?	WR_DATA :
							((byte_cnt <= 64'h18)& !rdempty_wf & !rdempty_wcf & (fib_tx_mac_usedw < 16'd960))?	WR_CNT :
							(byte_cnt <= 64'h20)?	WR_IDLE :
							WR_DATA;
		end
	end
	
	
//= Simulation ONLY =//
//synopsys translate_off	
reg [8*8-1:0] ascii_wr_state;
	always @ (wr_state) begin
		case(wr_state)
	    	WR_IDLE: ascii_wr_state = "WR_IDLE";
	    	WR_CNT:	 ascii_wr_state = "WR_CNT";
	    	WR_DATA: ascii_wr_state = "WR_DATA";
		endcase
	end
//synopsys translate_on		
		
				
endmodule
	