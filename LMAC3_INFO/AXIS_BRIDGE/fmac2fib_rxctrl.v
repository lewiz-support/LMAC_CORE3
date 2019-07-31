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

module fmac2fib_rxctrl(
	clk_fib,										//i-1	Depends on the speed of the device
	reset_,                                         //i-1	global reset signal 	 
	
	            
	//============Signals to Bridge FIFOs ==================
	wren_rf,                                        //o-1	write enable of Bridge data FIFO; data will be transferred from FMAC to bridge only when this signal is 1
	wren_rcf,                                       //o-1	write enable of Bridge wrcnt FIFO; byte count will be transferred from FMAC to bridge only when this signal is 1
	datain_rf,                                      //o-256	Datain of Brige data FIFO	    
	datain_rcf,                                     //o-64	Datain of Bridge wrcnt FIFO
	
	     
	//============Signals from Bridge FIFOs ==================
	wrempty_rf,                                     //i-1	Empty signal of Bridge data FIFO                 
	wrempty_rcf,                                    //i-1	Empty signal of Bridge rdcnt FIFO                
	wrusedw_rf,                        				//i-11	Number of slots used in the Bridge data FIFO
	
	
	//=============Signals from FMAC ============
	fib_rx_mac_data_empty,	                        //i-1 	 signal from FMAC saying its data FIFO is empty 
	fib_rx_mac_pkt_data,	                        //i-256  data signal of FMAC module              
	fib_rx_mac_ipcs_empty,                          //i-1 	 signal from FMAC saying its ipcs FIFO is empty   
	fib_rx_mac_ipcs_data,	                        //i-64 	 data signal of IPCS FIFO from FMAC module
	
	
	//=============Signals to FMAC ============
	fib_rx_mac_rd,                                  //o-1 	 read signal which enables reading of data from the FMAC data FIFO
	fib_rx_mac_ipcs_rd,                             //o-1 	 read signal which enables reading of data from the FMAC ipcs FIFO
	test											//o-1 	debug
	);                                          


parameter DATA_WIDTH = 256;
parameter BCNT_WIDTH = 64;
parameter DATA_PTR = 10;

input clk_fib;
input reset_;

input wrempty_rf;
input wrempty_rcf;
input [DATA_PTR : 0] wrusedw_rf;

input fib_rx_mac_data_empty;
input [DATA_WIDTH - 1 :0] fib_rx_mac_pkt_data;
input fib_rx_mac_ipcs_empty;
input [BCNT_WIDTH - 1 :0] fib_rx_mac_ipcs_data;

output reg fib_rx_mac_rd;
output reg fib_rx_mac_ipcs_rd;
output reg wren_rf;
output reg wren_rcf;
output reg [DATA_WIDTH - 1 : 0] datain_rf;
output reg [BCNT_WIDTH - 1 : 0] datain_rcf;

output reg test;

parameter [2:0] IDLE = 3'd0,           				// Idle state waiting for a condition to set and start the state machine.
				STALL = 3'd1,                       // To stall for one clock cycle because data is available in the next clock cycle.
				RD_BCNT = 3'd2,         			// Calculate number of data transfers to be performed.
				RD_DATA = 3'd3,               		// Transfer data from FMAC data fifo to bridge data fifo.
				END_DATA = 3'd4;     		    	// Transfer last set of data from FMAC data fifo to bridge data fifo and data from FMAC ipcs fifo to bridge ipcs fifo. 

reg [2:0] present_state;

reg [BCNT_WIDTH - 1 : 0] counter;                   // variable that indicates number of transfers to be performed.

reg [BCNT_WIDTH - 1 : 0] datain_rcf_dly;            // delayed datain_rcf

always @(posedge clk_fib)
begin
	if (!reset_)
	begin
		datain_rf <= 0;                             // reset condition
		datain_rcf <= 0;
		fib_rx_mac_rd <= 0;
		fib_rx_mac_ipcs_rd <= 0;
		wren_rf <= 0;
		wren_rcf <= 0;
		counter <= 0;
		datain_rcf_dly <= 0;
		test <= 0;
	end
	else
	begin
		
		// state machine.
		case(present_state)                                           	
		
			IDLE :                                                      // In Idle state, it polls the bridge fifos and FMAC fifos continuously and
			begin                                                       // changes state when bridge data fifo has 960 or more slots available out of
				datain_rf <= 0;                                         // 1024 AND both the FMAC fifos have data (i.e. not empty). 
				datain_rcf <= 0;                                        // It sets read signals to FMAC fifos to 1 allowing to read data from the fifos.
				datain_rcf_dly <= 0;                  					// Next state is Stall.
				counter <= 0;
				wren_rf <= 0;
				wren_rcf <= 0;
				fib_rx_mac_ipcs_rd <= ((wrusedw_rf < 960) && (!fib_rx_mac_data_empty && !fib_rx_mac_ipcs_empty)) ? 1'b1 : 1'b0;
				fib_rx_mac_rd <= ((wrusedw_rf < 960) && (!fib_rx_mac_data_empty && !fib_rx_mac_ipcs_empty)) ? 1'b1 : 1'b0;
			end
			
			STALL :                                                     // Read signal of the FMAC byte count fifo is set to 0 since it is desired to read 
			begin                                                       // byte count once only.                                                           
				fib_rx_mac_ipcs_rd <= 0;                                // Next state is RD_BCNT.                                              
			end                                                         																																					
			
			RD_BCNT :  													// Set write enable of the bridge data fifo to 1. Initialize the counter to byte 
			begin                                                       // count value - 32; as first set of data is being transferred simultaneously.  
				wren_rf <= 1;                                           // Store the byte count value in the delayed data_rcf register. 
				datain_rcf_dly <= fib_rx_mac_ipcs_data[63:32];          // If there are only two sets of data to be transferred then go to End Data state.
				datain_rf <= fib_rx_mac_pkt_data;						// Next state is RD_DATA or END_DATA.
				counter <= fib_rx_mac_ipcs_data[63:48] - 32;
				fib_rx_mac_rd <= ((fib_rx_mac_ipcs_data[63:48] - 32) > 32) ? 1'b1 : 1'b0;	
			end
			
			RD_DATA :                                             		// Transfer data from the FMAC data fifo to the bridge data fifo except the last
			begin                                                       // set of data. Clear the read signal of the FMAC data fifo when the last set of                                                                              	
				datain_rf <= fib_rx_mac_pkt_data;                       // data needs to be transferred.
				datain_rcf <= datain_rcf_dly;                           // Next state is END_DATA.
				counter <= counter - 32;
				fib_rx_mac_rd <= ((counter - 32) > 32) ? 1'b1 : 1'b0;	
			end
			
			END_DATA :                                             		// Transfer the last set of data from FMAC data fifo to bridge data fifo and the
			begin												   		// byte count value from FMAC ipcs fifo to bridge ipcs fifo. 
				fib_rx_mac_rd <= 0;                                		// Next state is IDLE.
				wren_rcf <= 1;                                          
				counter <= 0;
				datain_rf <= fib_rx_mac_pkt_data;
				datain_rcf <= datain_rcf_dly;
			end
		
		endcase
		
	end
end


always @(posedge clk_fib)
begin
	if (!reset_)
		present_state <= IDLE;
	else
	begin
		
		case(present_state)		// state machine that controls transition from one state to another.
		
			IDLE :
				present_state <= ((wrusedw_rf < 960) && (!fib_rx_mac_data_empty && !fib_rx_mac_ipcs_empty)) ? STALL : IDLE;
			
			STALL :
				present_state <= RD_BCNT;
				
			RD_BCNT :
				present_state <= ((fib_rx_mac_ipcs_data[63:48] - 32) > 32) ? RD_DATA : END_DATA;
			
			RD_DATA :
				present_state <= ((counter - 32) > 32) ? RD_DATA : END_DATA;
				
			END_DATA :
				present_state <= IDLE;
			
			default :
				present_state <= IDLE;
		endcase
	end
end
	
//============== Simulation ONLY =======================//		
        //synopsys translate_off
            
        reg [8*8-1:0] ascii_br_state;
        
        always@(present_state)
        begin
            case(present_state)
            IDLE	: 	ascii_br_state = "IDLE";
            STALL	: 	ascii_br_state = "STALL";
            RD_BCNT	: 	ascii_br_state = "RD_BCNT";
            RD_DATA	: 	ascii_br_state = "RD_DATA";
            END_DATA: 	ascii_br_state = "END_DATA";
            endcase
        end
        
        //synopsys translate_on        
		
endmodule