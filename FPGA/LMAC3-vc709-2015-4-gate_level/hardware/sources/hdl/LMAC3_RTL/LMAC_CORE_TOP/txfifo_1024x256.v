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

module txfifo_1024x256

(
			aclr,

			wrclk,     	// Clk for writing data  
			wrreq,     	// request to write
			data,       // Data coming in              
			wrfull,    	// indicates fifo is full or not (To avoid overiding)
		                           
            wrusedw,    // number of slots currently in use for writting                

		    rdclk,     	// Clk for reading data 
			rdreq,     	// Request to read from FIFO
			q, 	    	// Data coming out 
			rdempty  	// indicates fifo is empty or not (to avoid underflow)

);


	parameter WIDTH = 256,
			  DEPTH = 1024,
			  PTR	= 10;
			  
			  
			input  wire 				aclr;

			input  wire 				wrclk;      // Clk for writing data  
			input  wire 				wrreq;      // request to write 
			input  wire [WIDTH-1 : 0]	data;   	// Data coming in
			output wire					wrfull; 	// indicates fifo is full or not (To avoid overiding)
            output wire	[PTR  : 0]		wrusedw;	// number of slots currently in use for writting  

		    input  wire 				rdclk;    	// Clk for reading data
			input  wire 				rdreq;    	// Request to read from FIFO 
			output wire [WIDTH-1 : 0]	q; 	    	// Data coming out
			output wire 				rdempty;  	// indicates fifo is empty or not (to avoid underflow) 

            wire		[PTR-1  : 0]	wr_data_count;     // number of slots currently in use for writting  

	assign	wrusedw	=	{1'b0, wr_data_count};
            
txfifo_ip_1024x256	
				//#(.WIDTH ( WIDTH),		  				
				//	  	  .DEPTH (DEPTH),
				//	 	  .PTR	 (PTR) )		  	
 											
	txfifo_ip_1024x256 (
			.srst	(aclr),		
			
			.clk	(wrclk),		// Clk to write data
			.wr_en	(wrreq),	   	// write enable
			.din	(data),			// write data
			.full	(wrfull),		// indicates fifo is full or not (To avoid overiding)
			//.wrempty(),				
			.data_count(wr_data_count),		// wrusedw -number of locations filled in fifo

			//.rd_clk	(rdclk),		// i-1, Clk to read data
			.rd_en	(rdreq),		// i-1, read enable of data FIFO
			.dout	(q),			// Dataout of data FIFO
			//.rdfull	(),				// indicates fifo is full or not (To avoid overiding) (Not used)
			.empty	(rdempty)		// indicates fifo is empty or not (to avoid underflow)
			//.rd_data_count()				

			//.dbg()

		 );			
			
//asynch_fifo	#(.WIDTH ( WIDTH),		  				
//					  	  .DEPTH (DEPTH),
//					 	  .PTR	 (PTR) )		  	
// 											
//	tx_f (
//			.reset_		(~aclr),		
//			        	
//			.wrclk		(wrclk),		// Clk to write data
//			.wren		(wrreq),	   	// write enable
//			.datain		(data),			// write data
//			.wrfull		(wrfull),		// indicates fifo is full or not (To avoid overiding)
//			.wrempty	(),				
//			.wrusedw	(wrusedw),		// wrusedw -number of locations filled in fifo
//                    	
//			.rdclk		(rdclk),		// i-1, Clk to read data
//			.rden		(rdreq),		// i-1, read enable of data FIFO
//			.dataout	(q),			// Dataout of data FIFO
//			.rdfull		(),				// indicates fifo is full or not (To avoid overiding) (Not used)
//			.rdempty	(rdempty),		// indicates fifo is empty or not (to avoid underflow)
//			.rdusedw	(),				
//
//			.dbg		()
//
//		 );
endmodule