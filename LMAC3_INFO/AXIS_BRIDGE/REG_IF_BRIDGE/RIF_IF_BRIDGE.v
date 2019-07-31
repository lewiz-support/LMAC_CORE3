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

module rif_if_bridge (

		fmac_clk,           //i, LMAC clock
		axis_clk,           //i, AXI stream clock
		reset_,             //i, reset
		
		host_addr_in,       //i-16, host address coming from AXI master
		mac_regdout_in,     //i-32, MAC_REGDOUT coming from LMAC
		reg_rd_start_in,    //i, start siganl coming from AXI master
		reg_rd_done_in,     //i, done signal coming from LMAC 
		
		host_addr_out,      //o-16, host address to be sent to the LMAC
		mac_regdout_out,    //o-32, mac_regdout to be sent to the AXI master
		reg_rd_start_out,   //o, start signal to be sent to the LMAC
		reg_rd_done_out     //o, done signal to be sent to the AXI master

);




input						fmac_clk;              //i, LMAC clock                                 
input						axis_clk;              //i, AXI stream clock                           
input						reset_;                //i, reset                                      
		                                                                                           
input		[15 : 0]		host_addr_in;          //i-16, host address coming from AXI master     
input		[31 : 0]		mac_regdout_in;        //i-32, MAC_REGDOUT coming from LMAC            
input						reg_rd_start_in;       //i, start siganl coming from AXI master        
input						reg_rd_done_in;        //i, done signal coming from LMAC               
		                                                                                           
output		[15 : 0]		host_addr_out;         //o-16, host address to be sent to the LMAC     
output		[31 : 0]		mac_regdout_out;       //o-32, mac_regdout to be sent to the AXI master
output						reg_rd_start_out;      //o, start signal to be sent to the LMAC        
output		reg				reg_rd_done_out;       //o, done signal to be sent to the AXI master   

wire						wrfull_done;           // Write full signal for Done signal FIFO
wire						wrfull_start;          // Write full signal for start signal FIFO
wire						wrfull_data;           // Write full signal for data FIFO
wire						wrfull_address;        // Write full signal for address FIFO
    						
wire						wren_done;             // Write enable signal for Done signal FIFO 
reg							wren_start;            // Write enable signal for start signal FIFO
wire						wren_data;             // Write enable signal for data FIFO        
reg							wren_address;          // Write enable signal for address FIFO     
    						
wire		[7 : 0]			reg_rd_done_in_8bit;   // Input done signal converted to 8 bits 
wire		[7 : 0]			reg_rd_done_out_8bit;  // Output done signal in 8 bits
reg			[7 : 0]			reg_rd_start_in_8bit;  // Input start signal converted to 8 bits
wire		[7 : 0]			reg_rd_start_out_8bit; // Output start signal in 8 bits     
    						
wire						wrempty_done;          // Write empty signal for Done FIFO
wire		[2 : 0]			wrusedw_done;          // Write used word signal for Done FIFO
wire						rdfull_done;           // Read full signal for Done FIFO
wire						rdempty_done;          // Read empty signal for Done FIFO
wire		[2 : 0]			rdusedw_done;          // Read used word signal for Done FIFO
    						
wire						wrempty_start;         // Write empty signal for Start FIFO    
wire		[2 : 0]			wrusedw_start;         // Write used word signal for Start FIFO
wire						rdfull_start;          // Read full signal for Start FIFO      
wire						rdempty_start;         // Read empty signal for Start FIFO     
wire		[2 : 0]			rdusedw_start;         // Read used word signal for Start FIFO 
    						
wire						wrempty_data;          // Write empty signal for Data FIFO    
wire		[2 : 0]			wrusedw_data;          // Write used word signal for Data FIFO
wire						rdfull_data;           // Read full signal for Data FIFO      
wire						rdempty_data;          // Read empty signal for Data FIFO     
wire		[2 : 0]			rdusedw_data;          // Read used word signal for Data FIFO 
    						
wire						wrempty_address;       // Write empty signal for Address FIFO    
wire		[2 : 0]			wrusedw_address;       // Write used word signal for Address FIFO
wire						rdfull_address;        // Read full signal for Address FIFO      
wire						rdempty_address;       // Read empty signal for Address FIFO     
wire		[2 : 0]			rdusedw_address;       // Read used word signal for Address FIFO 
    						
wire						dbg_done;
wire						dbg_start;
wire						dbg_data;
wire						dbg_address;

wire						done_out;

reg							rden_address;



reg done_rd_start;
reg done_rd_start_delay1;
reg done_rd_start_delay2;
reg done_rd_start_delay3;




// Generating delayed versions of done_rd_start siganl
always @(posedge axis_clk) begin
   if (!reset_) begin
   		done_rd_start_delay1 <= 1'd0;
   		done_rd_start_delay2 <= 1'd0;
   		done_rd_start_delay3 <= 1'd0;
   		done_rd_start <= 1'd0;
   end
   else
   begin
   		done_rd_start_delay1 <= 1'b1;
   		done_rd_start_delay2 <= done_rd_start_delay1;
   		done_rd_start_delay3 <= done_rd_start_delay2;
   		done_rd_start <= done_rd_start_delay3;
   end
end



always @ (posedge axis_clk) begin
   if (!reset_) begin
          wren_address <= 1'b0;
          rden_address <= 1'b0;
   end
   else
   begin
          wren_address      <= 		wrfull_address ? 1'b0 : 1'b1;    // Address should be written to the FIFO only if it is not full
          rden_address      <= 		wren_address;					 // Read enable signal
   end
end



assign wren_data 						= 		reg_rd_done_in;
assign wren_done 						= 		reg_rd_done_in;


assign reg_rd_done_in_8bit 			= 		{7'b000000, reg_rd_done_in};		  	// Done signal converted to 8 bits

assign reg_rd_start_out					=		reg_rd_start_out_8bit[0];
assign done_out				=					reg_rd_done_out_8bit[0];




always @ (posedge axis_clk or negedge reset_)
begin
	if (!reset_) begin
		reg_rd_start_in_8bit <= 8'd0;
		wren_start <= 1'b0;
	end
	else
	begin
		reg_rd_start_in_8bit 			<= 		{7'b000000, reg_rd_start_in};	   	// Start signal converted to 8 bits
		wren_start 						<=		!wrfull_start;					  	// Write enable to start signal only if the FIFO is not full
	end

end





reg [2:0] count_done;
reg read_en_done;

// Counter is used to generate the read enable signal for the Done FIFO
always @ (posedge fmac_clk)
begin
	if(!reset_) begin
		count_done <= 3'b0;
	end
	else
	begin
		if(count_done == 3'b100) begin
			count_done <= 3'b001;            // Counter intialized to 1 after 4
		end
		else
		begin
			count_done <= count_done + 1'b1;
		end
	end
end

always @(posedge axis_clk)
begin
	if(!reset_) begin
		read_en_done <= 1'd0;
	end
	else
	begin
		if(count_done == 3'b100) begin		// Read enable only when couter value is 4
			read_en_done <= 1'd1;
		end
		else
		begin
			read_en_done <= 1'd0;
		end
	end
end



always @(posedge axis_clk)
begin
	if(!reset_) begin
		reg_rd_done_out <= 1'd0;
	end
	else
	begin
		if(reg_rd_done_out == 1'b1) begin
			reg_rd_done_out <= 1'd0;		// reg_rd_done_out signal deasserted one clock after it is asserted
		end
		else
		begin
			reg_rd_done_out <= done_out;
					end
	end
end


// 4x8 FIFO for DONE signal
rxrregif_fifo4x8 # (.WIDTH (8),
					.DEPTH (4),
					.PTR (2) )

		  rxrregif_fifo4x8_done(
		  
			.reset_				(reset_),
			
			.wrclk				(fmac_clk),
						.wren				(!wrfull_done),
			.datain				(reg_rd_done_in_8bit),
			.wrfull				(wrfull_done),
			.wrempty			(wrempty_done),
			.wrusedw			(wrusedw_done),
                                                    

			
			.rdclk				(axis_clk),
												.rden				(done_rd_start),
			.dataout			(reg_rd_done_out_8bit),
			.rdfull				(rdfull_done),
			.rdempty			(rdempty_done),
			.rdusedw			(rdusedw_done),

			
			.dbg				(dbg_done)

);

// 4x8 FIFO for Start signal
wire		start_sclk	;		
reg			reg_rd_start_in_d1;
wire		reg_rd_start_in_d;
txwregif_fifo4x8 # (.WIDTH (8),
					.DEPTH (4),
					.PTR (2) )

		  txwregif_fifo4x8_start(
		  
			.reset_				(reset_),
			
			.wrclk				(axis_clk),
			.wren				(reg_rd_start_in_d),
			.datain				(reg_rd_start_in_8bit),
			.wrfull				(wrfull_start),
			.wrempty			(wrempty_start),
			.wrusedw			(wrusedw_start),
                                                                                 
                                                                                 
			                                                                                 
			.rdclk				(fmac_clk),                                      
			.rden				(start_sclk),
			.dataout			(reg_rd_start_out_8bit),
			.rdfull				(rdfull_start),
			.rdempty			(rdempty_start),
			.rdusedw			(rdusedw_start),

			
			.dbg				(dbg_start)

);

reg [2:0] count_start;

always @ (posedge axis_clk or negedge reset_)
begin
	if(!reset_) begin
		count_start <= 3'd0;
	end
	else
	begin
		if(reg_rd_start_in && count_start == 3'd0) begin
			count_start <= count_start + 1'b1;
		end
		else if(count_start > 3'b000 && count_start < 3'b100) begin		 // Counter countes only from 0 to 4
			count_start <= count_start + 1'b1;
		end
		else
		begin
			count_start <= 3'b000;
		end
	end
end

always @ (posedge axis_clk or negedge reset_)
begin
	if(!reset_) begin
				reg_rd_start_in_d1 <= 1'b0;
		end
	else
		begin
				if (reg_rd_start_in == 1'b1)			   //  reg_rd_start_in goes to write enable of START FIFO
			reg_rd_start_in_d1 <= reg_rd_start_in;
		else
			reg_rd_start_in_d1 <= reg_rd_start_in_d;
		end
end

assign reg_rd_start_in_d = (count_start == 3'd0) ? 1'b0 : 1'b1;
assign start_sclk = !wrempty_start;

//4x32 FIFO for MAC_REGDOUT signal
rxrregif_fifo4x32 # (.WIDTH (32),
					.DEPTH (4),
					.PTR (2) )

		  rxrregif_fifo4x32_data(
		  
			.reset_				(reset_),
			
			.wrclk				(fmac_clk),
			.wren				(wren_data),
			.datain				(mac_regdout_in),
			.wrfull				(wrfull_data),
			.wrempty			(wrempty_data),                             
			.wrusedw			(wrusedw_data),                             
                                                                            
                                                                            
			
			.rdclk				(axis_clk),
			.rden				(!rdempty_data),
			.dataout			(mac_regdout_out),
			.rdfull				(rdfull_data),
			.rdempty			(rdempty_data),
			.rdusedw			(rdusedw_data),

			
			.dbg				(dbg_data)

);

//4x16 FIFO for Address signal
txwregif_fifo4x16 # (.WIDTH (16),
					.DEPTH (4),
					.PTR (2) )

		  txwregif_fifo4x16_address(
		  
			.reset_				(reset_),
			
			.wrclk				(axis_clk),
			.wren				(wren_address),
			.datain				(host_addr_in),
			.wrfull				(wrfull_address),                           
			.wrempty			(wrempty_address),                          
			.wrusedw			(wrusedw_address),                          
                                                                            
                                                                            
			
			.rdclk				(fmac_clk),
			.rden				(rden_address),
			.dataout			(host_addr_out),
			.rdfull				(rdfull_address),
			.rdempty			(rdempty_address),
			.rdusedw			(rdusedw_address),

			
			.dbg				(dbg_address)

);


endmodule

