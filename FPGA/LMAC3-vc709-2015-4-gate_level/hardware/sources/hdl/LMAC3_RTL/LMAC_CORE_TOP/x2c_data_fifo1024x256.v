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

module x2c_data_fifo1024x256

(
			aclr,		//i-1                                                      
			                                                                       
			wrclk,      //i-1, Clk for writing data                                
			wrreq,      //i-1, request to write                                    
			data,       //i-256, Data coming in                                    
			full,       //o-1, indicates fifo is full or not (To avoid overiding)  
		                                                                           
			rdclk,	    //i-1, Clk for reading data                                
			rdreq,      //i-1, Request to read from FIFO                           
			q, 	        //o-256, Data coming out                                   
			empty,      //o-1, indicates fifo is empty or not (to avoid underflow) 
			usedw       //o-11, 1number of slots currently in use for reading      

);
	parameter WIDTH = 256,
			  DEPTH = 1024,
			  PTR	= 10;
			  
			  
			input  wire 				aclr;	//i-1  
                                                       
			input  wire 				wrclk;  //i-1, Clk for writing data                               
			input  wire 				wrreq;  //i-1, request to write                                   
			input  wire [WIDTH-1 : 0]	data;   //i-256, Data coming in                                    
			output wire					full;   //o-1, indicates fifo is full or not (To avoid overiding) 
		                                                                                              
			input  wire 				rdclk;  //i-1, Clk for reading data                               
			input  wire 				rdreq;  //i-1, Request to read from FIFO                          
			output wire [WIDTH-1 : 0]	q; 	    //o-256, Data coming out                                   
			output wire 				empty;  //o-1, indicates fifo is empty or not (to avoid underflow)
			output wire [PTR : 0] 		usedw;  //o-11, 1number of slots currently in use for reading      

			wire		[PTR-1  : 0]	data_count;     // number of slots currently in use for writting  

	assign	usedw	=	{1'b0, data_count};
	
	
	x2c_data_fifo_ip_1024x256
						//#(.WIDTH (WIDTH),		  			
//					  	  .DEPTH (DEPTH),
//					 	  .PTR	 (PTR) )
 											
    x2c_data_fifo_ip_1024x256 (
			.srst	(aclr),		
			
			.clk	(wrclk),			// Clk to write data
			.wr_en	(wrreq),	      	// write enable                                                
			.din	(data),		  		// write data                                                 
			.full	(full),	      		// indicates fifo is full or not (To avoid overiding)           
			.data_count(data_count),	// wrusedw -number of locations filled in fifo
                                                                                                               
			.rd_en	(rdreq),	     	// i-1, read enable of data FIFO                                    
			.dout	(q),		     	// Dataout of data FIFO                              
			.empty	(empty)	    		// indicates fifo is empty or not (to avoid underflow)      
		 );			

//asynch_fifo	#(.WIDTH (WIDTH),		  			
//					  	  .DEPTH (DEPTH),
//					 	  .PTR	 (PTR) )		 
// 											
//	asynch_256x64		  (
//			.reset_		(~aclr),
//			        	
//			.wrclk		(wrclk),			//i, Clk to write data                                    	      
//			.wren		(wrreq),	   	    //i, write enable                                                
//			.datain		(data),			    //i, write data                                                  
//			.wrfull		(full),			    //o, indicates fifo is full or not (To avoid overiding)          
//			.wrempty	(),				                                                                     
//			.wrusedw	(),				                                                                     
//                    	                                                                                     
//			.rdclk		(rdclk),		                                                                     
//			.rden		(rdreq),		    // i-1, Clk to read data                                         
//			.dataout	(q),			    // i-1, read enable of data FIFO                                 
//			.rdfull		(),				    // Dataout of data FIFO                                          
//			.rdempty	(empty),		    // indicates fifo is empty or not (to avoid underflow)           
//			.rdusedw	(usedw),		    // rdusedw -number of locations filled in fifo (not used )       
//
//			.dbg		()
//
//		 );
endmodule