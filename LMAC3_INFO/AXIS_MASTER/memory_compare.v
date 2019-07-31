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

module memory_compare(

	rx_mac_aclk,				//i-1, RX Clock
	reset_,        				//i-1, 
	                        	
	axis_rd_done_st,        	//i-1, self check works at every read_done state                             
	   	                    	
	pkt_cnt,					//i-32
	                        	
	rx_axis_mac_tvalid,			//i-1
	rx_axis_mac_tbcnt,          //i-BCNT_WIDTH
	rx_axis_mac_tstrb_reg       //i-BCNT_WIDTH
	
	);

	parameter DATA_WIDTH = 256;
	parameter BCNT_WIDTH = 32;
	
	input 							rx_mac_aclk;					//i, RX Clock
	input							reset_;							//i, 
	
	input							axis_rd_done_st;				//i, self check works at every read_done state
	                                                                                                                                     	
	input		[31 : 0]			pkt_cnt;						//i, number of incoming packets
	
	input							rx_axis_mac_tvalid;				//i   
    input		[BCNT_WIDTH-1 : 0]	rx_axis_mac_tbcnt;
    input		[BCNT_WIDTH-1 : 0]	rx_axis_mac_tstrb_reg;				//i
    
   	reg								axis_rd_done_st_dly1;			//self check works at every read_done state
	                                        
	reg 		[ 63 :  0] 			memory_rd_data [0:16383];		//Depth = 2^11 = 2048 for now
	reg 		[ 7	 :  0]			memory_rd_ctrl [0:16383];		//Depth = 2^11 = 2048 for now
	reg 		[ 63 :  0] 			memory_wr_data [0:16383];		//Depth = 2^11 = 2048 for now
	
	integer							i;								//stores the index to help find the wrong data.
	integer							mem_rd_start_address;			//to store start address for each packet.
	integer							mem_rd_end_address;				//to store end address for each packet.
	
	reg								is_error;						//this signal will show if the packet is received succesfully or error is present.

	
	always @ (posedge rx_mac_aclk)
		axis_rd_done_st_dly1	<=	axis_rd_done_st;
		
		
	
	always @ (rx_axis_mac_tvalid) begin
	
		if (rx_axis_mac_tvalid)
			mem_rd_start_address = mem_rd_end_address;
	
	end

	
	always @ (axis_rd_done_st_dly1) begin

		if (!reset_) begin
		
			mem_rd_start_address	=	0;
			mem_rd_end_address  	=	0;
			i						=	0;
			is_error            	=	1'b0;
		
		end
	
		else if (axis_rd_done_st_dly1) begin

			$readmemh("C:/LMAC3_INFO/AXIS_MASTER/data_received_file.txt", memory_rd_data);			//read memory file at every rd_done_state
			$readmemh("C:/LMAC3_INFO/AXIS_MASTER/ctrl_received_file.txt", memory_rd_ctrl);			//read memory file at every rd_done_state
			$readmemh("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", memory_wr_data);					//read memory file at every rd_done_state
			
			case (rx_axis_mac_tstrb_reg)
			
				32'h0000_0001 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0000_0003 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0000_0007 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0000_01ff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0000_03ff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0000_07ff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0001_ffff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h0003_ffff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;  
				32'h0007_ffff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1;
				32'h01ff_ffff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1; 
				32'h03ff_ffff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1; 
				32'h07ff_ffff 	:	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd1; 
				
				default			: 	mem_rd_end_address	<=	mem_rd_start_address + rx_axis_mac_tbcnt + 32'd2; 
			endcase			
		
		end
		else begin
		
			for (i = mem_rd_start_address; i < mem_rd_end_address; i = i+1) begin
			
				//if first packet, then initialize is_error to zero.
				if (i == mem_rd_start_address)
					is_error = 1'b0;
				
					//display error message if data does not match			
        			case (memory_rd_ctrl[i])
        		      8'hE0 :	if (memory_rd_data[i][7:0] != memory_wr_data[i][7:0]) begin                                                                                                                                                  
        		              		$display("\n**ERROR: Qwadword at index %0d of Packet No.: %0d does not match.", i, pkt_cnt);          
        		              		$display("**Expected Data Qwadword: 64'h%h \tbut, we received: 64'h%h", memory_wr_data[i], memory_rd_data[i]);
        			          		is_error = 1'b1;	                                                                                 
        		              	end                                                   
        		      8'hC0 :	if (memory_rd_data[i][15:0] != memory_wr_data[i][15:0]) begin                                                                                               
        		              		$display("\n**ERROR: Qwadword at index %0d of Packet No.: %0d does not match.", i, pkt_cnt);          
        		              		$display("**Expected Data Qwadword: 64'h%h \tbut, we received: 64'h%h", memory_wr_data[i], memory_rd_data[i]);
        		              		is_error = 1'b1;	                                                                                 
        		              	end        
        		      8'h80 :	if (memory_rd_data[i][23:0] != memory_wr_data[i][23:0]) begin                                                                                               
        		              		$display("\n**ERROR: Qwadword at index %0d of Packet No.: %0d does not match.", i, pkt_cnt);          
        		              		$display("**Expected Data Qwadword: 64'h%h \tbut, we received: 64'h%h", memory_wr_data[i], memory_rd_data[i]);
        		              		is_error = 1'b1;	                                                                                 
        		              	end 
        		      8'h00 :	if (memory_rd_data[i][63:0] != memory_wr_data[i][63:0]) begin                                         
        		              		$display("\n**ERROR: Qwadword at index %0d of Packet No.: %0d does not match.", i, pkt_cnt);                     	
        		              		$display("**Expected Data Qwadword: 64'h%h \tbut, we received: 64'h%h", memory_wr_data[i], memory_rd_data[i]);           	 
        		              		is_error = 1'b1;	                                                                                            	
        		              	end                                                                                                           	
        		      8'h01 :	if (memory_rd_data[i][63:0] != memory_wr_data[i][63:0]) begin                                                  	
        		              		$display("\n**ERROR: Qwadword at index %0d of Packet No.: %0d does not match.", i, pkt_cnt);                     	
        		              		$display("**Expected Data Qwadword: 64'h%h \tbut, we received: 64'h%h", memory_wr_data[i], memory_rd_data[i]);           	
        		              		is_error = 1'b1;	                                                                                            	      
                              	end  
        		      //default: 	is_error = 1'b0;
        		endcase
			end
			
			//if last data, and packet is received successfully then display PASSED message.
			if ((i == mem_rd_end_address) & (is_error == 0))
				$display("\n**PASSED: Packet No.: %0d \tis received as expected.", pkt_cnt);
		
		end
				
	end

endmodule