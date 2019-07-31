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

module rx_100G(

	clk,                              	//i-1, Depends on the speed of the device
	reset_,                           	//i-1
	                                  	
	mode_10G,                         	//i-1, 10-Gbps speed mode 
	mode_25G,                         	//i-1, 25-Gbps speed mode 
	mode_40G,                         	//i-1, 40-Gbps speed mode 
	mode_50G,                         	//i-1, 50-Gbps speed mode 
	mode_100G,                        	//i-1, 100-Gbps speed mode
	                                  	
	init_done,                        	//i-1
	                                  	
	data_in,                          	//i-256, 256-bit Input Data
	ctrl_in,                          	//i-32, 32-bit Input Ctrl
	                                  	
	data_out,                         	//o-256, 256-bit Output Data to the BR FIFO
	ctrl_out,                         	//o-40, 42-bit Output Ctrl to the BR FIFO
	                                  	
	x_we,                             	//o-1, Write Data 
	linkup                            	//o-1, Linkup

);

	input clk;                          //i-1, Depends on the speed of the device  
	input reset_;                       //i-1                                      
	                                                                               
	input mode_10G;                     //i-1, 10-Gbps speed mode                  
	input mode_25G;                     //i-1, 25-Gbps speed mode                  
	input mode_40G;                     //i-1, 40-Gbps speed mode                  
	input mode_50G;                     //i-1, 50-Gbps speed mode                  
	input mode_100G;                    //i-1, 100-Gbps speed mode                 
	                                                                               
	input init_done;                    //i-1                                      
	                                                                               
	input [255:0] data_in;              //i-256, 256-bit Input Data                
	input [31:0]  ctrl_in;              //i-32, 32-bit Input Ctrl                  
	                                                                               
	output reg [255:0] data_out;        //o-256, 256-bit Output Data to the BR FIFO
	output reg [39:0] ctrl_out;         //o-40, 40-bit Output Ctrl to the BR FIFO  
	                                                                               
	output reg x_we;                    //o-1, Write Data                          
	output reg linkup;                  //o-1, Linkup                              
	
	reg sof;                            //Start of Frame
	reg eof;                            //End of Frame
	reg frame;                          //Frame Signal shows the Valid Input Data
	reg sof0;                           //Sof at byte 0, 8, 16, 24
	reg sof4;                           //Sof at byte 4, 12, 20, 28
	reg eof0;                           //Eof at byte 0, 8, 16, 24
	reg eof1;                           //Eof at byte 1, 9, 17, 25
	reg eof2;                           //Eof at byte 2, 10, 18, 26
	reg eof3;                           //Eof at byte 3, 11, 19, 27
	reg eof4;                           //Eof at byte 4, 12, 20, 28
	reg eof5;                           //Eof at byte 5, 13, 21, 29
	reg eof6;                           //Eof at byte 6, 14, 22, 30
	reg eof7;                           //Eof at byte 7, 15, 23, 31
	reg eof_dly1;
	
	reg [255:0] data_in_dly1, data_in_dly2;		//Delayed Data by 1 and 2 clock cycles respectively
	reg [31:0] ctrl_in_dly1, ctrl_in_dly2;      //Delayed Ctrl by 1 and 2 clock cycles respectively
	
	reg pre_eof, pre_sof;                       //Shows that there is eof or sof in the next cycle respectively 
	
	parameter [255:0] data_def = 256'h0707070707070707070707070707070707070707070707070707070707070707;
	parameter [31:0] ctrl_def = 32'hffffffff;
	
	always @ (posedge clk) begin
		if(!reset_) begin
			data_out <= 256'd0;
			ctrl_out <= 32'd0;
			x_we <= 1'b0;
			sof0 <= 1'b0;
            sof4 <= 1'b0;
            eof0 <= 1'b0;
            eof1 <= 1'b0;
            eof2 <= 1'b0;
            eof3 <= 1'b0;
            eof4 <= 1'b0;
            eof5 <= 1'b0;
            eof6 <= 1'b0;
            eof7 <= 1'b0;
            frame <= 1'b0;
            data_in_dly1 <= data_def;
            data_in_dly2 <= data_def;
            ctrl_in_dly1 <= ctrl_def;
            ctrl_in_dly2 <= ctrl_def;
            pre_eof <= 1'b0;
            pre_sof <= 1'b0;
            sof <= 1'b0;
            eof <= 1'b0;
            eof_dly1 <= 1'b0;
        end
        else begin
        	
        	data_in_dly1 <= data_in;
        	
            data_in_dly2 <= data_in_dly1;
            
            ctrl_in_dly1 <= ctrl_in;
            
            ctrl_in_dly2 <= ctrl_in_dly1;
            
            sof0 <= ( ((data_in[7:0]     == 8'hfb) && ctrl_in[0])  | ((data_in[71:64]   == 8'hfb) && ctrl_in[8]) |
        			  ((data_in[135:128] == 8'hfb) && ctrl_in[16]) | ((data_in[199:192] == 8'hfb) && ctrl_in[24]) ) ? 1'b1 :
        			  1'b0;
        			  
        	sof4 <= ( ((data_in[39:32]   == 8'hfb) && ctrl_in[4])  | ((data_in[103:96]  == 8'hfb) && ctrl_in[12]) |
        			  ((data_in[167:160] == 8'hfb) && ctrl_in[20]) | ((data_in[231:224] == 8'hfb) && ctrl_in[28]) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof0 <= ( (ctrl_in[0]  & (data_in[7:0]     == 8'hfd)) | (ctrl_in[8]  & (data_in[71:64]   == 8'hfd)) |
        			  (ctrl_in[16] & (data_in[135:128] == 8'hfd)) | (ctrl_in[24] & (data_in[199:192] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof1 <= ( (ctrl_in[1]  & (data_in[15:8]    == 8'hfd)) | (ctrl_in[9]  & (data_in[79:72]   == 8'hfd)) |
        			  (ctrl_in[17] & (data_in[143:136] == 8'hfd)) | (ctrl_in[25] & (data_in[207:200] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof2 <= ( (ctrl_in[2]  & (data_in[23:16]   == 8'hfd)) | (ctrl_in[10] & (data_in[87:80]   == 8'hfd)) |
        			  (ctrl_in[18] & (data_in[151:144] == 8'hfd)) | (ctrl_in[26] & (data_in[215:208] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof3 <= ( (ctrl_in[3]  & (data_in[31:24]   == 8'hfd)) | (ctrl_in[11] & (data_in[95:88]   == 8'hfd)) |
        			  (ctrl_in[19] & (data_in[159:152] == 8'hfd)) | (ctrl_in[27] & (data_in[223:216] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof4 <= ( (ctrl_in[4]  & (data_in[39:32]   == 8'hfd)) | (ctrl_in[13] & (data_in[103:96]  == 8'hfd)) |
        			  (ctrl_in[20] & (data_in[167:160] == 8'hfd)) | (ctrl_in[28] & (data_in[231:224] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof5 <= ( (ctrl_in[5]  & (data_in[47:40]   == 8'hfd)) | (ctrl_in[14] & (data_in[111:104] == 8'hfd)) |
        			  (ctrl_in[21] & (data_in[175:168] == 8'hfd)) | (ctrl_in[29] & (data_in[239:232] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof6 <= ( (ctrl_in[6]  & (data_in[55:48]   == 8'hfd)) | (ctrl_in[15] & (data_in[119:112] == 8'hfd)) |
        			  (ctrl_in[22] & (data_in[183:176] == 8'hfd)) | (ctrl_in[30] & (data_in[247:240] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	eof7 <= ( (ctrl_in[7]  & (data_in[63:56]   == 8'hfd)) | (ctrl_in[16] & (data_in[127:120] == 8'hfd)) |
        			  (ctrl_in[23] & (data_in[191:184] == 8'hfd)) | (ctrl_in[31] & (data_in[255:248] == 8'hfd)) ) ? 1'b1 :
        			  1'b0;
        			  
        	frame <= (sof0|sof4) ? 1'b1 : 
        			((eof & ! sof) ? 1'b0 : 
        			frame);
	
			data_out <= (sof0|sof4|frame) ? data_in_dly2 :
        				data_def
        				;
        	ctrl_out <= (sof0|sof4|frame) ? {4'd0,eof, pre_eof, sof, pre_sof, ctrl_in_dly2} :                    //Add the sof_eof_markers eof, pre_eof, sof and pre_sof before the ctrl data  
        				ctrl_def
        				;		  
        	
        	eof_dly1 <= eof;		  
        			  

        		pre_sof <= ( ((data_in[7:0]  == 8'hfb) && ctrl_in[0])  | ((data_in[71:64]   == 8'hfb) && ctrl_in[8]) |            //Calculate the pre_sof
        			  ((data_in[135:128] == 8'hfb) && ctrl_in[16]) | ((data_in[199:192] == 8'hfb) && ctrl_in[24]) |
        			  ((data_in[39:32]   == 8'hfb) && ctrl_in[4])  | ((data_in[103:96]  == 8'hfb) && ctrl_in[12]) |
        			  ((data_in[167:160] == 8'hfb) && ctrl_in[20]) | ((data_in[231:224] == 8'hfb) && ctrl_in[28]) );
        		pre_eof <= ((frame|sof0|sof4) & ((ctrl_in[0] & (data_in[7:0] == 8'hfd))|(ctrl_in[8]&(data_in[71:64] == 8'hfd)) |    //Calculate the pre_eof
        			  	 (ctrl_in[16] & (data_in[135:128] == 8'hfd)) | (ctrl_in[24] & (data_in[199:192] == 8'hfd)) |
        			  	 (ctrl_in[1]  & (data_in[15:8]    == 8'hfd)) | (ctrl_in[9]  & (data_in[79:72]   == 8'hfd)) |
        			  	 (ctrl_in[17] & (data_in[143:136] == 8'hfd)) | (ctrl_in[25] & (data_in[207:200] == 8'hfd)) |
        			  	 (ctrl_in[2]  & (data_in[23:16]   == 8'hfd)) | (ctrl_in[10] & (data_in[87:80]   == 8'hfd)) |
        			  	 (ctrl_in[18] & (data_in[151:144] == 8'hfd)) | (ctrl_in[26] & (data_in[215:208] == 8'hfd)) |
        			  	 (ctrl_in[3]  & (data_in[31:24]   == 8'hfd)) | (ctrl_in[11] & (data_in[95:88]   == 8'hfd)) |
        			  	 (ctrl_in[19] & (data_in[159:152] == 8'hfd)) | (ctrl_in[27] & (data_in[223:216] == 8'hfd)) |	
        			  	 (ctrl_in[4]  & (data_in[39:32]   == 8'hfd)) | (ctrl_in[13] & (data_in[103:96]  == 8'hfd)) |
        			  	 (ctrl_in[20] & (data_in[167:160] == 8'hfd)) | (ctrl_in[28] & (data_in[231:224] == 8'hfd)) |
        			  	 (ctrl_in[5]  & (data_in[47:40]   == 8'hfd)) | (ctrl_in[14] & (data_in[111:104] == 8'hfd)) |
        			  	 (ctrl_in[21] & (data_in[175:168] == 8'hfd)) | (ctrl_in[29] & (data_in[239:232] == 8'hfd)) |
        			  	 (ctrl_in[6]  & (data_in[55:48]   == 8'hfd)) | (ctrl_in[15] & (data_in[119:112] == 8'hfd)) |
        			   	 (ctrl_in[22] & (data_in[183:176] == 8'hfd)) | (ctrl_in[30] & (data_in[247:240] == 8'hfd)) |
        			  	 (ctrl_in[7]  & (data_in[63:56]   == 8'hfd)) | (ctrl_in[16] & (data_in[127:120] == 8'hfd)) |
        			  	 (ctrl_in[23] & (data_in[191:184] == 8'hfd)) | (ctrl_in[31] & (data_in[255:248] == 8'hfd)) ) );
        		sof <= (sof0 | sof4);
        		eof <= (frame & ( eof0  | eof1 | eof2 | eof3 | eof4 | eof5 | eof6 | eof7 )) ;
        		
        		
        	case({mode_10G, mode_25G, mode_40G, mode_50G, mode_100G})                                   //The write signal for the data changes for the every speed mode
        	
        		5'b10000: begin
        			x_we <= (sof) ? 1'b1 : 
						(eof_dly1 & !frame) ? 1'b0 : 
						x_we ;
        		end
        		
        		5'b01000: begin
        			x_we <= (eof_dly1 | ((data_in_dly2 == data_def) & (ctrl_in_dly2 == ctrl_def))) ? 1'b0 :
        				(frame) ? 1'b1 :
        				1'b0
        				;
        		end
        		
        		5'b00100: begin
        			x_we <= (eof_dly1 | ((data_in_dly2 == data_def) & (ctrl_in_dly2 == ctrl_def))) ? 1'b0 :
        				(frame) ? 1'b1 :
        				1'b0
        				;
        		end
        		
        		5'b00010: begin
        			x_we <= (eof_dly1 | ((data_in_dly2 == data_def) & (ctrl_in_dly2 == ctrl_def))) ? 1'b0 :
        				(frame) ? 1'b1 :
        				1'b0
        				;
        		end
        		
        		5'b00001: begin
        			x_we <= (sof) ? 1'b1 : 
						(eof_dly1 & !frame) ? 1'b0 : 
						x_we ;
        		end
        		
        		default: begin
        			x_we <= 1'b0;
        		end
        	
        	endcase
        	
        end
	end
	
	
//==========================================	
//Linkup Logic
//==========================================	
	
	parameter [2:0]
	LINK_FAIL = 3'h1,
	LINK_RCVR = 3'h2,
	LINK_GOOD = 3'h4;
reg [2:0] state;
reg [4:0] link_cnt;
	
reg				link_bad;
reg				link_ok;
wire			link_fault;
assign			link_fault = !init_done || (data_in_dly1[7:0] == 8'h9C && ctrl_in_dly1[4] == 1'b1) || 
										   (data_in_dly1[39:32]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ||
										   (data_in_dly1[71:64]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ||
										   (data_in_dly1[103:96]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ||
										   (data_in_dly1[135:128]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ||
										   (data_in_dly1[167:160]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ||
										   (data_in_dly1[199:192]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ||
										   (data_in_dly1[231:224]   == 8'h9C && ctrl_in_dly1[0] == 1'b1) ;
										   
always @ (posedge clk) begin
	if (!reset_) begin
		link_ok <= 1'b0;
		link_bad <= 1'b0;
		linkup <= 1'b0;
	end
	else begin
		linkup		<=	state[2];
		link_bad	<=	link_fault;
		link_ok		<=	(link_cnt == 5'd0);
	end
end

always @ (posedge clk)
begin
	if (!reset_)
	begin
		state <= LINK_FAIL;
		link_cnt <= 5'd08;
	end
	
	else
	begin
		case (state)
		LINK_FAIL:
			begin
				state <= link_bad? LINK_FAIL : LINK_RCVR;
				link_cnt <= 5'd08;
			end
			
		LINK_RCVR:
			begin
				state <= link_bad? LINK_FAIL : (link_ok? LINK_GOOD : LINK_RCVR);
				link_cnt <= link_cnt - 5'd1;
			end
			
		LINK_GOOD:
			begin
				state <= link_bad? LINK_FAIL : LINK_GOOD;
				link_cnt <= 5'd08;
			end
			
		default: 
			state <= LINK_FAIL;
		endcase		
	end
end
	
endmodule        		