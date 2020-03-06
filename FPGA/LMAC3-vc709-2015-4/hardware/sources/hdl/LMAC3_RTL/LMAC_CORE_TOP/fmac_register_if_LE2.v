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

module fmac_register_if(
	clk,     					// i-1
    reset_,  					// i-1
     
    // REGULAR Statistic Registers
    //NOTE:  Each mac should do its own count then resync one time only
    fmac_ctrl_dly,				//i-32
    FMAC_TX_PKT_CNT,  			// i-32
    FMAC_RX_PKT_CNT_LO,      	// i-32, (derived from SYNCLK125 [or FMAC0 clk])
    FMAC_RX_PKT_CNT_HI,      	// i-32, (derived from SYNCLK125 [or FMAC0 clk])

    FMAC_TX_BYTE_CNT,			// i-32
	FMAC_RX_BYTE_CNT_LO,   		// i-32, (from synclk)
	FMAC_RX_BYTE_CNT_HI,   		// i-32, (from synclk)
	

	FMAC_RX_UNDERSIZE_PKT_CNT,	// i-32
	FMAC_RX_CRC_ERR_CNT,		// i-32
	FMAC_DCNT_OVERRUN,			// i-32
	FMAC_DCNT_LINK_ERR,			// i-32
	FMAC_PKT_CNT_OVERSIZE,		// i-32
	FMAC_PHY_STAT,				// i-32
	fmac_ctrl1	,				//i-32
	
	FMAC_PKT_CNT_JABBER		,	//i-32
	FMAC_PKT_CNT_FRAGMENT	,	//i-32
	FMAC_RAW_FRAME_CNT	,		//i-32
	FMAC_BAD_FRAMESOF_CNT	,	//i-32
	
	//Interface to 64 bit Statistic register group, in DECAP
	STAT_GROUP_LO_DOUT	,		// i-32,
	STAT_GROUP_HI_DOUT	,		// i-32,
	STAT_GROUP_addr	,			// o-10, address to select the register within the STAT GROUP
	STAT_GROUP_sel	,			//o-1
	fmac_rx_clr_en,				//o-1
	
	fmac_tx_clr_en,	
	
	// Interface to mac_register
	reg_rd_start,				// i-1, pulse indicating the start of a reg access
	reg_rd_done,				// i-1, pulse indicating the end of a reg access
	host_addr_reg,				// i-16
	SYS_ADDR,					// i-4
	
	rx_auto_clr_en,				//i-1
	tx_auto_clr_en,				//i-1
	
	
	//REGISTERS
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
	//--
	FMAC_REGDOUT				// o-32
	
    );
      
// ----------------------------------------------------------------------------
// PORT DECLARATIONS
// ----------------------------------------------------------------------------
input       clk;
input       reset_;

// Statistic Registers
input	[31:0]	fmac_ctrl_dly	;
input [31:0]	FMAC_TX_PKT_CNT;
input [31:0]	FMAC_RX_PKT_CNT_LO;
input [31:0]	FMAC_RX_PKT_CNT_HI;

input [31:0]	FMAC_TX_BYTE_CNT;
input [31:0]	FMAC_RX_BYTE_CNT_LO;
input [31:0]	FMAC_RX_BYTE_CNT_HI;

input [31:0]	FMAC_RX_UNDERSIZE_PKT_CNT;
input [31:0]	FMAC_RX_CRC_ERR_CNT;
input [31:0]	FMAC_DCNT_OVERRUN;
input [31:0]	FMAC_DCNT_LINK_ERR;
input [31:0]	FMAC_PKT_CNT_OVERSIZE;
input [31:0]	FMAC_PHY_STAT;
input	[31:0]	fmac_ctrl1	;

input	[31:0]	FMAC_PKT_CNT_JABBER		;	//i-32
input	[31:0]	FMAC_PKT_CNT_FRAGMENT	;	//i-32
input	[31:0]	FMAC_RAW_FRAME_CNT	;		//i-32
input	[31:0]	FMAC_BAD_FRAMESOF_CNT	;	//i-32
	
input	[31:0]	STAT_GROUP_LO_DOUT	;		// i-32,
input	[31:0]	STAT_GROUP_HI_DOUT	;		// i-32,
output	[9:0]	STAT_GROUP_addr	;			// o-10, address to select the register within the STAT GROUP
output			STAT_GROUP_sel	;			// o-1, 
output			fmac_rx_clr_en	;			// o-1, 
	
output			fmac_tx_clr_en	;

// Interface to mac_register
input			reg_rd_start;
input			reg_rd_done;
input [15:0]	host_addr_reg;
input [3:0]		SYS_ADDR;

input			rx_auto_clr_en;
input			tx_auto_clr_en;


//REGISTERS
input	[32:0]		FMAC_RX_PKT_CNT64_LO;
input	[31:0]		FMAC_RX_PKT_CNT64_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT127_LO;
input	[31:0]		FMAC_RX_PKT_CNT127_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT255_LO;
input	[31:0]		FMAC_RX_PKT_CNT255_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT511_LO;
input	[31:0]		FMAC_RX_PKT_CNT511_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT1023_LO;
input	[31:0]		FMAC_RX_PKT_CNT1023_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT1518_LO;
input	[31:0]		FMAC_RX_PKT_CNT1518_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT2047_LO;
input	[31:0]		FMAC_RX_PKT_CNT2047_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT4095_LO;
input	[31:0]		FMAC_RX_PKT_CNT4095_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT8191_LO;
input	[31:0]		FMAC_RX_PKT_CNT8191_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT9018_LO;
input	[31:0]		FMAC_RX_PKT_CNT9018_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT9022_LO;
input	[31:0]		FMAC_RX_PKT_CNT9022_HI;
     	      		
input	[32:0]		FMAC_RX_PKT_CNT9199P_LO;
input	[31:0]		FMAC_RX_PKT_CNT9199P_HI;


output [31:0]	FMAC_REGDOUT;

//Variables for atomic controller
wire				atomic_cycle_mode;
reg					atm_latch_en;
reg					atm_latch_en_dly;
reg		[31:0]		local32_hi;					//keeping the upper 32 bit of the 64 bit reg
reg		[31:0]		my_local32_hi;				//temp mux
reg		[8:0]		atm_tag;					//keeping the addr of the previous reg read for checking matching
reg					atm_valid;      		
wire				tag_match;      		
                	                		
reg					reg_rd_start_int;       	
reg					reg_rd_done_int;        	
reg					atomic_hi_en;				//enable the access to the ATOMIC HI register
                	
reg		[31:0]		FMAC_RAW_FRAME_CNT_DLY1	;	//i-32
reg		[31:0]		FMAC_BAD_FRAMESOF_CNT_DLY1;	//i-32


// ----------------------------------------------------------------------------
// INTERNAL
// ----------------------------------------------------------------------------
// STATISTIC & DIAGNOSTIC REGISTERS
//											addr[11:3]		addr[15:0]	
//`define	FMAC_TX_PKT_CNT_addr			9'h004			// 	1020h
//`define 	FMAC_RX_PKT_CNT_addr			9'h005			// 	1028h	
//`define	FMAC_TX_BYTE_CNT_addr			9'h006			// 	1030h
//`define	FMAC_RX_BYTE_CNT_addr  			9'h007			// 	1038h
//`define	FMAC_RX_UNDERSIZE_PKT_CNT_addr	9'h008			// 	1040h
//`define	FMAC_RX_CRC_ERR_CNT_addr		9'h009			// 	1048h
//`define	FMAC_DCNT_OVERRUN_addr 			9'h00A   		// 	1050h
//`define	FMAC_DCNT_LINK_ERR_addr 		9'h00B   		// 	1058h
//`define	FMAC_DCNT_OVERSIZE_addr 		9'h00C   		// 	1060h
//`define	FMAC_PHY_STAT_addr  			9'h00D 			// 	1068h

// ========================================
// Buffer the address    
// ========================================          

//bit 9:0 actually select the individual reg
//bit 11:10 select the group within the FMAC
//For now, (13jun10) bit 11 selects the new statistic regs
reg [8:0]	addr_buf0;
reg [9:0]	STAT_GROUP_addr;	//only bit 9:3 are used, for used by the new statistic regs
reg			upper32_addr;

reg			STAT_GROUP_sel;
reg			fmac_rx_clr_en;
reg			fmac_tx_clr_en;

reg	[3:0]	host_addr_int;		//only upper nibble of the host addr

reg			high_sel;

always @ (posedge clk)
	begin
	addr_buf0	 <=	host_addr_reg[11:3];
	upper32_addr	<= host_addr_reg[2];
	
	//keeping the bit numbering the same as the address
	host_addr_int		<= host_addr_reg[15:12];
	STAT_GROUP_addr	 	<= {host_addr_reg[9:3], 3'b000} ;
	
	//use 1 bit for NO decoding
	STAT_GROUP_sel		<= host_addr_reg[11];
		//sys_addr is a constant
		//teh DONE signal may be a clock too late and can cause conflict
		//need to clear sooner if possible
	fmac_rx_clr_en			<= 
		!reset_ ? 1'b0 :
		(host_addr_int == SYS_ADDR) & reg_rd_done_int & rx_auto_clr_en ;
	fmac_tx_clr_en			<= 
		!reset_ ? 1'b0 :
		(host_addr_int == SYS_ADDR) & reg_rd_done_int & tx_auto_clr_en ;

	high_sel				<=
		host_addr_reg[2] | host_addr_reg[1];
	end
	
//STATISTIC & DIAGNOSTIC REGISTERS
parameter	[9:0]	FMAC_CTRL_addr							= 	10'h0_00;
parameter	[9:0]	FMAC_TX_PKT_CNT_addr					= 	10'h0_20;

//addr bit 2 indicates the lo or hi 32bit of 64 bit register
parameter 	[9:0]	FMAC_RX_PKT_CNT_addr					= 	10'h0_28;	// 	- RX_PKT_CNT_LO
															//	102Ch 		//	- RX_PKT_CNT_HI
parameter	[9:0]	FMAC_TX_BYTE_CNT_addr					= 	10'h0_30;	// 	- RX_BYTE_CNT_LO
															//	1034h 		//	- RX_BYTE_CNT_HI
														
parameter	[9:0]	FMAC_RX_BYTE_CNT_addr  					= 	10'h0_38;
parameter 	[9:0]	FMAC_RX_UNDERSIZE_PKT_CNT_addr			= 	10'h0_40;
parameter 	[9:0]	FMAC_RX_CRC_ERR_CNT_addr				= 	10'h0_48;
parameter	[9:0]	FMAC_DCNT_OVERRUN_addr 			   		= 	10'h0_50;
parameter	[9:0]	FMAC_DCNT_LINK_ERR_addr 		   		= 	10'h0_58;
parameter	[9:0]	FMAC_PKT_CNT_OVERSIZE_addr 		   		= 	10'h0_60;
parameter	[9:0]	FMAC_PHY_STAT_addr  			 		= 	10'h0_68;
parameter	[9:0]	FMAC_CTRL1_addr  			 			= 	10'h0_70;

parameter	[9:0]	FMAC_PKT_CNT_JABBER_addr 		   		= 	10'h0_78;
parameter	[9:0]	FMAC_PKT_CNT_FRAGMENT_addr 		   		= 	10'h0_80;
parameter	[9:0]	FMAC_RAW_FRAME_CNT_addr 		   		= 	10'h0_88;	//addr = 'h1088
parameter	[9:0]	FMAC_BAD_FRAMESOF_CNT_addr 		   		= 	10'h0_90;	//addr = 'h1090

// ========================================	
// Decode address to Select lines           	
// ======================================== 

wire		FMAC_CTRL_sel		;
wire		FMAC_TX_PKT_CNT_sel;
wire		FMAC_RX_PKT_CNT_sel;
wire		FMAC_TX_BYTE_CNT_sel;
wire		FMAC_RX_BYTE_CNT_sel;
wire		FMAC_RX_UNDERSIZE_PKT_CNT_sel;
wire	 	FMAC_RX_CRC_ERR_CNT_sel;
wire		FMAC_DCNT_OVERRUN_sel;
wire		FMAC_DCNT_LINK_ERR_sel;
wire		FMAC_PKT_CNT_OVERSIZE_sel;
wire		FMAC_PHY_STAT_sel;
wire		FMAC_CTRL1_sel		;

wire		FMAC_PKT_CNT_JABBER_sel		;
wire		FMAC_PKT_CNT_FRAGMENT_sel	;
wire		FMAC_RAW_FRAME_CNT_sel	;
wire		FMAC_BAD_FRAMESOF_CNT_sel	;

assign	FMAC_CTRL_sel					=	( addr_buf0[6:0] == FMAC_CTRL_addr[9:3]						); 
assign	FMAC_TX_PKT_CNT_sel				=	( addr_buf0[6:0] == FMAC_TX_PKT_CNT_addr[9:3]				); 
assign	FMAC_TX_BYTE_CNT_sel			=	( addr_buf0[6:0] == FMAC_TX_BYTE_CNT_addr[9:3]				); 
assign	FMAC_RX_PKT_CNT_sel				=	( addr_buf0[6:0] == FMAC_RX_PKT_CNT_addr[9:3]				); 
assign	FMAC_RX_BYTE_CNT_sel			=	( addr_buf0[6:0] == FMAC_RX_BYTE_CNT_addr[9:3]				); 
assign	FMAC_RX_UNDERSIZE_PKT_CNT_sel	=	( addr_buf0[6:0] == FMAC_RX_UNDERSIZE_PKT_CNT_addr[9:3]		); 
assign	FMAC_RX_CRC_ERR_CNT_sel			=	( addr_buf0[6:0] == FMAC_RX_CRC_ERR_CNT_addr[9:3]			);
assign	FMAC_DCNT_OVERRUN_sel			=	( addr_buf0[6:0] == FMAC_DCNT_OVERRUN_addr[9:3]				); 
assign	FMAC_DCNT_LINK_ERR_sel			=	( addr_buf0[6:0] == FMAC_DCNT_LINK_ERR_addr[9:3]			); 
assign	FMAC_PKT_CNT_OVERSIZE_sel		=	( addr_buf0[6:0] == FMAC_PKT_CNT_OVERSIZE_addr[9:3]			); 
assign	FMAC_PHY_STAT_sel				=	( addr_buf0[6:0] == FMAC_PHY_STAT_addr[9:3]					); 	
assign	FMAC_CTRL1_sel					=	( addr_buf0[6:0] == FMAC_CTRL1_addr[9:3]					); 
assign	FMAC_PKT_CNT_JABBER_sel			=	( addr_buf0[6:0] == FMAC_PKT_CNT_JABBER_addr[9:3]			); 
assign	FMAC_PKT_CNT_FRAGMENT_sel		=	( addr_buf0[6:0] == FMAC_PKT_CNT_FRAGMENT_addr[9:3]			); 
assign	FMAC_RAW_FRAME_CNT_sel			=	( addr_buf0[6:0] == FMAC_RAW_FRAME_CNT_addr[9:3]			); 
assign	FMAC_BAD_FRAMESOF_CNT_sel		=	( addr_buf0[6:0] == FMAC_BAD_FRAMESOF_CNT_addr[9:3]			); 

//=================================================
//DELAYED VERSION FOR READING - better timing
reg		DLY_FMAC_CTRL_sel		;
reg		DLY_FMAC_TX_PKT_CNT_sel;
reg		DLY_FMAC_RX_PKT_CNT_sel;
reg		DLY_FMAC_TX_BYTE_CNT_sel;
reg		DLY_FMAC_RX_BYTE_CNT_sel;
reg		DLY_FMAC_RX_UNDERSIZE_PKT_CNT_sel;
reg	 	DLY_FMAC_RX_CRC_ERR_CNT_sel;
reg		DLY_FMAC_DCNT_OVERRUN_sel;
reg		DLY_FMAC_DCNT_LINK_ERR_sel;
reg		DLY_FMAC_PKT_CNT_OVERSIZE_sel;
reg		DLY_FMAC_PHY_STAT_sel;
reg		DLY_FMAC_CTRL1_sel		;
reg		DLY_FMAC_PKT_CNT_JABBER_sel;
reg		DLY_FMAC_PKT_CNT_FRAGMENT_sel;
reg		DLY_FMAC_RAW_FRAME_CNT_sel;
reg		DLY_FMAC_BAD_FRAMESOF_CNT_sel;

always@(posedge clk)
begin
		DLY_FMAC_CTRL_sel					<= !reset_ ? 1'b0 : FMAC_CTRL_sel			      		;
		DLY_FMAC_TX_PKT_CNT_sel				<= !reset_ ? 1'b0 : FMAC_TX_PKT_CNT_sel			      	;
		DLY_FMAC_RX_PKT_CNT_sel				<= !reset_ ? 1'b0 : FMAC_RX_PKT_CNT_sel				   	;
		DLY_FMAC_TX_BYTE_CNT_sel			<= !reset_ ? 1'b0 : FMAC_TX_BYTE_CNT_sel			   	;
		DLY_FMAC_RX_BYTE_CNT_sel			<= !reset_ ? 1'b0 : FMAC_RX_BYTE_CNT_sel			   	;
		DLY_FMAC_RX_UNDERSIZE_PKT_CNT_sel	<= !reset_ ? 1'b0 : FMAC_RX_UNDERSIZE_PKT_CNT_sel		;
	 	DLY_FMAC_RX_CRC_ERR_CNT_sel			<= !reset_ ? 1'b0 : FMAC_RX_CRC_ERR_CNT_sel			    ;
		DLY_FMAC_DCNT_OVERRUN_sel			<= !reset_ ? 1'b0 : FMAC_DCNT_OVERRUN_sel			    ;
		DLY_FMAC_DCNT_LINK_ERR_sel			<= !reset_ ? 1'b0 : FMAC_DCNT_LINK_ERR_sel			    ;
		DLY_FMAC_PKT_CNT_OVERSIZE_sel		<= !reset_ ? 1'b0 : FMAC_PKT_CNT_OVERSIZE_sel		   	;
		DLY_FMAC_PHY_STAT_sel				<= !reset_ ? 1'b0 : FMAC_PHY_STAT_sel				    ;
		DLY_FMAC_CTRL1_sel					<= !reset_ ? 1'b0 : FMAC_CTRL1_sel			      		;
	
		DLY_FMAC_PKT_CNT_JABBER_sel			<= !reset_ ? 1'b0 : FMAC_PKT_CNT_JABBER_sel		   		;
		DLY_FMAC_PKT_CNT_FRAGMENT_sel		<= !reset_ ? 1'b0 : FMAC_PKT_CNT_FRAGMENT_sel		   	;
		DLY_FMAC_RAW_FRAME_CNT_sel			<= !reset_ ? 1'b0 : FMAC_RAW_FRAME_CNT_sel		   	;
		DLY_FMAC_BAD_FRAMESOF_CNT_sel		<= !reset_ ? 1'b0 : FMAC_BAD_FRAMESOF_CNT_sel		   	;
end
	
//==================================================	
reg		[31:0]	REGU_GROUP_LO_DOUT;

// REGULAR GROUP register - LOW 32
always@(posedge clk)
	begin
		FMAC_RAW_FRAME_CNT_DLY1		<= !reset_ ? 32'h0	   	: FMAC_RAW_FRAME_CNT	;	
		FMAC_BAD_FRAMESOF_CNT_DLY1	<= !reset_ ? 32'h0 		: FMAC_BAD_FRAMESOF_CNT	;	
	
	REGU_GROUP_LO_DOUT		<=
	
			//previous
			fmac_ctrl_dly 				&	{32{ DLY_FMAC_CTRL_sel					}}	| 
			fmac_ctrl1		 			&	{32{ DLY_FMAC_CTRL1_sel					}}	| 
			
			FMAC_TX_PKT_CNT 			&	{32{ DLY_FMAC_TX_PKT_CNT_sel			}}  | 
			FMAC_TX_BYTE_CNT 			&	{32{ DLY_FMAC_TX_BYTE_CNT_sel			}}  | 
			FMAC_RX_PKT_CNT_LO 			&	{32{ DLY_FMAC_RX_PKT_CNT_sel			}}  | 
			FMAC_RX_BYTE_CNT_LO 		&	{32{ DLY_FMAC_RX_BYTE_CNT_sel			}}  | 
			FMAC_RX_UNDERSIZE_PKT_CNT 	&	{32{ DLY_FMAC_RX_UNDERSIZE_PKT_CNT_sel	}}  | 
			FMAC_RX_CRC_ERR_CNT 		&	{32{ DLY_FMAC_RX_CRC_ERR_CNT_sel		}}  |
			FMAC_DCNT_OVERRUN 			&	{32{ DLY_FMAC_DCNT_OVERRUN_sel			}}  | 
			FMAC_DCNT_LINK_ERR 			&	{32{ DLY_FMAC_DCNT_LINK_ERR_sel			}}  | 
			FMAC_PKT_CNT_OVERSIZE 		&	{32{ DLY_FMAC_PKT_CNT_OVERSIZE_sel		}}  | 
			FMAC_PHY_STAT 				&	{32{ DLY_FMAC_PHY_STAT_sel				}}  |
			FMAC_PKT_CNT_JABBER 		&	{32{ DLY_FMAC_PKT_CNT_JABBER_sel		}}  | 
			
			FMAC_RAW_FRAME_CNT_DLY1 		&	{32{ DLY_FMAC_RAW_FRAME_CNT_sel			}}	|        //25may13
			FMAC_BAD_FRAMESOF_CNT_DLY1 		&	{32{ DLY_FMAC_BAD_FRAMESOF_CNT_sel		}}	| 
			FMAC_PKT_CNT_FRAGMENT 		&	{32{ DLY_FMAC_PKT_CNT_FRAGMENT_sel		}}   
			;	
		
	end

reg		[31:0]	REGU_GROUP_HI_DOUT;
	
always@ (posedge clk)
	begin
		if (!reset_) begin
			REGU_GROUP_HI_DOUT		<=		0;
		end
		else begin
			case (host_addr_reg)
				16'h102C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT_HI;
				16'h103C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_BYTE_CNT_HI;
				16'h1804	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT64_HI;
				16'h180C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT127_HI;
				16'h1814	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT255_HI;
				16'h181C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT511_HI;
				16'h1824	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT1023_HI;
				16'h182C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT1518_HI;
				16'h1834	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT2047_HI;
				16'h183C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT4095_HI;
				16'h1844	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT8191_HI;
				16'h184C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT9018_HI;
				16'h1854	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT9022_HI;
				16'h185C	:	REGU_GROUP_HI_DOUT		<=		FMAC_RX_PKT_CNT9199P_HI;		 
				default		:	REGU_GROUP_HI_DOUT		<= 		0;
			endcase
		end
	end
	
//NOTE:  The REGU_GROUP_HI only has 2 registers so output it directly rather than via a bus
//if more registers later, a bus may be needed for this group.


// ========================================	
// Muxing for FMAC_REGDOUT - SEE ATOMIC ENFORCEMENT BELOW
// ========================================
reg [31:0]	FMAC_REGDOUT;
always@(posedge clk)
begin
							
	//The address of the registers are structured for fast decode
	//bit 11:10 are used to decode which reg group within the FMAC
	//so at this level of muxing still preserve the old regs while allow room to add
	//new regs
	//bit 11:10 = 0 is for the old group
	//bit 11 = 1 is for the new statistic regs which are many
	FMAC_REGDOUT	<=		high_sel	?
							REGU_GROUP_HI_DOUT		:
							{32{ !STAT_GROUP_sel & !upper32_addr	}} & 		REGU_GROUP_LO_DOUT	|
							{32{  STAT_GROUP_sel & !upper32_addr	}} & 		STAT_GROUP_LO_DOUT	|
							{32{ atomic_hi_en }} & local32_hi
							;

end

//=======================================
// ATOMIC CONTROLLER - Enforce ATOMICITY for 64 bit reg reads
//=======================================
// SW always read the lo of the 64 bit reg first
// the LO regs go directly to the MUX
// the HI is being kept in the ATOMIC reg
// need more precise timing to avoid stale data

//if detect a read to LO of PKT_CNT or BYTE_CNT (host_addr[2] = 0)
//only HW can write to these registers
assign		atomic_cycle_mode = 
							( !STAT_GROUP_sel & DLY_FMAC_RX_PKT_CNT_sel 	& !upper32_addr )
						|	( !STAT_GROUP_sel & DLY_FMAC_RX_BYTE_CNT_sel 	& !upper32_addr )
						//add the regs from the STAT GROUP
						|	(  STAT_GROUP_sel 		& !upper32_addr )
						
						;

//HI access cycle
assign	tag_match	= (addr_buf0 == atm_tag);

//internal signals
always@(posedge clk)
	if (!reset_)
		begin
		reg_rd_start_int	<= 1'b0;
		reg_rd_done_int	<= 1'b0;
		end
	else
		begin
		reg_rd_start_int	<= reg_rd_start;	//reg_rd_start and done are from MAC_REG module
		reg_rd_done_int	<= reg_rd_done;	
		end
		
//keeping upper 32 bit reg
//reg_rd_start -> decode -> temp_mux -> local32
always@(posedge clk)
begin
	
		//local ATMOMIC HI valid bit
	if (!reset_)
		atm_valid	<= 1'b0;
	else case (atm_valid)
		1'b0:
		atm_valid	<=
			//set on 1st latch, or keep
			atm_latch_en_dly & atomic_cycle_mode ? 1'b1 : 1'b0;
			
		1'b1:
		atm_valid	<=
			//negate on next read ending
			(reg_rd_done & tag_match & upper32_addr) ? 1'b0 : 1'b1;
			
		endcase

//add reset for simulation
if (!reset_ )
	begin
	atm_latch_en		<= 1'b0 ;
	atm_latch_en_dly	<= 1'b0 ;
	local32_hi			<= 32'h0 ;
	atm_tag				<= 9'h0 ;
	my_local32_hi		<= 32'h0 ;
	atomic_hi_en		<= 1'b0 ;
	
	end
else
	begin		
	atm_latch_en		<= reg_rd_start_int & atomic_cycle_mode;	//enable latching if it's atomic access start
	atm_latch_en_dly	<= atm_latch_en;							//delay to wait for address propagation
	local32_hi			<= atm_latch_en_dly ? my_local32_hi : local32_hi;
	atm_tag				<= atm_latch_en_dly ? addr_buf0 : atm_tag;
				
	//32 bit mux
	//this is used to mux 15 64 bit reg to 1
	my_local32_hi			<=
	                        	{32{ !STAT_GROUP_sel & DLY_FMAC_RX_PKT_CNT_sel	}} &	FMAC_RX_PKT_CNT_HI		//from rx_decap
							|	{32{ !STAT_GROUP_sel & DLY_FMAC_RX_BYTE_CNT_sel	}} &	FMAC_RX_BYTE_CNT_HI		//from rx_decap
							//ADD the regs from the STAT group
							|	{32{  STAT_GROUP_sel			}} & 	STAT_GROUP_HI_DOUT
							
									;
	
	atomic_hi_en	<=
			//clr if see reg_rd_done
			atomic_hi_en & reg_rd_done ? 1'b0 :
			//set, if this cycle matches my tag
			//need to allow the data to drive back as soon as possible for downstream to latch
			atm_valid & tag_match & upper32_addr ? 1'b1 :
			//keep otherwise
			atomic_hi_en
			;
	end
			
end



endmodule