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

module memory_rd_module(

	rx_mac_aclk,						//i-1, RX Clock		
	reset_,        						//i-1,

  	//outputs to drive the AXI bus
	mem_axis_rdata,    					//i-DATA_WIDTH, read_data to store in a text file
	                                	
	mem_rd_address,       				//i-ADDR_WIDTH, address to access the memory
	mem_axis_rstrb,						//i-BCNT_WIDTH, read_strobe to store in a text file
	rd_done,							//i-1, indicates that the read transaction is done
	rx_axis_mac_tvalid,                 //i-1, to write to memory as long as valid data is high.                                        
	rx_axis_mac_tlen,                   //i-32, holds the length of the received data 
	
	rx_pkt_gen_sel,						//i-1
	
	mem_rd_start_address,				//o-ADDR_WIDTH
	
	pkt_cnt								//o-BCNT_WIDTH
	                                                   
	);
	
	parameter ADDR_WIDTH = 32;			//default
	parameter DATA_WIDTH = 256;
	parameter BCNT_WIDTH = 32;
	
	input								rx_mac_aclk;					//i, RX Clock		
	input								reset_;  						//i,      	
	input		[DATA_WIDTH-1 : 0]		mem_axis_rdata;					//i, read_data to store in a text file
	input		[ADDR_WIDTH-1 : 0]		mem_rd_address;					//i, address to access the memory
	input		[BCNT_WIDTH-1 : 0]		mem_axis_rstrb;					//i, read_strobe to store in a text file
	
	input								rd_done;						//i, indicates that the read transaction is done
	input								rx_axis_mac_tvalid;             //i, to write to memory as long as valid data is high.                                        
	input		[31 : 0]				rx_axis_mac_tlen;               //i, holds the length of the received data   
	                                        
	input								rx_pkt_gen_sel;					//i
	
	output reg	[ADDR_WIDTH-1 : 0]		mem_rd_start_address;			//o, start address for each packet
	
	output reg	[BCNT_WIDTH-1 : 0]		pkt_cnt;						//packet count
	
	reg 		[BCNT_WIDTH-1 : 0] 		memory_rd_ctrl [0:16383];		//Depth = 2^11 = 2048 for now
	reg 		[DATA_WIDTH-1 : 0]		memory_rd_data [0:16383];		//Depth = 2^11 = 2048 for now
	
	integer								data_received_file;
	integer								ctrl_received_file;
	
	integer								i, j;		//stores index value
	

	initial begin
	
		data_received_file 	= $fopen("C:/LMAC3_INFO/AXIS_MASTER/data_received_file.txt", "w"); 		//open file
		ctrl_received_file 	= $fopen("C:/LMAC3_INFO/AXIS_MASTER/ctrl_received_file.txt", "w"); 		//open file
		
		//write to the text file: First line description
		$fdisplay (data_received_file, "// Copyright (C) 2018 LeWiz Communications, Inc.");
		$fdisplay (data_received_file, "//\n// This library is free software; you can redistribute it and/or");
		$fdisplay (data_received_file, "// modify it under the terms of the GNU Lesser General Public");
		$fdisplay (data_received_file, "// License as published by the Free Software Foundation; either");
		$fdisplay (data_received_file, "// version 2.1 of the License, or (at your option) any later version.");
		$fdisplay (data_received_file, "//\n// This library is distributed in the hope that it will be useful,");
		$fdisplay (data_received_file, "// but WITHOUT ANY WARRANTY; without even the implied warranty of");
		$fdisplay (data_received_file, "// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU");
		$fdisplay (data_received_file, "// Lesser General Public License for more details.");
		$fdisplay (data_received_file, "//\n// You should have received a copy of the GNU Lesser General Public");
		$fdisplay (data_received_file, "// License along with this library release; if not, write to the Free Software");
		$fdisplay (data_received_file, "// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA");
		$fdisplay (data_received_file, "//\n// LeWiz can be contacted at:  support@lewiz.com");
		$fdisplay (data_received_file, "// or address:");
		$fdisplay (data_received_file, "// PO Box 9276");
		$fdisplay (data_received_file, "// San Jose, CA 95157-9276");
		$fdisplay (data_received_file, "// www.lewiz.com");
		$fdisplay (data_received_file, "//\n//    Author: LeWiz Communications, Inc.");
		$fdisplay (data_received_file, "//    Language: Verilog");
		$fdisplay (data_received_file, "//\n//\n\n//This file stores the 256 bits received data which needs to be compared with transmitted data (LMAC input).");//write to the text file: First line description
		
		$fdisplay (ctrl_received_file, "// Copyright (C) 2018 LeWiz Communications, Inc.");
		$fdisplay (ctrl_received_file, "//\n// This library is free software; you can redistribute it and/or");
		$fdisplay (ctrl_received_file, "// modify it under the terms of the GNU Lesser General Public");
		$fdisplay (ctrl_received_file, "// License as published by the Free Software Foundation; either");
		$fdisplay (ctrl_received_file, "// version 2.1 of the License, or (at your option) any later version.");
		$fdisplay (ctrl_received_file, "//\n// This library is distributed in the hope that it will be useful,");
		$fdisplay (ctrl_received_file, "// but WITHOUT ANY WARRANTY; without even the implied warranty of");
		$fdisplay (ctrl_received_file, "// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU");
		$fdisplay (ctrl_received_file, "// Lesser General Public License for more details.");
		$fdisplay (ctrl_received_file, "//\n// You should have received a copy of the GNU Lesser General Public");
		$fdisplay (ctrl_received_file, "// License along with this library release; if not, write to the Free Software");
		$fdisplay (ctrl_received_file, "// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA");
		$fdisplay (ctrl_received_file, "//\n// LeWiz can be contacted at:  support@lewiz.com");
		$fdisplay (ctrl_received_file, "// or address:");
		$fdisplay (ctrl_received_file, "// PO Box 9276");
		$fdisplay (ctrl_received_file, "// San Jose, CA 95157-9276");
		$fdisplay (ctrl_received_file, "// www.lewiz.com");
		$fdisplay (ctrl_received_file, "//\n//    Author: LeWiz Communications, Inc.");
		$fdisplay (ctrl_received_file, "//    Language: Verilog");
		$fdisplay (ctrl_received_file, "//\n//\n\n//This file stores the 32 bits received ctrl which needs to be compared with transmitted ctrl (LMAC input).");//write to the text file: First line description
	
		$fclose(data_received_file);
		$fclose(ctrl_received_file);
		
		i		=	0;	//index from packet start to packet end.
		j		=	0;	//stores the index to print inside the text file.
		
		pkt_cnt	=	0;	//stores the packet count to print inside the text file.
		
		mem_rd_start_address = 32'b0;
		
	end
	
	always @ (posedge rx_mac_aclk) begin
	
		if (rx_axis_mac_tvalid) begin
			//write data and strobe to memories
			memory_rd_data [mem_rd_address]	 <=	 mem_axis_rdata;
			memory_rd_ctrl [mem_rd_address]	 <=	 mem_axis_rstrb;	
		end
	
	end
	  
	
	always @ (rx_axis_mac_tvalid) begin
		//always at start of tvalid, take the read address as start address.
		if (rx_axis_mac_tvalid)
			mem_rd_start_address = mem_rd_address;
	
	end
	
	always @ (rd_done) begin
	
		if (rd_done) begin
		
			pkt_cnt	=	pkt_cnt	+	1;		//at every read done, pkt_cnt = pkt_cnt + 1.
			
			data_received_file 	= $fopen("C:/LMAC3_INFO/AXIS_MASTER/data_received_file.txt", "a"); 		//open file
			ctrl_received_file 	= $fopen("C:/LMAC3_INFO/AXIS_MASTER/ctrl_received_file.txt", "a"); 		//open file
		
			$fdisplay (data_received_file, "\n\n//pkt - %0d\n", pkt_cnt);	//add new line packet number
			$fdisplay (ctrl_received_file, "\n\n//pkt - %0d\n", pkt_cnt);	//add new line packet number
		
			//write first data (D5555555555555FB) to the text file.
			$fdisplayh (data_received_file, 64'hD5555555555555FB, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
			$fdisplayh (ctrl_received_file, 8'h01, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
			j = j+1;
			
			for (i = mem_rd_start_address; i < mem_rd_address; i = i+1) begin
			
				//if last data, check the control and write only valid data.
				if (i == (mem_rd_address - 1)) begin
					case (memory_rd_ctrl[i])
					
						32'hff_ff_ff_ff: 	begin
									
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file, ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
									        	
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
									        	
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
												
												$fdisplayh (data_received_file, memory_rd_data [i][255:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][31:24])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
												$fdisplayh (data_received_file, 64'h070707FDC4C3C2C1, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);		
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                 
												j = j+1;                                                                                                 
												
								
											end
						32'h7f_ff_ff_ff: 	begin
											
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file, ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);    
												j = j+1;                                                                                                       
												                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file, ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);   
												j = j+1;                                                                                                       
												                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);  
												j = j+1;                                                                                                       
												
												$fdisplayh (data_received_file,8'hC1,memory_rd_data [i][247:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file, {1'b1	, ~(memory_rd_ctrl [i][30:24])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);  
												j = j+1;  
												$fdisplayh (data_received_file, 64'h07070707FDC4C3C2, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);		      
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                                                                                                   				
												j = j+1;                                                                                                       									
												
											end
					 	32'h3f_ff_ff_ff: 	begin
												
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	  
												$fdisplayh (ctrl_received_file, ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);     
												j = j+1;                                                                                                        
												                                                                                                                
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);    
												j = j+1;                                                                                                        
												                                                                                                                
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);   
												j = j+1;                                                                                                        
												                                                                                                                
												$fdisplayh (data_received_file,16'hC2C1, memory_rd_data [i][239:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file, {2'b11, ~(memory_rd_ctrl [i][29:24])},  "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);   
												j = j+1;  
												$fdisplayh (data_received_file, 64'h0707070707FDC4C3, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	  
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);          
												j = j+1;                                                                                                                                                                                               
											end
						32'h1f_ff_ff_ff: 	begin
									
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	            
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);              
												j = j+1;                                                                                                                 
												                                                                                                                         
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	          
												$fdisplayh (ctrl_received_file, ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);             
												j = j+1;                                                                                                                 
												                                                                                                                         
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	          
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);            
												j = j+1;                                                                                                                 
												                                                                                                                         
												$fdisplayh (data_received_file, 24'hC3C2C1,memory_rd_data [i][231:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file, {3'b111, ~(memory_rd_ctrl [i][28:24])},  "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);     
												j = j+1;   
												$fdisplayh (data_received_file, 64'h070707070707FDC4, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	  
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);          
												j = j+1;                                                                                                                                                                                                                
												
											end
						32'h0f_ff_ff_ff: 	begin
									        	
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	            
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);              
												j = j+1;                                                                                                                 
												                                                                                                                         
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	          
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8]), "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);             
												j = j+1;                                                                                                                 
												                                                                                                                         
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	          
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);            
												j = j+1;                                                                                                                 
												                                                                                                                         
												$fdisplayh (data_received_file, 32'hC4C3C2C1,memory_rd_data [i][223:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);									
												$fdisplayh (ctrl_received_file,{4'hf , ~(memory_rd_ctrl [i][27:24])},  "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);    
												j = j+1;
												$fdisplayh (data_received_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	     
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);             
												j = j+1;                                                                                                     
												                                                                                                                 
											end
						32'h07_ff_ff_ff: 	begin
												
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	               
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                 
												j = j+1;                                                                                                                    
												                                                                                                                            
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	             
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                
												j = j+1;                                                                                                                    
												                                                                                                                            
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	             							
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);               
												j = j+1;                                                                                                                    
												                                                                                                                            
												$fdisplayh (data_received_file, 40'hFDC4C3C2C1,memory_rd_data [i][215:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  {5'b11111,~(memory_rd_ctrl [i][26:24])},  "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);      
												j = j+1;                                                                                                                   
											 end
						32'h03_ff_ff_ff: 	begin
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                  
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                       
												                                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                   									
												j = j+1;                                                                                                                       
												                                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	             			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                  
												j = j+1;                                                                                                                       
												                                                                                                                               
												$fdisplayh (data_received_file, 48'h07FDC4C3C2C1,memory_rd_data [i][207:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file,  {6'b111111,~(memory_rd_ctrl [i][25:24])},  "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);        
												j = j+1;                                                                                                                       
									
											end
						32'h01_ff_ff_ff: 	begin
								
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                  
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                       
												                                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                   		
												j = j+1;                                                                                                                       
												                                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	             		
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                  
												j = j+1;                                                                                                                       
												                                                                                                                               
												$fdisplayh (data_received_file, 56'h0707FDC4C3C2C1,memory_rd_data [i][199:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file, {7'b1111111, ~(memory_rd_ctrl [i][24])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);        
												j = j+1;                                                                                                                       
											end
						32'h00_ff_ff_ff: 	begin
											
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
									        	
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
									        	
												$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][23:16])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
												
												$fdisplayh (data_received_file, 64'h070707FDC4C3C2C1, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
								
											end
						32'h00_7f_ff_ff: 	begin
											
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);    
												j = j+1;                                                                                                       
												                                                                                                               
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);   
												j = j+1;                                                                                                       
												                                                                                                               
												$fdisplayh (data_received_file, 8'hC1,memory_rd_data [i][183:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  {1'b1,~(memory_rd_ctrl [i][22:16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);  
												j = j+1;                                                                                                       
												                                                                                                               
												$fdisplayh (data_received_file, 64'h07070707FDC4C3C2, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			     
												$fdisplayh (ctrl_received_file, 8'hFF	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                       
												j = j+1;                                                                                                       	
																					
												
											end
						32'h00_3f_ff_ff: 	begin
										
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	      
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);         
												j = j+1;                                                                                                            
												                                                                                                                    
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	     
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);        
												j = j+1;                                                                                                            
												                                                                                                                    
												$fdisplayh (data_received_file, 16'hC2C1,memory_rd_data [i][175:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  {2'b11,~(memory_rd_ctrl [i][21:16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);   
												j = j+1;                                                                                                            
												                                                                                                                    
												$fdisplayh (data_received_file, 64'h0707070707FDC4C3, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			          
												$fdisplayh (ctrl_received_file, 8'hff	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                            
												j = j+1;                                                                                                       	    
											end
						32'h00_1f_ff_ff: 	begin
											
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	          
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);             
												j = j+1;                                                                                                                
												                                                                                                                        
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	         
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);            
												j = j+1;                                                                                                                
												                                                                                                                        
												$fdisplayh (data_received_file, 24'hC3C2C1,memory_rd_data [i][167:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  {3'b111,~(memory_rd_ctrl [i][20:16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);       
												j = j+1;                                                                                                                
												                                                                                                                        
												$fdisplayh (data_received_file, 64'h070707070707FDC4, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			               
												$fdisplayh (ctrl_received_file, 8'hff, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                 
												j = j+1;                                                                                                       	        
												
											end
						32'h00_0f_ff_ff: 	begin
									       
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	            
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);               
												j = j+1;                                                                                                                  
												                                                                                                                          
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	           
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);              
												j = j+1;                                                                                                                  
												                                                                                                                          
												$fdisplayh (data_received_file, 32'hC4C3C2C1,memory_rd_data[i][159:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
												$fdisplayh (ctrl_received_file,  {4'hf,~(memory_rd_ctrl [i][19:16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);         
												j = j+1;                                                                                                                  
												                                                                                                                          
												$fdisplayh (data_received_file, 64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			                								
												$fdisplayh (ctrl_received_file, 8'hFF	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                  
												j = j+1;                                                                                                       	          
											end
						32'h00_07_ff_ff: 	begin
												
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                  
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                     
												j = j+1;                                                                                                                        
												                                                                                                                                
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                 
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                        
												                                                                                                                                
												$fdisplayh (data_received_file,40'hFDC4C3C2C1, memory_rd_data [i][151:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	    							
												$fdisplayh (ctrl_received_file, {5'b11111, ~(memory_rd_ctrl [i][18:16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);               
												j = j+1;                                                                                                                        
												                                                                                                                                    	                
											 end
						32'h00_03_ff_ff: 	begin
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                            
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                            
												j = j+1;                                                                                                                              
												                                                                                                                                      
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                        
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                          									
												j = j+1;                                                                                                                              
												                                                                                                                                      
												$fdisplayh (data_received_file, 48'h07FDC4C3C2C1,memory_rd_data [i][143:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	      			
												$fdisplayh (ctrl_received_file, {6'b111111, ~(memory_rd_ctrl [i][17:16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                              
												                                                                                                                               
											end
						32'h00_01_ff_ff: 	begin
								
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                             
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                               
												j = j+1;                                                                                                                                  
												                                                                                                                                          
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                           
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                          				
												j = j+1;                                                                                                                                  
												                                                                                                                                          
												$fdisplayh (data_received_file, 56'h0707FDC4C3C2C1,memory_rd_data [i][135:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	      			 
												$fdisplayh (ctrl_received_file, {7'b1111111, ~(memory_rd_ctrl [i][16])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                                  
												
											end
						32'h00_00_ff_ff: 	begin
										
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
									        	
												$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][15:8])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
									        	
												$fdisplayh (data_received_file,64'h070707FDC4C3C2C1, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   		
												$fdisplayh (ctrl_received_file,8'b11111111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                 
												j = j+1;                                                                                                                             		
										
											end
						32'h00_00_7f_ff: 	begin
									
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	    
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);      
												j = j+1;                                                                                                         
												                                                                                                                 
												$fdisplayh (data_received_file, 8'hC1,memory_rd_data [i][119: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	  
												$fdisplayh (ctrl_received_file,  {1'b1,~(memory_rd_ctrl [i][14:8])}	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);     
												j = j+1;                                                                                                         
												                                                                                                                 
												$fdisplayh (data_received_file,64'h07070707FDC4C3C2, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   		     
												$fdisplayh (ctrl_received_file,8'b11111111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                                                                                                           

											end
						32'h00_00_3f_ff: 	begin
												//write 8 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	             
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);               
												j = j+1;                                                                                                                  
												                                                                                                                          
												$fdisplayh (data_received_file, 16'hC2C1,memory_rd_data [i][111: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	      
												$fdisplayh (ctrl_received_file,  {2'b11,~(memory_rd_ctrl [i][13:8])}	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);          
												j = j+1;                                                                                                                  
												                                                                                                                          
												$fdisplayh (data_received_file,64'h0707070707FDC4C3, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   		              
												$fdisplayh (ctrl_received_file,8'b11111111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                             
												j = j+1;                                                                                                                  
												
											end
						32'h00_00_1f_ff: 	begin
												//write 8 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                    
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                      
												                                                                                                                              
												$fdisplayh (data_received_file, 24'hC3C2C1,memory_rd_data [i][103: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	        
												$fdisplayh (ctrl_received_file,  {3'b111,~(memory_rd_ctrl [i][12:8])}	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);              
												j = j+1;                                                                                                                      
												                                                                                                                              
												$fdisplayh (data_received_file,64'h070707070707FDC4, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   		                   
												$fdisplayh (ctrl_received_file,8'b11111111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                    
												j = j+1;                                                                                                                      
												                                                                                                                       
											end
						32'h00_00_0f_ff: 	begin
									        		//write 8 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                    
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                    
												j = j+1;                                                                                                                      
												                                                                                                                              
												$fdisplayh (data_received_file, 32'hC4C3C2C1,memory_rd_data [i][95: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	     
												$fdisplayh (ctrl_received_file,  {4'b1111,~(memory_rd_ctrl [i][11:8])}	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);             
												j = j+1;                                                                                                                      
												                                                                                                                              
												$fdisplayh (data_received_file,64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   		                   
												$fdisplayh (ctrl_received_file,8'b11111111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                    
												j = j+1;                                                                                                                      
												                                                                                                                         
											end
						32'h00_00_07_ff: 	begin
												//write 8 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                    
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                      
												j = j+1;                                                                                                                         
												                                                                                                                                 
												$fdisplayh (data_received_file, 40'hFDC4C3C2C1,memory_rd_data [i][87: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	      
												$fdisplayh (ctrl_received_file, {5'b11111, ~(memory_rd_ctrl [i][10:8])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                
												j = j+1;                                                                                                                         
												                                                                                                                                                                                                                                                         
											 end
						32'h00_00_03_ff: 	begin
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                               
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                               
												j = j+1;                                                                                                                                 
												                                                                                                                                         
												$fdisplayh (data_received_file, 48'h07FDC4C3C2C1,memory_rd_data [i][79: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	             
												$fdisplayh (ctrl_received_file, {6'b111111	,~(memory_rd_ctrl [i][9:8])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                   									
												j = j+1;                                                                                                                                 
												                                                                                                                               
											end
						32'h00_00_01_ff: 	begin
									
												$fdisplayh (data_received_file, memory_rd_data [i][63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                                         
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                         
												j = j+1;                                                                                                                                           
												                                                                                                                                                   
												$fdisplayh (data_received_file, 56'h0707FDC4C3C2C1,memory_rd_data [i][71: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                     
												$fdisplayh (ctrl_received_file, {7'b1111111,~(memory_rd_ctrl [i][8])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                             		
												j = j+1;                                                                                                                                           
												                                                                              	
											end
						32'h00_00_00_ff: 	begin
												//write entire QWD to the text file.
												$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);			
												$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);
												j = j+1;
												$fdisplayh (data_received_file,64'h070707FDC4C3C2C1, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);  
												$fdisplayh (ctrl_received_file,8'b1111_1111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);              
									            j = j+1;                                                                                                                          
								
											end
						32'h00_00_00_7f: 	begin
												//write 7 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, 8'hC1,memory_rd_data [i][ 55: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   
												$fdisplayh (ctrl_received_file,  {1'b1,~(memory_rd_ctrl [i][6:0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);      
												j = j+1;                                                                                                         
												$fdisplayh (data_received_file,64'h07070707FDC4C3C2, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);           
												$fdisplayh (ctrl_received_file,8'b1111_1111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                   
												j = j+1;                                                                                                                                                                                                             
												                                                                                                               
											end
						32'h00_00_00_3f: 	begin
												//write 6 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, 16'hC2C1,memory_rd_data [i][ 47: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	   
												$fdisplayh (ctrl_received_file,  {2'b11,~(memory_rd_ctrl [i][5:0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);       
												j = j+1;                                                                                                               
												$fdisplayh (data_received_file,64'h0707070707FDC4C3, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                 
												$fdisplayh (ctrl_received_file,8'b1111_1111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                         
												j = j+1;                                                                                                               
							
											end
						32'h00_00_00_1f: 	begin
												//write 5 bytes of the QQQWD to the text file.
												$fdisplayh (data_received_file, 24'hC3C2C1,memory_rd_data [i][ 39: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	            
												$fdisplayh (ctrl_received_file, {3'b111, ~(memory_rd_ctrl [i][4:0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                 
												j = j+1;                                                                                                                        
												$fdisplayh (data_received_file,64'h070707070707FDC4, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                            
												$fdisplayh (ctrl_received_file,8'b1111_1111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                   
												j = j+1;                                                                                                                        
												
											end
						32'h00_00_00_0f: 	begin
									        		//write 4 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, 32'hC4C3C2C1,memory_rd_data [i][ 31: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	    
												$fdisplayh (ctrl_received_file, {4'b1111, ~(memory_rd_ctrl [i][3:0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);            
												j = j+1;                                                                                                                    
												$fdisplayh (data_received_file,64'h07070707070707FD, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                        
												$fdisplayh (ctrl_received_file,8'b1111_1111, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                              
												j = j+1;                                                                                                                    
																					
											 
											
											end
						32'h00_00_00_07: 	begin
												//write 3 bytes of the QQWD to the text file.
												$fdisplayh (data_received_file, 40'hFDC4C3C2C1,memory_rd_data [i][ 23: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	      
												$fdisplayh (ctrl_received_file, {5'b11111, ~(memory_rd_ctrl [i][2:0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);               
												j = j+1;                                                                                                                      
												               
												                
												               
												
											 end
						32'h00_00_00_03: 	begin
												$fdisplayh (data_received_file, 48'h07FDC4C3C2C1,memory_rd_data [i][ 15: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                       
												$fdisplayh (ctrl_received_file, {6'b111111,~(memory_rd_ctrl [i][1:0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                              
												j = j+1;                                                                                                                                                                                                           
									
											end
						32'h00_00_00_01: 	begin
									//write 1 byte of the QQWD to the text file.
												$fdisplayh (data_received_file, 56'h0707FDC4C3C2C1,memory_rd_data [i][7: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	                                       
												$fdisplayh (ctrl_received_file, {7'b1111111, ~(memory_rd_ctrl [i][0])}, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);                                               
												j = j+1;                                                                                                                                                            
											
											end
						default:begin
						
								end
					
					endcase
				
				end
				else begin
					//write the data to the text file.
					$fdisplayh (data_received_file, memory_rd_data [i][ 63: 0], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	 
					$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);    
					j = j+1;                                                                                                       
					                                                                                                               
					$fdisplayh (data_received_file, memory_rd_data [i][127: 64], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
					$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);   
					j = j+1;                                                                                                       
					                                                                                                               
					$fdisplayh (data_received_file, memory_rd_data [i][191:128], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
					$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);  
					j = j+1;                                                                                                       
					                                                                                                               
					$fdisplayh (data_received_file, memory_rd_data [i][255:192], "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);	
					$fdisplayh (ctrl_received_file,  ~(memory_rd_ctrl [i][7:0])	, "\t\t//Index: %3d\tPkt No.: %0d", j, pkt_cnt);  
					j = j+1;                                                                                                       
					
				end

			end
		
		end
		
		else begin
		
			data_received_file 	= $fopen("C:/LMAC3_INFO/AXIS_MASTER/data_received_file.txt", "w"); 		//open file
			ctrl_received_file 	= $fopen("C:/LMAC3_INFO/AXIS_MASTER/ctrl_received_file.txt", "w"); 		//open file
		
		    $fclose(data_received_file);
			$fclose(ctrl_received_file);
		
		end

	end
     
	
endmodule