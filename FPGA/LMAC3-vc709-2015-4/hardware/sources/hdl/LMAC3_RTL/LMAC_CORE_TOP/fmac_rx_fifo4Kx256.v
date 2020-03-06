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
`timescale 1ns/1ps
// synopsys translate_on

module fmac_rx_fifo4Kx256

(
			aclr,
			
			//=== Signals for WRITE
			wrclk,	   	// Clk for writing data                              
			wrreq,  	// Data coming in                                    
			data,    	// request to write                                  
			wrfull,     // indicates fifo is full or not (To avoid overiding)
			wrempty,    // 0- some data is present (atleast 1 data is present)                                            
			wrusedw,    // number of slots currently in use for writing                                                                                                         
                                                    
			//=== Signals for READ
			rdclk,      // Clk for reading data                                
			rdreq, 		// Request to read from FIFO                           
			q,    		// Data coming out                                     
			rdfull,     //  
			rdempty,    // indicates fifo is empty or not (to avoid underflow)  
			rdusedw    	// number of slots currently in use for reading
			
);
parameter 	  WIDTH = 256,
			  DEPTH = 4096,
			  PTR	= 12;
			  
			input  wire 				aclr;
			
			//=== Signals for WRITE
			input  wire 				wrclk;      // Clk for writing data                              
			input  wire 				wrreq;    	// Data coming in                                    
			input  wire [WIDTH-1 : 0]	data;     	// request to write                                  
			output wire					wrfull;     // indicates fifo is full or not (To avoid overiding)
			output wire 			 	wrempty;    // 0- some data is present (atleast 1 data is present)                                            
			output wire	[PTR : 0]		wrusedw;    // number of slots currently in use for writing                                                                                                         
                                                    
			//=== Signals for READ
			input  wire 				rdclk;      // Clk for reading data                                
			input  wire 				rdreq;     	// Request to read from FIFO                           
			output wire [WIDTH-1 : 0]	q;    		// Data coming out                                     
			output wire 				rdfull;     //  
			output wire 				rdempty;    // indicates fifo is empty or not (to avoid underflow)  
			output wire [PTR  : 0] 		rdusedw;   	// number of slots currently in use for reading

			wire		[PTR-1  : 0]	data_count;     // number of slots currently in use for writting  

	assign	wrusedw	=	{1'b0, data_count};
	assign	rdusedw	=	{1'b0, data_count};
	assign	wrempty	=	rdempty;
	assign	rdfull	=	wrfull;
			
			
fmac_rxfifo_ip_4Kx256
			//#(.WIDTH (64),	
			//	  .DEPTH (4096),
			//	  .PTR	 (12) )	
 								
	fmac_rxfifo_ip_4Kx256	  (
			.srst	(aclr),		
			
			.clk	(wrclk),			// Clk to write data
			.wr_en	(wrreq),	      	// write enable                                                
			.din	(data),		  		// write data                                                 
			.full	(wrfull),	      	// indicates fifo is full or not (To avoid overiding)           
			.data_count(data_count),	// wrusedw -number of locations filled in fifo
                                                                                                               
			.rd_en	(rdreq),	     	// i-1, read enable of data FIFO                                    
			.dout	(q),		     	// Dataout of data FIFO                              
			.empty	(rdempty)	    	// indicates fifo is empty or not (to avoid underflow)      

		 );
		 
//asynch_fifo		#(.WIDTH (256),		  	// Making 4kX256 fifo
//				  .DEPTH (4096),      	
//				  .PTR	 (12) )		  	// 2**12 = 4096 (DEPTH)
// 											
//	async	  (
//			.reset_		(~aclr),
//			
//			//=== Signals for WRITE
//			.wrclk		(wrclk),		// Clk to write data
//			.wren		(wrreq),		// write enable
//			.datain		(data),			// write data
//			.wrfull		(wrfull),		// indicates fifo is full or not (To avoid overiding)
//			.wrempty	(wrempty),		// indicates fifo is empty or not (to avoid underflow)
//			.wrusedw	(wrusedw),		// wrusedw -number of locations filled in fifo
//
//
//			//=== Signals for READ
//			.rdclk		(rdclk),		// i-1, Clk to read data
//			.rden		(rdreq),		// i-1, read enable of data FIFO
//			.dataout	(q),			// Dataout of data FIFO
//			.rdfull		(rdfull),		// indicates fifo is full or not (To avoid overiding) (Not used)
//			.rdempty	(rdempty),		// indicates fifo is empty or not (to avoid underflow)
//			.rdusedw	(rdusedw),		// rdusedw -number of locations filled in fifo (not used )
//
//			//=== Signals for TEST
//			.dbg		()
//
//		 );
endmodule