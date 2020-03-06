/*******************************************************************************
** © Copyright 2009 - 2014 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        
**  /   /          
** /___/   /\     
** \   \  /  \   Project: Virtex-7 XT Connectivity Domain Targeted Reference Design 

**  \___\/\___\ 
** 
**     
*******************************************************************************
**
**  Disclaimer: 
**
**    This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**    requiring fail-safe performance, such as life-support or safety devices or systems, 
**    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**    or any other applications that could lead to death, personal injury, or severe property or 
**    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**    to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************/
//
// This module changes a data vector from one clock domain to another, safely.
// It holds the data in the old clock domain when a change in the data value
// is detected, then sends a synchronization signal across to the new clock
// domain (using two flops in the new clock domain for metastability).  When
// the synchronization signal has been seen by the second flop, the held data
// is clocked once in the new clock domain and is ready to use.
//
// This method delays the data by several clocks into the new domain, and can miss
// intermediate values of the data, if the data changes every clock in the old
// domain, for instance.  However, for data that only accumulates, such as status
// bits, or for configuration instructions from software that changes infrequently,
// there will be no problems using this method.
//
`timescale 1ps / 1ps

module synchronizer_vector #
(
   parameter DATA_WIDTH = 1
)
(
   input                        old_clk,
   input       [DATA_WIDTH-1:0] data_in,
   input                        new_clk,
   output wire [DATA_WIDTH-1:0] data_out
);

reg change_sync_1reg, change_sync_2reg, change_sync_3reg;
reg done_sync_1reg, done_sync_2reg;
reg [DATA_WIDTH-1:0] hold_reg = 'h0; //initially
wire data_changed;
reg  [DATA_WIDTH-1:0] data_reg = 'h0; //initially

parameter IDLE = 0, HOLD = 1;
reg state = IDLE;  //initially in IDLE


always @(posedge old_clk)
begin
  case (state)
  
    IDLE: if (data_changed)
            state <= HOLD;
    HOLD: if (done_sync_2reg)
            state <= IDLE;
  endcase
end

// Register input data to detect change in incoming data, hold when
// change is detected.
always @(posedge old_clk)
begin
  if (state == IDLE)
    hold_reg <= data_in;
end

assign data_changed = (data_in !== hold_reg) ? 1'b1 : 1'b0;

// Register enable signal twice for metastability crossing into new clock domain
always @(posedge new_clk)
begin
  change_sync_1reg <= (state == HOLD);
  change_sync_2reg <= change_sync_1reg;
  change_sync_3reg <= change_sync_2reg;
end

// Register twice for metastability, done signal back to old clock domain
always @(posedge old_clk)
begin
  // hold for at least two clocks for change from faster clock to slower clock
  done_sync_1reg <= change_sync_2reg || change_sync_3reg;
  done_sync_2reg <= done_sync_1reg;
end


// When change signal has been registered twice, allow data to cross from old
// clock domain to new clock domain.  The data should not have changed for 
// two of the new clock cycles, so should be quite stable.
always @(posedge new_clk)
begin
  if (change_sync_2reg)
    data_reg <= hold_reg; 
end

assign data_out = data_reg;

endmodule

