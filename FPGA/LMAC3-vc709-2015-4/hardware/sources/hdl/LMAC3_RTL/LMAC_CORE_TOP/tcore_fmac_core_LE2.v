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

module tcore_fmac_core(

	// clock & reset
	usr_clk,    		// i-1, depends on speed_mode
	x_clk,				// i-1, depends on speed_mode
	usr_rst_,  			// i-1,	RESET if ext dev reset or PCIE reset 	
	
	mode_10G,			// i-1, speed_modes	
	mode_25G,		    // i-1
	mode_40G,	 	    // i-1
	mode_50G,           // i-1
	mode_100G,		    // i-1
	
	TCORE_MODE,	      	//i-1
	
	// register config
	tx_xo_en,			// i-1
	rx_xo_en,			// i-1
	bcast_en,			// i-1
	prom_mode,			// i-1         	
	mac_addr0, 			// i-48
	rx_size, 			// i-12
	rx_check_crc,		// i-1
	
	// txfifo interface
	txfifo_din, 		// i-256
	txfifo_wr_en,		// i-1
	txfifo_full, 		// o-1
	txfifo_usedw,		// o-13
	
	// tx_encap interface
	mac_pause_value,	// i-32
	tx_b2b_dly,			// i-2
	
	// rxfifo interface
	rxfifo_rd_en,		// i-1
	rxfifo_dout,		// o-256
	rxfifo_ctrl_dout,	//o-32
	rxfifo_empty,		// o-1
	
	//for field debug
	rxfifo_full_dbg,	//o-1
	rxfifo_usedw_dbg,	//o-12
	
	drx_pkt_data, 		//o-256     	
	drx_pkt_start,    	//o-1		     
	drx_pkt_end,       	//o-1		     
	drx_pkt_we,       	//o-1		     
	drx_pkt_beat_bcnt,	//o-3	 
	drx_pkt_be,       	//o-32	 
	drx_crc32,       	//o-32	
	drx_crc_vld,       	//o-1		     
	drx_crc_err,       	//o-1		     
	drx_crc_err_dly1 ,	//o-1		     
	
	//PRE-parser FIFO
	cs_fifo_rd_en	,	//i-1, also rd the pre-parser fifo
	ipcs_fifo_dout	,	//o-64, {32'b0, fpseudo, fast_ipsum}	
	cs_fifo_empty	,	//o-1, for debug
	
	//CGMII Signals
	cgmii_rxc, 			//i-32 		
	cgmii_rxd,  		//i-256
	cgmii_rxp,  		//i-8
	
	br_sof	,			//i-8	
	
	fmac_ctrl1_dly,		//i-32
	                	
	fmac_rxd_en	,		//i-1

	// tx_cgmii to oddr
	cgmii_txc, 			//o-32 	
	cgmii_txd, 			//o-256 	
	
	// to mac_register.v
	FMAC_TX_PKT_CNT,  		// o-32
	FMAC_RX_PKT_CNT_LO,     // o-32
	FMAC_RX_PKT_CNT_HI,     // o-32
	
	FMAC_TX_BYTE_CNT,		// o-32
	FMAC_RX_BYTE_CNT_LO,    // o-32
	FMAC_RX_BYTE_CNT_HI,    // o-32
	
	FMAC_RX_UNDERSIZE_PKT_CNT,	// o-32
	FMAC_RX_CRC_ERR_CNT,		// o-32
	FMAC_DCNT_OVERRUN,			// o-32
	FMAC_DCNT_LINK_ERR,			// o-32
	FMAC_PKT_CNT_OVERSIZE,		// o-32
	FIFO_OV_IPEND,				// o-1
	
	FMAC_PKT_CNT_JABBER,		// o-32
	FMAC_PKT_CNT_FRAGMENT,		// o-32
	
	STAT_GROUP_LO_DOUT	,		//o-32
	STAT_GROUP_HI_DOUT	,		//o-32
	STAT_GROUP_addr		,		//i-10
	STAT_GROUP_sel		,		//i-1

	fmac_tx_clr_en		,		//i-1
	
	FMAC_RX_PKT_CNT64_LO	,	//o-33
	FMAC_RX_PKT_CNT64_HI	,	//o-32
	FMAC_RX_PKT_CNT127_LO	,	//o-33
	FMAC_RX_PKT_CNT127_HI	,	//o-32
	FMAC_RX_PKT_CNT255_LO	,	//o-33
	FMAC_RX_PKT_CNT255_HI	,	//o-32
	FMAC_RX_PKT_CNT511_LO	,	//o-33
	FMAC_RX_PKT_CNT511_HI	,	//o-32
	FMAC_RX_PKT_CNT1023_LO	,	//o-33
	FMAC_RX_PKT_CNT1023_HI	,	//o-32
	FMAC_RX_PKT_CNT1518_LO	,	//o-33
	FMAC_RX_PKT_CNT1518_HI	,	//o-32
	FMAC_RX_PKT_CNT2047_LO	,	//o-33
	FMAC_RX_PKT_CNT2047_HI	,	//o-32
	FMAC_RX_PKT_CNT4095_LO	,	//o-33
	FMAC_RX_PKT_CNT4095_HI	,	//o-32
	FMAC_RX_PKT_CNT8191_LO	,	//o-33
	FMAC_RX_PKT_CNT8191_HI	,	//o-32
	FMAC_RX_PKT_CNT9018_LO	,	//o-33
	FMAC_RX_PKT_CNT9018_HI	,	//o-32
	FMAC_RX_PKT_CNT9022_LO	,	//o-33
	FMAC_RX_PKT_CNT9022_HI	,	//o-32
	FMAC_RX_PKT_CNT9199P_LO ,	//o-33
	FMAC_RX_PKT_CNT9199P_HI ,	//o-32
	
	fmac_rx_clr_en				//i-1			
	
	);

//default values
parameter	DATA_WIDTH = 256;
parameter	CTRL_WIDTH = 32;	
		
parameter	FMAC_ID = 10;
parameter	RX_FIFO_DEPTH = 4096;
parameter	RX_FIFO_ADDR_WIDTH = 12;

parameter	RX_DRAM_DEPTH = 3072;		//only use 3K qwds	
parameter	RX_DRAM_ADDR_WIDTH = 12;
parameter	OVERSIZE_MARK = 9022;		//not used


// clock & reset
input usr_clk;		// i-1, depends on speed_mode               
input x_clk;        // i-1, depends on speed_mode               
input usr_rst_;     // i-1,	RESET if ext dev reset or PCIE reset
 
input mode_100G;    // i-1
input mode_10G ;    // i-1
input mode_50G ;    // i-1
input mode_40G ;    // i-1
input mode_25G ;    // i-1
                                     
input TCORE_MODE;

// register config
input tx_xo_en;
input rx_xo_en;
input bcast_en;
input prom_mode;
input [47:0] mac_addr0;
input [11:0] rx_size;
input rx_check_crc;

// txfifo interface
input [DATA_WIDTH - 1:0] txfifo_din;
input txfifo_wr_en;
output txfifo_full;
output [12:0] txfifo_usedw;

// tx_encap interface
input [31:0] mac_pause_value;
input [1:0]  tx_b2b_dly;

// rxfifo interface
input 									rxfifo_rd_en;
output 		[DATA_WIDTH - 1:0] 			rxfifo_dout;
output reg 	[CTRL_WIDTH - 1:0]			rxfifo_ctrl_dout;	
output 									rxfifo_empty;
output reg 								rxfifo_full_dbg;
output reg 	[RX_FIFO_ADDR_WIDTH-1 : 0]	rxfifo_usedw_dbg;

output	[DATA_WIDTH - 1:0]	drx_pkt_data;             
output						drx_pkt_start; 
output						drx_pkt_end ; 
output						drx_pkt_we ;
output	[4:0]				drx_pkt_beat_bcnt;
output	[CTRL_WIDTH - 1:0]	drx_pkt_be;
output	[31:0]				drx_crc32;
output						drx_crc_vld;
output						drx_crc_err;
output						drx_crc_err_dly1;

//pre-parser FIFO
input			cs_fifo_rd_en	;	//i-1
output [63:0] 	ipcs_fifo_dout;	
output			cs_fifo_empty	;	//o-1, for debug

// front end interface
input [CTRL_WIDTH - 1:0] cgmii_rxc; 
input [DATA_WIDTH - 1:0] cgmii_rxd; 
input [07:0] cgmii_rxp;

input	[7:0]	br_sof ;

input	[31:0]	fmac_ctrl1_dly	;
input			fmac_rxd_en	;	
output [CTRL_WIDTH - 1:0] cgmii_txc; 
output [DATA_WIDTH - 1:0] cgmii_txd;

// to mac_register.v
output [31:0] FMAC_TX_PKT_CNT;
output [31:0] FMAC_RX_PKT_CNT_LO;		wire	[31:0]	FMAC_RX_PKT_CNT_LO;// = 32'h0 ;
output [31:0] FMAC_RX_PKT_CNT_HI;		wire	[31:0]	FMAC_RX_PKT_CNT_HI;// = 32'h0 ;

output [31:0] FMAC_TX_BYTE_CNT;
output [31:0] FMAC_RX_BYTE_CNT_LO;		wire	[31:0]	FMAC_RX_BYTE_CNT_LO;// = 32'h0 ;
output [31:0] FMAC_RX_BYTE_CNT_HI;		wire	[31:0]	FMAC_RX_BYTE_CNT_HI;// = 32'h0 ;

output [31:0] FMAC_RX_UNDERSIZE_PKT_CNT;		wire	[31:0]	FMAC_RX_UNDERSIZE_PKT_CNT;// = 32'h0 ;
output [31:0] FMAC_RX_CRC_ERR_CNT;				wire	[31:0]	FMAC_RX_CRC_ERR_CNT;// = 32'h0 ;
output [31:0] FMAC_DCNT_OVERRUN;
output [31:0] FMAC_DCNT_LINK_ERR;
output [31:0] FMAC_PKT_CNT_OVERSIZE;
output		  FIFO_OV_IPEND;

output [31:0] FMAC_PKT_CNT_JABBER;		wire	[31:0]	FMAC_PKT_CNT_JABBER;// = 32'h0 ;
output [31:0] FMAC_PKT_CNT_FRAGMENT;	wire	[31:0]	FMAC_PKT_CNT_FRAGMENT;// = 32'h0 ;

//Interface to the FMAC reg IF
output	[31:0]	STAT_GROUP_LO_DOUT;		wire	[31:0]	STAT_GROUP_LO_DOUT;// = 32'h0 ;
output	[31:0]	STAT_GROUP_HI_DOUT;		wire	[31:0]	STAT_GROUP_HI_DOUT;// = 32'h0 ;

output		[32:0]		FMAC_RX_PKT_CNT64_LO   ;
output		[31:0]		FMAC_RX_PKT_CNT64_HI   ;
output		[32:0]		FMAC_RX_PKT_CNT127_LO  ;
output		[31:0]		FMAC_RX_PKT_CNT127_HI  ;
output		[32:0]		FMAC_RX_PKT_CNT255_LO  ;
output		[31:0]		FMAC_RX_PKT_CNT255_HI  ;
output		[32:0]		FMAC_RX_PKT_CNT511_LO  ;
output		[31:0]		FMAC_RX_PKT_CNT511_HI  ;
output		[32:0]		FMAC_RX_PKT_CNT1023_LO ;
output		[31:0]		FMAC_RX_PKT_CNT1023_HI ;
output		[32:0]		FMAC_RX_PKT_CNT1518_LO ;
output		[31:0]		FMAC_RX_PKT_CNT1518_HI ;
output		[32:0]		FMAC_RX_PKT_CNT2047_LO ;
output		[31:0]		FMAC_RX_PKT_CNT2047_HI ;
output		[32:0]		FMAC_RX_PKT_CNT4095_LO ;
output		[31:0]		FMAC_RX_PKT_CNT4095_HI ;
output		[32:0]		FMAC_RX_PKT_CNT8191_LO ;
output		[31:0]		FMAC_RX_PKT_CNT8191_HI ;
output		[32:0]		FMAC_RX_PKT_CNT9018_LO ;
output		[31:0]		FMAC_RX_PKT_CNT9018_HI ;
output		[32:0]		FMAC_RX_PKT_CNT9022_LO ;
output		[31:0]		FMAC_RX_PKT_CNT9022_HI ;
output		[32:0]		FMAC_RX_PKT_CNT9199P_LO;
output		[31:0]		FMAC_RX_PKT_CNT9199P_HI;
//--

input	[9:0]	STAT_GROUP_addr; 
input			STAT_GROUP_sel; 
input			fmac_rx_clr_en;
input			fmac_tx_clr_en;
reg		cs_fifo_rst ;	//reset pre-parser fifo

wire	wr_nbyte	;

wire	[9:0]	ipcs_fifo_wrusedw ;			//14 June 2018 KP

wire	[DATA_WIDTH - 1:0]	pkt_data;
wire			pkt_we, pkt_start, pkt_end ;

//TEMP
wire	fmac_tx_byte_cnt_clr = 1'b0 ;

// wires between txfifo & tx_encap
wire txfifo_empty;

//pre signals: input to mux (to read from TX fifo) - 5 sep 2018
wire pre_txfifo_rd_en_10G;  	
wire pre_txfifo_rd_en_100G; 
wire txfifo_rd_en = mode_10G? pre_txfifo_rd_en_10G : 
						pre_txfifo_rd_en_100G;
						
wire [DATA_WIDTH - 1:0] txfifo_dout; 

//pre output signals from 10G wrapper
wire	[255:0]	pre_cgmii_txd;
wire	[31:0]	pre_cgmii_txc;

wire rxfifo_full;

wire 	[RX_FIFO_ADDR_WIDTH : 0] rxfifo_rdusedw;

wire 	[RX_FIFO_ADDR_WIDTH-1:0] rxfifo_usedw;		//not used, tie lo
assign	rxfifo_usedw	= 12'd0 ;		//keep from floating

wire 	[RX_FIFO_ADDR_WIDTH : 0] rxfifo_wrusedw;

// wires between rx_decap & rx_xgmii
wire [RX_DRAM_ADDR_WIDTH:0]    xgmir2derx_wptr;
wire [RX_DRAM_ADDR_WIDTH-1:0]  raddr_marker;

wire	clr_pkt_cnt_oversize;

wire	add_lo_bcast	;		//  these signals are 250Mhz pre-synced
wire	add_lo_mcast	;		// 
wire	clr_carry_cast	;		// clr the carry of the B/Mcast group
wire	add_hi_cast		;		// add the HI reg of the B/Mcast group

// wires between rxdram & rx_xgmii
wire [RX_DRAM_ADDR_WIDTH-1:0]  xgmir2ram_waddr;
wire 		xgmir2ram_wen;

// wires between tx_encap & rx_xgmii
wire [15:0] rx_pvalue;
wire rx_pause;


//pre signals to differentiate the output to RX
wire pre_rx_pack_10G;
wire pre_rx_pack_100G;
wire rx_pack = mode_10G? pre_rx_pack_10G :
					pre_rx_pack_100G;

// wires between tx_decap & rx_decap
wire	xreq;
wire	xon;

wire pre_xdone_10G;
wire pre_xdone_100G;
wire xdone = mode_10G? pre_xdone_10G :
				pre_xdone_100G;

reg	mode_10G_buf ; 
reg	mode_25G_buf  ; 
reg	mode_40G_buf;
reg mode_50G_buf; 
reg	mode_100G_buf  ; 

wire [31:0]	chk_crc;

wire [10:0] txfifo_usedw_int;
assign txfifo_usedw = {3'h0, txfifo_usedw_int};
wire [31:0] rxfifo_ctrl_q;
wire [15:0] nbytes_out;

//initialisation to zero
assign raddr_marker	= 12'b0;
assign xreq = 1'b0;
assign xon = 1'b0;

wire	[31:0]	PRE_FMAC_TX_PKT_CNT_10G;
wire	[31:0]	PRE_FMAC_TX_BYTE_CNT_10G;

//buffer
always @(posedge usr_clk) 
	begin
	
		mode_10G_buf    <=	mode_10G ;
		mode_25G_buf    <=	mode_25G ;
		mode_40G_buf	<=	mode_40G ;
		mode_50G_buf    <=	mode_50G ;
		mode_100G_buf   <=  mode_100G;
	
	end

reg		[DATA_WIDTH - 1:0]	cgmii_dout_reg;
	reg		[CTRL_WIDTH - 1:0]	cgmii_cout_reg;
	reg		[31:0]	FMAC_TX_PKT_CNT;
	reg		[31:0]	FMAC_TX_BYTE_CNT;
	wire	[31:0]  PRE_FMAC_TX_PKT_CNT_100G,PRE_FMAC_TX_BYTE_CNT_100G;	

	
	
// =========================================
// TRANSMIT PATH
// txfifo -> tx_encap -> tx_xgmii
// =========================================
txfifo_1024x256 txfifo_1024x256 (
			.aclr		(!usr_rst_),
                    	
			.wrclk		(usr_clk),     
			.wrreq		(txfifo_wr_en),     
			.data		(txfifo_din),                     
			.wrfull		(txfifo_full),    
		            	               
            .wrusedw	(txfifo_usedw_int),                
                    	
		    .rdclk		(x_clk),     
			.rdreq		(txfifo_rd_en),     
			.q			(txfifo_dout), 	    
			.rdempty	(txfifo_empty)  
	);

wire fmac_tx_clr_en, crc32_ok, rxfifo_wrempty156;
		
tx_100G_wrap tx_100G_wrap(
    .usr_clk					(usr_clk),				        //i-1, clk depends on speed_mode         
    .x_clk						(x_clk),				  	    //i-1, clk depends on speed_mode         
    .usr_rst_					(usr_rst_),				        //i-1, reset                             
                				                                                                         
   	.mode_100G					(mode_100G_buf) ,				//i-1, speed_modes                       
   	.mode_10G					(mode_10G_buf) ,				//i-1                                    
	.mode_50G					(mode_50G_buf)  ,				//i-1                                    
	.mode_40G					(mode_40G_buf),	                //i-1                                    
	.mode_25G					(mode_25G_buf),			        //i-1                                    
                                                                                                         
	//tx_encap interface                                                                                 
    .mac_addr0					(mac_addr0),				    //i-48                                   
    .mac_pause_value			(mac_pause_value),		        //i-32                                   
    .tx_b2b_dly					(tx_b2b_dly),			 	    //i-2                                    
   	                			                                                                         
    .txfifo_dout				(txfifo_dout),			        //i-256                                  
    .txfifo_empty				(txfifo_empty),	    		    //i-1                                    
    .pre_txfifo_rd_en_100G		(pre_txfifo_rd_en_100G),		//o-1, read data from tx_fifo  
                                                                                                         
	.rx_pause					(rx_pause),				        //i-1                                    
    .rx_pvalue					(rx_pvalue),				    //i-16                                   
	.pre_rx_pack_100G			(pre_rx_pack_100G),				//o-1, output to rx		
                        		                                                                         
	.xreq						(xreq),					        //i-1                                    
	.xon						(xon),				            //i-1                                    
	.pre_xdone_100G				(pre_xdone_100G),				//o-1, output to internal wire in tcore	
	                    		                                                                         
    .xaui_mode					(1'b1),				            //i-1                                    
                        		                                                                         
    .pre_cgmii_txd				(pre_cgmii_txd),			    //o-256                                  
    .pre_cgmii_txc				(pre_cgmii_txc),                //o-32                                   
    			                                                                                         
    .PRE_FMAC_TX_PKT_CNT_100G	(PRE_FMAC_TX_PKT_CNT_100G),     //o-32                                   
    .PRE_FMAC_TX_BYTE_CNT_100G	(PRE_FMAC_TX_BYTE_CNT_100G),	//o-32                                   
                                                                                                         
    .fmac_tx_clr_en				(fmac_tx_clr_en)	            //i-1                                    
    
    );
    
wire	[63:0]  pre_xgmii_txd;
wire	[7:0]   pre_xgmii_txc;
	
tx_10G_wrap tx_10G_wrap(
    .usr_clk					(usr_clk),				        //i-1, clk depends on speed_mode         
    .x_clk						(x_clk),				  	    //i-1, clk depends on speed_mode         
    .usr_rst_					(usr_rst_),				        //i-1, reset                             
                				                                                                         
   	.mode_10G 					(mode_10G_buf) ,	 			//i-1, speed_mode (active only for 10Gig)  
     	            			                                                                         
    .mac_addr0					(mac_addr0),				    //i-48                                   
    .mac_pause_value			(mac_pause_value),		        //i-32                                   
    .tx_b2b_dly					(tx_b2b_dly),			 	    //i-2                                    
   	                			                                                                         
    .txfifo_dout				(txfifo_dout),			        //i-256                                  
    .txfifo_empty				(txfifo_empty),	                //i-1                                    
    		                	                                                                   
    .pre_txfifo_rd_en_10G		(pre_txfifo_rd_en_10G),         //o-1                                    
                            	                                                                         
	.rx_pause					(rx_pause),				        //i-1                                    
    .rx_pvalue					(rx_pvalue),				    //i-16                                   
	.pre_rx_pack_10G			(pre_rx_pack_10G),		        //o-1                                    
                            	                                                                         
	.xreq						(xreq),					        //i-1                                    
	.xon						(xon),				            //i-1                                    
	.pre_xdone_10G				(pre_xdone_10G),			    //o-1                                    
	                        	                                                                         
    .xaui_mode					(1'b1),				            //i-1                                    
                            	                                                                         
    .pre_xgmii_txd				(pre_xgmii_txd),			    //o-64                                   
    .pre_xgmii_txc				(pre_xgmii_txc),                //o-8                                    
    			                                                                                         
    .PRE_FMAC_TX_PKT_CNT_10G	(PRE_FMAC_TX_PKT_CNT_10G),      //o-32                                   
    .PRE_FMAC_TX_BYTE_CNT_10G	(PRE_FMAC_TX_BYTE_CNT_10G),		//o-32                                   	
                                                                                                         
    .fmac_tx_clr_en				(fmac_tx_clr_en)	            //i-1 
    
    );

tcore_rx_cgmii #(RX_DRAM_DEPTH, RX_DRAM_ADDR_WIDTH) 
core_rx_cgmii(
	.clk156					(x_clk),				// i-1			
	.clk250					(usr_clk),				// i-1		
	.rst_					(usr_rst_),				// i-1		
                			    	        		
	.TCORE_MODE				(TCORE_MODE),			// i-1 	
	            			                		       
	.xaui_mode				(1'b1),		    		// i-1 
                				                                                                         
   	.mode_100G				(mode_100G_buf),		//i-1, speed_modes                       
   	.mode_10G				(mode_10G_buf),			//i-1                                    
	.mode_50G				(mode_50G_buf),			//i-1                                    
	.mode_40G				(mode_40G_buf),	        //i-1                                    
	.mode_25G				(mode_25G_buf),			//i-1                                    
                                                                                                         
	.pkt_data				(pkt_data),				//o-256
	.pkt_start				(pkt_start),			//o-1  	
	.pkt_end				(pkt_end),				//o-1  
	.pkt_we					(pkt_we),				//o-1  
	                    	
	.drx_pkt_data			(drx_pkt_data),         //o-256
	.drx_pkt_start			(drx_pkt_start),        //o-1  
	.drx_pkt_end			(drx_pkt_end),          //o-1  
	.drx_pkt_we				(drx_pkt_we),           //o-1  
	.drx_pkt_beat_bcnt		(drx_pkt_beat_bcnt),    //o-5  
	.drx_pkt_be				(drx_pkt_be),           //o-32  
	.drx_crc32 				(drx_crc32),            //o-32 
	.drx_crc_vld 			(drx_crc_vld),          //o-1  
	.drx_crc_err			(drx_crc_err),          //o-1  
	.drx_crc_err_dly1		(drx_crc_err_dly1),     //o-1  
	                    	
	.wen					(xgmir2ram_wen),		//o-1     		
	.waddr					(xgmir2ram_waddr),		// o-param		
	.wptr					(xgmir2derx_wptr),		// o-param		
	.raddr_marker			(raddr_marker),		    // i-param
                        	
	.rx_pause				(rx_pause),			    // o-1 
	.rx_pvalue				(rx_pvalue),			// o-16
	.rx_pack				(rx_pack),			    // i-1 
	                		
	.pause_en				(rx_xo_en),			    // i-1                             
	.bcast_en				(bcast_en),			    // i-1                             
	.pmode					(prom_mode),			// i-1, promiscuous mode enable bit	
	.daddr0					(mac_addr0),			// i-48                            	
	                		
	.rsize					(rx_size),				// i-12                           		
	.rxd					(cgmii_rxd),			// i-256                           	
	.rxc					(cgmii_rxc),            // i-32                           
	.br_sof0				(br_sof[0]),			// i-1, byte_reordering's sof0_out	
	.br_sof4				(br_sof[1]),			// i-1, byte_reordering's sof4_out
	                    	
	//Incoming from Byte	 Reordering module
	.br_sof8				(br_sof[2]),
	.br_sof12				(br_sof[3]),
	.br_sof16				(br_sof[4]),
	.br_sof20				(br_sof[5]),
	.br_sof24				(br_sof[6]),
	.br_sof28				(br_sof[7]),
                        	
	.rxp					(cgmii_rxp),				// i-8, not used, always 0                  
	                    	                        	                                            
	.fmac_ctrl1_dly			(fmac_ctrl1_dly),	        //i-32, contains the max_pkt_size and enable
	.fmac_rxd_en			(fmac_rxd_en),		        //i-1, from TSPE_CTRL1  reg                 
	                    	                                                                        
	.FMAC_DCNT_OVERRUN		(FMAC_DCNT_OVERRUN),	    // o-32                                     
	.FMAC_DCNT_LINK_ERR		(FMAC_DCNT_LINK_ERR),		// o-32                                     
	.FMAC_PKT_CNT_OVERSIZE	(FMAC_PKT_CNT_OVERSIZE),    // o-32                                     
	.FIFO_OV_IPEND			(FIFO_OV_IPEND),		    // o-1                                      
	                                                                                                
	.clr_pkt_cnt_oversize	(clr_pkt_cnt_oversize),     // i-1                                      
	                                                                                                
	.add_lo_bcast			(add_lo_bcast),		        // o-1, these signals are 250Mhz pre-synced 
	.add_lo_mcast			(add_lo_mcast),		        // o-1                                      
	.clr_carry_cast			(clr_carry_cast),		    // o-1 clr the carry of the B/Mcast group   
	.add_hi_cast			(add_hi_cast),		        // o-1 add the HI reg of the B/Mcast group  
	                                                                                		              
	.vlan_ip				(),	                        //o-1                                       
	.normal_ip				(),	                        //o-1                                       
	.non_ip					(),		                    //o-1                                       
	.pkt_reject				(),			                //o-1, EXTR use to drop the pkt at end      
	.pkt_jumbo_flag			(),		                                                                
	.pkt_ipver				(),			                                                            
	                                                                                                
	.wr_nbyte				(wr_nbyte),		            //o-1                                       
	.nbytes_out				(nbytes_out),	            //o-16, pkt byte cnt                        
	.rxfifo_full			(rxfifo_full),              //i-1                                       
	
	.chk_crc				(chk_crc),
	
	.crc32_ok				(crc32_ok),			
	
	.fmac_rx_clr_en			(fmac_rx_clr_en)
	
	);
	
	
fmac_rx_fifo4Kx256 
	rx_fifo (
			.aclr(!usr_rst_ | !fmac_rxd_en),
			
			//=== Signals for WRITE
			.wrclk		(x_clk),	      		// Clk for writing data                              
			.wrreq		(pkt_we),  	     		// Data coming in                                    
			.data		(pkt_data),    			// request to write                                  
			.wrfull		(),     				// indicates fifo is full or not (To avoid overiding)
			.wrempty	(rxfifo_wrempty156),	// 0- some data is present (atleast 1 data is present)                                            
			.wrusedw	(rxfifo_wrusedw),		// number of slots currently in use for writing                                                                                                         
                                                    
			//=== Signals for READ
			.rdclk		(usr_clk),      		// Clk for reading data                                
			.rdreq		(rxfifo_rd_en),  		// Request to read from FIFO                           
			.q			(rxfifo_dout),    		// Data coming out                                     
			.rdfull		(),     				//  
			.rdempty	(rxfifo_empty),    		// indicates fifo is empty or not (to avoid underflow)  
			.rdusedw	(rxfifo_rdusedw)    	// number of slots currently in use for reading
			
	);
	
	
wire	[31:0]	pktctrl_din	= {
					30'h0	,	
					pkt_end	,	
					pkt_start	
					};

					
fmac_fifo4Kx32
	pkt_ctrl_fifo (
			.aclr		(!usr_rst_ | !fmac_rxd_en),
			
			//=== Signals for WRITE
			.wrclk		(x_clk),      		// Clk for writing data                              
			.wrreq		(pkt_we),      		// request to write 
			.data		(pktctrl_din),     	// Data coming in                                                                    
			.wrfull		(),     			// indicates fifo is full or not (To avoid overiding)
		    .wrempty	(),  				// indicates fifo is empty or not (to avoid underflow)                                                                                                      
            .wrusedw	(),      			// number of slots currently in use for writting                                     

			//=== Signals for READ
		    .rdclk		(usr_clk),       	// Clk for reading data                     
			.rdreq		(rxfifo_rd_en),		// Request to read from FIFO                           
			.q			(rxfifo_ctrl_q),	// Data coming out                                     
			.rdempty	(),  	 			// indicates fifo is empty or not (to avoid underflow)  
			.rdusedw	(),      			// number of slots currently in use for reading
			.rdfull		()      			// indicates fifo is full or not (To avoid overiding)
			
	);
	
rx_decap #(FMAC_ID, RX_FIFO_DEPTH, RX_FIFO_ADDR_WIDTH, RX_DRAM_DEPTH, RX_DRAM_ADDR_WIDTH, DATA_WIDTH) 
	rx_decap(
	.clk250		(usr_clk),				// i-1
	.clk156		(x_clk),				// i-1
	.rst_		(usr_rst_),				// i-1
	
	.full		(rxfifo_full),			// i-1	
	.usedw		(rxfifo_usedw),			// i-12
			
	.rx_check_crc				(rx_check_crc),					// i-1, enabling checking of CRC	
		                                                                                        
	.fmac_ctrl1_dly 			(fmac_ctrl1_dly),	            //i-32                          
	.fmac_rxd_en				(fmac_rxd_en),			        //i-1                           

	.FMAC_RX_CRC_ERR_CNT		(FMAC_RX_CRC_ERR_CNT),			// o-32	
	.FMAC_RX_UNDERSIZE_PKT_CNT	(FMAC_RX_UNDERSIZE_PKT_CNT),	// o-32
	.FMAC_RX_PKT_CNT_LO			(FMAC_RX_PKT_CNT_LO),			// o-32			
	.FMAC_RX_PKT_CNT_HI			(FMAC_RX_PKT_CNT_HI),			// o-32			
	.FMAC_RX_BYTE_CNT_LO		(FMAC_RX_BYTE_CNT_LO),			// o-32		
	.FMAC_RX_BYTE_CNT_HI		(FMAC_RX_BYTE_CNT_HI),			// o-32		
	
	.FMAC_PKT_CNT_JABBER		(FMAC_PKT_CNT_JABBER),	        // o-32
	.FMAC_PKT_CNT_FRAGMENT		(FMAC_PKT_CNT_FRAGMENT),	    // o-32
	
	//Interface to 64 bit Statistic register group, in DECAP
	.STAT_GROUP_LO_DOUT			(STAT_GROUP_LO_DOUT),	        // o-32                                                       
	.STAT_GROUP_HI_DOUT			(STAT_GROUP_HI_DOUT),	        // o-32                                                       
	.STAT_GROUP_addr			(STAT_GROUP_addr),			    // i-10,  address to select the register within the STAT GROUP
	.STAT_GROUP_sel				(STAT_GROUP_sel),			    //i-1                                                         
	.fmac_rx_clr_en				(fmac_rx_clr_en),				//i-1                                                         	
	
	.wptr						(xgmir2derx_wptr),	          	// i-param  
	.rdata						(256'h0),                       // i-256   
	
	.clr_pkt_cnt_oversize		(clr_pkt_cnt_oversize),	    	//o-1
	
	.add_lo_bcast				(add_lo_bcast),		         	// i-1, these signals are 250Mhz pre-synced
	.add_lo_mcast				(add_lo_mcast),		            // i-1                                     
	.clr_carry_cast				(clr_carry_cast),	            // i-1 clr the carry of the B/Mcast group  
	.add_hi_cast				(add_hi_cast),		            // i-1 add the HI reg of the B/Mcast group 
	
	.tx_xo_en					(tx_xo_en),				       	// i-1 From Register
	.xdone						(xdone),						// o-1              
	
						
		
	.FMAC_RX_PKT_CNT64_LO		(FMAC_RX_PKT_CNT64_LO),
	.FMAC_RX_PKT_CNT64_HI		(FMAC_RX_PKT_CNT64_HI),
	
	.FMAC_RX_PKT_CNT127_LO		(FMAC_RX_PKT_CNT127_LO),
	.FMAC_RX_PKT_CNT127_HI		(FMAC_RX_PKT_CNT127_HI),
	                      		
	.FMAC_RX_PKT_CNT255_LO		(FMAC_RX_PKT_CNT255_LO),
	.FMAC_RX_PKT_CNT255_HI		(FMAC_RX_PKT_CNT255_HI),
	                      		
	.FMAC_RX_PKT_CNT511_LO		(FMAC_RX_PKT_CNT511_LO),
	.FMAC_RX_PKT_CNT511_HI		(FMAC_RX_PKT_CNT511_HI),
	
	.FMAC_RX_PKT_CNT1023_LO		(FMAC_RX_PKT_CNT1023_LO),
	.FMAC_RX_PKT_CNT1023_HI		(FMAC_RX_PKT_CNT1023_HI),
	                       		
	.FMAC_RX_PKT_CNT1518_LO		(FMAC_RX_PKT_CNT1518_LO),
	.FMAC_RX_PKT_CNT1518_HI		(FMAC_RX_PKT_CNT1518_HI),
	                       		
	.FMAC_RX_PKT_CNT2047_LO		(FMAC_RX_PKT_CNT2047_LO),
	.FMAC_RX_PKT_CNT2047_HI		(FMAC_RX_PKT_CNT2047_HI),
	                       		
	.FMAC_RX_PKT_CNT4095_LO		(FMAC_RX_PKT_CNT4095_LO),
	.FMAC_RX_PKT_CNT4095_HI		(FMAC_RX_PKT_CNT4095_HI),
	                       		
	.FMAC_RX_PKT_CNT8191_LO		(FMAC_RX_PKT_CNT8191_LO),
	.FMAC_RX_PKT_CNT8191_HI		(FMAC_RX_PKT_CNT8191_HI),
	                       		
	.FMAC_RX_PKT_CNT9018_LO		(FMAC_RX_PKT_CNT9018_LO),
	.FMAC_RX_PKT_CNT9018_HI		(FMAC_RX_PKT_CNT9018_HI),
	                       		
	.FMAC_RX_PKT_CNT9022_LO		(FMAC_RX_PKT_CNT9022_LO),
	.FMAC_RX_PKT_CNT9022_HI		(FMAC_RX_PKT_CNT9022_HI),
	
	.FMAC_RX_PKT_CNT9199P_LO	(FMAC_RX_PKT_CNT9199P_LO),
	.FMAC_RX_PKT_CNT9199P_HI	(FMAC_RX_PKT_CNT9199P_HI),
	
	.nbyte						(nbytes_out),
	.pkt_done					(wr_nbyte),
				
	.crc_chk					(chk_crc),
	.crc32						(drx_crc32),
	.crc32_vld_					(drx_crc_vld),
	
	.crc_ok 					(crc32_ok)
	
	);	
	
	

assign	rxfifo_full	= (rxfifo_wrusedw >= 16'd3840 ) | (ipcs_fifo_wrusedw >= 9'd500) ;

 
	
always @ (posedge usr_clk)
begin
	rxfifo_usedw_dbg 	<= 	rxfifo_wrusedw;
	rxfifo_full_dbg		<=	rxfifo_full;
	
	cs_fifo_rst			<= 
		!usr_rst_ ? 1'b1 :
		!fmac_rxd_en ? 1'b1 :
		1'b0 ;
		
	rxfifo_ctrl_dout	<= 
		!usr_rst_ ? 32'd0 :
		rxfifo_ctrl_q ;
	
end
	

wire	[63:0]	ipcs_fifo_din = {
					2'h0,		
					nbytes_out[13:0],
					16'h0,		
					16'h0	,	
					16'h0		
					};	

fmac_ipcs_fifo512x64 
	ipcs_fifo (
			.aclr(cs_fifo_rst),
			
			//=== Signals for WRITE
			.wrclk		(x_clk),       			// Clk for writing data                              
			.wrreq		(wr_nbyte),       		//  request to write                                      
			.data		(ipcs_fifo_din), 		// Data coming in                            
			.wrfull		(),      				// indicates fifo is full or not (To avoid overiding)
			.wrempty	(),     				// 0- some data is present (atleast 1 data is present)                                            
			.wrusedw	(ipcs_fifo_wrusedw),	// number of slots currently in use for writing                                                                                                                                                             

			//=== Signals for READ
		    .rdclk		(usr_clk),      		// Clk for  reading data                            
			.rdreq		(cs_fifo_rd_en),      	// Request to read from FIFO                           
			.q			(ipcs_fifo_dout),  		// Data coming out                                     
			.rdfull		(),     //  
			.rdempty	(cs_fifo_empty),    	// indicates fifo is empty or not (to avoid underflow)  
			.rdusedw	()     					// number of slots currently in use for reading

	);
	
	always @(posedge x_clk)
	begin
		if (!usr_rst_)
			begin
			FMAC_TX_PKT_CNT 		<= 32'h0;
			FMAC_TX_BYTE_CNT 		<= 32'h0;
			cgmii_dout_reg		<= 256'h0707070707070707_0707070707070707_0707070707070707_0707070707070707;
			cgmii_cout_reg		<= 32'hFF_FF_FF_FF;
			end
		else
			begin
			FMAC_TX_PKT_CNT <= mode_10G? PRE_FMAC_TX_PKT_CNT_10G : PRE_FMAC_TX_PKT_CNT_100G;
			FMAC_TX_BYTE_CNT <= mode_10G? PRE_FMAC_TX_BYTE_CNT_10G : PRE_FMAC_TX_BYTE_CNT_100G;
			
			cgmii_dout_reg[255:64]		<= mode_10G? 192'h0707070707070707_0707070707070707_0707070707070707 : pre_cgmii_txd[255:64];
			cgmii_dout_reg[63:0]		<= mode_10G? pre_xgmii_txd : pre_cgmii_txd[63:0];
			
			cgmii_cout_reg[31:8]	<=	mode_10G? 24'hFF_FF_FF : pre_cgmii_txc[31:8];
			cgmii_cout_reg[7:0]		<=	mode_10G? pre_xgmii_txc : pre_cgmii_txc[7:0];	
			end
	end		
	
	assign cgmii_txd 	= cgmii_dout_reg;
	assign cgmii_txc 	= cgmii_cout_reg;	
	


endmodule