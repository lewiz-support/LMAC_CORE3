//
//////////////////////////////////////////////////////////////////////////////////////////-
// Copyright  2011, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
//////////////////////////////////////////////////////////////////////////////////////////-
//
// Disclaimer:
// This disclaimer is not a license and does not grant any rights to the materials
// distributed herewith. Except as otherwise provided in a valid license issued to
// you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
// MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
// DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
// INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
// OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
// (whether in contract or tort, including negligence, or under any other theory
// of liability) for any loss or damage of any kind or nature related to, arising
// under or in connection with these materials, including for any direct, or any
// indirect, special, incidental, or consequential loss or damage (including loss
// of data, profits, goodwill, or any type of loss or damage suffered as a result
// of any action brought by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-safe, or for use in any
// application requiring fail-safe performance, such as life-support or safety
// devices or systems, Class III medical devices, nuclear facilities, applications
// related to the deployment of airbags, or any other applications that could lead
// to death, personal injury, or severe property or environmental damage
// (individually and collectively, "Critical Applications"). Customer assumes the
// sole risk and liability of any use of Xilinx products in Critical Applications,
// subject only to applicable laws and regulations governing limitations on product
// liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////////////////-
//
//
//
//             _ ______ ____ ____ __ __ __
//             | |/ / ___| _ \/ ___|| \/ |/ /_
//             | ' / | | |_) \___ \| |\/| | '_ \
//             | . \ |___| __/ ___) | | | | (_) |
//             |_|\_\____|_| |____/|_| |_|\___/
// 
// 
//
// This reference design is to illustrate a way in which a KCPSM6 processor can implement 
// a PMBus protocol and communicate with the UCD9248 power supply controller
// (Texas Instruments) on the KC705 board. The design also implements a bridge between a 
// UART and a Block Memory (BRAM) within a device so that information associated with the 
// power supply controller can be observed both outside of the device and by another 
// circuit connected to the second port of the BRAM at some point in the future.
//
// It implements a  115200 baud, 1 stop bit, no parity, no handshake UART connection 
// providing simple text based commands which enable the BRAM treated as 1K words of 
// 32-bits to be read from and written to. 
//
// All data values are represented as 8-digit hexadecimal values.
//
// Whilst this bridge design could be more efficiently implemented by exploiting the 
// ability for the port of the BRAM to be configured as 9-bits (8-bits plus parity) a 
// full 32-bit data path has been created. The reason for this is that it has been
// designed initially for an application in which the second port of the BRAM will be 
// used in a 32-bit application. It may be important that all bytes within a 32-bit 
// location are read or written in one transaction (i.e. If four byte transactions 
// were used by this bridge to write a new 32-bit value then the 32-bit application 
// may observe a the intermediate values which would be undesirable).    
// 
// If a frequency applied to the bridge module is not 50MHz then the KCPSM6 program will 
// require some adjustments to maintain the same communication settings.
// 
// IMPORTANT: The BRAM must be connected to this module using the same 50MHz clock
//            (Synchronous interface).
//
//
//
//////////////////////////////////////////////////////////////////////////////////////////-
`timescale 1ps / 1ps

module power_test_control
  (   output reg          bram_we,
      output reg          bram_en,
      output reg  [9:0]   bram_address,
      output reg [31:0]   bram_data_in,
      input      [31:0]   bram_data_out,
      input               pmbus_clk_in,
      output reg          pmbus_clk_out,
      input               pmbus_data_in,
      output reg          pmbus_data_out,
      output reg          pmbus_control,
      input               pmbus_alert,
      input               rst,
      input               clk
);


//
//////////////////////////////////////////////////////////////////////////////////////////-
//
// Signals
//
//////////////////////////////////////////////////////////////////////////////////////////-
//
//
// Signals used to connect KCPSM6
//
wire  [11:0]      address;
wire  [17:0]      instruction;
wire              bram_enable;
reg    [7:0]      in_port;
wire   [7:0]      out_port;
wire   [7:0]      port_id;
wire              write_strobe;
wire              k_write_strobe;
wire              read_strobe;
wire              interrupt;
wire              interrupt_ack;
wire              kcpsm6_sleep;
wire              kcpsm6_reset;
//
//
// Signals used to connect XADC
//
reg    [6:0]      xadc_addr = 'b0;
reg   [15:0]      xadc_di = 'b0;
wire              xadc_den;
wire              xadc_dwe;
wire              xadc_drdy;
reg               xadc_tip= 'b0;
wire  [15:0]      xadc_do;
reg   [15:0]      xadc_read_data = 'b0;
wire              xadc_jtagbusy;
wire              xadc_jtaglocked;
wire              xadc_jtagmodified;
//
wire              vp;
wire              vn;
wire  [15:0]      vauxp;
wire  [15:0]      vauxn;
//
//////////////////////////////////////////////////////////////////////////////////////////-
//
// Start of circuit description
//
//////////////////////////////////////////////////////////////////////////////////////////-
//
//
////////////////////////////////////////////////////////////////////////////////////////-
// Instantiate KCPSM6 and connect to program ROM
////////////////////////////////////////////////////////////////////////////////////////-
//
// The generics can be defined as required. In this case the 'hwbuild' value is used to 
// define a version using the ASCII code for the desired letter. The interrupt vector 
// has been set to address 7F0 which would provide 16 instructions to implement an 
// interrupt service route (ISR) before the end of a 2K program space. Interrupt is not 
// used in this design at this time but could be exploited in the future.
//
kcpsm6
  # (   
      .hwbuild                 (12'h041),    // ASCII Character "A"
      .interrupt_vector        (12'h7F0),   
      .scratch_pad_memory_size (64)
     )
  processor 
     (           .address (address),
             .instruction (instruction),
             .bram_enable (bram_enable),
                 .port_id (port_id),
            .write_strobe (write_strobe),
          .k_write_strobe (k_write_strobe),
                .out_port (out_port),
             .read_strobe (read_strobe),
                 .in_port (in_port),
               .interrupt (interrupt),
           .interrupt_ack (interrupt_ack),
                   .sleep (kcpsm6_sleep),
                   .reset (kcpsm6_reset), 
                     .clk (clk)
     );

 
  assign kcpsm6_reset = rst;
  assign kcpsm6_sleep = 1'b0;
  assign interrupt = interrupt_ack;

  //
  // Program memory up to 4k with JTAG Loader option
  // 
  power_test_control_program #(           
                .C_FAMILY ("7S"), 
       .C_RAM_SIZE_KWORDS (2),
    .C_JTAG_LOADER_ENABLE (0))
  program_rom
    (      .address ( address ),      
       .instruction ( instruction ),
            .enable ( bram_enable ),
               .rdl (),
               .clk ( clk )
    );

  //
  ////////////////////////////////////////////////////////////////////////////////////////-
  // KCPSM6 general purpose input ports 
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  always @(posedge clk)
  begin

      case (port_id[3:0]) 
       
        // Read 32-bit data from BRAM using four 8-bit ports 00, 01, 02 and 03 hex
        4'b0000:    in_port <= bram_data_out[7 : 0];
        4'b0001:    in_port <= bram_data_out[15 : 8];
        4'b0010:    in_port <= bram_data_out[23 : 16];
        4'b0011:    in_port <= bram_data_out[31 : 24];

        // Read PMBus at port address 04 hex
        4'b0100:  begin
                    in_port[0] <= pmbus_clk_in;
                    in_port[1] <= pmbus_data_in;
                    in_port[2] <= pmbus_alert;
                  end       
        // Read 16-bit XADC DRP data at port addresses 0C and 0D hex
        4'b1100:    in_port <= xadc_read_data[7 : 0];
        4'b1101:    in_port <= xadc_read_data[15 : 8];
        
        // Read XADC DRP status signals at port address 0E hex
        4'b1110:  begin
                    in_port[0] <= xadc_tip;
                    in_port[1] <= xadc_jtagbusy;
                    in_port[2] <= xadc_jtaglocked;
                    in_port[3] <= xadc_jtagmodified;
                  end

        // To ensure minimum logic implementation when defining a multiplexer always
        // use don't care for any of the unused cases
        default:    in_port <= 8'bx;  
       
      endcase

    end


  //
  ////////////////////////////////////////////////////////////////////////////////////////-
  // KCPSM6 general purpose output ports 
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  // A combination of one-hot and encoded addressing schemes are employed.
  //
  //
  ////////////////////////////////////////////////////////////////////////////////////////-
  // KCPSM6 general purpose output ports 
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  // A combination of one-hot and encoded addressing schemes are employed.
  //

  always @(posedge clk)
  begin

      // 'write_strobe' is used to qualify all writes to general output ports.
      if (write_strobe == 1'b1) 
      begin
        // Write 32-bit data to BRAM using four 8-bit ports 04, 05, 06 and 07 hex
        //    (port_id(2) = '1' and port_id(1:0) selects the data byte) 

        if ((port_id[2] == 1'b1) && (port_id[1:0] == 2'b00)) 
          bram_data_in[7:0] <= out_port;

        if ((port_id[2] == 1'b1) && (port_id[1:0] == 2'b01)) 
          bram_data_in[15:8] <= out_port;

        if ((port_id[2] == 1'b1) && (port_id[1:0] == 2'b10)) 
          bram_data_in[23:16] <= out_port;

        if ((port_id[2] == 1'b1) && (port_id[1:0] == 2'b11)) 
          bram_data_in[31:24] <= out_port;

        // Write 10-bit address to BRAM using ports 08 and 09 hex
        //    (port_id(3) = '1' and port_id(0) selects the address byte) 

        if ((port_id[3] == 1'b1) && (port_id[0] == 1'b0)) 
          bram_address[7:0] <= out_port;

        if ((port_id[3] == 1'b1) && (port_id[0] == 1'b1)) 
          bram_address[9:8] <= out_port[1:0];

        // Drive PMBus at port address 20 hex
        
        if (port_id[5] == 1'b1)
        begin
          pmbus_clk_out <= out_port[0];
          pmbus_data_out <= out_port[1];
          pmbus_control <= out_port[2];
        end
        

        // Write 16-bit XADC DRP address at port addresses 80 hex
        if ((port_id[7] == 1'b1) && (port_id[1:0] == 2'b00))
          xadc_addr <= out_port[6:0];

        // Write 16-bit XADC DRP data at port addresses 81 and 82 hex
        if ((port_id[7] == 1'b1) && (port_id[1:0] == 2'b01))
          xadc_di[7:0] <= out_port;

        if ((port_id[7] == 1'b1) && (port_id[1:0] == 2'b10))
          xadc_di[15:8] <= out_port;

      end
  end 


  //
  ////////////////////////////////////////////////////////////////////////////////////////-
  // KCPSM6 constant optimised output ports 
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  always @(posedge clk)
  begin


      // 'k_write_strobe' is used to qualify all writes to constant optimised output ports.
      if (k_write_strobe == 1'b1)
      begin
        // Control BRAM using port 01 hex

        if (port_id[0] == 1'b1)
        begin
          bram_we <= out_port[0];
          bram_en <= out_port[1];
        end
        
        // Sleep control of Power Consuming Modules using port 02 hex

        if (port_id[1] == 1'b1) 
        begin
          bram_we <= out_port[0];
          bram_en <= out_port[1];
        end

      end
  end

  //
  // A transaction with the XADC is initiated by a write to 
  // constant optimised port addresses 04 hex. The write is used to form
  // a single clock cycle strobe on the DEN input to XADC and 
  // define the level of DWE to define a read (0) or write (1) operation.
  // This is a purely combinatorial process in order that the k_write_strobe 
  // is used to define only a single clock cycle pulse.
  //
  
  assign xadc_den = k_write_strobe & port_id[2];
  assign xadc_dwe = out_port[0];  

  //
  ////////////////////////////////////////////////////////////////////////////////////////-
  // XADC
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  // The XADC contains a number of internal registers that are accessed by KCPSM6
  // via the DRP port. The first 64 address locations (00 to 3F) are read only and provide 
  // status and measurement data etc. The remaining addresses (40 to 7F) are read/write 
  // registers that can be used to control and configure the system monitor. Note that not
  // all addresses correspond with actual registers and multiple addresses should not be 
  // modified. Please check UG370 for details and refer to the KCPSM6 code to see which 
  // registers are actually accessed.
  //
  // The initial values for the writable registers are also defined during configuration 
  // using the INIT_40 to INIT_57 values. All registers are 16-bits.
  //
  // INIT_42 corresponds with 'Configuration Register 2' of which the most significant 
  // byte defines a clock division factor CD[7:0]. DCLK is the system clock provided to 
  // the XADC and must be in the range 8 to 80MHz. In this design a 66MHz clock 
  // is used. Internally to XADC an ADCCLK is formed through the division of 
  // DCLK by the factor CD[7:0]. This clock is used to drive the A/D converter and must 
  // be in the range 1 to 5.2MHz. In this design 50MHz/10 = 5MHz is defined as the 
  // initial ADC clock frequency. Hence CD[7:0] = 10 decimal = 0A hex. So INIT_42=0A00.
  //
  // VP/VN is used to measure VCCint current.
  // VAUXP(12)/VAUXN(12)is used to measure +12v board supply voltage. 
  // VAUXP(13)/VAUXN(13)is used to measure +12v board supply current. 
  //

  //vauxp <= "00" & board_amp_vp & board_volt_vp & "000000000000";
  //vauxn <= "00" & board_amp_vn & board_volt_vn & "000000000000";
  
  assign vp = 1'b0; // vccint_amp_vp;
  assign vn = 1'b0; // vccint_amp_vn; 
  assign vauxp = 'b0;
  assign vauxn = 'b0;

  XADC
    #(
       // INIT_40 - INIT_42: XADC configuration registers
       .INIT_40 (16'h0000),
       .INIT_41 (16'h20C7),
       .INIT_42 (16'h0A00),
       // INIT_43 - INIT_47: XADC Test registers (do not edit)
       .INIT_43 (16'h0000),
       .INIT_44 (16'h0000),
       .INIT_45 (16'h0000),
       .INIT_46 (16'h0000),
       .INIT_47 (16'h0000),
       // INIT_48 - INIT_4F: Sequence registers for the Channel Sequencer
       .INIT_48 (16'h0401),
       .INIT_49 (16'h0000),
       .INIT_4A (16'h0000),
       .INIT_4B (16'h0000),
       .INIT_4C (16'h0000),
       .INIT_4D (16'h0000),
       .INIT_4F (16'h0000),
       .INIT_4E (16'h0000), // Sequence register 6
       // INIT_50 - INIT_58, INIT5C: Alarm threshold registers
       .INIT_50 (16'h0000),
       .INIT_51 (16'h0000),
       .INIT_52 (16'hE000),
       .INIT_53 (16'h0000),
       .INIT_54 (16'h0000),
       .INIT_55 (16'h0000),
       .INIT_56 (16'hCAAA),
       .INIT_57 (16'h0000),
       .INIT_58 (16'h0000),
       .INIT_5C (16'h0000),
       // Reserved: Reserved for future use
       .INIT_59 (16'h0000),
       .INIT_5A (16'h0000),
       .INIT_5B (16'h0000),
       .INIT_5D (16'h0000),
       .INIT_5E (16'h0000),
       .INIT_5F (16'h0000),
       // Simulation attributes: Set for proepr simulation behavior
       .SIM_MONITOR_FILE ("design.txt")  // Analog simulation data file name
    )
  XADC_inst (
       // Alarm Ports: 8-bit (each) output: ALM, OT
       .ALM ( ),                       // 8-bit output: Output alarm for temp, Vccint and Vccaux
       .OT ( ),                        // 1-bit output: Over-Temperature alarm output
       // DRP Ports: 16-bit (each) output: Dynamic Reconfiguration Ports
       .DO ( xadc_do ),                     // 16-bit output: DRP output data bus
       .DRDY ( xadc_drdy ),                 // 1-bit output: DRP data ready output signal
       // Status Ports: 1-bit (each) output: XADC status ports
       .BUSY ( ),                      // 1-bit output: ADC busy output
       .CHANNEL ( ),                   // 5-bit output: Channel selection outputs
       .EOC ( ),                       // 1-bit output: End of Conversion output
       .EOS ( ),                       // 1-bit output: End of Sequence output
       .JTAGBUSY ( xadc_jtagbusy ),         // 1-bit output: JTAG DRP transaction in progress output
       .JTAGLOCKED ( xadc_jtaglocked ),     // 1-bit output: JTAG requested DRP port lock output
       .JTAGMODIFIED ( xadc_jtagmodified ), // 1-bit output: JTAG Write to the DRP has occurred output
       .MUXADDR ( ),                   // 5-bit output: External MUX channel decode output
       // Auxiliary Analog-Input Pairs: 16-bit (each) input: VAUXP[15:0], VAUXN[15:0]
       .VAUXN ( vauxn ),                    // 16-bit input: N-side auxiliary analog input
       .VAUXP ( vauxp ),                    // 16-bit input: P-side auxiliary analog input
       // Control and Clock Ports: 1-bit (each) input: Reset, conversion start and clock inputs
       .CONVST ( 1'b0 ),                     // 1-bit input: Convert start input
       .CONVSTCLK ( 1'b0 ),                  // 1-bit input: Convert start input
       .RESET ( 1'b0 ),                      // 1-bit input: Active-high reset input
       // DRP Ports: 7-bit (each) input: Dynamic Reconfiguration Ports
       .DADDR ( xadc_addr ),                // 7-bit input: DRP input address bus
       .DCLK ( clk ),                       // 1-bit input: DRP clock input
       .DEN ( xadc_den ),                   // 1-bit input: DRP input enable signal
       .DI ( xadc_di ),                     // 16-bit input: DRP input data bus
       .DWE ( xadc_dwe ),                   // 1-bit input: DRP write enable input
       // Dedicated Analog Input Pair: 1-bit (each) input: VP/VN
       .VN ( vn ),                          // 1-bit input: N-side analog input
       .VP ( vp )                          // 1-bit input: P-side analog input
    );


  ////////////////////////////////////////////////////////////////////////////////////////-

  //
  // When information read from the XADC registers it is provided on the D0 
  // output. However, it is only valid when the DRDY strobe is High so the information must 
  // be catured on the clock edge that DRDY is High so that it can be read by KCPSM6. 
  //
  // Any read or write operation is initiated by a single cycle High strobe being applied 
  // to the DEN input. The 7-bit address of the register to be accessed must be provided on 
  // the DADDR input along with the 16-bit data to be written on the DI input if appropreate. 
  // The DWE input defines if the operation is a read when (0) or write (1).
  //
  // In this design KCPSM6 will present values for DADDR and DI in advance and then initiate 
  // the operation with a write to a constant optimised port. This will be used to generate 
  // a single cycle DEN strobe directly from the k_write_strobe as well as define the state 
  // of DWE for a read or write operation. At the same time a 'transaction in progress'
  // flag (xadc_tip) will be set which will remain High until the subsequent DRDY strobe is 
  // observed. This flag can then be monitored by KCPSM6 to determine when the operation 
  // is complete before reading the newly captured data following a read operation or 
  // performing another transaction. 
  //
  always @(posedge clk)
  begin

      if (xadc_drdy == 1'b1) begin
        // Capture output data when DRDY is High 
        xadc_read_data <= xadc_do;
        // Clear 'transaction in progress' flag 
        xadc_tip <= 'b0;
       end else begin
        // Hold last captured value 
        xadc_read_data <= xadc_read_data;
        if (xadc_den == 1'b1) 
          // Set 'transaction in progress' flag if DEN is High
          xadc_tip <= 1'b1;
         else
          // Keep current state of flag
          xadc_tip <= xadc_tip;
       end
  end

  
endmodule

//////////////////////////////////////////////////////////////////////////////////////////-
//
// END OF FILE power_test_control.v
//
//////////////////////////////////////////////////////////////////////////////////////////-

