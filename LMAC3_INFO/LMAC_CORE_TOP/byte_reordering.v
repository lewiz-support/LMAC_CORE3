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

module tcore_byte_reordering (
	clk250	,		 		//i-1
	x_clk,					//i-1
	reset_,					//i-1
	fmac_rxd_en	,			//i-1 
	                    	
	xaui_mode,				//i-1
	
	data_in,		   		//i-256, data	                                 
	ctrl_in,		   		//i-40,ctrl-32bits + 8 bits of sof/eof markers
	data_out,		  		//o-256
	ctrl_out,		   		//o-32
	
	br_sof0,				//o-1, to rxgmii
	br_sof4,               	//o-1, to rxgmii
	br_sof8,               	//o-1, to rxgmii
	br_sof12,              	//o-1, to rxgmii
	br_sof16,              	//o-1, to rxgmii
	br_sof20,              	//o-1, to rxgmii
	br_sof24,              	//o-1, to rxgmii
	br_sof28,		       	//o-1, to rxgmii
	
	RAW_FRAME_CNT,			//o-32
	
	rx_auto_clr_en,        	//i-1
	init_done,		        //i-1
	linkup,                 //o-1
	br_rd_en,               //o-1
	br_rd_empty,            //i-1
	rdusedw_data,           //i-11
	rdusedw_ctrl			//i-11	
	
	);

parameter WIDTH 		= 256;	//default
parameter CTRL_WIDTH 	= 32;	
	
	
input clk250;      		//i-1
input x_clk;            //i-1
input reset_;           //i-1

input fmac_rxd_en;     	//i-1
input xaui_mode;        //i-1

input [10:0]	rdusedw_data;  	//i-11
input [10:0]	rdusedw_ctrl;   //i-11

input 	[WIDTH-1:0]	data_in;   	//i-256

//debug
wire 	[63:0]	data_inA = data_in[63:0];
wire 	[63:0]	data_inB = data_in[127:64];
wire 	[63:0]	data_inC = data_in[191:128];
wire 	[63:0]	data_inD = data_in[255:192];
	
input 	[CTRL_WIDTH + 7:0]	ctrl_in; 		// 40 bits ctrl with [39:32] indicating pre-sof and pre-eof

output	[WIDTH-1:0]			data_out;		//o-256
output	[CTRL_WIDTH-1:0]	ctrl_out;		//o-32

output						br_sof0; 		//o-1, to rxgmii
output						br_sof4; 		//o-1, to rxgmii
output						br_sof8; 		//o-1, to rxgmii
output						br_sof12;		//o-1, to rxgmii
output						br_sof16;		//o-1, to rxgmii
output						br_sof20;		//o-1, to rxgmii
output						br_sof24;		//o-1, to rxgmii
output						br_sof28;		//o-1, to rxgmii

output		[31:0]	RAW_FRAME_CNT ;			//o-31

input		rx_auto_clr_en; 				//i-1
input		init_done;                      //i-1
output		linkup;	                        //o-1
output 		br_rd_en;                       //o-1
input 		br_rd_empty;                    //i-1

reg		 	br_rd_en;


parameter [2:0]
	LINK_FAIL = 3'h1,
	LINK_RCVR = 3'h2,
	LINK_GOOD = 3'h4;
reg [2:0] state;

reg [4:0] link_cnt;

reg		[WIDTH-1:0]			data_out,data_out_eof ;
reg		[WIDTH-1:0]			data_in_dly,data_in_dly_1 ;
reg		[CTRL_WIDTH + 7:0]	ctrl_in_dly,ctrl_in_dly_1 ;
reg		[CTRL_WIDTH-1:0]	ctrl_out,ctrl_out_eof ;
reg							br_sof0;
reg							br_sof4 ;
reg							br_sof8 ;
reg							br_sof12;
reg							br_sof16;
reg							br_sof20;
reg							br_sof24;
reg							br_sof28;

reg							br_sof0_d;     	//dealy used to output the sof aligned with data.
reg							br_sof4_d ;    	//dealy used to output the sof aligned with data.
reg							br_sof8_d ;    	//dealy used to output the sof aligned with data.
reg							br_sof12_d;    	//dealy used to output the sof aligned with data.
reg							br_sof16_d;    	//dealy used to output the sof aligned with data.
reg							br_sof20_d;    	//dealy used to output the sof aligned with data.
reg							br_sof24_d;    	//dealy used to output the sof aligned with data.
reg							br_sof28_d;    	//dealy used to output the sof aligned with data.

				

reg							no_shift;       //the number indicates the amount by which data is shifted.
reg							shift;          //the number indicates the amount by which data is shifted.
reg							shift4;         //the number indicates the amount by which data is shifted.
reg							shift8;         //the number indicates the amount by which data is shifted.
reg							shift12;        //the number indicates the amount by which data is shifted.
reg							shift16;        //the number indicates the amount by which data is shifted.
reg							shift20;        //the number indicates the amount by which data is shifted.
reg							shift24;        //the number indicates the amount by which data is shifted.
reg							shift28;        //the number indicates the amount by which data is shifted.
                    		
reg							eof0;     		// FD ending in 0-3 position  
reg							eof1;     		// FD ending in 4-7 position  
reg							eof2;     		// FD ending in 8-11 position 
reg							eof3;     		// FD ending in 12-15 position
reg							eof4;     		// FD ending in 16-19 position
reg							eof5;     		// FD ending in 20-23 position
reg							eof6;     		// FD ending in 24-27 position
reg							eof7;     		// FD ending in 28-31 position
reg							linkup;
reg							link_bad;
reg							link_ok;
wire						link_fault;

reg							flag0;     				// indicates whether the 256 bits data contains SOF and EOF or not.

assign						link_fault = !init_done || 	(data_in_dly_1[7:0] 		== 8'h9C && ctrl_in_dly_1[0] 	== 1'b1) 	 	|| 
										   				(data_in_dly_1[39:32]   	== 8'h9C && ctrl_in_dly_1[4] 	== 1'b1) 		||
										   				(data_in_dly_1[71:64] 		== 8'h9C && ctrl_in_dly_1[8] 	== 1'b1) 	 	||
										   				(data_in_dly_1[103:96]   	== 8'h9C && ctrl_in_dly_1[12] 	== 1'b1)  		||
										   				(data_in_dly_1[135:128] 	== 8'h9C && ctrl_in_dly_1[16] 	== 1'b1)  		||
                                           				(data_in_dly_1[167:160]  	== 8'h9C && ctrl_in_dly_1[20] 	== 1'b1) 		||
                                           				(data_in_dly_1[199:192] 	== 8'h9C && ctrl_in_dly_1[24] 	== 1'b1) 		||
                                           				(data_in_dly_1[231:224]  	== 8'h9C && ctrl_in_dly_1[28] 	== 1'b1);
wire 						seq0 ;                            
assign 						seq0	=	(data_in[7:0] == 8'h9C && ctrl_in[0] == 1'b1) ;
wire						seq1 ;
assign						seq1 	= 	(data_in[39:32] == 8'h9C && ctrl_in[4] == 1'b1) ;
wire 						seq2 ;                                                   										   
assign 						seq2 	= 	(data_in[71:64] == 8'h9C && ctrl_in[8] == 1'b1) ; 
wire						seq3 ;                                                    
assign						seq3 	= 	(data_in[103:96] == 8'h9C && ctrl_in[12] == 1'b1) ;
wire 						seq4 ;                                                   
assign 						seq4 	= 	(data_in[135:128] == 8'h9C && ctrl_in[16] == 1'b1) ; 
wire						seq5 ;                                                    
assign						seq5 	= 	(data_in[167:160] == 8'h9C && ctrl_in[20] == 1'b1) ;
wire 						seq6 ;                                                   
assign 						seq6 	= 	(data_in[199:192] == 8'h9C && ctrl_in[24] == 1'b1) ; 
wire						seq7 ;                                                    
assign						seq7 	= 	(data_in[231:224] == 8'h9C && ctrl_in[28] == 1'b1) ;

//indicates the type of SOF and EOF in one frame. eg: sof8_eof_same_frame indicates sof8 and eof of previous packet are in same 256 bits.
wire						sof_eof_same_frame;         
reg 						sof8_eof_same_frame;      
reg 						sof12_eof_same_frame;     
reg 						sof16_eof_same_frame;     
reg 						sof20_eof_same_frame;     
reg 						sof24_eof_same_frame;     
reg 						sof28_eof_same_frame;     
        			
//the number indicates the position of start of frame.		
reg							sof0;                       
reg							sof4;                      
reg							sof8;                      
reg							sof12;                     
reg							sof16;                     
reg							sof20;                     
reg							sof24;                     
reg							sof28;
reg							sof0_d; 	//delayed version of the sof's
reg							sof4_d; 	//delayed version of the sof's
reg							sof8_d; 	//delayed version of the sof's
reg							sof12_d;	//delayed version of the sof's
reg							sof16_d;	//delayed version of the sof's
reg							sof20_d;	//delayed version of the sof's
reg							sof24_d;	//delayed version of the sof's
reg							sof28_d;	//delayed version of the sof's
                                    	
reg 	[WIDTH-1 : 0]		data_out_0;
reg		[WIDTH-1 : 0]		data_out_4;
reg		[WIDTH-1 : 0]		data_out_8;
reg		[WIDTH-1 : 0]		data_out_12;
reg 	[WIDTH-1 : 0]		data_out_16;
reg		[WIDTH-1 : 0]		data_out_20;
reg		[WIDTH-1 : 0]		data_out_24;
reg		[WIDTH-1 : 0]		data_out_28;
reg		[WIDTH-1 : 0]		data_out_without_shift;

reg 	[CTRL_WIDTH-1 : 0]		ctrl_out_0;            
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_4;            
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_8;            
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_12;           
reg 	[CTRL_WIDTH-1 : 0]		ctrl_out_16;           
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_20;           
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_24;           
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_28;           
reg		[CTRL_WIDTH-1 : 0]		ctrl_out_without_shift;

reg							d_shift;
reg							d_no_shift;
reg							d_shift4  ;
reg							d_shift8  ;
reg							d_shift12 ;
reg							d_shift16 ;
reg							d_shift20 ;
reg							d_shift24 ;      					                                                                   
reg							d_shift28 ;
reg							has_sof;                    // indicates if the frame has valid sof.  
        					
reg							frame_done;
reg							fmac_rxd_en156 ;
        					
reg							eof	;
reg							invalid_sof;

reg		[31:0]				raw_frame_cnt156 ;
reg		[31:0]				RAW_FRAME_CNT ;		

reg							frame;
reg							frame_dly,frame_dly_1;		

wire						rf_sfifo_full ;
wire						rf_sfifo_empty ;
wire	[31:0]				rf_sfifo_dout ;

assign  sof_eof_same_frame 	=  sof8_eof_same_frame | sof12_eof_same_frame | sof16_eof_same_frame| sof20_eof_same_frame | sof24_eof_same_frame | sof28_eof_same_frame; 
                                                                                                   
always @ (posedge x_clk)
begin
		data_in_dly			<=	data_in ;
		
		data_in_dly_1 		<= 	data_in_dly ;
		
		ctrl_in_dly[3:0] 	<= seq0? 4'hf : ctrl_in[3:0] 	; 
		ctrl_in_dly[7:4] 	<= seq1? 4'hf : ctrl_in[7:4] 	;
		ctrl_in_dly[11:8] 	<= seq2? 4'hf : ctrl_in[11:8] 	;
		ctrl_in_dly[15:12] 	<= seq3? 4'hf : ctrl_in[15:12] 	;
		ctrl_in_dly[19:16] 	<= seq4? 4'hf : ctrl_in[19:16] 	;
		ctrl_in_dly[23:20] 	<= seq5? 4'hf : ctrl_in[23:20] 	;
		ctrl_in_dly[27:24] 	<= seq6? 4'hf : ctrl_in[27:24] 	;
		ctrl_in_dly[31:28] 	<= seq7? 4'hf : ctrl_in[31:28] 	;
		ctrl_in_dly[39:32]	<= ctrl_in[39:32];	  
		ctrl_in_dly_1 		<= ctrl_in_dly;	
		fmac_rxd_en156		<= fmac_rxd_en;
end

always @ (posedge x_clk)
begin
	if (!reset_)
	begin
	
	//Initializing all the registers to 0.
		br_rd_en 	<=	1'b0;
	  
	   	sof8_eof_same_frame		<=	1'b0;  
	   	sof12_eof_same_frame	<=	1'b0; 
	   	sof16_eof_same_frame	<=	1'b0; 
	   	sof20_eof_same_frame	<=	1'b0; 
	   	sof24_eof_same_frame	<=	1'b0; 
	   	sof28_eof_same_frame	<=	1'b0; 
	   	eof						<=	1'b0;
	    
	
		no_shift	<=	1'b0;
		shift		<=	1'b0;
		shift4 		<=	1'b0;
		shift8		<=	1'b0; 
		shift12 	<=	1'b0;
		shift16		<=	1'b0; 
		shift20 	<=	1'b0;
		shift24		<=	1'b0; 
		shift28 	<=	1'b0;
		eof0	    <=	1'b0;
		eof1		<=	1'b0;     
		eof2	    <=	1'b0;
		eof3		<=	1'b0;     
		eof4	    <=	1'b0;
		eof5		<=	1'b0;     
		eof6	    <=	1'b0;
		eof7		<=	1'b0;     	              
		linkup		<=	1'b0;
		link_bad	<=	1'b0;
		link_ok		<=	1'b0;
		flag0 		<= 	1'b0;
		frame		<=	1'b0;
		frame_dly	<=	1'b0;
		frame_dly_1	<=	1'b0;
		invalid_sof	<=	1'b0;
		
		sof0		<=  1'b0;
		sof4		<=  1'b0;
		sof8		<=  1'b0;
		sof12		<=  1'b0;
		sof16		<=	1'b0;
		sof20		<=	1'b0;
		sof24		<=	1'b0;
		sof28		<=	1'b0;
		
		sof0_d		<=	1'b0;
		sof4_d		<=  1'b0; 
		sof8_d		<=  1'b0; 
		sof12_d		<=  1'b0;
		sof16_d		<=	1'b0; 
		sof20_d		<=	1'b0; 
		sof24_d		<=	1'b0; 
		sof28_d		<=	1'b0;
		 
		data_out_0				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707; 
		data_out_4				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707; 
		data_out_8				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707; 
		data_out_12				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
		data_out_16				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
		data_out_20				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
		data_out_24				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
        data_out_28				<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
        data_out_without_shift	<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
        ctrl_out_0				<=	32'hff_ff_ff_ff;         
        ctrl_out_4				<=	32'hff_ff_ff_ff;         
        ctrl_out_8				<=	32'hff_ff_ff_ff;         
        ctrl_out_12				<=	32'hff_ff_ff_ff;        
        ctrl_out_16				<=	32'hff_ff_ff_ff;        
        ctrl_out_20				<=	32'hff_ff_ff_ff;        
        ctrl_out_24				<=	32'hff_ff_ff_ff;        
        ctrl_out_28				<=	32'hff_ff_ff_ff;        
        ctrl_out_without_shift	<=	32'hff_ff_ff_ff;
        
        d_no_shift  	<=     1'b0;
        d_shift  		<=     1'b0;
        d_shift4		<=     1'b0;
        d_shift8		<=     1'b0;
        d_shift12   	<=     1'b0;
        d_shift16   	<=     1'b0;
        d_shift20   	<=     1'b0;
        d_shift24   	<=     1'b0;
        d_shift28   	<=     1'b0;
        
        
		br_sof0		<=	1'b0;
		br_sof4		<=	1'b0;
		br_sof8 	<=	1'b0;
		br_sof12	<=	1'b0;
		br_sof16	<=	1'b0;
		br_sof20	<=	1'b0;
		br_sof24	<=	1'b0;
		br_sof28	<=	1'b0;
		
		br_sof0_d		<=	1'b0;
		br_sof4_d		<=	1'b0;
		br_sof8_d 	<=	1'b0;
		br_sof12_d	<=	1'b0;
		br_sof16_d	<=	1'b0;
		br_sof20_d	<=	1'b0;
		br_sof24_d	<=	1'b0;
		br_sof28_d	<=	1'b0;
		
		has_sof			<=	1'b0;
		frame_done		<=	1'b0;
		data_in_dly 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
		data_out_eof 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
		ctrl_in_dly   	<= 	32'hff_ff_ff_ff;
		data_in_dly_1 	<=  256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
		ctrl_in_dly_1 	<=  32'hff_ff_ff_ff;
		ctrl_out_eof  	<=  32'hff_ff_ff_ff; 
		                                                        
		raw_frame_cnt156	<=	32'h0;
		
	end
	
	else
	begin
	
		invalid_sof	<=	(data_in[15:8]		==	8'hFB)	&	ctrl_in[1]	|   
						(data_in[23:16]		==	8'hFB)	&	ctrl_in[2]	|  
						(data_in[31:24]		==	8'hFB)	&	ctrl_in[3]	|  
						(data_in[47:40]		==	8'hFB)	&	ctrl_in[5]	|  
						(data_in[55:48]		==	8'hFB)	&	ctrl_in[6]	|  
						(data_in[63:56]		==	8'hFB)	&	ctrl_in[7]	|  
						(data_in[79:72]		==	8'hFB)	&	ctrl_in[9]	|  
						(data_in[87:80]		==	8'hFB)	&	ctrl_in[10]	| 
						(data_in[95:88]		==	8'hFB)	&	ctrl_in[11]	| 
						(data_in[111:104]	==	8'hFB)	&	ctrl_in[13]	|
						(data_in[119:112]	==	8'hFB)	&	ctrl_in[14]	|
						(data_in[127:120]	==	8'hFB)	&	ctrl_in[15]	|
						(data_in[143:136]	==	8'hFB)	&	ctrl_in[17]	|
						(data_in[151:144]	==	8'hFB)	&	ctrl_in[18]	|
						(data_in[159:152]	==	8'hFB)	&	ctrl_in[19]	|
						(data_in[175:168]	==	8'hFB)	&	ctrl_in[21]	|
						(data_in[183:176]	==	8'hFB)	&	ctrl_in[22]	|
						(data_in[191:184]	==	8'hFB)	&	ctrl_in[23]	|
						(data_in[207:200]	==	8'hFB)	&	ctrl_in[25]	|
						(data_in[215:208]	==	8'hFB)	&	ctrl_in[26]	|
						(data_in[223:216]	==	8'hFB)	&	ctrl_in[27]	|
						(data_in[239:232]	==	8'hFB)	&	ctrl_in[29]	|
						(data_in[247:240]	==	8'hFB)	&	ctrl_in[30]	|
						(data_in[255:248]	==	8'hFB)	&	ctrl_in[31]	;
		frame	<=	((ctrl_in_dly_1[39:32] == 8'd2) |	(ctrl_in_dly[39:32] == 8'd7) | (ctrl_in_dly[39:32] == 8'd0) | (ctrl_in_dly[39:32] == 8'd6) | (ctrl_in_dly[39:32] == 8'd5) | (ctrl_in_dly[39:32] == 8'd4) | ((ctrl_in[39:32] == 8'd4)&(sof28)))	?	1'b1 : ((ctrl_in_dly_1[39:32] == 8'd8) | (ctrl_in_dly_1[39:32] == 8'd10) | (ctrl_in_dly_1[39:32] == 8'd5))	?	1'b0	:	frame;  
		frame_dly		<=	frame;
		frame_dly_1	<=	frame_dly;
		eof		 <= (!frame & !shift & !no_shift & br_rd_empty) ?	1'b0 :	  
											 eof				?	1'b0 :  
											 
											((shift28 | sof28)  & (sof28 | frame))  	?	(ctrl_in[39:32] == 8'h8 | ctrl_in[39:32] == 8'h9 | ctrl_in[39:32] == 8'h0a):
											(!shift28 & frame)				?	(ctrl_in_dly[39:32] == 8'h8 | ctrl_in_dly[39:32] == 8'h9 | ctrl_in_dly[39:32] == 8'h0a ) :
											eof;
		br_rd_en <= ctrl_in[39:32] == 8'h04 ? 1'b0:            // check whether the data coming in has a EOF. 
					ctrl_in[39:32] == 8'h05 ? 1'b0:
					ctrl_in[39:32] == 8'h06 ? 1'b0:
					ctrl_in[39:32] == 8'h07 ? 1'b0:            //check whether the data coming in has a EOF and SOF in same frame. 
					br_rd_empty ? 1'b0	:                     //Check whether the FIFO is empty or not. If not, enable the br_rd_en to activate the read request for reading data from FIFO.
					1'b1;
		                 		
	                                                 
		sof8_eof_same_frame 	<= sof8_eof_same_frame 	?	1'b0	:	(ctrl_in[31:8] == 24'h000001)		?	 (ctrl_in[7:0] ==  8'hff)			?	(data_in[7:0]  == 8'h07) 			?	1'b0	:	1'b1 : 1'b1 : 1'b0;         
		sof12_eof_same_frame	<= sof12_eof_same_frame	?	1'b0	:	(ctrl_in[31:12] == 20'h00001)		?	 (ctrl_in[11:0] == 12'hfff)			?	(data_in[11:0] == 12'h707) 			?   1'b0	:	1'b1 : 1'b1 : 1'b0;   					  
		sof16_eof_same_frame	<= sof16_eof_same_frame	?	1'b0	:	(ctrl_in[31:16] == 16'h0001) 		?	 (ctrl_in[15:0] == 16'hffff)		?	(data_in[15:0] == 16'h0707) 		?   1'b0	:	1'b1 : 1'b1 : 1'b0;   					  
		sof20_eof_same_frame	<= sof20_eof_same_frame	?	1'b0	:	(ctrl_in[31:20] == 12'h001) 		?	 (ctrl_in[19:0] == 20'hfffff)		?	(data_in[19:0] == 20'h70707) 		?   1'b0	:	1'b1 : 1'b1 : 1'b0; 					  
		sof24_eof_same_frame	<= sof24_eof_same_frame	?	1'b0	:	(ctrl_in[31:24] == 8'h01) 			?	 (ctrl_in[23:0] == 24'hffffff)		?	(data_in[23:0] == 24'h070707) 		?   1'b0	:	1'b1 : 1'b1 : 1'b0; 					  
		sof28_eof_same_frame	<= sof28_eof_same_frame	?	1'b0	:	(ctrl_in[31:28] == 4'h1) 			?	 (ctrl_in[27:0] == 28'hfffffff)		?	(data_in[27:0] == 28'h7070707) 		?   1'b0	:	1'b1 : 1'b1 : 1'b0;					  
						
		shift		<= 	(
						(data_in_dly[39:32]==8'hFB) 	&& (ctrl_in_dly[4] == 1'b1) 	|| 
						(data_in_dly[71:64]==8'hFB) 	&& (ctrl_in_dly[8] == 1'b1) 	||
						(data_in_dly[103:96]==8'hFB) 	&& (ctrl_in_dly[12] == 1'b1) 	||
						(data_in_dly[135:128]==8'hFB) 	&& (ctrl_in_dly[16] == 1'b1) 	||
						(data_in_dly[167:160]==8'hFB) 	&& (ctrl_in_dly[20] == 1'b1) 	||
						(data_in_dly[199:192]==8'hFB) 	&& (ctrl_in_dly[24] == 1'b1) 	||
						(data_in_dly[231:224]==8'hFB) 	&& (ctrl_in_dly[28] == 1'b1)) 	&& !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)? 1'b1 :  
                    				                                                                 
						(((eof & !sof8)  || (sof0 & !sof8))  	    &&                    
						 ((eof & !sof12) || (sof0 & !sof12))		&&                        
						 ((eof & !sof16) || (sof0 & !sof16))		&&                        
						 ((eof & !sof20) || (sof0 & !sof20))		&&                        
						 ((eof & !sof24) || (sof0 & !sof24))		&&                        
						 ((eof & !sof28) || (sof0 & !sof28)))		||	((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)? 1'b0 :             
				  		shift
						;
						
		no_shift		<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof0	? 1'b1 : eof ? 1'b0 : no_shift	:	1'b0			;				// an event to represent data transmitted is shifted by 0.
		shift4 			<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof4 	? 1'b1 : eof ? 1'b0 : shift4  	:	1'b0			;             // an event to represent data transmitted is shifted by 4.
		shift8 			<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof8 	? 1'b1 : eof ? 1'b0 : shift8  	:	1'b0			;             // an event to represent data transmitted is shifted by 8.
		shift12 		<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof12 	? 1'b1 : eof ? 1'b0 : shift12 	:	1'b0			;             // an event to represent data transmitted is shifted by 12.
		shift16 		<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof16 	? 1'b1 : eof ? 1'b0 : shift16 	:	1'b0			;             // an event to represent data transmitted is shifted by 16.
		shift20 		<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof20 	? 1'b1 : eof ? 1'b0 : shift20 	:	1'b0			;             // an event to represent data transmitted is shifted by 20.
		shift24 		<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	sof24 	? 1'b1 : eof ? 1'b0 : shift24	:	1'b0 			;             // an event to represent data transmitted is shifted by 24.
		shift28 		<= !((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0) 	?	sof28 	? 1'b1 : eof ? 1'b0 : shift28 	:	1'b0			;  
		
		d_shift  		<=  shift;
		d_no_shift  	<=	no_shift;
		d_shift4		<=	shift4;	
		d_shift8		<=	shift8;	
		d_shift12   	<=	shift12;
		d_shift16   	<=	shift16;
		d_shift20   	<=	shift20;
		d_shift24   	<=	shift24;
		d_shift28   	<=	shift28;        
		// an event to represent data transmitted is shifted by 28.
		
		// logic for getting the end of frame i.e locating FD in data and 1'b1 in ctrl.
		
		eof0      	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof0	?	1'b0:  shift28	?		(ctrl_in[0]  		&&  	(data_in[7:0] == 8'hFD))    	|| 	(ctrl_in[1]  && (data_in[15:8] == 8'hFD))  			|| 		          
																												                            (ctrl_in[2]  		&&  	(data_in[23:16] == 8'hFD))  	|| 	(ctrl_in[3]  && (data_in[31:24] == 8'hFD))			:
									
																								!flag0	?		(ctrl_in_dly[0] 	&&  	(data_in_dly[7:0] == 8'hFD))    || 	(ctrl_in_dly[1]  && (data_in_dly[15:8] == 8'hFD))  	||
																												(ctrl_in_dly[2] 	&&  	(data_in_dly[23:16] == 8'hFD))  || 	(ctrl_in_dly[3]  && (data_in_dly[31:24] == 8'hFD))	: 
																											
																												1'b0;     
				                        	     	           	                                                                                              	
		eof1      	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof1	?	1'b0: 	shift28	?		(ctrl_in[4]  		&&  	(data_in[39:32] == 8'hFD))  	|| 	(ctrl_in[5]  && (data_in[47:40] == 8'hFD)) 			|| 		       
																												(ctrl_in[6]  		&&  	(data_in[55:48] == 8'hFD))  	|| 	(ctrl_in[7]  && (data_in[63:56] == 8'hFD))			:
																												
																								!flag0	?		(ctrl_in_dly[4] 	&&  	(data_in_dly[39:32] == 8'hFD))  || 	(ctrl_in_dly[5]  && (data_in_dly[47:40] == 8'hFD)) 	||	
																			                	     	  		(ctrl_in_dly[6] 	&&  	(data_in_dly[55:48] == 8'hFD))  || 	(ctrl_in_dly[7]  && (data_in_dly[63:56] == 8'hFD))	:
																			                	     	  		1'b0;                                                                                                   		    
																			                	     	                	                                                                                  		    
		eof2    	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof2	?	1'b0: 	shift28	?		(ctrl_in[8]  		&& 		(data_in[71:64] == 8'hFD))   	||	(ctrl_in[9]  && (data_in[79:72] == 8'hFD)) 			||  	                  
																												(ctrl_in[10] 		&& 		(data_in[87:80] == 8'hFD))   	||	(ctrl_in[11] && (data_in[95:88] == 8'hFD))			:
																								!flag0	?		(ctrl_in_dly[8] 	&& 		(data_in_dly[71:64] == 8'hFD))  ||	(ctrl_in_dly[9]  && (data_in_dly[79:72] == 8'hFD)) 	||     		
																		                	    				(ctrl_in_dly[10]	&& 		(data_in_dly[87:80] == 8'hFD))  ||	(ctrl_in_dly[11] && (data_in_dly[95:88] == 8'hFD))	:
																		                	    				1'b0;                                                                                                                		       
																		                	     	                	                                                                                  		       
		eof3    	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof3	?	1'b0: 	shift28	?		(ctrl_in[12] 		&& 		(data_in[103:96] == 8'hFD))  	||	(ctrl_in[13] && (data_in[111:104] == 8'hFD))		||  	  
																												(ctrl_in[14] 		&& 		(data_in[119:112] == 8'hFD)) 	||	(ctrl_in[15] && (data_in[127:120] == 8'hFD))		:
																								!flag0	?		(ctrl_in_dly[12]	&& 		(data_in_dly[103:96] == 8'hFD)) ||	(ctrl_in_dly[13] && (data_in_dly[111:104] == 8'hFD))||    		
																		                						(ctrl_in_dly[14]	&& 		(data_in_dly[119:112] == 8'hFD))||	(ctrl_in_dly[15] && (data_in_dly[127:120] == 8'hFD)):
																		                						1'b0;                                                                                                                     		       
																		                	     	        	                                                                                          		       
		eof4    	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof4	?	1'b0: 	shift28	?		(ctrl_in[16] 		&& 		(data_in[135:128] == 8'hFD)) 	||	(ctrl_in[17] && (data_in[143:136] == 8'hFD)) 		|| 	 
																												(ctrl_in[18] 		&& 		(data_in[151:144] == 8'hFD)) 	||	(ctrl_in[19] && (data_in[159:152] == 8'hFD))		: 
																								!flag0	?		(ctrl_in_dly[16] 	&& 		(data_in_dly[135:128] == 8'hFD))||	(ctrl_in_dly[17] && (data_in_dly[143:136] == 8'hFD))||   		
																		                	    				(ctrl_in_dly[18] 	&& 		(data_in_dly[151:144] == 8'hFD))||	(ctrl_in_dly[19] && (data_in_dly[159:152] == 8'hFD)):
																		                	    				1'b0;                                                                                                                  		     
																		                	     	        	                	                                                                          		     
		eof5    	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof5	?	1'b0: 	shift28	?		(ctrl_in[20] 		&& 		(data_in[167:160] == 8'hFD)) 	||	(ctrl_in[21] && (data_in[175:168] == 8'hFD)) 		|| 	 
																												(ctrl_in[22] 		&& 		(data_in[183:176] == 8'hFD)) 	||	(ctrl_in[23] && (data_in[191:184] == 8'hFD))		:
																								!flag0	?		(ctrl_in_dly[20] 	&& 		(data_in_dly[167:160] == 8'hFD))||	(ctrl_in_dly[21] && (data_in_dly[175:168] == 8'hFD))||   		
																		                	    				(ctrl_in_dly[22] 	&& 		(data_in_dly[183:176] == 8'hFD))||	(ctrl_in_dly[23] && (data_in_dly[191:184] == 8'hFD)):
																		                	    				1'b0;                                                                                                                  		      
																		                	     	        	                	                                                                          		      
		eof6      	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof6	?	1'b0: 	shift28	?		(ctrl_in[24] 		&& 		(data_in[199:192] == 8'hFD)) 	||	(ctrl_in[25] && (data_in[207:200] == 8'hFD)) 		|| 	 
																						 						(ctrl_in[26] 		&& 		(data_in[215:208] == 8'hFD)) 	||	(ctrl_in[27] && (data_in[223:216] == 8'hFD))		: 
																								!flag0	?		(ctrl_in_dly[24] 	&& 		(data_in_dly[199:192] == 8'hFD))||	(ctrl_in_dly[25] && (data_in_dly[207:200] == 8'hFD))||   		
						                 	    																(ctrl_in_dly[26] 	&& 		(data_in_dly[215:208] == 8'hFD))||	(ctrl_in_dly[27] && (data_in_dly[223:216] == 8'hFD)):
						                 	    																1'b0;                                                                                                                  		     
						                 	     	                       	                                                                          		     
		eof7      	<=  (!shift & !no_shift & br_rd_empty) ?	1'b0	:	eof7	?	1'b0: 	shift28	?		(ctrl_in[28] 		&& 		(data_in[231:224] == 8'hFD)) 	||	(ctrl_in[29] && (data_in[239:232] == 8'hFD)) 		|| 		 
																												(ctrl_in[30] 		&& 		(data_in[247:240] == 8'hFD)) 	||	(ctrl_in[31] && (data_in[255:248] == 8'hFD))		:
																								!flag0	?		(ctrl_in_dly[28] 	&& 		(data_in_dly[231:224] == 8'hFD))||	(ctrl_in_dly[29] && (data_in_dly[239:232] == 8'hFD))||   		
						                                    													(ctrl_in_dly[30] 	&& 		(data_in_dly[247:240] == 8'hFD))||	(ctrl_in_dly[31] && (data_in_dly[255:248] == 8'hFD)):
						                                    													1'b0;                                              	
		 				

		link_bad	<=	link_fault;
		link_ok		<=	(link_cnt == 5'd0);
		
		//sof is used to locate the start of frame. look for FB in data and 1'b1 in ctrl on same byte position.		
		sof0		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof0		?	1'b0: 	(data_in_dly[7:0]		==	8'hFB)   	& 	ctrl_in_dly[0]	;
		sof4		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof4		?	1'b0: 	(data_in_dly[39:32]		==	8'hFB) 		& 	ctrl_in_dly[4]	;
		sof8		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof8		?	1'b0: 	(data_in_dly[71:64]		==	8'hFB)  	& 	ctrl_in_dly[8] 	;
		sof12		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof12		?	1'b0: 	(data_in_dly[103:96]	==	8'hFB)  	& 	ctrl_in_dly[12]	;
		sof16		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof16		?	1'b0: 	(data_in_dly[135:128]	==	8'hFB) 		& 	ctrl_in_dly[16]	;             	             	
		sof20		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof20		?	1'b0: 	(data_in_dly[167:160]	==	8'hFB) 		& 	ctrl_in_dly[20]	;
		sof24		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof24		?	1'b0: 	(data_in_dly[199:192]	==	8'hFB) 		& 	ctrl_in_dly[24]	;
		sof28		<= ((ctrl_in_dly_1[39:32] == ctrl_in[39:32]) & (ctrl_in_dly_1[39:32] == ctrl_in_dly[39:32])	&	ctrl_in != 10'd0)	?	1'b0	:	sof28		?	1'b0: 	(data_in_dly[231:224]	==	8'hFB) 		& 	ctrl_in_dly[28]	;
		
		//Delay the SOF.
		sof0_d		<=	sof0;
		sof4_d		<=  sof4; 
		sof8_d		<=  sof8; 
		sof12_d		<=  sof12;
		sof16_d		<=	sof16; 
		sof20_d		<=	sof20; 
		sof24_d		<=	sof24; 
		sof28_d		<=	sof28; 
		//
		br_sof0_d		<= 	br_sof0_d		?	1'b0	:	(sof0 	& !eof	&	!flag0)	?	sof0 	:	sof0_d 	;
		br_sof4_d		<= 	br_sof4_d		?	1'b0	:	(sof4 	& !eof	&	!flag0)	?	sof4 	:	sof4_d 	;
		br_sof8_d 		<=	br_sof8_d 		?	1'b0	:	(sof8 	& !eof	&	!flag0)	?	sof8 	:	sof8_d 	;
		br_sof12_d		<=	br_sof12_d		?	1'b0	:	(sof12 	& !eof	&	!flag0)	?	sof12	:	sof12_d	;
		br_sof16_d		<=	br_sof16_d		?	1'b0	:	(sof16 	& !eof	&	!flag0)	?	sof16	:	sof16_d	;
		br_sof20_d		<=	br_sof20_d		?	1'b0	:	(sof20 	& !eof	&	!flag0)	?	sof20	:	sof20_d	;
		br_sof24_d		<=	br_sof24_d		?	1'b0	:	(sof24 	& !eof	&	!flag0)	?	sof24	:	sof24_d	;
		br_sof28_d		<=	br_sof28_d		?	1'b0	:	(sof28 	& !eof	&	!flag0)	?	sof28	:	sof28_d	;
		
		br_sof0		<=	(frame	|	frame_dly)	?	br_sof0 	?	1'b0	:	br_sof0_d 	:	1'b0;
		br_sof4		<=	(frame	|	frame_dly)	?	br_sof4 	?	1'b0	:	br_sof4_d 	:	1'b0;
		br_sof8 	<=	(frame	|	frame_dly)	?	br_sof8 	?	1'b0	:	br_sof8_d 	:	1'b0;
		br_sof12	<=	(frame	|	frame_dly)	?	br_sof12	?	1'b0	:	br_sof12_d	:	1'b0;
		br_sof16	<=	(frame	|	frame_dly)	?	br_sof16	?	1'b0	:	br_sof16_d	:	1'b0;
		br_sof20	<=	(frame	|	frame_dly)	?	br_sof20	?	1'b0	:	br_sof20_d	:	1'b0;
		br_sof24	<=	(frame	|	frame_dly)	?	br_sof24	?	1'b0	:	br_sof24_d	:	1'b0;
		br_sof28	<=	(frame	|	frame_dly)	?	br_sof28	?	1'b0	:	br_sof28_d	:	1'b0;
		
		
		// has_sof indicates whether the SOF in received data is valid or not. 
		has_sof				<=	  	(sof0 | sof4 | sof8 | sof12 | sof16 | sof20 | sof24 | sof28) ? 1'b1: 
								  	(eof) ? 1'b0 :
								  	has_sof;		
								
		frame_done			<=		frame_done ? 1'b0 :	
									(eof) & has_sof ? 1'b1 : 	
									1'b0 ;
	
		raw_frame_cnt156	<=		!fmac_rxd_en156 ? 32'h0 :		
									frame_done ? raw_frame_cnt156 + 8'd1 :
									raw_frame_cnt156;
					
	end
end

always @(posedge x_clk)
begin
	if (!reset_)
		begin
			data_out		<= 256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			ctrl_out		<= 32'hff_ff_ff_ff;
		
		end
	
	else
		begin
		    data_out_eof <=  ((ctrl_in[0] 	&& (data_in[7:0] 		== 8'hFD)) 	|| (ctrl_in[1] 	&& (data_in[15:8] 		== 8'hFD)) 	||
							  (ctrl_in[2] 	&& (data_in[23:16] 		== 8'hFD)) 	|| (ctrl_in[3] 	&& (data_in[31:24] 		== 8'hFD))) ? {64'h0707070707070707,64'h0707070707070707,64'h0707070707070707, 32'h07070707,data_in[31:0]}:
			                                                    	
							 ((ctrl_in[4] 	&& (data_in[39:32] 		== 8'hFD)) 	|| (ctrl_in[5] 	&& (data_in[47:40] 		== 8'hFD)) 	||
							  (ctrl_in[6] 	&& (data_in[55:48] 		== 8'hFD)) 	|| (ctrl_in[7] 	&& (data_in[63:56] 		== 8'hFD)))	?  {64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,data_in[63:0]}:	 
							 ((ctrl_in[8] 	&& (data_in[71:64] 		== 8'hFD)) 	|| (ctrl_in[9] 	&& (data_in[79:72] 		== 8'hFD)) 	|| 
							  (ctrl_in[10] 	&& (data_in[87:80] 		== 8'hFD)) 	|| (ctrl_in[11] && (data_in[95:88] 		== 8'hFD)))	?   {64'h0707070707070707,64'h0707070707070707,32'h07070707,data_in[95:0]}:   
							 ((ctrl_in[12]	&& (data_in[103:96] 	== 8'hFD)) 	|| (ctrl_in[13] && (data_in[111:104] 	== 8'hFD)) 	||
							  (ctrl_in[14]	&& (data_in[119:112] 	== 8'hFD)) 	|| (ctrl_in[15] && (data_in[127:120] 	== 8'hFD)))	?  {64'h0707070707070707,64'h0707070707070707,data_in[127:0]}:	
							 ((ctrl_in[16] 	&& (data_in[135:128] 	== 8'hFD)) 	|| (ctrl_in[17] && (data_in[143:136] 	== 8'hFD)) 	||
							  (ctrl_in[18] 	&& (data_in[151:144] 	== 8'hFD)) 	|| (ctrl_in[19] && (data_in[159:152] 	== 8'hFD)))	?  {64'h0707070707070707,32'h07070707,data_in[159:0]}:  
							 ((ctrl_in[20] 	&& (data_in[167:160] 	== 8'hFD)) 	|| (ctrl_in[21] && (data_in[175:168] 	== 8'hFD)) 	||
							  (ctrl_in[22] 	&& (data_in[183:176] 	== 8'hFD)) 	|| (ctrl_in[23] && (data_in[191:184] 	== 8'hFD)))	?  {64'h0707070707070707,data_in[191:0]}:	 
							 ((ctrl_in[24] 	&& (data_in[199:192] 	== 8'hFD)) 	|| (ctrl_in[25] && (data_in[207:200] 	== 8'hFD)) 	|| 
							  (ctrl_in[26] 	&& (data_in[215:208] 	== 8'hFD)) 	|| (ctrl_in[27] && (data_in[223:216] 	== 8'hFD)))	?  {32'h07070707,data_in[223:0]}:   
							  data_in;
							  
		    ctrl_out_eof <=  ((ctrl_in[0] 	&& (data_in[7:0] 		== 8'hFD)) 	|| (ctrl_in[1] 	&& (data_in[15:8] 		== 8'hFD)) 	||
							  (ctrl_in[2] 	&& (data_in[23:16] 		== 8'hFD)) 	|| (ctrl_in[3] 	&& (data_in[31:24] 		== 8'hFD))) ? {8'hff,8'hff,8'hff, 4'hf,ctrl_in[3:0]}:
			                                                    	
							 ((ctrl_in[4] 	&& (data_in[39:32] 		== 8'hFD)) 	|| (ctrl_in[5] 	&& (data_in[47:40] 		== 8'hFD)) 	||
							  (ctrl_in[6] 	&& (data_in[55:48] 		== 8'hFD)) 	|| (ctrl_in[7] 	&& (data_in[63:56] 		== 8'hFD)))	?  {8'hff,8'hff,8'hff,ctrl_in[7:0]}:	 
							 ((ctrl_in[8] 	&& (data_in[71:64] 		== 8'hFD)) 	|| (ctrl_in[9] 	&& (data_in[79:72] 		== 8'hFD)) 	|| 
							  (ctrl_in[10] 	&& (data_in[87:80] 		== 8'hFD)) 	|| (ctrl_in[11] && (data_in[95:88] 		== 8'hFD)))	?   {8'hff,8'hff,4'hf,ctrl_in[11:0]}:   
							 ((ctrl_in[12]	&& (data_in[103:96] 	== 8'hFD)) 	|| (ctrl_in[13] && (data_in[111:104] 	== 8'hFD)) 	||
							  (ctrl_in[14]	&& (data_in[119:112] 	== 8'hFD)) 	|| (ctrl_in[15] && (data_in[127:120] 	== 8'hFD)))	?  {8'hff,8'hff,ctrl_in[15:0]}:	
							 ((ctrl_in[16] 	&& (data_in[135:128] 	== 8'hFD)) 	|| (ctrl_in[17] && (data_in[143:136] 	== 8'hFD)) 	||
							  (ctrl_in[18] 	&& (data_in[151:144] 	== 8'hFD)) 	|| (ctrl_in[19] && (data_in[159:152] 	== 8'hFD)))	?  {8'hff,4'hf,ctrl_in[19:0]}:  
							 ((ctrl_in[20] 	&& (data_in[167:160] 	== 8'hFD)) 	|| (ctrl_in[21] && (data_in[175:168] 	== 8'hFD)) 	||
							  (ctrl_in[22] 	&& (data_in[183:176] 	== 8'hFD)) 	|| (ctrl_in[23] && (data_in[191:184] 	== 8'hFD)))	?  {8'hff,ctrl_in[23:0]}:	 
							 ((ctrl_in[24] 	&& (data_in[199:192] 	== 8'hFD)) 	|| (ctrl_in[25] && (data_in[207:200] 	== 8'hFD)) 	|| 
							  (ctrl_in[26] 	&& (data_in[215:208] 	== 8'hFD)) 	|| (ctrl_in[27] && (data_in[223:216] 	== 8'hFD)))	?  {4'hf,ctrl_in[27:0]}:   
							  ctrl_in;
		
		
		
		     ////flag0 is used to indicate the presence of remaining data in next frame with sof and eof in same 256 bit data. 
			flag0			<=		(shift28 & eof & !(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28))	?	1'b1 : 1'b0;  
			
			data_out_0		<=	 {256 {sof0 																				}}						& 	{data_in_dly[63:0],data_in_dly_1[255:64]}															| 
								 {256 {(no_shift    & !eof   & !(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28)	&	!invalid_sof)}}   	&	{data_in_dly[63:0],data_in_dly_1[255:64]}															|
								 {256 {(sof8 		&  eof	 & no_shift)													}}				&	{64'h0707070707070707,32'h07070707,64'h0707070707070707,64'h0707070707070707, 64'h0707070707070707}	| 
								 {256 {(sof12 		&  eof	 & no_shift)													}}				&	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707, 64'h0707070707070707}				|
								 {256 {(sof16 		&  eof	 & no_shift)													}}				&	{64'h0707070707070707,32'h07070707,64'h0707070707070707,64'h0707070707070707, data_in_dly_1[95:64]}	|
								 {256 {(sof20 		&  eof	 & no_shift)													}}				&	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707, data_in_dly_1[127:64]}				|
								 {256 {(sof24		&  eof	 & no_shift)													}}				&	{64'h0707070707070707,32'h07070707,64'h0707070707070707, data_in_dly[159:64]}						|  
								 {256 {(no_shift   & !eof   & invalid_sof)}}   															&	{data_out_eof[63:0],data_in_dly_1[255:64]}                                                          |
								 {256 {(sof28		&  eof	 & no_shift)													}}				&	{64'h0707070707070707,64'h0707070707070707, data_in_dly[191:64]}									|                                                                      
			                 	 {256 {(no_shift 	&  eof 	 & !(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28))}}				&	{64'h0707070707070707, data_out_eof[255:64]}														;	                                   
		
			data_out_4		<=   {256{(shift 		& sof4)																				}}										& 	{data_in_dly[95:0],data_in_dly_1 [255:96]} 															|                                                                                                                                                                              							
								 {256 {(shift4      & !eof      & 	!sof_eof_same_frame	&	!(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28) & !invalid_sof)}}  	&	{data_in_dly[95:0],data_in_dly_1[255:96]}                                                           |
								// {256{(shift4 		& !eof 		& 	sof_eof_same_frame )												}}	& 	{data_in_dly[95:0],data_in_dly_1 [255:96]} 															|                                         
								 {256{(shift4 		& !eof 		&  	sof_eof_same_frame & !sof8_eof_same_frame & !sof12_eof_same_frame)	}}						& 	{data_in_dly[95:0],data_in_dly_1 [255:96]} 															|        
								 {256{(shift4 		& !eof 		&  	sof8_eof_same_frame)												}}						& 	{32'h07070707,data_in_dly[63:0],data_in_dly_1 [255:96]} 											|                                 
                            	 {256{(shift4 		& !eof 		&  	sof12_eof_same_frame)												}}						& 	{32'h07070707,data_in_dly[63:0],data_in_dly_1 [255:96]} 											|                                
								 {256{(shift4		&  eof 		& 	sof8)																}}						&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|                                
								 {256{(shift4		&  eof 		& 	sof12)																}}						&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|                                
								 {256{(shift4		&  eof 		& 	sof16)																}}						&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|  
								 {256{(shift4		&  !eof	 	&   invalid_sof)														}}						&	{data_out_eof [95:0], data_in_dly_1[255:96]}						                                |
								 {256{(sof20 		&  eof	 	& 	shift4)																}}						&	{64'h0707070707070707,32'h07070707,64'h0707070707070707,64'h0707070707070707, data_in_dly_1[127:96]}|
								 {256{(sof24		&  eof	 	& 	shift4)																}}						&	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707, data_in_dly[159:96]}				| 
								 {256{(sof28		&  eof	 	& 	shift4)																}}						&	{64'h0707070707070707,64'h0707070707070707,32'h07070707, data_in_dly[191:96]}						|   	                              
								 {256{(shift4 		&  eof 	& 	!(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28))			}}						& 	{32'h07070707,64'h0707070707070707,data_out_eof [255:96]}											;
								
								 
								
		 	data_out_8		<=	//{256{(sof8			&  	eof		&	!no_shift & !shift8)												}}	& 	{data_in_dly[127:0],data_in_dly_1 [255:128]} 											        |                                                                               	
								{256{(sof8			&  	shift 	& 	!eof &	!flag0)														}}	& 	{data_in_dly[127:0],data_in_dly_1[255:128]} 														|
								{256{(shift8		& 	!eof	& 	!sof_eof_same_frame & !invalid_sof)												}}	& 	{data_in_dly[127:0],data_in_dly_1[255:128]} 														|
								{256{(shift8 		& 	!eof 	&  	(sof8_eof_same_frame | sof12_eof_same_frame))						}}	& 	{64'h0707070707070707,data_in_dly [63:0],data_in_dly_1[255:128]} 									|
								{256{(shift8 		& 	!eof 	&  	sof_eof_same_frame & (!sof8_eof_same_frame & !sof12_eof_same_frame))}}	& 	{data_in_dly [127:0],data_in_dly_1[255:128]} 														|
								{256{(shift8		&	eof  	& 	sof8)																}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							| 
								{256{(shift8		&	eof  	& 	sof12)																}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							| 
								{256{(shift8		&	eof  	& 	sof16)																}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							| 
								{256{(shift8		&	eof  	& 	sof20)																}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							| 
								{256{(sof24			&  	eof	 	&   shift8)																}}	&	{64'h0707070707070707,32'h07070707,64'h0707070707070707,64'h0707070707070707, data_in_dly[159:128]}	| 
								{256{(sof28			&  	eof	 	&   shift8)																}}	&	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707, data_in_dly[191:128]}				| 
								{256{(shift8			&  !eof	 	&   invalid_sof)													}}	&	{data_out_eof [127:0], data_in_dly_1[255:128]}														| 
								{256{(shift8		&  	eof 	& !(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))						}}	& 	{64'h0707070707070707,64'h0707070707070707,data_out_eof [255:128]}									;
								
								//shifting Data by 12 Bytes                                                                                                                              
								//extra condition                                                                                                                                          
			data_out_12		<=	//{256{(sof12		&  eof		&	!no_shift 	& !shift12)												}}	& 	{data_in_dly[159:0],data_in_dly_1 [255:160]} 														|                                                                                                                               		
								{256{(sof12		&  shift 	& 	!eof		&	!flag0)												}}	& 	{data_in_dly[159:0],data_in_dly_1[255:160]} 														|                                                         
								
								{256{(shift12	& !eof	 	& 	!sof_eof_same_frame & !invalid_sof)									}}	& 	{data_in_dly[159:0],data_in_dly_1[255:160]} 														|                                            
								{256{(shift12 	& !eof 	 	&  	sof8_eof_same_frame)												}}	& 	{32'h07070707,64'h0707070707070707,data_in_dly [63:0],data_in_dly_1 [255:160]} 						|
								{256{(shift12 	& !eof 	 	&  	sof12_eof_same_frame)												}}	& 	{32'h07070707,64'h0707070707070707,data_in_dly [63:0],data_in_dly_1 [255:160]}						|
								{256{(shift12 	& !eof 	 	&  	sof16_eof_same_frame)												}}	& 	{64'h0707070707070707,data_in_dly [95:0],data_in_dly_1 [255:160]} 									| 
								{256{((shift12 	& !eof 	 	&  	sof_eof_same_frame) 											&   
								(!sof16_eof_same_frame & !sof12_eof_same_frame & !sof8_eof_same_frame))								}}	&	 {data_in_dly [159:0],data_in_dly_1 [255:160]} 														|     
								{256{(shift12	&	eof  	& sof8)																	}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							| 
								{256{(shift12	&	eof  	& sof12)																	}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|      
								{256{(shift12	&	eof  	& sof16)																	}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|       
								{256{(shift12	&	eof  	& sof20)																	}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|       
								{256{(shift12	&  !eof	 	& invalid_sof)																}}	&	{data_out_eof [159:0], data_in_dly_1[255:160]}		|	
								{256{(shift12	&	eof  	& sof24)																	}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|      
								{256{(sof28		&  eof	 	& shift12)																	}}	&	{64'h0707070707070707,32'h07070707,64'h0707070707070707,64'h0707070707070707, data_in_dly[191:160]}	|                                
								{256{(shift12	&  eof 	 	& !(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))							}}	& 	{32'h07070707,64'h0707070707070707,64'h0707070707070707,data_out_eof [255:160]}					; 
								
								//
								 
								
								//Shifting Data by 16 Bytes 
			data_out_16		<=	//{256{(sof16		&  eof		& !no_shift &	!shift)												}}	& 	{data_in_dly[191:0],data_in_dly_1 [255:192]} 													|                                                                         		
								{256{(sof16		&  shift 	& !eof	&	!flag0)													}}	& 	{data_in_dly[191:0],data_in_dly_1[255:192]} 													|                                                                                        
								{256{(shift16	& !eof	 	& !sof_eof_same_frame & !invalid_sof)								}}	& 	{data_in_dly[191:0],data_in_dly_1[255:192]} 													|
								{256{(shift16 	& !eof 	 	&  sof8_eof_same_frame)												}}	& 	{64'h0707070707070707,64'h0707070707070707,data_in_dly [63:0],data_in_dly_1 [255:192]} 			|
								{256{(shift16 	& !eof 	 	&  sof12_eof_same_frame)											}}	& 	{64'h0707070707070707,64'h0707070707070707,data_in_dly [63:0],data_in_dly_1 [255:192]}			|
								{256{(shift16 	& !eof 	 	&  sof16_eof_same_frame)											}}	& 	{32'h07070707,64'h0707070707070707,data_in_dly [95:0],data_in_dly_1 [255:192]} 					|
								{256{(shift16 	& !eof 	 	&  sof20_eof_same_frame)											}}	& 	{64'h0707070707070707,data_in_dly [127:0],data_in_dly_1 [255:192]} 								| 
								{256{((shift16 	& !eof 	 	&  sof_eof_same_frame) 								&											                                                                                                            
						    	(sof24_eof_same_frame | sof28_eof_same_frame))													}}	& 	{data_in_dly [191:0],data_in_dly_1 [255:192]} 													|  
						    	{256{(shift16	&	eof  	& sof8)																}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 						| 	   
						    	{256{(shift16	&	eof  	& sof12)															}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 						|  
						    	{256{(shift16	&	eof  	& sof16)															}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 						|  
						    	{256{(shift16	&	eof  	& sof20)															}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 						|  
						    	{256{(shift16	&	eof  	& sof24)															}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 						|  
						    	{256{(shift16	&	eof  	& sof28)															}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 						|                                          
								{256{(shift16	&  !eof	 	& invalid_sof)														}}	&	{data_out_eof [191:0], data_in_dly_1[255:192]}		|	
						    	{256{(shift16	&  eof 	 	& !(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))					}}	& 	{32'h07070707,32'h07070707,64'h0707070707070707,64'h0707070707070707,data_out_eof [255:192]}	;
								
								//shifting by 20 BYtes                                                                     
			data_out_20		<=	//{256{(sof20		&  eof		&	!shift4	& !no_shift & !shift20)						}}					& 	{data_in_dly[223:0],data_in_dly_1 [255:224]} 			                                    			    |                                                                                                                                                               		                                                                                                        	
								{256{(sof20		&  shift 	& 	!eof	&	!flag0)									}}					& 	{data_in_dly[223:0],data_in_dly_1[255:224]} 																|                                                                              
								{256{(shift20	& !eof	 	& 	!sof_eof_same_frame & !invalid_sof)					}}					& 	{data_in_dly[223:0],data_in_dly_1[255:224]} 																|  
								{256{(shift20 	& !eof 	 	& 	 sof8_eof_same_frame)								}}					& 	{64'h0707070707070707,32'h07070707,64'h0707070707070707,data_in_dly [63:0],data_in_dly_1 [255:224]}			|
								{256{(shift20 	& !eof 	 	& 	 sof12_eof_same_frame)								}}					& 	{64'h0707070707070707,32'h07070707,64'h0707070707070707,data_in_dly [63:0],data_in_dly_1 [255:224]}			|
								{256{(shift20 	& !eof 	 	& 	 sof16_eof_same_frame)								}}					& 	{64'h0707070707070707,64'h0707070707070707,data_in_dly [95:0],data_in_dly_1 [255:224]} 						|         
								{256{(shift20 	& !eof 	 	& 	 sof20_eof_same_frame)								}}					& 	{64'h0707070707070707,32'h07070707,data_in_dly [127:0],data_in_dly_1 [255:224]} 							|
								{256{(shift20 	& !eof 	 	& 	 sof24_eof_same_frame)								}}					& 	{64'h0707070707070707,64'h0707070707070707,data_in_dly [159:0],data_in_dly_1 [255:224]} 			    	|                                                                     
								{256{(shift20 	& !eof 	 	& 	 sof_eof_same_frame & sof28_eof_same_frame)			}}					& 	{64'h0707070707070707,data_in_dly [159:0],data_in_dly_1 [255:224]} 											| 
								{256{(shift20	&	eof  	& 	sof8)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}									| 
								{256{(shift20	&	eof  	& 	sof12)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}									|
								{256{(shift20	&	eof  	& 	sof16)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}									|
								{256{(shift20	&	eof  	& 	sof20)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}									|
								{256{(shift20	&	eof  	& 	sof24)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}									|
								{256{(shift20	&	eof  	& 	sof28)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}									|                                              
								{256{(shift20	&  !eof	 	& invalid_sof)														}}	&	{data_out_eof [223:0], data_in_dly_1[255:224]}		|	
								{256{(shift20	&  eof 	 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))	}}					& 	{32'h07070707,32'h07070707,32'h07070707,64'h0707070707070707,64'h0707070707070707,data_out_eof [255:224]}	;    
								
								 //shift by 24 Bytes                                          
			data_out_24		<=	// {256{(sof24	&  eof		&	!shift8 & !shift4	& !no_shift & !shift24)			}}					& 	{data_in_dly[255:0]} 			                                    					|                                                                                                                                                                                                                                             		                                                                                                        	    
								 {256{(sof24 	&  shift 	& 	!eof	&	!flag0)									}}					& 	{data_in_dly[255:0]} 																	|                                                                                                   
								 {256{(shift24	& !eof	 	& 	!sof_eof_same_frame	&	!invalid_sof)				}}					& 	{data_in_dly[255:0]} 																	| 
								 {256{(shift24 	& !eof 	 	& 	sof8_eof_same_frame)								}}					& 	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,data_in_dly [63:0]}		|  
								 {256{(shift24 	& !eof 	 	& 	sof12_eof_same_frame)								}}					& 	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,data_in_dly [63:0]}		|
								 {256{(shift24 	& !eof 	 	& 	sof16_eof_same_frame)								}}					& 	{32'h07070707,64'h0707070707070707,64'h0707070707070707,data_in_dly [95:0]} 			|         
								 {256{(shift24 	& !eof 	 	& 	sof20_eof_same_frame)								}}					& 	{32'h07070707,64'h0707070707070707,32'h07070707,data_in_dly [127:0]} 					|               
								 {256{(shift24 	& !eof 	 	& 	sof24_eof_same_frame)								}}					& 	{32'h07070707,64'h0707070707070707,data_in_dly [159:0]} 								|
								 {256{(shift24 	& !eof 	 	& 	sof28_eof_same_frame)								}}					& 	{64'h0707070707070707,data_in_dly [191:0]} 												| 
								 {256{(shift24	&	eof  	& 	sof8)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 				| 
								 {256{(shift24	&	eof  	& 	sof12)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 				|
								 {256{(shift24	&	eof  	& 	sof16)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 				|
								 {256{(shift24	&	eof  	& 	sof20)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 				|
								 {256{(shift24	&	eof  	& 	sof24)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 				|
								 {256{(shift24	&  !eof	 	& 	invalid_sof)										}}					&	{data_out_eof}																			|	
								 {256{(shift24	&	eof  	& 	sof28)												}}					&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 				|                                                                                      		
								 {256{(shift24	&  eof 	 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))	}}					& 	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,64'h0707070707070707}	;  
								
								 //shift by 28 BYtes                                                                                   
			data_out_28		<=	//{256{(sof28		&  	eof		&	!shift12 & !shift8 & !shift4	& !no_shift & !shift28)	}}				&	{data_in[31:0],data_in_dly[255:32]} 			                                    				|                                                                                                                                                                                                                                                                                  		                                                                                                        	     
								{256{(sof28 	&  	shift 	& 	!eof	&	!flag0)										}}				&	{data_in[31:0],data_in_dly[255:32]}																	|                                                                                                                    
								{256{(shift28	& !	eof	 	& 	!sof_eof_same_frame	&	!invalid_sof)					}}				&	{data_in[31:0],data_in_dly[255:32]}																	|   
								{256{(shift28 	&  	eof 	&  	sof8_eof_same_frame)									}}				&	{32'h07070707,64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,data_in_dly [63:32]}	| 
								{256{(shift28 	&  	eof 	&  	sof12_eof_same_frame)									}}				&	{32'h07070707,64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,data_in_dly [63:32]}	|
								{256{(shift28 	&  	eof 	&  	sof16_eof_same_frame)									}}				&	{32'h07070707,32'h07070707,64'h0707070707070707,64'h0707070707070707,data_in_dly [95:32]} 			|
								{256{(shift28 	&  	eof 	&  	sof20_eof_same_frame)									}}				&	{32'h07070707,32'h07070707,64'h0707070707070707,32'h07070707,data_in_dly [127:32]} 					|           
								{256{(shift28 	&  	eof 	&  	sof24_eof_same_frame)									}}				&	{64'h0707070707070707,64'h0707070707070707,data_in_dly [159:32]} 											|                                                                                                                         
				            	{256{(shift28 	&  	eof 	&  	sof28_eof_same_frame)									}}				&	{32'h07070707,64'h0707070707070707,data_in_dly [191:32]} 											|   
				            	{256{(shift28	&	eof  	& 	sof8)													}}				&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							| 
				            	{256{(shift28	&	eof  	& 	sof12)													}}				&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|
				            	{256{(shift28	&	eof  	& 	sof16)													}}				&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|
				            	{256{(shift28	&	eof  	& 	sof20)													}}				&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|
				            	{256{(shift28	&	eof  	& 	sof24)													}}				&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|
				            	{256{(shift28	&  !eof	 	& 	invalid_sof)											}}				&	{32'h07070707, data_out_eof[255:32]}		|	
				            	{256{(shift28	&	eof  	& 	sof28)													}}				&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707} 							|                                                 
								{256{(shift28	&  	eof 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28) & !sof_eof_same_frame) & invalid_sof}}	&	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707}			| 
				            	{256{(shift28	&  	eof 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28) & !sof_eof_same_frame) & !invalid_sof}}	&	{32'h07070707,data_out_eof[255:32]}																	;  
						    	                                                              
						    	     
								
			data_out_without_shift	<=	{256{(!no_shift & !shift & !eof & !(sof0 | sof4 | sof8 | sof12 | sof16 | sof20 | sof24 | sof28))}} 	&	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707 				|
										{256{ flag0																						}}	& 	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,64'h0707070707070707}	|
										{256{(!shift  & !no_shift  & !sof_eof_same_frame &                                            
										!sof0 & !sof4 & !sof8 & !sof12 & !sof16 & !sof20 & !sof24 &  !sof28)							}}	&	{64'h0707070707070707,64'h0707070707070707,64'h0707070707070707,64'h0707070707070707}	;
										                                                 
											
										
			data_out				<=	{256{(br_sof0_d 	| (d_no_shift | no_shift))	}}					&	data_out_0 	|
										{256{(br_sof4_d 	| (d_shift & (d_shift4   | shift4  )))		}}	&	data_out_4	|
										{256{(br_sof8_d 	| (d_shift & (d_shift8   | shift8  )))		}}	&	data_out_8	|
										{256{(br_sof12_d 	| (d_shift & (d_shift12  | shift12 )))	}}	&	data_out_12	|
										{256{(br_sof16_d 	| (d_shift & (d_shift16  | shift16 )))	}}	&	data_out_16	|
										{256{(br_sof20_d 	| (d_shift & (d_shift20  | shift20 )))	}}	&	data_out_20	|
										{256{(br_sof24_d 	| (d_shift & (d_shift24  | shift24 )))	}}	&	data_out_24	|
										{256{(br_sof28_d 	| (d_shift & (d_shift28  | shift28 )))	}}	&	data_out_28	|
										{256{(!d_shift	| !d_no_shift)	}}	&	data_out_without_shift ;
										
		 ctrl_out_0		<=	 	{32 {sof0 																											}}			& 	{ctrl_in_dly[7:0],ctrl_in_dly_1[31:8]}															| 
					 			{32 {(no_shift    & !eof   & !(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28)	&	!invalid_sof)		}}         	&	{ctrl_in_dly[7:0],ctrl_in_dly_1[31:8]}															|
					 			{32 {(sof8 		&  eof	 & no_shift)															}}			&	{32'hff_ff_ff_ff}																				| 
					 			{32 {(sof12 		&  eof	 & no_shift)														}}			&	{32'hff_ff_ff_ff}																				|
					 			{32 {(sof16 		&  eof	 & no_shift)														}}			&	{8'hff,4'hf,8'hff,8'hff, ctrl_in_dly_1[11:8]}													|
					 			{32 {(sof20 		&  eof	 & no_shift)														}}			&	{8'hff,8'hff,8'hff, ctrl_in_dly_1[15:8]}														|
					 			{32 {(sof24		&  eof	 & no_shift)															}}			&	{8'hff,4'hf,8'hff, ctrl_in_dly[19:8]}															|  
					 			{32{(no_shift	&  !eof	 &   invalid_sof)														}}			&	{ctrl_out_eof [7:0], ctrl_in_dly_1[31:8]}	                         |
					 			{32 {(sof28		&  eof	 & no_shift)															}}			&	{8'hff,8'hff, ctrl_in_dly[23:8]}																|            
                 	 			{32 {(no_shift 	&  eof 	 & !(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28))		}}			&	{8'hff, ctrl_out_eof[31:8]}														;	         

				ctrl_out_4		<=   {32{(shift 		& sof4)																				}}						& 	{ctrl_in_dly[11:0],ctrl_in_dly_1 [31:12]} 				|								
									 {32 {(shift4      & !eof      & 	!sof_eof_same_frame	&	!(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28) & !invalid_sof)}}  	&	{ctrl_in_dly[11:0],ctrl_in_dly_1[31:12]}                |                                
									// {256{(shift4 		& !eof 		& 	sof_eof_same_frame )												}}	& 	{data_in_dly[95:0],data_in_dly_1 [255:96]} 								   
									 {32{(shift4 		& !eof 		&  	sof_eof_same_frame & !sof8_eof_same_frame & !sof12_eof_same_frame)	}}						& 	{ctrl_in_dly[11:0],ctrl_in_dly_1 [31:12]} 				|								
									 {32{(shift4 		& !eof 		&  	sof8_eof_same_frame)												}}						& 	{4'hf,ctrl_in_dly[7:0],ctrl_in_dly_1 [31:12]} 			|					
				                	 {32{(shift4 		& !eof 		&  	sof12_eof_same_frame)												}}						& 	{4'hf,ctrl_in_dly[7:0],ctrl_in_dly_1 [31:12]} 			|					
									 {32{(shift4		&  eof 		& 	sof8)																}}						&	{32'hff_ff_ff_ff} 				                        |
									 {32{(shift4		&  eof 		& 	sof12)																}}						&	{32'hff_ff_ff_ff} 				                        |
									 {32{(shift4		&  eof 		& 	sof16)																}}						&	{32'hff_ff_ff_ff} 				                        |
									 {32{(sof20 		&  eof	 	& 	shift4)																}}						&	{8'hff,4'hf,8'hff,8'hff, ctrl_in_dly_1[15:12]}			|                 
									 {32{(sof24		&  eof	 	& 	shift4)																	}}						&	{8'hff,8'hff,8'hff, ctrl_in_dly[19:12]}					|
									 {32{(shift4	&  !eof	 	&   invalid_sof)															}}						&	{ctrl_out_eof [11:0], ctrl_in_dly_1[31:12]}	            |             
									 {32{(sof28		&  eof	 	& 	shift4)																	}}						&	{8'hff,8'hff,4'hf,  ctrl_in_dly[23:12]}			 		|
									 {32{(shift4 		&  eof 	& 	!(sof0 | sof4 |sof8 | sof12 | sof16 | sof20 | sof24 | sof28))			}}						& 	{4'hf,8'hff,ctrl_out_eof [31:12]}						;	
									
									 
									
				ctrl_out_8		<=	//{256{(sof8			&  	eof		&	!no_shift & !shift8)												}}	& 	{data_in_dly[127:0],data_in_dly_1 [255:128]} 											            |    
									{32{(sof8		&  	shift 	& 	!eof &	!flag0)														}}	& 	{ctrl_in_dly[15:0],ctrl_in_dly_1[31:16]} 						|
									{32{(shift8		& 	!eof	& 	!sof_eof_same_frame	&	!invalid_sof)								}}	& 	{ctrl_in_dly[15:0],ctrl_in_dly_1[31:16]} 						|
									{32{(shift8 	& 	!eof 	&  	(sof8_eof_same_frame | sof12_eof_same_frame))						}}	& 	{8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1[31:16]} 					|
									{32{(shift8 	& 	!eof 	&  	sof_eof_same_frame & (!sof8_eof_same_frame & !sof12_eof_same_frame))}}	& 	{ctrl_in_dly [15:0],ctrl_in_dly_1[31:16]} 						|
									{32{(shift8		&	eof  	& 	sof8)																}}	&	{32'hff_ff_ff_ff}												| 
									{32{(shift8		&	eof  	& 	sof12)																}}	&	{32'hff_ff_ff_ff}												| 
									{32{(shift8		&	eof  	& 	sof16)																}}	&	{32'hff_ff_ff_ff}												| 
									{32{(shift8		&	eof  	& 	sof20)																}}	&	{32'hff_ff_ff_ff}												| 
									{32{(sof24		&  	eof	 	& shift8)																}}	&	{8'hff,4'hf,8'hff,8'hff, ctrl_in_dly[19:16]}					|
									{32{(sof28		&  	eof	 	& shift8)																}}	&	{8'hff,8'hff,8'hff, ctrl_in_dly[23:16]}							|
									{32{(shift8		&  !eof	 	&   invalid_sof)														}}	&	{ctrl_out_eof [15:0], ctrl_in_dly_1[31:16]}	                         |
									{32{(shift8		&  	eof 	& !(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))						}}	& 	{8'hff,8'hff,ctrl_out_eof [31:16]}									;
									
									//shifting Data by 12 Bytes                                                                                                                              
									//extra condition                                                                                                                                          
				ctrl_out_12		<=	//{256{(sof12		&  eof		&	!no_shift 	& !shift12)												}}	& 	{data_in_dly[159:0],data_in_dly_1 [255:160]} 														|        
									{32{(sof12		&  shift 	& 	!eof		&	!flag0)												}}	& 	{ctrl_in_dly[19:0],ctrl_in_dly_1[31:20]} 													|            
									{32{(shift12	& !eof	 	& 	!sof_eof_same_frame	&	!invalid_sof)								}}	& 	{ctrl_in_dly[19:0],ctrl_in_dly_1[31:20]} 													|            
									{32{(shift12 	& !eof 	 	&  	sof8_eof_same_frame)												}}	& 	{4'hf,8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1 [31:20]} 										|
									{32{(shift12 	& !eof 	 	&  	sof12_eof_same_frame)												}}	& 	{4'hf,8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1 [31:20]}										|
									{32{(shift12 	& !eof 	 	&  	sof16_eof_same_frame)												}}	& 	{8'hff,ctrl_in_dly [11:0],ctrl_in_dly_1 [31:20]} 											| 
									{32{((shift12 	& !eof 	 	&  	sof_eof_same_frame) 											&   
									(!sof16_eof_same_frame & !sof12_eof_same_frame & !sof8_eof_same_frame))								}}	&	 {ctrl_in_dly [19:0],ctrl_in_dly_1 [31:20]} 												|     
									{32{(shift12	&	eof  	& sof8)																	}}	&	{32'hff_ff_ff_ff} 						| 
									{32{(shift12	&	eof  	& sof12)																}}	&	{32'hff_ff_ff_ff} 																			|      
									{32{(shift12	&	eof  	& sof16)																}}	&	{32'hff_ff_ff_ff} 																			|       
									{32{(shift12	&	eof  	& sof20)																}}	&	{32'hff_ff_ff_ff} 																			|       
									{32{(shift12	&	eof  	& sof24)																}}	&	{32'hff_ff_ff_ff} 																			|      
									{32{(shift12		&  !eof	 	&   invalid_sof)													}}	&	{ctrl_out_eof [19:0], ctrl_in_dly_1[31:20]}	                         |
									{32{(sof28		&  eof	 	& shift12)																}}	&	{8'hff,4'hf,8'hff,8'hff, ctrl_in_dly[23:20]}												|        
									{32{(shift12	&  eof 	 	& !(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))						}}	& 	{4'hf,8'hff,8'hff,ctrl_out_eof [31:20]}					; 
									
									//
									 
									
									//Shifting Data by 16 Bytes 
				ctrl_out_16		<=	//{256{(sof16		&  eof		& !no_shift &	!shift)												}}	& 	{data_in_dly[191:0],data_in_dly_1 [255:192]} 													|                
									{32{(sof16		&  shift 	& !eof	&	!flag0)													}}	& 	{ctrl_in_dly[23:0],ctrl_in_dly_1[31:24]} 					|                    
									{32{(shift16	& !eof	 	& !sof_eof_same_frame	&	!invalid_sof)							}}	& 	{ctrl_in_dly[23:0],ctrl_in_dly_1[31:24]} 					|
									{32{(shift16 	& !eof 	 	&  sof8_eof_same_frame)												}}	& 	{8'hff,8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1 [31:24]} 		|
									{32{(shift16 	& !eof 	 	&  sof12_eof_same_frame)											}}	& 	{8'hff,8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1 [31:24]}		|
									{32{(shift16 	& !eof 	 	&  sof16_eof_same_frame)											}}	& 	{4'hf,8'hff,ctrl_in_dly [11:0],ctrl_in_dly_1 [31:24]} 		|
									{32{(shift16 	& !eof 	 	&  sof20_eof_same_frame)											}}	& 	{8'hff,ctrl_in_dly [15:0],ctrl_in_dly_1 [31:24]} 			| 
									{32{((shift16 	& !eof 	 	&  sof_eof_same_frame) 								&											                                                                                                 
							    	(sof24_eof_same_frame | sof28_eof_same_frame))													}}	& 	{ctrl_in_dly [23:0],ctrl_in_dly_1 [31:24]} 					|  
							    	{32{(shift16	&	eof  	& sof8)																}}	&	{32'hff_Ff_ff_ff} 						| 	   
							    	{32{(shift16	&	eof  	& sof12)															}}	&	{32'hff_Ff_ff_ff} 						|  
							    	{32{(shift16	&	eof  	& sof16)															}}	&	{32'hff_Ff_ff_ff} 						|  
							    	{32{(shift16	&	eof  	& sof20)															}}	&	{32'hff_Ff_ff_ff} 						|  
							    	{32{(shift16	&	eof  	& sof24)															}}	&	{32'hff_Ff_ff_ff} 						|  
							    	{32{(shift16	&	eof  	& sof28)															}}	&	{32'hff_Ff_ff_ff} 						|                    
									{32{(shift16	&  !eof	 	&   invalid_sof)													}}	&	{ctrl_out_eof [23:0], ctrl_in_dly_1[31:24]}	                         |
							    	{32{(shift16	&  eof 	 	& !(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))					}}	& 	{4'hf,4'hf,8'hff,8'hff,ctrl_out_eof [31:24]}	;
									
									//shifting by 20 BYtes                                                                     
				ctrl_out_20		<=	//{256{(sof20		&  eof		&	!shift4	& !no_shift & !shift20)						}}					& 	{data_in_dly[223:0],data_in_dly_1 [255:224]} 			                                    			    |
									{32{(sof20		&  shift 	& 	!eof	&	!flag0)									}}					& 	{ctrl_in_dly[27:0],ctrl_in_dly_1[31:28]} 																|    
									{32{(shift20	& !eof	 	& 	!sof_eof_same_frame	&	!invalid_sof)				}}					& 	{ctrl_in_dly[27:0],ctrl_in_dly_1[31:28]} 																|  
									{32{(shift20 	& !eof 	 	& 	 sof8_eof_same_frame)								}}					& 	{8'hff,4'hf,8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1 [31:28]}			|
									{32{(shift20 	& !eof 	 	& 	 sof12_eof_same_frame)								}}					& 	{8'hff,4'hf,8'hff,ctrl_in_dly [7:0],ctrl_in_dly_1 [31:28]}			|
									{32{(shift20 	& !eof 	 	& 	 sof16_eof_same_frame)								}}					& 	{8'hff,8'hff,ctrl_in_dly [11:0],ctrl_in_dly_1 [31:28]} 						|    
									{32{(shift20 	& !eof 	 	& 	 sof20_eof_same_frame)								}}					& 	{8'hff,4'hf,ctrl_in_dly [15:0] ,ctrl_in_dly_1 [31:28]} 							|
									{32{(shift20 	& !eof 	 	& 	 sof24_eof_same_frame)								}}					& 	{8'hff,8'hff,ctrl_in_dly [19:0],ctrl_in_dly_1 [31:28]} 			    	|    
									{32{(shift20 	& !eof 	 	& 	 sof_eof_same_frame & sof28_eof_same_frame)			}}					& 	{8'hff,ctrl_in_dly [19:0],ctrl_in_dly_1 [31:28]} 											| 
									{32{(shift20	&	eof  	& 	sof8)												}}					&	{32'hff_ff_ff_ff}									| 
									{32{(shift20	&	eof  	& 	sof12)												}}					&	{32'hff_ff_ff_ff}									|
									{32{(shift20	&	eof  	& 	sof16)												}}					&	{32'hff_ff_ff_ff}									|
									{32{(shift20	&	eof  	& 	sof20)												}}					&	{32'hff_ff_ff_ff}									|
									{32{(shift20	&	eof  	& 	sof24)												}}					&	{32'hff_ff_ff_ff}									|
									{32{(shift20	&	eof  	& 	sof28)												}}					&	{32'hff_ff_ff_ff}									|    
									{32{(shift20	&  !eof	 	&   invalid_sof)										}}					&	{ctrl_out_eof [27:0], ctrl_in_dly_1[31:28]}	                         |
									{32{(shift20	&  eof 	 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))	}}					& 	{4'hf,8'hff,8'hff,8'hff,ctrl_out_eof [31:28]}	;    
									
									 //shift by 24 Bytes                                          
				ctrl_out_24		<=	// {256{(sof24	&  eof		&	!shift8 & !shift4	& !no_shift & !shift24)			}}					& 	{data_in_dly[255:0]} 			                                    					|                        
									 {32{(sof24 	&  shift 	& 	!eof	&	!flag0)									}}					& 	{ctrl_in_dly[31:0]} 						|                        
									 {32{(shift24	& !eof	 	& 	!sof_eof_same_frame	&	!invalid_sof)				}}					& 	{ctrl_in_dly[31:0]} 						| 
									 {32{(shift24 	& !eof 	 	& 	sof8_eof_same_frame)								}}					& 	{8'hff,8'hff,8'hff,ctrl_in_dly [7:0]}		|  
									 {32{(shift24 	& !eof 	 	& 	sof12_eof_same_frame)								}}					& 	{8'hff,8'hff,8'hff,ctrl_in_dly [7:0]}		|
									 {32{(shift24 	& !eof 	 	& 	sof16_eof_same_frame)								}}					& 	{4'hf,8'hff,8'hff,ctrl_in_dly [11:0]} 		|         
									 {32{(shift24 	& !eof 	 	& 	sof20_eof_same_frame)								}}					& 	{4'hf,8'hff,4'hf,ctrl_in_dly [15:0]} 		|               
									 {32{(shift24 	& !eof 	 	& 	sof24_eof_same_frame)								}}					& 	{4'hf,8'hff,ctrl_in_dly [19:0]} 			|
									 {32{(shift24 	& !eof 	 	& 	sof28_eof_same_frame)								}}					& 	{8'hff,ctrl_in_dly [23:0]} 					| 
									 {32{(shift24	&	eof  	& 	sof8)												}}					&	{32'hff_ff_ff_ff} 							| 
									 {32{(shift24	&	eof  	& 	sof12)												}}					&	{32'hff_ff_ff_ff} 							|
									 {32{(shift24	&	eof  	& 	sof16)												}}					&	{32'hff_ff_ff_ff} 							|
									 {32{(shift24	&	eof  	& 	sof20)												}}					&	{32'hff_ff_ff_ff} 							|
									 {32{(shift24	&	eof  	& 	sof24)												}}					&	{32'hff_ff_ff_ff} 							|
									 {32{(shift24	&	eof  	& 	sof28)												}}					&	{32'hff_ff_ff_ff} 							|                        
									 {32{(shift24	&  !eof	 	&   invalid_sof)										}}					&	{ctrl_out_eof}		                         |
									 {32{(shift24	&  eof 	 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28))	}}					& 	{32'hff_ff_ff_ff}	;  
									
									 //shift by 28 BYtes                                                                                   
				ctrl_out_28		<=	//{256{(sof28		&  	eof		&	!shift12 & !shift8 & !shift4	& !no_shift & !shift28)	}}				&	{data_in[31:0],data_in_dly[255:32]} 			                                    				|        
									{32{(sof28 	&  	shift 	& 	!eof	&	!flag0)										}}					&	{ctrl_in[31:0],ctrl_in_dly[31:4]}																	|            
									{32{(shift28	& !	eof	 	& 	!sof_eof_same_frame	&	!invalid_sof)				}}					&	{ctrl_in[31:0],ctrl_in_dly[31:4]}			|   
									{32{(shift28 	&  	eof 	&  	sof8_eof_same_frame)									}}				&	{4'hf,8'hff,8'hff,8'hff,ctrl_in_dly [7:4]}	| 
									{32{(shift28 	&  	eof 	&  	sof12_eof_same_frame)									}}				&	{4'hf,8'hff,8'hff,8'hff,ctrl_in_dly [7:4]}	|
									{32{(shift28 	&  	eof 	&  	sof16_eof_same_frame)									}}				&	{4'hf,4'hf, 8'hff,8'hff,ctrl_in_dly [11:4]} |
									{32{(shift28 	&  	eof 	&  	sof20_eof_same_frame)									}}				&	{4'hf,4'hf, 8'hff,4'hf, ctrl_in_dly [15:4]} |           
									{32{(shift28 	&  	eof 	&  	sof24_eof_same_frame)									}}				&	{4'hf,4'hf,8'hff,ctrl_in_dly [19:4]} 			|            
					            	{32{(shift28 	&  	eof 	&  	sof28_eof_same_frame)									}}				&	{4'hf,8'hff,ctrl_in_dly [23:4]} 			|   
					            	{32{(shift28	&	eof  	& 	sof8)													}}				&	{32'hff_ff_ff_ff} 							| 
					            	{32{(shift28	&	eof  	& 	sof12)													}}				&	{32'hff_ff_ff_ff} 							|
					            	{32{(shift28	&	eof  	& 	sof16)													}}				&	{32'hff_ff_ff_ff} 							|
					            	{32{(shift28	&	eof  	& 	sof20)													}}				&	{32'hff_ff_ff_ff} 							|
					            	{32{(shift28	&	eof  	& 	sof24)													}}				&	{32'hff_ff_ff_ff} 							|
					            	{32{(shift28	&	eof  	& 	sof28)													}}				&	{32'hff_ff_ff_ff} 							|            
									{32{(shift28	&  !eof	 	&   invalid_sof)											}}				&	{4'hf, ctrl_out_eof[31:4]}	                |
									{32{(shift28	&  	eof 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28) & !sof_eof_same_frame)	&	invalid_sof}}	&	{32'hffffffff}			|
					            	{32{(shift28	&  	eof 	& 	!(sof8 | sof12 | sof16 | sof20 | sof24 | sof28) & !sof_eof_same_frame)	&	!invalid_sof}}	&	{4'hf,ctrl_out_eof[31:4]};
									
				ctrl_out_without_shift	<=	{32{(!no_shift & !shift & !eof & !(sof0 | sof4 | sof8 | sof12 | sof16 | sof20 | sof24 | sof28))}} 	&	32'hff_ff_ff_ff 				|					
											{32{ flag0																						}}	& 	{32'hff_ff_ff_ff}	|                                                                         					
											{32{(!shift  & !no_shift  & !sof_eof_same_frame &                                                                                                                                                     					
											!sof0 & !sof4 & !sof8 & !sof12 & !sof16 & !sof20 & !sof24 &  !sof28)							}}	&	{32'hff_ff_ff_ff}	;                                					
							    	                                                              									
		ctrl_out				<=	 {32{(br_sof0_d 	| d_no_shift)}}	&       ctrl_out_0 	|             
		                             {32{(br_sof4_d 	| d_shift4) }}	&	ctrl_out_4	| 
		                             {32{(br_sof8_d 	| d_shift8)	}}	&	ctrl_out_8	| 
		                             {32{(br_sof12_d 	| d_shift12)	 	}}	&	    ctrl_out_12	|
		                             {32{(br_sof16_d 	| d_shift16)	 	}}	&	    ctrl_out_16	|
		                             {32{(br_sof20_d 	| d_shift20)	 	}}	&	    ctrl_out_20	|
		                             {32{(br_sof24_d 	| d_shift24)	 	}}	&	    ctrl_out_24	|
		                             {32{(br_sof28_d 	| d_shift28)	 	}}	&	    ctrl_out_28	|
		                             ctrl_out_without_shift	;
		                             
		end
end


always @ (posedge x_clk)
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


br_sfifo4x32	rf_sfifo (				 		//raw frame fifo
	.aclr		(!reset_ | !fmac_rxd_en156), 	//i-1
	.wrclk		(x_clk),					 	//i-1
	.data		(raw_frame_cnt156 ),		 	//i-32
	.wrreq		(!rf_sfifo_full),			 	//i-1
	.rdclk		(clk250),					 	//i-1
	.rdreq		(!rf_sfifo_empty),			 	//i-1
	.q			(rf_sfifo_dout ),				//o-32, 
	.rdempty	(rf_sfifo_empty),				//o-1
	.rdusedw	(),								//o-2,
	.wrfull		(rf_sfifo_full)					//o-1
	);
	

always @ (posedge clk250)
	if (!reset_ | !fmac_rxd_en )
		begin
		
		RAW_FRAME_CNT		<=	32'h0;
		
		end
	else
		begin
		
		RAW_FRAME_CNT		<=	rx_auto_clr_en ? 32'h0 : rf_sfifo_dout ;
		
		end
	
endmodule