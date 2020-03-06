//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information of Xilinx, Inc.
// and is protected under U.S. and international copyright and other
// intellectual property laws.
//
// DISCLAIMER
//
// This disclaimer is not a license and does not grant any rights to the
// materials distributed herewith. Except as otherwise provided in a valid
// license issued to you by Xilinx, and to the maximum extent permitted by
// applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
// FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
// IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
// MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
// and (2) Xilinx shall not be liable (whether in contract or tort, including
// negligence, or under any other theory of liability) for any loss or damage
// of any kind or nature related to, arising under or in connection with these
// materials, including for any direct, or any indirect, special, incidental,
// or consequential loss or damage (including loss of data, profits, goodwill,
// or any type of loss or damage suffered as a result of any action brought by
// a third party) even if such damage or loss was reasonably foreseeable or
// Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
//
// Xilinx products are not designed or intended to be fail-safe, or for use in
// any application requiring fail-safe performance, such as life-support or
// safety devices or systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any other
// applications that could lead to death, personal injury, or severe property
// or environmental damage (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and liability of any use of
// Xilinx products in Critical Applications, subject only to applicable laws
// and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
// AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Virtex-7 XT Connectivity Domain Targeted Reference Design 
// File       : registers.v
//
//-----------------------------------------------------------------------------
//

module registers #(
  parameter ADDR_WIDTH  = 32,
  parameter DATA_WIDTH  = 32,
  parameter NUM_POWER_REG = 13
) (
    //-IPIC Interface

  input [ADDR_WIDTH-1:0]        Bus2IP_Addr,
  input                         Bus2IP_RNW,
  input                         Bus2IP_CS,
  input [DATA_WIDTH-1:0]        Bus2IP_Data,
  output reg [DATA_WIDTH-1:0]   IP2Bus_Data,
  output reg                    IP2Bus_WrAck,
  output reg                    IP2Bus_RdAck,
  output                        IP2Bus_Error,
    //- User registers
  output reg [1:0]              scaling_factor,
  input [31:0]                  tx_pcie_byte_cnt,
  input [31:0]                  rx_pcie_byte_cnt,
  input [31:0]                  tx_pcie_payload_cnt,
  input [31:0]                  rx_pcie_payload_cnt,

  input [11:0]                  init_fc_cpld,
  input [7:0]                   init_fc_cplh,
  input [11:0]                  init_fc_npd,
  input [7:0]                   init_fc_nph,
  input [11:0]                  init_fc_pd,
  input [7:0]                   init_fc_ph,
 
  output reg                    ch0_perf_mode_en,
  output reg                    app0_en_lpbk,
  output reg                    app0_en_gen,
  output reg                    app0_en_chk,
  output reg [15:0]             app0_pkt_size,
  input                         app0_chk_status,
  
  input [7:0]                   ddr3_fifo_empty,
  output reg                    axi_ic_mig_shim_rst_n = 1'b1,
  input                         calib_done,  
  input                         c0_calib_done,  
  input                         c1_calib_done,  

  input                         xphy0_status, 
  input                         xphy1_status, 
  input                         xphy2_status, 
  input                         xphy3_status, 
  output reg                    mac0_pm_enable,
  output [47:0]                 mac0_adrs,
  input                         mac0_rx_fifo_overflow,
  input                         mac1_rx_fifo_overflow,
  output reg                    mac1_pm_enable,
  output [47:0]                 mac1_adrs,
  output reg                    mac2_pm_enable,
  output [47:0]                 mac2_adrs,
  input                         mac2_rx_fifo_overflow,
  input                         mac3_rx_fifo_overflow,
  output reg                    mac3_pm_enable,
  output [47:0]                 mac3_adrs,

  
    //- PCIe link related
  input                         pcie_link_up,
`ifdef USE_PVTMON
  input [(NUM_POWER_REG * 32) - 1: 0] power_status_reg,
`endif
    //- System signals
  input                         Clk,
  input                         Resetn
);

  //- Address offset definitions
  localparam [15:0] 
        //- Design Info registers
      DESIGN_VERSION      = 16'h9000,
      DESIGN_MODE         = 16'h9004,
      DESIGN_STATUS       = 16'h9008,
        //- PCIe Performance Monitor
      TX_PCIE_BYTE_CNT    = 16'h900C,
      RX_PCIE_BYTE_CNT    = 16'h9010,
      TX_PCIE_PAYLOAD_CNT = 16'h9014,
      RX_PCIE_PAYLOAD_CNT = 16'h9018,
      INIT_FC_CPLD        = 16'h901C,
      INIT_FC_CPLH        = 16'h9020,
      INIT_FC_NPD         = 16'h9024,
      INIT_FC_NPH         = 16'h9028,
      INIT_FC_PD          = 16'h902C,
      INIT_FC_PH          = 16'h9030,
      
      PERF_SCALE_REG      = 16'h9034,
        //- Power Monitor registers
      PWR_VCCINT_REG      = 16'h9040,
      PWR_VCCAUX_REG      = 16'h9044,
      PWR_VCC3_3_REG      = 16'h9048,
      UNUSED_1            = 16'h904C,
      PWR_VCC2_5_REG      = 16'h9050,
      PWR_VCC1_5_REG      = 16'h9054,
      PWR_MGT_AVCC_REG    = 16'h9058,
      PWR_MGT_AVTT_REG    = 16'h905C,
      PWR_VCCAUX_IO_REG   = 16'h9060,
      UNUSED_2            = 16'h9064,
      PWR_MGT_VCCAUX_REG  = 16'h9068,
      PWR_VCC1_8_REG      = 16'h906C,
      DIE_TEMP_REG        = 16'h9070,
        //- PCIe-DMA Performance GEN/CHK - 0
      APP0_ENABLE_GEN     = 16'h9100,
      APP0_PKT_LEN        = 16'h9104,
      APP0_ENABLE_LB_CHK  = 16'h9108,
      APP0_CHK_STATUS     = 16'h910C,
      APP0_CNT_WRAP       = 16'h9110,
        //- PCIe-DMA Performance GEN/CHK - 1
      APP1_ENABLE_GEN     = 16'h9200,
      APP1_PKT_LEN        = 16'h9204,
      APP1_ENABLE_LB_CHK  = 16'h9208,
      APP1_CHK_STATUS     = 16'h920C,
      APP1_CNT_WRAP       = 16'h9210,
        //-XGEMAC Related registers
      MAC0_ADRS_FILTER    = 16'h9400,
      MAC0_ADRS_LOW       = 16'h9404,
      MAC0_ADRS_HIGH      = 16'h9408,
      MAC1_ADRS_FILTER    = 16'h940C,
      MAC1_ADRS_LOW       = 16'h9410,
      MAC1_ADRS_HIGH      = 16'h9414,
      MAC2_ADRS_FILTER    = 16'h9418,
      MAC2_ADRS_LOW       = 16'h941C,
      MAC2_ADRS_HIGH      = 16'h9420,
      MAC3_ADRS_FILTER    = 16'h9424,
      MAC3_ADRS_LOW       = 16'h9428,
      MAC3_ADRS_HIGH      = 16'h942C;

  reg [47:0]  mac0_id = 'd0;
  reg [47:0]  mac1_id = 'd0;
  reg [47:0]  mac2_id = 'd0;
  reg [47:0]  mac3_id = 'd0;

  assign IP2Bus_Error = 1'b0;

  assign mac0_adrs = mac0_id;
  assign mac1_adrs = mac1_id;
  assign mac2_adrs = mac2_id;
  assign mac3_adrs = mac3_id;
  // 
  // On the assertion of CS, RNW port is checked for read or a write
  // transaction. 
  // In case of a write transaction, the relevant register is written to and
  // WrAck generated.
  // In case of reads, the read data along with RdAck is generated.
  // 
 
  always @(posedge Clk)
    if (Resetn == 1'b0)
    begin
      IP2Bus_Data   <= 32'd0;
      IP2Bus_WrAck  <= 1'b0;
      IP2Bus_RdAck  <= 1'b0;

      scaling_factor  <= 2'b01; //- 2x scaling by default
      ch0_perf_mode_en  <= 1'b1;
      app0_en_gen   <= 1'b0;
      app0_en_chk   <= 1'b0;
      app0_en_lpbk  <= 1'b1;
      app0_pkt_size <= 16'd4096;
      axi_ic_mig_shim_rst_n <= 1'b1;
      mac0_pm_enable  <= 1'b0;
      mac0_id         <= 48'hFFEEDDCCBBAA;
      mac1_pm_enable  <= 1'b0;
      mac1_id         <= 48'hFFEEDDCC00AA;
      mac2_pm_enable  <= 1'b0;
      mac2_id         <= 48'hFFEEDD00BBAA;
      mac3_pm_enable  <= 1'b0;
      mac3_id         <= 48'hFFEE00CCBBAA;
    end
    else
    begin
        //- Write transaction
      if (Bus2IP_CS & ~Bus2IP_RNW)
      begin
       if(Bus2IP_Addr[15:8]=='h90)
        case (Bus2IP_Addr[7:0])
          DESIGN_MODE[7:0]: ch0_perf_mode_en  <= Bus2IP_Data[0];
          DESIGN_STATUS[7:0]: axi_ic_mig_shim_rst_n <= Bus2IP_Data[1];
          PERF_SCALE_REG[7:0]: scaling_factor <= Bus2IP_Data[1:0];
        endcase
       else if(Bus2IP_Addr[15:8]=='h91)
        case (Bus2IP_Addr[7:0])
          APP0_ENABLE_GEN[7:0]: app0_en_gen  <= Bus2IP_Data[0];
          APP0_PKT_LEN[7:0]   : app0_pkt_size  <= Bus2IP_Data[15:0];
          APP0_ENABLE_LB_CHK[7:0]:begin
                                   app0_en_chk <= Bus2IP_Data[0];
                                   app0_en_lpbk<= Bus2IP_Data[1];
                                  end
        endcase
       else if(Bus2IP_Addr[15:8]=='h94)
        case (Bus2IP_Addr[7:0])
          MAC0_ADRS_FILTER[7:0]: mac0_pm_enable  <= Bus2IP_Data[0];
          MAC0_ADRS_LOW[7:0]   : mac0_id[31:0]   <= Bus2IP_Data;
          MAC0_ADRS_HIGH[7:0]  : mac0_id[47:32]  <= Bus2IP_Data[15:0];
          MAC1_ADRS_FILTER[7:0]: mac1_pm_enable  <= Bus2IP_Data[0];
          MAC1_ADRS_LOW[7:0]   : mac1_id[31:0]   <= Bus2IP_Data;
          MAC1_ADRS_HIGH[7:0]  : mac1_id[47:32]  <= Bus2IP_Data[15:0];
          MAC2_ADRS_FILTER[7:0]: mac2_pm_enable  <= Bus2IP_Data[0];
          MAC2_ADRS_LOW[7:0]   : mac2_id[31:0]   <= Bus2IP_Data;
          MAC2_ADRS_HIGH[7:0]  : mac2_id[47:32]  <= Bus2IP_Data[15:0];
          MAC3_ADRS_FILTER[7:0]: mac3_pm_enable  <= Bus2IP_Data[0];
          MAC3_ADRS_LOW[7:0]   : mac3_id[31:0]   <= Bus2IP_Data;
          MAC3_ADRS_HIGH[7:0]  : mac3_id[47:32]  <= Bus2IP_Data[15:0];
        endcase
        IP2Bus_WrAck  <= 1'b1;
        IP2Bus_Data   <= 32'd0;
        IP2Bus_RdAck  <= 1'b0;  
      end
        //- Read transaction
      else if (Bus2IP_CS & Bus2IP_RNW)
      begin
       if(Bus2IP_Addr[15:8]=='h90) 
        case (Bus2IP_Addr[7:0])
          // [31:20] : Rsvd
          // [19:16] : Device, 0 -> A7, 1 -> K7, 2 -> V7, 3 -> V7 XT 
          // [15:8]  : DMA version (major, minor)
          // [7:0]   : Design version (major, minor)
          // 
          DESIGN_VERSION[7:0]  : IP2Bus_Data <= {12'd0,4'h3,8'h10,8'h10};
            //- Base performance demo mode
          DESIGN_MODE[7:0]     : IP2Bus_Data <= {31'd0,ch0_perf_mode_en};
          DESIGN_STATUS[7:0]   : IP2Bus_Data <= {c1_calib_done, c0_calib_done, 
                                   xphy3_status, xphy2_status, xphy1_status, xphy0_status,
                                   16'd0, ddr3_fifo_empty,
                                   axi_ic_mig_shim_rst_n, calib_done}; 
          PERF_SCALE_REG[7:0]  : IP2Bus_Data <= {30'd0, scaling_factor}; 

          TX_PCIE_BYTE_CNT[7:0] : IP2Bus_Data <= tx_pcie_byte_cnt;
          RX_PCIE_BYTE_CNT[7:0] : IP2Bus_Data <= rx_pcie_byte_cnt;
          TX_PCIE_PAYLOAD_CNT[7:0]: IP2Bus_Data <= tx_pcie_payload_cnt;
          RX_PCIE_PAYLOAD_CNT[7:0]: IP2Bus_Data <= rx_pcie_payload_cnt;
          INIT_FC_CPLD[7:0]  : IP2Bus_Data <= {20'd0,init_fc_cpld};
          INIT_FC_CPLH[7:0]  : IP2Bus_Data <= {24'd0,init_fc_cplh};
          INIT_FC_NPD[7:0]  : IP2Bus_Data <= {20'd0,init_fc_npd};
          INIT_FC_NPH[7:0]  : IP2Bus_Data <= {24'd0,init_fc_nph};
          INIT_FC_PD[7:0]  : IP2Bus_Data <= {20'd0,init_fc_pd};
          INIT_FC_PH[7:0]  : IP2Bus_Data <= {24'd0,init_fc_ph};
`ifdef USE_PVTMON
          PWR_VCCINT_REG[7:0]    : IP2Bus_Data <= power_status_reg[31:0];
          PWR_VCCAUX_REG[7:0]    : IP2Bus_Data <= power_status_reg[63:32];
          PWR_VCC3_3_REG[7:0]    : IP2Bus_Data <= power_status_reg[95:64];
          PWR_VCC2_5_REG[7:0]    : IP2Bus_Data <= power_status_reg[159:128];
          PWR_VCC1_5_REG[7:0]    : IP2Bus_Data <= power_status_reg[191:160];
          PWR_MGT_AVCC_REG[7:0]  : IP2Bus_Data <= power_status_reg[223:192];
          PWR_MGT_AVTT_REG[7:0]  : IP2Bus_Data <= power_status_reg[255:224];
          PWR_VCCAUX_IO_REG[7:0] : IP2Bus_Data <= power_status_reg[287:256];
          PWR_MGT_VCCAUX_REG[7:0]: IP2Bus_Data <= power_status_reg[351:320];
          PWR_VCC1_8_REG[7:0]    : IP2Bus_Data <= power_status_reg[383:352];
          DIE_TEMP_REG[7:0]      : IP2Bus_Data <= power_status_reg[415:384];
`endif          
          
        endcase
       else if(Bus2IP_Addr[15:8]=='h91)
        case (Bus2IP_Addr[7:0])
          APP0_ENABLE_GEN[7:0]     : IP2Bus_Data <= {31'd0,app0_en_gen};
          APP0_PKT_LEN[7:0]        : IP2Bus_Data <= {16'd0,app0_pkt_size};
          APP0_ENABLE_LB_CHK[7:0]  : IP2Bus_Data <= {30'd0,app0_en_lpbk,app0_en_chk};
          APP0_CHK_STATUS[7:0]     : IP2Bus_Data <= {31'd0,app0_chk_status}; 
        endcase
       else if(Bus2IP_Addr[15:8]=='h94)
        case (Bus2IP_Addr[7:0])
          MAC0_ADRS_FILTER[7:0]  : IP2Bus_Data <= {mac0_rx_fifo_overflow, 30'd0,mac0_pm_enable};
          MAC0_ADRS_LOW[7:0]     : IP2Bus_Data <= mac0_adrs[31:0];
          MAC0_ADRS_HIGH[7:0]    : IP2Bus_Data <= {16'd0,mac0_adrs[47:32]};
          MAC1_ADRS_FILTER[7:0]  : IP2Bus_Data <= {mac1_rx_fifo_overflow, 30'd0,mac1_pm_enable};
          MAC1_ADRS_LOW[7:0]     : IP2Bus_Data <= mac1_adrs[31:0];
          MAC1_ADRS_HIGH[7:0]    : IP2Bus_Data <= {16'd0,mac1_adrs[47:32]};
          MAC2_ADRS_FILTER[7:0]  : IP2Bus_Data <= {mac2_rx_fifo_overflow, 30'd0,mac2_pm_enable};
          MAC2_ADRS_LOW[7:0]     : IP2Bus_Data <= mac2_adrs[31:0];
          MAC2_ADRS_HIGH[7:0]    : IP2Bus_Data <= {16'd0,mac2_adrs[47:32]};
          MAC3_ADRS_FILTER[7:0]  : IP2Bus_Data <= {mac3_rx_fifo_overflow, 30'd0,mac3_pm_enable};
          MAC3_ADRS_LOW[7:0]     : IP2Bus_Data <= mac3_adrs[31:0];
          MAC3_ADRS_HIGH[7:0]    : IP2Bus_Data <= {16'd0,mac3_adrs[47:32]};

        endcase
        IP2Bus_RdAck  <= 1'b1;
        IP2Bus_WrAck  <= 1'b0;
      end
      else
      begin
        IP2Bus_Data   <= 32'd0;
        IP2Bus_WrAck  <= 1'b0;
        IP2Bus_RdAck  <= 1'b0;
      end
    end
  
endmodule
