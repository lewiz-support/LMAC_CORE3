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

module rx_50G(
	
	clk,       		//i-1, Depends on the speed of the device            
	reset_,         //i-1                                                
	                                                                     
	mode_10G,       //i-1, 10-Gbps speed mode                            
	mode_25G,       //i-1, 25-Gbps speed mode                            
	mode_40G,       //i-1, 40-Gbps speed mode                            
	mode_50G,       //i-1, 50-Gbps speed mode                            
	mode_100G,      //i-1, 100-Gbps speed mode                           
	                                                                     
	init_done,      //i-1                                                
	                                                                     
	data_in,        //i-256, 256-bit Input Data                          
	ctrl_in,        //i-32, 32-bit Input Ctrl                            
	data_out,       //o-256, 256-bit Output Data                         
	ctrl_out,       //o-32, 32-bit Output Ctrl                           
	                                                                     
	x_we,           //o-1, Write Data                                    
	x_byte_cnt,     //o-1                                                
	x_bcnt_we,      //o-32                                               
	linkup          //o-1, Linkup                                        

	);
	
	//default parameters
	parameter DATA_WIDTH = 256;
	parameter CTRL_WIDTH = 32;
	parameter data_def = 256'h0707070707070707070707070707070707070707070707070707070707070707;
	parameter ctrl_def = 32'hffffffff;
	
	input 		clk;      		//i-1, Depends on the speed of the device            
	input 		reset_;         //i-1                                                
	      		                                                                     
	input 		mode_10G;       //i-1, 10-Gbps speed mode                            
    input 		mode_25G;       //i-1, 25-Gbps speed mode                            
    input 		mode_40G;       //i-1, 40-Gbps speed mode                            
    input 		mode_50G;       //i-1, 50-Gbps speed mode                            
    input 		mode_100G;      //i-1, 100-Gbps speed mode                           
                                                                                     
    input 		init_done;      //i-1                                                
    
    input 		[DATA_WIDTH - 1:0] data_in;  	//i-256, 256-bit Input Data   
    input 		[CTRL_WIDTH - 1:0] ctrl_in;     //i-32, 32-bit Input Ctrl     
    output reg 	[DATA_WIDTH - 1:0] data_out;    //o-256, 256-bit Output Data  
    output reg 	[CTRL_WIDTH - 1:0] ctrl_out;    //o-32, 32-bit Output Ctrl    
    
    output reg 			x_we;      		//o-1, Write Data               	
(* KEEP = "TRUE" *)    output reg 	[31:0] 	x_byte_cnt;     //o-1                     
    output reg 			x_bcnt_we;      //o-32                    
    output reg 			linkup;         //o-1, Linkup             
    
    reg 		[DATA_WIDTH - 1:0] data_out_50g;
    reg 		[CTRL_WIDTH - 1:0] ctrl_out_50g;
    
    wire 		[DATA_WIDTH - 1:0] data_out_10g;
    wire 		[CTRL_WIDTH - 1:0] ctrl_out_10g;
    
    reg 		[DATA_WIDTH - 1:0] data_in_dly;
    reg 		[CTRL_WIDTH - 1:0] ctrl_in_dly;    
    
    wire 		sof;
	wire 		eof;
	reg 		frame;

	//valid sof
	reg sof0  , sof1  , sof2  , sof3  , sof4  , sof5  , sof6  , sof7  ;
	reg sof0_dly  , sof1_dly  , sof2_dly  , sof3_dly  , sof4_dly  , sof5_dly  , sof6_dly  , sof7_dly  ;
	reg sof_n_eof, eof_dly;

	//all eof
	reg eof0  , eof1  , eof2  , eof3  , eof4  , eof5  , eof6  , eof7  ,
		eof8  , eof9  , eof10 , eof11 , eof12 , eof13 , eof14 , eof15 ,
		eof16 , eof17 , eof18 , eof19 , eof20 , eof21 , eof22 , eof23 ,
		eof24 , eof25 , eof26 , eof27 , eof28 , eof29 , eof30 , eof31 ;
				  	
	reg  	[1:0] count;
	reg  	x_we_50g;
	reg  	x_bcnt_we_50g;
	wire 	x_bcnt_we_10g;
	wire 	x_we_10g;
	
	reg 	linkup_50g;
	wire 	linkup_10g;
	
	wire [31:0] x_byte_cnt_10g;
	reg  [31:0] x_byte_cnt_10g_reg;
	
	reg  [31:0] x_byte_cnt_50g;
	
	//valid sof
	assign sof = (sof0 | sof1 | sof2 | sof3 | sof4 | sof5 | sof6 | sof7 );
	
	//all eof conditions
	assign eof = (eof0  | eof1  | eof2  | eof3  | eof4  | eof5  | eof6  | eof7  |
				  eof8  | eof9  | eof10 | eof11 | eof12 | eof13 | eof14 | eof15 |
				  eof16 | eof17 | eof18 | eof19 | eof20 | eof21 | eof22 | eof23 |
				  eof24 | eof25 | eof26 | eof27 | eof28 | eof29 | eof30 | eof31 );
	
	always @ (posedge clk) begin
		if(!reset_) begin
			data_out		<= data_def;
		    ctrl_out        <= ctrl_def;
			data_in_dly		<= data_in;
		    ctrl_in_dly     <= ctrl_in;
			data_out_50g 	<= data_def;
			ctrl_out_50g 	<= ctrl_def;
			x_we			<= 1'b0;
			x_byte_cnt		<= 32'b0;
			x_bcnt_we		<= 1'b0;
			x_we_50g 		<= 1'b0;
			x_bcnt_we_50g	<= 1'b0;
			linkup			<= 1'b0;
			
			x_byte_cnt_50g	<= 32'b0;
			
			x_byte_cnt_10g_reg	<=	32'b0;
			
			frame			<= 1'b0;
			sof0			<= 1'b0;
			sof1			<= 1'b0;
			sof2			<= 1'b0;
			sof3			<= 1'b0;
			sof4			<= 1'b0;
			sof5			<= 1'b0;
			sof6			<= 1'b0;
			sof7			<= 1'b0;
			
			sof0_dly		<= 1'b0;
			sof1_dly		<= 1'b0;
			sof2_dly		<= 1'b0;
			sof3_dly		<= 1'b0;
			sof4_dly		<= 1'b0;
			sof5_dly		<= 1'b0;
			sof6_dly		<= 1'b0;
			sof7_dly		<= 1'b0;
			
			sof_n_eof		<= 1'b0;
			eof_dly			<= 1'b0;
			
			eof0			<= 1'b0;
			eof1			<= 1'b0;
			eof2			<= 1'b0;
			eof3			<= 1'b0;
			eof4			<= 1'b0;
			eof5			<= 1'b0;
			eof6			<= 1'b0;
			eof7			<= 1'b0;
			eof8			<= 1'b0;
			eof9			<= 1'b0;
			eof10			<= 1'b0;
			eof11			<= 1'b0;
			eof12			<= 1'b0;
			eof13			<= 1'b0;
			eof14			<= 1'b0;
			eof15			<= 1'b0;
			eof16			<= 1'b0;
			eof17			<= 1'b0;
			eof18			<= 1'b0;
			eof19			<= 1'b0;
			eof20			<= 1'b0;
			eof21			<= 1'b0;
			eof22			<= 1'b0;
			eof23			<= 1'b0;
			eof24			<= 1'b0;
			eof25			<= 1'b0;
			eof26			<= 1'b0;
			eof27			<= 1'b0;
			eof28			<= 1'b0;
			eof29			<= 1'b0;
			eof30			<= 1'b0;
			eof31			<= 1'b0;
			
			count			<= 2'b0;
		end
		else begin
		
			    //frame shows valid packet		  
        		frame <= (sof) ? 1'b1 : 
        				 (eof & !sof) ? 1'b0 : 
        				 frame;
        		
		 		//buffer
            	data_in_dly <= data_in;
            	ctrl_in_dly <= ctrl_in;
        		
            	
            	//delay signal			  
            	sof0_dly		<= 	sof0;
				sof1_dly		<= 	sof1;
				sof2_dly		<= 	sof2;
				sof3_dly		<= 	sof3;
				sof4_dly		<= 	sof4;
				sof5_dly		<= 	sof5;
				sof6_dly		<= 	sof6;
				sof7_dly		<= 	sof7;
				
				sof_n_eof 		<=	sof & eof;
				eof_dly 		<=	eof;

		
            if (mode_10G) begin
            
				//valid sof 8'hFB and control.
				sof0 <= ((data_out_10g[7:0]		== 8'hfb) && ctrl_out_10g[0] );
				//below conditions will not come in 10Gig mode
				//sof2 <= ((data_out_10g[71:64]		== 8'hfb) && ctrl_out_10g[8] );
        		//sof4 <= ((data_out_10g[135:128]	== 8'hfb) && ctrl_out_10g[16]);
        		//sof6 <= ((data_out_10g[199:192] 	== 8'hfb) && ctrl_out_10g[24]);
        				  
        		sof1 <= ((data_out_10g[39:32]   == 8'hfb) && ctrl_out_10g[4] );
        		//below conditions will not come in 10Gig mode
        		//sof3 <= ((data_out_10g[103:96]  	== 8'hfb) && ctrl_out_10g[12]);
       			//sof5 <= ((data_out_10g[167:160] 	== 8'hfb) && ctrl_out_10g[20]);
       			//sof7 <= ((data_out_10g[231:224] 	== 8'hfb) && ctrl_out_10g[28]);
        				  
       			//all eof conditions: found only for valid pakets, hence frame (signal high only for valid pakets) is used.
        		eof0  <= (frame & ctrl_out_10g[0]  & (data_out_10g[7:0]     == 8'hfd));
        		eof8  <= (frame & ctrl_out_10g[8]  & (data_out_10g[71:64]   == 8'hfd));
        		eof16 <= (frame & ctrl_out_10g[16] & (data_out_10g[135:128] == 8'hfd));
        		eof24 <= (frame & ctrl_out_10g[24] & (data_out_10g[199:192] == 8'hfd));
            	                 
        		eof1  <= (frame & ctrl_out_10g[1]  & (data_out_10g[15:8]    == 8'hfd));
        		eof9  <= (frame & ctrl_out_10g[9]  & (data_out_10g[79:72]   == 8'hfd));
        		eof17 <= (frame & ctrl_out_10g[17] & (data_out_10g[143:136] == 8'hfd));
        		eof25 <= (frame & ctrl_out_10g[25] & (data_out_10g[207:200] == 8'hfd));
            	                  
        		eof2  <= (frame & ctrl_out_10g[2]  & (data_out_10g[23:16]   == 8'hfd));
        		eof10 <= (frame & ctrl_out_10g[10] & (data_out_10g[87:80]   == 8'hfd));
        		eof18 <= (frame & ctrl_out_10g[18] & (data_out_10g[151:144] == 8'hfd));
        		eof26 <= (frame & ctrl_out_10g[26] & (data_out_10g[215:208] == 8'hfd));
            	                  
        		eof3  <= (frame & ctrl_out_10g[3]  & (data_out_10g[31:24]   == 8'hfd));
        		eof11 <= (frame & ctrl_out_10g[11] & (data_out_10g[95:88]   == 8'hfd));
        		eof19 <= (frame & ctrl_out_10g[19] & (data_out_10g[159:152] == 8'hfd));
        		eof27 <= (frame & ctrl_out_10g[27] & (data_out_10g[223:216] == 8'hfd));
            	                 
        		eof4  <= (frame & ctrl_out_10g[4]  & (data_out_10g[39:32]   == 8'hfd));
        		eof12 <= (frame & ctrl_out_10g[12] & (data_out_10g[103:96]  == 8'hfd));
        		eof20 <= (frame & ctrl_out_10g[20] & (data_out_10g[167:160] == 8'hfd));
        		eof28 <= (frame & ctrl_out_10g[28] & (data_out_10g[231:224] == 8'hfd));
            	                 
        		eof5  <= (frame & ctrl_out_10g[5]  & (data_out_10g[47:40]   == 8'hfd));
        		eof13 <= (frame & ctrl_out_10g[13] & (data_out_10g[111:104] == 8'hfd));
        		eof21 <= (frame & ctrl_out_10g[21] & (data_out_10g[175:168] == 8'hfd));
        		eof29 <= (frame & ctrl_out_10g[29] & (data_out_10g[239:232] == 8'hfd));
            	                  
        		eof6  <= (frame & ctrl_out_10g[6]  & (data_out_10g[55:48]   == 8'hfd));
        		eof14 <= (frame & ctrl_out_10g[14] & (data_out_10g[119:112] == 8'hfd));
        		eof22 <= (frame & ctrl_out_10g[22] & (data_out_10g[183:176] == 8'hfd));
        		eof30 <= (frame & ctrl_out_10g[30] & (data_out_10g[247:240] == 8'hfd));
            	                 
        		eof7  <= (frame & ctrl_out_10g[7]  & (data_out_10g[63:56]   == 8'hfd));
        		eof15 <= (frame & ctrl_out_10g[15] & (data_out_10g[127:120] == 8'hfd));
        		eof23 <= (frame & ctrl_out_10g[23] & (data_out_10g[191:184] == 8'hfd));
        		eof31 <= (frame & ctrl_out_10g[31] & (data_out_10g[255:248] == 8'hfd));
        		            				  
            	//send data to x2c: only sof0 or sof4 for 10G mode			  
            	x_byte_cnt_10g_reg[31:24] <=
            						(sof1_dly) ? 8'h02 :
            						(sof0_dly) ? 8'h01 :
            						x_byte_cnt_10g_reg[31:24]
            						;
				          
				x_byte_cnt_10g_reg[23:16] <= 8'b0;

            	//final output
            	data_out 	<= data_out_10g;
            	ctrl_out 	<= ctrl_out_10g;
            	x_we	 	<= x_we_10g;	
            		
            	x_byte_cnt[31:16]	<= x_byte_cnt_10g_reg[31:16];			
            	x_byte_cnt[15: 0]	<= x_byte_cnt_10g[15:0];		
            		
            	x_bcnt_we	<= x_bcnt_we_10g;
            	linkup		<= linkup_10g;
                       				
            end else begin
			
				//valid sof 8'hFB and control.
				sof0 <= ((data_in[7:0]		== 8'hfb) && ctrl_in[0] );
				sof2 <= ((data_in[71:64]	== 8'hfb) && ctrl_in[8] );
        		sof4 <= ((data_in[135:128]	== 8'hfb) && ctrl_in[16]);
        		sof6 <= ((data_in[199:192] 	== 8'hfb) && ctrl_in[24]);
        				  
        		sof1 <= ((data_in[39:32]   	== 8'hfb) && ctrl_in[4] );
        		sof3 <= ((data_in[103:96]  	== 8'hfb) && ctrl_in[12]);
       			sof5 <= ((data_in[167:160] 	== 8'hfb) && ctrl_in[20]);
       			sof7 <= ((data_in[231:224] 	== 8'hfb) && ctrl_in[28]);
        				  
       			//all eof conditions: found only for valid pakets, hence frame (signal high only for valid pakets) is used.
       			//in slower speed mode (25Gig) count signal is used with frame to give eof only for valid packets.
        		eof0  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[0]  & (data_in[7:0]     == 8'hfd));
        		eof8  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[8]  & (data_in[71:64]   == 8'hfd));
        		eof16 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[16] & (data_in[135:128] == 8'hfd));
        		eof24 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[24] & (data_in[199:192] == 8'hfd));
            	                 
        		eof1  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[1]  & (data_in[15:8]    == 8'hfd));
        		eof9  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[9]  & (data_in[79:72]   == 8'hfd));
        		eof17 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[17] & (data_in[143:136] == 8'hfd));
        		eof25 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[25] & (data_in[207:200] == 8'hfd));
            	                     
        		eof2  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[2]  & (data_in[23:16]   == 8'hfd));
        		eof10 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[10] & (data_in[87:80]   == 8'hfd));
        		eof18 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[18] & (data_in[151:144] == 8'hfd));
        		eof26 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[26] & (data_in[215:208] == 8'hfd));
            	                    
        		eof3  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[3]  & (data_in[31:24]   == 8'hfd));
        		eof11 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[11] & (data_in[95:88]   == 8'hfd));
        		eof19 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[19] & (data_in[159:152] == 8'hfd));
        		eof27 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[27] & (data_in[223:216] == 8'hfd));
            	                 
        		eof4  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[4]  & (data_in[39:32]   == 8'hfd));
        		eof12 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[12] & (data_in[103:96]  == 8'hfd));
        		eof20 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[20] & (data_in[167:160] == 8'hfd));
        		eof28 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[28] & (data_in[231:224] == 8'hfd));
            	                 
        		eof5  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[5]  & (data_in[47:40]   == 8'hfd));
        		eof13 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[13] & (data_in[111:104] == 8'hfd));
        		eof21 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[21] & (data_in[175:168] == 8'hfd));
        		eof29 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[29] & (data_in[239:232] == 8'hfd));
            	                  
        		eof6  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[6]  & (data_in[55:48]   == 8'hfd));
        		eof14 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[14] & (data_in[119:112] == 8'hfd));
        		eof22 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[22] & (data_in[183:176] == 8'hfd));
        		eof30 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[30] & (data_in[247:240] == 8'hfd));
            	                 
        		eof7  <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[7]  & (data_in[63:56]   == 8'hfd));
        		eof15 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[15] & (data_in[127:120] == 8'hfd));
        		eof23 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[23] & (data_in[191:184] == 8'hfd));
        		eof31 <= (frame & ((mode_25G & count[1]) | mode_50G | mode_40G) & ctrl_in[31] & (data_in[255:248] == 8'hfd));
        		
        		
            	//count is used as control which starts from zero at every new packet data.
        		count <= (sof & !frame)? 2'b0 : 	//start
        				 ((mode_25G & (count == 2'd3))|((mode_50G | mode_40G) & (count == 2'b01))) ? 2'b0 :  //reach limit: (2'd3 for 25Gig :: 2'd1 for 50Gig and 40 Gig)
	        			 (frame | eof)? (count + 1) :	//if valid data or last data(eof) then increment count.
	        			 count                      
            			;
            	
            	//fifo write pulse valid data and ctrl. only for one clock hence count is used. (eof & !frame) for last valid data.
            	x_we_50g <= ((frame & (count == 2'b0)) | (eof & !frame))? 1'b1 :
            				1'b0;
            	
            	//data_out and ctrl_out only when valid data and ctrl is present
            	data_out_50g <= (sof | eof | frame) ? data_in_dly :
            					data_out_50g;
            	ctrl_out_50g <= (sof | eof | frame) ? ctrl_in_dly :
            					ctrl_out_50g;
            	            		
            	//bcnt_fifo write pulse at every eof.		
            	x_bcnt_we_50g  <= (x_bcnt_we_50g)? 1'b0 :
            						(eof)? 1'b1 :
            						x_bcnt_we_50g ; 
            	
            	//byte_count calculation.			
            	x_byte_cnt_50g[15:0] <=             			  
            	              (eof & frame & !x_bcnt_we_50g)?  (eof0 )? x_byte_cnt_50g[15:0] + 16'd1  :	
            	              				  (eof1 )? x_byte_cnt_50g[15:0] + 16'd2  :	
            	                    		  (eof2 )? x_byte_cnt_50g[15:0] + 16'd3  :
            	                    		  (eof3 )? x_byte_cnt_50g[15:0] + 16'd4  :
            	                    		  (eof4 )? x_byte_cnt_50g[15:0] + 16'd5  :
            	                    		  (eof5 )? x_byte_cnt_50g[15:0] + 16'd6  :
            	                    		  (eof6 )? x_byte_cnt_50g[15:0] + 16'd7  :
            	                    		  (eof7 )? x_byte_cnt_50g[15:0] + 16'd8  :
            	                    		  (eof8 )? x_byte_cnt_50g[15:0] + 16'd9  :
            	                    		  (eof9 )? x_byte_cnt_50g[15:0] + 16'd10 :
            	                    		  (eof10)? x_byte_cnt_50g[15:0] + 16'd11 :
            	                    		  (eof11)? x_byte_cnt_50g[15:0] + 16'd12 :
            	                    		  (eof12)? x_byte_cnt_50g[15:0] + 16'd13 :
            	                    		  (eof13)? x_byte_cnt_50g[15:0] + 16'd14 :
            	                    		  (eof14)? x_byte_cnt_50g[15:0] + 16'd15 :
            	                    		  (eof15)? x_byte_cnt_50g[15:0] + 16'd16 :
            	                    		  (eof16)? x_byte_cnt_50g[15:0] + 16'd17 :
            	                    		  (eof17)? x_byte_cnt_50g[15:0] + 16'd18 :
            	                    		  (eof18)? x_byte_cnt_50g[15:0] + 16'd19 :
            	                    		  (eof19)? x_byte_cnt_50g[15:0] + 16'd20 :
            	                    		  (eof20)? x_byte_cnt_50g[15:0] + 16'd21 :
            	                    		  (eof21)? x_byte_cnt_50g[15:0] + 16'd22 :
            	                    		  (eof22)? x_byte_cnt_50g[15:0] + 16'd23 :
            	                    		  (eof23)? x_byte_cnt_50g[15:0] + 16'd24 :
            	                    		  (eof24)? x_byte_cnt_50g[15:0] + 16'd25 :
            	                    		  (eof25)? x_byte_cnt_50g[15:0] + 16'd26 :
            	                    		  (eof26)? x_byte_cnt_50g[15:0] + 16'd27 :
            	                    		  (eof27)? x_byte_cnt_50g[15:0] + 16'd28 :
            	                    		  (eof28)? x_byte_cnt_50g[15:0] + 16'd29 :
            	                    		  (eof29)? x_byte_cnt_50g[15:0] + 16'd30 :
            	              				  (eof30)? x_byte_cnt_50g[15:0] + 16'd31 :
            				            	  x_byte_cnt_50g[15:0] + 16'd32 :
            	
            				  (sof & frame)?  (sof0)? 16'd32 :
            	                        	  (sof1)? 16'd28 :
            	                        	  (sof2)? 16'd24 :
            	                        	  (sof3)? 16'd20 :
            	                        	  (sof4)? 16'd16 :
            	                        	  (sof5)? 16'd12 :
            	                        	  (sof6)? 16'd8  :
            	                        	  16'd4 		 :
            	                        
            				  (frame & x_we_50g)? x_byte_cnt_50g[15:0] + 16'd32 :
            				  
            				  (eof)? 16'd0 :
            				  
            				  x_byte_cnt_50g[15:0]; 
            		
            	            				  
            	//send data to x2c			  
            	x_byte_cnt_50g[31:24] <= (sof7_dly) ? 8'h80 :
            						(sof6_dly) ? 8'h40 :
            						(sof5_dly) ? 8'h20 :
            						(sof4_dly) ? 8'h10 :
            						(sof3_dly) ? 8'h08 :
            						(sof2_dly) ? 8'h04 :
            						(sof1_dly) ? 8'h02 :
            						(sof0_dly) ? 8'h01 :
            						x_byte_cnt_50g[31:24]
            						;
				
            	//if sof and eof in same data
				x_byte_cnt_50g[23] <= (sof_n_eof) ? 1'b1 :
										(eof_dly) ? 1'b0 :
										x_byte_cnt_50g[23];  
				          
				x_byte_cnt_50g[22:16] <= 8'b0;
			            
				
            	//final output
            	data_out 	<= data_out_50g;
            	ctrl_out 	<= ctrl_out_50g;
            	x_we	 	<= x_we_50g;		
            	x_byte_cnt	<= x_byte_cnt_50g;			
            	x_bcnt_we	<= x_bcnt_we_50g;
            	linkup		<= linkup_50g;
            
            end
  		            			
        end
	end
	
parameter [2:0]
	LINK_FAIL = 3'h1,
	LINK_RCVR = 3'h2,
	LINK_GOOD = 3'h4;
reg [2:0] state;
reg [4:0] link_cnt;
	
reg				link_bad;
reg				link_ok;
wire			link_fault;
assign			link_fault = !init_done || (data_in_dly[7:0] == 8'h9C && ctrl_in_dly[4] == 1'b1) || 
										   (data_in_dly[39:32]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ||
										   (data_in_dly[71:64]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ||
										   (data_in_dly[103:96]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ||
										   (data_in_dly[135:128]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ||
										   (data_in_dly[167:160]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ||
										   (data_in_dly[199:192]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ||
										   (data_in_dly[231:224]   == 8'h9C && ctrl_in_dly[0] == 1'b1) ;
										   
always @ (posedge clk) begin
	if (!reset_) begin
		link_ok <= 1'b0;
		link_bad <= 1'b0;
		linkup_50g <= 1'b0;
	end
	else begin
		linkup_50g		<=	state[2];
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
	
	s2p10 s2p10(

		.clk		(clk),        		//i-1, Depends on the speed of the device               
		.reset_		(reset_),           //i-1                                                   
		                                                                                        
		.mode_10G	(mode_10G),         //i-1, 10-Gbps speed mode                               
		.mode_25G	(mode_25G),         //i-1, 25-Gbps speed mode                               
		.mode_40G	(mode_40G),         //i-1, 40-Gbps speed mode                               
		.mode_50G	(mode_50G),         //i-1, 50-Gbps speed mode                               
		.mode_100G	(mode_100G),        //i-1, 100-Gbps speed mode                              
		                                                                                        
		.init_done	(1'b1),             //i-1,                                                  
		                                                                                        
		.data_in	(data_in[63:0]),    //i-64, Incoming 64-bit Serial Data from the PHY        
		.ctrl_in	(ctrl_in[7:0]),     //i-8, Incoming 8-bit Serial Control from the PHY       
		                                                                                        
		.data_out	(data_out_10g),     //o-256, 256-bit Output data                            
		.ctrl_out	(ctrl_out_10g),     //o-32, 32-bit Output ctrl                              
		                                                                                        
		.linkup		(linkup_10g),       //o-1, to check whether the linkup is established or not
				                                                                                
		.x_we		(x_we_10g),         //o-1, write enable for the X2C data and ctrl FIFOs     
		                                                                                        
		.x_bcnt_we	(x_bcnt_we_10g),    //o-1, write enable for the X2C byte count FIFO         
		.x_byte_cnt	(x_byte_cnt_10g)    //o-32, byte count data input to the X2C byte count FIFO
	);

    

endmodule                          