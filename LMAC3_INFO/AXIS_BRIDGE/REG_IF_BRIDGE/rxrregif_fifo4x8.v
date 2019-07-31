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

module rxrregif_fifo4x8 # (parameter WIDTH = 8,         
								DEPTH = 4,
								PTR	= 2 )          

		  (
			input wire reset_,                                   //i,                                                        
			                                                                                                                 
			input  wire 				wrclk,                   //i, Clk for writing data                                   
			input  wire 				wren,                    //i, request to write                                       
			input  wire [WIDTH-1 : 0]	datain,                  //i, Data coming in                                           
			output wire					wrfull,                  //o, indicates fifo is full or not (To avoid overiding)     
			output wire 			 	wrempty,                 //o, indicates fifo is empty or not (to avoid underflow)      
			output wire	[PTR  : 0]		wrusedw,                 //o, number of slots currently in use for writting          
                                                                                                                             
                                                                                                                             
			                                                                                                                 
			input  wire 				rdclk,                   //i, Clk for reading data                                   
			input  wire 				rden,                    //i, Request to read from FIFO                              
			output wire [WIDTH-1 : 0]	dataout,                 //o, Data coming out                                        
			output wire 				rdfull,                  //o, indicates fifo is full or not (To avoid overiding)     
			output wire 					rdempty,             //o, indicates fifo is empty or not (to avoid underflow)    
			output wire [PTR  : 0] 	rdusedw,                     //o, number of slots currently in use for reading           
                                                                                                                             
			                                                                                                                 
			output wire dbg                                      //o,                                                        

);


			
			
asynch_fifo # ( .WIDTH(WIDTH),         
								.DEPTH(DEPTH),
								.PTR(PTR) )          

asynch_fifo		  (
			.reset_(reset_),
			
			.wrclk(wrclk),                                                  // Clk for writing data                                         
			.wren(wren),                                                    // request to write                                             
			.datain(datain),                                               	// Data coming in                                               
			.wrfull(wrfull),                                                // indicates fifo is full or not (To avoid overiding)           
			.wrempty(wrempty),                                             	// indicates fifo is empty or not (to avoid underflow)          
			.wrusedw(wrusedw),                                              // number of slots currently in use for writting                s                                                                                                                                            
                                                                                                                                            
			// Clk for reading data                                           
			.rdclk(rdclk),                                                // Request to read from FIFO                                      
			.rden(rden),                                                  // Data coming out                                                
			.dataout(dataout),                                            // indicates fifo is full or not (To avoid overiding)             
			.rdfull(rdfull),                                              // indicates fifo is empty or not (to avoid underflow)            
			.rdempty(rdempty),                                            // number of slots currently in use for reading                   
			.rdusedw(rdusedw),    

			
			.dbg(dbg)

);			
			
			
			
			
endmodule



