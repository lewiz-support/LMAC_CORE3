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


module rx_pkt_gen2kx32_dram_2clk # (parameter ADDR_DEPTH = 2048,			
									DATA_WIDTH = 32,
									ADDR_WIDTH = 11)				// 2**11 == 2048 which is DEPTH
			(
			
			//=== PORT_A Signals
			clk_a,			// Clk for PORT A
			addr_a,        	// ADDRESS to which data to be written through PORT A
			din_a,         	// DATA to be written
			en_a,          	// enables read, write and reset operations through PORT A
			we_a,          	// enables write operation through PORT A (1- WRITE 0- READ)
			dout_a,        	// read data through PORT A
			
			//=== PORT_B Signals
			clk_b,			// Clk for PORT B                                         
			addr_b,        	// ADDRESS to which data to be written through PORT B     
			din_b,         	// DATA to be written                                     
			en_b,          	// enables read, write and reset operations through PORT B
			we_b,          	// enables write operation through PORT B                 
			dout_b		   	// read data through PORT B                               				
									
);

			//=== PORT_A Signals
			input 							clk_a;			// Clk for PORT A
			input 	[ADDR_WIDTH - 1 : 0] 	addr_a;        	// ADDRESS to which data to be written through PORT A
			input 	[DATA_WIDTH - 1 : 0] 	din_a;         	// DATA to be written
			input 							en_a;           // enables read, write and reset operations through PORT A
			input 							we_a;           // enables write operation through PORT A (1- WRITE 0- READ)
			output 	[DATA_WIDTH - 1 : 0] 	dout_a;         // read data through PORT A
			
			//=== PORT_B Signals
			input							clk_b;			// Clk for PORT B                                         
			input	[ADDR_WIDTH - 1 : 0]	addr_b;        	// ADDRESS to which data to be written through PORT B     
			input	[DATA_WIDTH - 1 : 0]	din_b;         	// DATA to be written                                     
			input							en_b;           // enables read, write and reset operations through PORT B
			input							we_b;           // enables write operation through PORT B                 
			output	[DATA_WIDTH - 1 : 0] 	dout_b;		   	// read data through PORT B                               				

			
//==== Initialization
reg  [DATA_WIDTH - 1 : 0] din_a1 	 = {DATA_WIDTH{1'b0}};
reg  [DATA_WIDTH - 1 : 0] din_a2 	 = {DATA_WIDTH{1'b0}}; 
                                 	 
reg  [DATA_WIDTH - 1 : 0] din_b1 	 = {DATA_WIDTH{1'b0}};
reg  [DATA_WIDTH - 1 : 0] din_b2 	 = {DATA_WIDTH{1'b0}};

reg	 [ADDR_WIDTH - 1 : 0] rd_addr_b  = {ADDR_WIDTH{1'b0}};
reg	 [ADDR_WIDTH - 1 : 0] rd_addr_b1 = {ADDR_WIDTH{1'b0}};
     
reg	 [ADDR_WIDTH - 1 : 0] rd_addr_a  = {ADDR_WIDTH{1'b0}};
reg	 [ADDR_WIDTH - 1 : 0] rd_addr_a1 = {ADDR_WIDTH{1'b0}};
     
reg  [DATA_WIDTH - 1 : 0] dout_a 	 = {DATA_WIDTH{1'b0}};
reg  [DATA_WIDTH - 1 : 0] dout_b 	 = {DATA_WIDTH{1'b0}};


// INTERNAL MEMORY 
reg [DATA_WIDTH - 1 : 0] mem [0 : ADDR_DEPTH - 1];


//initial begin
//	$readmemh("C:/LMAC3_INFO/PHY_EMULATOR/rx_pkt_gen_ctrl.mem",mem); // initializing to zero just to avoid X.
//end


//=== PORT A
always @(posedge clk_a)
begin
	if (en_a)
		begin
		if (we_a)
			begin
				//mem[addr_a] <= (addr_a == addr_b ) ? din_a : din_a;					// WRITE TO MEMORY
				mem[addr_a] <= din_a;	
				
				din_a1 <= din_a;
				din_a2 <= din_a1;			// extra buff
				dout_a <= din_a1;
				       									
	//== This is for write before read condition
	// buffer the read address so that we read old data from the old address even after writing
				rd_addr_a <= addr_a;		// holding the current address into rd_addr_a 
				rd_addr_a1 <= rd_addr_a;	// holding the current address into rd_addr_a1
	//==
				
			end
		else             								// we_a else part
			begin
				
	//== This is for write before read condition	
	// buffer the read address so that we read old data from the old address even after writing		
				rd_addr_a <= addr_a;
				rd_addr_a1 <= rd_addr_a;
	//==
				
				din_a1 <= mem[addr_a];                        // READ FROM MEMORY
				din_a2 <= din_a1;			// extra buff
				dout_a <= din_a1; 
						
			end
		end

		
		
end// Always end

//assign dout_a = 1'b1 ? din_a2 : mem[rd_addr_a1] ;  			 	//write_before_read
//assign dout_a = 1'b0 ? din_a2 : mem[rd_addr_a1] ;  				 // read before write

//=== PORT B

always @(posedge clk_b)
begin
	if (en_b) 
		begin
		if (we_b)
			begin
				//mem[addr_b] <= (addr_a == addr_b) ? din_a : din_b;// WRITE TO MEMORY
				mem[addr_b] <= din_b;
				din_b1 <= din_b;
				din_b2 <= din_b1;
				dout_b <= din_b1;
				
	//== This is for write before read condition
	// buffer the read address so that we read old data from the old address even after writing
				rd_addr_b <= addr_b;
				rd_addr_b1 <= rd_addr_b;
	//==			
				
			end
		else
			begin
				// READ FROM MEMORY
	//== This is for write before read condition		
	// buffer the read address so that we read old data from the old address even after writing	
				rd_addr_b <= addr_b;
				//rd_addr_b1 <= rd_addr_b;
	//==			
				din_b1 <= mem[addr_b];        // for true dual port
				din_b2 <= din_b1;
				dout_b <= mem[rd_addr_b] ;	
						
			end
        end
end



//assign dout_b = 1'b1 ? mem[rd_addr_b1] : din_b2;                                        //write_before_read
//assign dout_b = 1'b0 ? mem[rd_addr_b1] : din_b2;                                        //read_before_write




//====Collision Detection Warning
always @(addr_a, addr_b,we_a,we_b)
begin
	if (addr_a == addr_b & we_a & we_b )
		
	 	$display( "at time : %d WARNING: Collision Detected: WRITE addr_a :%b and WRITE addr_b :%b ",$time, addr_a,addr_b);
	else if (addr_a == addr_b & we_a & !we_b )
		
		$display( "at time : %d WARNING: Collision Detected: WRITE addr_a :%b and READ addr_b :%b ",$time, addr_a,addr_b);
	else if	(addr_a == addr_b & !we_a & we_b )
		
		$display( "at time : %d WARNING: Collision Detected: READ addr_a :%b and WRITE addr_b :%b ",$time, addr_a,addr_b);
		 	
end

endmodule