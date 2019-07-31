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

// Any Polynomial CRC Generator                                               
//
/**** CRC32 Generate/Check Timing Diagram ****
                	   __    __    __    __    __    __    __    __    __  
   clock        	__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
                	                  __________	      |
   data_vld     	_________________|          |___________________________		//data_vld start after the data_sop in LMAC3
                	             ____   		          |
   data_sop     	____________|    |______________________________________
                	                        ____          |
   data_eop     	_______________________|    |___________________________
                	                                    __|_
   crc_vld      	___________________________________|    |_______________ 
                	                                      |   
   crc_out      	-----------------------------------[crc ]---------------		//vld crc available next to next clk after data_eop
                	                                      |
****/   
 
module eth_crc32_gen(
   /* i */ clk,         	//clock
   /* i */ rst_n,       	//active low reset
   /* i */ data_vld,    	//data valid
   /* i */ data_eop,    	//end of frame
   /* i */ data_sop,    	//start of frame
   /* i */ data_in,     	//align first byte on bit [7:0] ... last byte [63:56]
   
   /* i */ data_be,     	//0 - all bytes valid  (really is beat_bcnt)
                        	//1 - 1 byte valid bit[7:0]
                        	//..
                        	//7 - 7 bytes valid bit[55:0]
   /* o */ crc_out,     	//final generated crc32 value
   /* o */ crc_vld      	//crc check valid
 );

 //system clock and reset
 input            	clk;         	//clock
 input            	rst_n;       	//active low reset
                          
 //data inputs            
 input            	data_vld;    	//packet data is valid
 input            	data_eop;    	//indicates last packet data for this packet
 input            	data_sop;    	//indicates the first packet data for this packet
 input  [255:0]  	data_in;     	//packet data
 input  [4:0]   	data_be;     	//total number of bytes valid, regardless of the where the first data is align on this clock

 //crc outputs
 output [31:0]  	crc_out;   		//final crc32 value (inverted/reversed)
 output reg       	crc_vld;   		//indicates crc status is valid
 
 reg 	[31:0]  	crc_reg;   		//crc32 value 
 reg            	data_eop_dly;
 reg	[4:0]   	data_be_dly; 

 wire	[63:0]		data1, data2, data3, data4;

 assign	data1	=	{
 	    data_in[0]  , data_in[1]  , data_in[2]  , data_in[3]  , data_in[4]  , data_in[5]  , data_in[6]  , data_in[7]  ,
 	    data_in[8]  , data_in[9]  , data_in[10] , data_in[11] , data_in[12] , data_in[13] , data_in[14] , data_in[15] , 
 	    data_in[16] , data_in[17] , data_in[18] , data_in[19] , data_in[20] , data_in[21] , data_in[22] , data_in[23] ,
 	    data_in[24] , data_in[25] , data_in[26] , data_in[27] , data_in[28] , data_in[29] , data_in[30] , data_in[31] , 
 	    data_in[32] , data_in[33] , data_in[34] , data_in[35] , data_in[36] , data_in[37] , data_in[38] , data_in[39] , 
 	    data_in[40] , data_in[41] , data_in[42] , data_in[43] , data_in[44] , data_in[45] , data_in[46] , data_in[47] , 
 	    data_in[48] , data_in[49] , data_in[50] , data_in[51] , data_in[52] , data_in[53] , data_in[54] , data_in[55] ,
 	    data_in[56] , data_in[57] , data_in[58] , data_in[59] , data_in[60] , data_in[61] , data_in[62] , data_in[63] };
 	    
 assign	data2	=	{
 	    data_in[64] , data_in[65] , data_in[66] , data_in[67] , data_in[68] , data_in[69] , data_in[70] , data_in[71] ,
 	    data_in[72] , data_in[73] , data_in[74] , data_in[75] , data_in[76] , data_in[77] , data_in[78] , data_in[79] , 
 	    data_in[80] , data_in[81] , data_in[82] , data_in[83] , data_in[84] , data_in[85] , data_in[86] , data_in[87] ,
 	    data_in[88] , data_in[89] , data_in[90] , data_in[91] , data_in[92] , data_in[93] , data_in[94] , data_in[95] , 
 	    data_in[96] , data_in[97] , data_in[98] , data_in[99] , data_in[100], data_in[101], data_in[102], data_in[103], 
 	    data_in[104], data_in[105], data_in[106], data_in[107], data_in[108], data_in[109], data_in[110], data_in[111], 
 	    data_in[112], data_in[113], data_in[114], data_in[115], data_in[116], data_in[117], data_in[118], data_in[119],
 	    data_in[120], data_in[121], data_in[122], data_in[123], data_in[124], data_in[125], data_in[126], data_in[127]};
 	    
 assign	data3	=	{
 	    data_in[128], data_in[129], data_in[130], data_in[131], data_in[132], data_in[133], data_in[134], data_in[135],
 	    data_in[136], data_in[137], data_in[138], data_in[139], data_in[140], data_in[141], data_in[142], data_in[143], 
 	    data_in[144], data_in[145], data_in[146], data_in[147], data_in[148], data_in[149], data_in[150], data_in[151],
 	    data_in[152], data_in[153], data_in[154], data_in[155], data_in[156], data_in[157], data_in[158], data_in[159], 
 	    data_in[160], data_in[161], data_in[162], data_in[163], data_in[164], data_in[165], data_in[166], data_in[167], 
 	    data_in[168], data_in[169], data_in[170], data_in[171], data_in[172], data_in[173], data_in[174], data_in[175], 
 	    data_in[176], data_in[177], data_in[178], data_in[179], data_in[180], data_in[181], data_in[182], data_in[183],
 	    data_in[184], data_in[185], data_in[186], data_in[187], data_in[188], data_in[189], data_in[190], data_in[191]};
 	    
 assign	data4	=	{
 	    data_in[192], data_in[193], data_in[194], data_in[195], data_in[196], data_in[197], data_in[198], data_in[199],
 	    data_in[200], data_in[201], data_in[202], data_in[203], data_in[204], data_in[205], data_in[206], data_in[207],
 	    data_in[208], data_in[209], data_in[210], data_in[211], data_in[212], data_in[213], data_in[214], data_in[215], 
 	    data_in[216], data_in[217], data_in[218], data_in[219], data_in[220], data_in[221], data_in[222], data_in[223],
 	    data_in[224], data_in[225], data_in[226], data_in[227], data_in[228], data_in[229], data_in[230], data_in[231], 
 	    data_in[232], data_in[233], data_in[234], data_in[235], data_in[236], data_in[237], data_in[238], data_in[239], 
 	    data_in[240], data_in[241], data_in[242], data_in[243], data_in[244], data_in[245], data_in[246], data_in[247], 
 	    data_in[248], data_in[249], data_in[250], data_in[251], data_in[252], data_in[253], data_in[254], data_in[255]};
 	    
 assign	crc_out	=	~{
 	    crc_reg[0] , crc_reg[1] , crc_reg[2] , crc_reg[3] , crc_reg[4] , crc_reg[5] , crc_reg[6] , crc_reg[7] ,
 	    crc_reg[8] , crc_reg[9] , crc_reg[10], crc_reg[11], crc_reg[12], crc_reg[13], crc_reg[14], crc_reg[15], 
 	    crc_reg[16], crc_reg[17], crc_reg[18], crc_reg[19], crc_reg[20], crc_reg[21], crc_reg[22], crc_reg[23],
 	    crc_reg[24], crc_reg[25], crc_reg[26], crc_reg[27], crc_reg[28], crc_reg[29], crc_reg[30], crc_reg[31]};

 wire	[31:0]	crc_in;
 wire	[31:0]	crc_out_d8;
 wire	[31:0]	crc_out_d16;
 wire	[31:0]	crc_out_d24;
 wire	[31:0]	crc_out_d32;
 wire	[31:0]	crc_out_d40;
 wire	[31:0]	crc_out_d48;
 wire	[31:0]	crc_out_d56;
 wire	[31:0]	crc_out_d64;
 wire	[31:0]	crc_out_d72;
 wire	[31:0]	crc_out_d80;
 wire	[31:0]	crc_out_d88;
 wire	[31:0]	crc_out_d96;
 wire	[31:0]	crc_out_d104;
 wire	[31:0]	crc_out_d112;
 wire	[31:0]	crc_out_d120;
 wire	[31:0]	crc_out_d128;
 wire	[31:0]	crc_out_d136;
 wire	[31:0]	crc_out_d144;
 wire	[31:0]	crc_out_d152;
 wire	[31:0]	crc_out_d160;
 wire	[31:0]	crc_out_d168;
 wire	[31:0]	crc_out_d176;
 wire	[31:0]	crc_out_d184;
 wire	[31:0]	crc_out_d192;
 wire	[31:0]	crc_out_d200;
 wire	[31:0]	crc_out_d208;
 wire	[31:0]	crc_out_d216;
 wire	[31:0]	crc_out_d224;
 wire	[31:0]	crc_out_d232;
 wire	[31:0]	crc_out_d240;
 wire	[31:0]	crc_out_d248;
 wire	[31:0]	crc_out_d256;
 	     	    
 	    
 always @(posedge clk) begin
 	if (!rst_n) begin
 		crc_reg			<=	32'hFFFF_FFFF;
 		crc_vld			<=	1'b0;
		data_eop_dly	<=	1'b0;
		data_be_dly		<=	5'b0; 
 	end
 	else begin
 		if (data_eop_dly) begin
 			crc_vld		<=	1'b1;
 			case (data_be_dly)
 				5'd1	:	crc_reg		<=	crc_out_d8;  
 				5'd2	:	crc_reg		<=	crc_out_d16; 
 				5'd3	:	crc_reg		<=	crc_out_d24; 
 				5'd4	:	crc_reg		<=	crc_out_d32; 
 				5'd5	:	crc_reg		<=	crc_out_d40; 
 				5'd6	:	crc_reg		<=	crc_out_d48; 
 				5'd7	:	crc_reg		<=	crc_out_d56; 
 				5'd8	:	crc_reg		<=	crc_out_d64; 
 				5'd9	:	crc_reg		<=	crc_out_d72; 
 				5'd10	:	crc_reg		<=	crc_out_d80; 
 				5'd11	:	crc_reg		<=	crc_out_d88; 
 				5'd12	:	crc_reg		<=	crc_out_d96; 
 				5'd13	:	crc_reg		<=	crc_out_d104;
 				5'd14	:	crc_reg		<=	crc_out_d112;
 				5'd15	:	crc_reg		<=	crc_out_d120;
 				5'd16	:	crc_reg		<=	crc_out_d128;
 				5'd17	:	crc_reg		<=	crc_out_d136;
 				5'd18	:	crc_reg		<=	crc_out_d144;
 				5'd19	:	crc_reg		<=	crc_out_d152;
 				5'd20	:	crc_reg		<=	crc_out_d160;
 				5'd21	:	crc_reg		<=	crc_out_d168;
 				5'd22	:	crc_reg		<=	crc_out_d176;
 				5'd23	:	crc_reg		<=	crc_out_d184;
 				5'd24	:	crc_reg		<=	crc_out_d192;
 				5'd25	:	crc_reg		<=	crc_out_d200;
 				5'd26	:	crc_reg		<=	crc_out_d208;
 				5'd27	:	crc_reg		<=	crc_out_d216;
 				5'd28	:	crc_reg		<=	crc_out_d224;
 				5'd29	:	crc_reg		<=	crc_out_d232;
 				5'd30	:	crc_reg		<=	crc_out_d240;
 				5'd31	:	crc_reg		<=	crc_out_d248;
 				default	:	crc_reg		<=	crc_out_d256;
 			endcase
 		end
 		else begin
 			crc_vld		<=	1'b0;
 			crc_reg		<=	32'hFFFF_FFFF;
 		end
 		
		data_eop_dly	<=	data_eop;
		data_be_dly		<=	data_be;
		 		
 	end
 end
 
 
 assign	crc_in	=	(data_sop)?	32'hFFFF_FFFF	:
 						crc_out_d256;
 	    
 CRC32_D256 CRC32_D256(
	.data_in	({data1, data2, data3, data4}),
	.crc_in     (crc_in),
	.crc_en     (data_sop | data_vld | data_eop),
	.crc_out    (crc_out_d256),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D248 CRC32_D248(
	.data_in	({data1, data2, data3, data4[63:8]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d248),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D240 CRC32_D240(
	.data_in	({data1, data2, data3, data4[63:16]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d240),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D232 CRC32_D232(
	.data_in	({data1, data2, data3, data4[63:24]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d232),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D224 CRC32_D224(
	.data_in	({data1, data2, data3, data4[63:32]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d224),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D216 CRC32_D216(
	.data_in	({data1, data2, data3, data4[63:40]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d216),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D208 CRC32_D208(
	.data_in	({data1, data2, data3, data4[63:48]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d208),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D200 CRC32_D200(
	.data_in	({data1, data2, data3, data4[63:56]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d200),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D192 CRC32_D192(
	.data_in	({data1, data2, data3}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d192),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D184 CRC32_D184(
	.data_in	({data1, data2, data3[63:8]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d184),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D176 CRC32_D176(
	.data_in	({data1, data2, data3[63:16]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d176),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D168 CRC32_D168(
	.data_in	({data1, data2, data3[63:24]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d168),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D160 CRC32_D160(
	.data_in	({data1, data2, data3[63:32]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d160),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D152 CRC32_D152(
	.data_in	({data1, data2, data3[63:40]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d152),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D144 CRC32_D144(
	.data_in	({data1, data2, data3[63:48]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d144),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D136 CRC32_D136(
	.data_in	({data1, data2, data3[63:56]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d136),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D128 CRC32_D128(
	.data_in	({data1, data2}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d128),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D120 CRC32_D120(
	.data_in	({data1, data2[63:8]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d120),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D112 CRC32_D112(
	.data_in	({data1, data2[63:16]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d112),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D104 CRC32_D104(
	.data_in	({data1, data2[63:24]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d104),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D96 CRC32_D96(
	.data_in	({data1, data2[63:32]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d96),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D88 CRC32_D88(
	.data_in	({data1, data2[63:40]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d88),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D80 CRC32_D80(
	.data_in	({data1, data2[63:48]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d80),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D72 CRC32_D72(
	.data_in	({data1, data2[63:56]}),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d72),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D64 CRC32_D64(
	.data_in	(data1),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d64),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D56 CRC32_D56(
	.data_in	(data1[63:8]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d56),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D48 CRC32_D48(
	.data_in	(data1[63:16]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d48),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D40 CRC32_D40(
	.data_in	(data1[63:24]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d40),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D32 CRC32_D32(
	.data_in	(data1[63:32]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d32),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D24 CRC32_D24(
	.data_in	(data1[63:40]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d24),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D16 CRC32_D16(
	.data_in	(data1[63:48]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d16),
	.rst	    (rst_n),
	.clk        (clk)
  );
 	    
 CRC32_D8 CRC32_D8(
	.data_in	(data1[63:56]),
	.crc_in     (crc_out_d256),
	.crc_en     (data_eop),
	.crc_out    (crc_out_d8),
	.rst	    (rst_n),
	.clk        (clk)
  );
 
endmodule