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

module phy_emulator_100G(
	
	x_clk,			//i
	reset_,			//i
	
	fmac_speed,		//i
	
	rx_pkt_gen_sel,	//i
	
	//cgmii 02 OCT 2018
	cgmii_txd,    	//i-256
	cgmii_txc,    	//i-32
	
   	cgmii_rxd,      //o-256
   	cgmii_rxc,      //o-32 
   	
    test			//o TEST
    
	);

	input 				x_clk;			//i
	input 				reset_;			//i
	
	input	[2 : 0]		fmac_speed;		//fmac_speed = 3'b000	-	10G
                                		//fmac_speed = 3'b001	-	25G
                                		//fmac_speed = 3'b010	-	40G
                                		//fmac_speed = 3'b011	-	50G
  										//fmac_speed = 3'b100	-	100G
                                		//fmac_speed = 3'b101	-	RSVD
                                		//fmac_speed = 3'b110	-	RSVD
                                		//fmac_speed = 3'b111	-	RSVD
	
	input				rx_pkt_gen_sel;	//i
	
	//cgmii 02 OCT 2018
	input		[255:0]		cgmii_txd;
	input 		[ 31:0]		cgmii_txc;
			
	output reg	[255:0]		cgmii_rxd;
    output reg	[ 31:0]		cgmii_rxc;

    
    //to store the previous data to write in the txt file
	reg			[255:0]		cgmii_rxd_dly;
    reg			[ 31:0]		cgmii_rxc_dly;
    
	reg			[255:0]		cgmii_rxd_dly1;
    reg			[ 31:0]		cgmii_rxc_dly1;
    
	reg			[255:0]		cgmii_rxd_dly2;
    reg			[ 31:0]		cgmii_rxc_dly2;
    
	reg			[255:0]		cgmii_rxd_dly3;
    reg			[ 31:0]		cgmii_rxc_dly3;
                                              	
    output 					test;					//o TEST
    
    reg					rx_pkt_gen_en;
    reg		[ 63: 0]	rx_pkt_gen_start_addr;
    reg		[ 10: 0]	rx_pkt_gen_read_cnt;
    
    wire	[255: 0]	rx_pkt_gen_data_out;
    wire	[ 31: 0]	rx_pkt_gen_ctrl_out;
    
   	integer				data_file;
   	integer				ctrl_file;
   	
   	wire				addr_incr;
   	integer				n, k;
   	
   	//needed to write in the text file
   	reg					sof, sof0, sof4;
   	
   	reg					loopback_mode;

   	   	
    rx_pkt_gen_100G rx_pkt_gen_100G(
	
    .x_clk 						(x_clk),					//i-1
	.reset_ 					(reset_),                   //i-1
	                        	                            
	.fmac_speed					(fmac_speed),				//i-3
	                        	
	.data_out 					(rx_pkt_gen_data_out),      //o-256
	.ctrl_out 					(rx_pkt_gen_ctrl_out),      //o-32
	
	.tb_rx_pkt_gen_en 			(rx_pkt_gen_en),         	//i-1
	.tb_rx_pkt_gen_addr_offset	(rx_pkt_gen_start_addr),   	//i-64
	.tb_rx_pkt_gen_read_cnt 	(rx_pkt_gen_read_cnt),   	//i-11
	
	.addr_incr					(addr_incr),				//o-1
	                        	
	.test 						(test)						//o-1
	
	);
    
	
	always @ (posedge x_clk)
	begin
	
		if (!reset_)
		begin
		
			//RESET initialization
			rx_pkt_gen_start_addr	<=	64'b0;
			rx_pkt_gen_read_cnt		<=	11'b0;
			
			rx_pkt_gen_en		<=	1'b0;
			
			cgmii_rxd 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			cgmii_rxc 	<= 	32'hFF_FF_FF_FF;
		
		end
		
		else
		begin
			
			//output depending on the 'rx_pkt_gen_sel' signal.
			cgmii_rxd 	<= 	(rx_pkt_gen_sel)? 	rx_pkt_gen_data_out 	: 	cgmii_txd;
			cgmii_rxc 	<= 	(rx_pkt_gen_sel)? 	rx_pkt_gen_ctrl_out 	: 	cgmii_txc;
												
		end
		
		loopback_mode	<=	!(rx_pkt_gen_sel);
		
	end
	
	initial begin
	
	 	//open files
		data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "w");
		ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "w");
		
		//write to the text files: Copyright info and first line description
		$fdisplay (data_file, "// Copyright (C) 2018 LeWiz Communications, Inc.");
		$fdisplay (data_file, "//\n// This library is free software; you can redistribute it and/or");
		$fdisplay (data_file, "// modify it under the terms of the GNU Lesser General Public");
		$fdisplay (data_file, "// License as published by the Free Software Foundation; either");
		$fdisplay (data_file, "// version 2.1 of the License, or (at your option) any later version.");
		$fdisplay (data_file, "//\n// This library is distributed in the hope that it will be useful,");
		$fdisplay (data_file, "// but WITHOUT ANY WARRANTY; without even the implied warranty of");
		$fdisplay (data_file, "// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU");
		$fdisplay (data_file, "// Lesser General Public License for more details.");
		$fdisplay (data_file, "//\n// You should have received a copy of the GNU Lesser General Public");
		$fdisplay (data_file, "// License along with this library release; if not, write to the Free Software");
		$fdisplay (data_file, "// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA");
		$fdisplay (data_file, "//\n// LeWiz can be contacted at:  support@lewiz.com");
		$fdisplay (data_file, "// or address:");
		$fdisplay (data_file, "// PO Box 9276");
		$fdisplay (data_file, "// San Jose, CA 95157-9276");
		$fdisplay (data_file, "// www.lewiz.com");
		$fdisplay (data_file, "//\n//    Author: LeWiz Communications, Inc.");
		$fdisplay (data_file, "//    Language: Verilog");
		$fdisplay (data_file, "//\n//\n\n//This file stores the 256 bit data (CGMII_RXD) which needs to be compared with received data (AXIS Master input).");
		
		$fdisplay (ctrl_file, "// Copyright (C) 2018 LeWiz Communications, Inc.");
		$fdisplay (ctrl_file, "//\n// This library is free software; you can redistribute it and/or");
		$fdisplay (ctrl_file, "// modify it under the terms of the GNU Lesser General Public");
		$fdisplay (ctrl_file, "// License as published by the Free Software Foundation; either");
		$fdisplay (ctrl_file, "// version 2.1 of the License, or (at your option) any later version.");
		$fdisplay (ctrl_file, "//\n// This library is distributed in the hope that it will be useful,");
		$fdisplay (ctrl_file, "// but WITHOUT ANY WARRANTY; without even the implied warranty of");
		$fdisplay (ctrl_file, "// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU");
		$fdisplay (ctrl_file, "// Lesser General Public License for more details.");
		$fdisplay (ctrl_file, "//\n// You should have received a copy of the GNU Lesser General Public");
		$fdisplay (ctrl_file, "// License along with this library release; if not, write to the Free Software");
		$fdisplay (ctrl_file, "// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA");
		$fdisplay (ctrl_file, "//\n// LeWiz can be contacted at:  support@lewiz.com");
		$fdisplay (ctrl_file, "// or address:");
		$fdisplay (ctrl_file, "// PO Box 9276");
		$fdisplay (ctrl_file, "// San Jose, CA 95157-9276");
		$fdisplay (ctrl_file, "// www.lewiz.com");
		$fdisplay (ctrl_file, "//\n//    Author: LeWiz Communications, Inc.");
		$fdisplay (ctrl_file, "//    Language: Verilog");
		$fdisplay (ctrl_file, "//\n//\n\n//This file stores the  32 bit ctrl (CGMII_RXC) which needs to be compared with received ctrl (AXIS Master input).");
	    
	 	//close files
		$fclose(data_file);
		$fclose(ctrl_file);
		
	end

		
	always @ (posedge x_clk)
	begin
	
		if (!reset_)
		begin
		
			cgmii_rxd_dly 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			cgmii_rxc_dly 	<= 	32'hFF_FF_FF_FF;
			cgmii_rxd_dly1 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			cgmii_rxc_dly1 	<= 	32'hFF_FF_FF_FF;
			cgmii_rxd_dly2 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			cgmii_rxc_dly2 	<= 	32'hFF_FF_FF_FF;
			cgmii_rxd_dly3 	<= 	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			cgmii_rxc_dly3 	<= 	32'hFF_FF_FF_FF;
								
		end
		
		else
		begin
			// buffered signals: delayed and original data needed to print the SOF4 data
			if (fmac_speed == 3'b0 || fmac_speed == 3'd4) begin
				cgmii_rxd_dly 	<= 	cgmii_rxd;
				cgmii_rxc_dly 	<= 	cgmii_rxc;
			end
			else if (fmac_speed == 3'd2 || fmac_speed == 3'd3) begin
				cgmii_rxd_dly1 	<= 	cgmii_rxd;
				cgmii_rxc_dly1 	<= 	cgmii_rxc;
				
				cgmii_rxd_dly 	<= 	cgmii_rxd_dly1;
				cgmii_rxc_dly 	<= 	cgmii_rxc_dly1;
			end
			else if (fmac_speed == 3'd1) begin
				cgmii_rxd_dly1 	<= 	cgmii_rxd;
				cgmii_rxc_dly1 	<= 	cgmii_rxc;
				
				cgmii_rxd_dly2 	<= 	cgmii_rxd_dly1;
				cgmii_rxc_dly2 	<= 	cgmii_rxc_dly1;
				
				cgmii_rxd_dly3 	<= 	cgmii_rxd_dly2;
				cgmii_rxc_dly3 	<= 	cgmii_rxc_dly2;
				                                  
				cgmii_rxd_dly 	<= 	cgmii_rxd_dly3;
				cgmii_rxc_dly 	<= 	cgmii_rxc_dly3;
			end
		end
		
	end
				
	
	
	always @ (posedge x_clk)
	begin
	
		if (!reset_)
		begin
			
			sof	 =	1'b0;
			sof0 =  1'b0;
			sof4 =  1'b0;
			n	 =	1'b1;
			k	 =	1'b0;
						
		end
		
		else
		begin
		
			// 10G speed
			if (fmac_speed == 3'd0) begin	
			
				//first check end of packet: if yes, write last data and close the file
				if (sof && (cgmii_rxd_dly [7:0] == 8'hFD) && cgmii_rxc_dly [0]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [15:8] == 8'hFD) && cgmii_rxc_dly [1]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [23:16] == 8'hFD) && cgmii_rxc_dly [2]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[15:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[1:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [31:24] == 8'hFD) && cgmii_rxc_dly [3]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[23:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[2:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [39:32] == 8'hFD) && cgmii_rxc_dly [4]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[31:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[3:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end	
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [47:40] == 8'hFD) && cgmii_rxc_dly [5]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[39:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[4:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[39:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [55:48] == 8'hFD) && cgmii_rxc_dly [6]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[47:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[5:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[47:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[5:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [63:56] == 8'hFD) && cgmii_rxc_dly [7]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[55:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[6:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[55:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[6:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				
				//after checking the end of pkt, check for the start of pkt: if yes, open the file and write 1st data
				if ((cgmii_rxd_dly [7:0] == 8'hFB) && cgmii_rxc_dly [0]) begin
					sof = 1'b1;
					sof0 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [39:32] == 8'hFB) && cgmii_rxc_dly [4]) begin
					sof = 1'b1;
					sof4 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[63:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[7:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				
				//if no sof or eof: write entire data as it is
				else if (sof) begin
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[63:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[7:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
							
				end // if sof
			
			end // addr_incr and fmac_speed = 3'd0
				
			
			//for all other speed modes (100G, 50G, 40G and 25G)	
			if (addr_incr & (fmac_speed != 3'd0)) begin			
								
				//first check end of packet: if yes, write last data and close the file
				if (sof && (cgmii_rxd_dly [7:0] == 8'hFD) && cgmii_rxc_dly [0]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [15:8] == 8'hFD) && cgmii_rxc_dly [1]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [23:16] == 8'hFD) && cgmii_rxc_dly [2]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[15:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[1:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [31:24] == 8'hFD) && cgmii_rxc_dly [3]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[23:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[2:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [39:32] == 8'hFD) && cgmii_rxc_dly [4]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[31:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[3:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end	
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [47:40] == 8'hFD) && cgmii_rxc_dly [5]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[39:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[4:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[39:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [55:48] == 8'hFD) && cgmii_rxc_dly [6]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[47:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[5:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[47:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[5:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [63:56] == 8'hFD) && cgmii_rxc_dly [7]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[55:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[6:0]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[55:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[6:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [71:64] == 8'hFD) && cgmii_rxc_dly [8]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[63:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[7:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [79:72] == 8'hFD) && cgmii_rxc_dly [9]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[71:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[71:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[8:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [87:80] == 8'hFD) && cgmii_rxc_dly [10]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[79:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[9:8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[79:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[9:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [95:88] == 8'hFD) && cgmii_rxc_dly [11]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[87:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[10:8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[87:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[10:4]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [103:96] == 8'hFD) && cgmii_rxc_dly [12]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[95:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[11:8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [111:104] == 8'hFD) && cgmii_rxc_dly [13]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[103:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[12:8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[103:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [119:112] == 8'hFD) && cgmii_rxc_dly [14]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[111:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[13:8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[111:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[13:12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [127:120] == 8'hFD) && cgmii_rxc_dly [15]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[119:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[14:8]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[119:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[14:12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [135:128] == 8'hFD) && cgmii_rxc_dly [16]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[127:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[15:12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [143:136] == 8'hFD) && cgmii_rxc_dly [17]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[135:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[135:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[16:12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [151:144] == 8'hFD) && cgmii_rxc_dly [18]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[143:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[17:16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[143:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[17:12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [159:152] == 8'hFD) && cgmii_rxc_dly [19]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[151:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[18:16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[151:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[18:12]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [167:160] == 8'hFD) && cgmii_rxc_dly [20]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[159:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[19:16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [175:168] == 8'hFD) && cgmii_rxc_dly [21]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[167:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[20:16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[167:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [183:176] == 8'hFD) && cgmii_rxc_dly [22]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[175:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[21:16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[175:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[21:20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [191:184] == 8'hFD) && cgmii_rxc_dly [23]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[183:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[22:16]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[183:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[22:20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [199:192] == 8'hFD) && cgmii_rxc_dly [24]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[191:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[23:20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [207:200] == 8'hFD) && cgmii_rxc_dly [25]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[199:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[199:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[24:20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [215:208] == 8'hFD) && cgmii_rxc_dly [26]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[207:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[25:24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[207:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[25:20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [223:216] == 8'hFD) && cgmii_rxc_dly [27]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[215:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[26:24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[215:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[26:20]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [231:224] == 8'hFD) && cgmii_rxc_dly [28]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 32'h070707FD, cgmii_rxd_dly[223:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {4'b1111, cgmii_rxc_dly[27:24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, 8'hFF, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [239:232] == 8'hFD) && cgmii_rxc_dly [29]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 24'h0707FD, cgmii_rxd_dly[231:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {3'b111, cgmii_rxc_dly[28:24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 56'h070707070707FD, cgmii_rxd_dly[231:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {7'b1111111, cgmii_rxc_dly[28]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [247:240] == 8'hFD) && cgmii_rxc_dly [30]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 16'h07FD, cgmii_rxd_dly[239:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {2'b11, cgmii_rxc_dly[29:24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 48'h0707070707FD, cgmii_rxd_dly[239:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {6'b111111, cgmii_rxc_dly[29:28]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
				else if (sof && (cgmii_rxd_dly [255:248] == 8'hFD) && cgmii_rxc_dly [31]) begin
					
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 8'hFD, cgmii_rxd_dly[247:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {1'b1, cgmii_rxc_dly[30:24]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						
						$fdisplayh (data_file, 40'h07070707FD, cgmii_rxd_dly[247:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, {5'b11111, cgmii_rxc_dly[30:28]}, "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end					
									
					sof  = 1'b0;
					sof0 = 1'b0;
					sof4 = 1'b0;
					
					n	=	n + 1;
					$fclose(data_file);
					$fclose(ctrl_file);							
						
				end
								
				
				//after checking the end of pkt, check for the start of pkt: if yes, open the file and write 1st data
				if ((cgmii_rxd_dly [7:0] == 8'hFB) && cgmii_rxc_dly [0]) begin
					sof = 1'b1;
					sof0 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd_dly[255:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[31:24], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [39:32] == 8'hFB) && cgmii_rxc_dly [4]) begin
					sof = 1'b1;
					sof4 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[255:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[31:28], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [71:64] == 8'hFB) && cgmii_rxc_dly [8]) begin
					sof = 1'b1;
					sof0 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd_dly[255:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[31:24], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [103:96] == 8'hFB) && cgmii_rxc_dly [12]) begin
					sof = 1'b1;
					sof4 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[255:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[31:28], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [135:128] == 8'hFB) && cgmii_rxc_dly [16]) begin
					sof = 1'b1;
					sof0 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd_dly[255:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[31:24], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [167:160] == 8'hFB) && cgmii_rxc_dly [20]) begin
					sof = 1'b1;
					sof4 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[255:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[31:28], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [199:192] == 8'hFB) && cgmii_rxc_dly [24]) begin
					sof = 1'b1;
					sof0 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd_dly[255:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[31:24], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
				else if ((cgmii_rxd_dly [231:224] == 8'hFB) && cgmii_rxc_dly [28]) begin
					sof = 1'b1;
					sof4 = 1'b1;
					data_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/data_file.txt", "a"); 	
					ctrl_file 	= $fopen("C:/LMAC3_INFO/PHY_EMULATOR/ctrl_file.txt", "a"); 	
				    
					$fdisplay (data_file, "\n\n//pkt - %0d\n", n);							
					$fdisplay (ctrl_file, "\n\n//pkt - %0d\n", n);							
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[255:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[31:28], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
				end
					
				//if no sof or eof: write entire data as it is				
				else if (sof) begin
					if (sof0) begin
						$fdisplayh (data_file, cgmii_rxd_dly[63:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[7:0], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[127:64], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[15:8], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[191:128], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[23:16], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd_dly[255:192], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[31:24], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
					else if (sof4) begin
						$fdisplayh (data_file, cgmii_rxd_dly[95:32], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[11:4], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[159:96], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[19:12], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                    
						$fdisplayh (data_file, cgmii_rxd_dly[223:160], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc_dly[27:20], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
						                                     						                                         
						$fdisplayh (data_file, cgmii_rxd[31:0], cgmii_rxd_dly[255:224], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						$fdisplayh (ctrl_file, cgmii_rxc[3:0], cgmii_rxc_dly[31:28], "\t\t//Index: %3d\tPkt No.: %0d", k, n);
						k	=	k + 1;
					end
							
				end // if sof
			
			end //if addr_incr	
			
		end //else if not !reset_
		
	end // always block
	
	
	
	
endmodule