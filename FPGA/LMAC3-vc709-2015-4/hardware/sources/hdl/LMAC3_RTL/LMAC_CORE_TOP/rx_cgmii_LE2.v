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

module tcore_rx_cgmii(
	clk156,				  	// i-1
	clk250,				  	// i-1
	rst_,				  	// i-1
                    	  	
	TCORE_MODE	,		  	// i-1
	
	xaui_mode	,		   	// i-1
                				                                                                         
   	mode_100G,				//i-1, speed_modes                       
   	mode_10G ,				//i-1                                    
	mode_50G ,				//i-1                                    
	mode_40G ,		        //i-1                                    
	mode_25G ,				//i-1                                    
                                                                                                         
	pkt_data	,		  	//o-256
    pkt_start	,		 	//o-1
	pkt_end		,		  	//o-1
	pkt_we		,			//o-1
	
	drx_pkt_data		,	//o-256
	drx_pkt_start 		,	//o-1
	drx_pkt_end 		,	//o-1
	drx_pkt_we 			,	//o-1
	drx_pkt_beat_bcnt	,	//o-5
	drx_pkt_be			,	//o-32
	drx_crc32 			,	//o-32
	drx_crc_vld 		,	//o-1
	drx_crc_err 		,	//o-1
	drx_crc_err_dly1 	,	//o-1
	
	wen,					//o-1
	waddr,					// o-param
	wptr,					// o-param
	raddr_marker,			// i-param

	rx_pause,			    // o-1
	rx_pvalue,				// o-16
	rx_pack,				// i-1
	                	
	pause_en,				// i-1
	bcast_en,				// i-1
	pmode,					// i-1, promiscuous mode enable bit
	daddr0,					// i-48
	                	
	rsize,					// i-12
	rxd,					// i-256
	rxc,					// i-32
	br_sof0,				// i-1, byte_reordering's sof0_out
	br_sof4,			    // i-1, byte_reordering's sof4_out
	
	//Incoming from Byte Reordering module
	br_sof8,
	br_sof12,
	br_sof16,
	br_sof20,
	br_sof24,
	br_sof28,
	
	rxp,				  	// i-8, not used, always 0
	
	fmac_ctrl1_dly	,		//i-32, contains the max_pkt_size and enable
	fmac_rxd_en	,			//i-1, from TSPE_CTRL1  reg
	
	FMAC_DCNT_OVERRUN,		// o-32
	FMAC_DCNT_LINK_ERR,		// o-32
	FMAC_PKT_CNT_OVERSIZE, 	// o-32
	FIFO_OV_IPEND,			// o-1
	
	clr_pkt_cnt_oversize,	// i-1
	
	add_lo_bcast	,		// o-1, these signals are 250Mhz pre-synced
	add_lo_mcast	,		// o-1  
	clr_carry_cast	,		// o-1 clr the carry of the B/Mcast group
	add_hi_cast		,		// o-1 add the HI reg of the B/Mcast group 
                                                        		
    vlan_ip,				//o-1
    normal_ip,				//o-1
    non_ip,					//o-1
    pkt_reject,				//o-1, EXTR use to drop the pkt at end
	pkt_jumbo_flag,		
	pkt_ipver,			
	
    wr_nbyte	,			//o-1
    nbytes_out		,		//o-16, pkt byte cnt
    rxfifo_full	, 			//i-1
	
	chk_crc,
	
	crc32_ok,			
	
	fmac_rx_clr_en
	
	);

	
parameter	RX_DRAM_DEPTH = 3072;	
parameter	RX_DRAM_ADDR_WIDTH = 12;


//Parameters for Data and control widths
parameter	DATA_WIDTH	=	256;
parameter	CTRL_WIDTH	=	32;
//--

input clk156;
input clk250;
input rst_;

input TCORE_MODE;

input xaui_mode;
                				                                                                         
input mode_100G;	//i-1, speed_modes                       
input mode_10G;		//i-1                                    
input mode_50G;		//i-1                                    
input mode_40G;		//i-1                                    
input mode_25G;		//i-1                                    
                                                                                                         
input pause_en;
input bcast_en;
input pmode;

input [47:0] daddr0;

input rx_pack;
output rx_pause;
output [15:0] rx_pvalue;

output	[DATA_WIDTH - 1:0]	pkt_data	;

//for sim only
	wire	[63:0]	pkt_dataA	= pkt_data[63:0] ;
	wire	[63:0]	pkt_dataB	= pkt_data[127:64] ;
	wire	[63:0]	pkt_dataC	= pkt_data[191:128] ;
	wire	[63:0]	pkt_dataD	= pkt_data[255:192] ;
//--

output		pkt_start	;	
output		pkt_end		;	
output		pkt_we		;

output	[DATA_WIDTH - 1:0]	drx_pkt_data	;
 
//for sim only
wire	[63:0]	drx_pkt_dataA	= drx_pkt_data[63:0] ;
wire	[63:0]	drx_pkt_dataB	= drx_pkt_data[127:64] ;
wire	[63:0]	drx_pkt_dataC	= drx_pkt_data[191:128] ;
wire	[63:0]	drx_pkt_dataD	= drx_pkt_data[255:192] ;
//--
            
output			drx_pkt_start ; 
output			drx_pkt_end ; 
output			drx_pkt_we ;

//CTRL_WIDTH
output	[4:0]					drx_pkt_beat_bcnt	;
output	[CTRL_WIDTH - 1 : 0]	drx_pkt_be	;
//--

output	[31:0]	drx_crc32 ;
output			drx_crc_vld ;
output			drx_crc_err ;
output			drx_crc_err_dly1 ;

//output to the DRAM buffer where the pkt from the Ethernet port is 1st stored
output wen;
output [RX_DRAM_ADDR_WIDTH-1:0] waddr;         	//current DRAM buffer Write Addr
input  [RX_DRAM_ADDR_WIDTH-1:0] raddr_marker;
output [RX_DRAM_ADDR_WIDTH:0] 	wptr; 			//pointer of the start of the last pkt

input  [DATA_WIDTH - 1:0] rxd;
input  [CTRL_WIDTH - 1:0] rxc;

// for simulation only
wire	[63:0]	rxdA	=	rxd[63:0];
wire	[63:0]	rxdB	=	rxd[127:64];
wire	[63:0]	rxdC	=	rxd[191:128];
wire	[63:0]	rxdD	=	rxd[255:192];
wire	[8:0]	rxcA	=	rxc[7:0];
wire	[8:0]	rxcB	=	rxc[15:8];
wire	[8:0]	rxcC	=	rxc[23:16];
wire	[8:0]	rxcD	=	rxc[31:24];
//--

input  [07:0] rxp;
input  [11:0] rsize;
input			br_sof4 ;


//Incoming from Byte Reordering module
input	br_sof0;
input	br_sof8;
input	br_sof12;
input	br_sof16;
input	br_sof20;
input	br_sof24;
input	br_sof28;
//--


input [31:0]	fmac_ctrl1_dly;

input			fmac_rxd_en	;

// To Register
output [31:0]	FMAC_DCNT_OVERRUN;
output [31:0]	FMAC_DCNT_LINK_ERR;
output [31:0]	FMAC_PKT_CNT_OVERSIZE;
output			FIFO_OV_IPEND;

input		clr_pkt_cnt_oversize	;	//control signal to clear the PKT_CNT_OVERSIZE reg

output		add_lo_bcast	;			// o-1, these signals are 250Mhz pre-synced
output		add_lo_mcast	;			// o-1  
output		clr_carry_cast	;			// o-1 clr the carry of the B/Mcast group
output		add_hi_cast		;			// o-1 add the HI reg of the B/Mcast group

output			vlan_ip ;
output			normal_ip ;
output			non_ip ;
output		    pkt_reject;
output		    pkt_jumbo_flag;			//o-1
output	[3:0]	pkt_ipver ;

output			wr_nbyte	;
output	[15:0]	nbytes_out		;
input			rxfifo_full	;

output	[31:0]	chk_crc;

output			crc32_ok;

input			fmac_rx_clr_en;


reg		wr_nbyte ;		

wire	sof_n_eof ;
reg		sof_n_eof_dly1, sof_n_eof_dly2 ;

reg		pre_eof	;

reg		[13:0]	MAX_PKT_SIZE	;		//this is a dynamic parameter vary from system to system
reg				pkt_slice_en	;

parameter	[15:0]	MAX_RSVD_SIZE = (16'd1138 + 8'd16);	
parameter	[15:0]	MAX_ALLOW		= (RX_DRAM_DEPTH - 8'd16)	;	

reg [RX_DRAM_ADDR_WIDTH-1:0] raddr_chk;		// buffer the raddr_marker from rx_decap
                                        	
reg [RX_DRAM_ADDR_WIDTH:0] 		wptr;   	
reg [RX_DRAM_ADDR_WIDTH-1:0] 	wrusedw;	//current used qwd in the DRAM buffer

reg			wrfull	;						//if full do not write in any more new pkt until the old one had read out
reg			space_ok;

reg			has_pre_sof ;
reg		   has_sof;							// use to detect a frame that has EOF but no SOF
reg		   has_sof_dly1;		

reg		   valid_frame;					   	// when see EOF, if does see that it has SOF, it is not valid

reg [5:0] bcnt;

reg	pre_sof;
reg sof;

reg sof_dly;
reg post_sof_dly;			//a 1 clk delay of SOF_DLY

reg		sof_pending ;	   	//must be quick enough to avoid racing conditions


reg rx_err0;
reg rx_err1;

reg rx_err2;
reg rx_err3;
reg rx_err4;
reg rx_err5;
reg rx_err6;
reg rx_err7;

reg err;

reg eof0;
reg eof1;

reg eof2;
reg eof3;
reg eof4;
reg eof5;
reg eof6;
reg eof7;

wire	br_sof0;
wire	br_sof8;
wire	br_sof12;
wire	br_sof16;
wire	br_sof20;
wire	br_sof24;
wire	br_sof28;

wire 	eof;
wire	eof_present ;	
wire	eof_with_data ;
reg		eof_with_data_dly1 ;

reg eof_dly;
reg eof_dly2;

reg		ok_clk250	;

//Parameterized data and control width added
reg [DATA_WIDTH - 1:0] bdata1;
reg [DATA_WIDTH - 1:0] bdata2;
reg [CTRL_WIDTH - 1:0] brxc1;

reg		[DATA_WIDTH - 1:0]	pkt_data	;
reg		no_start_pattern; 
reg		no_start_pattern_dly1;
reg		no_start_pattern_dly2;          

reg				pkt_start, pkt_end, pkt_we ;

reg [15:0] nbytes, nbytes_out;

reg [RX_DRAM_ADDR_WIDTH-1:0] waddr1; 
reg		   b2b_pkt;						// indicate packets that have only 1 or no Idle gap in between
reg		   reject;		

wire	pkt_reject = reject ;			//over all late rejection signal
reg		type_reject;					//protocol type reject

reg [RX_DRAM_ADDR_WIDTH-1:0] waddr, pre_waddr;

reg [11:0] upd_cnt;

reg overwrite;
reg first_time;
reg  wen1;
reg  wen, pre_wen;
reg  nowr;

reg baddr_hit;
reg bcast_addr;							//if 1, MAC dest addr is broadcast addr
reg mcast_addr;

reg paddr_hit;

wire [47:0] chk_daddr_order;
wire [47:0] qchk_daddr_order;

reg  [31:0] chk_crc = 32'h0;
reg  [31:0] chk_crc_dly = 32'h0;
reg  [15:0] rx_opcode;
reg  [15:0] rx_type;
reg  [15:0] rx_pvalue;
reg  [47:0] chk_daddr;

reg  [47:0] chk_daddr_dly1;

reg  [47:0] qchk_daddr;

reg  [07:0] rport;
reg  mac_hit;
reg  my_mac_hit;
reg  mcast_hit;	

reg  rx_pause;
reg  sof_dly2;

reg  opcode_pause;
reg  port0_hit;
reg  pmode_hit;

reg	vlan_ip	;
reg pppoe_ip ;

reg normal_ip ;

reg	isl_frame ;

reg [3:0] pkt_ipver;
wire pkt_jumbo_flag;
reg saddr_filter_drop_flag ;

//for 1G support
reg	[2:0]	count8 		;
reg			count8_en1 	;
reg			count8_en2 	;
reg			count8_en3  ;

reg			qwd0_time	;    

wire	[1:0]	fmac_speed 	= fmac_ctrl1_dly[17:16] ;


assign	sof_n_eof	= sof & (eof & has_sof) ;

//received MAC ADDR reordered from big endian
assign chk_daddr_order = {chk_daddr[7:0],chk_daddr[15:8],chk_daddr[23:16],chk_daddr[31:24],chk_daddr[39:32],chk_daddr[47:40]};
assign qchk_daddr_order = {qchk_daddr[7:0],qchk_daddr[15:8],qchk_daddr[23:16],qchk_daddr[31:24],qchk_daddr[39:32],qchk_daddr[47:40]};

wire advance_wptr;


assign	advance_wptr = 
			!wrfull &  sof_n_eof                & mac_hit & !reject               & !overwrite & !saddr_filter_drop_flag |
			!wrfull & !sof_n_eof_dly1 & eof_dly & mac_hit & !reject & valid_frame & !overwrite & !saddr_filter_drop_flag ;


wire	[7:0]	pre_stat2 = {isl_frame, 7'h0 };

always@(posedge clk156)
begin

	bdata1   <=   rxd;
	bdata2   <=   bdata1;
	
	//control bytes, if all 0, has data otherwise control is presence
	brxc1    <=   rxc;

	chk_crc_dly	<= chk_crc;

	if(eof0 || eof1 || eof2 || eof3 || eof4 || eof5 || eof6 || eof7)
		chk_crc		<=		chk_crc;
	else
	begin
		if (xaui_mode)
			case(brxc1)
			32'hfffffffe:	chk_crc		<=		{bdata1[7:0], bdata2[255:232]};
			32'hfffffffc:	chk_crc		<=		{bdata1[15:0],bdata2[255:240]};
			32'hfffffff8:	chk_crc		<=		{bdata1[23:0],bdata2[255:248]};
			32'hfffffff0:	chk_crc		<=		bdata1[31:0];
			32'hffffffe0:	chk_crc		<=		bdata1[39:8];
			32'hffffffc0:	chk_crc		<=		bdata1[47:16];
			32'hffffff80:	chk_crc		<=		bdata1[55:24];
			32'hffffff00:	chk_crc		<=		bdata1[63:32];
			            
			32'hfffffe00:	chk_crc		<=		bdata1[71:40];
			32'hfffffc00:	chk_crc		<=		bdata1[79:48];
			32'hfffff800:	chk_crc		<=		bdata1[87:56];
			32'hfffff000:	chk_crc		<=		bdata1[95:64];
			32'hffffe000:	chk_crc		<=		bdata1[103:72];
			32'hffffc000:	chk_crc		<=		bdata1[111:80];
			32'hffff8000:	chk_crc		<=		bdata1[119:88];
			32'hffff0000:	chk_crc		<=		bdata1[127:96];
			            
			32'hfffe0000:	chk_crc		<=		bdata1[135:104];
			32'hfffc0000:	chk_crc		<=		bdata1[143:112];
			32'hfff80000:	chk_crc		<=		bdata1[151:120];
			32'hfff00000:	chk_crc		<=		bdata1[159:128];
			32'hffe00000:	chk_crc		<=		bdata1[167:136];
			32'hffc00000:	chk_crc		<=		bdata1[175:144];
			32'hff800000:	chk_crc		<=		bdata1[183:152];
			32'hff000000:	chk_crc		<=		bdata1[191:160];
			            
			32'hfe000000:	chk_crc		<=		bdata1[199:168];
			32'hfc000000:	chk_crc		<=		bdata1[207:176];
			32'hf8000000:	chk_crc		<=		bdata1[215:184];
			32'hf0000000:	chk_crc		<=		bdata1[223:192];
			32'he0000000:	chk_crc		<=		bdata1[231:200];
			32'hc0000000:	chk_crc		<=		bdata1[239:208];
			32'h80000000:	chk_crc		<=		bdata1[247:216];
			32'h00000000:	chk_crc		<=		bdata1[255:224];
			
			default: 		chk_crc		<=		chk_crc;
			endcase
		else
			case(brxc1)
			32'hfffffffe:	chk_crc		<=		{bdata1[7:0], chk_crc[31:8]};
			32'hfffffffc:	chk_crc		<=		{bdata1[15:0],chk_crc[31:16]};
			32'hfffffff8:	chk_crc		<=		{bdata1[23:0],chk_crc[31:24]};
			32'hfffffff0:	chk_crc		<=		bdata1[31:0];
			32'hffffffe0:	chk_crc		<=		bdata1[39:8];
			32'hffffffc0:	chk_crc		<=		bdata1[47:16];
			32'hffffff80:	chk_crc		<=		bdata1[55:24];
			32'hffffff00:	chk_crc		<=		bdata1[63:32];
			
			32'hfffffe00:	chk_crc		<=		bdata1[71:40];
			32'hfffffc00:	chk_crc		<=		bdata1[79:48];
			32'hfffff800:	chk_crc		<=		bdata1[87:56];
			32'hfffff000:	chk_crc		<=		bdata1[95:64];
			32'hffffe000:	chk_crc		<=		bdata1[103:72];
			32'hffffc000:	chk_crc		<=		bdata1[111:80];
			32'hffff8000:	chk_crc		<=		bdata1[119:88];
			32'hffff0000:	chk_crc		<=		bdata1[127:96];
			            
			32'hfffe0000:	chk_crc		<=		bdata1[135:104];
			32'hfffc0000:	chk_crc		<=		bdata1[143:112];
			32'hfff80000:	chk_crc		<=		bdata1[151:120];
			32'hfff00000:	chk_crc		<=		bdata1[159:128];
			32'hffe00000:	chk_crc		<=		bdata1[167:136];
			32'hffc00000:	chk_crc		<=		bdata1[175:144];
			32'hff800000:	chk_crc		<=		bdata1[183:152];
			32'hff000000:	chk_crc		<=		bdata1[191:160];
			            
			32'hfe000000:	chk_crc		<=		bdata1[199:168];
			32'hfc000000:	chk_crc		<=		bdata1[207:176];
			32'hf8000000:	chk_crc		<=		bdata1[215:184];
			32'hf0000000:	chk_crc		<=		bdata1[223:192];
			32'he0000000:	chk_crc		<=		bdata1[231:200];
			32'hc0000000:	chk_crc		<=		bdata1[239:208];
			32'h80000000:	chk_crc		<=		bdata1[247:216];
			32'h00000000:	chk_crc		<=		bdata1[255:224];
			
			default: 		chk_crc		<=		chk_crc;
			endcase
		
	end

	//counting the number of data bytes in bdata
	case(brxc1)
	32'h00000001: bcnt		<=		6'd24;
	
	32'hfffffffe: bcnt		<=		6'd1;
	32'hfffffffc: bcnt		<=		6'd2;
	32'hfffffff8: bcnt		<=		6'd3;
	32'hfffffff0: bcnt		<=		6'd4;
	32'hffffffe0: bcnt		<=		6'd5;
	32'hffffffc0: bcnt		<=		6'd6;
	32'hffffff80: bcnt		<=		6'd7;
	32'hffffff00: bcnt		<=		6'd8;
	                  		  		
	32'hfffffe00: bcnt		<=		6'd9;
	32'hfffffc00: bcnt		<=		6'd10;
	32'hfffff800: bcnt		<=		6'd11;
	32'hfffff000: bcnt		<=		6'd12;
	32'hffffe000: bcnt		<=		6'd13;
	32'hffffc000: bcnt		<=		6'd14;
	32'hffff8000: bcnt		<=		6'd15;
	32'hffff0000: bcnt		<=		6'd16;
	                  		  		
	32'hfffe0000: bcnt		<=		6'd17;
	32'hfffc0000: bcnt		<=		6'd18;
	32'hfff80000: bcnt		<=		6'd19;
	32'hfff00000: bcnt		<=		6'd20;
	32'hffe00000: bcnt		<=		6'd21;
	32'hffc00000: bcnt		<=		6'd22;
	32'hff800000: bcnt		<=		6'd23;
	32'hff000000: bcnt		<=		6'd24;
	                  		  		
	32'hfe000000: bcnt		<=		6'd25;
	32'hfc000000: bcnt		<=		6'd26;
	32'hf8000000: bcnt		<=		6'd27;
	32'hf0000000: bcnt		<=		6'd28;
	32'he0000000: bcnt		<=		6'd29;
	32'hc0000000: bcnt		<=		6'd30;
	32'h80000000: bcnt		<=		6'd31;
	32'h00000000: bcnt		<=		6'd32;
	
	default: bcnt <=   32'd0;
	endcase

	
	chk_daddr <=   
		!rst_ ? 48'h0 :			
		(pre_sof & xaui_mode) ? ((no_start_pattern) ? bdata1[47:0] : bdata1[111:64]):
		chk_daddr;
		
	chk_daddr_dly1	<=	chk_daddr;
	//--

	port0_hit<=   (chk_daddr_order == daddr0);

	baddr_hit <=   (&chk_daddr) & bcast_en;
	
	bcast_addr	<=	(!rst_) ? 1'b0 : (&chk_daddr)	;

	mcast_addr	<=	(!rst_) ? 1'b0 : ( chk_daddr[31:0] == 32'h005E0001);

	//FAST checking of dest MAC ADDR	
	qchk_daddr <=   
		!rst_ ? 48'h0 :
		(no_start_pattern) ? bdata1[47:0] : bdata1[111:64];

	//Will go High if recieved destination address is either unicast(AF4E 0032 1200), multicast (0000 005E 0001) or broadcast(FFFF FFFF FFFF)
	my_mac_hit	<=
		!rst_ |		
		TCORE_MODE & sof & (qchk_daddr_order[47:23] == {24'h01005E, 1'b0}) ? 1'b0 :    //mcast in TCORE_MODE
		sof & (qchk_daddr_order == daddr0) |	//uni
		sof & (&qchk_daddr_order) |				//bcast, all 1's
		!TCORE_MODE & sof & (qchk_daddr_order[47:23] == {24'h01005E, 1'b0}) ? 1'b1 :    //mcast
		sof & (qchk_daddr_order != daddr0) ? 1'b0 :	
		my_mac_hit
		;
		
		mcast_hit	<=
		!rst_ ? 1'b0 :		
		(chk_daddr_order[47:23] == {24'h01005E, 1'b0}) ? 1'b1 :
		1'b0
		;
	
	//PAUSE stuffs
	paddr_hit <=   (chk_daddr_order == 48'h0180C2000001) && (rx_type == 16'h8808);
	
	opcode_pause <=   (rx_opcode == 16'h0001);
	
	isl_frame	<= 
		(!rst_) ? 1'b0 : 
		(pre_sof) ? 1'b0 : 
		(sof_dly2 ) &		 
				( ( chk_daddr_order[47:8] == 40'h01000C_0000) |
				  ( chk_daddr_order[47:8] == 40'h03000C_0000) ) ? 1'b1 :
		isl_frame ;
			
end

assign eof = (eof0 || eof1 || eof2 || eof3 || eof4 || eof5 || eof6 || eof7);

wire 	[RX_DRAM_ADDR_WIDTH:0]	wptr_plus_upd_cnt;
wire	[RX_DRAM_ADDR_WIDTH:0]	new_wptr;
wire 	[RX_DRAM_ADDR_WIDTH:0]	new_wptr_plus1;


assign			wptr_plus_upd_cnt = wptr + upd_cnt;

assign		    new_wptr = (wptr_plus_upd_cnt > (RX_DRAM_DEPTH-1))? (wptr_plus_upd_cnt - RX_DRAM_DEPTH) : wptr_plus_upd_cnt ;
assign 			new_wptr_plus1 = (wptr_plus_upd_cnt >= (RX_DRAM_DEPTH-1))? (wptr_plus_upd_cnt - (RX_DRAM_DEPTH-1)) : (wptr_plus_upd_cnt + 1);

wire	[RX_DRAM_ADDR_WIDTH:0]	wptr_plus1;
assign			wptr_plus1 = (wptr == (RX_DRAM_DEPTH-1))? 0 : (wptr[RX_DRAM_ADDR_WIDTH-1:0] + 8'd1);

wire	[RX_DRAM_ADDR_WIDTH-1:0]	waddr1_plus1;

assign			waddr1_plus1	=	(waddr1 == (RX_DRAM_DEPTH-1))? 0 : (waddr1 + 8'd1);

always @ (posedge clk156)
begin
	//indicating very first pkt written into the DRAM buffer
	first_time	 <=		
		//reset (indicating 1st pkt)
		(!rst_ | !fmac_rxd_en)? 1'b1 : 
		//if wptr incremented, negate
		((wptr != 0)? 1'b0 : 
		first_time);
end

//---------- PRE-detect some critical events ------------
assign	eof_present =  	(brxc1[0] && (bdata1[7:0] == 8'hFD))   || 
					(brxc1[1] && (bdata1[15:8] == 8'hFD))  || 
					(brxc1[2] && (bdata1[23:16] == 8'hFD)) || 
					(brxc1[3] && (bdata1[31:24] == 8'hFD)) ||
					
	         		(brxc1[4] && (bdata1[39:32] == 8'hFD)) || 
					(brxc1[5] && (bdata1[47:40] == 8'hFD)) || 
					(brxc1[6] && (bdata1[55:48] == 8'hFD)) || 
					(brxc1[7] && (bdata1[63:56] == 8'hFD)) ||
					
					(brxc1[8]  && (bdata1[71:64]   == 8'hFD)) || 
					(brxc1[9]  && (bdata1[79:72]   == 8'hFD)) || 
					(brxc1[10] && (bdata1[87:80]   == 8'hFD)) || 
					(brxc1[11] && (bdata1[95:88]   == 8'hFD)) ||
					                              
					(brxc1[12] && (bdata1[103:96]  == 8'hFD)) || 
					(brxc1[13] && (bdata1[111:104] == 8'hFD)) || 
					(brxc1[14] && (bdata1[119:112] == 8'hFD)) || 
					(brxc1[15] && (bdata1[127:120] == 8'hFD)) ||
					                              
					(brxc1[16] && (bdata1[135:128] == 8'hFD)) || 
					(brxc1[17] && (bdata1[143:136] == 8'hFD)) || 
					(brxc1[18] && (bdata1[151:144] == 8'hFD)) || 
					(brxc1[19] && (bdata1[159:152] == 8'hFD)) ||
					                              
					(brxc1[20] && (bdata1[167:160] == 8'hFD)) || 
					(brxc1[21] && (bdata1[175:168] == 8'hFD)) || 
					(brxc1[22] && (bdata1[183:176] == 8'hFD)) || 
					(brxc1[23] && (bdata1[191:184] == 8'hFD)) ||
					                              
					(brxc1[24] && (bdata1[199:192] == 8'hFD)) || 
					(brxc1[25] && (bdata1[207:200] == 8'hFD)) || 
					(brxc1[26] && (bdata1[215:208] == 8'hFD)) || 
					(brxc1[27] && (bdata1[223:216] == 8'hFD)) ||
					                              
					(brxc1[28] && (bdata1[231:224] == 8'hFD)) || 
					(brxc1[29] && (bdata1[239:232] == 8'hFD)) || 
					(brxc1[30] && (bdata1[247:240] == 8'hFD)) || 
					(brxc1[31] && (bdata1[255:248] == 8'hFD)) ;
//--

wire		no_data;

assign no_data	=	((brxc1 == 32'hFFFFFFFF) | (brxc1 == 32'hFFFFFFFE) | (brxc1 == 32'hFFFFFFFC) | (brxc1 == 32'hFFFFFFF8) | (brxc1 == 32'hFFFFFFF0)) ;

assign	eof_with_data =  eof_present & !no_data;
// These are the cases when data will have the end of frame pattern FD as well as the data. CRC should be excluded so the cases


always@(posedge clk156)
if( !rst_ | !fmac_rxd_en )
begin
	eof_with_data_dly1	<= 1'b0;
	
	raddr_chk <=   0;
	wr_nbyte       <=   1'b0;
	pre_wen       <=   1'b0;
	wen       <=   1'b0;
	wen1      <=   1'b0;
	pre_sof	  <=   1'b0;
	sof       <=   1'b0;
	sof_pending       <=   1'b0;				
	
	eof0      <=   1'b0;
	eof1      <=   1'b0;
	
	eof2      <=   1'b0;
	eof3      <=   1'b0;
	eof4      <=   1'b0;
	eof5      <=   1'b0;
	eof6      <=   1'b0;
	eof7      <=   1'b0;
	
	err       <=   1'b0;
	nbytes    <=   16'h0;
	nbytes_out    <=   16'h0;
	rx_err0   <=   1'b0;
	rx_err1   <=   1'b0;

	rx_err2   <=   1'b0;
	rx_err3   <=   1'b0;
	rx_err4   <=   1'b0;
	rx_err5   <=   1'b0;
	rx_err6   <=   1'b0;
	rx_err7   <=   1'b0;

	eof_dly   <=   1'b0;
	eof_dly2  <=   1'b0;
	overwrite <=   1'b0;
	wptr      <=   0;
	upd_cnt   <=   12'h0;
	waddr1    <=   0;
	b2b_pkt	  <=   1'b0;
	reject	  <=   1'b0;
	waddr     <=   0;
	pre_waddr     <=   0;
	
	wrfull		<= 1'b0;
	wrusedw		<= 0;
	space_ok	<= 1'b1;
	
	nowr      <=   1'b0;
	sof_dly   <=   1'b0;
	post_sof_dly   <=   1'b0;
	
	sof_dly2  <=   1'b0;
	mac_hit   <=   1'b0;
	rx_pvalue <=   16'h0;
	rx_pause  <=   1'b0;
	rx_opcode <=   16'h0;
	rx_type   <=   16'h0;
	rport     <=   8'h0;
	pmode_hit <=   1'b0;
	has_pre_sof		<=	1'b0;
	has_sof		<=	1'b0;
	has_sof_dly1		<=	1'b0;
	
	valid_frame	<=	1'b0;
	
	count8 		<= 3'd7;
	count8_en1 	<= 1'b0;
	count8_en2 	<= 1'b0;
	count8_en3  <= 1'b0;
	qwd0_time	<= 1'b0;
	
	no_start_pattern <= 1'b0;
	no_start_pattern_dly1 <= 1'b0;
	no_start_pattern_dly2 <= 1'b0;
end
else
begin

	no_start_pattern <= ((br_sof0 || br_sof4 || br_sof8 || br_sof12 || br_sof16 || br_sof20 || br_sof24 || br_sof28) && !((rxd[63:0] == 64'hd5555555555555FB) && rxc[7:0] == 8'h01));
	no_start_pattern_dly1 <= no_start_pattern;
	no_start_pattern_dly2 <= no_start_pattern_dly1;
	
	raddr_chk <=  raddr_marker; 
	pmode_hit <=   pmode;
	rx_pause  <=   rx_pause ? !rx_pack : ((pause_en && !rport[0])? (eof_dly2 && paddr_hit && opcode_pause) : 1'b0);
	
	//Equation changed as the opcode will come in the first cycle for 256G
	rx_opcode <=   (pre_sof)  ? ((no_start_pattern) ? {bdata1[119:112],bdata1[127:120]} : {bdata1[183:176],bdata1[191:184]}) : rx_opcode;	
	
	rx_type   <=   (pre_sof)  ? ((no_start_pattern) ? {bdata1[103:96],bdata1[111:104]} : {bdata1[167:160],bdata1[175:168]}) : rx_type;

	rx_pvalue <=   (pre_sof)  ? ((no_start_pattern) ? {bdata1[135:128],bdata1[143:136]} : {bdata1[199:192],bdata1[207:200]}) : rx_pvalue;

	//added mcast_hit ----->> Need to confirm
	mac_hit   <=   (port0_hit || baddr_hit || mcast_hit || pmode_hit) && !paddr_hit;

	rport     <=   sof ? rxp : rport;		

		
	sof_dly   <=   
		xaui_mode ? sof :
		(count8 == 3'd2) & count8_en2
		;
	post_sof_dly  <=   sof_dly;
	

	sof_dly2  <=   
		xaui_mode ? sof_dly :
		(count8 == 3'd2) & count8_en3
		;
		
	//do not write on error codes
	//if the last incoming qwd is 4 bytes, 3 bytes, 2 bytes, or 1 byte
	//  ie the last qword contain only CRC info
	nowr      <=   (brxc1 == 32'hfffffff0) || (brxc1 == 32'hfffffff8) || (brxc1 == 32'hfffffffc) || (brxc1 == 32'hfffffffe);
	//--

	upd_cnt   <=   
		(|nbytes[2:0]) ? (nbytes[14:3] + 12'd2) : 
		(nbytes[14:3] + 12'd1);   
		
	overwrite	<= 1'b0 ;	
	
	wr_nbyte	<=
		( wr_nbyte ) ? 1'b0 :
		(sof_n_eof & my_mac_hit & !type_reject |
		!sof_n_eof_dly1 & eof_dly & has_sof_dly1 & my_mac_hit & !type_reject ) ? 1'b1 : 
		1'b0 ;
		
	
	wen			<= pre_wen ;
	
	//added rx_err2 to 7 to the equation
	pre_wen     <=   
		//last data write for data mixing in EOF qwd (no CRC write.  Last eof_dqwd may have 1, 2, or 3 bytes)
		eof_with_data_dly1 & space_ok & has_sof ? 1'b1 :
		(wen1 & sof_pending & space_ok
			& !err & !rx_err0 & !rx_err1 & !rx_err2 & !rx_err3 & !rx_err4 & !rx_err5 & !rx_err6 & !rx_err7 
			& !overwrite 
			& !(sof |(nowr & eof)));
	
	wen1      <=   fmac_rxd_en & has_pre_sof 
						& !(&brxc1) 		
						& ( !eof_present  )
						& !err;
	
	pre_waddr     <=   
			//1st DRAM write addr is the WPTR aligned to Qwd
			(wrfull ) ? pre_waddr :
			//at end of normal write cycle, write the last one (NBYTE) to the beginning
			(sof_n_eof |			
			!sof_n_eof_dly1 & eof_dly & !reject )  ? wptr[RX_DRAM_ADDR_WIDTH-1:0] : 
			(!space_ok ) ? pre_waddr :
			waddr1;
			
	waddr	<= pre_waddr ;
			
	wrfull		<= rxfifo_full;
	
	wrusedw		<=		
		!(raddr_chk > wptr) ? (wptr - raddr_chk) :
		wptr + (RX_DRAM_DEPTH - raddr_chk)
		;
		
	space_ok	<= !rxfifo_full ;
	
	b2b_pkt	  <=   pre_sof & has_sof_dly1 & (eof | eof_dly);
	
	//added more rx_err conditions
	reject	  <=   
		//reject current data if EOF and got error or not enough space
		eof ? (err | rx_err0 | rx_err1 | rx_err2 | rx_err3 | rx_err4 | rx_err5 | rx_err6 | rx_err7 | overwrite | !space_ok | !mac_hit) : 
		(eof_dly2? 1'b0 : 
		reject);
	
	has_pre_sof		<=	pre_sof? 1'b1: 	
						(eof & !sof ? 1'b0 :
						has_pre_sof);		
						
	has_sof		<=	sof? 1'b1: 
						(eof? 1'b0 : 	
						has_sof);		
						
	has_sof_dly1	<= has_sof ;
							
	//only assert from EOF to EOF_DLY2 for advancing the WPTR
	valid_frame	<=	
		eof? has_sof : 
		eof_dly2? 1'b0 : 	
		valid_frame ; 
	
	//added more rx_err conditions
	err       <=   
		pre_sof ? 1'b0 : 
		//capture error conditions
		(rx_err0 || rx_err1 || rx_err2 || rx_err3 || rx_err4 || rx_err5 || rx_err6 || rx_err7 || err); 
	
	eof_dly   <=   eof;
	eof_dly2  <=   eof_dly;
	
	pre_sof	  <=   br_sof0 | br_sof4 | br_sof8 | br_sof12 | br_sof16 | br_sof20 | br_sof24 | br_sof28;
	
	sof		  <=	pre_sof & fmac_rxd_en;
	
	sof_pending	<=
		!fmac_rxd_en ? 1'b0 :
		//assert if seen SOF
		pre_sof & fmac_rxd_en ? 1'b1 :
		eof & !sof ? 1'b0 :
		sof_pending ;
	
					
	eof0      <=   	fmac_rxd_en & (brxc1[0] && (bdata1[7:0] == 8'hFD))   || 
					fmac_rxd_en & (brxc1[1] && (bdata1[15:8] == 8'hFD))  || 
					fmac_rxd_en & (brxc1[2] && (bdata1[23:16] == 8'hFD)) || 
					fmac_rxd_en & (brxc1[3] && (bdata1[31:24] == 8'hFD));
		
	eof1      <=   	fmac_rxd_en & (brxc1[4] && (bdata1[39:32] == 8'hFD)) || 
					fmac_rxd_en & (brxc1[5] && (bdata1[47:40] == 8'hFD)) || 
					fmac_rxd_en & (brxc1[6] && (bdata1[55:48] == 8'hFD)) || 
					fmac_rxd_en & (brxc1[7] && (bdata1[63:56] == 8'hFD));
	
	
		eof2      <=   	fmac_rxd_en & (brxc1[8] && (bdata1 [71:64]   == 8'hFD))  || 
						fmac_rxd_en & (brxc1[9] && (bdata1 [79:72]   == 8'hFD))  || 
						fmac_rxd_en & (brxc1[10] && (bdata1[87:80]   == 8'hFD)) || 
						fmac_rxd_en & (brxc1[11] && (bdata1[95:88]   == 8'hFD));
		
		eof3      <=   	fmac_rxd_en & (brxc1[12] && (bdata1[103:96]  == 8'hFD))  || 
						fmac_rxd_en & (brxc1[13] && (bdata1[111:104] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[14] && (bdata1[119:112] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[15] && (bdata1[127:120] == 8'hFD));
		
		eof4      <=   	fmac_rxd_en & (brxc1[16] && (bdata1[135:128] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[17] && (bdata1[143:136] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[18] && (bdata1[151:144] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[19] && (bdata1[159:152] == 8'hFD));
		
		eof5      <=   	fmac_rxd_en & (brxc1[20] && (bdata1[167:160] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[21] && (bdata1[175:168] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[22] && (bdata1[183:176] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[23] && (bdata1[191:184] == 8'hFD));
		
		eof6      <=   	fmac_rxd_en & (brxc1[24] && (bdata1[199:192] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[25] && (bdata1[207:200] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[26] && (bdata1[215:208] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[27] && (bdata1[223:216] == 8'hFD));
		
		eof7      <=   	fmac_rxd_en & (brxc1[28] && (bdata1[231:224] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[29] && (bdata1[239:232] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[30] && (bdata1[247:240] == 8'hFD)) || 
						fmac_rxd_en & (brxc1[31] && (bdata1[255:248] == 8'hFD));

	//Equation change
	// FE pattern is for "Transmit error propogation"
	rx_err0   <=   (brxc1[0] && (bdata1[7:0] == 8'hFE)) || (brxc1[1] && (bdata1[15:8] == 8'hFE)) || (brxc1[2] && (bdata1[23:16] == 8'hFE)) || (brxc1[3] && (bdata1[31:24] == 8'hFE));
	rx_err1   <=   (brxc1[4] && (bdata1[39:32] == 8'hFE)) || (brxc1[5] && (bdata1[47:40] == 8'hFE)) || (brxc1[6] && (bdata1[55:48] == 8'hFE)) || (brxc1[7] && (bdata1[63:56] == 8'hFE));
	rx_err2   <=   (brxc1[8] && (bdata1[71:64] == 8'hFE)) || (brxc1[9] && (bdata1[79:72] == 8'hFE)) || (brxc1[10] && (bdata1[87:80] == 8'hFE)) || (brxc1[11] && (bdata1[95:88] == 8'hFE));
	rx_err3   <=   (brxc1[12] && (bdata1[103:96] == 8'hFE)) || (brxc1[13] && (bdata1[111:104] == 8'hFE)) || (brxc1[14] && (bdata1[119:112] == 8'hFE)) || (brxc1[15] && (bdata1[127:120] == 8'hFE));
	rx_err4   <=   (brxc1[16] && (bdata1[135:128] == 8'hFE)) || (brxc1[17] && (bdata1[143:136] == 8'hFE)) || (brxc1[18] && (bdata1[151:144] == 8'hFE)) || (brxc1[19] && (bdata1[159:152] == 8'hFE));
	rx_err5   <=   (brxc1[20] && (bdata1[167:160] == 8'hFE)) || (brxc1[21] && (bdata1[175:168] == 8'hFE)) || (brxc1[22] && (bdata1[183:176] == 8'hFE)) || (brxc1[23] && (bdata1[191:184] == 8'hFE));
	rx_err6   <=   (brxc1[24] && (bdata1[199:192] == 8'hFE)) || (brxc1[25] && (bdata1[207:200] == 8'hFE)) || (brxc1[26] && (bdata1[215:208] == 8'hFE)) || (brxc1[27] && (bdata1[223:216] == 8'hFE));
	rx_err7   <=   (brxc1[28] && (bdata1[231:224] == 8'hFE)) || (brxc1[29] && (bdata1[239:232] == 8'hFE)) || (brxc1[30] && (bdata1[247:240] == 8'hFE)) || (brxc1[31] && (bdata1[255:248] == 8'hFE));
	
	nbytes    <=
		sof ? (bcnt - 3'd4) :  
		(wen1 |
			eof & (bcnt < 8'd32) ? (nbytes + bcnt) :
		nbytes);
	 		
	nbytes_out	<= nbytes	;
	
	wptr[RX_DRAM_ADDR_WIDTH-1:0]      <=   advance_wptr ? waddr1 : wptr;
	
	//count every 8 clks (for assembling to 64 bits)
	count8 		<= (count8_en1 | count8_en2 | count8_en3)? (count8 - 3'd1) : 3'd7 ;
	
	count8_en1 	<= 
		//see SOF assert
		sof? 1'b1 : 
		(qwd0_time? 1'b0 : 
		count8_en1);
		
	count8_en2 	<= 
		qwd0_time? 1'b1 : 
		(sof_dly ? 1'b0 : 
		count8_en2);
		
	count8_en3 	<= 
		sof_dly ? 1'b1 : 
		(sof_dly2? 1'b0 : 
		count8_en3);
	
	qwd0_time   <=   (count8 == 3'd2) & count8_en1;  
	
	if (sof_n_eof )
		waddr1	<= waddr1 + 4'd1 ;
	else	

	casez ({eof_with_data_dly1, wrfull, sof, b2b_pkt, reject, wen1, has_sof})
		7'b0010??? :	waddr1	<=	wptr_plus1 ;		// restart, 2 or more gap between packets, wptr is already valid
		
		7'b00111?? :	waddr1	<=	wptr_plus1 ;		// 1 or 0 gap between packets but drop the packet, restart
		
		7'b00110?? : 	waddr1	<=	waddr1_plus1;		// 1 or 0 gap between packets, wptr is not valid yet,
														//must take wrap into account
		7'b000??11 : 	waddr1	<=	waddr1_plus1 ;		// advance addr for consecutive write
		
		7'b100???1 :	waddr1	<=	waddr1_plus1 ;
		
		default	:	waddr1	<=	waddr1 ;				//hold if full
	endcase
	
	eof_with_data_dly1	<= eof_with_data;

end


// Logic : Pre-Detetcion of IPv version , Jumbo Pkt , Vlan
reg		qvlan_type;
wire	vlan_type;
wire	pppoe_session_type;
wire	pppoe_disc_type;

wire	vlan_ip_type;	   //VLAN and next layer is IP
wire	pppoe_ip_type;	   //PPPoE and next layer is IP
wire	normal_ip_type;	   //normal IP packet and next layer is IP
reg		qnormal_ip_type;

reg		qenet_arp_pkt ;

wire	no_start_pattern_wire;

assign	no_start_pattern_wire = ((br_sof0 || br_sof4 || br_sof8 || br_sof12 || br_sof16 || br_sof20 || br_sof24 || br_sof28) && !((rxd[63:0] == 64'hd5555555555555FB) && rxc[7:0] == 8'h01));

//ARP -> 0100 0608, NIP -> 0045 0008, VLAN -> 0000 0081 Changed assign statement to always block
//Changed no_start_pattern to no_start_pattern_wire
always@(posedge clk156) begin
	if(!rst_) begin
		qnormal_ip_type		<=		1'b0;
		qvlan_type			<=		1'b0;
		qenet_arp_pkt		<=		1'b0;
	end
	else
	begin
		qnormal_ip_type 	<= (no_start_pattern_wire) ? ((rxd[103:96]==8'h08)&&(rxd[111:104]==8'h00)) : ((rxd[167:160]==8'h08)&&(rxd[175:168]==8'h00)) ;
		qvlan_type 			<= (no_start_pattern_wire) ? ((rxd[103:96]==8'h81)&&(rxd[111:104]==8'h00)) : ((rxd[167:160]==8'h81)&&(rxd[175:168]==8'h00));
		qenet_arp_pkt		<= (no_start_pattern_wire) ? (rxd[127:96] == 32'h0100_0608) : (rxd[191:160] == 32'h0100_0608) ;
	end
end

assign	normal_ip_type 		= (no_start_pattern)	?	(bdata1[103:96]==8'h08)&&(bdata1[111:104]==8'h00) :	(bdata1[167:160]==8'h08)&&(bdata1[175:168]==8'h00)	;
assign	vlan_type 			= (no_start_pattern)	?	(bdata1[103:96]==8'h81)&&(bdata1[111:104]==8'h00) :	(bdata1[167:160]==8'h81)&&(bdata1[175:168]==8'h00)	;
assign	pppoe_session_type 	= (no_start_pattern)	?	(bdata1[103:96]==8'h88)&&(bdata1[111:104]==8'h64) :	(bdata1[167:160]==8'h88)&&(bdata1[175:168]==8'h64)	;
assign	pppoe_disc_type 	= (no_start_pattern)	?	(bdata1[103:96]==8'h88)&&(bdata1[111:104]==8'h63) :	(bdata1[167:160]==8'h88)&&(bdata1[175:168]==8'h63)	;

assign	vlan_ip_type		=	vlan_type;

assign	pppoe_ip_type		=	pppoe_session_type;
			
reg		non_ip ;

	
always@(posedge clk156)
if(!rst_)
begin
	normal_ip			<= 1'b0 ;
	vlan_ip				<= 1'b0 ;
	pppoe_ip		 	<= 1'b0 ;
	
	pkt_ipver 		<= 4'd0 ;
	non_ip			<= 1'b0 ;
	type_reject		<= 1'b0 ;
end
else
begin

//sof_dly changed to pre_sof
	normal_ip	<=	pre_sof ? normal_ip_type : normal_ip ;
	
	vlan_ip		<=	
		 xaui_mode & pre_sof  ? vlan_ip_type : 
		!xaui_mode & sof ? vlan_ip_type : 
		vlan_ip ;
	
	non_ip		<= !(vlan_ip | normal_ip) ;
			
	pppoe_ip <= 
			 xaui_mode & pre_sof  ? pppoe_ip_type :  
			!xaui_mode & sof ? pppoe_ip_type :  
			pppoe_ip ;
	
	//sof changed to pre_sof	
   //reject unwanted pkt types
	type_reject	<=	
		pre_sof & !(qnormal_ip_type | qvlan_type | qenet_arp_pkt) ? 1'b1  :
		pre_sof &  (qnormal_ip_type | qvlan_type | qenet_arp_pkt) ? 1'b0  :
		type_reject
		;
	
	//Might need modifications
	pkt_ipver      <= 
		xaui_mode & sof_dly ? 
					//if VLAN & IP case, use next qwd bit 23:20
					( (vlan_ip_type) ? rxd[23:20] :  
					//if PPPoE_Session & IP Type
					  (pppoe_ip_type) ? rxd[55:52] :
					  (normal_ip_type) ? bdata1[55:52] :
					   4'he ) : 	
		!xaui_mode & sof_dly & (normal_ip_type) ? bdata1[55:52] : 
					//if VLAN & IP case, use next qwd bit 23:20
		!xaui_mode & sof_dly2 & (vlan_ip_type) ? bdata1[23:20] : 
					//if PPPoE_Session & IP Type
		!xaui_mode & sof_dly2 & (pppoe_ip_type) ? bdata1[55:52] : 
					pkt_ipver ;
	
	
					
end


assign pkt_jumbo_flag = (nbytes>16'd1500) ? 1'b1 : 1'b0 ;


always@(posedge clk156)
if(!rst_)
begin
	saddr_filter_drop_flag <= 0 ;
end
else
begin
	saddr_filter_drop_flag <= 
					eof_dly2 ? 1'b0 : 
					saddr_filter_drop_flag ;
end

// REGISTER and SYNCHRONIZATION
reg [31:0]	no_space_drop_cnt;
reg			no_space_drop;
reg [31:0]	FMAC_DCNT_OVERRUN;	

reg [31:0]	bad_link_drop_cnt;
reg			bad_link_drop;

reg [31:0]	FMAC_DCNT_LINK_ERR;	
reg			FIFO_OV_IPEND;		

reg [31:0]	FMAC_PKT_CNT_OVERSIZE;	
reg			pkt_oversize;

always @ (posedge clk156)
begin
	if (!rst_)
	begin
		no_space_drop_cnt <= 32'h0;
		no_space_drop <= 1'b0;
		
		bad_link_drop_cnt <= 32'h0;
		bad_link_drop <= 1'b0;
		
		MAX_PKT_SIZE	<=	14'd1518	;
		pkt_slice_en	<=	1'b0	;
		
		pkt_oversize <= 1'b0	;
		
		sof_n_eof_dly1	<= 1'b0 ;
		sof_n_eof_dly2	<= 1'b0 ;
	end
	
	else
	begin
		sof_n_eof_dly1	<= sof_n_eof ;
		sof_n_eof_dly2	<= sof_n_eof_dly1 ;
	
		MAX_PKT_SIZE	<=	fmac_ctrl1_dly[13:0]	;
		pkt_slice_en	<=	fmac_ctrl1_dly[15]		;
		
		no_space_drop_cnt <= no_space_drop? (no_space_drop_cnt + 32'd1) : no_space_drop_cnt;
		
		no_space_drop <= 
			sof & !space_ok;
		
		bad_link_drop_cnt <= bad_link_drop? (bad_link_drop_cnt + 32'd1) : bad_link_drop_cnt;
		
		//added more conditions for error
		bad_link_drop <= eof & (err | rx_err0 | rx_err1 | rx_err2 | rx_err3 | rx_err4 | rx_err5 | rx_err6 | rx_err7);
		
		pkt_oversize	<= 
				eof_dly2 ? 1'b0 : 
				( eof_dly & (nbytes > MAX_PKT_SIZE) ) ? 1'b1 :
				pkt_oversize;
	end
end

//============== SYNC the reg for output to internal logic

reg		no_space_drop0_clk250;
reg		no_space_drop1_clk250;

reg		bad_link_drop0_clk250;
reg		bad_link_drop1_clk250;

//detect the capture en for clk250 (if see 2 zeroes in a row)
wire	no_space_drop_clk250 = no_space_drop0_clk250 & no_space_drop1_clk250;
wire	bad_link_drop_clk250 = bad_link_drop0_clk250 & bad_link_drop1_clk250;

always @ (posedge clk250)
	begin
	no_space_drop0_clk250	<= !no_space_drop;
	no_space_drop1_clk250	<=  no_space_drop0_clk250;
	
	bad_link_drop0_clk250	<= !bad_link_drop;
	bad_link_drop1_clk250	<=  bad_link_drop0_clk250;
	end

	
wire	no_space_drop_ok = no_space_drop_clk250;
wire	bad_link_drop_ok = bad_link_drop_clk250;

reg		sof_dly3;

always @ (posedge clk250)
begin
	if (!rst_)
	begin
		FMAC_DCNT_OVERRUN <= 32'h0;
		
		FMAC_DCNT_LINK_ERR <= 32'h0;
		
		FIFO_OV_IPEND <= 1'b0;
		
	end
	
	else
	begin
		
		FMAC_DCNT_OVERRUN <= fmac_rx_clr_en ? 32'h0 : (no_space_drop_ok? no_space_drop_cnt : FMAC_DCNT_OVERRUN);
		
		FMAC_DCNT_LINK_ERR <= fmac_rx_clr_en ? 32'h0 : (bad_link_drop_ok? bad_link_drop_cnt : FMAC_DCNT_LINK_ERR);
		
		FIFO_OV_IPEND <= no_space_drop_ok;
	end
end


//====== SUPPORT FOR COUNTING B/MCAST, OverSize PKTS

reg		add_lo_bcast156	;
reg		add_lo_mcast156	;

reg		add_lo_bcast	;
reg		add_lo_mcast	;

reg		clr_carry_cast	;
reg		add_hi_cast		;


reg		eof_sync_wait	;

reg		eof_sync_wait_dly	;
reg		clr_pkt_cnt_oversize_dly	;


always @(posedge clk156)
	if (!rst_)
		begin
		add_lo_bcast156		<= 1'b0;
		add_lo_mcast156		<= 1'b0;
		sof_dly3			<= 1'b0;	
		end
		
	else
		begin

	sof_dly3	<=		sof_dly2;
				
		add_lo_bcast156		<= 
				(eof_dly2) ? 1'b0 :
				(eof_dly & bcast_addr) ? 1'b1 :
				add_lo_bcast156
				;

		add_lo_mcast156		<= 
				(eof_dly2) ? 1'b0 :
				(eof_dly & mcast_addr) ? 1'b1 :
				add_lo_mcast156
				;
				
		end


reg		ok_clk250_dly1;
reg		ok_clk250_dly2;
reg		ok_clk250_dly3;
reg		ok_clk250_dly4;


always @(posedge clk250)
	if (!rst_)
		begin

		ok_clk250			<= 1'b0;
		
		ok_clk250_dly1		<= 1'b0 ;
		ok_clk250_dly2		<= 1'b0 ;
		ok_clk250_dly3		<= 1'b0 ;
		ok_clk250_dly4		<= 1'b0 ;
		
		
		eof_sync_wait		<= 1'b0;
		
		
		eof_sync_wait_dly	<= 1'b0;
		
		end
	
	else
		begin
		ok_clk250			<=
				//clear if set
				ok_clk250 ? 1'b0 :
				//asserts when seeing the 1st valid EOF
				(!ok_clk250 & eof) ? 1'b1 :
				ok_clk250;
						
		ok_clk250_dly1		<= ok_clk250 ;
		ok_clk250_dly2		<= ok_clk250_dly1 ;
		ok_clk250_dly3		<= ok_clk250_dly2 ;
		ok_clk250_dly4		<= ok_clk250_dly3 ;
		
		//Equation changed. eof_sync_wait used to stay asserted for 4 clocks, now only for 1 clock. Written as assign statement
		eof_sync_wait				<= 
							eof_sync_wait ? 1'b0 :
							ok_clk250_dly1 ? 1'b1 :
							eof_sync_wait;
							
		eof_sync_wait_dly			<= eof_sync_wait ;

		end

//Equation changed. eof_sync_wait used to stay asserted for 4 clocks, now only for 1 clock	
always @(posedge clk250)
	if (!rst_)
		begin
		add_lo_bcast	<= 1'b0 ;
		add_lo_mcast	<= 1'b0 ;
		clr_carry_cast	<= 1'b0 ;
		add_hi_cast		<= 1'b0 ;
		end
		
	else
		begin
		add_lo_bcast	<= add_lo_bcast156 & !eof_sync_wait & ok_clk250_dly1 ;
		add_lo_mcast	<= add_lo_mcast156 & !eof_sync_wait & ok_clk250_dly1 ;
		
		clr_carry_cast	<= ok_clk250_dly3 ;
		
		add_hi_cast		<= ok_clk250_dly1 & !eof_sync_wait_dly  ;		
		end


reg		dly_between_pkts, dly_between_pkts_dly1;

always@(posedge clk250) begin
	if (!rst_) begin
		dly_between_pkts		<=		1'b0;
		dly_between_pkts_dly1		<=		1'b0;
	end
	else begin
		dly_between_pkts		<=		(brxc1 == 32'hFF_FF_FF_FF) & (bdata1 			==	256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707) 	|
										(brxc1 == 32'hFF_FF_FF_FF) & (bdata1 			==	256'h0707070707070707_0707070707070707_0707070707070707_07070707070707FD) 	|
										(brxc1 == 32'hFF_FF_FF_FE) & (bdata1[255:8] 	== 	248'h0707070707070707_0707070707070707_0707070707070707_070707070707FD) 	|
										(brxc1 == 32'hFF_FF_FF_FC) & (bdata1[255:16] 	== 	240'h0707070707070707_0707070707070707_0707070707070707_0707070707FD) 		|
										(brxc1 == 32'hFF_FF_FF_F8) & (bdata1[255:24] 	== 	232'h0707070707070707_0707070707070707_0707070707070707_07070707FD) 		|
										(brxc1 == 32'hFF_FF_FF_F0) & (bdata1[255:32] 	== 	224'h0707070707070707_0707070707070707_0707070707070707_070707FD) 			;
		dly_between_pkts_dly1	<=		dly_between_pkts;
	end
end

reg		ok_clk250_dly;

always @(posedge clk250)
	if (!rst_)
		begin
		FMAC_PKT_CNT_OVERSIZE		<= 32'h0 ;
		
		clr_pkt_cnt_oversize_dly	<= 1'b0	;
		
		ok_clk250_dly				<= 1'b0;
		end
		
	else
		begin
		clr_pkt_cnt_oversize_dly <= clr_pkt_cnt_oversize;
		
		ok_clk250_dly			<=		ok_clk250;
		
		FMAC_PKT_CNT_OVERSIZE	<= 
				(clr_pkt_cnt_oversize_dly | fmac_rx_clr_en) ? 32'h0 :
				(ok_clk250_dly & !eof_sync_wait_dly & pkt_oversize ) ? FMAC_PKT_CNT_OVERSIZE + 1'b1 :				
				FMAC_PKT_CNT_OVERSIZE;
				
		
		end
		
reg		[DATA_WIDTH - 1:0]	pre_pkt_data	;
reg				pre_pkt_start	;
reg		[DATA_WIDTH - 1:0]	pre_pkt_data_dly;
reg				eof_with_data_dly2 ;

always@(posedge clk156)
if( !rst_ | !fmac_rxd_en )
	begin
	pre_pkt_data		<= 256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
	
	pre_pkt_start		<= 1'b0;
	pkt_data		<= 256'h0;
	
	pre_pkt_data_dly <= 256'd0;
	
	pkt_start		<= 1'b0;
	pkt_end			<= 1'b0;
	pkt_we			<= 1'b0;
	
	pre_eof		<= 1'b0 ;
	end
else
	begin
	
	pre_pkt_data		<= 
		bdata1;

	//sof changed to pre sof because data will start from the d55fb pattern itself for 100G - Yet to be done
	pre_pkt_start		<= 
		//case of SOF4 took care of in SOF
		sof;
	//--
		
	pre_pkt_data_dly	<=	pre_pkt_data;
	pkt_data			<=	pre_pkt_data_dly;
	
	pkt_start	<= pre_pkt_start & my_mac_hit & !type_reject;	

	//eof_with_data changed to eof_present, removed pkt_we
	pkt_end			<= 
		pkt_end ? 1'b0 :
		eof_with_data | eof_with_data_dly1? 1'b0 :
		eof_with_data_dly2 & pkt_we ? 1'b1 :
		eof	& pkt_we		
		;

	//dly_between_pkts_dly1
	pkt_we		<=
		(pkt_end && (dly_between_pkts_dly1 || dly_between_pkts))? 1'b0 :
		pre_pkt_start & my_mac_hit & !type_reject ? 1'b1 :
		pkt_we
		;
				
	pre_eof		<=		
	   	fmac_rxd_en & (rxc[0] && (rxd[7:0] == 8'hFD))   || 
		fmac_rxd_en & (rxc[1] && (rxd[15:8] == 8'hFD))  || 
		fmac_rxd_en & (rxc[2] && (rxd[23:16] == 8'hFD)) || 
		fmac_rxd_en & (rxc[3] && (rxd[31:24] == 8'hFD)) ||
					
	   	fmac_rxd_en & (rxc[4] && (rxd[39:32] == 8'hFD)) ||
		fmac_rxd_en & (rxc[5] && (rxd[47:40] == 8'hFD)) ||
		fmac_rxd_en & (rxc[6] && (rxd[55:48] == 8'hFD)) ||
		fmac_rxd_en & (rxc[7] && (rxd[63:56] == 8'hFD)) ||
		
		fmac_rxd_en & (rxc[8] && (rxd[71:64] == 8'hFD)) ||
		fmac_rxd_en & (rxc[9] && (rxd[79:72] == 8'hFD)) ||
		fmac_rxd_en & (rxc[10] && (rxd[87:80] == 8'hFD)) ||
		fmac_rxd_en & (rxc[11] && (rxd[95:88] == 8'hFD)) ||
		
		fmac_rxd_en & (rxc[12] && (rxd[103:96]  == 8'hFD)) ||
		fmac_rxd_en & (rxc[13] && (rxd[111:104] == 8'hFD)) ||
		fmac_rxd_en & (rxc[14] && (rxd[119:112] == 8'hFD)) ||
		fmac_rxd_en & (rxc[15] && (rxd[127:120] == 8'hFD)) ||
		
		fmac_rxd_en & (rxc[16] && (rxd[135:128] == 8'hFD)) || 
		fmac_rxd_en & (rxc[17] && (rxd[143:136] == 8'hFD)) || 
		fmac_rxd_en & (rxc[18] && (rxd[151:144] == 8'hFD)) || 
		fmac_rxd_en & (rxc[19] && (rxd[159:152] == 8'hFD)) ||
					
	   	fmac_rxd_en & (rxc[20] && (rxd[167:160]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[21] && (rxd[175:168]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[22] && (rxd[183:176]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[23] && (rxd[191:184]	== 8'hFD)) ||
		                                       
		fmac_rxd_en & (rxc[24] && (rxd[199:192]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[25] && (rxd[207:200]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[26] && (rxd[215:208]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[27] && (rxd[223:216]	== 8'hFD)) ||
		                                       
		fmac_rxd_en & (rxc[28] && (rxd[231:224]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[29] && (rxd[239:232]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[30] && (rxd[247:240]	== 8'hFD)) ||
		fmac_rxd_en & (rxc[31] && (rxd[255:248]	== 8'hFD))
		;
	
		end


// CRC32
reg				pre_pkt_we_wire	;

wire			pre_pkt_eof	;

wire	[4:0]	pre_pkt_beat_bcnt_wire	;
reg		[4:0]	pre_pkt_beat_bcnt	;
reg		[4:0]	pre_pkt_beat_bcnt_dly1	;

wire	[31:0]	crc32_out ;
wire			crc32_vld ;
reg				pre_eof_dly1	;
reg				pre_eof_dly2	;


always @ (*) begin
	pre_pkt_we_wire	=
		!rst_  ? 1'b0 :
		pre_eof_dly1  	& !eof_with_data_dly1 	&  pre_pkt_we_wire  ? 1'b0 :
		pre_eof_dly2	&  eof_with_data_dly2 	&  pre_pkt_we_wire	? 1'b0 :
		pre_pkt_start 	&  my_mac_hit 			& !type_reject 		? 1'b1 :
		pre_pkt_we_wire
		;		
end


assign	pre_pkt_eof	=
  			pre_eof 	 & !eof_with_data 		? 1'b1 :
			pre_eof_dly1 & eof_with_data_dly1 	? 1'b1 :
			1'b0 ;
		
assign	pre_pkt_beat_bcnt_wire	=
  			pre_eof 	 & !eof_with_data 		? pre_pkt_beat_bcnt :
			pre_eof_dly1 & eof_with_data_dly1 	? pre_pkt_beat_bcnt_dly1 :
			3'h0 ;
			

always@(posedge clk156)
begin

if( !rst_ | !fmac_rxd_en )
	begin
	pre_eof_dly1		<= 1'b0;
	pre_eof_dly2		<= 1'b0;
	
	pre_pkt_beat_bcnt	<= 5'b0;
	pre_pkt_beat_bcnt_dly1	<= 5'b0;
		
	eof_with_data_dly2		<= 1'b0 ;
	end
else
	begin

	pre_eof_dly1		<= pre_eof;
	pre_eof_dly2		<= pre_eof_dly1;
	eof_with_data_dly2		<= eof_with_data_dly1 ;
	
	//count the number of valid bytes excluding crc
		case(rxc)
			32'hffffffff: pre_pkt_beat_bcnt	<=		5'd28;
			32'hfffffffe: pre_pkt_beat_bcnt	<=		5'd29;
			32'hfffffffc: pre_pkt_beat_bcnt	<=		5'd30;
			32'hfffffff8: pre_pkt_beat_bcnt	<=		5'd31;
			32'hfffffff0: pre_pkt_beat_bcnt	<=		5'd0;
			32'hffffffe0: pre_pkt_beat_bcnt	<=		5'd1;
			32'hffffffc0: pre_pkt_beat_bcnt	<=		5'd2;
			32'hffffff80: pre_pkt_beat_bcnt	<=		5'd3;
			
			32'hffffff00: pre_pkt_beat_bcnt	<=		5'd4;
			32'hfffffe00: pre_pkt_beat_bcnt	<=		5'd5;
			32'hfffffc00: pre_pkt_beat_bcnt	<=		5'd6;
			32'hfffff800: pre_pkt_beat_bcnt	<=		5'd7;
			32'hfffff000: pre_pkt_beat_bcnt	<=		5'd8;
			32'hffffe000: pre_pkt_beat_bcnt	<=		5'd9;
			32'hffffc000: pre_pkt_beat_bcnt	<=		5'd10;
			32'hffff8000: pre_pkt_beat_bcnt	<=		5'd11;
			
			32'hffff0000: pre_pkt_beat_bcnt	<=		5'd12;
			32'hfffe0000: pre_pkt_beat_bcnt	<=		5'd13;
			32'hfffc0000: pre_pkt_beat_bcnt	<=		5'd14;
			32'hfff80000: pre_pkt_beat_bcnt	<=		5'd15;
			32'hfff00000: pre_pkt_beat_bcnt	<=		5'd16;
			32'hffe00000: pre_pkt_beat_bcnt	<=		5'd17;
			32'hffc00000: pre_pkt_beat_bcnt	<=		5'd18;
			32'hff800000: pre_pkt_beat_bcnt	<=		5'd19;
			
			32'hff000000: pre_pkt_beat_bcnt	<=		5'd20;
			32'hfe000000: pre_pkt_beat_bcnt	<=		5'd21;
			32'hfc000000: pre_pkt_beat_bcnt	<=		5'd22;
			32'hf8000000: pre_pkt_beat_bcnt	<=		5'd23;
			32'hf0000000: pre_pkt_beat_bcnt	<=		5'd24;
			32'he0000000: pre_pkt_beat_bcnt	<=		5'd25;
			32'hc0000000: pre_pkt_beat_bcnt	<=		5'd26;
			32'h80000000: pre_pkt_beat_bcnt	<=		5'd27;
			32'h00000000: pre_pkt_beat_bcnt	<=		5'd0;
			
			default: pre_pkt_beat_bcnt <=   5'd0;
		endcase
	
	pre_pkt_beat_bcnt_dly1	<= pre_pkt_beat_bcnt ;
	 
	end
end


eth_crc32_gen eth_crc32_gen_rx(
   .clk			(clk156),         		//i-1, clock
   .rst_n		(rst_),        	  		//i-1, active low reset
                				                                                                         
   .mode_100G   (1'b1) ,				//i-1, speed_modes                       
   .mode_10G    (1'b0) ,				//i-1                                    
   .mode_50G    (1'b0) ,				//i-1                                    
   .mode_40G    (1'b0) ,	        	//i-1                                    
   .mode_25G    (1'b0) ,				//i-1                                    
                                                                                                         
   .data_vld	(pre_pkt_we_wire),		//i-1, data valid
   .data_eop	(pre_pkt_eof),    		//i-1, end of frame
   .data_sop	(sof),			  		//i-1, start of frame
   .data_in		(pre_pkt_data),   		//i-256, align first byte on bit [7:0] ... last byte [63:56]
   								  
   .data_be		(pre_pkt_beat_bcnt_wire),	//i-5, 0 - all bytes valid  (really is beat_bcnt), shows number of valid bytes
   	             			 
   .crc_out		(crc32_out), 				//final generated crc32 value
   .crc_vld     (crc32_vld)					//crc check valid
 );

 
wire	crc32_ok ;
assign	crc32_ok	=	crc32_vld ? (crc32_out == chk_crc_dly) : 1'b0 ;

// DRX_PKT_DATA
reg		[DATA_WIDTH - 1:0]	drx_pkt_data	;

reg				drx_pkt_start ; 
reg				drx_pkt_end ; 
reg				drx_pkt_we ;

reg		[4:0]					drx_pkt_beat_bcnt	;
reg		[CTRL_WIDTH - 1 : 0]	drx_pkt_be	;

wire	[31:0]	drx_crc32 ;
wire			drx_crc_vld ;
wire			drx_crc_err ;

reg				drx_crc_err_dly1 ;


assign		drx_crc_err = !crc32_ok ;
assign		drx_crc_vld = crc32_vld ;
assign		drx_crc32 	= crc32_out ;


reg		eof_present_dly1;

reg		[DATA_WIDTH - 1:0]		drx_pkt_data_dly;

always@(posedge clk156)
if( !rst_ | !fmac_rxd_en )
	begin
		drx_pkt_data		<= 265'h0;
		drx_pkt_data_dly	<= 265'h0;
		drx_pkt_start		<= 1'b0;
		drx_pkt_end			<= 1'b0;
		drx_pkt_we			<= 1'b0;

		drx_pkt_beat_bcnt	<= 5'h0;
		drx_pkt_be			<= 32'h0;

		drx_crc_err_dly1	<= 1'b0;
		eof_present_dly1	<= 1'b0;
		
	end
else
	begin
		
		drx_pkt_data_dly	<=	pre_pkt_data;
		drx_pkt_data		<=	drx_pkt_data_dly;
		
		drx_pkt_start	<= pre_pkt_start & (my_mac_hit | mcast_hit) & !type_reject;	
		
		//eof_with_data changed to eof_present, drx_pkt_we removed
		eof_present_dly1 <= eof_present;

		drx_pkt_end			<= 
			drx_pkt_end ? 1'b0 :
			eof_present ? 1'b0 :
			eof_present_dly1 ? 1'b1 :
			pre_eof	& drx_pkt_we	
			;

		drx_pkt_we		<=
			drx_pkt_end ? 1'b0 :
			pre_pkt_start & (my_mac_hit | mcast_hit) & !type_reject ? 1'b1 :
			drx_pkt_we
			;		
		drx_pkt_beat_bcnt	<=	pre_pkt_beat_bcnt_wire ;
		
		case(pre_pkt_beat_bcnt_wire)
			5'h0: drx_pkt_be <=    32'hffffffff;
			5'd1: drx_pkt_be <=    32'h00000001;
			5'd2: drx_pkt_be <=    32'h00000003;
			5'd3: drx_pkt_be <=    32'h00000007;
			5'd4: drx_pkt_be <=    32'h0000000f;
			5'd5: drx_pkt_be <=    32'h0000001f;
			5'd6: drx_pkt_be <=    32'h0000003f;	
			5'd7: drx_pkt_be <=    32'h0000007f;	
			
			5'd8: drx_pkt_be <=    32'h000000ff;
			5'd9: drx_pkt_be <=    32'h000001ff;
			5'd10: drx_pkt_be <=   32'h000003ff;
			5'd11: drx_pkt_be <=   32'h000007ff;
			5'd12: drx_pkt_be <=   32'h00000fff;
			5'd13: drx_pkt_be <=   32'h00001fff;
			5'd14: drx_pkt_be <=   32'h00003fff;	
			5'd15: drx_pkt_be <=   32'h00007fff;	
			
			5'd16: drx_pkt_be <=   32'h0000ffff;
			5'd17: drx_pkt_be <=   32'h0001ffff;
			5'd18: drx_pkt_be <=   32'h0003ffff;
			5'd19: drx_pkt_be <=   32'h0007ffff;
			5'd20: drx_pkt_be <=   32'h000fffff;
			5'd21: drx_pkt_be <=   32'h001fffff;
			5'd22: drx_pkt_be <=   32'h003fffff;	
			5'd23: drx_pkt_be <=   32'h007fffff;	
			
			5'd24: drx_pkt_be <=   32'h00ffffff;
			5'd25: drx_pkt_be <=   32'h01ffffff;
			5'd26: drx_pkt_be <=   32'h03ffffff;
			5'd27: drx_pkt_be <=   32'h07ffffff;
			5'd28: drx_pkt_be <=   32'h0fffffff;
			5'd29: drx_pkt_be <=   32'h1fffffff;
			5'd30: drx_pkt_be <=   32'h3fffffff;	
			5'd31: drx_pkt_be <=   32'h7fffffff;	
			
			default: drx_pkt_be <=   32'hffffffff;
			
		endcase
		
		drx_crc_err_dly1	<= drx_crc_err ;
		
		end



endmodule