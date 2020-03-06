// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Wed Jan 18 10:25:58 2017
// Host        : MANTA-RAY running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/SUNNY2/LMAC3-vc709-2015-4/hardware/LMAC3-vc7-9-2015-4/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256_stub.v
// Design      : x2c_data_fifo_ip_1024x256
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_0_1,Vivado 2015.4" *)
module x2c_data_fifo_ip_1024x256(clk, srst, din, wr_en, rd_en, dout, full, empty, data_count)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[255:0],wr_en,rd_en,dout[255:0],full,empty,data_count[9:0]" */;
  input clk;
  input srst;
  input [255:0]din;
  input wr_en;
  input rd_en;
  output [255:0]dout;
  output full;
  output empty;
  output [9:0]data_count;
endmodule
