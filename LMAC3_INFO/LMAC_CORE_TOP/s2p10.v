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

module s2p10(

	clk,			//i-1, Depends on the speed of the device
	reset_,			//i-1
	            	
	mode_10G,		//i-1, 10-Gbps speed mode
	mode_25G,   	//i-1, 25-Gbps speed mode
	mode_40G,   	//i-1, 40-Gbps speed mode
	mode_50G,   	//i-1, 50-Gbps speed mode
	mode_100G,  	//i-1, 100-Gbps speed mode
	            	
	init_done,  	//i-1, 
	            	
	data_in,    	//i-64, Incoming 64-bit Serial Data from the PHY
	ctrl_in,    	//i-8, Incoming 8-bit Serial Control from the PHY
	            	
	data_out,   	//o-256, 256-bit Output data
	ctrl_out,   	//o-32, 32-bit Output ctrl
	            	
	linkup,			//o-1, to check whether the linkup is established or not
	            	
	x_we,       	//o-1, write enable for the X2C data and ctrl FIFOs
	            	
	x_bcnt_we,  	//o-1, write enable for the X2C byte count FIFO
	x_byte_cnt  	//o-32, byte count data input to the X2C byte count FIFO
);

	input 				clk;                    //i-1, Depends on the speed of the device               
	input 				reset_;                 //i-1                                                   
	                                                                                                    
	input 				mode_10G;               //i-1, 10-Gbps speed mode                               
	input 				mode_25G;               //i-1, 25-Gbps speed mode                               
	input 				mode_40G;               //i-1, 40-Gbps speed mode                               
	input 				mode_50G;               //i-1, 50-Gbps speed mode                               
	input 				mode_100G;              //i-1, 100-Gbps speed mode                              
	                                                                                                    
	input				init_done;              //i-1,                                                  
	                                                                                                    
	input 		[63:0] 	data_in;                //i-64, Incoming 64-bit Serial Data from the PHY        
	input 		[7:0] 	ctrl_in;                //i-8, Incoming 8-bit Serial Control from the PHY       
	                                                                                                    
	output reg		[255:0] data_out;           //o-256, 256-bit Output data                            
	output reg		[31:0] 	ctrl_out;           //o-32, 32-bit Output ctrl                              
	                                                                                                    
	output reg 			linkup;                 //o-1, to check whether the linkup is established or not
	                                                                                                    
	output reg 			x_we;                   //o-1, write enable for the X2C data and ctrl FIFOs     
	                                                                                                    
	output reg 			x_bcnt_we;              //o-1, write enable for the X2C byte count FIFO         
	output reg 	[31:0] 	x_byte_cnt;             //o-32, byte count data input to the X2C byte count FIFO
	
	reg			[63:0]	data_in_dly;            //Delayed data input
	reg			[7:0]	ctrl_in_dly;            //Delayed ctrl input
	
	reg 		[63:0]	dff0, dff1, dff2, dff3;     //Cascading D-flip flop
	reg 		[7:0]	cff0, cff1, cff2, cff3;     //Cascading D-flip flop

	reg 				frame;                      //frame signal used to determine valid input data
	
	reg 				sof,                        //start-of-frame
						sof0,                       //sof at byte 0
						sof4;                       //sof at byte 4
		
	reg 				eof,                        //end-of-frame
						eof0,                       //eof at byte 0
						eof1,                       //eof at byte 1
						eof2,                       //eof at byte 2
						eof3,                       //eof at byte 3
						eof4,                       //eof at byte 4
						eof5,                       //eof at byte 5
						eof6,                       //eof at byte 6
						eof7;                       //eof at byte 7
		
	wire		[255:0]	pdata = {dff0, dff1, dff2, dff3} ;      //256-bit parallel data
	wire		[31:0]	pctrl = {cff0, cff1, cff2, cff3} ;      //32-bit parallel ctrl
	
	reg			[4:0] 	count;                                  //count signal
	
	wire			  	pdet_in;
	reg					pvld;                                   //parallel data valid
	reg					eof_dly1;                               //delayed eof
	
	parameter [255:0] data_def = 256'h0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707;
	parameter [31:0]  ctrl_def = 32'hffff_ffff;
	
	assign pdet_in = (ctrl_in != 8'hff) ? 1'b0 :
					1'b1
					;
		
	always @ (posedge clk) begin
		if (!reset_) begin
			
			data_out 	<= 256'b0;
	        ctrl_out 	<= 32'b0;
	        
	        linkup 		<= 1'b0;
	        
	        x_we 		<= 1'b0;
	        
	        x_bcnt_we 	<= 1'b0;
	        x_byte_cnt 	<= 32'b0;
	        
	        data_in_dly <= 64'b0;
	        ctrl_in_dly <= 8'b0;
	        
	        sof 		<= 1'b0;
	        sof0 		<= 1'b0;
	        sof4 		<= 1'b0;
	        
	        eof 		<= 1'b0;
	        eof0 		<= 1'b0;
	        eof1 		<= 1'b0;
	        eof2 		<= 1'b0;
	        eof3 		<= 1'b0;
	        eof4 		<= 1'b0;
	        eof5 		<= 1'b0;
	        eof6 		<= 1'b0;
	        eof7 		<= 1'b0;
	        
	        count 		<= 5'd0;
	        frame		<= 1'b0;
	        pvld		<= 1'b0;
	        eof_dly1	<= 1'b0;
		end
		else begin
			data_in_dly <= data_in;	        
			ctrl_in_dly <= ctrl_in;
			
			sof <= (((data_in[7:0] == 8'hfb) & ctrl_in[0]) | ((data_in[39:32] == 8'hfb) & ctrl_in[4])) ? 1'b1 :			//assign high when data is fb and ctrl is 1 at byte 0 or byte 4 of the data
				1'b0
				;
			
			sof0 <= ((data_in[07:00] == 8'hfb) & ctrl_in[0]);       //high when sof at byte 0
			sof4 <= ((data_in[39:32] == 8'hfb) & ctrl_in[4]);       //high when sof at byte 4
			
			eof <= (((data_in[07:00] == 8'hfd) & ctrl_in[0])|       //high when the fd is one any of the bytes and the ctrl is high
                   ((data_in[15:08] == 8'hfd) & ctrl_in[1])|
                   ((data_in[23:16] == 8'hfd) & ctrl_in[2])|
                   ((data_in[31:24] == 8'hfd) & ctrl_in[3])|
                   ((data_in[39:32] == 8'hfd) & ctrl_in[4])|
                   ((data_in[47:40] == 8'hfd) & ctrl_in[5])|
                   ((data_in[55:48] == 8'hfd) & ctrl_in[6])|
                   ((data_in[63:56] == 8'hfd) & ctrl_in[7]))
                   ;
                   
			frame <= (((data_in[7:0] == 8'hfb) & ctrl_in[0]) | ((data_in[39:32] == 8'hfb) & ctrl_in[4])) ? 1'b1 :      //goes high when there is sof
					(eof) ? 1'b0 :                                                                                     //goes low when there is eof
					frame
					;
			
			eof_dly1 <= eof;
					
			if (mode_10G) begin
				eof0 <= ((data_in[07:00] == 8'hfd) & ctrl_in[0]);       //high when eof at byte 0
				eof1 <= ((data_in[15:08] == 8'hfd) & ctrl_in[1]);       //high when eof at byte 1
				eof2 <= ((data_in[23:16] == 8'hfd) & ctrl_in[2]);       //high when eof at byte 2
				eof3 <= ((data_in[31:24] == 8'hfd) & ctrl_in[3]);       //high when eof at byte 3
				eof4 <= ((data_in[39:32] == 8'hfd) & ctrl_in[4]);       //high when eof at byte 4
				eof5 <= ((data_in[47:40] == 8'hfd) & ctrl_in[5]);       //high when eof at byte 5
				eof6 <= ((data_in[55:48] == 8'hfd) & ctrl_in[6]);       //high when eof at byte 6
				eof7 <= ((data_in[63:56] == 8'hfd) & ctrl_in[7]);       //high when eof at byte 7
				
				count <= (eof) ? 5'd3 :
						(frame & count != 5'h0)? (count - 5'h1) :       //counter to count up to 4, to get the get 256=64*4
						5'h3 ;
						
				x_byte_cnt[15:0] <= (sof0) ? 16'd8 :                    //byte count of every packet
							(sof4) ? 23'd4 :
							(eof0) ? x_byte_cnt[15:0] + 16'd1 :
							(eof1) ? x_byte_cnt[15:0] + 16'd2 :
							(eof2) ? x_byte_cnt[15:0] + 16'd3 :
							(eof3) ? x_byte_cnt[15:0] + 16'd4 :
							(eof4) ? x_byte_cnt[15:0] + 16'd5 :
							(eof5) ? x_byte_cnt[15:0] + 16'd6 :
							(eof6) ? x_byte_cnt[15:0] + 16'd7 :
							(frame) ? x_byte_cnt[15:0] + 16'd8 :
							x_byte_cnt[15:0];
							
				x_byte_cnt[31:24] <= (sof0) ? 8'h01 :                   //MSB bit shows the X2C module whether the packet starts with sof0 or sof4
								(sof4) ? 8'h02 :
								x_byte_cnt[31]
								;
								
				x_byte_cnt[23:16] <= 8'b0;
							
				x_bcnt_we <= (eof & frame);                             //write byte count after done counting
				 
			end
			
			pvld <= (!eof & count == 5'd1);
			x_we <= (frame) ? (pvld | eof) :
					1'b0
					;
			
			casez ({pvld, eof})                                         
			
				2'b1?: begin                                            //write pdata and pctrl if pvld is 1
					data_out <= (frame) ? ((eof0|eof1|eof2|eof3) ? {32'h0707_0707,pdata[223:0]} :
											pdata) :
							data_def;
					ctrl_out <= (frame) ? ((eof0|eof1|eof2|eof3) ? {4'hf,pctrl[27:0]} :
											pctrl) :
							ctrl_def;
				end
				
				2'b01: begin                                            //if there an eof write the data and ctrl based on the count
					data_out <= (frame) ? ((count == 5'd1) ? ((eof0|eof1|eof2|eof3) ? {64'h0707_0707_0707_0707, {32'h0707_0707,dff0[31:0]}, dff1, dff2} : 
															{64'h0707_0707_0707_0707, dff0, dff1, dff2}):
								(count == 5'd2) ? ((eof0|eof1|eof2|eof3) ? {128'h0707_0707_0707_0707_0707_0707_0707_0707, {32'h0707_0707,dff0[31:0]}, dff1} : 
															{128'h0707_0707_0707_0707_0707_0707_0707_0707, dff0, dff1}) :
								(count == 5'd3) ? ((eof0|eof1|eof2|eof3) ? {192'h0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707, {32'h0707_0707,dff0[31:0]}} :
															{192'h0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707_0707, dff0}) :
								data_out) : 
								data_def
								;
					ctrl_out <= (frame) ? ((count == 5'd1) ? ((eof0|eof1|eof2|eof3) ? {8'hff, {4'hf,cff0[3:0]}, cff1, cff2} :
															{8'hff, cff0, cff1, cff2}) :
								(count == 5'd2) ? ((eof0|eof1|eof2|eof3) ? {16'hff_ff, cff0, cff1} :
															{16'hff_ff, cff0, cff1}) :
								(count == 5'd3) ? ((eof0|eof1|eof2|eof3) ? {24'hff_ff_ff, {4'hf,cff0[3:0]}} :
															{24'hff_ff_ff, cff0}) :
								ctrl_out) :
								ctrl_def
								;
				end
								
				default : begin
					data_out <= data_def;
					ctrl_out <= ctrl_def;	
				end
			
			endcase
		end
	end
	
	
	//Cascading D-FlipFlops
	always @ (posedge clk) begin
		if(!reset_) begin
			dff0 <= 256'b0;
			dff1 <= 256'b0; 
			dff2 <= 256'b0; 
			dff3 <= 256'b0;
			
			cff0 <= 32'b0; 
			cff1 <= 32'b0; 
			cff2 <= 32'b0; 
			cff3 <= 32'b0;
		end
		else begin
			dff0 <= data_in;
			dff1 <= dff0;
			dff2 <= dff1;
			dff3 <= dff2;
			
			cff0 <= ctrl_in;                  
            cff1 <= cff0;
            cff2 <= cff1;
            cff3 <= cff2;
        end
	end

	
//---------------------------------------	
//Linkup Logic
//---------------------------------------
parameter [2:0]
	LINK_FAIL = 3'h1,
	LINK_RCVR = 3'h2,
	LINK_GOOD = 3'h4;
reg [2:0] state;
reg [4:0] link_cnt;
	
reg				link_bad;
reg				link_ok;
wire			link_fault;
assign			link_fault = !init_done || (data_in_dly[39:32] == 8'h9C && ctrl_in_dly[4] == 1'b1) || 
										   (data_in_dly[7:0]   == 8'h9C && ctrl_in_dly[0] == 1'b1);
										   
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
		link_cnt <= 5'd25;
	end
	
	else
	begin
		case (state)
		LINK_FAIL:
			begin
				state <= link_bad? LINK_FAIL : LINK_RCVR;
				link_cnt <= 5'd25;
			end
			
		LINK_RCVR:
			begin
				state <= link_bad? LINK_FAIL : (link_ok? LINK_GOOD : LINK_RCVR);
				link_cnt <= link_cnt - 5'd1;
			end
			
		LINK_GOOD:
			begin
				state <= link_bad? LINK_FAIL : LINK_GOOD;
				link_cnt <= 5'd25;
			end
			
		default: 
			state <= LINK_FAIL;
		endcase		
	end
end

	
	

endmodule