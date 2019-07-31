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

module axis2fib_rxctrl (
	rx_mac_aclk,									//i-1	clock signal at AXIS frequency		
	reset_,											//i-1	global reset signal 	         	

//============Signals to Read FIFOs ==================		
	rden_rf,										//o-1	read enable of data FIFO 	
	rden_rcf,										//o-1	read enable of rdcnt FIFO	
	
//============Signals from Read FIFOs ==================	
	rdempty_rf, 									//i-1	Empty signal of data FIFO 	
	rdempty_rcf,									//i-1	Empty signal of rdcnt FIFO	
	dataout_rf,										//i-256	Dataout of data FIFO	   	
	dataout_rcf,									//i-64	Dataout of rdcnt FIFO    	

//=============Signals to AXIS Master ============		
	rx_axis_mac_tdata,								//o-256 	 data signal of bridge module                              	
    rx_axis_mac_tvalid,  							//o-1 	 signal to AXIS master indicating the data is valid          	
    rx_axis_mac_tlast,								//o-1 	 signal to AXIS Master saying end of data                    	
    rx_axis_mac_tuser,								//o-1 	 error signal from FMAC                                      	
    rx_axis_filter_tuser,							//o-1 	 error signal from filter of FMAC                            	
    rx_axis_mac_tstrb,								//o-32 	 Signal indicating valid bytes inside the qword transmitting	
    rx_statistics_vector,							//o-27 	 information about current frame                            	
    rx_statistics_valid,							//o-1	 Signal indication the statistics vector is valid             	

//=============Signals from AXIS Master ============    
	rx_axis_mac_tready,								//i-1	signal indicating that AXIS master accepted data	
	rx_axis_compatible_mode,    					//i-1    signal to keep tready always one             	   
	
//=============TEST signal ============	
	test 	                    					//o-1 	debug	       
								
);

parameter 	DATA_WIDTH = 256;
parameter 	BCNT_WIDTH = 64;
parameter	STRB_WIDTH = 32;

input	rx_mac_aclk;						        //i-1	clock signal at AXIS frequency 
input	reset_;								        //i-1	global reset signal 		         

//============Signals from Read FIFOs ==================
output	reg 	rden_rf				;		        //o-1	read enable of data FIFO 
output	reg 	rden_rcf			;		        //o-1	read enable of rdcnt FIFO

//============Signals from Read FIFOs ==================	
input		rdempty_rf 					;	        //i-1	Empty signal of data FIFO	 
input		rdempty_rcf					;	        //i-1	Empty signal of rdcnt FIFO	
input		[DATA_WIDTH - 1:0]	dataout_rf	;	    //i-256	Dataout of data FIFO		   
input		[BCNT_WIDTH - 1:0]	dataout_rcf	;	    //i-64	Dataout of rdcnt FIFO		   

//=============Signals to AXIS Master ============	
output	reg [DATA_WIDTH - 1:0]rx_axis_mac_tdata	;   //o-256 	 data signal of bridge module                                 
output  reg  rx_axis_mac_tvalid  	;		        //o-1 	 signal to AXIS master indicating the data is valid            
output  reg  rx_axis_mac_tlast		;		        //o-1 	 signal to AXIS Master saying end of data                      
output  reg  rx_axis_mac_tuser		;		        //o-1 	 error signal from FMAC                                        
output  reg  rx_axis_filter_tuser	;		        //o-1 	 error signal from filter of FMAC                              
output  reg [STRB_WIDTH - 1: 0] rx_axis_mac_tstrb;  //o-32 	 Signal indicating valid bytes inside the qword transmitting   
output  reg [28 - 1:0]  rx_statistics_vector;       //o-27 	 information about current frame                              
output  reg  rx_statistics_valid	;		        //o-1	 Signal indication the statistics vector is valid               

//=============Signals from AXIS Master ============    
input		rx_axis_mac_tready		;		        //i-1	signal indicating that AXIS master accepted data
input       rx_axis_compatible_mode;    	        //i-1    signal to keep tready always one

output		test 	;						        //o-1, debug
								
		

	parameter [5:0] 
	AR_IDLE		= 	6'h1,	                        //idle state                       
	AR_WAIT    	= 	6'h2, 	                        //wait for transfer to get complete
	AR_READCNT	= 	6'h4, 	                        //read rdcount state               
	AR_RDDATA	= 	6'h8,	                        //read data state                  
	AR_DONE		= 	6'h16	                        //done  state                      
	;
					  
	wire 						ar_idle_st ;
	wire 						ar_wait_st ;
	wire 						ar_readcnt_st ;
	wire 						ar_rddata_st ;
	wire 						ar_done_st ;
		        				
	reg 	[5:0] 				ar_state;
	
	reg 	[15:0] 				chckcnt, prev_chckcnt ; 
	reg 	[1:0] 				rd_st_cnt;
	reg                        rden_rcf_delay,rden_rf_delay,rden_rf_delay2 , rx_axis_mac_tlast_delay, rx_axis_mac_tlast_delay2,rx_axis_mac_tready_tmp ;
	reg    [STRB_WIDTH-1 :0]            rx_axis_mac_tstrb_delay3, rx_axis_mac_tstrb_delay2, rx_axis_mac_tstrb_delay;
	reg    [2:0]               waitcnt;
	
	assign 			ar_idle_st    	= 	ar_state[0];
	assign 			ar_wait_st   	= 	ar_state[1];
	assign 			ar_readcnt_st 	= 	ar_state[2];
	assign 			ar_rddata_st  	= 	ar_state[3];
	assign 			ar_done_st    	= 	ar_state[4]; 	
	

	assign	test = 1'b0;
			
	                    
always @(posedge rx_mac_aclk)
		if (!reset_ )
		begin
			rden_rcf <= 1'b0;
			rden_rcf_delay <= 1'b0;
			chckcnt <= 16'd00;
			prev_chckcnt <= 16'd00;
			 
                  
	       rx_axis_mac_tdata        	<=	256'h0 ;		//o-64	data signal of bridge module                              	
           rx_axis_mac_tvalid           <=   1'b0;          //o-1	signal to AXIS master indicating the data is valid         
           rx_axis_mac_tlast            <=    1'b0;         //o-1	signal to AXIS Master saying end of data                   
           rx_axis_mac_tuser            <=   1'b0;          //o-1	error signal from FMAC                                     
           rx_axis_filter_tuser         <=  1'b0;           //o-1	error signal from filter of FMAC                           
           rx_axis_mac_tstrb            <=  32'h0;          //o-8	Signal indicating valid bytes inside the qword transmitting 
           rx_axis_mac_tstrb_delay3     <=  32'h0;                                                                           
           rx_axis_mac_tstrb_delay2     <=  32'h0;          //o-8                                                             
           rx_axis_mac_tstrb_delay      <=  32'h0;          //o-8                                                             
           rx_statistics_vector         <=  28'h0;          //o-27	information about current frame                           
           rx_statistics_valid          <= 1'b0;                                                                             
	       rd_st_cnt                    <= 2'b0;            // count for changing read count state                           
           rden_rf                      <= 1'b0;                                                                             
	       rden_rf_delay                <= 1'b0;                                                                             
	       rden_rf_delay2               <= 1'b0;                                                                             
	       waitcnt                      <= 3'b000;          // count for remaining in wait state                             
	       rx_axis_mac_tlast_delay      <= 1'b0;
	       rx_axis_mac_tlast_delay2     <= 1'b0;
	       rx_axis_mac_tready_tmp       <= 1'b0; 
	       
		end
		
		else
		begin 
		
		rx_axis_mac_tready_tmp <= (rx_axis_compatible_mode) ? 1'b1 :   // if mode = 1, tready is always 1
		                          rx_axis_mac_tready
		                          ;
		
		
		
			rden_rcf <= ( ar_idle_st & (!rdempty_rf & !rdempty_rcf ) ) ? 1'b1 :       // enable byte cnt read
            			1'b0  
						;
			rden_rcf_delay <= rden_rcf ;
	
             chckcnt <= ( rden_rcf_delay )  								      ?   dataout_rcf[31:16] :		 // read byte cnt 
                               ( ar_rddata_st &  rx_axis_mac_tready_tmp & (16'h00 < chckcnt) & (chckcnt <= 16'h20) )? 16'h00	:    
                               ( ar_rddata_st &  rx_axis_mac_tready_tmp & (chckcnt > 16'h20) )  ?   chckcnt - 16'h20 :           // if read st and master ready and 8bit mode off, reduce count by 8  
                                 chckcnt 
                                ;
              
            rx_axis_mac_tdata <= (rden_rf_delay  & rx_axis_mac_tready_tmp) ? dataout_rf :   //When tready is high  (Normal mode)
                                rx_axis_mac_tdata
                                ;         
                              
			prev_chckcnt <= chckcnt;		    
			rd_st_cnt <= (ar_readcnt_st) ? rd_st_cnt + 1'b1 :            // if in read_cnt_st, increment by 1; if not then zero (read state count)
                         2'b0
                         ;
                         
            rden_rf <= (( ar_rddata_st) & (chckcnt == 16'h00) & (prev_chckcnt > 16'h00) & (prev_chckcnt <= 16'h20)) ? 1'b0 :    // enable data read
            			( ar_rddata_st  ) ? 1'b1 :
                        1'b0  
                        ;               
 	
             rden_rf_delay <= rden_rf ;           // delay signals for read enable
             rden_rf_delay2 <=   rden_rf_delay;   // delay signals for read enable
 	   
 	   
		   rx_axis_mac_tvalid <= 
		   		                 rx_axis_mac_tvalid & rx_axis_mac_tlast ? 1'b0 :
		   		                 !rx_axis_mac_tvalid & ( rx_axis_mac_tstrb_delay2 != 32'h00000000    ) ? 1'b1 :       // generate the valid with read delay as data comes 1 clock later       
		   						 rx_axis_mac_tvalid  
								 ;
								 						 
	        rx_axis_mac_tstrb_delay3  <= (chckcnt == 16'h00) ? 32'h00000000 :               // Strobe generation
										(chckcnt >= 16'h20) ? 32'hffffffff :
										(chckcnt >= 16'h18) ? 
										{((chckcnt == 16'h1f) ? 8'h7f :
										  (chckcnt == 16'h1e) ? 8'h3f :
										  (chckcnt == 16'h1d) ? 8'h1f :
										  (chckcnt == 16'h1c) ? 8'h0f :
										  (chckcnt == 16'h1b) ? 8'h07 :
										  (chckcnt == 16'h1a) ? 8'h03 :
										  (chckcnt == 16'h19) ? 8'h01 :
										  (chckcnt == 16'h18) ? 8'h00 :
										  rx_axis_mac_tstrb[31:24]),24'hffffff} :
										(chckcnt >= 16'h10) ?
										{8'h00,
										  ((chckcnt == 16'h17) ? 8'h7f :
										   (chckcnt == 16'h16) ? 8'h3f :
										   (chckcnt == 16'h15) ? 8'h1f :
										   (chckcnt == 16'h14) ? 8'h0f :
										   (chckcnt == 16'h13) ? 8'h07 :
										   (chckcnt == 16'h12) ? 8'h03 :
										   (chckcnt == 16'h11) ? 8'h01 :
										   (chckcnt == 16'h10) ? 8'h00 :
										   rx_axis_mac_tstrb[23:16]),16'hffff} :
										(chckcnt >= 16'h08) ?
										{16'h00,
										  ((chckcnt == 16'h0f) ? 8'h7f :
										   (chckcnt == 16'h0e) ? 8'h3f :
										   (chckcnt == 16'h0d) ? 8'h1f :
										   (chckcnt == 16'h0c) ? 8'h0f :
										   (chckcnt == 16'h0b) ? 8'h07 :
										   (chckcnt == 16'h0a) ? 8'h03 :
										   (chckcnt == 16'h09) ? 8'h01 :
										   (chckcnt == 16'h08) ? 8'h00 :
										   rx_axis_mac_tstrb[15:8]),8'hff} :
										(chckcnt > 16'h00) ?
										{24'h00,
										  ((chckcnt == 16'h07) ? 8'h7f :
										   (chckcnt == 16'h06) ? 8'h3f :
										   (chckcnt == 16'h05) ? 8'h1f :
										   (chckcnt == 16'h04) ? 8'h0f :
										   (chckcnt == 16'h03) ? 8'h07 :
										   (chckcnt == 16'h02) ? 8'h03 :
										   (chckcnt == 16'h01) ? 8'h01 :
										   rx_axis_mac_tstrb[7:0])} :
										rx_axis_mac_tstrb_delay3;
	         
	        rx_axis_mac_tstrb_delay2 <= rx_axis_mac_tstrb_delay3;                   
	        rx_axis_mac_tstrb       <=  rx_axis_mac_tstrb_delay2;
	       
	       
	       waitcnt <= (ar_rddata_st) ? 3'b000:                                // if in wait count state, increment by 1
	                   (ar_wait_st) ?  waitcnt + 3'b001:
	                   waitcnt
	                   ;                          
		
    	
    	rx_axis_mac_tlast   <= 
    		                   rx_axis_mac_tlast ? 1'b0 :
    		                   !rx_axis_mac_tlast & rx_axis_mac_tlast_delay2 ;
                               
           rx_axis_mac_tlast_delay2  <=  rx_axis_mac_tlast_delay ;
           rx_axis_mac_tlast_delay <=  ( ( (chckcnt < 16'h20) | (chckcnt == 16'h20) ) & ar_rddata_st ) ? 1'b1 :
                                       1'b0
                                       ;                  
                               		
		end 
	
	
	
	
always @(posedge rx_mac_aclk)
		if (!reset_ )             // if reset then go into idle state
			ar_state <= AR_IDLE ;	
		else
			begin
			
			if(ar_idle_st)           // wait in idle state till the Read FIFOs are empty
				ar_state <= 
				(!rdempty_rf & !rdempty_rcf ) ? AR_READCNT :       // if not empty , get read count, go to read data state
				AR_IDLE
				;
			
			if(ar_readcnt_st)       // read byte count and make a copy, go in next state
               ar_state <= (rd_st_cnt==2'b01) ? AR_RDDATA  :      // wait till read state sount is 2; 2 indicates the read data has been written successfully
               AR_READCNT
               ;	
               
			if(ar_rddata_st)        // get data in this state
				ar_state <=
				((chckcnt == 16'h00)  ) ? AR_IDLE :
			    AR_RDDATA
				;
end 
	
	    //Simulation Only
        //synopsys translate_off
            
        reg [8*8-1:0] ascii_ar_state;
        
        always@(ar_state)
        begin
            case(ar_state)
            AR_IDLE:          ascii_ar_state 	= 	"AR_IDLE";
            AR_WAIT   :       ascii_ar_state 	= 	"AR_WAIT";
            AR_READCNT:       ascii_ar_state 	= 	"AR_READCNT";
            AR_RDDATA:        ascii_ar_state 	= 	"AR_RDDATA";
            AR_DONE:          ascii_ar_state 	= 	"AR_DONE";
            endcase
        end
        
        //synopsys translate_on        
		
endmodule 
