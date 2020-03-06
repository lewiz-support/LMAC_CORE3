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

//-----------------------------------------------------------------------------
// CRC module for data[127:0] ,   crc[31:0]=1+x^1+x^2+x^4+x^5+x^7+x^8+x^10+x^11+x^12+x^16+x^22+x^23+x^26+x^32;
//-----------------------------------------------------------------------------

// synopsys translate_off
`timescale 1ns/1ps
// synopsys translate_on

module CRC32_D128(
  input  [127:0]	data_in,
  input	 [31:0] 	crc_in,
  input 			crc_en,
  output [31:0] 	crc_out,
  input 			rst,
  input 			clk
  );
  
    //BIT-0	 
  wire 	crc_bit0_0,crc_bit0_1,crc_bit0_2;
  reg 	crc_bit0_0_reg,crc_bit0_1_reg,crc_bit0_2_reg;
  //**BIT-1
  wire 	crc_bit1_0,crc_bit1_1;
  reg 	crc_bit1_0_reg,crc_bit1_1_reg;
  //**BIT-2
  wire 	crc_bit2_0,crc_bit2_1;
  reg 	crc_bit2_0_reg,crc_bit2_1_reg;
  //**BIT-3
  wire 	crc_bit3_0,crc_bit3_1;
  reg 	crc_bit3_0_reg,crc_bit3_1_reg;
  //**BIT-4
  wire 	crc_bit4_0,crc_bit4_1,crc_bit4_2;
  reg 	crc_bit4_0_reg,crc_bit4_1_reg,crc_bit4_2_reg;
  //**BIT-5
  wire 	crc_bit5_0,crc_bit5_1,crc_bit5_2;
  reg 	crc_bit5_0_reg,crc_bit5_1_reg,crc_bit5_2_reg;
  //**BIT-6
  wire 	crc_bit6_0,crc_bit6_1,crc_bit6_2;
  reg 	crc_bit6_0_reg,crc_bit6_1_reg,crc_bit6_2_reg;
  //**BIT-7
  wire 	crc_bit7_0,crc_bit7_1;
  reg 	crc_bit7_0_reg,crc_bit7_1_reg;
  //**BIT-8
  wire 	crc_bit8_0,crc_bit8_1,crc_bit8_2;
  reg 	crc_bit8_0_reg,crc_bit8_1_reg,crc_bit8_2_reg;
   //**BIT-9
  wire 	crc_bit9_0,crc_bit9_1,crc_bit9_2;
  reg 	crc_bit9_0_reg,crc_bit9_1_reg,crc_bit9_2_reg;
   //**BIT-10
  wire 	crc_bit10_0,crc_bit10_1,crc_bit10_2;
  reg 	crc_bit10_0_reg,crc_bit10_1_reg,crc_bit10_2_reg;
   //**BIT-11
  wire 	crc_bit11_0,crc_bit11_1,crc_bit11_2;
  reg 	crc_bit11_0_reg,crc_bit11_1_reg,crc_bit11_2_reg;
   //**BIT-12
  wire 	crc_bit12_0,crc_bit12_1,crc_bit12_2;
  reg 	crc_bit12_0_reg,crc_bit12_1_reg,crc_bit12_2_reg;
   //**BIT-13
  wire 	crc_bit13_0,crc_bit13_1,crc_bit13_2;
  reg 	crc_bit13_0_reg,crc_bit13_1_reg,crc_bit13_2_reg;
   //**BIT-14
  wire 	crc_bit14_0,crc_bit14_1,crc_bit14_2;
  reg 	crc_bit14_0_reg,crc_bit14_1_reg,crc_bit14_2_reg;
   //**BIT-15
  wire 	crc_bit15_0,crc_bit15_1;
  reg 	crc_bit15_0_reg,crc_bit15_1_reg;
  //**BIT-16
  wire 	crc_bit16_0,crc_bit16_1;
  reg 	crc_bit16_0_reg,crc_bit16_1_reg;
  //**BIT-17
  wire 	crc_bit17_0,crc_bit17_1;
  reg 	crc_bit17_0_reg,crc_bit17_1_reg;
  //**BIT-18
  wire 	crc_bit18_0,crc_bit18_1;
  reg 	crc_bit18_0_reg,crc_bit18_1_reg;
  //**BIT-19
  wire 	crc_bit19_0,crc_bit19_1;
  reg 	crc_bit19_0_reg,crc_bit19_1_reg;
  //**BIT-20
  wire 	crc_bit20_0,crc_bit20_1;
  reg 	crc_bit20_0_reg,crc_bit20_1_reg;
  //**BIT-21
  wire 	crc_bit21_0,crc_bit21_1;
  reg 	crc_bit21_0_reg,crc_bit21_1_reg;
  //**BIT-22
  wire 	crc_bit22_0,crc_bit22_1,crc_bit22_2;
  reg 	crc_bit22_0_reg,crc_bit22_1_reg,crc_bit22_2_reg;
  //**BIT-23
  wire 	crc_bit23_0,crc_bit23_1,crc_bit23_2;
  reg 	crc_bit23_0_reg,crc_bit23_1_reg,crc_bit23_2_reg;
  //**BIT-24
  wire 	crc_bit24_0,crc_bit24_1,crc_bit24_2;
  reg 	crc_bit24_0_reg,crc_bit24_1_reg,crc_bit24_2_reg;
  //**BIT-25
  wire 	crc_bit25_0,crc_bit25_1,crc_bit25_2;
  reg 	crc_bit25_0_reg,crc_bit25_1_reg,crc_bit25_2_reg;
  //**BIT-26
  wire 	crc_bit26_0,crc_bit26_1,crc_bit26_2;
  reg 	crc_bit26_0_reg,crc_bit26_1_reg,crc_bit26_2_reg;
  //**BIT-27
  wire 	crc_bit27_0,crc_bit27_1,crc_bit27_2;
  reg 	crc_bit27_0_reg,crc_bit27_1_reg,crc_bit27_2_reg;
  //**BIT-28
  wire 	crc_bit28_0,crc_bit28_1,crc_bit28_2;
  reg 	crc_bit28_0_reg,crc_bit28_1_reg,crc_bit28_2_reg;
  //**BIT-29
  wire 	crc_bit29_0,crc_bit29_1,crc_bit29_2;
  reg 	crc_bit29_0_reg,crc_bit29_1_reg,crc_bit29_2_reg;
  //**BIT-30
  wire 	crc_bit30_0,crc_bit30_1,crc_bit30_2;
  reg 	crc_bit30_0_reg,crc_bit30_1_reg,crc_bit30_2_reg;
  //**BIT-31
  wire 	crc_bit31_0,crc_bit31_1,crc_bit31_2;
  reg 	crc_bit31_0_reg,crc_bit31_1_reg,crc_bit31_2_reg;

  reg [31:0] lfsr_q,lfsr_c;

  assign crc_out = lfsr_c;

 // always @(*) begin
 
 assign crc_bit0_0 = data_in[0] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[16] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[32] ^ data_in[34] ^ data_in[37] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[63] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[72];
 
 assign crc_bit0_1 = data_in[73] ^ data_in[79] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[87] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[106] ^ data_in[110] ^ data_in[111] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[117] ^ data_in[118] ^ data_in[119] ^ data_in[123] ^ data_in[125] ^ data_in[126] ^ data_in[127];
 
 
  //  lfsr_c[0] = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ data_in[0] ^ data_in[6] ^ data_in[9] ^ data_in[10] ^ data_in[12] ^ data_in[16] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[32] ^ data_in[34] ^ data_in[37] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[63] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[72] ^ data_in[73] ^ data_in[79] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[87] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[106] ^ data_in[110] ^ data_in[111] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[117] ^ data_in[118] ^ data_in[119] ^ data_in[123] ^ data_in[125] ^ data_in[126] ^ data_in[127];
  
  assign crc_bit1_0 = data_in[0] ^ data_in[1] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[37] ^ data_in[38] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[53] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[65];
  
  assign crc_bit1_1 = data_in[69] ^ data_in[72] ^ data_in[74] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[94] ^ data_in[100] ^ data_in[101] ^ data_in[102] ^ data_in[103] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[110] ^ data_in[112] ^ data_in[113] ^ data_in[115] ^ data_in[116] ^ data_in[120] ^ data_in[123] ^ data_in[124] ^ data_in[125];
  
  
  //  lfsr_c[1] = crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[24] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ data_in[0] ^ data_in[1] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[24] ^ data_in[27] ^ data_in[28] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[37] ^ data_in[38] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[53] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[65] ^ data_in[69] ^ data_in[72] ^ data_in[74] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[94] ^ data_in[100] ^ data_in[101] ^ data_in[102] ^ data_in[103] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[110] ^ data_in[112] ^ data_in[113] ^ data_in[115] ^ data_in[116] ^ data_in[120] ^ data_in[123] ^ data_in[124] ^ data_in[125];
  
  assign crc_bit2_0 = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[24] ^ data_in[26] ^ data_in[30] ^ data_in[31] ^ data_in[32] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[39] ^ data_in[44] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[59] ^ data_in[64] ^ data_in[67] ^ data_in[68];
  
  assign crc_bit2_1 = data_in[70] ^ data_in[72] ^ data_in[75] ^ data_in[79] ^ data_in[80] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[88] ^ data_in[89] ^ data_in[94] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[102] ^ data_in[107] ^ data_in[108] ^ data_in[110] ^ data_in[118] ^ data_in[119] ^ data_in[121] ^ data_in[123] ^ data_in[124] ^ data_in[127];
  
   // lfsr_c[2] = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[6] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[31] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[24] ^ data_in[26] ^ data_in[30] ^ data_in[31] ^ data_in[32] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[39] ^ data_in[44] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[59] ^ data_in[64] ^ data_in[67] ^ data_in[68] ^ data_in[70] ^ data_in[72] ^ data_in[75] ^ data_in[79] ^ data_in[80] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[88] ^ data_in[89] ^ data_in[94] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[102] ^ data_in[107] ^ data_in[108] ^ data_in[110] ^ data_in[118] ^ data_in[119] ^ data_in[121] ^ data_in[123] ^ data_in[124] ^ data_in[127];
   
   assign crc_bit3_0 = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[25] ^ data_in[27] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[39] ^ data_in[40] ^ data_in[45] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[65] ^ data_in[68] ^ data_in[69];
   
   assign crc_bit3_1 = data_in[71] ^ data_in[73] ^ data_in[76] ^ data_in[80] ^ data_in[81] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[89] ^ data_in[90] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[103] ^ data_in[108] ^ data_in[109] ^ data_in[111] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[124] ^ data_in[125];
   
   
   // lfsr_c[3] = crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[7] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[25] ^ data_in[27] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[39] ^ data_in[40] ^ data_in[45] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[65] ^ data_in[68] ^ data_in[69] ^ data_in[71] ^ data_in[73] ^ data_in[76] ^ data_in[80] ^ data_in[81] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[89] ^ data_in[90] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[103] ^ data_in[108] ^ data_in[109] ^ data_in[111] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[124] ^ data_in[125];
   
   assign crc_bit4_0 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[24] ^ data_in[25] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[38] ^ data_in[39] ^ data_in[40] ^ data_in[41] ^ data_in[44] ^ data_in[45] ^ data_in[46] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[57] ^ data_in[58] ^ data_in[59] ^ data_in[63] ^ data_in[65];
   
   assign crc_bit4_1 = data_in[67] ^ data_in[68] ^ data_in[69] ^ data_in[70] ^ data_in[73] ^ data_in[74] ^ data_in[77] ^ data_in[79] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[90] ^ data_in[91] ^ data_in[94] ^ data_in[95] ^ data_in[97] ^ data_in[100] ^ data_in[103] ^ data_in[106] ^ data_in[109] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[117] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[127];
   
   // lfsr_c[4] = crc_in[1] ^ crc_in[4] ^ crc_in[7] ^ crc_in[10] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[31] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[8] ^ data_in[11] ^ data_in[12] ^ data_in[15] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[24] ^ data_in[25] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[38] ^ data_in[39] ^ data_in[40] ^ data_in[41] ^ data_in[44] ^ data_in[45] ^ data_in[46] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[57] ^ data_in[58] ^ data_in[59] ^ data_in[63] ^ data_in[65] ^ data_in[67] ^ data_in[68] ^ data_in[69] ^ data_in[70] ^ data_in[73] ^ data_in[74] ^ data_in[77] ^ data_in[79] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[90] ^ data_in[91] ^ data_in[94] ^ data_in[95] ^ data_in[97] ^ data_in[100] ^ data_in[103] ^ data_in[106] ^ data_in[109] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[117] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[127];
   
   assign crc_bit5_0 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[28] ^ data_in[29] ^ data_in[37] ^ data_in[39] ^ data_in[40] ^ data_in[41] ^ data_in[42] ^ data_in[44] ^ data_in[46] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[64] ^ data_in[65];
   
   assign crc_bit5_1 = data_in[67] ^ data_in[69] ^ data_in[70] ^ data_in[71] ^ data_in[72] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[97] ^ data_in[99] ^ data_in[103] ^ data_in[106] ^ data_in[107] ^ data_in[111] ^ data_in[112] ^ data_in[115] ^ data_in[116] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[125] ^ data_in[126] ^ data_in[127];
   
   // lfsr_c[5] = crc_in[1] ^ crc_in[3] ^ crc_in[7] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[16] ^ crc_in[19] ^ crc_in[20] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[28] ^ data_in[29] ^ data_in[37] ^ data_in[39] ^ data_in[40] ^ data_in[41] ^ data_in[42] ^ data_in[44] ^ data_in[46] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[64] ^ data_in[65] ^ data_in[67] ^ data_in[69] ^ data_in[70] ^ data_in[71] ^ data_in[72] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[97] ^ data_in[99] ^ data_in[103] ^ data_in[106] ^ data_in[107] ^ data_in[111] ^ data_in[112] ^ data_in[115] ^ data_in[116] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[125] ^ data_in[126] ^ data_in[127];
   
   assign crc_bit6_0 = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[25] ^ data_in[29] ^ data_in[30] ^ data_in[38] ^ data_in[40] ^ data_in[41] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[47] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[65] ^ data_in[66];
   
   assign crc_bit6_1 = data_in[68] ^ data_in[70] ^ data_in[71] ^ data_in[72] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[98] ^ data_in[100] ^ data_in[104] ^ data_in[107] ^ data_in[108] ^ data_in[112] ^ data_in[113] ^ data_in[116] ^ data_in[117] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[126] ^ data_in[127];
   
  //  lfsr_c[6] = crc_in[2] ^ crc_in[4] ^ crc_in[8] ^ crc_in[11] ^ crc_in[12] ^ crc_in[16] ^ crc_in[17] ^ crc_in[20] ^ crc_in[21] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[25] ^ data_in[29] ^ data_in[30] ^ data_in[38] ^ data_in[40] ^ data_in[41] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[47] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[68] ^ data_in[70] ^ data_in[71] ^ data_in[72] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[98] ^ data_in[100] ^ data_in[104] ^ data_in[107] ^ data_in[108] ^ data_in[112] ^ data_in[113] ^ data_in[116] ^ data_in[117] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[126] ^ data_in[127];
  
  assign crc_bit7_0 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[15] ^ data_in[16] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[28] ^ data_in[29] ^ data_in[32] ^ data_in[34] ^ data_in[37] ^ data_in[39] ^ data_in[41] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[46] ^ data_in[47] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[54] ^ data_in[56] ^ data_in[57] ^ data_in[58];
  
  assign crc_bit7_1 = data_in[60] ^ data_in[68] ^ data_in[69] ^ data_in[71] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[79] ^ data_in[80] ^ data_in[87] ^ data_in[93] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[108] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[116] ^ data_in[119] ^ data_in[122] ^ data_in[124] ^ data_in[126];
  
  //  lfsr_c[7] = crc_in[1] ^ crc_in[2] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[20] ^ crc_in[23] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[15] ^ data_in[16] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[28] ^ data_in[29] ^ data_in[32] ^ data_in[34] ^ data_in[37] ^ data_in[39] ^ data_in[41] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[46] ^ data_in[47] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[54] ^ data_in[56] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[68] ^ data_in[69] ^ data_in[71] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[79] ^ data_in[80] ^ data_in[87] ^ data_in[93] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[108] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[116] ^ data_in[119] ^ data_in[122] ^ data_in[124] ^ data_in[126];
  
  assign crc_bit8_0 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[8] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[17] ^ data_in[22] ^ data_in[23] ^ data_in[28] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[37] ^ data_in[38] ^ data_in[40] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[46] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[54] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[63] ^ data_in[65];
  
  assign crc_bit8_1 = data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[69] ^ data_in[70] ^ data_in[73] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[87] ^ data_in[88] ^ data_in[95] ^ data_in[97] ^ data_in[101] ^ data_in[103] ^ data_in[105] ^ data_in[107] ^ data_in[109] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[126];
  
   // lfsr_c[8] = crc_in[1] ^ crc_in[5] ^ crc_in[7] ^ crc_in[9] ^ crc_in[11] ^ crc_in[13] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[30] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[8] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[17] ^ data_in[22] ^ data_in[23] ^ data_in[28] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[37] ^ data_in[38] ^ data_in[40] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[46] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[54] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[63] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[69] ^ data_in[70] ^ data_in[73] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[87] ^ data_in[88] ^ data_in[95] ^ data_in[97] ^ data_in[101] ^ data_in[103] ^ data_in[105] ^ data_in[107] ^ data_in[109] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[126];
   
   assign crc_bit9_0 = data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[18] ^ data_in[23] ^ data_in[24] ^ data_in[29] ^ data_in[32] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[38] ^ data_in[39] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[55] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[64] ^ data_in[66];
   
   assign crc_bit9_1 = data_in[67] ^ data_in[68] ^ data_in[69] ^ data_in[70] ^ data_in[71] ^ data_in[74] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[88] ^ data_in[89] ^ data_in[96] ^ data_in[98] ^ data_in[102] ^ data_in[104] ^ data_in[106] ^ data_in[108] ^ data_in[110] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[127];
   
   
  //  lfsr_c[9] = crc_in[0] ^ crc_in[2] ^ crc_in[6] ^ crc_in[8] ^ crc_in[10] ^ crc_in[12] ^ crc_in[14] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[31] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[18] ^ data_in[23] ^ data_in[24] ^ data_in[29] ^ data_in[32] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[38] ^ data_in[39] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[55] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[64] ^ data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[69] ^ data_in[70] ^ data_in[71] ^ data_in[74] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[88] ^ data_in[89] ^ data_in[96] ^ data_in[98] ^ data_in[102] ^ data_in[104] ^ data_in[106] ^ data_in[108] ^ data_in[110] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[127];
  
  assign crc_bit10_0 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[35] ^ data_in[36] ^ data_in[39] ^ data_in[40] ^ data_in[42] ^ data_in[50] ^ data_in[52] ^ data_in[55] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[63] ^ data_in[66] ^ data_in[69] ^ data_in[70] ^ data_in[71];
  
  assign crc_bit10_1 = data_in[73] ^ data_in[75] ^ data_in[77] ^ data_in[78] ^ data_in[80] ^ data_in[83] ^ data_in[86] ^ data_in[89] ^ data_in[90] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[98] ^ data_in[101] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[109] ^ data_in[110] ^ data_in[113] ^ data_in[115] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[125] ^ data_in[126] ^ data_in[127];
  
  
  //  lfsr_c[10] = crc_in[0] ^ crc_in[2] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[14] ^ crc_in[17] ^ crc_in[19] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[19] ^ data_in[26] ^ data_in[28] ^ data_in[29] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[35] ^ data_in[36] ^ data_in[39] ^ data_in[40] ^ data_in[42] ^ data_in[50] ^ data_in[52] ^ data_in[55] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[63] ^ data_in[66] ^ data_in[69] ^ data_in[70] ^ data_in[71] ^ data_in[73] ^ data_in[75] ^ data_in[77] ^ data_in[78] ^ data_in[80] ^ data_in[83] ^ data_in[86] ^ data_in[89] ^ data_in[90] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[98] ^ data_in[101] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[109] ^ data_in[110] ^ data_in[113] ^ data_in[115] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[125] ^ data_in[126] ^ data_in[127];
  
  assign crc_bit11_0 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[9] ^ data_in[12] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[20] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[40] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[58];
  
  assign crc_bit11_1 = data_in[59] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[68] ^ data_in[70] ^ data_in[71] ^ data_in[73] ^ data_in[74] ^ data_in[76] ^ data_in[78] ^ data_in[82] ^ data_in[83] ^ data_in[85] ^ data_in[90] ^ data_in[91] ^ data_in[94] ^ data_in[98] ^ data_in[101] ^ data_in[102] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[107] ^ data_in[108] ^ data_in[113] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[124] ^ data_in[125];
  
  //  lfsr_c[11] = crc_in[2] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[17] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[9] ^ data_in[12] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[20] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[40] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[58] ^ data_in[59] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[68] ^ data_in[70] ^ data_in[71] ^ data_in[73] ^ data_in[74] ^ data_in[76] ^ data_in[78] ^ data_in[82] ^ data_in[83] ^ data_in[85] ^ data_in[90] ^ data_in[91] ^ data_in[94] ^ data_in[98] ^ data_in[101] ^ data_in[102] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[107] ^ data_in[108] ^ data_in[113] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[124] ^ data_in[125];
  
  assign crc_bit12_0 = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30] ^ data_in[31] ^ data_in[41] ^ data_in[42] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[56] ^ data_in[57] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[68];
  
  assign crc_bit12_1 = data_in[69] ^ data_in[71] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[77] ^ data_in[81] ^ data_in[82] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[101] ^ data_in[102] ^ data_in[105] ^ data_in[108] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[113] ^ data_in[116] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[127];
  
  //  lfsr_c[12] = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[5] ^ crc_in[6] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[20] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[31] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30] ^ data_in[31] ^ data_in[41] ^ data_in[42] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[56] ^ data_in[57] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[68] ^ data_in[69] ^ data_in[71] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[77] ^ data_in[81] ^ data_in[82] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[101] ^ data_in[102] ^ data_in[105] ^ data_in[108] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[113] ^ data_in[116] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[127];
  
  assign crc_bit13_0 = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[18] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28] ^ data_in[31] ^ data_in[32] ^ data_in[42] ^ data_in[43] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[69];
  
  assign crc_bit13_1 = data_in[70] ^ data_in[72] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[78] ^ data_in[82] ^ data_in[83] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[102] ^ data_in[103] ^ data_in[106] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[114] ^ data_in[117] ^ data_in[118] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123];
  
   // lfsr_c[13] = crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[6] ^ crc_in[7] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[18] ^ crc_in[21] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[18] ^ data_in[19] ^ data_in[22] ^ data_in[25] ^ data_in[28] ^ data_in[31] ^ data_in[32] ^ data_in[42] ^ data_in[43] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[69] ^ data_in[70] ^ data_in[72] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[78] ^ data_in[82] ^ data_in[83] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[102] ^ data_in[103] ^ data_in[106] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[114] ^ data_in[117] ^ data_in[118] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123];
   
   assign crc_bit14_0 = data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29] ^ data_in[32] ^ data_in[33] ^ data_in[43] ^ data_in[44] ^ data_in[48] ^ data_in[49] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[65] ^ data_in[70];
   
   assign crc_bit14_1 = data_in[71] ^ data_in[73] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[79] ^ data_in[83] ^ data_in[84] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[93] ^ data_in[94] ^ data_in[96] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[103] ^ data_in[104] ^ data_in[107] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[115] ^ data_in[118] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124];
   
   // lfsr_c[14] = crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[7] ^ crc_in[8] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[23] ^ data_in[26] ^ data_in[29] ^ data_in[32] ^ data_in[33] ^ data_in[43] ^ data_in[44] ^ data_in[48] ^ data_in[49] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[65] ^ data_in[70] ^ data_in[71] ^ data_in[73] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[79] ^ data_in[83] ^ data_in[84] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[93] ^ data_in[94] ^ data_in[96] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[103] ^ data_in[104] ^ data_in[107] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[115] ^ data_in[118] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124];
   
   assign crc_bit15_0 = data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30] ^ data_in[33] ^ data_in[34] ^ data_in[44] ^ data_in[45] ^ data_in[49] ^ data_in[50] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[66] ^ data_in[71];
   
   assign crc_bit15_1 = data_in[72] ^ data_in[74] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[80] ^ data_in[84] ^ data_in[85] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[94] ^ data_in[95] ^ data_in[97] ^ data_in[99] ^ data_in[100] ^ data_in[101] ^ data_in[104] ^ data_in[105] ^ data_in[108] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[125];
   
  //  lfsr_c[15] = crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[12] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ data_in[24] ^ data_in[27] ^ data_in[30] ^ data_in[33] ^ data_in[34] ^ data_in[44] ^ data_in[45] ^ data_in[49] ^ data_in[50] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[66] ^ data_in[71] ^ data_in[72] ^ data_in[74] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[80] ^ data_in[84] ^ data_in[85] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[94] ^ data_in[95] ^ data_in[97] ^ data_in[99] ^ data_in[100] ^ data_in[101] ^ data_in[104] ^ data_in[105] ^ data_in[108] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[116] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[125];
  
  assign crc_bit16_0 = data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[12] ^ data_in[13] ^ data_in[17] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30] ^ data_in[32] ^ data_in[35] ^ data_in[37] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[48] ^ data_in[51] ^ data_in[56] ^ data_in[57] ^ data_in[66] ^ data_in[68] ^ data_in[75] ^ data_in[77] ^ data_in[78] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[86];
  
  assign crc_bit16_1 = data_in[87] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[94] ^ data_in[97] ^ data_in[99] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[115] ^ data_in[116] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[124] ^ data_in[127];
  
   // lfsr_c[16] = crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[19] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[28] ^ crc_in[31] ^ data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[8] ^ data_in[12] ^ data_in[13] ^ data_in[17] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[26] ^ data_in[29] ^ data_in[30] ^ data_in[32] ^ data_in[35] ^ data_in[37] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[48] ^ data_in[51] ^ data_in[56] ^ data_in[57] ^ data_in[66] ^ data_in[68] ^ data_in[75] ^ data_in[77] ^ data_in[78] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[87] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[94] ^ data_in[97] ^ data_in[99] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[109] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[115] ^ data_in[116] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[124] ^ data_in[127];
   
   assign crc_bit17_0 = data_in[1] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[18] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[27] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[38] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[49] ^ data_in[52] ^ data_in[57] ^ data_in[58] ^ data_in[67] ^ data_in[69] ^ data_in[76] ^ data_in[78] ^ data_in[79] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[87];
   
   assign crc_bit17_1 = data_in[88] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[95] ^ data_in[98] ^ data_in[100] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[116] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[125];
   
   // lfsr_c[17] = crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[20] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[29] ^ data_in[1] ^ data_in[5] ^ data_in[6] ^ data_in[9] ^ data_in[13] ^ data_in[14] ^ data_in[18] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[27] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[38] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[49] ^ data_in[52] ^ data_in[57] ^ data_in[58] ^ data_in[67] ^ data_in[69] ^ data_in[76] ^ data_in[78] ^ data_in[79] ^ data_in[83] ^ data_in[84] ^ data_in[85] ^ data_in[87] ^ data_in[88] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[95] ^ data_in[98] ^ data_in[100] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[116] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[125];
   
   assign crc_bit18_0 = data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[19] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[28] ^ data_in[31] ^ data_in[32] ^ data_in[34] ^ data_in[37] ^ data_in[39] ^ data_in[46] ^ data_in[48] ^ data_in[49] ^ data_in[50] ^ data_in[53] ^ data_in[58] ^ data_in[59] ^ data_in[68] ^ data_in[70] ^ data_in[77] ^ data_in[79] ^ data_in[80] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[88];
   
   assign crc_bit18_1 = data_in[89] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[96] ^ data_in[99] ^ data_in[101] ^ data_in[102] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[117] ^ data_in[118] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[126];
   
 //   lfsr_c[18] = crc_in[0] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[21] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[30] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[10] ^ data_in[14] ^ data_in[15] ^ data_in[19] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[28] ^ data_in[31] ^ data_in[32] ^ data_in[34] ^ data_in[37] ^ data_in[39] ^ data_in[46] ^ data_in[48] ^ data_in[49] ^ data_in[50] ^ data_in[53] ^ data_in[58] ^ data_in[59] ^ data_in[68] ^ data_in[70] ^ data_in[77] ^ data_in[79] ^ data_in[80] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[88] ^ data_in[89] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[96] ^ data_in[99] ^ data_in[101] ^ data_in[102] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[117] ^ data_in[118] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[126];
 
 assign crc_bit19_0 = data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[15] ^ data_in[16] ^ data_in[20] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[29] ^ data_in[32] ^ data_in[33] ^ data_in[35] ^ data_in[38] ^ data_in[40] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[54] ^ data_in[59] ^ data_in[60] ^ data_in[69] ^ data_in[71] ^ data_in[78] ^ data_in[80] ^ data_in[81] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[89];
 
 assign crc_bit19_1 = data_in[90] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[97] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[108] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[118] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[127];
 
 //   lfsr_c[19] = crc_in[1] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[31] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[11] ^ data_in[15] ^ data_in[16] ^ data_in[20] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[29] ^ data_in[32] ^ data_in[33] ^ data_in[35] ^ data_in[38] ^ data_in[40] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[54] ^ data_in[59] ^ data_in[60] ^ data_in[69] ^ data_in[71] ^ data_in[78] ^ data_in[80] ^ data_in[81] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[89] ^ data_in[90] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[97] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[108] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[118] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[127];
 
 assign crc_bit20_0 = data_in[4] ^ data_in[8] ^ data_in[9] ^ data_in[12] ^ data_in[16] ^ data_in[17] ^ data_in[21] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[30] ^ data_in[33] ^ data_in[34] ^ data_in[36] ^ data_in[39] ^ data_in[41] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[55] ^ data_in[60] ^ data_in[61] ^ data_in[70] ^ data_in[72] ^ data_in[79] ^ data_in[81] ^ data_in[82] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[90];
 
 assign crc_bit20_1 = data_in[91] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[98] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[106] ^ data_in[107] ^ data_in[108] ^ data_in[109] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[125];
 
  //  lfsr_c[20] = crc_in[2] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ data_in[4] ^ data_in[8] ^ data_in[9] ^ data_in[12] ^ data_in[16] ^ data_in[17] ^ data_in[21] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[30] ^ data_in[33] ^ data_in[34] ^ data_in[36] ^ data_in[39] ^ data_in[41] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[55] ^ data_in[60] ^ data_in[61] ^ data_in[70] ^ data_in[72] ^ data_in[79] ^ data_in[81] ^ data_in[82] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[90] ^ data_in[91] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[98] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[106] ^ data_in[107] ^ data_in[108] ^ data_in[109] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[125];
  
  assign crc_bit21_0 = data_in[5] ^ data_in[9] ^ data_in[10] ^ data_in[13] ^ data_in[17] ^ data_in[18] ^ data_in[22] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[35] ^ data_in[37] ^ data_in[40] ^ data_in[42] ^ data_in[49] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[56] ^ data_in[61] ^ data_in[62] ^ data_in[71] ^ data_in[73] ^ data_in[80] ^ data_in[82] ^ data_in[83] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[91];
  
  assign crc_bit21_1 = data_in[92] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[99] ^ data_in[102] ^ data_in[104] ^ data_in[105] ^ data_in[107] ^ data_in[108] ^ data_in[109] ^ data_in[110] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[117] ^ data_in[120] ^ data_in[121] ^ data_in[123] ^ data_in[124] ^ data_in[125] ^ data_in[126];
  
   // lfsr_c[21] = crc_in[0] ^ crc_in[3] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[24] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ data_in[5] ^ data_in[9] ^ data_in[10] ^ data_in[13] ^ data_in[17] ^ data_in[18] ^ data_in[22] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[35] ^ data_in[37] ^ data_in[40] ^ data_in[42] ^ data_in[49] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[56] ^ data_in[61] ^ data_in[62] ^ data_in[71] ^ data_in[73] ^ data_in[80] ^ data_in[82] ^ data_in[83] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[99] ^ data_in[102] ^ data_in[104] ^ data_in[105] ^ data_in[107] ^ data_in[108] ^ data_in[109] ^ data_in[110] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[117] ^ data_in[120] ^ data_in[121] ^ data_in[123] ^ data_in[124] ^ data_in[125] ^ data_in[126];
   
   assign crc_bit22_0 = data_in[0] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[16] ^ data_in[18] ^ data_in[19] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[52] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[65];
   
   assign crc_bit22_1 = data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[73] ^ data_in[74] ^ data_in[79] ^ data_in[82] ^ data_in[85] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[101] ^ data_in[104] ^ data_in[105] ^ data_in[108] ^ data_in[109] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124];
   
  //  lfsr_c[22] = crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ data_in[0] ^ data_in[9] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[16] ^ data_in[18] ^ data_in[19] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[48] ^ data_in[52] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[68] ^ data_in[73] ^ data_in[74] ^ data_in[79] ^ data_in[82] ^ data_in[85] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[101] ^ data_in[104] ^ data_in[105] ^ data_in[108] ^ data_in[109] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124];
  
  assign crc_bit23_0 = data_in[0] ^ data_in[1] ^ data_in[6] ^ data_in[9] ^ data_in[13] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[38] ^ data_in[39] ^ data_in[42] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[65] ^ data_in[69] ^ data_in[72];
  
  assign crc_bit23_1 = data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[93] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[109] ^ data_in[111] ^ data_in[113] ^ data_in[115] ^ data_in[117] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[122];
  
  assign crc_bit23_2 = data_in[124] ^ data_in[126] ^ data_in[127];
  
   // lfsr_c[23] = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[13] ^ crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31] ^ data_in[0] ^ data_in[1] ^ data_in[6] ^ data_in[9] ^ data_in[13] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[19] ^ data_in[20] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[38] ^ data_in[39] ^ data_in[42] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[50] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[65] ^ data_in[69] ^ data_in[72] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[84] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[93] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[109] ^ data_in[111] ^ data_in[113] ^ data_in[115] ^ data_in[117] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[122] ^ data_in[124] ^ data_in[126] ^ data_in[127];
   
   assign crc_bit24_0 = data_in[1] ^ data_in[2] ^ data_in[7] ^ data_in[10] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[32] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[39] ^ data_in[40] ^ data_in[43] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[60] ^ data_in[61] ^ data_in[63] ^ data_in[66] ^ data_in[70] ^ data_in[73];
   
   assign crc_bit24_1 = data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[110] ^ data_in[112] ^ data_in[114] ^ data_in[116] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[123];
   
   assign crc_bit24_2 = data_in[125] ^ data_in[127];
   
   // lfsr_c[24] = crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[14] ^ crc_in[16] ^ crc_in[18] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[31] ^ data_in[1] ^ data_in[2] ^ data_in[7] ^ data_in[10] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[20] ^ data_in[21] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[32] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[39] ^ data_in[40] ^ data_in[43] ^ data_in[47] ^ data_in[48] ^ data_in[50] ^ data_in[51] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[60] ^ data_in[61] ^ data_in[63] ^ data_in[66] ^ data_in[70] ^ data_in[73] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[85] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[94] ^ data_in[97] ^ data_in[98] ^ data_in[99] ^ data_in[101] ^ data_in[103] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[110] ^ data_in[112] ^ data_in[114] ^ data_in[116] ^ data_in[118] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[123] ^ data_in[125] ^ data_in[127];
   
   assign crc_bit25_0 = data_in[2] ^ data_in[3] ^ data_in[8] ^ data_in[11] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ data_in[28] ^ data_in[29] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[40] ^ data_in[41] ^ data_in[44] ^ data_in[48] ^ data_in[49] ^ data_in[51] ^ data_in[52] ^ data_in[56] ^ data_in[57] ^ data_in[58] ^ data_in[61] ^ data_in[62] ^ data_in[64] ^ data_in[67] ^ data_in[71] ^ data_in[74];
   
   assign crc_bit25_1 = data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[102] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[111] ^ data_in[113] ^ data_in[115] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[124];
   
   assign crc_bit25_2 = data_in[126];
   
   // lfsr_c[25] = crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30] ^ data_in[2] ^ data_in[3] ^ data_in[8] ^ data_in[11] ^ data_in[15] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[21] ^ data_in[22] ^ data_in[28] ^ data_in[29] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[40] ^ data_in[41] ^ data_in[44] ^ data_in[48] ^ data_in[49] ^ data_in[51] ^ data_in[52] ^ data_in[56] ^ data_in[57] ^ data_in[58] ^ data_in[61] ^ data_in[62] ^ data_in[64] ^ data_in[67] ^ data_in[71] ^ data_in[74] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[87] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[98] ^ data_in[99] ^ data_in[100] ^ data_in[102] ^ data_in[104] ^ data_in[105] ^ data_in[106] ^ data_in[107] ^ data_in[111] ^ data_in[113] ^ data_in[115] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[124] ^ data_in[126];
   
   assign crc_bit26_0 = data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[10] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[31] ^ data_in[38] ^ data_in[39] ^ data_in[41] ^ data_in[42] ^ data_in[44] ^ data_in[47] ^ data_in[48] ^ data_in[49] ^ data_in[52] ^ data_in[54] ^ data_in[55] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[66] ^ data_in[67];
   
   assign crc_bit26_1 = data_in[73] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[81] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[100] ^ data_in[104] ^ data_in[105] ^ data_in[107] ^ data_in[108] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[126];
   
   // lfsr_c[26] = crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[30] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[10] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[28] ^ data_in[31] ^ data_in[38] ^ data_in[39] ^ data_in[41] ^ data_in[42] ^ data_in[44] ^ data_in[47] ^ data_in[48] ^ data_in[49] ^ data_in[52] ^ data_in[54] ^ data_in[55] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[66] ^ data_in[67] ^ data_in[73] ^ data_in[75] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[81] ^ data_in[88] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[95] ^ data_in[97] ^ data_in[98] ^ data_in[100] ^ data_in[104] ^ data_in[105] ^ data_in[107] ^ data_in[108] ^ data_in[110] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[117] ^ data_in[119] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[126];
   
   assign crc_bit27_0 = data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[11] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[32] ^ data_in[39] ^ data_in[40] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[48] ^ data_in[49] ^ data_in[50] ^ data_in[53] ^ data_in[55] ^ data_in[56] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[63] ^ data_in[67] ^ data_in[68];
   
   assign crc_bit27_1 = data_in[74] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[82] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[96] ^ data_in[98] ^ data_in[99] ^ data_in[101] ^ data_in[105] ^ data_in[106] ^ data_in[108] ^ data_in[109] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[118] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[127];
   
   
  //  lfsr_c[27] = crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[31] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7] ^ data_in[11] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[29] ^ data_in[32] ^ data_in[39] ^ data_in[40] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[48] ^ data_in[49] ^ data_in[50] ^ data_in[53] ^ data_in[55] ^ data_in[56] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[63] ^ data_in[67] ^ data_in[68] ^ data_in[74] ^ data_in[76] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[82] ^ data_in[89] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[96] ^ data_in[98] ^ data_in[99] ^ data_in[101] ^ data_in[105] ^ data_in[106] ^ data_in[108] ^ data_in[109] ^ data_in[111] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[118] ^ data_in[120] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[127];
  
  assign crc_bit28_0 = data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[12] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[33] ^ data_in[40] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[46] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[54] ^ data_in[56] ^ data_in[57] ^ data_in[59] ^ data_in[61] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[68] ^ data_in[69];
  
  assign crc_bit28_1 = data_in[75] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[83] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[97] ^ data_in[99] ^ data_in[100] ^ data_in[102] ^ data_in[106] ^ data_in[107] ^ data_in[109] ^ data_in[110] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124];
  
  //  lfsr_c[28] = crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[8] ^ data_in[12] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[30] ^ data_in[33] ^ data_in[40] ^ data_in[41] ^ data_in[43] ^ data_in[44] ^ data_in[46] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[54] ^ data_in[56] ^ data_in[57] ^ data_in[59] ^ data_in[61] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[68] ^ data_in[69] ^ data_in[75] ^ data_in[77] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[83] ^ data_in[90] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[97] ^ data_in[99] ^ data_in[100] ^ data_in[102] ^ data_in[106] ^ data_in[107] ^ data_in[109] ^ data_in[110] ^ data_in[112] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[119] ^ data_in[121] ^ data_in[122] ^ data_in[123] ^ data_in[124];
  
  assign crc_bit29_0 = data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[13] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[41] ^ data_in[42] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[65] ^ data_in[69] ^ data_in[70];
  
  assign crc_bit29_1 = data_in[76] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[84] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[98] ^ data_in[100] ^ data_in[101] ^ data_in[103] ^ data_in[107] ^ data_in[108] ^ data_in[110] ^ data_in[111] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[120] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[125];
  
   // lfsr_c[29] = crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ data_in[3] ^ data_in[6] ^ data_in[7] ^ data_in[9] ^ data_in[13] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[31] ^ data_in[34] ^ data_in[41] ^ data_in[42] ^ data_in[44] ^ data_in[45] ^ data_in[47] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[55] ^ data_in[57] ^ data_in[58] ^ data_in[60] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[65] ^ data_in[69] ^ data_in[70] ^ data_in[76] ^ data_in[78] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[84] ^ data_in[91] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[98] ^ data_in[100] ^ data_in[101] ^ data_in[103] ^ data_in[107] ^ data_in[108] ^ data_in[110] ^ data_in[111] ^ data_in[113] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[120] ^ data_in[122] ^ data_in[123] ^ data_in[124] ^ data_in[125];
   
   assign crc_bit30_0 = data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[14] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[32] ^ data_in[35] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[46] ^ data_in[48] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[70] ^ data_in[71];
   
   assign crc_bit30_1 = data_in[77] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[85] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[97] ^ data_in[99] ^ data_in[101] ^ data_in[102] ^ data_in[104] ^ data_in[108] ^ data_in[109] ^ data_in[111] ^ data_in[112] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[117] ^ data_in[121] ^ data_in[123] ^ data_in[124] ^ data_in[125] ^ data_in[126];
   
  //  lfsr_c[30] = crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ data_in[4] ^ data_in[7] ^ data_in[8] ^ data_in[10] ^ data_in[14] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[32] ^ data_in[35] ^ data_in[42] ^ data_in[43] ^ data_in[45] ^ data_in[46] ^ data_in[48] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[56] ^ data_in[58] ^ data_in[59] ^ data_in[61] ^ data_in[63] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[70] ^ data_in[71] ^ data_in[77] ^ data_in[79] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[85] ^ data_in[92] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[97] ^ data_in[99] ^ data_in[101] ^ data_in[102] ^ data_in[104] ^ data_in[108] ^ data_in[109] ^ data_in[111] ^ data_in[112] ^ data_in[114] ^ data_in[115] ^ data_in[116] ^ data_in[117] ^ data_in[121] ^ data_in[123] ^ data_in[124] ^ data_in[125] ^ data_in[126];
  
  assign crc_bit31_0 = data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[15] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[43] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[71] ^ data_in[72];
  
  assign crc_bit31_1 = data_in[78] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[105] ^ data_in[109] ^ data_in[110] ^ data_in[112] ^ data_in[113] ^ data_in[115] ^ data_in[116] ^ data_in[117] ^ data_in[118] ^ data_in[122] ^ data_in[124] ^ data_in[125] ^ data_in[126] ^ data_in[127];
  
  //  lfsr_c[31] = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31] ^ data_in[5] ^ data_in[8] ^ data_in[9] ^ data_in[11] ^ data_in[15] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[27] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[36] ^ data_in[43] ^ data_in[44] ^ data_in[46] ^ data_in[47] ^ data_in[49] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[57] ^ data_in[59] ^ data_in[60] ^ data_in[62] ^ data_in[64] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[71] ^ data_in[72] ^ data_in[78] ^ data_in[80] ^ data_in[81] ^ data_in[82] ^ data_in[83] ^ data_in[84] ^ data_in[86] ^ data_in[93] ^ data_in[94] ^ data_in[95] ^ data_in[96] ^ data_in[97] ^ data_in[98] ^ data_in[100] ^ data_in[102] ^ data_in[103] ^ data_in[105] ^ data_in[109] ^ data_in[110] ^ data_in[112] ^ data_in[113] ^ data_in[115] ^ data_in[116] ^ data_in[117] ^ data_in[118] ^ data_in[122] ^ data_in[124] ^ data_in[125] ^ data_in[126] ^ data_in[127];

 // end // always
 
 always @ (posedge clk) begin
  	if (!rst) begin
  	
  		crc_bit0_0_reg 	<= 	0;
  		crc_bit0_1_reg 	<= 	0;
  		crc_bit0_2_reg 	<= 	0;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           																																																																																																																																																																																																																																																													
  		
  		crc_bit1_0_reg 	<= 	0;
  		crc_bit1_1_reg 	<= 	0;
  		
  	
  	
  		crc_bit2_0_reg 	<= 	0;
  		crc_bit2_1_reg 	<= 	0;
  		
  		
  	
  		crc_bit3_0_reg 	<= 	0;
  		crc_bit3_1_reg 	<= 	0;
  		
  		
  	
  		crc_bit4_0_reg 	<= 	0;
  		crc_bit4_1_reg 	<= 	0;
  		crc_bit4_2_reg 	<= 	0;
  		
  		
  		crc_bit5_0_reg 	<= 	0;
  		crc_bit5_1_reg 	<= 	0;
  		crc_bit5_2_reg 	<= 	0;
  
  		
  		crc_bit6_0_reg 	<=	0;
		crc_bit6_1_reg 	<=	0;
		crc_bit6_2_reg 	<=	0;
		
		
		crc_bit7_0_reg 	<=	0;
		crc_bit7_1_reg 	<=	0;
	
	
		
		crc_bit8_0_reg 	<=	0;
		crc_bit8_1_reg 	<=	0;
		crc_bit8_2_reg 	<=	0;
	
		
		crc_bit9_0_reg 	<=	0;
		crc_bit9_1_reg 	<=	0;
		crc_bit9_2_reg 	<=	0;
	
		
		crc_bit10_0_reg 	<=	0;
		crc_bit10_1_reg 	<=	0;
		crc_bit10_2_reg 	<=	0;
		
		
		crc_bit11_0_reg 	<=	0;
		crc_bit11_1_reg 	<=	0;
		crc_bit11_2_reg 	<=	0;
	
		
		crc_bit12_0_reg 	<=	0;
		crc_bit12_1_reg 	<=	0;
		crc_bit12_2_reg 	<=	0;

		
		crc_bit13_0_reg 	<=	0;
		crc_bit13_1_reg 	<=	0;
		crc_bit13_2_reg 	<=	0;

		
		crc_bit14_0_reg 	<=	0;
		crc_bit14_1_reg 	<=	0;
		crc_bit14_2_reg 	<=	0;

		
		crc_bit15_0_reg 	<=	0;
		crc_bit15_1_reg 	<=	0;
	

		
		crc_bit16_0_reg 	<=	0;
		crc_bit16_1_reg 	<=	0;
		
		
		
		crc_bit17_0_reg 	<=	0;
		crc_bit17_1_reg 	<=	0;
		
		
		
		crc_bit18_0_reg 	<=	0;
		crc_bit18_1_reg 	<=	0;
		
	
		
		crc_bit19_0_reg 	<=	0;
		crc_bit19_1_reg 	<=	0;
		
		
		
		crc_bit20_0_reg 	<=	0;
		crc_bit20_1_reg 	<=	0;
		
	
		
		crc_bit21_0_reg 	<=	0;
		crc_bit21_1_reg 	<=	0;
		

		
		crc_bit22_0_reg 	<=	0;
		crc_bit22_1_reg 	<=	0;
		crc_bit22_2_reg 	<=	0;
	
		
		crc_bit23_0_reg 	<=	0;
		crc_bit23_1_reg 	<=	0;
		crc_bit23_2_reg 	<=	0;
	
		
		crc_bit24_0_reg 	<=	0;
		crc_bit24_1_reg 	<=	0;
		crc_bit24_2_reg 	<=	0;
	
		
		crc_bit25_0_reg 	<=	0;
		crc_bit25_1_reg 	<=	0;
		crc_bit25_2_reg 	<=	0;
	
		
		crc_bit26_0_reg 	<=	0;
		crc_bit26_1_reg 	<=	0;
		crc_bit26_2_reg 	<=	0;
	
		//crc_bit26_4_reg 	<=	0;
		crc_bit27_0_reg 	<=	0;
		crc_bit27_1_reg 	<=	0;
		crc_bit27_2_reg 	<=	0;

		//crc_bit27_4_reg 	<=	0;
		crc_bit28_0_reg 	<=	0;
		crc_bit28_1_reg 	<=	0;
		crc_bit28_2_reg 	<=	0;
	
		//crc_bit28_4_reg 	<=	0;
		crc_bit29_0_reg 	<=	0;
		crc_bit29_1_reg 	<=	0;
		crc_bit29_2_reg 	<=	0;

		//crc_bit29_4_reg 	<=	0;
		crc_bit30_0_reg 	<=	0;
		crc_bit30_1_reg 	<=	0;
		crc_bit30_2_reg 	<=	0;

		//crc_bit30_4_reg 	<=	0;
		crc_bit31_0_reg 	<=	0;
		crc_bit31_1_reg 	<=	0;
		crc_bit31_2_reg 	<=	0;
		lfsr_c 				<= 32'h0;
  		lfsr_q 				<= 32'h0;
		
		//crc_bit31_4_reg 	<=	0;
  	end
  	else begin
  		crc_bit0_0_reg 	<= crc_bit0_0;
  		crc_bit0_1_reg 	<= crc_bit0_1;
  		crc_bit0_2_reg 	<= crc_bit0_2;
  		
  		
  		crc_bit1_0_reg 	<= crc_bit1_0;
  		crc_bit1_1_reg 	<= crc_bit1_1;
  		
  	
  	
  		crc_bit2_0_reg 	<= crc_bit2_0;
  		crc_bit2_1_reg 	<= crc_bit2_1;
  		
  		
  		
  		crc_bit3_0_reg 	<= crc_bit3_0;
  		crc_bit3_1_reg 	<= crc_bit3_1;
  		
 
  	
  		crc_bit4_0_reg 	<= crc_bit4_0;
  		crc_bit4_1_reg 	<= crc_bit4_1;
  		crc_bit4_2_reg 	<= crc_bit4_2;
  	
  		
  		crc_bit5_0_reg 	<= crc_bit5_0;
  		crc_bit5_1_reg 	<= crc_bit5_1;
  		crc_bit5_2_reg 	<= crc_bit5_2;
  	
  		
  		crc_bit6_0_reg 	<= crc_bit6_0;
  		crc_bit6_1_reg 	<= crc_bit6_1;
  		crc_bit6_2_reg 	<= crc_bit6_2;
  		
  		
  		crc_bit7_0_reg 	<= crc_bit7_0;
  		crc_bit7_1_reg 	<= crc_bit7_1;
  		
  	
  		
  		crc_bit8_0_reg 	<= crc_bit8_0;
  		crc_bit8_1_reg 	<= crc_bit8_1;
  		crc_bit8_2_reg 	<= crc_bit8_2;
  	
  		
  		crc_bit9_0_reg 	<= crc_bit9_0;
  		crc_bit9_1_reg 	<= crc_bit9_1;
  		crc_bit9_2_reg 	<= crc_bit9_2;
  	
  		
  		crc_bit10_0_reg 	<= crc_bit10_0;
  		crc_bit10_1_reg 	<= crc_bit10_1;
  		crc_bit10_2_reg 	<= crc_bit10_2;
  	
  		
  		crc_bit11_0_reg 	<= crc_bit11_0;
  		crc_bit11_1_reg 	<= crc_bit11_1;
  		crc_bit11_2_reg 	<= crc_bit11_2;

  		
  		crc_bit12_0_reg 	<= crc_bit12_0;
  		crc_bit12_1_reg 	<= crc_bit12_1;
  		crc_bit12_2_reg 	<= crc_bit12_2;
  	
  	
  		crc_bit13_0_reg 	<= crc_bit13_0;
  		crc_bit13_1_reg 	<= crc_bit13_1;
  		crc_bit13_2_reg 	<= crc_bit13_2;
  
  		
  		crc_bit14_0_reg 	<= crc_bit14_0;
  		crc_bit14_1_reg 	<= crc_bit14_1;
  		crc_bit14_2_reg 	<= crc_bit14_2;

  		
  		crc_bit15_0_reg 	<= crc_bit15_0;
  		crc_bit15_1_reg 	<= crc_bit15_1;

  		
  		crc_bit16_0_reg 	<= crc_bit16_0;
  		crc_bit16_1_reg 	<= crc_bit16_1;
  		
  		
  		
  		crc_bit17_0_reg 	<= crc_bit17_0;
  		crc_bit17_1_reg 	<= crc_bit17_1;
  		
  		
  		
  		crc_bit18_0_reg 	<= crc_bit18_0;
  		crc_bit18_1_reg 	<= crc_bit18_1;
  		
  
  		
  		crc_bit19_0_reg 	<= crc_bit19_0;
  		crc_bit19_1_reg 	<= crc_bit19_1;
  		

  		
  		crc_bit20_0_reg 	<= crc_bit20_0;
  		crc_bit20_1_reg 	<= crc_bit20_1;
  		

  		
  		crc_bit21_0_reg 	<= crc_bit21_0;
  		crc_bit21_1_reg 	<= crc_bit21_1;
  		
  	
  		
  		crc_bit22_0_reg 	<= crc_bit22_0;
  		crc_bit22_1_reg 	<= crc_bit22_1;
  		crc_bit22_2_reg 	<= crc_bit22_2;
  	
  		
  		crc_bit23_0_reg 	<= crc_bit23_0;
  		crc_bit23_1_reg 	<= crc_bit23_1;
  		crc_bit23_2_reg 	<= crc_bit23_2;
  	
  		
  		crc_bit24_0_reg 	<= crc_bit24_0;
  		crc_bit24_1_reg 	<= crc_bit24_1;
  		crc_bit24_2_reg 	<= crc_bit24_2;
  	
  		
  		crc_bit25_0_reg 	<= crc_bit25_0;
  		crc_bit25_1_reg 	<= crc_bit25_1;
  		crc_bit25_2_reg 	<= crc_bit25_2;
  	
  		
  		crc_bit26_0_reg 	<= crc_bit26_0;
  		crc_bit26_1_reg 	<= crc_bit26_1;
  		crc_bit26_2_reg 	<= crc_bit26_2;
  	
  		//crc_bit26_4_reg 	<= crc_bit26_4;
  		crc_bit27_0_reg 	<= crc_bit27_0;
  		crc_bit27_1_reg 	<= crc_bit27_1;
  		crc_bit27_2_reg 	<= crc_bit27_2;

  		//crc_bit27_4_reg 	<= crc_bit27_4;
  		crc_bit28_0_reg 	<= crc_bit28_0;
  		crc_bit28_1_reg 	<= crc_bit28_1;
  		crc_bit28_2_reg 	<= crc_bit28_2;

  		//crc_bit28_4_reg 	<= crc_bit28_4;
  		crc_bit29_0_reg 	<= crc_bit29_0;
  		crc_bit29_1_reg 	<= crc_bit29_1;
  		crc_bit29_2_reg 	<= crc_bit29_2;
  		
  		//crc_bit29_4_reg 	<= crc_bit29_4;
  		crc_bit30_0_reg 	<= crc_bit30_0;
  		crc_bit30_1_reg 	<= crc_bit30_1;
  		crc_bit30_2_reg 	<= crc_bit30_2;
  		
  		//crc_bit30_4_reg 	<= crc_bit30_4;
  		crc_bit31_0_reg 	<= crc_bit31_0;
  		crc_bit31_1_reg 	<= crc_bit31_1;
  		crc_bit31_2_reg 	<= crc_bit31_2;
  		
  		lfsr_c[0] 			<=  crc_bit0_0_reg  ^ crc_bit0_1_reg  ^ crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31];
  		lfsr_c[1] 			<=  crc_bit1_0_reg  ^ crc_bit1_1_reg  ^  crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[24] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29];
  		lfsr_c[2] 			<=  crc_bit2_0_reg  ^ crc_bit2_1_reg  ^  crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[6] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[31];
  		lfsr_c[3] 			<=  crc_bit3_0_reg  ^ crc_bit3_1_reg  ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[7] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29]; 
  		lfsr_c[4] 			<=  crc_bit4_0_reg  ^ crc_bit4_1_reg  ^ crc_in[1] ^ crc_in[4] ^ crc_in[7] ^ crc_in[10] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[31]; 
  		lfsr_c[5] 			<=  crc_bit5_0_reg  ^ crc_bit5_1_reg  ^  crc_in[1] ^ crc_in[3] ^ crc_in[7] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[16] ^ crc_in[19] ^ crc_in[20] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31];
  		lfsr_c[6] 			<=  crc_bit6_0_reg  ^ crc_bit6_1_reg  ^ crc_in[2] ^ crc_in[4] ^ crc_in[8] ^ crc_in[11] ^ crc_in[12] ^ crc_in[16] ^ crc_in[17] ^ crc_in[20] ^ crc_in[21] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31]; 
  		lfsr_c[7] 			<=  crc_bit7_0_reg  ^ crc_bit7_1_reg  ^ crc_in[1] ^ crc_in[2] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[20] ^ crc_in[23] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30]; 
  		lfsr_c[8] 			<=  crc_bit8_0_reg  ^ crc_bit8_1_reg  ^ crc_in[1] ^ crc_in[5] ^ crc_in[7] ^ crc_in[9] ^ crc_in[11] ^ crc_in[13] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[30]; 
  		lfsr_c[9] 			<=  crc_bit9_0_reg  ^ crc_bit9_1_reg  ^ crc_in[0] ^ crc_in[2] ^ crc_in[6] ^ crc_in[8] ^ crc_in[10] ^ crc_in[12] ^ crc_in[14] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[31]; 
  		lfsr_c[10] 			<=  crc_bit10_0_reg ^ crc_bit10_1_reg ^ crc_in[0] ^ crc_in[2] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[14] ^ crc_in[17] ^ crc_in[19] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31];
  		lfsr_c[11] 			<=  crc_bit11_0_reg ^ crc_bit11_1_reg ^ crc_in[2] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[17] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29];
  		lfsr_c[12] 			<=  crc_bit12_0_reg ^ crc_bit12_1_reg ^ crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[5] ^ crc_in[6] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[20] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[31];
  		lfsr_c[13] 			<=  crc_bit13_0_reg ^ crc_bit13_1_reg ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[6] ^ crc_in[7] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[18] ^ crc_in[21] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27];
  		lfsr_c[14] 			<=  crc_bit14_0_reg ^ crc_bit14_1_reg ^ crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[7] ^ crc_in[8] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28];
  		lfsr_c[15] 			<=  crc_bit15_0_reg ^ crc_bit15_1_reg ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[12] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29];
  		lfsr_c[16] 			<=  crc_bit16_0_reg ^ crc_bit16_1_reg ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[19] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[28] ^ crc_in[31];
  		lfsr_c[17] 			<=  crc_bit17_0_reg ^ crc_bit17_1_reg ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[20] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[29];
  		lfsr_c[18] 			<=  crc_bit18_0_reg ^ crc_bit18_1_reg ^ crc_in[0] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[21] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[30];
  		lfsr_c[19] 			<=  crc_bit19_0_reg ^ crc_bit19_1_reg ^ crc_in[1] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[22] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[31];
  		lfsr_c[20] 			<=  crc_bit20_0_reg ^ crc_bit20_1_reg ^ crc_in[2] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29];
  		lfsr_c[21] 			<=  crc_bit21_0_reg ^ crc_bit21_1_reg ^ crc_in[0] ^ crc_in[3] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[24] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30];
  		lfsr_c[22] 			<=  crc_bit22_0_reg ^ crc_bit22_1_reg ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[8] ^ crc_in[9] ^ crc_in[12] ^ crc_in[13] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28];
  		lfsr_c[23] 			<=  crc_bit23_0_reg ^ crc_bit23_1_reg ^ crc_bit23_2_reg ^ crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[13] ^ crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[21] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30] ^ crc_in[31];
  		lfsr_c[24] 			<=  crc_bit24_0_reg ^ crc_bit24_1_reg ^ crc_bit24_2_reg ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[14] ^ crc_in[16] ^ crc_in[18] ^ crc_in[20] ^ crc_in[22] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[27] ^ crc_in[29] ^ crc_in[31];
  		lfsr_c[25] 			<=  crc_bit25_0_reg ^ crc_bit25_1_reg ^ crc_bit25_2_reg ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[15] ^ crc_in[17] ^ crc_in[19] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[28] ^ crc_in[30];
  		lfsr_c[26] 			<=  crc_bit26_0_reg ^ crc_bit26_1_reg ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[8] ^ crc_in[9] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[21] ^ crc_in[23] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[30];
  		lfsr_c[27] 			<=  crc_bit27_0_reg ^ crc_bit27_1_reg ^ crc_in[0] ^ crc_in[2] ^ crc_in[3] ^ crc_in[5] ^ crc_in[9] ^ crc_in[10] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[22] ^ crc_in[24] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[31];
  		lfsr_c[28] 			<=  crc_bit28_0_reg ^ crc_bit28_1_reg ^ crc_in[1] ^ crc_in[3] ^ crc_in[4] ^ crc_in[6] ^ crc_in[10] ^ crc_in[11] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[23] ^ crc_in[25] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28];
  		lfsr_c[29] 			<=  crc_bit29_0_reg ^ crc_bit29_1_reg ^ crc_in[0] ^ crc_in[2] ^ crc_in[4] ^ crc_in[5] ^ crc_in[7] ^ crc_in[11] ^ crc_in[12] ^ crc_in[14] ^ crc_in[15] ^ crc_in[17] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[24] ^ crc_in[26] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29];
  		lfsr_c[30] 			<=  crc_bit30_0_reg ^ crc_bit30_1_reg ^ crc_in[0] ^ crc_in[1] ^ crc_in[3] ^ crc_in[5] ^ crc_in[6] ^ crc_in[8] ^ crc_in[12] ^ crc_in[13] ^ crc_in[15] ^ crc_in[16] ^ crc_in[18] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[25] ^ crc_in[27] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30];
  		lfsr_c[31] 			<=  crc_bit31_0_reg ^ crc_bit31_1_reg ^ crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[4] ^ crc_in[6] ^ crc_in[7] ^ crc_in[9] ^ crc_in[13] ^ crc_in[14] ^ crc_in[16] ^ crc_in[17] ^ crc_in[19] ^ crc_in[20] ^ crc_in[21] ^ crc_in[22] ^ crc_in[26] ^ crc_in[28] ^ crc_in[29] ^ crc_in[30] ^ crc_in[31];
  end
 end
  		
  	
  always @(posedge clk) begin
    if(!rst) begin
      lfsr_q <= {32{1'b1}};
    end
    else begin
      lfsr_q <= crc_en ? lfsr_c : lfsr_q;
    end
  end // always
endmodule // crc