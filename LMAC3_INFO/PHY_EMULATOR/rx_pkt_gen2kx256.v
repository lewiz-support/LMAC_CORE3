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


module rx_pkt_gen2kx256  		

(
		data,    	//i-256
		rdaddress,  //i-11 
	    clock,      //i-1  
	    wraddress,  //i-11 
		wren,       //i-1  
	    q           //o-256    

);
		parameter 	DATAWIDTH = 256, ADDRWIDTH = 11, ADDRDEPTH = 2048 ; 
		
		input	 wire  [DATAWIDTH - 1:0]  data;     	//i-256
		input    wire  [ADDRWIDTH - 1:0]  rdaddress;    //i-11
		input    wire                     clock;        //i-1 
		input    wire  [ADDRWIDTH - 1:0]  wraddress;    //i-11
		input    wire                     wren;         //i-1 
		output   wire  [DATAWIDTH - 1:0]  q;            //o-256


                     	
	rx_pkt_gen2kx256_dram_2clk  #(.ADDR_DEPTH(ADDRDEPTH),
	                   .DATA_WIDTH(DATAWIDTH),         	// considering 64-bit data
					   .ADDR_WIDTH(ADDRWIDTH) )         // considering 2048 (2K) RAM size		 
                        	
       dram_data (
			.clk_a(clock),		  			// Clk for PORT A (Write Port)
			.addr_a(wraddress),       		// ADDRESS to which data to be written through PORT A
			.din_a(data),         	  		// DATA to be written
			.en_a(1'b1),          	  		// enables read, write and reset operations through PORT A
			.we_a(wren),          	  		// enables write operation through PORT A (1- WRITE 0- READ)
			.dout_a(),        		  		// read data through PORT A
			
			//=== PORT_B Signals
			.clk_b(clock),					// Clk for PORT B    (Read Port)                                     
			.addr_b(rdaddress),        		// ADDRESS to which data to be written through PORT B     
			.din_b({DATAWIDTH {1'b1}}),	 	// DATA to be written                                     
			.en_b(1'b1),            		// enables read, write and reset operations through PORT B
			.we_b(1'b0),            		// enables write operation through PORT B                 
            .dout_b(q)		   				// read data through PORT B
            );	



endmodule 
