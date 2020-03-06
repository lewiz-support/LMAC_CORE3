//
///////////////////////////////////////////////////////////////////////////////////////////
// Copyright © 2010-2013, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
///////////////////////////////////////////////////////////////////////////////////////////
//
// Disclaimer:
// This disclaimer is not a license and does not grant any rights to the materials
// distributed herewith. Except as otherwise provided in a valid license issued to
// you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
// MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
// DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
// INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
// OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
// (whether in contract or tort, including negligence, or under any other theory
// of liability) for any loss or damage of any kind or nature related to, arising
// under or in connection with these materials, including for any direct, or any
// indirect, special, incidental, or consequential loss or damage (including loss
// of data, profits, goodwill, or any type of loss or damage suffered as a result
// of any action brought by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-safe, or for use in any
// application requiring fail-safe performance, such as life-support or safety
// devices or systems, Class III medical devices, nuclear facilities, applications
// related to the deployment of airbags, or any other applications that could lead
// to death, personal injury, or severe property or environmental damage
// (individually and collectively, "Critical Applications"). Customer assumes the
// sole risk and liability of any use of Xilinx products in Critical Applications,
// subject only to applicable laws and regulations governing limitations on product
// liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// Definition of a program memory for KCPSM6 including generic parameters for the 
// convenient selection of device family, program memory size and the ability to include 
// the JTAG Loader hardware for rapid software development.
//
// This file is primarily for use during code development and it is recommended that the 
// appropriate simplified program memory definition be used in a final production design. 
//
//
//    Generic                  Values             Comments
//    Parameter                Supported
//  
//    C_FAMILY                 "S6"               Spartan-6 device
//                             "V6"               Virtex-6 device
//                             "7S"               7-Series device 
//                                                  (Artix-7, Kintex-7, Virtex-7 or Zynq)
//
//    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
//
//    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
//
// Notes
//
// If your design contains MULTIPLE KCPSM6 instances then only one should have the 
// JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
// '1' on one instance of the program memory). Advanced users may be interested to know 
// that it is possible to connect JTAG Loader to multiple memories and then to use the 
// JTAG Loader utility to specify which memory contents are to be modified. However, 
// this scheme does require some effort to set up and the additional connectivity of the 
// multiple BRAMs can impact the placement, routing and performance of the complete 
// design. Please contact the author at Xilinx for more detailed information. 
//
// Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
// 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
// without requiring changes to the fundamental hardware definition. However, when the 
// program memory is 1K then only the lower 10-bits of the address are actually used and 
// the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
// 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
//
// Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
// size of the program and the device family. 
//
// In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
// will require 2 BRAMs to be used and a 4K program will require 4 BRAMs to be used. It 
// should be noted that a 4K program is not such a natural fit in a Spartan-6 device and 
// the implementation also requires a small amount of logic resulting in slightly lower 
// performance. A Spartan-6 BRAM can also be split into two 9k-bit memories suggesting 
// that a program containing up to 512 instructions could be implemented. However, there 
// is a silicon errata which makes this unsuitable and therefore it is not supported by 
// this file.
//
// In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
// obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
// 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally 
// reported as being an 18k-bit BRAM). For a program of 4K instructions, 2 BRAMs are used.
//
//
// Program defined by 'U:\althouse\releases\v7_xt_conn_trd\2014.1\test_0422_pico_verilog\v7_xt_conn_trd\hardware\sources\hdl\pvtmon\utils\power_test_control_program.psm'.
//
// Generated by KCPSM6 Assembler: 22 Apr 2014 - 10:17:29. 
//
// Assembler used ROM_form template: ROM_form_JTAGLoader_14March13.v
//
//
`timescale 1ps/1ps
module power_test_control_program (address, instruction, enable, rdl, clk);
//
parameter integer C_JTAG_LOADER_ENABLE = 0;                        
parameter         C_FAMILY = "S6";                        
parameter integer C_RAM_SIZE_KWORDS = 1;                        
//
input         clk;        
input  [11:0] address;        
input         enable;        
output [17:0] instruction;        
output        rdl;
//
//
wire [15:0] address_a;
wire        pipe_a11;
wire [35:0] data_in_a;
wire [35:0] data_out_a;
wire [35:0] data_out_a_l;
wire [35:0] data_out_a_h;
wire [35:0] data_out_a_ll;
wire [35:0] data_out_a_lh;
wire [35:0] data_out_a_hl;
wire [35:0] data_out_a_hh;
wire [15:0] address_b;
wire [35:0] data_in_b;
wire [35:0] data_in_b_l;
wire [35:0] data_in_b_ll;
wire [35:0] data_in_b_hl;
wire [35:0] data_out_b;
wire [35:0] data_out_b_l;
wire [35:0] data_out_b_ll;
wire [35:0] data_out_b_hl;
wire [35:0] data_in_b_h;
wire [35:0] data_in_b_lh;
wire [35:0] data_in_b_hh;
wire [35:0] data_out_b_h;
wire [35:0] data_out_b_lh;
wire [35:0] data_out_b_hh;
wire        enable_b;
wire        clk_b;
wire [7:0]  we_b;
wire [3:0]  we_b_l;
wire [3:0]  we_b_h;
//
wire [11:0] jtag_addr;
wire        jtag_we;
wire        jtag_clk;
wire [17:0] jtag_din;
wire [17:0] jtag_dout;
wire [17:0] jtag_dout_1;
wire [0:0]  jtag_en;
//
wire [0:0]  picoblaze_reset;
wire [0:0]  rdl_bus;
//
parameter integer BRAM_ADDRESS_WIDTH = addr_width_calc(C_RAM_SIZE_KWORDS);
//
//
function integer addr_width_calc;
  input integer size_in_k;
    if (size_in_k == 1) begin addr_width_calc = 10; end
      else if (size_in_k == 2) begin addr_width_calc = 11; end
      else if (size_in_k == 4) begin addr_width_calc = 12; end
      else begin
        if (C_RAM_SIZE_KWORDS != 1 && C_RAM_SIZE_KWORDS != 2 && C_RAM_SIZE_KWORDS != 4) begin
          //#0;
          $display("Invalid BlockRAM size. Please set to 1, 2 or 4 K words..\n");
          $finish;
        end
    end
endfunction
//
//
generate
  if (C_RAM_SIZE_KWORDS == 1) begin : ram_1k_generate 
    //
    if (C_FAMILY == "S6") begin: s6 
      //
      assign address_a[13:0] = {address[9:0], 4'b0000};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {34'b0000000000000000000000000000000000, address[11:10]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b[13:0] = 14'b00000000000000;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b[13:0] = {jtag_addr[9:0], 4'b0000};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (18),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (18),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'hD141D0401300120011001000D007D006D005D004D009D0081000B00101F80201),
                   .INIT_01             (256'h004500370029201300CC02E600FC001D601ADA0102A118061900B012D343D242),
                   .INIT_02             (256'h1011F0321010F0311000F0301034500000B500A70099008B007D006F00610053),
                   .INIT_03             (256'h1016F0331015F0321014F0311001F0301034500000F700E300D0F0341012F033),
                   .INIT_04             (256'h00D0F034101AF0331019F0321018F0311002F0301034500000F700E300D0F034),
                   .INIT_05             (256'h00F700E300D0F034101EF033101DF032101CF0311003F0301034500000F700E3),
                   .INIT_06             (256'h1035500000F700E300D0F0341022F0331021F0321020F0311000F03010355000),
                   .INIT_07             (256'h1002F0301035500000F700E300D0F0341026F0331025F0321024F0311001F030),
                   .INIT_08             (256'h102CF0311003F0301035500000F700E300D0F034102AF0331029F0321028F031),
                   .INIT_09             (256'h1031F0321030F0311000F0301036500000F700E300D0F034102EF033102DF032),
                   .INIT_0A             (256'h1036F0331035F0321034F0311001F0301036500000F700E300D0F0341032F033),
                   .INIT_0B             (256'h00D0F034103AF0331039F0321038F0311002F0301036500000F700E300D0F034),
                   .INIT_0C             (256'h500002D102C702BD500002989A0FDB1002A11C001D0018031900500000F700E3),
                   .INIT_0D             (256'h0B301C001D00B832190002771680173EB501B4000199BA300186F000B031BA30),
                   .INIT_0E             (256'h190002771600177D0286B501B40001ADBA300186F000B031BA30500002980A20),
                   .INIT_0F             (256'h03B002A11812190050000148BF34BE33BD32500002980A200B301C001D00B833),
                   .INIT_10             (256'h19002310020000A001B002A1181E19002310020000A001B002A11816190002A0),
                   .INIT_11             (256'h02A1182A19002310020000A001B002A1182619002310020000A001B002A11822),
                   .INIT_12             (256'h00A001B002A1183219002310020000A001B002A1182E19002310020000A001B0),
                   .INIT_13             (256'h2310020000A001B002A1183A19002310020000A001B002A11836190023100200),
                   .INIT_14             (256'h02A108E0190004A005B002A108D01900500002980A200B301C001D0018011900),
                   .INIT_15             (256'h027706D007E0082009301A00027706000710148915410D200E30027706A007B0),
                   .INIT_16             (256'h1A350186F00010021A355000029808F019000A900BA01C001D002A2029100800),
                   .INIT_17             (256'h01B11B1F1CFD50000195F0001000F00110101A3502620195F0001062F0011016),
                   .INIT_18             (256'h1B011C04500001B11B011C04500001D11B011C00500001B11B011C0021814181),
                   .INIT_19             (256'h01B11B021C38500001B11B021C8B500001D11B021C21500001B11B011C2001D1),
                   .INIT_1A             (256'h01B11B021C8C500001D11B021C39500001B11B021C39500001D11B021C385000),
                   .INIT_1B             (256'h05A002190242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                   .INIT_1C             (256'hC5E00220E530022C024561C4C3B01301E53001EB022602450242022E01EB4507),
                   .INIT_1D             (256'h01EBA5300242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                   .INIT_1E             (256'hD1C04108C50001E010805000D50102200242022E05E061DEC3B013010242022E),
                   .INIT_1F             (256'h0220020561F994010256020B020514645000E1EC400E4E0621F54E077E03E1F4),
                   .INIT_20             (256'h220DD0019004DF205F0150000256DF202F0070FF10015000DF205F021F015000),
                   .INIT_21             (256'h50000205025202110256020B02165000DF205F025000DF202F0070FF10025000),
                   .INIT_22             (256'hC540148022270216500002050252020B02560211500002160252020B02560211),
                   .INIT_23             (256'h024E4500D0029004024E020B02560216222F9000440E02270216223402116233),
                   .INIT_24             (256'h110012005000624B9001100B500062469401023814085000D501023850000205),
                   .INIT_25             (256'h11181200227210FA110012002272101F1100120022721019110012002272100C),
                   .INIT_26             (256'h115E125F22721068118912092272104811E8120122721012117A12002272106A),
                   .INIT_27             (256'h430823500240E27F4608470E12001300181050006272B200B100900122721010),
                   .INIT_28             (256'h4408450E2292D080100B3507400A400A400A00505000627A9801400841084208),
                   .INIT_29             (256'hB001B031DD07DC06DB05DA04D909D80822929001450044061000D000628E1001),
                   .INIT_2A             (256'h5000980C990D02B4B004DA8050009D039C029B019A00B001B021D909D8085000),
                   .INIT_2B             (256'h180819051A40500002B01800190A1A42500062B4D001900EB014D881D982DA80),
                   .INIT_2C             (256'h025E02B018A019301A4102B0180019051A405000025E02B0180019301A4102B0),
                   .INIT_2D             (256'h4808490E1006500002980A200B301C001D001802190002E302DD02AA1A005000),
                   .INIT_2E             (256'h02B0DD43DC42DB41DA403BC01A0002A118041900500002800390500062DE9001),
                   .INIT_2F             (256'h4308440E42084308440E42084308440E42084308440E42084308440E04D003C0),
                   .INIT_30             (256'h9A0818051900B012DD421D00230DB002230AF300D200333F42084308440E4208),
                   .INIT_31             (256'h00000000000000000000000000000000000000000000500002989D0B9C0A9B09),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h22AA22222AA22222AA22222AA22222AA22222AA22222AAAAAAAAC82AA00AAA2A),
                   .INITP_01            (256'h20A0280020822828002008A0AAA2802AA22222AA22222AA22222AA22222AA222),
                   .INITP_02            (256'h82A20A8828280015800800208020A00050814205081420508142050814205080),
                   .INITP_03            (256'hADA8B5931022A35A8A8A92826AB5AAA92A8A928282828282828282820A0A0A0B),
                   .INITP_04            (256'h57502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282),
                   .INITP_05            (256'h555555502A82082D528002A2A0202A020280B0AA82A802AAAAAA95DD5C454B55),
                   .INITP_06            (256'h00000000000000000000000000000000000000000000000000000280028AD455),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
       kcpsm6_rom( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a[31:0]),
                   .DOPA                (data_out_a[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b[31:0]),
                   .DOPB                (data_out_b[35:32]), 
                   .DIB                 (data_in_b[31:0]),
                   .DIPB                (data_in_b[35:32]), 
                   .WEB                 (we_b[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
    end // s6;
    // 
    //
    if (C_FAMILY == "V6") begin: v6 
      //
      assign address_a[13:0] = {address[9:0], 4'b1111};
      assign instruction = data_out_a[17:0];
      assign data_in_a[17:0] = {16'b0000000000000000, address[11:10]};
      assign jtag_dout = data_out_b[17:0];
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b[17:0] = data_out_b[17:0];
        assign address_b[13:0] = 14'b11111111111111;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b[17:0] = jtag_din[17:0];
        assign address_b[13:0] = {jtag_addr[9:0], 4'b1111};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB18E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (18'b000000000000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (18'b000000000000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'hD141D0401300120011001000D007D006D005D004D009D0081000B00101F80201),
                 .INIT_01                   (256'h004500370029201300CC02E600FC001D601ADA0102A118061900B012D343D242),
                 .INIT_02                   (256'h1011F0321010F0311000F0301034500000B500A70099008B007D006F00610053),
                 .INIT_03                   (256'h1016F0331015F0321014F0311001F0301034500000F700E300D0F0341012F033),
                 .INIT_04                   (256'h00D0F034101AF0331019F0321018F0311002F0301034500000F700E300D0F034),
                 .INIT_05                   (256'h00F700E300D0F034101EF033101DF032101CF0311003F0301034500000F700E3),
                 .INIT_06                   (256'h1035500000F700E300D0F0341022F0331021F0321020F0311000F03010355000),
                 .INIT_07                   (256'h1002F0301035500000F700E300D0F0341026F0331025F0321024F0311001F030),
                 .INIT_08                   (256'h102CF0311003F0301035500000F700E300D0F034102AF0331029F0321028F031),
                 .INIT_09                   (256'h1031F0321030F0311000F0301036500000F700E300D0F034102EF033102DF032),
                 .INIT_0A                   (256'h1036F0331035F0321034F0311001F0301036500000F700E300D0F0341032F033),
                 .INIT_0B                   (256'h00D0F034103AF0331039F0321038F0311002F0301036500000F700E300D0F034),
                 .INIT_0C                   (256'h500002D102C702BD500002989A0FDB1002A11C001D0018031900500000F700E3),
                 .INIT_0D                   (256'h0B301C001D00B832190002771680173EB501B4000199BA300186F000B031BA30),
                 .INIT_0E                   (256'h190002771600177D0286B501B40001ADBA300186F000B031BA30500002980A20),
                 .INIT_0F                   (256'h03B002A11812190050000148BF34BE33BD32500002980A200B301C001D00B833),
                 .INIT_10                   (256'h19002310020000A001B002A1181E19002310020000A001B002A11816190002A0),
                 .INIT_11                   (256'h02A1182A19002310020000A001B002A1182619002310020000A001B002A11822),
                 .INIT_12                   (256'h00A001B002A1183219002310020000A001B002A1182E19002310020000A001B0),
                 .INIT_13                   (256'h2310020000A001B002A1183A19002310020000A001B002A11836190023100200),
                 .INIT_14                   (256'h02A108E0190004A005B002A108D01900500002980A200B301C001D0018011900),
                 .INIT_15                   (256'h027706D007E0082009301A00027706000710148915410D200E30027706A007B0),
                 .INIT_16                   (256'h1A350186F00010021A355000029808F019000A900BA01C001D002A2029100800),
                 .INIT_17                   (256'h01B11B1F1CFD50000195F0001000F00110101A3502620195F0001062F0011016),
                 .INIT_18                   (256'h1B011C04500001B11B011C04500001D11B011C00500001B11B011C0021814181),
                 .INIT_19                   (256'h01B11B021C38500001B11B021C8B500001D11B021C21500001B11B011C2001D1),
                 .INIT_1A                   (256'h01B11B021C8C500001D11B021C39500001B11B021C39500001D11B021C385000),
                 .INIT_1B                   (256'h05A002190242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1C                   (256'hC5E00220E530022C024561C4C3B01301E53001EB022602450242022E01EB4507),
                 .INIT_1D                   (256'h01EBA5300242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1E                   (256'hD1C04108C50001E010805000D50102200242022E05E061DEC3B013010242022E),
                 .INIT_1F                   (256'h0220020561F994010256020B020514645000E1EC400E4E0621F54E077E03E1F4),
                 .INIT_20                   (256'h220DD0019004DF205F0150000256DF202F0070FF10015000DF205F021F015000),
                 .INIT_21                   (256'h50000205025202110256020B02165000DF205F025000DF202F0070FF10025000),
                 .INIT_22                   (256'hC540148022270216500002050252020B02560211500002160252020B02560211),
                 .INIT_23                   (256'h024E4500D0029004024E020B02560216222F9000440E02270216223402116233),
                 .INIT_24                   (256'h110012005000624B9001100B500062469401023814085000D501023850000205),
                 .INIT_25                   (256'h11181200227210FA110012002272101F1100120022721019110012002272100C),
                 .INIT_26                   (256'h115E125F22721068118912092272104811E8120122721012117A12002272106A),
                 .INIT_27                   (256'h430823500240E27F4608470E12001300181050006272B200B100900122721010),
                 .INIT_28                   (256'h4408450E2292D080100B3507400A400A400A00505000627A9801400841084208),
                 .INIT_29                   (256'hB001B031DD07DC06DB05DA04D909D80822929001450044061000D000628E1001),
                 .INIT_2A                   (256'h5000980C990D02B4B004DA8050009D039C029B019A00B001B021D909D8085000),
                 .INIT_2B                   (256'h180819051A40500002B01800190A1A42500062B4D001900EB014D881D982DA80),
                 .INIT_2C                   (256'h025E02B018A019301A4102B0180019051A405000025E02B0180019301A4102B0),
                 .INIT_2D                   (256'h4808490E1006500002980A200B301C001D001802190002E302DD02AA1A005000),
                 .INIT_2E                   (256'h02B0DD43DC42DB41DA403BC01A0002A118041900500002800390500062DE9001),
                 .INIT_2F                   (256'h4308440E42084308440E42084308440E42084308440E42084308440E04D003C0),
                 .INIT_30                   (256'h9A0818051900B012DD421D00230DB002230AF300D200333F42084308440E4208),
                 .INIT_31                   (256'h00000000000000000000000000000000000000000000500002989D0B9C0A9B09),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h22AA22222AA22222AA22222AA22222AA22222AA22222AAAAAAAAC82AA00AAA2A),
                 .INITP_01                  (256'h20A0280020822828002008A0AAA2802AA22222AA22222AA22222AA22222AA222),
                 .INITP_02                  (256'h82A20A8828280015800800208020A00050814205081420508142050814205080),
                 .INITP_03                  (256'hADA8B5931022A35A8A8A92826AB5AAA92A8A928282828282828282820A0A0A0B),
                 .INITP_04                  (256'h57502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282),
                 .INITP_05                  (256'h555555502A82082D528002A2A0202A020280B0AA82A802AAAAAA95DD5C454B55),
                 .INITP_06                  (256'h00000000000000000000000000000000000000000000000000000280028AD455),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a[13:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[15:0]),
                 .DOPADOP                   (data_out_a[17:16]), 
                 .DIADI                     (data_in_a[15:0]),
                 .DIPADIP                   (data_in_a[17:16]), 
                 .WEA                       (2'b00),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[13:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[15:0]),
                 .DOPBDOP                   (data_out_b[17:16]), 
                 .DIBDI                     (data_in_b[15:0]),
                 .DIPBDIP                   (data_in_b[17:16]), 
                 .WEBWE                     (we_b[3:0]),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0));
    end // v6;  
    // 
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a[13:0] = {address[9:0], 4'b1111};
      assign instruction = data_out_a[17:0];
      assign data_in_a[17:0] = {16'b0000000000000000, address[11:10]};
      assign jtag_dout = data_out_b[17:0];
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b[17:0] = data_out_b[17:0];
        assign address_b[13:0] = 14'b11111111111111;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b[17:0] = jtag_din[17:0];
        assign address_b[13:0] = {jtag_addr[9:0], 4'b1111};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB18E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (18'b000000000000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (18'b000000000000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'hD141D0401300120011001000D007D006D005D004D009D0081000B00101F80201),
                 .INIT_01                   (256'h004500370029201300CC02E600FC001D601ADA0102A118061900B012D343D242),
                 .INIT_02                   (256'h1011F0321010F0311000F0301034500000B500A70099008B007D006F00610053),
                 .INIT_03                   (256'h1016F0331015F0321014F0311001F0301034500000F700E300D0F0341012F033),
                 .INIT_04                   (256'h00D0F034101AF0331019F0321018F0311002F0301034500000F700E300D0F034),
                 .INIT_05                   (256'h00F700E300D0F034101EF033101DF032101CF0311003F0301034500000F700E3),
                 .INIT_06                   (256'h1035500000F700E300D0F0341022F0331021F0321020F0311000F03010355000),
                 .INIT_07                   (256'h1002F0301035500000F700E300D0F0341026F0331025F0321024F0311001F030),
                 .INIT_08                   (256'h102CF0311003F0301035500000F700E300D0F034102AF0331029F0321028F031),
                 .INIT_09                   (256'h1031F0321030F0311000F0301036500000F700E300D0F034102EF033102DF032),
                 .INIT_0A                   (256'h1036F0331035F0321034F0311001F0301036500000F700E300D0F0341032F033),
                 .INIT_0B                   (256'h00D0F034103AF0331039F0321038F0311002F0301036500000F700E300D0F034),
                 .INIT_0C                   (256'h500002D102C702BD500002989A0FDB1002A11C001D0018031900500000F700E3),
                 .INIT_0D                   (256'h0B301C001D00B832190002771680173EB501B4000199BA300186F000B031BA30),
                 .INIT_0E                   (256'h190002771600177D0286B501B40001ADBA300186F000B031BA30500002980A20),
                 .INIT_0F                   (256'h03B002A11812190050000148BF34BE33BD32500002980A200B301C001D00B833),
                 .INIT_10                   (256'h19002310020000A001B002A1181E19002310020000A001B002A11816190002A0),
                 .INIT_11                   (256'h02A1182A19002310020000A001B002A1182619002310020000A001B002A11822),
                 .INIT_12                   (256'h00A001B002A1183219002310020000A001B002A1182E19002310020000A001B0),
                 .INIT_13                   (256'h2310020000A001B002A1183A19002310020000A001B002A11836190023100200),
                 .INIT_14                   (256'h02A108E0190004A005B002A108D01900500002980A200B301C001D0018011900),
                 .INIT_15                   (256'h027706D007E0082009301A00027706000710148915410D200E30027706A007B0),
                 .INIT_16                   (256'h1A350186F00010021A355000029808F019000A900BA01C001D002A2029100800),
                 .INIT_17                   (256'h01B11B1F1CFD50000195F0001000F00110101A3502620195F0001062F0011016),
                 .INIT_18                   (256'h1B011C04500001B11B011C04500001D11B011C00500001B11B011C0021814181),
                 .INIT_19                   (256'h01B11B021C38500001B11B021C8B500001D11B021C21500001B11B011C2001D1),
                 .INIT_1A                   (256'h01B11B021C8C500001D11B021C39500001B11B021C39500001D11B021C385000),
                 .INIT_1B                   (256'h05A002190242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1C                   (256'hC5E00220E530022C024561C4C3B01301E53001EB022602450242022E01EB4507),
                 .INIT_1D                   (256'h01EBA5300242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1E                   (256'hD1C04108C50001E010805000D50102200242022E05E061DEC3B013010242022E),
                 .INIT_1F                   (256'h0220020561F994010256020B020514645000E1EC400E4E0621F54E077E03E1F4),
                 .INIT_20                   (256'h220DD0019004DF205F0150000256DF202F0070FF10015000DF205F021F015000),
                 .INIT_21                   (256'h50000205025202110256020B02165000DF205F025000DF202F0070FF10025000),
                 .INIT_22                   (256'hC540148022270216500002050252020B02560211500002160252020B02560211),
                 .INIT_23                   (256'h024E4500D0029004024E020B02560216222F9000440E02270216223402116233),
                 .INIT_24                   (256'h110012005000624B9001100B500062469401023814085000D501023850000205),
                 .INIT_25                   (256'h11181200227210FA110012002272101F1100120022721019110012002272100C),
                 .INIT_26                   (256'h115E125F22721068118912092272104811E8120122721012117A12002272106A),
                 .INIT_27                   (256'h430823500240E27F4608470E12001300181050006272B200B100900122721010),
                 .INIT_28                   (256'h4408450E2292D080100B3507400A400A400A00505000627A9801400841084208),
                 .INIT_29                   (256'hB001B031DD07DC06DB05DA04D909D80822929001450044061000D000628E1001),
                 .INIT_2A                   (256'h5000980C990D02B4B004DA8050009D039C029B019A00B001B021D909D8085000),
                 .INIT_2B                   (256'h180819051A40500002B01800190A1A42500062B4D001900EB014D881D982DA80),
                 .INIT_2C                   (256'h025E02B018A019301A4102B0180019051A405000025E02B0180019301A4102B0),
                 .INIT_2D                   (256'h4808490E1006500002980A200B301C001D001802190002E302DD02AA1A005000),
                 .INIT_2E                   (256'h02B0DD43DC42DB41DA403BC01A0002A118041900500002800390500062DE9001),
                 .INIT_2F                   (256'h4308440E42084308440E42084308440E42084308440E42084308440E04D003C0),
                 .INIT_30                   (256'h9A0818051900B012DD421D00230DB002230AF300D200333F42084308440E4208),
                 .INIT_31                   (256'h00000000000000000000000000000000000000000000500002989D0B9C0A9B09),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h22AA22222AA22222AA22222AA22222AA22222AA22222AAAAAAAAC82AA00AAA2A),
                 .INITP_01                  (256'h20A0280020822828002008A0AAA2802AA22222AA22222AA22222AA22222AA222),
                 .INITP_02                  (256'h82A20A8828280015800800208020A00050814205081420508142050814205080),
                 .INITP_03                  (256'hADA8B5931022A35A8A8A92826AB5AAA92A8A928282828282828282820A0A0A0B),
                 .INITP_04                  (256'h57502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282),
                 .INITP_05                  (256'h555555502A82082D528002A2A0202A020280B0AA82A802AAAAAA95DD5C454B55),
                 .INITP_06                  (256'h00000000000000000000000000000000000000000000000000000280028AD455),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a[13:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[15:0]),
                 .DOPADOP                   (data_out_a[17:16]), 
                 .DIADI                     (data_in_a[15:0]),
                 .DIPADIP                   (data_in_a[17:16]), 
                 .WEA                       (2'b00),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[13:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[15:0]),
                 .DOPBDOP                   (data_out_b[17:16]), 
                 .DIBDI                     (data_in_b[15:0]),
                 .DIPBDIP                   (data_in_b[17:16]), 
                 .WEBWE                     (we_b[3:0]),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0));
    end // akv7;  
    // 
  end // ram_1k_generate;
endgenerate
//  
generate
  if (C_RAM_SIZE_KWORDS == 2) begin : ram_2k_generate 
    //
    if (C_FAMILY == "S6") begin: s6 
      //
      assign address_a[13:0] = {address[10:0], 3'b000};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b[13:0] = 14'b00000000000000;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b[13:0] = {jtag_addr[10:0], 3'b000};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h45372913CCE6FC1D1A01A106001243424140000000000706050409080001F801),
                   .INIT_01             (256'h16331532143101303400F7E3D03412331132103100303400B5A7998B7D6F6153),
                   .INIT_02             (256'hF7E3D0341E331D321C3103303400F7E3D0341A331932183102303400F7E3D034),
                   .INIT_03             (256'h02303500F7E3D03426332532243101303500F7E3D03422332132203100303500),
                   .INIT_04             (256'h3132303100303600F7E3D0342E332D322C3103303500F7E3D0342A3329322831),
                   .INIT_05             (256'hD0343A333932383102303600F7E3D03436333532343101303600F7E3D0343233),
                   .INIT_06             (256'h300000320077803E010099308600313000D1C7BD00980F10A10000030000F7E3),
                   .INIT_07             (256'hB0A112000048343332009820300000330077007D860100AD3086003130009820),
                   .INIT_08             (256'hA12A001000A0B0A126001000A0B0A122001000A0B0A11E001000A0B0A11600A0),
                   .INIT_09             (256'h1000A0B0A13A001000A0B0A136001000A0B0A132001000A0B0A12E001000A0B0),
                   .INIT_0A             (256'h77D0E02030007700108941203077A0B0A1E000A0B0A1D0000098203000000100),
                   .INIT_0B             (256'hB11FFD0095000001103562950062011635860002350098F00090A00000201000),
                   .INIT_0C             (256'hB1023800B1028B00D1022100B10120D1010400B1010400D1010000B101008181),
                   .INIT_0D             (256'hA019422EEBC0422EEB06A01901000000B1028C00D1023900B1023900D1023800),
                   .INIT_0E             (256'hEB30422EEBC0422EEB06A01901000000E020302C45C4B00130EB2645422EEB07),
                   .INIT_0F             (256'h2005F901560B056400EC0E06F50703F4C00800E080000120422EE0DEB001422E),
                   .INIT_10             (256'h00055211560B16002002002000FF02000D0104200100562000FF010020020100),
                   .INIT_11             (256'h4E0002044E0B56162F000E2716341133408027160005520B56110016520B5611),
                   .INIT_12             (256'h180072FA0000721F000072190000720C0000004B010B00460138080001380005),
                   .INIT_13             (256'h0850407F080E000010007200000172105E5F726889097248E80172127A00726A),
                   .INIT_14             (256'h01310706050409089201000600008E01080E92800B070A0A0A50007A01080808),
                   .INIT_15             (256'h08054000B0000A4200B4010E14818280000C0DB4048000030201000121090800),
                   .INIT_16             (256'h080E060098203000000200E3DDAA00005EB0A03041B0000540005EB0003041B0),
                   .INIT_17             (256'h080E08080E08080E08080E08080ED0C0B043424140C000A1040000809000DE01),
                   .INIT_18             (256'h000000000000000000000000980B0A090805001242000D020A00003F08080E08),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h968A9540A9A801280000000000000000000000000000000000000000000AA802),
                   .INITP_01            (256'h2049F23CCCE2A7C38CE2CCCCCCCD999BC81040AA28B1291593264C993264C992),
                   .INITP_02            (256'h9249544842A01104420221442A204402C5088888888880084000800000D8198E),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000052ED4),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom_l( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_l[31:0]),
                   .DOPA                (data_out_a_l[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_l[31:0]),
                   .DOPB                (data_out_b_l[35:32]), 
                   .DIB                 (data_in_b_l[31:0]),
                   .DIPB                (data_in_b_l[35:32]), 
                   .WEB                 (we_b[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0000001000010000B06D010C0C58696968680909080868686868686808580001),
                   .INIT_01             (256'h0878087808780878082800000078087808780878087808280000000000000000),
                   .INIT_02             (256'h0000007808780878087808780828000000780878087808780878082800000078),
                   .INIT_03             (256'h0878082800000078087808780878087808280000007808780878087808780828),
                   .INIT_04             (256'h0878087808780828000000780878087808780878082800000078087808780878),
                   .INIT_05             (256'h0078087808780878087808280000007808780878087808780828000000780878),
                   .INIT_06             (256'h050E0E5C0C010B0B5A5A005D0078585D2801010128014D6D010E0E0C0C280000),
                   .INIT_07             (256'h01010C0C28005F5F5E280105050E0E5C0C010B0B015A5A005D0078585D280105),
                   .INIT_08             (256'h010C0C91810000010C0C91810000010C0C91810000010C0C91810000010C0C01),
                   .INIT_09             (256'h91810000010C0C91810000010C0C91810000010C0C91810000010C0C91810000),
                   .INIT_0A             (256'h01030304040D0103030A0A060701030301040C020201040C280105050E0E0C0C),
                   .INIT_0B             (256'h000D0E2800780878080D0100780878080D0078080D2801040C05050E0E959484),
                   .INIT_0C             (256'h000D0E28000D0E28000D0E28000D0E000D0E28000D0E28000D0E28000D0E10A0),
                   .INIT_0D             (256'h020101010002010100A20201010F0928000D0E28000D0E28000D0E28000D0E28),
                   .INIT_0E             (256'h005201010002010100A20201010F0928E201720101B0E18972000101010100A2),
                   .INIT_0F             (256'h0101B0CA0101010A28F0A0A710A73FF068A0620008286A01010102B0E1890101),
                   .INIT_10             (256'h28010101010101286F2F286F173808289168486F2F28016F173808286F2F0F28),
                   .INIT_11             (256'h01A268480101010111C8A201011101B1620A1101280101010101280101010101),
                   .INIT_12             (256'h08091108080911080809110808091108080928B1C80828B1CA010A286A012801),
                   .INIT_13             (256'hA19181F1A3A309090C28B1D9D8C8110808091108080911080809110808091108),
                   .INIT_14             (256'h58586E6E6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1),
                   .INIT_15             (256'h0C0C0D28010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C28),
                   .INIT_16             (256'hA4A408280105050E0E0C0C0101010D2801010C0C0D010C0C0D2801010C0C0D01),
                   .INIT_17             (256'hA1A2A1A1A2A1A1A2A1A1A2A1A1A20201016E6E6D6D1D0D010C0C28010128B1C8),
                   .INIT_18             (256'h000000000000000000000028014E4E4D4D0C0C586E0E115891F9E919A1A1A2A1),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000004800000000000000000000000000000000),
                   .INITP_00            (256'h4C604966042CFD87D55F557D55F557D55F557D55F557D55F557D55FFFFA7C3F7),
                   .INITP_01            (256'hEEC905D3BB997CFE7B999999999933339D3A6600820484C00810204081020408),
                   .INITP_02            (256'h00007926181DC47118CF9E1FFF8A203010622222222233578FDF3FFFFFB19719),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000181B80),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0001000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom_h( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_h[31:0]),
                   .DOPA                (data_out_a_h[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_h[31:0]),
                   .DOPB                (data_out_b_h[35:32]), 
                   .DIB                 (data_in_b_h[31:0]),
                   .DIPB                (data_in_b_h[35:32]), 
                   .WEB                 (we_b[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
    end // s6;
    // 
    // 
    if (C_FAMILY == "V6") begin: v6 
      //
      assign address_a = {1'b1, address[10:0], 4'b1111};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b = {1'b1, jtag_addr[10:0], 4'b1111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'hD141D0401300120011001000D007D006D005D004D009D0081000B00101F80201),
                 .INIT_01                   (256'h004500370029201300CC02E600FC001D601ADA0102A118061900B012D343D242),
                 .INIT_02                   (256'h1011F0321010F0311000F0301034500000B500A70099008B007D006F00610053),
                 .INIT_03                   (256'h1016F0331015F0321014F0311001F0301034500000F700E300D0F0341012F033),
                 .INIT_04                   (256'h00D0F034101AF0331019F0321018F0311002F0301034500000F700E300D0F034),
                 .INIT_05                   (256'h00F700E300D0F034101EF033101DF032101CF0311003F0301034500000F700E3),
                 .INIT_06                   (256'h1035500000F700E300D0F0341022F0331021F0321020F0311000F03010355000),
                 .INIT_07                   (256'h1002F0301035500000F700E300D0F0341026F0331025F0321024F0311001F030),
                 .INIT_08                   (256'h102CF0311003F0301035500000F700E300D0F034102AF0331029F0321028F031),
                 .INIT_09                   (256'h1031F0321030F0311000F0301036500000F700E300D0F034102EF033102DF032),
                 .INIT_0A                   (256'h1036F0331035F0321034F0311001F0301036500000F700E300D0F0341032F033),
                 .INIT_0B                   (256'h00D0F034103AF0331039F0321038F0311002F0301036500000F700E300D0F034),
                 .INIT_0C                   (256'h500002D102C702BD500002989A0FDB1002A11C001D0018031900500000F700E3),
                 .INIT_0D                   (256'h0B301C001D00B832190002771680173EB501B4000199BA300186F000B031BA30),
                 .INIT_0E                   (256'h190002771600177D0286B501B40001ADBA300186F000B031BA30500002980A20),
                 .INIT_0F                   (256'h03B002A11812190050000148BF34BE33BD32500002980A200B301C001D00B833),
                 .INIT_10                   (256'h19002310020000A001B002A1181E19002310020000A001B002A11816190002A0),
                 .INIT_11                   (256'h02A1182A19002310020000A001B002A1182619002310020000A001B002A11822),
                 .INIT_12                   (256'h00A001B002A1183219002310020000A001B002A1182E19002310020000A001B0),
                 .INIT_13                   (256'h2310020000A001B002A1183A19002310020000A001B002A11836190023100200),
                 .INIT_14                   (256'h02A108E0190004A005B002A108D01900500002980A200B301C001D0018011900),
                 .INIT_15                   (256'h027706D007E0082009301A00027706000710148915410D200E30027706A007B0),
                 .INIT_16                   (256'h1A350186F00010021A355000029808F019000A900BA01C001D002A2029100800),
                 .INIT_17                   (256'h01B11B1F1CFD50000195F0001000F00110101A3502620195F0001062F0011016),
                 .INIT_18                   (256'h1B011C04500001B11B011C04500001D11B011C00500001B11B011C0021814181),
                 .INIT_19                   (256'h01B11B021C38500001B11B021C8B500001D11B021C21500001B11B011C2001D1),
                 .INIT_1A                   (256'h01B11B021C8C500001D11B021C39500001B11B021C39500001D11B021C385000),
                 .INIT_1B                   (256'h05A002190242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1C                   (256'hC5E00220E530022C024561C4C3B01301E53001EB022602450242022E01EB4507),
                 .INIT_1D                   (256'h01EBA5300242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1E                   (256'hD1C04108C50001E010805000D50102200242022E05E061DEC3B013010242022E),
                 .INIT_1F                   (256'h0220020561F994010256020B020514645000E1EC400E4E0621F54E077E03E1F4),
                 .INIT_20                   (256'h220DD0019004DF205F0150000256DF202F0070FF10015000DF205F021F015000),
                 .INIT_21                   (256'h50000205025202110256020B02165000DF205F025000DF202F0070FF10025000),
                 .INIT_22                   (256'hC540148022270216500002050252020B02560211500002160252020B02560211),
                 .INIT_23                   (256'h024E4500D0029004024E020B02560216222F9000440E02270216223402116233),
                 .INIT_24                   (256'h110012005000624B9001100B500062469401023814085000D501023850000205),
                 .INIT_25                   (256'h11181200227210FA110012002272101F1100120022721019110012002272100C),
                 .INIT_26                   (256'h115E125F22721068118912092272104811E8120122721012117A12002272106A),
                 .INIT_27                   (256'h430823500240E27F4608470E12001300181050006272B200B100900122721010),
                 .INIT_28                   (256'h4408450E2292D080100B3507400A400A400A00505000627A9801400841084208),
                 .INIT_29                   (256'hB001B031DD07DC06DB05DA04D909D80822929001450044061000D000628E1001),
                 .INIT_2A                   (256'h5000980C990D02B4B004DA8050009D039C029B019A00B001B021D909D8085000),
                 .INIT_2B                   (256'h180819051A40500002B01800190A1A42500062B4D001900EB014D881D982DA80),
                 .INIT_2C                   (256'h025E02B018A019301A4102B0180019051A405000025E02B0180019301A4102B0),
                 .INIT_2D                   (256'h4808490E1006500002980A200B301C001D001802190002E302DD02AA1A005000),
                 .INIT_2E                   (256'h02B0DD43DC42DB41DA403BC01A0002A118041900500002800390500062DE9001),
                 .INIT_2F                   (256'h4308440E42084308440E42084308440E42084308440E42084308440E04D003C0),
                 .INIT_30                   (256'h9A0818051900B012DD421D00230DB002230AF300D200333F42084308440E4208),
                 .INIT_31                   (256'h00000000000000000000000000000000000000000000500002989D0B9C0A9B09),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000009000),
                 .INITP_00                  (256'h22AA22222AA22222AA22222AA22222AA22222AA22222AAAAAAAAC82AA00AAA2A),
                 .INITP_01                  (256'h20A0280020822828002008A0AAA2802AA22222AA22222AA22222AA22222AA222),
                 .INITP_02                  (256'h82A20A8828280015800800208020A00050814205081420508142050814205080),
                 .INITP_03                  (256'hADA8B5931022A35A8A8A92826AB5AAA92A8A928282828282828282820A0A0A0B),
                 .INITP_04                  (256'h57502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282),
                 .INITP_05                  (256'h555555502A82082D528002A2A0202A020280B0AA82A802AAAAAA95DD5C454B55),
                 .INITP_06                  (256'h00000000000000000000000000000000000000000000000000000280028AD455),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000200000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[31:0]),
                 .DOPADOP                   (data_out_a[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[31:0]),
                 .DOPBDOP                   (data_out_b[35:32]), 
                 .DIBDI                     (data_in_b[31:0]),
                 .DIPBDIP                   (data_in_b[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0));   
    end // v6;  
    // 
    // 
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a = {1'b1, address[10:0], 4'b1111};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b = {1'b1, jtag_addr[10:0], 4'b1111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'hD141D0401300120011001000D007D006D005D004D009D0081000B00101F80201),
                 .INIT_01                   (256'h004500370029201300CC02E600FC001D601ADA0102A118061900B012D343D242),
                 .INIT_02                   (256'h1011F0321010F0311000F0301034500000B500A70099008B007D006F00610053),
                 .INIT_03                   (256'h1016F0331015F0321014F0311001F0301034500000F700E300D0F0341012F033),
                 .INIT_04                   (256'h00D0F034101AF0331019F0321018F0311002F0301034500000F700E300D0F034),
                 .INIT_05                   (256'h00F700E300D0F034101EF033101DF032101CF0311003F0301034500000F700E3),
                 .INIT_06                   (256'h1035500000F700E300D0F0341022F0331021F0321020F0311000F03010355000),
                 .INIT_07                   (256'h1002F0301035500000F700E300D0F0341026F0331025F0321024F0311001F030),
                 .INIT_08                   (256'h102CF0311003F0301035500000F700E300D0F034102AF0331029F0321028F031),
                 .INIT_09                   (256'h1031F0321030F0311000F0301036500000F700E300D0F034102EF033102DF032),
                 .INIT_0A                   (256'h1036F0331035F0321034F0311001F0301036500000F700E300D0F0341032F033),
                 .INIT_0B                   (256'h00D0F034103AF0331039F0321038F0311002F0301036500000F700E300D0F034),
                 .INIT_0C                   (256'h500002D102C702BD500002989A0FDB1002A11C001D0018031900500000F700E3),
                 .INIT_0D                   (256'h0B301C001D00B832190002771680173EB501B4000199BA300186F000B031BA30),
                 .INIT_0E                   (256'h190002771600177D0286B501B40001ADBA300186F000B031BA30500002980A20),
                 .INIT_0F                   (256'h03B002A11812190050000148BF34BE33BD32500002980A200B301C001D00B833),
                 .INIT_10                   (256'h19002310020000A001B002A1181E19002310020000A001B002A11816190002A0),
                 .INIT_11                   (256'h02A1182A19002310020000A001B002A1182619002310020000A001B002A11822),
                 .INIT_12                   (256'h00A001B002A1183219002310020000A001B002A1182E19002310020000A001B0),
                 .INIT_13                   (256'h2310020000A001B002A1183A19002310020000A001B002A11836190023100200),
                 .INIT_14                   (256'h02A108E0190004A005B002A108D01900500002980A200B301C001D0018011900),
                 .INIT_15                   (256'h027706D007E0082009301A00027706000710148915410D200E30027706A007B0),
                 .INIT_16                   (256'h1A350186F00010021A355000029808F019000A900BA01C001D002A2029100800),
                 .INIT_17                   (256'h01B11B1F1CFD50000195F0001000F00110101A3502620195F0001062F0011016),
                 .INIT_18                   (256'h1B011C04500001B11B011C04500001D11B011C00500001B11B011C0021814181),
                 .INIT_19                   (256'h01B11B021C38500001B11B021C8B500001D11B021C21500001B11B011C2001D1),
                 .INIT_1A                   (256'h01B11B021C8C500001D11B021C39500001B11B021C39500001D11B021C385000),
                 .INIT_1B                   (256'h05A002190242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1C                   (256'hC5E00220E530022C024561C4C3B01301E53001EB022602450242022E01EB4507),
                 .INIT_1D                   (256'h01EBA5300242022E01EB05C00242022E01EB450605A0021902011E0013005000),
                 .INIT_1E                   (256'hD1C04108C50001E010805000D50102200242022E05E061DEC3B013010242022E),
                 .INIT_1F                   (256'h0220020561F994010256020B020514645000E1EC400E4E0621F54E077E03E1F4),
                 .INIT_20                   (256'h220DD0019004DF205F0150000256DF202F0070FF10015000DF205F021F015000),
                 .INIT_21                   (256'h50000205025202110256020B02165000DF205F025000DF202F0070FF10025000),
                 .INIT_22                   (256'hC540148022270216500002050252020B02560211500002160252020B02560211),
                 .INIT_23                   (256'h024E4500D0029004024E020B02560216222F9000440E02270216223402116233),
                 .INIT_24                   (256'h110012005000624B9001100B500062469401023814085000D501023850000205),
                 .INIT_25                   (256'h11181200227210FA110012002272101F1100120022721019110012002272100C),
                 .INIT_26                   (256'h115E125F22721068118912092272104811E8120122721012117A12002272106A),
                 .INIT_27                   (256'h430823500240E27F4608470E12001300181050006272B200B100900122721010),
                 .INIT_28                   (256'h4408450E2292D080100B3507400A400A400A00505000627A9801400841084208),
                 .INIT_29                   (256'hB001B031DD07DC06DB05DA04D909D80822929001450044061000D000628E1001),
                 .INIT_2A                   (256'h5000980C990D02B4B004DA8050009D039C029B019A00B001B021D909D8085000),
                 .INIT_2B                   (256'h180819051A40500002B01800190A1A42500062B4D001900EB014D881D982DA80),
                 .INIT_2C                   (256'h025E02B018A019301A4102B0180019051A405000025E02B0180019301A4102B0),
                 .INIT_2D                   (256'h4808490E1006500002980A200B301C001D001802190002E302DD02AA1A005000),
                 .INIT_2E                   (256'h02B0DD43DC42DB41DA403BC01A0002A118041900500002800390500062DE9001),
                 .INIT_2F                   (256'h4308440E42084308440E42084308440E42084308440E42084308440E04D003C0),
                 .INIT_30                   (256'h9A0818051900B012DD421D00230DB002230AF300D200333F42084308440E4208),
                 .INIT_31                   (256'h00000000000000000000000000000000000000000000500002989D0B9C0A9B09),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000009000),
                 .INITP_00                  (256'h22AA22222AA22222AA22222AA22222AA22222AA22222AAAAAAAAC82AA00AAA2A),
                 .INITP_01                  (256'h20A0280020822828002008A0AAA2802AA22222AA22222AA22222AA22222AA222),
                 .INITP_02                  (256'h82A20A8828280015800800208020A00050814205081420508142050814205080),
                 .INITP_03                  (256'hADA8B5931022A35A8A8A92826AB5AAA92A8A928282828282828282820A0A0A0B),
                 .INITP_04                  (256'h57502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282),
                 .INITP_05                  (256'h555555502A82082D528002A2A0202A020280B0AA82A802AAAAAA95DD5C454B55),
                 .INITP_06                  (256'h00000000000000000000000000000000000000000000000000000280028AD455),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000200000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[31:0]),
                 .DOPADOP                   (data_out_a[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[31:0]),
                 .DOPBDOP                   (data_out_b[35:32]), 
                 .DIBDI                     (data_in_b[31:0]),
                 .DIPBDIP                   (data_in_b[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0));   
    end // akv7;  
    // 
  end // ram_2k_generate;
endgenerate              
//
generate
  if (C_RAM_SIZE_KWORDS == 4) begin : ram_4k_generate 
    if (C_FAMILY == "S6") begin: s6 
      //
      assign address_a[13:0] = {address[10:0], 3'b000};
      assign data_in_a = 36'b000000000000000000000000000000000000;
      //
      FD s6_a11_flop ( .D      (address[11]),
                       .Q      (pipe_a11),
                       .C      (clk));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux0_lut( .I0     (data_out_a_ll[0]),
                       .I1     (data_out_a_hl[0]),
                       .I2     (data_out_a_ll[1]),
                       .I3     (data_out_a_hl[1]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[0]),
                       .O6     (instruction[1]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux2_lut( .I0     (data_out_a_ll[2]),
                       .I1     (data_out_a_hl[2]),
                       .I2     (data_out_a_ll[3]),
                       .I3     (data_out_a_hl[3]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[2]),
                       .O6     (instruction[3]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux4_lut( .I0     (data_out_a_ll[4]),
                       .I1     (data_out_a_hl[4]),
                       .I2     (data_out_a_ll[5]),
                       .I3     (data_out_a_hl[5]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[4]),
                       .O6     (instruction[5]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux6_lut( .I0     (data_out_a_ll[6]),
                       .I1     (data_out_a_hl[6]),
                       .I2     (data_out_a_ll[7]),
                       .I3     (data_out_a_hl[7]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[6]),
                       .O6     (instruction[7]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux8_lut( .I0     (data_out_a_ll[32]),
                       .I1     (data_out_a_hl[32]),
                       .I2     (data_out_a_lh[0]),
                       .I3     (data_out_a_hh[0]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[8]),
                       .O6     (instruction[9]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux10_lut( .I0     (data_out_a_lh[1]),
                       .I1     (data_out_a_hh[1]),
                       .I2     (data_out_a_lh[2]),
                       .I3     (data_out_a_hh[2]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[10]),
                       .O6     (instruction[11]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux12_lut( .I0     (data_out_a_lh[3]),
                       .I1     (data_out_a_hh[3]),
                       .I2     (data_out_a_lh[4]),
                       .I3     (data_out_a_hh[4]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[12]),
                       .O6     (instruction[13]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux14_lut( .I0     (data_out_a_lh[5]),
                       .I1     (data_out_a_hh[5]),
                       .I2     (data_out_a_lh[6]),
                       .I3     (data_out_a_hh[6]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[14]),
                       .O6     (instruction[15]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux16_lut( .I0     (data_out_a_lh[7]),
                       .I1     (data_out_a_hh[7]),
                       .I2     (data_out_a_lh[32]),
                       .I3     (data_out_a_hh[32]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[16]),
                       .O6     (instruction[17]));
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_ll = {3'b000, data_out_b_ll[32], 24'b000000000000000000000000, data_out_b_ll[7:0]};
        assign data_in_b_lh = {3'b000, data_out_b_lh[32], 24'b000000000000000000000000, data_out_b_lh[7:0]};
        assign data_in_b_hl = {3'b000, data_out_b_hl[32], 24'b000000000000000000000000, data_out_b_hl[7:0]};
        assign data_in_b_hh = {3'b000, data_out_b_hh[32], 24'b000000000000000000000000, data_out_b_hh[7:0]};
        assign address_b[13:0] = 14'b00000000000000;
        assign we_b_l[3:0] = 4'b0000;
        assign we_b_h[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
        assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_lh = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_ll = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign data_in_b_hh = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_hl = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b[13:0] = {jtag_addr[10:0], 3'b000};
        //
        LUT6_2 # (         .INIT   (64'h8000000020000000))
        s6_4k_jtag_we_lut( .I0     (jtag_we),
                           .I1     (jtag_addr[11]),
                           .I2     (1'b1),
                           .I3     (1'b1),
                           .I4     (1'b1),
                           .I5     (1'b1),
                           .O5     (jtag_we_l),
                           .O6     (jtag_we_h));
        //
        assign we_b_l[3:0] = {jtag_we_l, jtag_we_l, jtag_we_l, jtag_we_l};
        assign we_b_h[3:0] = {jtag_we_h, jtag_we_h, jtag_we_h, jtag_we_h};
        //
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux0_lut( .I0     (data_out_b_ll[0]),
                              .I1     (data_out_b_hl[0]),
                              .I2     (data_out_b_ll[1]),
                              .I3     (data_out_b_hl[1]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[0]),
                              .O6     (jtag_dout[1]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux2_lut( .I0     (data_out_b_ll[2]),
                              .I1     (data_out_b_hl[2]),
                              .I2     (data_out_b_ll[3]),
                              .I3     (data_out_b_hl[3]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[2]),
                              .O6     (jtag_dout[3]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux4_lut( .I0     (data_out_b_ll[4]),
                              .I1     (data_out_b_hl[4]),
                              .I2     (data_out_b_ll[5]),
                              .I3     (data_out_b_hl[5]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[4]),
                              .O6     (jtag_dout[5]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux6_lut( .I0     (data_out_b_ll[6]),
                              .I1     (data_out_b_hl[6]),
                              .I2     (data_out_b_ll[7]),
                              .I3     (data_out_b_hl[7]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[6]),
                              .O6     (jtag_dout[7]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux8_lut( .I0     (data_out_b_ll[32]),
                              .I1     (data_out_b_hl[32]),
                              .I2     (data_out_b_lh[0]),
                              .I3     (data_out_b_hh[0]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[8]),
                              .O6     (jtag_dout[9]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux10_lut( .I0     (data_out_b_lh[1]),
                              .I1     (data_out_b_hh[1]),
                              .I2     (data_out_b_lh[2]),
                              .I3     (data_out_b_hh[2]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[10]),
                              .O6     (jtag_dout[11]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux12_lut( .I0     (data_out_b_lh[3]),
                              .I1     (data_out_b_hh[3]),
                              .I2     (data_out_b_lh[4]),
                              .I3     (data_out_b_hh[4]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[12]),
                              .O6     (jtag_dout[13]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux14_lut( .I0     (data_out_b_lh[5]),
                              .I1     (data_out_b_hh[5]),
                              .I2     (data_out_b_lh[6]),
                              .I3     (data_out_b_hh[6]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[14]),
                              .O6     (jtag_dout[15]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux16_lut( .I0     (data_out_b_lh[7]),
                              .I1     (data_out_b_hh[7]),
                              .I2     (data_out_b_lh[32]),
                              .I3     (data_out_b_hh[32]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[16]),
                              .O6     (jtag_dout[17]));
        //
      end // loader;
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h45372913CCE6FC1D1A01A106001243424140000000000706050409080001F801),
                   .INIT_01             (256'h16331532143101303400F7E3D03412331132103100303400B5A7998B7D6F6153),
                   .INIT_02             (256'hF7E3D0341E331D321C3103303400F7E3D0341A331932183102303400F7E3D034),
                   .INIT_03             (256'h02303500F7E3D03426332532243101303500F7E3D03422332132203100303500),
                   .INIT_04             (256'h3132303100303600F7E3D0342E332D322C3103303500F7E3D0342A3329322831),
                   .INIT_05             (256'hD0343A333932383102303600F7E3D03436333532343101303600F7E3D0343233),
                   .INIT_06             (256'h300000320077803E010099308600313000D1C7BD00980F10A10000030000F7E3),
                   .INIT_07             (256'hB0A112000048343332009820300000330077007D860100AD3086003130009820),
                   .INIT_08             (256'hA12A001000A0B0A126001000A0B0A122001000A0B0A11E001000A0B0A11600A0),
                   .INIT_09             (256'h1000A0B0A13A001000A0B0A136001000A0B0A132001000A0B0A12E001000A0B0),
                   .INIT_0A             (256'h77D0E02030007700108941203077A0B0A1E000A0B0A1D0000098203000000100),
                   .INIT_0B             (256'hB11FFD0095000001103562950062011635860002350098F00090A00000201000),
                   .INIT_0C             (256'hB1023800B1028B00D1022100B10120D1010400B1010400D1010000B101008181),
                   .INIT_0D             (256'hA019422EEBC0422EEB06A01901000000B1028C00D1023900B1023900D1023800),
                   .INIT_0E             (256'hEB30422EEBC0422EEB06A01901000000E020302C45C4B00130EB2645422EEB07),
                   .INIT_0F             (256'h2005F901560B056400EC0E06F50703F4C00800E080000120422EE0DEB001422E),
                   .INIT_10             (256'h00055211560B16002002002000FF02000D0104200100562000FF010020020100),
                   .INIT_11             (256'h4E0002044E0B56162F000E2716341133408027160005520B56110016520B5611),
                   .INIT_12             (256'h180072FA0000721F000072190000720C0000004B010B00460138080001380005),
                   .INIT_13             (256'h0850407F080E000010007200000172105E5F726889097248E80172127A00726A),
                   .INIT_14             (256'h01310706050409089201000600008E01080E92800B070A0A0A50007A01080808),
                   .INIT_15             (256'h08054000B0000A4200B4010E14818280000C0DB4048000030201000121090800),
                   .INIT_16             (256'h080E060098203000000200E3DDAA00005EB0A03041B0000540005EB0003041B0),
                   .INIT_17             (256'h080E08080E08080E08080E08080ED0C0B043424140C000A1040000809000DE01),
                   .INIT_18             (256'h000000000000000000000000980B0A090805001242000D020A00003F08080E08),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h968A9540A9A801280000000000000000000000000000000000000000000AA802),
                   .INITP_01            (256'h2049F23CCCE2A7C38CE2CCCCCCCD999BC81040AA28B1291593264C993264C992),
                   .INITP_02            (256'h9249544842A01104420221442A204402C5088888888880084000800000D8198E),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000052ED4),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_ll( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_ll[31:0]),
                   .DOPA                (data_out_a_ll[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_ll[31:0]),
                   .DOPB                (data_out_b_ll[35:32]), 
                   .DIB                 (data_in_b_ll[31:0]),
                   .DIPB                (data_in_b_ll[35:32]), 
                   .WEB                 (we_b_l[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0000001000010000B06D010C0C58696968680909080868686868686808580001),
                   .INIT_01             (256'h0878087808780878082800000078087808780878087808280000000000000000),
                   .INIT_02             (256'h0000007808780878087808780828000000780878087808780878082800000078),
                   .INIT_03             (256'h0878082800000078087808780878087808280000007808780878087808780828),
                   .INIT_04             (256'h0878087808780828000000780878087808780878082800000078087808780878),
                   .INIT_05             (256'h0078087808780878087808280000007808780878087808780828000000780878),
                   .INIT_06             (256'h050E0E5C0C010B0B5A5A005D0078585D2801010128014D6D010E0E0C0C280000),
                   .INIT_07             (256'h01010C0C28005F5F5E280105050E0E5C0C010B0B015A5A005D0078585D280105),
                   .INIT_08             (256'h010C0C91810000010C0C91810000010C0C91810000010C0C91810000010C0C01),
                   .INIT_09             (256'h91810000010C0C91810000010C0C91810000010C0C91810000010C0C91810000),
                   .INIT_0A             (256'h01030304040D0103030A0A060701030301040C020201040C280105050E0E0C0C),
                   .INIT_0B             (256'h000D0E2800780878080D0100780878080D0078080D2801040C05050E0E959484),
                   .INIT_0C             (256'h000D0E28000D0E28000D0E28000D0E000D0E28000D0E28000D0E28000D0E10A0),
                   .INIT_0D             (256'h020101010002010100A20201010F0928000D0E28000D0E28000D0E28000D0E28),
                   .INIT_0E             (256'h005201010002010100A20201010F0928E201720101B0E18972000101010100A2),
                   .INIT_0F             (256'h0101B0CA0101010A28F0A0A710A73FF068A0620008286A01010102B0E1890101),
                   .INIT_10             (256'h28010101010101286F2F286F173808289168486F2F28016F173808286F2F0F28),
                   .INIT_11             (256'h01A268480101010111C8A201011101B1620A1101280101010101280101010101),
                   .INIT_12             (256'h08091108080911080809110808091108080928B1C80828B1CA010A286A012801),
                   .INIT_13             (256'hA19181F1A3A309090C28B1D9D8C8110808091108080911080809110808091108),
                   .INIT_14             (256'h58586E6E6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1),
                   .INIT_15             (256'h0C0C0D28010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C28),
                   .INIT_16             (256'hA4A408280105050E0E0C0C0101010D2801010C0C0D010C0C0D2801010C0C0D01),
                   .INIT_17             (256'hA1A2A1A1A2A1A1A2A1A1A2A1A1A20201016E6E6D6D1D0D010C0C28010128B1C8),
                   .INIT_18             (256'h000000000000000000000028014E4E4D4D0C0C586E0E115891F9E919A1A1A2A1),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000004800000000000000000000000000000000),
                   .INITP_00            (256'h4C604966042CFD87D55F557D55F557D55F557D55F557D55F557D55FFFFA7C3F7),
                   .INITP_01            (256'hEEC905D3BB997CFE7B999999999933339D3A6600820484C00810204081020408),
                   .INITP_02            (256'h00007926181DC47118CF9E1FFF8A203010622222222233578FDF3FFFFFB19719),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000181B80),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0001000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_lh( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_lh[31:0]),
                   .DOPA                (data_out_a_lh[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_lh[31:0]),
                   .DOPB                (data_out_b_lh[35:32]), 
                   .DIB                 (data_in_b_lh[31:0]),
                   .DIPB                (data_in_b_lh[35:32]), 
                   .WEB                 (we_b_l[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_01             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_02             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_03             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_04             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_05             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_06             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_07             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_08             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_09             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_10             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_11             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_12             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_13             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_14             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_15             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_16             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_17             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_18             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_01            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_02            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_hl( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_hl[31:0]),
                   .DOPA                (data_out_a_hl[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_hl[31:0]),
                   .DOPB                (data_out_b_hl[35:32]), 
                   .DIB                 (data_in_b_hl[31:0]),
                   .DIPB                (data_in_b_hl[35:32]), 
                   .WEB                 (we_b_h[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_01             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_02             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_03             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_04             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_05             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_06             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_07             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_08             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_09             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_10             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_11             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_12             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_13             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_14             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_15             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_16             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_17             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_18             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_01            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_02            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_hh( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_hh[31:0]),
                   .DOPA                (data_out_a_hh[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_hh[31:0]),
                   .DOPB                (data_out_b_hh[35:32]), 
                   .DIB                 (data_in_b_hh[31:0]),
                   .DIPB                (data_in_b_hh[35:32]), 
                   .WEB                 (we_b_h[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      //
    end // s6;
    //
    //
    if (C_FAMILY == "V6") begin: v6 
      //
      assign address_a = {1'b1, address[11:0], 3'b111};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = 36'b00000000000000000000000000000000000;
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b = {1'b1, jtag_addr[11:0], 3'b111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'h45372913CCE6FC1D1A01A106001243424140000000000706050409080001F801),
                 .INIT_01                   (256'h16331532143101303400F7E3D03412331132103100303400B5A7998B7D6F6153),
                 .INIT_02                   (256'hF7E3D0341E331D321C3103303400F7E3D0341A331932183102303400F7E3D034),
                 .INIT_03                   (256'h02303500F7E3D03426332532243101303500F7E3D03422332132203100303500),
                 .INIT_04                   (256'h3132303100303600F7E3D0342E332D322C3103303500F7E3D0342A3329322831),
                 .INIT_05                   (256'hD0343A333932383102303600F7E3D03436333532343101303600F7E3D0343233),
                 .INIT_06                   (256'h300000320077803E010099308600313000D1C7BD00980F10A10000030000F7E3),
                 .INIT_07                   (256'hB0A112000048343332009820300000330077007D860100AD3086003130009820),
                 .INIT_08                   (256'hA12A001000A0B0A126001000A0B0A122001000A0B0A11E001000A0B0A11600A0),
                 .INIT_09                   (256'h1000A0B0A13A001000A0B0A136001000A0B0A132001000A0B0A12E001000A0B0),
                 .INIT_0A                   (256'h77D0E02030007700108941203077A0B0A1E000A0B0A1D0000098203000000100),
                 .INIT_0B                   (256'hB11FFD0095000001103562950062011635860002350098F00090A00000201000),
                 .INIT_0C                   (256'hB1023800B1028B00D1022100B10120D1010400B1010400D1010000B101008181),
                 .INIT_0D                   (256'hA019422EEBC0422EEB06A01901000000B1028C00D1023900B1023900D1023800),
                 .INIT_0E                   (256'hEB30422EEBC0422EEB06A01901000000E020302C45C4B00130EB2645422EEB07),
                 .INIT_0F                   (256'h2005F901560B056400EC0E06F50703F4C00800E080000120422EE0DEB001422E),
                 .INIT_10                   (256'h00055211560B16002002002000FF02000D0104200100562000FF010020020100),
                 .INIT_11                   (256'h4E0002044E0B56162F000E2716341133408027160005520B56110016520B5611),
                 .INIT_12                   (256'h180072FA0000721F000072190000720C0000004B010B00460138080001380005),
                 .INIT_13                   (256'h0850407F080E000010007200000172105E5F726889097248E80172127A00726A),
                 .INIT_14                   (256'h01310706050409089201000600008E01080E92800B070A0A0A50007A01080808),
                 .INIT_15                   (256'h08054000B0000A4200B4010E14818280000C0DB4048000030201000121090800),
                 .INIT_16                   (256'h080E060098203000000200E3DDAA00005EB0A03041B0000540005EB0003041B0),
                 .INIT_17                   (256'h080E08080E08080E08080E08080ED0C0B043424140C000A1040000809000DE01),
                 .INIT_18                   (256'h000000000000000000000000980B0A090805001242000D020A00003F08080E08),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h968A9540A9A801280000000000000000000000000000000000000000000AA802),
                 .INITP_01                  (256'h2049F23CCCE2A7C38CE2CCCCCCCD999BC81040AA28B1291593264C993264C992),
                 .INITP_02                  (256'h9249544842A01104420221442A204402C5088888888880084000800000D8198E),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000052ED4),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_l( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_l[31:0]),
                 .DOPADOP                   (data_out_a_l[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_l[31:0]),
                 .DOPBDOP                   (data_out_b_l[35:32]), 
                 .DIBDI                     (data_in_b_l[31:0]),
                 .DIPBDIP                   (data_in_b_l[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));   
      //
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'h0000001000010000B06D010C0C58696968680909080868686868686808580001),
                 .INIT_01                   (256'h0878087808780878082800000078087808780878087808280000000000000000),
                 .INIT_02                   (256'h0000007808780878087808780828000000780878087808780878082800000078),
                 .INIT_03                   (256'h0878082800000078087808780878087808280000007808780878087808780828),
                 .INIT_04                   (256'h0878087808780828000000780878087808780878082800000078087808780878),
                 .INIT_05                   (256'h0078087808780878087808280000007808780878087808780828000000780878),
                 .INIT_06                   (256'h050E0E5C0C010B0B5A5A005D0078585D2801010128014D6D010E0E0C0C280000),
                 .INIT_07                   (256'h01010C0C28005F5F5E280105050E0E5C0C010B0B015A5A005D0078585D280105),
                 .INIT_08                   (256'h010C0C91810000010C0C91810000010C0C91810000010C0C91810000010C0C01),
                 .INIT_09                   (256'h91810000010C0C91810000010C0C91810000010C0C91810000010C0C91810000),
                 .INIT_0A                   (256'h01030304040D0103030A0A060701030301040C020201040C280105050E0E0C0C),
                 .INIT_0B                   (256'h000D0E2800780878080D0100780878080D0078080D2801040C05050E0E959484),
                 .INIT_0C                   (256'h000D0E28000D0E28000D0E28000D0E000D0E28000D0E28000D0E28000D0E10A0),
                 .INIT_0D                   (256'h020101010002010100A20201010F0928000D0E28000D0E28000D0E28000D0E28),
                 .INIT_0E                   (256'h005201010002010100A20201010F0928E201720101B0E18972000101010100A2),
                 .INIT_0F                   (256'h0101B0CA0101010A28F0A0A710A73FF068A0620008286A01010102B0E1890101),
                 .INIT_10                   (256'h28010101010101286F2F286F173808289168486F2F28016F173808286F2F0F28),
                 .INIT_11                   (256'h01A268480101010111C8A201011101B1620A1101280101010101280101010101),
                 .INIT_12                   (256'h08091108080911080809110808091108080928B1C80828B1CA010A286A012801),
                 .INIT_13                   (256'hA19181F1A3A309090C28B1D9D8C8110808091108080911080809110808091108),
                 .INIT_14                   (256'h58586E6E6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1),
                 .INIT_15                   (256'h0C0C0D28010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C28),
                 .INIT_16                   (256'hA4A408280105050E0E0C0C0101010D2801010C0C0D010C0C0D2801010C0C0D01),
                 .INIT_17                   (256'hA1A2A1A1A2A1A1A2A1A1A2A1A1A20201016E6E6D6D1D0D010C0C28010128B1C8),
                 .INIT_18                   (256'h000000000000000000000028014E4E4D4D0C0C586E0E115891F9E919A1A1A2A1),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000004800000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h4C604966042CFD87D55F557D55F557D55F557D55F557D55F557D55FFFFA7C3F7),
                 .INITP_01                  (256'hEEC905D3BB997CFE7B999999999933339D3A6600820484C00810204081020408),
                 .INITP_02                  (256'h00007926181DC47118CF9E1FFF8A203010622222222233578FDF3FFFFFB19719),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000181B80),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0001000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_h( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_h[31:0]),
                 .DOPADOP                   (data_out_a_h[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_h[31:0]),
                 .DOPBDOP                   (data_out_b_h[35:32]), 
                 .DIBDI                     (data_in_b_h[31:0]),
                 .DIPBDIP                   (data_in_b_h[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));  
    end // v6;  
    //
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a = {1'b1, address[11:0], 3'b111};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = 36'b00000000000000000000000000000000000;
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b = {1'b1, jtag_addr[11:0], 3'b111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'h45372913CCE6FC1D1A01A106001243424140000000000706050409080001F801),
                 .INIT_01                   (256'h16331532143101303400F7E3D03412331132103100303400B5A7998B7D6F6153),
                 .INIT_02                   (256'hF7E3D0341E331D321C3103303400F7E3D0341A331932183102303400F7E3D034),
                 .INIT_03                   (256'h02303500F7E3D03426332532243101303500F7E3D03422332132203100303500),
                 .INIT_04                   (256'h3132303100303600F7E3D0342E332D322C3103303500F7E3D0342A3329322831),
                 .INIT_05                   (256'hD0343A333932383102303600F7E3D03436333532343101303600F7E3D0343233),
                 .INIT_06                   (256'h300000320077803E010099308600313000D1C7BD00980F10A10000030000F7E3),
                 .INIT_07                   (256'hB0A112000048343332009820300000330077007D860100AD3086003130009820),
                 .INIT_08                   (256'hA12A001000A0B0A126001000A0B0A122001000A0B0A11E001000A0B0A11600A0),
                 .INIT_09                   (256'h1000A0B0A13A001000A0B0A136001000A0B0A132001000A0B0A12E001000A0B0),
                 .INIT_0A                   (256'h77D0E02030007700108941203077A0B0A1E000A0B0A1D0000098203000000100),
                 .INIT_0B                   (256'hB11FFD0095000001103562950062011635860002350098F00090A00000201000),
                 .INIT_0C                   (256'hB1023800B1028B00D1022100B10120D1010400B1010400D1010000B101008181),
                 .INIT_0D                   (256'hA019422EEBC0422EEB06A01901000000B1028C00D1023900B1023900D1023800),
                 .INIT_0E                   (256'hEB30422EEBC0422EEB06A01901000000E020302C45C4B00130EB2645422EEB07),
                 .INIT_0F                   (256'h2005F901560B056400EC0E06F50703F4C00800E080000120422EE0DEB001422E),
                 .INIT_10                   (256'h00055211560B16002002002000FF02000D0104200100562000FF010020020100),
                 .INIT_11                   (256'h4E0002044E0B56162F000E2716341133408027160005520B56110016520B5611),
                 .INIT_12                   (256'h180072FA0000721F000072190000720C0000004B010B00460138080001380005),
                 .INIT_13                   (256'h0850407F080E000010007200000172105E5F726889097248E80172127A00726A),
                 .INIT_14                   (256'h01310706050409089201000600008E01080E92800B070A0A0A50007A01080808),
                 .INIT_15                   (256'h08054000B0000A4200B4010E14818280000C0DB4048000030201000121090800),
                 .INIT_16                   (256'h080E060098203000000200E3DDAA00005EB0A03041B0000540005EB0003041B0),
                 .INIT_17                   (256'h080E08080E08080E08080E08080ED0C0B043424140C000A1040000809000DE01),
                 .INIT_18                   (256'h000000000000000000000000980B0A090805001242000D020A00003F08080E08),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h968A9540A9A801280000000000000000000000000000000000000000000AA802),
                 .INITP_01                  (256'h2049F23CCCE2A7C38CE2CCCCCCCD999BC81040AA28B1291593264C993264C992),
                 .INITP_02                  (256'h9249544842A01104420221442A204402C5088888888880084000800000D8198E),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000052ED4),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_l( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_l[31:0]),
                 .DOPADOP                   (data_out_a_l[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_l[31:0]),
                 .DOPBDOP                   (data_out_b_l[35:32]), 
                 .DIBDI                     (data_in_b_l[31:0]),
                 .DIPBDIP                   (data_in_b_l[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));   
      //
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'h0000001000010000B06D010C0C58696968680909080868686868686808580001),
                 .INIT_01                   (256'h0878087808780878082800000078087808780878087808280000000000000000),
                 .INIT_02                   (256'h0000007808780878087808780828000000780878087808780878082800000078),
                 .INIT_03                   (256'h0878082800000078087808780878087808280000007808780878087808780828),
                 .INIT_04                   (256'h0878087808780828000000780878087808780878082800000078087808780878),
                 .INIT_05                   (256'h0078087808780878087808280000007808780878087808780828000000780878),
                 .INIT_06                   (256'h050E0E5C0C010B0B5A5A005D0078585D2801010128014D6D010E0E0C0C280000),
                 .INIT_07                   (256'h01010C0C28005F5F5E280105050E0E5C0C010B0B015A5A005D0078585D280105),
                 .INIT_08                   (256'h010C0C91810000010C0C91810000010C0C91810000010C0C91810000010C0C01),
                 .INIT_09                   (256'h91810000010C0C91810000010C0C91810000010C0C91810000010C0C91810000),
                 .INIT_0A                   (256'h01030304040D0103030A0A060701030301040C020201040C280105050E0E0C0C),
                 .INIT_0B                   (256'h000D0E2800780878080D0100780878080D0078080D2801040C05050E0E959484),
                 .INIT_0C                   (256'h000D0E28000D0E28000D0E28000D0E000D0E28000D0E28000D0E28000D0E10A0),
                 .INIT_0D                   (256'h020101010002010100A20201010F0928000D0E28000D0E28000D0E28000D0E28),
                 .INIT_0E                   (256'h005201010002010100A20201010F0928E201720101B0E18972000101010100A2),
                 .INIT_0F                   (256'h0101B0CA0101010A28F0A0A710A73FF068A0620008286A01010102B0E1890101),
                 .INIT_10                   (256'h28010101010101286F2F286F173808289168486F2F28016F173808286F2F0F28),
                 .INIT_11                   (256'h01A268480101010111C8A201011101B1620A1101280101010101280101010101),
                 .INIT_12                   (256'h08091108080911080809110808091108080928B1C80828B1CA010A286A012801),
                 .INIT_13                   (256'hA19181F1A3A309090C28B1D9D8C8110808091108080911080809110808091108),
                 .INIT_14                   (256'h58586E6E6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1),
                 .INIT_15                   (256'h0C0C0D28010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C28),
                 .INIT_16                   (256'hA4A408280105050E0E0C0C0101010D2801010C0C0D010C0C0D2801010C0C0D01),
                 .INIT_17                   (256'hA1A2A1A1A2A1A1A2A1A1A2A1A1A20201016E6E6D6D1D0D010C0C28010128B1C8),
                 .INIT_18                   (256'h000000000000000000000028014E4E4D4D0C0C586E0E115891F9E919A1A1A2A1),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000004800000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h4C604966042CFD87D55F557D55F557D55F557D55F557D55F557D55FFFFA7C3F7),
                 .INITP_01                  (256'hEEC905D3BB997CFE7B999999999933339D3A6600820484C00810204081020408),
                 .INITP_02                  (256'h00007926181DC47118CF9E1FFF8A203010622222222233578FDF3FFFFFB19719),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000181B80),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0001000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_h( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_h[31:0]),
                 .DOPADOP                   (data_out_a_h[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_h[31:0]),
                 .DOPBDOP                   (data_out_b_h[35:32]), 
                 .DIBDI                     (data_in_b_h[31:0]),
                 .DIPBDIP                   (data_in_b_h[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));  
    end // akv7;  
    //
  end // ram_4k_generate;
endgenerate      
//
// JTAG Loader 
//
generate
  if (C_JTAG_LOADER_ENABLE == 1) begin: instantiate_loader
    jtag_loader_6  #(  .C_FAMILY              (C_FAMILY),
                       .C_NUM_PICOBLAZE       (1),
                       .C_JTAG_LOADER_ENABLE  (C_JTAG_LOADER_ENABLE),        
                       .C_BRAM_MAX_ADDR_WIDTH (BRAM_ADDRESS_WIDTH),        
                       .C_ADDR_WIDTH_0        (BRAM_ADDRESS_WIDTH))
    jtag_loader_6_inst(.picoblaze_reset       (rdl_bus),
                       .jtag_en               (jtag_en),
                       .jtag_din              (jtag_din),
                       .jtag_addr             (jtag_addr[BRAM_ADDRESS_WIDTH-1 : 0]),
                       .jtag_clk              (jtag_clk),
                       .jtag_we               (jtag_we),
                       .jtag_dout_0           (jtag_dout),
                       .jtag_dout_1           (jtag_dout),  // ports 1-7 are not used
                       .jtag_dout_2           (jtag_dout),  // in a 1 device debug 
                       .jtag_dout_3           (jtag_dout),  // session.  However, Synplify
                       .jtag_dout_4           (jtag_dout),  // etc require all ports are
                       .jtag_dout_5           (jtag_dout),  // connected
                       .jtag_dout_6           (jtag_dout),
                       .jtag_dout_7           (jtag_dout));  
    
  end //instantiate_loader
endgenerate 
//
//
endmodule
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////
//
// JTAG Loader 
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// JTAG Loader 6 - Version 6.00
//
// Kris Chaplin - 4th February 2010
// Nick Sawyer  - 3rd March 2011 - Initial conversion to Verilog
// Ken Chapman  - 16th August 2011 - Revised coding style
//
`timescale 1ps/1ps
module jtag_loader_6 (picoblaze_reset, jtag_en, jtag_din, jtag_addr, jtag_clk, jtag_we, jtag_dout_0, jtag_dout_1, jtag_dout_2, jtag_dout_3, jtag_dout_4, jtag_dout_5, jtag_dout_6, jtag_dout_7);
//
parameter integer C_JTAG_LOADER_ENABLE = 1;
parameter         C_FAMILY = "V6";
parameter integer C_NUM_PICOBLAZE = 1;
parameter integer C_BRAM_MAX_ADDR_WIDTH = 10;
parameter integer C_PICOBLAZE_INSTRUCTION_DATA_WIDTH = 18;
parameter integer C_JTAG_CHAIN = 2;
parameter [4:0]   C_ADDR_WIDTH_0 = 10;
parameter [4:0]   C_ADDR_WIDTH_1 = 10;
parameter [4:0]   C_ADDR_WIDTH_2 = 10;
parameter [4:0]   C_ADDR_WIDTH_3 = 10;
parameter [4:0]   C_ADDR_WIDTH_4 = 10;
parameter [4:0]   C_ADDR_WIDTH_5 = 10;
parameter [4:0]   C_ADDR_WIDTH_6 = 10;
parameter [4:0]   C_ADDR_WIDTH_7 = 10;
//
output [C_NUM_PICOBLAZE-1:0]                    picoblaze_reset;
output [C_NUM_PICOBLAZE-1:0]                    jtag_en;
output [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_din;
output [C_BRAM_MAX_ADDR_WIDTH-1:0]              jtag_addr;
output                                          jtag_clk ;
output                                          jtag_we;  
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_0;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_1;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_2;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_3;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_4;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_5;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_6;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_7;
//
//
wire   [2:0]                                    num_picoblaze;        
wire   [4:0]                                    picoblaze_instruction_data_width; 
//
wire                                            drck;
wire                                            shift_clk;
wire                                            shift_din;
wire                                            shift_dout;
wire                                            shift;
wire                                            capture;
//
reg                                             control_reg_ce;
reg    [C_NUM_PICOBLAZE-1:0]                    bram_ce;
wire   [C_NUM_PICOBLAZE-1:0]                    bus_zero;
wire   [C_NUM_PICOBLAZE-1:0]                    jtag_en_int;
wire   [7:0]                                    jtag_en_expanded;
reg    [C_BRAM_MAX_ADDR_WIDTH-1:0]              jtag_addr_int;
reg    [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_din_int;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] control_din;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] control_dout;
reg    [7:0]                                    control_dout_int;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] bram_dout_int;
reg                                             jtag_we_int;
wire                                            jtag_clk_int;
wire                                            bram_ce_valid;
reg                                             din_load;
//                                                
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_0_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_1_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_2_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_3_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_4_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_5_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_6_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_7_masked;
reg    [C_NUM_PICOBLAZE-1:0]                    picoblaze_reset_int;
//
initial picoblaze_reset_int = 0;
//
genvar i;
//
generate
  for (i = 0; i <= C_NUM_PICOBLAZE-1; i = i+1)
    begin : npzero_loop
      assign bus_zero[i] = 1'b0;
    end
endgenerate
//
generate
  //
  if (C_JTAG_LOADER_ENABLE == 1)
    begin : jtag_loader_gen
      //
      // Insert BSCAN primitive for target device architecture.
      //
      if (C_FAMILY == "S6")
        begin : BSCAN_SPARTAN6_gen
          BSCAN_SPARTAN6 # (.JTAG_CHAIN (C_JTAG_CHAIN))
          BSCAN_BLOCK_inst (.CAPTURE    (capture),
                            .DRCK       (drck),
                            .RESET      (),
                            .RUNTEST    (),
                            .SEL        (bram_ce_valid),
                            .SHIFT      (shift),
                            .TCK        (),
                            .TDI        (shift_din),
                            .TMS        (),
                            .UPDATE     (jtag_clk_int),
                            .TDO        (shift_dout)); 
            
        end 
      //
      if (C_FAMILY == "V6")
        begin : BSCAN_VIRTEX6_gen
          BSCAN_VIRTEX6 # ( .JTAG_CHAIN   (C_JTAG_CHAIN),
                            .DISABLE_JTAG ("FALSE"))
          BSCAN_BLOCK_inst (.CAPTURE      (capture),
                            .DRCK         (drck),
                            .RESET        (),
                            .RUNTEST      (),
                            .SEL          (bram_ce_valid),
                            .SHIFT        (shift),
                            .TCK          (),
                            .TDI          (shift_din),
                            .TMS          (),
                            .UPDATE       (jtag_clk_int),
                            .TDO          (shift_dout));
        end 
      //
      if (C_FAMILY == "7S")
        begin : BSCAN_7SERIES_gen
          BSCANE2 # (       .JTAG_CHAIN   (C_JTAG_CHAIN),
                            .DISABLE_JTAG ("FALSE"))
          BSCAN_BLOCK_inst (.CAPTURE      (capture),
                            .DRCK         (drck),
                            .RESET        (),
                            .RUNTEST      (),
                            .SEL          (bram_ce_valid),
                            .SHIFT        (shift),
                            .TCK          (),
                            .TDI          (shift_din),
                            .TMS          (),
                            .UPDATE       (jtag_clk_int),
                            .TDO          (shift_dout));
        end 
      //
      // Insert clock buffer to ensure reliable shift operations.
      //
      BUFG upload_clock (.I (drck), .O (shift_clk));
      //        
      //
      // Shift Register 
      //
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          control_reg_ce <= shift_din;
        end
      end
      // 
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          bram_ce[0] <= control_reg_ce;
        end
      end 
      //
      for (i = 0; i <= C_NUM_PICOBLAZE-2; i = i+1)
      begin : loop0 
        if (C_NUM_PICOBLAZE > 1) begin
          always @ (posedge shift_clk) begin
            if (shift == 1'b1) begin
              bram_ce[i+1] <= bram_ce[i];
            end
          end
        end 
      end
      // 
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          jtag_we_int <= bram_ce[C_NUM_PICOBLAZE-1];
        end
      end
      // 
      always @ (posedge shift_clk) begin 
        if (shift == 1'b1) begin
          jtag_addr_int[0] <= jtag_we_int;
        end
      end
      //
      for (i = 0; i <= C_BRAM_MAX_ADDR_WIDTH-2; i = i+1)
      begin : loop1
        always @ (posedge shift_clk) begin
          if (shift == 1'b1) begin
            jtag_addr_int[i+1] <= jtag_addr_int[i];
          end
        end 
      end
      // 
      always @ (posedge shift_clk) begin 
        if (din_load == 1'b1) begin
          jtag_din_int[0] <= bram_dout_int[0];
        end
        else if (shift == 1'b1) begin
          jtag_din_int[0] <= jtag_addr_int[C_BRAM_MAX_ADDR_WIDTH-1];
        end
      end       
      //
      for (i = 0; i <= C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2; i = i+1)
      begin : loop2
        always @ (posedge shift_clk) begin
          if (din_load == 1'b1) begin
            jtag_din_int[i+1] <= bram_dout_int[i+1];
          end
          if (shift == 1'b1) begin
            jtag_din_int[i+1] <= jtag_din_int[i];
          end
        end 
      end
      //
      assign shift_dout = jtag_din_int[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1];
      //
      //
      always @ (bram_ce or din_load or capture or bus_zero or control_reg_ce) begin
        if ( bram_ce == bus_zero ) begin
          din_load <= capture & control_reg_ce;
        end else begin
          din_load <= capture;
        end
      end
      //
      //
      // Control Registers 
      //
      assign num_picoblaze = C_NUM_PICOBLAZE-3'h1;
      assign picoblaze_instruction_data_width = C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-5'h01;
      //
      always @ (posedge jtag_clk_int) begin
        if (bram_ce_valid == 1'b1 && jtag_we_int == 1'b0 && control_reg_ce == 1'b1) begin
          case (jtag_addr_int[3:0]) 
            0 : // 0 = version - returns (7:4) illustrating number of PB
                // and [3:0] picoblaze instruction data width
                control_dout_int <= {num_picoblaze, picoblaze_instruction_data_width};
            1 : // 1 = PicoBlaze 0 reset / status
                if (C_NUM_PICOBLAZE >= 1) begin 
                  control_dout_int <= {picoblaze_reset_int[0], 2'b00, C_ADDR_WIDTH_0-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            2 : // 2 = PicoBlaze 1 reset / status
                if (C_NUM_PICOBLAZE >= 2) begin 
                  control_dout_int <= {picoblaze_reset_int[1], 2'b00, C_ADDR_WIDTH_1-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            3 : // 3 = PicoBlaze 2 reset / status
                if (C_NUM_PICOBLAZE >= 3) begin 
                  control_dout_int <= {picoblaze_reset_int[2], 2'b00, C_ADDR_WIDTH_2-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            4 : // 4 = PicoBlaze 3 reset / status
                if (C_NUM_PICOBLAZE >= 4) begin 
                  control_dout_int <= {picoblaze_reset_int[3], 2'b00, C_ADDR_WIDTH_3-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            5:  // 5 = PicoBlaze 4 reset / status
                if (C_NUM_PICOBLAZE >= 5) begin 
                  control_dout_int <= {picoblaze_reset_int[4], 2'b00, C_ADDR_WIDTH_4-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            6 : // 6 = PicoBlaze 5 reset / status
                if (C_NUM_PICOBLAZE >= 6) begin 
                  control_dout_int <= {picoblaze_reset_int[5], 2'b00, C_ADDR_WIDTH_5-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            7 : // 7 = PicoBlaze 6 reset / status
                if (C_NUM_PICOBLAZE >= 7) begin 
                  control_dout_int <= {picoblaze_reset_int[6], 2'b00, C_ADDR_WIDTH_6-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            8 : // 8 = PicoBlaze 7 reset / status
                if (C_NUM_PICOBLAZE >= 8) begin 
                  control_dout_int <= {picoblaze_reset_int[7], 2'b00, C_ADDR_WIDTH_7-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            15 : control_dout_int <= C_BRAM_MAX_ADDR_WIDTH -1;
            default : control_dout_int <= 8'h00;
            //
          endcase
        end else begin
          control_dout_int <= 8'h00;
        end
      end 
      //
      assign control_dout[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8] = control_dout_int;
      //
      always @ (posedge jtag_clk_int) begin
        if (bram_ce_valid == 1'b1 && jtag_we_int == 1'b1 && control_reg_ce == 1'b1) begin
          picoblaze_reset_int[C_NUM_PICOBLAZE-1:0] <= control_din[C_NUM_PICOBLAZE-1:0];
        end
      end     
      //
      //
      // Assignments 
      //
      if (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8) begin
        assign control_dout[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9:0] = 10'h000;
      end
      //
      // Qualify the blockram CS signal with bscan select output
      assign jtag_en_int = (bram_ce_valid) ? bram_ce : bus_zero;
      //
      assign jtag_en_expanded[C_NUM_PICOBLAZE-1:0] = jtag_en_int; 
      //
      for (i = 7; i >= C_NUM_PICOBLAZE; i = i-1)
        begin : loop4 
          if (C_NUM_PICOBLAZE < 8) begin : jtag_en_expanded_gen
            assign jtag_en_expanded[i] = 1'b0;
          end
        end
      //
      assign bram_dout_int = control_dout | jtag_dout_0_masked | jtag_dout_1_masked | jtag_dout_2_masked | jtag_dout_3_masked | jtag_dout_4_masked | jtag_dout_5_masked | jtag_dout_6_masked | jtag_dout_7_masked;
      //
      assign control_din = jtag_din_int;
      //
      assign jtag_dout_0_masked = (jtag_en_expanded[0]) ? jtag_dout_0 : 18'h00000;
      assign jtag_dout_1_masked = (jtag_en_expanded[1]) ? jtag_dout_1 : 18'h00000;
      assign jtag_dout_2_masked = (jtag_en_expanded[2]) ? jtag_dout_2 : 18'h00000;
      assign jtag_dout_3_masked = (jtag_en_expanded[3]) ? jtag_dout_3 : 18'h00000;
      assign jtag_dout_4_masked = (jtag_en_expanded[4]) ? jtag_dout_4 : 18'h00000;
      assign jtag_dout_5_masked = (jtag_en_expanded[5]) ? jtag_dout_5 : 18'h00000;
      assign jtag_dout_6_masked = (jtag_en_expanded[6]) ? jtag_dout_6 : 18'h00000;
      assign jtag_dout_7_masked = (jtag_en_expanded[7]) ? jtag_dout_7 : 18'h00000;
      //       
      assign jtag_en = jtag_en_int;
      assign jtag_din = jtag_din_int;
      assign jtag_addr = jtag_addr_int;
      assign jtag_clk = jtag_clk_int;
      assign jtag_we = jtag_we_int;
      assign picoblaze_reset = picoblaze_reset_int;
      //
    end
endgenerate
   //
endmodule
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//  END OF FILE power_test_control_program.v
//
///////////////////////////////////////////////////////////////////////////////////////////
//
