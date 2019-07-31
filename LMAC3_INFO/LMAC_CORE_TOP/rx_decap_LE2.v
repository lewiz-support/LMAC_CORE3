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

// synopsys translate_off
`timescale 1ns/1ps
// synopsys translate_on

module rx_decap(
	clk250,					// i-1
	clk156,					// i-1
	rst_,					// i-1
                        	
	full,					// i-1
	usedw,					// i-12
			            	
	rx_check_crc,			// i-1, enabling checking of CRC
	                    	
	fmac_ctrl1_dly	,		//i-32
	fmac_rxd_en	,			//i-1
	

	FMAC_RX_CRC_ERR_CNT,			// o-32
	FMAC_RX_UNDERSIZE_PKT_CNT,		// o-32
	FMAC_RX_PKT_CNT_LO,				// o-32
	FMAC_RX_PKT_CNT_HI,				// o-32
	FMAC_RX_BYTE_CNT_LO,			// o-32
	FMAC_RX_BYTE_CNT_HI,			// o-32
	
	FMAC_PKT_CNT_JABBER,			// o-32
	FMAC_PKT_CNT_FRAGMENT,			// o-32

	//Interface to 64 bit Statistic register group, in DECAP
	STAT_GROUP_LO_DOUT	,			// o-32
	STAT_GROUP_HI_DOUT	,			// o-32
	STAT_GROUP_addr	,				// i-10,  address to select the register within the STAT GROUP
	STAT_GROUP_sel	,				//i-1
	fmac_rx_clr_en	,				//i-1
	
	wptr,							// i-param
	rdata,							// i-256
	
	add_lo_bcast,					// i-1, these signals are 250Mhz pre-synced
	add_lo_mcast,					// i-1
	clr_carry_cast,					// i-1 clr the carry of the B/Mcast group
	add_hi_cast,					// i-1 add the HI reg of the B/Mcast group
	
	clr_pkt_cnt_oversize,			//o-1
	
	tx_xo_en,						// i-1 From Register
	xdone,							// o-1
	
	FMAC_RX_PKT_CNT64_LO,		
	FMAC_RX_PKT_CNT64_HI,		
	                            
	FMAC_RX_PKT_CNT127_LO,		
	FMAC_RX_PKT_CNT127_HI,		
	                            
	FMAC_RX_PKT_CNT255_LO,		
	FMAC_RX_PKT_CNT255_HI,		
	                            
	FMAC_RX_PKT_CNT511_LO,		
	FMAC_RX_PKT_CNT511_HI,		
	                            
	FMAC_RX_PKT_CNT1023_LO,		
	FMAC_RX_PKT_CNT1023_HI,		
	                            
	FMAC_RX_PKT_CNT1518_LO,		
	FMAC_RX_PKT_CNT1518_HI,		
	                            
	FMAC_RX_PKT_CNT2047_LO,		
	FMAC_RX_PKT_CNT2047_HI,		
	                            
	FMAC_RX_PKT_CNT4095_LO,		
	FMAC_RX_PKT_CNT4095_HI,		
	                            
	FMAC_RX_PKT_CNT8191_LO,		
	FMAC_RX_PKT_CNT8191_HI,		
	                            
	FMAC_RX_PKT_CNT9018_LO,		
	FMAC_RX_PKT_CNT9018_HI,		
	                            
	FMAC_RX_PKT_CNT9022_LO,		
	FMAC_RX_PKT_CNT9022_HI,		
	                            
	FMAC_RX_PKT_CNT9199P_LO,	
	FMAC_RX_PKT_CNT9199P_HI,	
	                            
	nbyte,						
	pkt_done,					
	crc_chk,					
	crc32,						
	crc32_vld_,					
	                    		
	crc_ok						
			
		
	);

parameter   FMAC_ID = 10;
parameter	RX_FIFO_DEPTH = 13'd4096;		
parameter	RX_FIFO_ADDR_WIDTH = 12;	
parameter	RX_DRAM_DEPTH = 13'd3072;
parameter	RX_DRAM_ADDR_WIDTH = 12;

//--
parameter	DATA_WIDTH	=	256;
//--

input clk250;	
input clk156;	
input rst_;

	


 // FIFO interface
input 	full;
input 	[RX_FIFO_ADDR_WIDTH-1:0] usedw;

 // From Register
input	rx_check_crc;

input	[31:0]	fmac_ctrl1_dly;
input			fmac_rxd_en	;		   //i-1


// To fmac_register_if
output [31:0]	FMAC_RX_UNDERSIZE_PKT_CNT;
output [31:0]	FMAC_RX_CRC_ERR_CNT;	
output [31:0]	FMAC_RX_PKT_CNT_LO;		
output [31:0]	FMAC_RX_PKT_CNT_HI;		
output [31:0]	FMAC_RX_BYTE_CNT_LO;	
output [31:0]	FMAC_RX_BYTE_CNT_HI;	

output [31:0]	FMAC_PKT_CNT_JABBER;			 // o-32
output [31:0]	FMAC_PKT_CNT_FRAGMENT;			 // o-32

//Interface to 64 bit Statistic register group, in DECAP
output [31:0]		STAT_GROUP_LO_DOUT	;		// o-32,
output [31:0]		STAT_GROUP_HI_DOUT	;		// o-32,
input	[9:0]		STAT_GROUP_addr	;			// i-10, address to select the register within the STAT GROUP
input				STAT_GROUP_sel	;	
input				fmac_rx_clr_en	;	
	
input  [RX_DRAM_ADDR_WIDTH:0] 		wptr;	

//--
input  [DATA_WIDTH - 1:0] 	rdata;				//data reading in from the front end's DRAM buffer
//--

input	add_lo_bcast	;						// i-1, these signals are 250Mhz pre-synced	
input	add_lo_mcast	;						// i-1
input	clr_carry_cast	;						// i-1 clr the carry of the B/Mcast group
input	add_hi_cast		;						// i-1 add the HI reg of the B/Mcast group

output	clr_pkt_cnt_oversize	;

input			tx_xo_en;
input			xdone;							// pause frame has been transmitted


output [32:0]	FMAC_RX_PKT_CNT64_LO;	
output [31:0]	FMAC_RX_PKT_CNT64_HI;	

output [32:0]	FMAC_RX_PKT_CNT127_LO;	
output [31:0]	FMAC_RX_PKT_CNT127_HI;	

output [32:0]	FMAC_RX_PKT_CNT255_LO;	
output [31:0]	FMAC_RX_PKT_CNT255_HI;	

output [32:0]	FMAC_RX_PKT_CNT511_LO;	
output [31:0]	FMAC_RX_PKT_CNT511_HI;	

output [32:0]	FMAC_RX_PKT_CNT1023_LO;	
output [31:0]	FMAC_RX_PKT_CNT1023_HI;	

output [32:0]	FMAC_RX_PKT_CNT1518_LO;	
output [31:0]	FMAC_RX_PKT_CNT1518_HI;	

output [32:0]	FMAC_RX_PKT_CNT2047_LO;	
output [31:0]	FMAC_RX_PKT_CNT2047_HI;	

output [32:0]	FMAC_RX_PKT_CNT4095_LO;	
output [31:0]	FMAC_RX_PKT_CNT4095_HI;	

output [32:0]	FMAC_RX_PKT_CNT8191_LO;	
output [31:0]	FMAC_RX_PKT_CNT8191_HI;	

output [32:0]	FMAC_RX_PKT_CNT9018_LO;	
output [31:0]	FMAC_RX_PKT_CNT9018_HI;	

output [32:0]	FMAC_RX_PKT_CNT9022_LO;	
output [31:0]	FMAC_RX_PKT_CNT9022_HI;	

output [32:0]	FMAC_RX_PKT_CNT9199P_LO;
output [31:0]	FMAC_RX_PKT_CNT9199P_HI;

input  [31:0]	crc_chk;	

input  [31:0]	crc32;		
input  			crc32_vld_;	


input			crc_ok;		

reg		[13:0]	MAX_PKT_SIZE;

input [15:0] nbyte;	

wire	bad_crc;	
assign	bad_crc = (crc_chk != crc32) ;

reg [31:0]	FMAC_RX_CRC_ERR_CNT;	
reg [31:0]	FMAC_RX_UNDERSIZE_PKT_CNT;

reg [31:0]	FMAC_PKT_CNT_JABBER;	
reg [31:0]	FMAC_PKT_CNT_FRAGMENT;	
	reg 	[32:0]	RX_BYTE_CNT_LO;	
reg 	[31:0]	RX_BYTE_CNT_HI;		

reg 	[32:0]	RX_PKT_CNT_LO;		
reg 	[31:0]	RX_PKT_CNT_HI;		

wire	[31:0]	FMAC_RX_BYTE_CNT_LO = RX_BYTE_CNT_LO[31:0];
wire	[31:0]	FMAC_RX_BYTE_CNT_HI = RX_BYTE_CNT_HI[31:0];

wire	[31:0]	FMAC_RX_PKT_CNT_LO = RX_PKT_CNT_LO[31:0];
wire	[31:0]	FMAC_RX_PKT_CNT_HI = RX_PKT_CNT_HI[31:0];

reg [32:0]	FMAC_RX_PKT_CNT64_LO;	
reg [31:0]	FMAC_RX_PKT_CNT64_HI;	

reg [32:0]	FMAC_RX_PKT_CNT127_LO;	
reg [31:0]	FMAC_RX_PKT_CNT127_HI;	

reg [32:0]	FMAC_RX_PKT_CNT255_LO;	
reg [31:0]	FMAC_RX_PKT_CNT255_HI;	

reg [32:0]	FMAC_RX_PKT_CNT511_LO;	
reg [31:0]	FMAC_RX_PKT_CNT511_HI;	

reg [32:0]	FMAC_RX_PKT_CNT1023_LO;	
reg [31:0]	FMAC_RX_PKT_CNT1023_HI;	

reg [32:0]	FMAC_RX_PKT_CNT1518_LO;	
reg [31:0]	FMAC_RX_PKT_CNT1518_HI;	

reg [32:0]	FMAC_RX_PKT_CNT2047_LO;	
reg [31:0]	FMAC_RX_PKT_CNT2047_HI;	

reg [32:0]	FMAC_RX_PKT_CNT4095_LO;	
reg [31:0]	FMAC_RX_PKT_CNT4095_HI;	

reg [32:0]	FMAC_RX_PKT_CNT8191_LO;	
reg [31:0]	FMAC_RX_PKT_CNT8191_HI;	

reg [32:0]	FMAC_RX_PKT_CNT9018_LO;	
reg [31:0]	FMAC_RX_PKT_CNT9018_HI;	

reg [32:0]	FMAC_RX_PKT_CNT9022_LO;	
reg [31:0]	FMAC_RX_PKT_CNT9022_HI;	

reg [32:0]	FMAC_RX_PKT_CNT9199P_LO;  		 //9199 plus bytes per packet
reg [31:0]	FMAC_RX_PKT_CNT9199P_HI;

reg [32:0]	FMAC_RX_PKT_CNT_BCAST_LO;  		 //broadcast packet
reg [31:0]	FMAC_RX_PKT_CNT_BCAST_HI;

reg [32:0]	FMAC_RX_PKT_CNT_MCAST_LO;  		 //multicast packet
reg [31:0]	FMAC_RX_PKT_CNT_MCAST_HI;
reg [31:0]	pkt_undersize;	

input		pkt_done;		
reg			pkt_done_dly1;	
reg			pkt_done_dly2;	

reg			statistic_ok;	

reg [31:0] 	rx_err_cnt;		
reg 		increase_err_cnt;
wire		rx_err_cnt_ok;	

always@ (posedge clk250)
begin
	if (!rst_)
	begin
		pkt_done_dly1 <=	1'b0;
		pkt_done_dly2 <=	1'b0;
		
		pkt_undersize <= 32'h0;
				
		increase_err_cnt	<=	1'b0;
		rx_err_cnt			<=	32'h0;
	end
	
	else
	begin
		pkt_done_dly1 	<= 	pkt_done;
		pkt_done_dly2 	<= 	pkt_done_dly1;
		
		//undersize are pkt size < 64 bytes including the CRC.  NBYTE excluded the CRC
		pkt_undersize 	<= (pkt_done & (nbyte < 16'd60))? (pkt_undersize + 32'h1) : pkt_undersize; 
		
		increase_err_cnt	<=	(crc32_vld_? (bad_crc ? 1'b1 : 1'b0): 1'b0);
		
		rx_err_cnt			<=	increase_err_cnt? (rx_err_cnt + 32'h1) : rx_err_cnt;
	end
end

//SYNC the reg for output to internal logic
reg		err_cnt_ok0_clk250;				
reg		err_cnt_ok1_clk250;				

wire	err_cnt_ok_clk250 = err_cnt_ok0_clk250 & err_cnt_ok1_clk250;

reg			sync_wait;		
reg			sync_wait_crc;	

wire		crc_ok;			
reg			crc_ok_dly1;	
reg			crc_ok_dly2;	
reg			crc_ok_dly3;	
reg			crc_ok_dly4;	



always @ (posedge clk250)
	begin
	
		
		statistic_ok		<= 
								(!rst_ | statistic_ok) ? 1'b0 :
								(!statistic_ok & pkt_done)  ? 1'b1 :
								statistic_ok;
					
																																	
		crc_ok_dly1		<=	crc_ok	;
		crc_ok_dly2		<=	crc_ok_dly1	;
		crc_ok_dly3		<=	crc_ok_dly2	;
		crc_ok_dly4		<=	crc_ok_dly3	;
					
	err_cnt_ok0_clk250	<= !increase_err_cnt;
	err_cnt_ok1_clk250	<=  err_cnt_ok0_clk250;
	
	
	end

// Synchronization for statistic registers
assign		rx_err_cnt_ok 	= err_cnt_ok_clk250;

//STATISTIC_OK PULSE
reg			stat_ok_dly;
	
reg			stat_ok_dly2;
reg			stat_ok_dly3;
reg			stat_ok_dly4;

always @ (posedge clk250)
begin
	if (!rst_)
	begin
		stat_ok_dly		<=	1'b0;
		stat_ok_dly2	<=	1'b0;
		stat_ok_dly3	<=	1'b0;
		stat_ok_dly4	<=	1'b0;
		
				FMAC_RX_UNDERSIZE_PKT_CNT <= 32'h0;
				
				FMAC_RX_CRC_ERR_CNT <= 32'h0;
	end
	
	else
	begin  
	
		stat_ok_dly	<=	statistic_ok;

				
		stat_ok_dly2	<=	stat_ok_dly;
		stat_ok_dly3	<=	stat_ok_dly2;
		stat_ok_dly4	<=	stat_ok_dly3;
		
		FMAC_RX_UNDERSIZE_PKT_CNT <= fmac_rx_clr_en ? 32'h0 : (statistic_ok? pkt_undersize : FMAC_RX_UNDERSIZE_PKT_CNT);
		
		FMAC_RX_CRC_ERR_CNT <= fmac_rx_clr_en ? 32'h0 : (rx_err_cnt_ok? FMAC_RX_CRC_ERR_CNT : rx_err_cnt);
		
	end
end


always@ (posedge clk250)
	if (!rst_)
		begin
		MAX_PKT_SIZE	<=	14'd1518	;
		end
	else
		begin
		MAX_PKT_SIZE	<=	fmac_ctrl1_dly[13:0]	;

end


reg	[31:0]		STAT_GROUP_LO_DOUT;
reg	[31:0]		STAT_GROUP_HI_DOUT;
                                   
//local info for tracking various counts
reg				pkt_rcv_jabber 	;
reg				pkt_rcv_fragment ;
                                   
reg				pkt_rcv64 	; 	
reg				pkt_rcv127 	; 	
reg				pkt_rcv255 	; 	
reg				pkt_rcv511 	; 	
reg				pkt_rcv1023 ; 	
reg				pkt_rcv1518 ; 	
		                           
reg				pkt_rcv2047  ; 	
reg				pkt_rcv4095  ; 	
reg				pkt_rcv8191  ; 	
reg				pkt_rcv9018  ; 	
reg				pkt_rcv9022  ; 	
reg				pkt_rcv9199p ;	
                                   
//single bit synced selects
reg     SYNC_PKT_CNT_SEL   ;	
reg		SYNC_BYTE_CNT_SEL  ;	
reg		SYNC_PKT_CNT_OVERSIZE_SEL	;

reg     SYNC_PKT_CNT_JABBER_SEL ;	
reg     SYNC_PKT_CNT_FRAGMENT_SEL;	

reg     SYNC_SEL64 	       ;		
reg		SYNC_SEL127 	   ;		
reg		SYNC_SEL255 	   ;		
reg		SYNC_SEL511 	   ;		
reg		SYNC_SEL1023       ;		
reg		SYNC_SEL1518       ;		
		                        	
reg		SYNC_SEL2047       ;		
reg		SYNC_SEL4095       ;		
reg		SYNC_SEL8191       ;		
reg		SYNC_SEL9018       ;		
reg		SYNC_SEL9022       ;		
reg		SYNC_SEL9199P      ;		
		                 
reg		SYNC_SEL_BCAST     ;
reg		SYNC_SEL_MCAST     ;


//signal used to allow the 156MHz signal to pass completely before adding again
reg		sync_wait_dly		;		
                                    
                                    
reg		[15:0]		sync_nbyte;		
reg					sync_pkt_done;	


parameter	[9:0]
		RX_PKT_CNT_ADDR     =	10'h0_28,		
		RX_BYTE_CNT_ADDR	=	10'h0_38,		
		
		PKT_CNT_OVERSIZE_ADDR	=	10'h0_60,	
		
			//new regs in the REGULAR group
		PKT_CNT_JABBER_ADDR		=	10'h0_78,	
		PKT_CNT_FRAGMENT_ADDR	=	10'h0_80,	
		
		PKT_RCV_ADDR64 		=	10'h0_00,		
		PKT_RCV_ADDR127 	=	10'h0_08,		
		PKT_RCV_ADDR255 	=	10'h0_10,		
		PKT_RCV_ADDR511 	=	10'h0_18,		
		PKT_RCV_ADDR1023 	=	10'h0_20,		
		PKT_RCV_ADDR1518 	=	10'h0_28,		
		        
		PKT_RCV_ADDR2047  	=	10'h0_30, 		
		PKT_RCV_ADDR4095  	=	10'h0_38, 		
		PKT_RCV_ADDR8191  	=	10'h0_40, 		
		PKT_RCV_ADDR9018  	=	10'h0_48, 		
		PKT_RCV_ADDR9022  	=	10'h0_50, 		
		PKT_RCV_ADDR9199P 	=	10'h0_58,	 //9199 plus bytes
		
		PKT_RCV_ADDR_BCAST 	=	10'h0_60,	   //broadcast
		PKT_RCV_ADDR_MCAST 	=	10'h0_68	   //multicast
		
		;	

		//regular group
wire		RX_PKT_CNT_SEL			=	(STAT_GROUP_addr[9:3] == RX_PKT_CNT_ADDR[9:3]  );	
wire		RX_BYTE_CNT_SEL			=	(STAT_GROUP_addr[9:3] == RX_BYTE_CNT_ADDR[9:3]  );	

wire		PKT_CNT_OVERSIZE_SEL	=	(STAT_GROUP_addr[9:3] == PKT_CNT_OVERSIZE_ADDR[9:3]  );

wire		PKT_CNT_JABBER_SEL		=	(STAT_GROUP_addr[9:3] == PKT_CNT_JABBER_ADDR[9:3]  );	
wire		PKT_CNT_FRAGMENT_SEL	=	(STAT_GROUP_addr[9:3] == PKT_CNT_FRAGMENT_ADDR[9:3]  );	

		//STAT GROUP
wire		PKT_RCV_SEL64 		=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR64[9:3]  );
wire		PKT_RCV_SEL127 		=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR127[9:3] );
wire		PKT_RCV_SEL255 		=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR255[9:3] );
wire		PKT_RCV_SEL511 		=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR511[9:3] );
wire		PKT_RCV_SEL1023 	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR1023[9:3]);
wire		PKT_RCV_SEL1518 	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR1518[9:3]);
		                                            
wire		PKT_RCV_SEL2047  	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR2047[9:3]);
wire		PKT_RCV_SEL4095  	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR4095[9:3]);
wire		PKT_RCV_SEL8191  	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR8191[9:3]);
wire		PKT_RCV_SEL9018  	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR9018[9:3]);
wire		PKT_RCV_SEL9022  	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR9022[9:3]);
wire		PKT_RCV_SEL9199P 	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR9199P[9:3]);
                                                    
wire		PKT_RCV_SEL_BCAST  	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR_BCAST[9:3]);	
wire		PKT_RCV_SEL_MCAST 	=	(STAT_GROUP_addr[9:3] == PKT_RCV_ADDR_MCAST[9:3]);


		
reg		DLY_PKT_RCV_SEL64 		;	
reg		DLY_PKT_RCV_SEL127 		;	
reg		DLY_PKT_RCV_SEL255 		;	
reg		DLY_PKT_RCV_SEL511 		;	
reg		DLY_PKT_RCV_SEL1023 	;	
reg		DLY_PKT_RCV_SEL1518 	;	
	                                            
reg		DLY_PKT_RCV_SEL2047  	;		
reg		DLY_PKT_RCV_SEL4095  	;		
reg		DLY_PKT_RCV_SEL8191  	;		
reg		DLY_PKT_RCV_SEL9018  	;		
reg		DLY_PKT_RCV_SEL9022  	;		
reg		DLY_PKT_RCV_SEL9199P 	;	
                                                
reg		DLY_PKT_RCV_SEL_BCAST  	;		
reg		DLY_PKT_RCV_SEL_MCAST 	;	

//USED FOR READING
always @(posedge clk250)
	begin
		
		DLY_PKT_RCV_SEL64 		<= (!rst_) ? 1'b0 : PKT_RCV_SEL64 	 ;	
		DLY_PKT_RCV_SEL127 		<= (!rst_) ? 1'b0 : PKT_RCV_SEL127 	 ;	
		DLY_PKT_RCV_SEL255 		<= (!rst_) ? 1'b0 : PKT_RCV_SEL255 	 ;	
		DLY_PKT_RCV_SEL511 		<= (!rst_) ? 1'b0 : PKT_RCV_SEL511 	 ;	
		DLY_PKT_RCV_SEL1023 	<= (!rst_) ? 1'b0 : PKT_RCV_SEL1023  ;	
		DLY_PKT_RCV_SEL1518 	<= (!rst_) ? 1'b0 : PKT_RCV_SEL1518  ;	
	                                                                 
		DLY_PKT_RCV_SEL2047  	<= (!rst_) ? 1'b0 : PKT_RCV_SEL2047  ;		
		DLY_PKT_RCV_SEL4095  	<= (!rst_) ? 1'b0 : PKT_RCV_SEL4095  ;		
		DLY_PKT_RCV_SEL8191  	<= (!rst_) ? 1'b0 : PKT_RCV_SEL8191  ;		
		DLY_PKT_RCV_SEL9018  	<= (!rst_) ? 1'b0 : PKT_RCV_SEL9018  ;		
		DLY_PKT_RCV_SEL9022  	<= (!rst_) ? 1'b0 : PKT_RCV_SEL9022  ;		
		DLY_PKT_RCV_SEL9199P 	<= (!rst_) ? 1'b0 : PKT_RCV_SEL9199P ;	
                                                
		DLY_PKT_RCV_SEL_BCAST  	<= (!rst_) ? 1'b0 : PKT_RCV_SEL_BCAST;		
		DLY_PKT_RCV_SEL_MCAST 	<= (!rst_) ? 1'b0 : PKT_RCV_SEL_MCAST;	
	
	end

//sync the select signal for better timing and gate more infor for clr
always @(posedge clk250)
	if (!rst_)
		begin
		
        SYNC_PKT_CNT_SEL   <=	1'b0;
		SYNC_BYTE_CNT_SEL  <=	1'b0;
		
		SYNC_PKT_CNT_OVERSIZE_SEL	<= 1'b0;
		
		SYNC_PKT_CNT_JABBER_SEL		<= 1'b0;
		SYNC_PKT_CNT_FRAGMENT_SEL	<= 1'b0;
		
		SYNC_SEL64 	       <=	1'b0;
		SYNC_SEL127 	   <=	1'b0;
		SYNC_SEL255 	   <=	1'b0;
		SYNC_SEL511 	   <=	1'b0;
		SYNC_SEL1023       <=	1'b0;
		SYNC_SEL1518       <=	1'b0;
		                 
		SYNC_SEL2047       <=	1'b0;
		SYNC_SEL4095       <=	1'b0;
		SYNC_SEL8191       <=	1'b0;
		SYNC_SEL9018       <=	1'b0;
		SYNC_SEL9022       <=	1'b0;
		SYNC_SEL9199P      <=	1'b0;
		                 
		SYNC_SEL_BCAST     <=	1'b0;
		SYNC_SEL_MCAST     <=	1'b0;
		end
	else
		begin
		SYNC_PKT_CNT_SEL   <=	RX_PKT_CNT_SEL  & !STAT_GROUP_sel;
		SYNC_BYTE_CNT_SEL  <=	RX_BYTE_CNT_SEL & !STAT_GROUP_sel;
		
		SYNC_PKT_CNT_OVERSIZE_SEL  <=	PKT_CNT_OVERSIZE_SEL 	& !STAT_GROUP_sel;
		
		SYNC_PKT_CNT_JABBER_SEL  	<=	PKT_CNT_JABBER_SEL 		& !STAT_GROUP_sel;
		SYNC_PKT_CNT_FRAGMENT_SEL  	<=	PKT_CNT_FRAGMENT_SEL 	& !STAT_GROUP_sel;
		
			//stat group
		SYNC_SEL64 	       <=	PKT_RCV_SEL64 	  & STAT_GROUP_sel;
		SYNC_SEL127 	   <=	PKT_RCV_SEL127 	  & STAT_GROUP_sel;
		SYNC_SEL255 	   <=	PKT_RCV_SEL255 	  & STAT_GROUP_sel;
		SYNC_SEL511 	   <=	PKT_RCV_SEL511 	  & STAT_GROUP_sel;
		SYNC_SEL1023       <=	PKT_RCV_SEL1023   & STAT_GROUP_sel;
		SYNC_SEL1518       <=	PKT_RCV_SEL1518   & STAT_GROUP_sel;
		                                       
		SYNC_SEL2047       <=	PKT_RCV_SEL2047   & STAT_GROUP_sel;
		SYNC_SEL4095       <=	PKT_RCV_SEL4095   & STAT_GROUP_sel;
		SYNC_SEL8191       <=	PKT_RCV_SEL8191   & STAT_GROUP_sel;
		SYNC_SEL9018       <=	PKT_RCV_SEL9018   & STAT_GROUP_sel;
		SYNC_SEL9022       <=	PKT_RCV_SEL9022   & STAT_GROUP_sel;
		SYNC_SEL9199P      <=	PKT_RCV_SEL9199P  & STAT_GROUP_sel;
		                                       
		SYNC_SEL_BCAST     <=	PKT_RCV_SEL_BCAST & STAT_GROUP_sel;
		SYNC_SEL_MCAST     <=	PKT_RCV_SEL_MCAST & STAT_GROUP_sel;
		end
	
		
//=========== tracking the reg value of various packet sizes =============
wire		pkt_size_jabber	;		
wire		pkt_size_fragment	;	

wire		pkt_size64 	 	; 		
wire		pkt_size127  	; 		
wire		pkt_size255  	;  		
wire		pkt_size511  	;  		
wire		pkt_size1023 	;  		
wire		pkt_size1518 	;  		
		                       		
wire		pkt_size2047  	; 		
wire		pkt_size4095  	; 		
wire		pkt_size8191  	; 		
wire		pkt_size9018  	; 		
wire		pkt_size9022  	; 		
wire		pkt_size9199p 	; 		


assign		pkt_size_jabber 	 	=	pkt_done	?	(nbyte > MAX_PKT_SIZE	?	1'b1	: 1'b0)	:	1'b0;
assign		pkt_size_fragment 	 	=	pkt_done	?	(nbyte < 14'd64			?	1'b1	: 1'b0)	:	1'b0;
assign		pkt_size64 	 	=	(nbyte == 16'd64);							
assign		pkt_size127  	=	(nbyte > 16'd64    ) & (nbyte < 16'd128);
assign		pkt_size255  	=	(nbyte >= 16'd128  ) & (nbyte < 16'd256 );
assign		pkt_size511  	=	(nbyte >= 16'd256  ) & (nbyte < 16'd512 );
assign		pkt_size1023 	=	(nbyte >= 16'd512  ) & (nbyte < 16'd1024 );
assign		pkt_size1518 	=	(nbyte >= 16'd1024 ) & (nbyte <= 16'd1518 );
		        
assign		pkt_size2047  	=	(nbyte >= 16'd1519 ) & (nbyte < 16'd2048 ); 		
assign		pkt_size4095  	=	(nbyte >= 16'd2048 ) & (nbyte < 16'd4096 ); 		
assign		pkt_size8191  	=	(nbyte >= 16'd4096 ) & (nbyte < 16'd8192 ); 		
assign		pkt_size9018  	=	(nbyte >= 16'd8192 ) & (nbyte <= 16'd9018 ); 		
assign		pkt_size9022  	=	(nbyte >= 16'd9019 ) & (nbyte <= 16'd9022 ); 		
assign		pkt_size9199p 	=	(nbyte > 16'd9199 );		

always@ (posedge clk250)       
begin
	if (!rst_)
		begin
		pkt_rcv64 	<=	1'b0;
		pkt_rcv127 	<=	1'b0;
		pkt_rcv255 	<=	1'b0;
		pkt_rcv511 	<=	1'b0;
		pkt_rcv1023 <=	1'b0;
		pkt_rcv1518 <=	1'b0;
		
		pkt_rcv2047  <=	1'b0; 		
		pkt_rcv4095  <=	1'b0; 		
		pkt_rcv8191  <=	1'b0; 		
		pkt_rcv9018  <=	1'b0; 		
		pkt_rcv9022  <=	1'b0; 		
		pkt_rcv9199p <=	1'b0;		
		
		sync_nbyte		<= 16'h0;
		sync_pkt_done	<= 1'b0;	
		
		pkt_rcv_jabber		<= 1'b0;
		pkt_rcv_fragment	<= 1'b0;
					
		end
	
	else
		begin
								
		
		pkt_rcv64 	<=	(pkt_done & pkt_size64  )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv64 ;
		pkt_rcv127 	<=	(pkt_done & pkt_size127 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv127 ;
		pkt_rcv255 	<=	(pkt_done & pkt_size255 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv255 ;
		pkt_rcv511  <=	(pkt_done & pkt_size511 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv511 ;
		pkt_rcv1023 <=	(pkt_done & pkt_size1023)	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv1023 ;
		pkt_rcv1518 <=	(pkt_done & pkt_size1518)	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv1518 ;
		pkt_rcv2047 <=	(pkt_done & pkt_size2047 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv2047  ;
		pkt_rcv4095 <=	(pkt_done & pkt_size4095 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv4095  ;
		pkt_rcv8191 <=	(pkt_done & pkt_size8191 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv8191  ;
		pkt_rcv9018 <=	(pkt_done & pkt_size9018 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv9018  ;
		pkt_rcv9022 <=	(pkt_done & pkt_size9022 )	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv9022  ;
		pkt_rcv9199p <=	(pkt_done & pkt_size9199p)	? 1'b1 : pkt_done_dly2 ? 1'b0 : pkt_rcv9199p ;
		
						
		//used in tracking total cumulative byte count
		sync_nbyte	<=	
						pkt_done ? nbyte :
						pkt_done_dly2 ? 16'h0 :
						sync_nbyte;
		
		//used in tracking total cumulative number of packets
		sync_pkt_done <=	pkt_done;
		
		//used in tracking JABBER & FRAGMENT packet count
		pkt_rcv_jabber <=
								
						!crc32_vld_ & bad_crc & pkt_size_jabber ? 1'b1 : 1'b0;
								
																
												
		pkt_rcv_fragment <=
								
						!crc32_vld_ & bad_crc & pkt_size_fragment ? 1'b1 : 1'b0;
				
								
												
												
		end
end


    
always@ (posedge clk250)
	if (!rst_)
		begin
		sync_wait				<= 1'b0;
		sync_wait_dly			<= 1'b0;
		
		sync_wait_crc				<= 1'b0;
		
			//regular group
		RX_PKT_CNT_LO			<= 33'h0;
    	RX_PKT_CNT_HI						<= 32'h0;
    	RX_BYTE_CNT_LO			<= 33'h0;
    	RX_BYTE_CNT_HI						<= 32'h0;
    	
    	FMAC_PKT_CNT_JABBER					<= 32'h0;
    	FMAC_PKT_CNT_FRAGMENT				<= 32'h0;
			
			//STAT GROUP
		FMAC_RX_PKT_CNT64_LO	<= 33'h0;
    	FMAC_RX_PKT_CNT64_HI				<= 32'h0;
    	FMAC_RX_PKT_CNT127_LO	<= 33'h0;
    	FMAC_RX_PKT_CNT127_HI				<= 32'h0;
    	FMAC_RX_PKT_CNT255_LO	<= 33'h0;
    	FMAC_RX_PKT_CNT255_HI				<= 32'h0;
    	FMAC_RX_PKT_CNT511_LO	<= 33'h0;
    	FMAC_RX_PKT_CNT511_HI				<= 32'h0;
    	FMAC_RX_PKT_CNT1023_LO	<= 33'h0;
    	FMAC_RX_PKT_CNT1023_HI				<= 32'h0;
    	FMAC_RX_PKT_CNT1518_LO	<= 33'h0;
    	FMAC_RX_PKT_CNT1518_HI				<= 32'h0;

       	FMAC_RX_PKT_CNT2047_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT2047_HI				<= 32'h0;
       	FMAC_RX_PKT_CNT4095_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT4095_HI				<= 32'h0;
       	FMAC_RX_PKT_CNT8191_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT8191_HI				<= 32'h0;
       	FMAC_RX_PKT_CNT9018_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT9018_HI				<= 32'h0;
       	FMAC_RX_PKT_CNT9022_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT9022_HI				<= 32'h0;
       	FMAC_RX_PKT_CNT9199P_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT9199P_HI				<= 32'h0;
       	
       	FMAC_RX_PKT_CNT_BCAST_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT_BCAST_HI	<= 32'h0;
       	
       	FMAC_RX_PKT_CNT_MCAST_LO	<= 33'h0;
       	FMAC_RX_PKT_CNT_MCAST_HI	<= 32'h0;
		
		end
	
	else
		begin
		sync_wait		 <= 
						 		stat_ok_dly ? 1'b0 :
						 		statistic_ok ? 1'b1 :
						 		sync_wait;
		sync_wait_dly	 <= 	sync_wait ;
		                 
		sync_wait_crc	 <= 
								crc_ok_dly4 ? 1'b0 :
								crc_ok ? 1'b1 :
								sync_wait_crc;
		

		RX_PKT_CNT_LO			<=
    					(fmac_rx_clr_en & SYNC_PKT_CNT_SEL) ? 33'h0 :
    					(statistic_ok & sync_pkt_done) ? RX_PKT_CNT_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,RX_PKT_CNT_LO[31:0]  } :		
    				 	RX_PKT_CNT_LO;
    	RX_PKT_CNT_HI			<=
    				(fmac_rx_clr_en & SYNC_PKT_CNT_SEL) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? RX_PKT_CNT_HI + RX_PKT_CNT_LO[32]   : 
    				RX_PKT_CNT_HI;
    	
    	RX_BYTE_CNT_LO			<=
    					(fmac_rx_clr_en & SYNC_BYTE_CNT_SEL) ? 33'h0 :
    					(statistic_ok & !sync_wait) ? RX_BYTE_CNT_LO + sync_nbyte  :
    					stat_ok_dly4 ? {1'b0,RX_BYTE_CNT_LO[31:0]  } :
    				 	RX_BYTE_CNT_LO;
    	RX_BYTE_CNT_HI			<=
    				(fmac_rx_clr_en & SYNC_BYTE_CNT_SEL) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? RX_BYTE_CNT_HI + RX_BYTE_CNT_LO[32]   : 
    				RX_BYTE_CNT_HI;
		
    	FMAC_PKT_CNT_JABBER		<= 
    					    			(fmac_rx_clr_en & SYNC_PKT_CNT_JABBER_SEL) ? 32'h0 :
    					    			(!crc_ok & sync_wait_crc & pkt_rcv_jabber) ? FMAC_PKT_CNT_JABBER + 1'b1   : 
    					            	
    					    			FMAC_PKT_CNT_JABBER;
    					
    	FMAC_PKT_CNT_FRAGMENT	<= 
    									(fmac_rx_clr_en & SYNC_PKT_CNT_FRAGMENT_SEL) ? 32'h0 :
    					    			(!crc_ok & sync_wait_crc & pkt_rcv_fragment) ? FMAC_PKT_CNT_FRAGMENT + 1'b1   : 
    					
    					    			FMAC_PKT_CNT_FRAGMENT;
		
		FMAC_RX_PKT_CNT64_LO[32:0]	<= 
    					//clear on a read to my reg
    					    			(fmac_rx_clr_en & SYNC_SEL64) ? 33'h0 :
    					//increment if OK and my count
    					    			(statistic_ok & !sync_wait & pkt_rcv64) ? FMAC_RX_PKT_CNT64_LO[32:0] + 1'b1   : 
    					//clear carry bit after add it to the HI reg
    					    			stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT64_LO[31:0]  } :
    					    			FMAC_RX_PKT_CNT64_LO;
    	FMAC_RX_PKT_CNT64_HI	<= 
    				    				(fmac_rx_clr_en & SYNC_SEL64) ? 32'h0 :
    				//adding the carry
    				    				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT64_HI + FMAC_RX_PKT_CNT64_LO[32]   : 
    				    				FMAC_RX_PKT_CNT64_HI;
    				
    	FMAC_RX_PKT_CNT127_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL127) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv127) ? FMAC_RX_PKT_CNT127_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT127_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT127_LO;
    	FMAC_RX_PKT_CNT127_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL127) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT127_HI + FMAC_RX_PKT_CNT127_LO[32]   : 
    				FMAC_RX_PKT_CNT127_HI;
   	
    	FMAC_RX_PKT_CNT255_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL255) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv255) ? FMAC_RX_PKT_CNT255_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT255_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT255_LO;
    	FMAC_RX_PKT_CNT255_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL255) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT255_HI + FMAC_RX_PKT_CNT255_LO[32]   : 
    				FMAC_RX_PKT_CNT255_HI;
    	
    	FMAC_RX_PKT_CNT511_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL511) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv511) ? FMAC_RX_PKT_CNT511_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT511_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT511_LO;
    	FMAC_RX_PKT_CNT511_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL511) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT511_HI + FMAC_RX_PKT_CNT511_LO[32]   : 
    				FMAC_RX_PKT_CNT511_HI;
    	
    	FMAC_RX_PKT_CNT1023_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL1023) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv1023) ? FMAC_RX_PKT_CNT1023_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT1023_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT1023_LO;
    	FMAC_RX_PKT_CNT1023_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL1023) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT1023_HI + FMAC_RX_PKT_CNT1023_LO[32]   : 
    				FMAC_RX_PKT_CNT1023_HI;
    	
    	FMAC_RX_PKT_CNT1518_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL1518) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv1518) ? FMAC_RX_PKT_CNT1518_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT1518_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT1518_LO;
    	FMAC_RX_PKT_CNT1518_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL1518) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT1518_HI + FMAC_RX_PKT_CNT1518_LO[32]   : 
    				FMAC_RX_PKT_CNT1518_HI;

       	FMAC_RX_PKT_CNT2047_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL2047) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv2047) ? FMAC_RX_PKT_CNT2047_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT2047_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT2047_LO;
       	FMAC_RX_PKT_CNT2047_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL2047) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT2047_HI + FMAC_RX_PKT_CNT2047_LO[32]   : 
    				FMAC_RX_PKT_CNT2047_HI;
       	
       	FMAC_RX_PKT_CNT4095_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL4095) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv4095) ? FMAC_RX_PKT_CNT4095_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT4095_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT4095_LO;
       	FMAC_RX_PKT_CNT4095_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL4095) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT4095_HI + FMAC_RX_PKT_CNT4095_LO[32]   : 
    				FMAC_RX_PKT_CNT4095_HI;
       	
       	FMAC_RX_PKT_CNT8191_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL8191) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv8191) ? FMAC_RX_PKT_CNT8191_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT8191_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT8191_LO;
       	FMAC_RX_PKT_CNT8191_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL8191) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT8191_HI + FMAC_RX_PKT_CNT8191_LO[32]   : 
    				FMAC_RX_PKT_CNT8191_HI;
       	
       	FMAC_RX_PKT_CNT9018_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL9018) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv9018) ? FMAC_RX_PKT_CNT9018_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT9018_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT9018_LO;
       	FMAC_RX_PKT_CNT9018_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL9018) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT9018_HI + FMAC_RX_PKT_CNT9018_LO[32]   : 
    				FMAC_RX_PKT_CNT9018_HI;
       	
       	FMAC_RX_PKT_CNT9022_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL9022) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv9022) ? FMAC_RX_PKT_CNT9022_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT9022_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT9022_LO;
       	FMAC_RX_PKT_CNT9022_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL9022) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT9022_HI + FMAC_RX_PKT_CNT9022_LO[32]   : 
    				FMAC_RX_PKT_CNT9022_HI;
       	
       	FMAC_RX_PKT_CNT9199P_LO	<= 
    					(fmac_rx_clr_en & SYNC_SEL9199P) ? 33'h0 :
    					(statistic_ok & !sync_wait & pkt_rcv9199p) ? FMAC_RX_PKT_CNT9199P_LO + 1'b1  :
    					stat_ok_dly4 ? {1'b0,FMAC_RX_PKT_CNT9199P_LO[31:0]  } :
    				 	FMAC_RX_PKT_CNT9199P_LO;
       	FMAC_RX_PKT_CNT9199P_HI	<= 
    				(fmac_rx_clr_en & SYNC_SEL9199P) ? 32'h0 :
     				(stat_ok_dly & !sync_wait_dly) ? FMAC_RX_PKT_CNT9199P_HI + FMAC_RX_PKT_CNT9199P_LO[32]   : 
    				FMAC_RX_PKT_CNT9199P_HI;
    				
    	//==== BROADCAST and MULTICAST has different events than the above			
    	    	    	FMAC_RX_PKT_CNT_BCAST_LO <=
    			(fmac_rx_clr_en & SYNC_SEL_BCAST) ? 33'h0 :
    			add_lo_bcast ? FMAC_RX_PKT_CNT_BCAST_LO + 1'b1 :
    			clr_carry_cast ? {1'b0, FMAC_RX_PKT_CNT_BCAST_LO[31:0]} :
    			FMAC_RX_PKT_CNT_BCAST_LO;
    			
    	FMAC_RX_PKT_CNT_BCAST_HI <=
    			(fmac_rx_clr_en & SYNC_SEL_BCAST) ? 32'h0 :
    			add_hi_cast ? FMAC_RX_PKT_CNT_BCAST_HI + FMAC_RX_PKT_CNT_BCAST_LO[32] :
    			FMAC_RX_PKT_CNT_BCAST_HI;
    			
    			
    	FMAC_RX_PKT_CNT_MCAST_LO <=
    			(fmac_rx_clr_en & SYNC_SEL_MCAST) ? 33'h0 :
    			add_lo_mcast ? FMAC_RX_PKT_CNT_MCAST_LO + 1'b1 :
    			clr_carry_cast ? {1'b0, FMAC_RX_PKT_CNT_MCAST_LO[31:0]} :
    			FMAC_RX_PKT_CNT_MCAST_LO;
    			
    	FMAC_RX_PKT_CNT_MCAST_HI <=
    			(fmac_rx_clr_en & SYNC_SEL_MCAST) ? 32'h0 :
    			add_hi_cast ? FMAC_RX_PKT_CNT_MCAST_HI + FMAC_RX_PKT_CNT_MCAST_LO[32] :
    			FMAC_RX_PKT_CNT_MCAST_HI;

    					
		end
    
//======= MUXING OUT THE LO & HI GROUP


always@ (posedge clk250)
	if (!rst_)
		begin
    	STAT_GROUP_LO_DOUT	<=	32'h0	;
    	STAT_GROUP_HI_DOUT	<=	32'h0	;
    	end
    	
    else
    	begin
    	//PKT_RCV_SEL is combinational
    	STAT_GROUP_LO_DOUT	<=	
    			{32{DLY_PKT_RCV_SEL64 	  }} &  FMAC_RX_PKT_CNT64_LO[31:0]   |
    	        {32{DLY_PKT_RCV_SEL127 	  }} &  FMAC_RX_PKT_CNT127_LO[31:0]  |
    	        {32{DLY_PKT_RCV_SEL255 	  }} &  FMAC_RX_PKT_CNT255_LO[31:0]  |
    	        {32{DLY_PKT_RCV_SEL511 	  }} &  FMAC_RX_PKT_CNT511_LO[31:0]  |
    	        {32{DLY_PKT_RCV_SEL1023   }} &  FMAC_RX_PKT_CNT1023_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL1518   }} &  FMAC_RX_PKT_CNT1518_LO[31:0] |
    	                         
    	        {32{DLY_PKT_RCV_SEL2047   }} &  FMAC_RX_PKT_CNT2047_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL4095   }} &  FMAC_RX_PKT_CNT4095_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL8191   }} &  FMAC_RX_PKT_CNT8191_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL9018   }} &  FMAC_RX_PKT_CNT9018_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL9022   }} &  FMAC_RX_PKT_CNT9022_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL9199P  }} &  FMAC_RX_PKT_CNT9199P_LO[31:0] |
    	        
    	        {32{DLY_PKT_RCV_SEL_BCAST  }} &  FMAC_RX_PKT_CNT_BCAST_LO[31:0] |
    	        {32{DLY_PKT_RCV_SEL_MCAST  }} &  FMAC_RX_PKT_CNT_MCAST_LO[31:0] 
    	        ;
    	
    	STAT_GROUP_HI_DOUT	<=	
    			{32{DLY_PKT_RCV_SEL64 	  }} &  FMAC_RX_PKT_CNT64_HI   |
    	        {32{DLY_PKT_RCV_SEL127 	  }} &  FMAC_RX_PKT_CNT127_HI  |
    	        {32{DLY_PKT_RCV_SEL255 	  }} &  FMAC_RX_PKT_CNT255_HI  |
    	        {32{DLY_PKT_RCV_SEL511 	  }} &  FMAC_RX_PKT_CNT511_HI  |
    	        {32{DLY_PKT_RCV_SEL1023   }} &  FMAC_RX_PKT_CNT1023_HI |
    	        {32{DLY_PKT_RCV_SEL1518   }} &  FMAC_RX_PKT_CNT1518_HI |
    	                         
    	        {32{DLY_PKT_RCV_SEL2047   }} &  FMAC_RX_PKT_CNT2047_HI |
    	        {32{DLY_PKT_RCV_SEL4095   }} &  FMAC_RX_PKT_CNT4095_HI |
    	        {32{DLY_PKT_RCV_SEL8191   }} &  FMAC_RX_PKT_CNT8191_HI |
    	        {32{DLY_PKT_RCV_SEL9018   }} &  FMAC_RX_PKT_CNT9018_HI |
    	        {32{DLY_PKT_RCV_SEL9022   }} &  FMAC_RX_PKT_CNT9022_HI |
    	        {32{DLY_PKT_RCV_SEL9199P  }} &  FMAC_RX_PKT_CNT9199P_HI |
    	        
    	        {32{DLY_PKT_RCV_SEL_BCAST  }} &  FMAC_RX_PKT_CNT_BCAST_HI |
    	        {32{DLY_PKT_RCV_SEL_MCAST  }} &  FMAC_RX_PKT_CNT_MCAST_HI 
    	        
    	        ;    	
    	end
    
// GENERATING CLEAR SIGNALS FOR DIFFERENT REGs inside the FMAC_RX    
reg		clr_pkt_cnt_oversize	;

always @(posedge clk250)
	begin
			clr_pkt_cnt_oversize <= !rst_ ? 1'b0 : (fmac_rx_clr_en & SYNC_PKT_CNT_OVERSIZE_SEL) ? 1'b1 : 1'b0 ;
	
	end    
    
endmodule