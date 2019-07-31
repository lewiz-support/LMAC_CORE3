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

module memory_wr_module(

	tx_mac_aclk,					//i-1, TX Clock
	reset_,        					//i-1
	mem_axis_wctrl,					//o-16, ctrl signals as output
	mem_axis_wdata,					//o-DATA_WIDTH, write data coming from the memory.
	mem_wr_address					//i-32, address to access the memory
	
	);
	
	parameter ADDR_WIDTH = 32;		//default
	parameter DATA_WIDTH = 256;
	
	input		tx_mac_aclk;		//i, TX Clock
	input		reset_; 			//i, 
	       	
	output		[15 : 0]			mem_axis_wctrl;			//o-1, ctrl signals as output
	output		[DATA_WIDTH-1 : 0]	mem_axis_wdata;			//o, write data coming from the memory.
	
	input		[31 : 0]			mem_wr_address;			//i, address to access the memory
	

	reg 	[31 : 0]			memory_wr_ctrl [0:8191];		//Depth = 2^11 = 2048 for now
	reg 	[DATA_WIDTH-1 : 0] 	memory_wr_data [0:8191];		//Depth = 2^11 = 2048 for now
	
	
	assign  mem_axis_wctrl	=	memory_wr_ctrl [mem_wr_address];
	assign  mem_axis_wdata	=	memory_wr_data [mem_wr_address];

	
	//initial 
	//begin
	//	$readmemh("C:/LMAC3_INFO/AXIS_MASTER/memory_wr_ctrl.txt",memory_wr_ctrl);
	//	$readmemh("C:/LMAC3_INFO/AXIS_MASTER/memory_wr_data.txt",memory_wr_data);
	//end
	
endmodule