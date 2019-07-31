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

module txdata_fifo1024x256 # (parameter WIDTH = 256,    // considering 8X8 fifo
								DEPTH = 1024,
								PTR	= 10 )          	// 2**10 = 1024 (DEPTH)

		  (
			input  wire 				reset_,
			
			//=== Signals for WRITE
			input  wire 				wrclk,      // Clk for writing data                              
			input  wire 				wren,       // request to write                                     
			input  wire [WIDTH-1 : 0]	datain,     // Data coming in                                 
			output wire					wrfull,     // indicates fifo is full or not (To avoid overiding)
			output wire 			 	wrempty,    // 0- some data is present (atleast 1 data is present)                                            
			output wire	[PTR  : 0]		wrusedw,    // number of slots currently in use for writing                                                                                                         

			//=== Signals for READ
			input  wire 				rdclk,      // Clk for reading data                                
			input  wire 				rden,       // Request to read from FIFO                           
			output wire [WIDTH-1 : 0]	dataout,    // Data coming out                                     
			output wire 				rdfull,     // 1-FIFO IS FULL (DATA AVAILABLE FOR READ is == DEPTH) 
			output wire 				rdempty,    // indicates fifo is empty or not (to avoid underflow)  
			output wire [PTR  : 0] 		rdusedw,    // number of slots currently in use for reading

			//=== Signals for TEST
			output wire dbg

);
			
			
asynch_fifo # ( .WIDTH(WIDTH),         				// considering 1024x256 fifo
								.DEPTH(DEPTH),
								.PTR(PTR) )       	// 2**10 = 1024 (DEPTH)

	asynch_fifo		  (
	
			.reset_		(reset_),
			
			//=== Signals for WRITE
			.wrclk		(wrclk),      // Clk for writing data                              
			.wren		(wren),       // request to write                                     
			.datain		(datain),     // Data coming in                                 
			.wrfull		(wrfull),     // indicates fifo is full or not (To avoid overiding)
			.wrempty	(wrempty),    // 0- some data is present (atleast 1 data is present)                                            
			.wrusedw	(wrusedw),    // number of slots currently in use for writing                                                                                                         
                                                    
			//=== Signals for READ
			.rdclk		(rdclk),      // Clk for reading data                                
			.rden		(rden),       // Request to read from FIFO                           
			.dataout	(dataout),    // Data coming out                                     
			.rdfull		(rdfull),     // 1-FIFO IS FULL (DATA AVAILABLE FOR READ is == DEPTH) 
			.rdempty	(rdempty),    // indicates fifo is empty or not (to avoid underflow)  
			.rdusedw	(rdusedw),    // number of slots currently in use for reading

			//=== Signals for TEST
			.dbg		(dbg)

	);			
						
			
endmodule