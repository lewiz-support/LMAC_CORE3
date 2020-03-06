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
`timescale 1ns/10ps
// synopsys translate_on

module tx_xgmii(
	clk250,	// i-1
	clk156,	// i-1, this really is coreclkout (can be 156 or 125MHz)
	rst_,  	// i-1
	
	//from register
	mode_10G,	//i-1, Not used
	
	// Interface to tx_encap
	rts,    // i-1
	rdata,  // i-256
	rbytes,	// i-16
		//for GIGE
	cts,	//o-1, enable ENCAP to read the next QWD (NOT USED, keep for I/O compatibility)
	
	// To xaui_top	
	xgmii_txd,	// o-64
	xgmii_txc,	// o-8
	
	// To mac_register.v
	FMAC_TX_PKT_CNT,  		// o-32
	FMAC_TX_BYTE_CNT,		// o-32
	fmac_tx_clr_en	// i-1
	
	);

	
// ----------------------------------------------------------------------------
// PORT DECLARATIONS
// ----------------------------------------------------------------------------	
input clk250;	// 250 Mhz
input clk156;	// 156.25 Mhz
input rst_;

	//decoded from register
input	mode_10G	;

// Interface to tx_encap
input   rts;
input  [255:0] rdata;	//data to send out
input   [15:0] rbytes;

output	cts;		 wire  cts = 1'b0 ;  //not used tie lo

// To xaui_top
output [63:0] xgmii_txd;
output [07:0] xgmii_txc;

// To mac_register.v
output [31:0] FMAC_TX_PKT_CNT;
output [31:0] FMAC_TX_BYTE_CNT;
input		  fmac_tx_clr_en;
	
// ----------------------------------------------------------------------------
// INTERNAL SIGNALS
// ----------------------------------------------------------------------------

reg   		  rts_dly;		//request to send from encap
reg    [63:0] rdata_dly;	// data input
reg	   [15:0] rbytes_dly;	//holds the size of data in Bytes
reg	   [1:0]  cntr_4;

reg    [63:0] bdata1;
reg    [63:0] bdata2;
reg    [15:0] wcnt;

wire	[15:0] nbytes;
reg  	[15:0] nbytes_reg;
reg 	[15:0] rbytes_reg;

reg    [63:0] xgmii_txd;
reg    [07:0] xgmii_txc;
reg    [07:0] txc_int;

reg    IDLE_sel;
reg    insert_crc;

reg    crc_we_;
reg    crc_last_;
reg    crc_clr_;
reg    [15:0] crc_cnt;
wire   [31:0] crc32;

reg		sent;
reg		sent_dly;
//reg	statistic_ok;
reg		[31:0]   pkt_transmitted;
reg		[31:0]   FMAC_TX_PKT_CNT;
reg 	[31:0]   accumulated_bcnt;
reg		[31:0]   FMAC_TX_BYTE_CNT;

parameter[4:0] 
    IDLE		= 5'h01 ,
	GET_WAIT1   = 5'h02 ,
	GET_WAIT2   = 5'h04 ,
	TX_DAT		= 5'h08 ,
	TX_CRC		= 5'h10 ;
reg    [4:0] state;

wire st_IDLE;			assign	st_IDLE			=	state[0];
wire st_GET_WAIT1;  	assign	st_GET_WAIT1	=	state[1];
wire st_GET_WAIT2;  	assign	st_GET_WAIT2	=	state[2];
wire st_TX_DAT;     	assign	st_TX_DAT		=	state[3];
wire st_TX_CRC;        	assign	st_TX_CRC		=	state[4];

assign nbytes = {(rbytes_dly[15:3] + |rbytes_dly[2:0]),3'b000};

//-------------------------------------------------------------------------------
//   BUFFER
//-------------------------------------------------------------------------------
always@(posedge clk156)
begin
	rts_dly		<=	rts;
	rdata_dly	<=	(cntr_4 == 2'b00)?	rdata [63:0]	:
					(cntr_4 == 2'b01)?	rdata [127:64]	:
					(cntr_4 == 2'b10)?	rdata [191:128]	:
					rdata [255:192];
	rbytes_dly	<=	rbytes;
	
	cntr_4		<=	(!rst_ | rts | (cntr_4 == 2'b11))?	2'b0	:
						(mode_10G)?	(cntr_4 + 1'b1)	:
						cntr_4;

	bdata1 <=   rdata_dly;
	bdata2 <=   bdata1;
	nbytes_reg <= nbytes;
	rbytes_reg <= rbytes_dly;
end

//-------------------------------------------------------------------------------
//   FMAC_TX_PKT_CNT REGISTER
//-------------------------------------------------------------------------------

always@ (posedge clk156)
begin
	if (!rst_)
	begin
		sent	<=	1'b0;
		sent_dly <= 1'b0;
	end
	
	else
	begin
		sent	<=	st_TX_CRC;
		sent_dly <= sent;
	end
end

always@ (posedge clk156)
begin
	if (!rst_)
		pkt_transmitted	<=	32'h0;
	else
		pkt_transmitted	<=	(sent)? (pkt_transmitted + 32'h1) : pkt_transmitted ;
end

//============== SYNC the reg for output to internal logic

reg		capture_en0_clk250;
reg		capture_en1_clk250;

//detect the capture en for clk250 (if see 2 zeroes in a row)
wire	capture_en_clk250 = capture_en0_clk250 & capture_en1_clk250;

always @ (posedge clk250)
	begin
		//if see 2 zero in a row (not updating by clk125), can capture the data
	capture_en0_clk250	<= !sent;
	capture_en1_clk250	<=  capture_en0_clk250;
	
	//if (!rst_ | fmac_tx_pkt_cnt_clr)
	if ( !rst_ )
		FMAC_TX_PKT_CNT <= 32'h0;
	else
		// capture if enabled
		FMAC_TX_PKT_CNT	<= (capture_en_clk250) ? pkt_transmitted : FMAC_TX_PKT_CNT;
	
	end

/************* CLE 12may10
always @ (posedge clk250)
begin
	if (!rst_)
		statistic_ok <= 1'b0;
	else
		statistic_ok <= sent_dly;
		
end

always @ (posedge clk250)
begin
	if (!rst_)
		FMAC_TX_PKT_CNT <= 32'h0;
		
	else
		FMAC_TX_PKT_CNT <= statistic_ok? pkt_transmitted : FMAC_TX_PKT_CNT ;
		// Make sure capture pkt_transmitted when its value is stable
end
****************/

//-------------------------------------------------------------------------------
//   FMAC_TX_BYTE_CNT REGISTER with auto clear
//-------------------------------------------------------------------------------
always@ (posedge clk156)
begin
	if (!rst_ | fmac_tx_clr_en)
		accumulated_bcnt	<=	32'h0;
	else
		//internal clk125 byte cnt reg
		accumulated_bcnt	<=	(sent)? (accumulated_bcnt + rbytes_reg) : accumulated_bcnt ;
end

	//clk250 BYTE CNT reg
always @ (posedge clk250)
begin
	if (!rst_ | fmac_tx_clr_en)
		FMAC_TX_BYTE_CNT <= 32'h0;
		
	else
		//FMAC_TX_BYTE_CNT <= statistic_ok? accumulated_bcnt : FMAC_TX_BYTE_CNT ;
		// Make sure capture pkt_transmitted when its value is stable
		FMAC_TX_BYTE_CNT <= capture_en_clk250? accumulated_bcnt : FMAC_TX_BYTE_CNT ;
end

//-------------------------------------------------------------------------------
//  STATE MACHINE
//-------------------------------------------------------------------------------
always@(posedge clk156)
if(!rst_)
begin
	state <=   IDLE;
	xgmii_txd   <=   64'h0707070707070707; // IDLE for xgmii interface (normal inter-frame)
	xgmii_txc   <=   8'hff; 

	txc_int <=   8'hff;
	IDLE_sel  <=   1;
	insert_crc<=   0;

	wcnt <=   0;
	
	crc_we_ <=   1;
	crc_last_<=   1;
	crc_cnt  <=   0;
	crc_clr_ <=   1;
end
else
begin
	//on last qwd in TX_DATa state, insert CRC & EOF
	if (IDLE_sel)	//allow elec idle to be inserted
		begin 
		if (insert_crc)
			begin 
				//depends on the pkt's byte cnt (last 3 bits indicate the offset
				//to where CRC and EOF should be inserted.
			case (rbytes_reg[2:0])
			3'd0: xgmii_txd <=   {32'h070707FD, crc32 };
			3'd1: xgmii_txd <=   {64'h0707070707070707};
			3'd2: xgmii_txd <=   {64'h0707070707070707};
			3'd3: xgmii_txd <=   {64'h0707070707070707};
			3'd4: xgmii_txd <=   {64'h07070707070707FD};
			3'd5: xgmii_txd <=   {32'h07070707, 24'h0707FD, crc32[31:24] };
			3'd6: xgmii_txd <=   {32'h07070707, 16'h07FD, crc32[31:16] };
			3'd7: xgmii_txd <=   {32'h07070707, 8'hFD, crc32[31:8] };
			endcase	
			end
			
		else xgmii_txd <=   64'h0707070707070707;
		end
		
	else
		begin
			//on last qwd transmit (in states other than TX_DATa)
			//insert CRC and EOF depends on last 3 bits if pkt bcnt
		if (wcnt[15])
			begin
			case (rbytes_reg[2:0])
			3'd0: xgmii_txd <=   {bdata2[63:32], bdata2[31:0] };
			3'd1: xgmii_txd <=   {24'h0707FD, crc32[31:0], bdata2[7:0] };
			3'd2: xgmii_txd <=   {16'h07FD, crc32[31:0], bdata2[15:0] };
			3'd3: xgmii_txd <=   {8'hFD, crc32[31:0], bdata2[23:0] };
			3'd4: xgmii_txd <=   {crc32, bdata2[31:0]};
			3'd5: xgmii_txd <=   {crc32[23:0], bdata2[39:0] };
			3'd6: xgmii_txd <=   {crc32[15:0], bdata2[47:0] };
			3'd7: xgmii_txd <=   {crc32[7:0], bdata2[55:0] };
			endcase
				
			end
		
		else xgmii_txd <=   {bdata2[63:0]};
		end
	
	xgmii_txc  <=   txc_int;
	insert_crc <=   (st_TX_DAT && wcnt[15]);

	crc_we_    <=   crc_we_ ? !st_GET_WAIT1 : !crc_last_; // enable begins at state3, disable at 
	crc_last_  <=   crc_last_ ? (crc_we_ || !crc_cnt[15]) : 1'b1;
	crc_cnt    <=   st_GET_WAIT1 ? (rbytes_dly - 16'd17) : ((st_GET_WAIT2 || st_TX_DAT)? (crc_cnt - 16'd8) : crc_cnt); 
	crc_clr_   <=   !(st_IDLE || st_TX_CRC);
	
	case(state)
	IDLE:
	begin
		state <= rts_dly? GET_WAIT1: IDLE;
	end

	GET_WAIT1:
	begin
		state <=   GET_WAIT2;
	end

	GET_WAIT2:
	begin
		state   <=   TX_DAT;   // 1st data cascade to bdata2
			//load the total bcnt of the packet (-1 by 1 to prepare for the negative detection)
		wcnt    <=   nbytes_reg - 16'd1;
		txc_int <=   8'h01;
		IDLE_sel<=   1'b0;
	end
	
	TX_DAT:
	begin
		state  <=   wcnt[15] ? TX_CRC : TX_DAT; // 2nd data cascade to bdata2
		txc_int<=   8'h00;
		IDLE_sel <=   wcnt[15];
		wcnt   <=   wcnt - 16'd8;
		if (wcnt[15])
			begin
			case (rbytes_reg[2:0])
			3'd0: txc_int <=   8'hF0;
			3'd1: txc_int <=   8'hFF;
			3'd2: txc_int <=   8'hFF;
			3'd3: txc_int <=   8'hFF;
			3'd4: txc_int <=   8'hFF;
			3'd5: txc_int <=   8'hFE;
			3'd6: txc_int <=   8'hFC;
			3'd7: txc_int <=   8'hF8;
			endcase
			end
		else
			begin
			if (wcnt <= 7)
				begin
				case (rbytes_reg[2:0])
				3'd0: txc_int <=   8'h00;
				3'd1: txc_int <=   8'hE0;
				3'd2: txc_int <=   8'hC0;
				3'd3: txc_int <=   8'h80;
				3'd4: txc_int <=   8'h00;
				3'd5: txc_int <=   8'h00;
				3'd6: txc_int <=   8'h00;
				3'd7: txc_int <=   8'h00;
				endcase
				end
		else txc_int <=   8'h00;
			end
	end
	TX_CRC:
	begin
		state <=   (rts_dly)? GET_WAIT1: IDLE;
		txc_int<=   8'hff;
	end
	
	default:
	begin
		state <=   IDLE;
	end
	endcase
end

//winlord_mac10g_crc32x64 winlord_mac10g_crc32x64(
tx_mac10g_crc32x64 tx_mac10g_crc32x64(

   	.clk (clk156),
   	.rst_(rst_),
   	
   	.bytes  (rbytes_reg[2:0]), 			// correct crc32
   	//.bytes  (rbytes_reg[2:0]- 1'b1),	// insert wrong crc32 for testing
   	.clr_  (crc_clr_),
   	.we_   (crc_we_),
   	.last_ (crc_last_),
   	.cdin  (rdata_dly),
   	.pdin  (bdata1),
   	
   	.crc32({crc32[7:0],crc32[15:8],crc32[23:16],crc32[31:24]}),
   	.crc32_vld_()
    );
//================== SIMULATION & DEBUG BELOW ===========================    
   
   
//synopsys translate_off
reg [(32 *8)-1:0] ascii_state;
always@(state)
begin
	case(state)
	IDLE: ascii_state = "IDLE";
	GET_WAIT1: ascii_state = "GET_WAIT1";
	GET_WAIT2: ascii_state = "GET_WAIT2";
	TX_DAT: ascii_state = "TX_DAT";
	TX_CRC: ascii_state = "TX_CRC";
	default: ascii_state = "unknown";
	endcase
	
end
//synopsys translate_on
endmodule