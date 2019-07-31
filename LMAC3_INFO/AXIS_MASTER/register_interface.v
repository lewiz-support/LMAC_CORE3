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

module register_interface(

	reg_clk,				//i-1, Register Interface clock 	
	reset_,        			//i-1, reset 
	host_addr,       	 	//o-16, address offset of the LMAC registers
	reg_rd_start,			//o-1, Pulsed signal. Start the read when 1  
	reg_rd_done_out,		//i-1, Indicates when valid data is available on the MAC_REGDOUT line 
	mac_regdout,			//i-32, Data returned from LMAC
	start,					//i-1, start signal to start the transaction   
	address                 //i-16, address in 
	);
	
	input 							reg_clk;			//i-1, Register Interface clock 						
	input							reset_;				//i-1, reset                    			
	input		[15 : 0]			address;			//i-16, address in 			
	output		reg [15 : 0]		host_addr;       	//o-16, address offset of the LMAC registers 			
	output		reg					reg_rd_start;		//o-1, Pulsed signal. Start the read when 1 			
	input 							start;				//i-1, start signal to start the transaction 			
	input							reg_rd_done_out;	//i-1, Indicates when valid data is available on the MAC_REGDOUT line			
	input		[31 : 0]			mac_regdout;		//i-32, Data returned from LMAC                                      			
	reg			[31 : 0]			data;
		
	
	
	
	//State Machine for Read
	reg		[4:0] 	rif_rd_state = 5'h01;
	
	wire			rif_rd_idle_st;                     //Idle state                                                                   
	wire			rif_rd_address_st;                  //In this state, address is sent along with the start signal                   
	wire			rif_rd_wait_st;                     //Wait state to get the response from the LMAC                                 
	wire			rif_rd_data_st;                     //Once we get the done signal from the LMAC we can latch the data in this state
	wire			rif_rd_done_st;                     //Transation complete state                                                    
		
	parameter [4:0]                                     // One hot encoding fo states                                                  
			RIF_RD_IDLE		= 	5'h01,  
			RIF_RD_ADDRESS	= 	5'h02, 
			RIF_RD_WAIT	    = 	5'h04,		
			RIF_RD_DATA		= 	5'h08,
			RIF_RD_DONE     =   5'h10;  
		
	assign	rif_rd_idle_st  	= 	rif_rd_state[0];   
	assign  rif_rd_address_st  	= 	rif_rd_state[1];             
	assign	rif_rd_wait_st	 	= 	rif_rd_state[2];   
	assign	rif_rd_data_st  	= 	rif_rd_state[3];
	assign	rif_rd_done_st  	= 	rif_rd_state[4];
	
	
	
	
	//counter to wait for data out
		reg [2:0] data_out_count;	
	always @ (posedge reg_clk)
	begin
		if (!reset_)
		begin
			data_out_count <= 3'd0;
		end
		else
		begin
			data_out_count <=
				(rif_rd_state == RIF_RD_WAIT) ? (data_out_count + 1'b1) : 3'd0;
		end
	end
	
	
	
	
	//State Machine for Read	
	always @ (posedge reg_clk)           
	begin             
	               	                                
		if (!reset_)         
		begin   
		                       
			rif_rd_state	<= RIF_RD_IDLE ;             // Idle state at Reset
		     
		end  
		                          
		else                            
		begin
		    case (rif_rd_state)
		    
		    	RIF_RD_IDLE:                             // Go to address state if start signal is received
		    		rif_rd_state <=
					(start) ? RIF_RD_ADDRESS : RIF_RD_IDLE;
					
				RIF_RD_ADDRESS:                          // Go to wait state in the next clock
					rif_rd_state <= RIF_RD_WAIT;
				
				RIF_RD_WAIT:                             // Wait for done signal, then go to data state
					rif_rd_state <=
										  (reg_rd_done_out == 1'b1) ? RIF_RD_DATA : RIF_RD_WAIT;
				
				RIF_RD_DATA:                             // Wait for one clock and go to done state
					rif_rd_state <= RIF_RD_DONE;
				
				RIF_RD_DONE:
		    		rif_rd_state <= RIF_RD_IDLE;
		    		
		    	default:
		    	    rif_rd_state <= RIF_RD_IDLE;
				
		    endcase                                             	  		
		 			    									                          		                             
		end
    end
		
		always @ (posedge reg_clk)           
            begin             
                                                               
                if (!reset_)         
                begin   
                                       
               		host_addr <= 16'd0;
                    data_out_count <= 3'd0;
                     
                end  
                                          
                else                            
                begin
                    case (rif_rd_state)
                    
                        RIF_RD_IDLE: begin                           // Initialize host address and data_out_counter to 0 in Idle
                            host_addr <= 16'd0;
                            data_out_count <= 3'd0;
                            end
                            
                        RIF_RD_ADDRESS: begin                        // Send the address requested for register read to the LMAC
                            host_addr <= address;
                            data_out_count <= 3'd0;
                            end
                        
                        RIF_RD_WAIT: begin                           // Wait for the Done signal from LMAC and increment counter
                        	if (data_out_count <= 3'b100) begin
								data_out_count <= data_out_count + 1'b1;
							end
							else
							begin
								data_out_count <= data_out_count;
							end
                            host_addr <= host_addr;
                            end
                        
                        RIF_RD_DATA: begin                            // Collect Data once the Done signal is received
                            host_addr <= host_addr;
                            data_out_count <= 3'd0;
                            end
                        
                        RIF_RD_DONE:begin
                            host_addr <= host_addr;
                            data_out_count <= 3'd0;
                            end
                            
                        default: begin
                            host_addr <= 16'd0;
                            data_out_count <= 3'd0;
                            end
                        
                    endcase                                                           
                                                                                                                                    
                end
		                 
	      end
	      
	      always @ (posedge reg_clk)
	      begin
	      	if (!reset_) begin
	      		data <= 31'd0;
	      	end
	      	else
	      	begin
	      		if (reg_rd_done_out == 1'b1) begin             // Collect data in data register from the mac_regdout signal
	      			data <= mac_regdout;
	      		end
	      		else
	      		begin
	      			data <= data;
	      		end
	      	end
	      end
	      
	      
	      always @ (posedge reg_clk)
	      begin
	      		if(!reset_)
	      		begin
	      			reg_rd_start <= 1'b0;
	      		end
	      		else
	      		begin
	      			reg_rd_start <= (data_out_count == 3'd1) ? 1'b1 : 1'b0;       // Send the start signal to the LMAC core
	      		end
	      end
	      
	      	      
	                                
	              //synopsys translate_off                                  
                                                                                
                                                               
              reg [64*8-1 : 0] ascii_rif_rd_state;                          
                                                                        
              always @ (rif_rd_state)                                       
              begin                                                     
                  case(rif_rd_state)                                         
                  RIF_RD_IDLE        :      ascii_rif_rd_state = "RIF_RD_IDLE";        
                  RIF_RD_ADDRESS     :      ascii_rif_rd_state = "RIF_RD_ADDRESS";          
                  RIF_RD_WAIT        :      ascii_rif_rd_state = "RIF_RD_WAIT";            
                  RIF_RD_DATA        :      ascii_rif_rd_state = "RIF_RD_DATA";
                  RIF_RD_DONE        :      ascii_rif_rd_state = "RIF_RD_DONE";
                  endcase                                                  
              end                                                       
                                                                        
              //synopsys translate_on

endmodule