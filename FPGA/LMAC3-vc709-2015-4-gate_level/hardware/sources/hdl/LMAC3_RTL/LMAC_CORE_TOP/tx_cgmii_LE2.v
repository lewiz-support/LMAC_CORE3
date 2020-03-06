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

module tx_cgmii(

	clk250,				//i-1, depends on speed_mode	
	clk156,	            //i-1, depends on speed_mode
	rst_,  	            //i-1, RESET
	
	mode_100G ,			//i-1, speed modes
	mode_50G  ,         //i-1
	mode_40G  ,	        //i-1
	mode_25G  ,	        //i-1
	mode_10G  ,	        //i-1
	
	xaui_mode,			//i-1
	
	rts,     			//i-1, request to send from encap
	rdata,              //i-256, data input
	txfifo_dout,		//i-256 bits from FIFO (previous data of rdata). This will help to calculate the crc earlier.
	rbytes,	            //i-16, holds the size of data in Bytes
	cts,	            //o-1, enable ENCAP to read the next QWD (NOT USED, keep for I/O compatibility)
	
	txd,	            //o-256, data_out
	txc,	            //o-32,  ctrl_out
	
	FMAC_TX_PKT_CNT,  	//o-32
	FMAC_TX_BYTE_CNT,	//o-32
	
	fmac_tx_clr_en,		//i-1

	tx_dvld             //i-1
	
	);
	
parameter DATA_WIDTH = 256,
	  	  CTRL_WIDTH = 32;

input clk250;                       //i-1, depends on speed_mode	          
input clk156;                       //i-1, depends on speed_mode           
input rst_;                         //i-1, RESET                           
                                                                           
input	mode_100G ;                 //i-1, speed modes                     
input	mode_50G  ;                 //i-1                                  
input	mode_25G;                   //i-1                                  
input 	mode_40G;                   //i-1                                  
input	mode_10G  ;                 //i-1                                  
                                                                           
input	xaui_mode	;               //i-1                                  
                                                                           
input   rts;                        //i-1, request to send from encap      
input   [DATA_WIDTH - 1:0] rdata;	//i-256, data input                    
input   [DATA_WIDTH - 1:0] txfifo_dout;		//i-256 bits from FIFO (previous data of rdata). This will help to calculate the crc earlier.
input   [15:0] rbytes;              //i-16, holds the size of data in Bytes
input   tx_dvld;                    //i-1


output	cts;		                //o-1, enable ENCAP to read the next QWD (NOT USED, keep for I/O compatibility)
wire    cts = 1'b0 ; 

output reg [DATA_WIDTH - 1:0] txd;     	//o-256, data_out
output reg [CTRL_WIDTH - 1:0] txc;      //o-32,  ctrl_out
                                                     
output reg	[31:0] FMAC_TX_PKT_CNT;      //o-32           
output reg	[31:0] FMAC_TX_BYTE_CNT;     //o-32           
                                                     
input		fmac_tx_clr_en;	        //i-1            

//buffer input data
reg    [DATA_WIDTH - 1:0] bdata1;
reg    [DATA_WIDTH - 1:0] bdata2;
reg    [DATA_WIDTH - 1:0] bdata3;

reg						data_vld;		//crc data valid
reg						data_eop;		//crc data end of frame
reg						data_sop;		//crc data start of frame
           	
reg		[15:0]			byte_cnt;
reg		[4:0]			data_be;		//0 - all bytes valid  (really is beat_bcnt)
										//1 - 1 byte valid bit[7:0]
										//..
										//7 - 7 bytes valid bit[55:0]
										
wire	[31:0]			crc_out;		//final generated crc32 value
wire					crc_vld;		//crc check valid
reg		[31:0]			crc_out_reg = 32'h0;	//delay of final generated crc32 value
reg						crc_vld_reg;	//delay of crc check valid

reg						tx_dvld_dly1;
reg						tx_dvld_dly2;
reg						tx_dvld_dly3;

reg		[15:0]			tx_byte_cnt;
reg		[15:0]			tx_byte_cnt_dly;

reg						tx_data_first;
reg						tx_data_first_dly1;
reg						tx_data_first_dly2;
reg						tx_data_first_dly3;
reg						tx_data_last;
reg						tx_data_last_dly1;
reg						tx_data_last_dly2;
reg						tx_data_last_dly3;

reg						tx_ndata_last_vld;	//ndata: no_data: just CRC and 8'hFD in last beat
reg						tx_ndata_last_vld_dly;

reg		[2:0]			tx_ndata_last_cnt;	//ndata: no_data: just CRC and 8'hFD in last beat
reg		[2:0]			tx_ndata_last_cnt_dly;

reg		[1:0]			cntr_speed;


eth_crc32_gen eth_crc32_gen_tx(
   /* i */ .clk			(clk156),		//clock
   /* i */ .rst_n		(rst_),			//active low reset
   
   /* i */ .mode_100G 	(mode_100G),	//i-1, speed modes
   /* i */ .mode_50G  	(mode_50G ),    //i-1
   /* i */ .mode_40G  	(mode_40G ),	//i-1
   /* i */ .mode_25G  	(mode_25G ),	//i-1
   /* i */ .mode_10G  	(mode_10G ),	//i-1
   
   /* i */ .data_vld	(data_vld),		//data valid
   /* i */ .data_eop	(data_eop),		//end of frame
   /* i */ .data_sop	(data_sop),		//start of frame
   
   /* i */ .data_in		({txfifo_dout[63:0], rdata[255:64]}),
                                    	
   /* i */ .data_be		(data_be),		//0 - all bytes valid  (really is beat_bcnt)
                        				//1 - 1 byte valid bit[7:0]
                        				//..
                        				//7 - 7 bytes valid bit[55:0]
   /* o */ .crc_out		(crc_out),		//final generated crc32 value
   /* o */ .crc_vld     (crc_vld)		//crc check valid
 );


	always @(posedge clk156) begin
		//buffer and delay signals
		bdata1			<=	rdata;
		bdata2			<=	bdata1;
		bdata3			<=	bdata2;
		tx_dvld_dly1	<=	tx_dvld;
		tx_dvld_dly2    <=	tx_dvld_dly1;
		tx_dvld_dly3    <=	tx_dvld_dly2;
		crc_out_reg		<=	(!rst_)?	32'h0	:
								(crc_vld)?	crc_out	:
								crc_out_reg;
		crc_vld_reg    	<=	crc_vld;
		
		tx_data_first_dly1	<=	tx_data_first;
		tx_data_first_dly2	<=	tx_data_first_dly1;
		tx_data_first_dly3	<=	tx_data_first_dly2;
		tx_data_last_dly1	<= 	tx_data_last;
		tx_data_last_dly2	<= 	tx_data_last_dly1;
		tx_data_last_dly3	<= 	tx_data_last_dly2;
		
		tx_ndata_last_vld_dly	<=	tx_ndata_last_vld;
		tx_ndata_last_cnt_dly	<=	tx_ndata_last_cnt;
	end

	always @(posedge clk156) begin
		if (!rst_) begin
			//initialization
			data_vld			<=	1'b0;
			data_eop			<=	1'b0;
			data_sop			<=	1'b0;
			byte_cnt			<=	16'h0;
			data_be				<=	5'b0;
			                	
			tx_byte_cnt			<=	16'h0;
			tx_byte_cnt_dly		<=	16'h0;
			tx_data_first		<=	1'b0;
			tx_data_last		<=	1'b0;
			
			cntr_speed			<=	2'b0;
		end
		else begin
			cntr_speed			<=	(mode_100G)?	2'b00	:
										(rts)?	2'b01	:
										((mode_50G | mode_40G) & (cntr_speed == 2'b01))?	2'b00	:
										(mode_25G & (cntr_speed == 2'b11))?	2'b00	:
										(cntr_speed + 1'b1);
													
			//sop delayed version of rts
			data_sop			<=	rts;
			
			tx_byte_cnt_dly		<=	tx_byte_cnt;
				
			if (rts) begin
				//byte_cnt to generate eop and data_be
				byte_cnt		<=	(txfifo_dout [15:0] - 16'h20);
										
				//byte_enable showing number of valid bytes in one beat.
				data_be			<=	5'b0;
				
				tx_byte_cnt		<=	(txfifo_dout [15:0] - 16'h18);
				
				tx_data_first	<=	1'b1;
			end
			else if (cntr_speed == 2'b0) begin
			
				/*----  CRC CONTROL SIGNAL ASSIGNMENTS ----*/
				
				//valid pulse should start after the sop
				data_vld		<=	(byte_cnt == 16'h0)?	1'b0	:
										tx_dvld;
										
				//eop with last crc data_in
				data_eop		<=	(tx_dvld & (byte_cnt <= 16'h20) & (byte_cnt != 16'h0));
				
				//byte_enable showing number of valid bytes in one beat.
				data_be			<=	(byte_cnt > 16'h20)?	5'b0	:
										byte_cnt;
										
				//byte_cnt to generate eop and data_be
				byte_cnt		<=	(byte_cnt > 16'h20)?	(byte_cnt - 16'h20)	:
										5'b0;
										
				/*----  CONTROL SIGNALS TO GENERATE TXD AND TXC ----*/
				
				tx_byte_cnt		<=	(tx_byte_cnt > 16'h20)?	(tx_byte_cnt - 16'h20)	:
										tx_byte_cnt;
										
				tx_data_first	<=	1'b0;
				tx_data_last	<=	(tx_data_last)?	1'b0	:
										(tx_dvld & (byte_cnt <= 16'h18));
			end
			else begin											
				data_vld		<=	1'b0;
				data_eop		<=	1'b0;
			end
		end
	end

	always @(posedge clk156) begin
		if (!rst_) begin
			//initialization
			txd			<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			txc			<=	32'hFFFF_FFFF;
			
			tx_ndata_last_vld	<=	1'b0;
			tx_ndata_last_cnt	<=	3'b0;
			
			FMAC_TX_PKT_CNT		<=	32'h0;
			FMAC_TX_BYTE_CNT	<=	32'h0;
		end
		else begin
		
			if (tx_data_last_dly2 & ((mode_25G & (cntr_speed == 2'b10)) | (!mode_25G & (cntr_speed == 2'b0)))) begin
				case (tx_byte_cnt)
					28	:	begin
								tx_ndata_last_vld	<=	1'b1;
								tx_ndata_last_cnt	<=	3'h1;
							end
					29	:	begin
								tx_ndata_last_vld	<=	1'b1;
								tx_ndata_last_cnt	<=	3'h2;
							end
					30	:	begin
								tx_ndata_last_vld	<=	1'b1;
								tx_ndata_last_cnt	<=	3'h3;
							end
					31	:	begin
								tx_ndata_last_vld	<=	1'b1;
								tx_ndata_last_cnt	<=	3'h4;
							end
					32	:	begin
								tx_ndata_last_vld	<=	1'b1;
								tx_ndata_last_cnt	<=	3'h5;
							end
				endcase
			end
			else if ((mode_25G & (cntr_speed == 2'b10)) | (!mode_25G & (cntr_speed == 2'b0))) begin
				tx_ndata_last_vld	<=	1'b0;
				tx_ndata_last_cnt	<=	3'h0;
			end
		
			//if ((mode_25G & (cntr_speed == 2'b11)) | ((mode_50G | mode_40G) & (cntr_speed == 2'b01)) | (mode_100G & (cntr_speed == 2'b0))) begin
			if (cntr_speed == 2'b0) begin
				if (tx_dvld_dly3 & tx_data_last_dly3) begin
					case (tx_byte_cnt_dly)
						1	:	begin
							txd		<=	{216'h0707070707070707_0707070707070707_0707070707070707_0707FD, crc_out_reg, bdata3 [7:0]};
							txc		<=	32'hFFFF_FFE0;
						end
						2	:	begin
							txd		<=	{208'h0707070707070707_0707070707070707_0707070707070707_07FD, crc_out_reg, bdata3 [15:0]};
							txc		<=	32'hFFFF_FFC0;
						end
						3	:	begin
							txd		<=	{200'h0707070707070707_0707070707070707_0707070707070707_FD, crc_out_reg, bdata3 [23:0]};
							txc		<=	32'hFFFF_FF80;
						end
						4	:	begin
							txd		<=	{192'h0707070707070707_0707070707070707_07070707070707FD, crc_out_reg, bdata3 [31:0]};
							txc		<=	32'hFFFF_FF00;
						end
						5	:	begin
							txd		<=	{184'h0707070707070707_0707070707070707_070707070707FD, crc_out_reg, bdata3 [39:0]};
							txc		<=	32'hFFFF_FE00;
						end
						6	:	begin
							txd		<=	{176'h0707070707070707_0707070707070707_0707070707FD, crc_out_reg, bdata3 [47:0]};
							txc		<=	32'hFFFF_FC00;
						end
						7	:	begin
							txd		<=	{168'h0707070707070707_0707070707070707_07070707FD, crc_out_reg, bdata3 [55:0]};
							txc		<=	32'hFFFF_F800;
						end
						8	:	begin
							txd		<=	{160'h0707070707070707_0707070707070707_070707FD, crc_out_reg, bdata3 [63:0]};
							txc		<=	32'hFFFF_F000;
						end
						9	:	begin
							txd		<=	{152'h0707070707070707_0707070707070707_0707FD, crc_out, bdata3 [71:0]};
							txc		<=	32'hFFFF_E000;
						end
						10	:	begin
							txd		<=	{144'h0707070707070707_0707070707070707_07FD, crc_out, bdata3 [79:0]};
							txc		<=	32'hFFFF_C000;
						end
						11	:	begin
							txd		<=	{136'h0707070707070707_0707070707070707_FD, crc_out, bdata3 [87:0]};
							txc		<=	32'hFFFF_8000;
						end
						12	:	begin
							txd		<=	{128'h0707070707070707_07070707070707FD, crc_out, bdata3 [95:0]};
							txc		<=	32'hFFFF_0000;
						end
						13	:	begin
							txd		<=	{120'h0707070707070707_070707070707FD, crc_out, bdata3 [103:0]};
							txc		<=	32'hFFFE_0000;
						end
						14	:	begin
							txd		<=	{112'h0707070707070707_0707070707FD, crc_out, bdata3 [111:0]};
							txc		<=	32'hFFFC_0000;
						end
						15	:	begin
							txd		<=	{104'h0707070707070707_07070707FD, crc_out, bdata3 [119:0]};
							txc		<=	32'hFFF8_0000;
						end
						16	:	begin
							txd		<=	{96'h0707070707070707_070707FD, crc_out, bdata3 [127:0]};
							txc		<=	32'hFFF0_0000;
						end
						17	:	begin
							txd		<=	{88'h0707070707070707_0707FD, crc_out, bdata3 [135:0]};
							txc		<=	32'hFFE0_0000;
						end
						18	:	begin
							txd		<=	{80'h0707070707070707_07FD, crc_out, bdata3 [143:0]};
							txc		<=	32'hFFC0_0000;
						end
						19	:	begin
							txd		<=	{72'h0707070707070707_FD, crc_out, bdata3 [151:0]};
							txc		<=	32'hFF80_0000;
						end
						20	:	begin
							txd		<=	{64'h07070707070707FD, crc_out, bdata3 [159:0]};
							txc		<=	32'hFF00_0000;
						end
						21	:	begin
							txd		<=	{56'h070707070707FD, crc_out, bdata3 [167:0]};
							txc		<=	32'hFE00_0000;
						end
						22	:	begin
							txd		<=	{48'h0707070707FD, crc_out, bdata3 [175:0]};
							txc		<=	32'hFC00_0000;
						end
						23	:	begin
							txd		<=	{40'h07070707FD, crc_out, bdata3 [183:0]};
							txc		<=	32'hF800_0000;
						end
						24	:	begin
							txd		<=	{32'h070707FD, crc_out, bdata3 [191:0]};
							txc		<=	32'hF000_0000;
						end
						25	:	begin
							txd		<=	{24'h0707FD, crc_out, bdata3 [199:0]};
							txc		<=	32'hE000_0000;
						end
						26	:	begin
							txd		<=	{16'h07FD, crc_out, bdata3 [207:0]};
							txc		<=	32'hC000_0000;
						end
						27	:	begin
							txd		<=	{8'hFD, crc_out, bdata3 [215:0]};
							txc		<=	32'h8000_0000;
						end
						28	:	begin
							txd		<=	{crc_out, bdata3 [223:0]};
							txc		<=	32'h0;
						end
						29	:	begin
							txd		<=	{crc_out [23:0], bdata3 [231:0]};
							txc		<=	32'h0;
						end
						30	:	begin
							txd		<=	{crc_out [15:0], bdata3 [239:0]};
							txc		<=	32'h0;
						end
						31	:	begin
							txd		<=	{crc_out [7:0], bdata3 [247:0]};
							txc		<=	32'h0;
						end
						32	:	begin
							txd		<=	bdata3;
							txc		<=	32'h0;
						end
					endcase
					
					FMAC_TX_PKT_CNT		<=	(fmac_tx_clr_en)?	32'h0	:
												(FMAC_TX_PKT_CNT + 1'b1);
					FMAC_TX_BYTE_CNT	<=	(fmac_tx_clr_en)?	32'h0	:
												(FMAC_TX_BYTE_CNT + rbytes);
					
				end
				else if (tx_dvld_dly3 & tx_data_first_dly3) begin
					txd		<=	bdata3;
					txc		<=	32'h0000_0001;
				end
				else if (tx_dvld_dly3) begin
					txd		<=	bdata3;
					txc		<=	32'h0;
				end
				else if (tx_ndata_last_vld_dly) begin
					case (tx_ndata_last_cnt_dly)
						1	:	begin
							txd		<=	256'h0707070707070707_0707070707070707_0707070707070707_07070707070707FD;
							txc		<=	32'hFFFF_FFFF;
						end
						2	:	begin
							txd		<=	{248'h0707070707070707_0707070707070707_0707070707070707_070707070707FD, crc_out_reg [31:24]};
							txc		<=	32'hFFFF_FFFE;
						end
						3	:	begin
							txd		<=	{240'h0707070707070707_0707070707070707_0707070707070707_0707070707FD, crc_out_reg [31:16]};
							txc		<=	32'hFFFF_FFFC;
						end
						4	:	begin
							txd		<=	{232'h0707070707070707_0707070707070707_0707070707070707_07070707FD, crc_out_reg [31:8]};
							txc		<=	32'hFFFF_FFF8;
						end
						5	:	begin
							txd		<=	{224'h0707070707070707_0707070707070707_0707070707070707_070707FD, crc_out_reg};
							txc		<=	32'hFFFF_FFF0;
						end
					endcase
				end
				else begin
					txd		<=	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
					txc		<=	32'hFFFF_FFFF;
				end
			end
		end
	end

		
endmodule