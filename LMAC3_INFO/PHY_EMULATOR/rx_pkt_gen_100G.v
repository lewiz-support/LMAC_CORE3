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


`timescale 1ns/1ps

module rx_pkt_gen_100G(
	x_clk,   						//i-1
	reset_,                         //i-1

	fmac_speed,                     //i-3
	
	data_out,                       //o-256
	ctrl_out,                       //o-32
	
	tb_rx_pkt_gen_en,               //i-1
	tb_rx_pkt_gen_addr_offset,      //i-64
	tb_rx_pkt_gen_read_cnt,         //i-11
	
	addr_incr,                     	//o-1
	
	test                           	//o-1
	);

  input x_clk;
  input reset_;
  
  input	[2:0]	fmac_speed;		//fmac_speed = 3'b000	-	10G
                                //fmac_speed = 3'b001	-	25G
                                //fmac_speed = 3'b010	-	40G
                                //fmac_speed = 3'b011	-	50G
  								//fmac_speed = 3'b100	-	100G
                                //fmac_speed = 3'b101	-	RSVD
                                //fmac_speed = 3'b110	-	RSVD
                                //fmac_speed = 3'b111	-	RSVD
  
  output reg	[255:0]	data_out;
  output reg	[ 31:0]	ctrl_out;
  
  output reg     		addr_incr;
  
  output 			 	test;				//o-1 debug
  

  //signals                                 	
  input [10:0]  tb_rx_pkt_gen_read_cnt;		//# of qwds - 1 (if pkt is 7, provide as 6 here)
  input [63:0]  tb_rx_pkt_gen_addr_offset;	//start
  input 	  	tb_rx_pkt_gen_en;			//pulse
  
  reg [10:0]  tb_rx_pkt_gen_read_cnt_int;
  reg [63:0]  tb_rx_pkt_gen_addr_offset_int;
  reg		  tb_rx_pkt_gen_en_dly1;
  
  wire [255:0] d_out;
  wire [ 31:0] c_out;
  reg  [ 10:0] rx_pkt_gen_addr;
  
  //increment address after this counter
  reg			cntr_50g;	//after every 2 clks
  reg  			cntr_40g;	//after every 2 clks
  reg   [1:0]	cntr_25g;	//after every 4 clks
  reg   [1:0]	cntr_10g;	//after every 4 clks
  
  
	parameter[7:0] 
		DAT_I  	= 8'h01 ,
		DAT_0	= 8'h02 ,
		DAT_1	= 8'h04 ,
		DAT_2	= 8'h08 ,
		DAT_3	= 8'h80 ;
	
	reg [7:0] gmii_state ;

  
	assign test = 1'b0;

 
always @ (posedge x_clk)
	begin
		if (!reset_)
			begin
			
				gmii_state	<= DAT_I;
                data_out   	<= 256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;	
                ctrl_out	<= 32'hFF_FF_FF_FF;
              
 			 	tb_rx_pkt_gen_read_cnt_int	 <= 11'h0;
 				tb_rx_pkt_gen_addr_offset_int <= 64'h0;
 				tb_rx_pkt_gen_en_dly1	  	 <= 1'b0;
 				
 				rx_pkt_gen_addr		<= 11'h0;
 				
             end //if
           
          else
           begin
           
 		    tb_rx_pkt_gen_en_dly1 <= tb_rx_pkt_gen_en;
 		    	
	        tb_rx_pkt_gen_read_cnt_int	<=
	        		//load
	        	tb_rx_pkt_gen_en ? tb_rx_pkt_gen_read_cnt :
	        		//keep
	        	tb_rx_pkt_gen_read_cnt_int; 
	        
	        tb_rx_pkt_gen_addr_offset_int	<= 
	        	//load
	        	tb_rx_pkt_gen_en ? tb_rx_pkt_gen_addr_offset :
	        	//keep
	        	tb_rx_pkt_gen_addr_offset_int;

	 		rx_pkt_gen_addr	<= 
	 				//load
	 				tb_rx_pkt_gen_en_dly1 ? tb_rx_pkt_gen_addr_offset_int :
	 				//count up
	 				((rx_pkt_gen_addr <= (tb_rx_pkt_gen_addr_offset_int + tb_rx_pkt_gen_read_cnt_int)) & addr_incr) ? rx_pkt_gen_addr+1:	 				
	 				//hold			
	 				rx_pkt_gen_addr;
	 				

			//========== RX_PKT_GEN_PLAYBACK ==========	
			//write lower 64 bits for 10G mode
			if (fmac_speed == 3'b0) begin
				case(gmii_state)
        	
					DAT_I:	// IDLE
					begin
						
						gmii_state	<= 	(tb_rx_pkt_gen_en_dly1)? DAT_2 : DAT_I;
        			
						data_out 	<= 	{256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707};
						ctrl_out 	<= 	{32'hFF_FF_FF_FF};
					
					end
					
					DAT_0:	// Transmit QWD 0
					begin
						
						gmii_state	<= 	DAT_1;
        			
						data_out 	<= 	{192'h0707070707070707_0707070707070707_0707070707070707, d_out[63:0]};
						ctrl_out 	<= 	{24'hFF_FF_FF, c_out[7:0]};
					
					end
					
					DAT_1:	// Transmit QWD 1
					begin
					
						gmii_state	<= 	DAT_2;
        			
						data_out 	<= 	{192'h0707070707070707_0707070707070707_0707070707070707, d_out[127:64]};
						ctrl_out 	<= 	{24'hFF_FF_FF, c_out[15:8]};
						
					end
					
					DAT_2:	// Transmit QWD 2
					begin
						
						gmii_state	<= 	DAT_3;
        			
						data_out 	<= 	{192'h0707070707070707_0707070707070707_0707070707070707, d_out[191:128]};
						ctrl_out 	<= 	{24'hFF_FF_FF, c_out[23:16]};
						
					end
					
					DAT_3:	// Transmit QWD 3
					begin
					
						gmii_state	<= 	DAT_0;
        			
						data_out 	<= 	{192'h0707070707070707_0707070707070707_0707070707070707, d_out[255:192]};
						ctrl_out 	<= 	{24'hFF_FF_FF, c_out[31:24]};
						
					end
					
					default:
					begin
						gmii_state 	<=	DAT_I;
					end
			
				endcase
			end
			
			//write entire QWD for 10, 5 and 2.5 GIG mode
			else begin
				data_out  	<= d_out	;
				ctrl_out	<= c_out	;
			end	
			                      	  
	       end //else
		
	end	//always
	
	
always @ (posedge x_clk) begin

	if(!reset_)
		begin
		
			cntr_50g		<=	1'b0;
			cntr_40g		<=	1'b0;
			cntr_25g		<=	2'b0;
			cntr_10g		<=	2'b0;
			addr_incr		<=	1'b0;

		end
		
	else
		begin
		
			//start counter at every 'tb_rx_pkt_gen_en'
			if (tb_rx_pkt_gen_en) begin
			
				cntr_50g		<=	1'b0;
				cntr_40g		<=	1'b0;
				cntr_25g		<=	2'b0;
				cntr_10g		<=	2'b0;
				addr_incr		<=	1'b0;
			
			end
			else begin
		
				case (fmac_speed)
									
					//10G increment address after every 4 clks		
					3'b000: begin
					
								cntr_10g		<=	cntr_10g + 1'b1;
								
								if (cntr_10g == 2'b11) begin
									addr_incr	<=	1'b1;
									cntr_10g	<=	2'b0;
								end
								else
									addr_incr	<=	1'b0;
					
							end
							
					//25G increment address after every 4 clks		
					3'b001: begin
					
								cntr_25g		<=	cntr_25g + 1'b1;
								
								if (cntr_25g == 2'b11) begin
									addr_incr	<=	1'b1;
									cntr_25g	<=	2'b0;
								end
								else
									addr_incr	<=	1'b0;
					
							end
						
					//40G increment address after every 2.5 clks	
					3'b010: begin
								
								cntr_40g		<=	cntr_40g + 1'b1;
								
								if (cntr_40g == 1'b1) begin
									addr_incr	<=	1'b1;
									cntr_40g	<=	1'b0;
								end
								else
									addr_incr	<=	1'b0;
									
							end
					
					//50G increment address after every 2 clks		
					3'b011: begin
					
								cntr_50g		<=	cntr_50g + 1'b1;
								
								if (cntr_50g == 1'b1) begin
									addr_incr	<=	1'b1;
									cntr_50g	<=	1'b0;
								end
								else
									addr_incr	<=	1'b0;
									
							end

					//100G increment address at every clk
					3'b100: begin
					
								addr_incr		<=	1'b1;
					
							end
							
					default: begin
					
								cntr_50g		<=	1'b0;
								cntr_40g		<=	1'b0;
								cntr_25g		<=	2'b0;
								addr_incr		<=	1'b0;
					
							end
							
				endcase
				
			end
		
		end
		
end
		

//========== STORAGE ==========	
rx_pkt_gen2kx256 rx_pkt_gen2kx256_inst (
	
	//.address	(rx_pkt_gen_addr),
	//.clock	(x_clk),
	//.rden		(1'b1),
	//.q		(d_out)
	
	.data		(256'b0),
	.rdaddress 	(rx_pkt_gen_addr),
	.clock 		(x_clk),
	.wraddress 	(11'b0),
	.wren 		(1'b0),
	.q 			(d_out)               
	
	);
	
	
rx_pkt_gen2kx32 rx_pkt_gen2kx32_inst (
	
	//.address	(rx_pkt_gen_addr),
	//.clock	(x_clk),
	//.rden		(1'b1),
	//.q		(c_out)
	
	.data		(32'b0),
	.rdaddress 	(rx_pkt_gen_addr),
	.clock 		(x_clk),
	.wraddress 	(11'b0),
	.wren 		(1'b0),
	.q 			(c_out)               

	);
	
	
endmodule
