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

module byte_reordering_wrap(

	clk250,    			//i-1
	x_clk,              //i-1
	reset_,             //i-1
	fmac_rxd_en	,	    //i-1

	xaui_mode,          //i-1
	
	x_we,				//i-1
	
	data_in,			//i-256, data	
	ctrl_in,		    //i-40, ctrl-32bits + 8 bits of sof/eof markers
	data_out,		    //o-256
	ctrl_out,           //o-32
	
	init_done,        	//i-1
	br_sof,		        //o-8
	
	RAW_FRAME_CNT,		//o-32	
	rx_auto_clr_en,     //i-1
	linkup              //o-1
	
	);
	
	parameter DATA_WIDTH = 256;
	parameter CTRL_WIDTH = 32;
	
	input clk250;      			//i-1
	input x_clk;                //i-1
	input reset_;               //i-1
	input fmac_rxd_en;          //i-1
	
	input xaui_mode;            //i-1
	input x_we;                 //i-1
	
	input [DATA_WIDTH - 1:0] data_in;   	//i-256, data	                                 
	input [39:0] ctrl_in;                   //i-40, ctrl-32bits + 8 bits of sof/eof markers
	
	output [DATA_WIDTH - 1:0] data_out;     //o-256
	output [CTRL_WIDTH - 1:0] ctrl_out;     //o-32 
	
	input init_done;       			//i-1
	
	output [7:0] br_sof;        	//o-8
	
	output [31:0] RAW_FRAME_CNT;	//o-32	
	
	input		rx_auto_clr_en;   	//i-1
	output 		linkup;             //o-1
	
	wire [DATA_WIDTH - 1:0] data_in_br;
	wire [39:0] 			ctrl_in_br;
	
	wire br_wr_full;
	wire br_rd_empty;
	wire br_rd_en;
	
	wire [10:0] rdusedw_data_br;
	wire [10:0] rdusedw_ctrl_br;
	
	tcore_byte_reordering tcore_byte_reordering(
	.clk250			(clk250),		  		//i-1           
	.x_clk			(x_clk),                //i-1           
	.reset_			(reset_),               //i-1           
	.fmac_rxd_en	(fmac_rxd_en),	        //i-1           
	                                                        
	.xaui_mode		(1'b1),		            //i-1           
	                                                        
	.data_in		(data_in_br),		    //i-256         
	.ctrl_in		(ctrl_in_br),		    //i-32          
	.data_out		(data_out),		        //o-256         
	.ctrl_out		(ctrl_out),             //o-32          
	                                                        
	.br_sof0		(br_sof[0]),		    //o-1, to rxgmii
	.br_sof4		(br_sof[1]),            //o-1, to rxgmii
	.br_sof8		(br_sof[2]),            //o-1, to rxgmii
	.br_sof12		(br_sof[3]),            //o-1, to rxgmii
	.br_sof16		(br_sof[4]),            //o-1, to rxgmii
	.br_sof20		(br_sof[5]),            //o-1, to rxgmii
	.br_sof24		(br_sof[6]),            //o-1, to rxgmii
	.br_sof28		(br_sof[7]),		    //o-1, to rxgmii
	                                                        
	.RAW_FRAME_CNT	(RAW_FRAME_CNT),        //o-32          
		                                                    
	.rx_auto_clr_en	(rx_auto_clr_en),       //i-1           
	.init_done		(init_done),		    //i-1           
	.linkup			(linkup),               //o-1           
	.br_rd_en		(br_rd_en),             //o-1           
	.br_rd_empty	(br_rd_empty),          //i-1           
	.rdusedw_data	(rdusedw_data_br),      //i-11          
	.rdusedw_ctrl	(rdusedw_ctrl_br)		//i-11	         	
	
	);
	
	br_pre_data_fifo1024x256 
		br_pre_data_fifo(                          
		
    			.aclr	(!reset_),     		//i-1                                                      
                                                                                                       
    			.wrclk	(x_clk),            //i-1, Clk for writing data                                
    			.wrreq	(x_we),             //i-1, request to write                                    
    			.data	(data_in),          //i-256, Data coming in                                    
    			.full	(br_wr_full),       //o-1, indicates fifo is full or not (To avoid overiding)  
    		                                                                                           
    			.rdclk	(x_clk),	        //i-1, Clk for reading data                                
    			.rdreq	(br_rd_en),         //i-1, Request to read from FIFO                           
    			.q		(data_in_br), 	    //o-256, Data coming out                                   
    			.empty	(br_rd_empty),      //o-1, indicates fifo is empty or not (to avoid underflow) 
    			.usedw	(rdusedw_data_br)   //o-11, 1number of slots currently in use for reading      
                                          
    );                                    
                                          
    br_pre_ctrl_fifo1024x40 
		br_pre_ctrl_fifo(
		                                     
    			.aclr	(!reset_),			//i-1                                                     
                                                                                                      
    			.wrclk	(x_clk),            //i-1, Clk for writing data                               
    			.wrreq	(x_we),             //i-1, request to write                                   
    			.data	(ctrl_in),          //i-40, Data coming in                                    
    			.full	(br_wr_full),       //o-1, indicates fifo is full or not (To avoid overiding) 
    		                                                                                          
    			.rdclk	(x_clk),	        //i-1, Clk for reading data                               
    			.rdreq	(br_rd_en),         //i-1, Request to read from FIFO                          
    			.q		(ctrl_in_br), 	    //o-40, Data coming out                                   
    			.empty	(br_rd_empty),      //o-1, indicates fifo is empty or not (to avoid underflow)
    			.usedw	(rdusedw_ctrl_br)   //o-1, 1number of slots currently in use for reading      
                                          
    );
    
endmodule                                    