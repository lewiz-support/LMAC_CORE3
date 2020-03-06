//
//
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
//

The main purpose of this release is to provide an FPGA emulation for LMAC_CORE3.
It illustrates an example how to implement Ethernet port on FPGA with Lewiz LMAC_CORE3. This example uses
Xilinx VC709 FPGA evaluation board which contains a Virtex 7 VX690T FPGA chip. (This board is also
compatible with LeWiz's iTrade7240(TM) board. 
http://lewiz.com/products/itrade7240.html - 
except the iTrade7240(TM) board is developed for production deployment.)

This example will show how to connect the LMAC_CORE3 with Xilinx FPGA SerDes.
It will also show how to use Xilinx Vivado2015.4 tool to build the FPGA project, simulate, 
synthesize the design for FPGA, Run Xilinx Implementation (Place & Route), 
meeting timing and generate the bitstream.

This implementation uses Xilinx's VC709 Connectivity Kit design and its test environment as the starting point
except this design uses LeWiz's LMAC CORE3. The Connectivity Kit's test environment and test vector were used to 
re-simulate the gate level netlist (including both the LMAC CORE3 and the SerDes in loopback mode) to
prove that the design is working after going through the Xilinx tool process. This design's main purpose
is to show the Ethernet implementation. Where not needed, other parts of the Connectivity Kit were removed. 

The project's directory contains 3 sub directories:
1) LMAC3-vc709-2015-4 -> This directory is for behavioral simulation, synthesis and implementaion of LMAC_CORE3.
2) LMAC3-vc709-2015-4-gate_level  -> This directory is for gate level simulation of LMAC_CORE3 + SerDes loopback
3) Screenshots -> 	This directory contains various screenshots of behavioral simulation and gate-level simulation including resulting waveforms. The main purpose of the screenshots is to show that the functionality of behavioral simulation and gate-level simulation remain the same, i.e. working. Screenshots of Gate level simulations can be found under GATE_LEVEL_SIMULATION directory.Each screenshot contains explanation of the results in the image


	differential clock input ( from testbench or Board)
                          |
 -------------------------|--------------------------------
|LMAC3-vc709-2015-4       |                               |
|                         |                               |
|                         |                               |
|                         V                               |
|    ----------------------------------------------       |
|   |CLOCK CONTROL BLOCK                           |      |
|   |provides clock to other modules	           |      |
|    ----------------------------------------------       |
|                      |                                  |
|      		       V                                  |
|    ----------------------------------------------       |
|   |NETWORK_PATH_INST_0                           |      |
|   |                                              |      |
|   |     -----------------------------------      |      |
|   |    | LOOPBACK MODULE                   |     |      |
|   |    | (to loopback input data)          |     |      |
|   |     -----------------------------------      |      |
|   |             |         ^                      |      |
|   |	          v         |                      |      |
|   |     ------------------------------------     |      |
|   |    | LMAC SYNTH                         |    |      |
|   |    |(LEWIZ MAC HDL/GATE TOP)            |    |      |
|   |     ------------------------------------     |      |      
|   |             |        ^                       |      |
|   |             v        |                       |      |
|   |     ------------------------------------     |      |
|   |    | ten_gig_pcs_pma_inst               |    |      |
|   |    |(Xilinx 10G SERDES)                 |    |      |
|   |     ------------------------------------     |      |
|   |             |        ^                       |      |
|   |             |        |                       |      |
|   |             |        |                       |      |
|    ----------------------------------------------       |
|                 |        |                              |
 -----------------|--------|------------------------------
                  v        |                      
 		diff_tx   diff_rx      

LMAC3-vc709-2015-4 directory and LMAC3-vc709-2015-4-gate_level directory, 
each contains 1 sub-directory: Hardware.

The Hardware directory contains 2 sub directories:

	1) sources
	2) vivado
	
	1) sources: This directory contains 5 sub directories namely:
		
		1) constraints : All the constraints files are under this directory. 
		
		2) hdl : This directory mainly consists of verilog code. It contains verilog code of LMAC_CORE3,
                   Loopback module, TOP level file etc.
		 
		3) ip_catalog : We are using ten_gig_pcs_pma ip. This directory contains the source code for that IP.
		
		4) test_mem : This directory contains a script for running the test.
		
		5) testbench : This directory consists the testbench used for simulation.

	2) Vivado: This directory contains Vivado scripts & project files
		
		1)  runs:	 (generated by Vivado)

The following provides instructions for re-running the different process in the design example

******FOR BEHAVIORAL SIMULATION****		
				
	STEPS to duplicate the work.
	
	1)  Copy the LMAC3-vc709-2015-4 directory.
	2)  Open Vivado 2015.4 and click on "OPEN PROJECT"
	3)  browse to the location where "../LMAC3-vc709-2015-4/hardware/vivado/runs/" and 
             select "LMAC3-vc7-9-2015-4.xpr"
	4)  Click OK.
	5)  You should now be able to see the Project Manager window with LMAC3-vc709-2015-4 as top design file.
	6)  Click on run simulation under SIMULATION tab and select run behavioral simulation.
	7)  Once the Simulation is completed, open multiple waveform windows by issuing "create_wave_config" 
               config in the TCL console.
	8)  Once all the waveform are up, issue "run 50us" command in TCL console.
	9)  To run the test script, issue command "cd "PATH to LMAC3-vc709-2015-4 directory"/hardware/sources/"
	10) Next issue command "source test_mem/script_test_siml"
	11) After running the script enter "run 10us" command to see the waveforms.


******FOR SYNTHESIS****

	1) Click Run Synthesis under "Synthesis tab".


******FOR VIVADO IMPLEMENTATION (FPGA Place & Route) ****

	1) Click Run Implementation under "Implementation tab".
		- you can also generate timing report after implementation, and can also open the implemented design.
		
******FOR VIVADO GENERATE BITSTREAM  ****

	1) Click Generate Bitstream under "Program and Debug tab".
		
******FOR GATE LEVEL SIMULATION****

	We have extracted the netlist file generated after performing synthesis on LMAC3-vc709-2015-4 project 
        and created a new project for gate level simulation. 
	
	1)  Copy the LMAC3-vc709-2015-4-gate_level directory.
	2)  Open Vivado 2015.4 and click on "OPEN PROJECT"
	3)  browse to the location where "PATH to LMAC3-vc709-2015-4-gate_level/hardware/vivado/runs/" and 
              select "LMAC3-vc7-9-2015-4.xpr"
	4)  Click OK.
	5)  You should now be able to see the Project Manager window with LMAC3-vc709-2015-4 as top design file.
	6)  Click on run simulation under SIMULATION tab and select run behavioral simulation.
	7)  Once the Simulation is completed, open multiple waveform windows by issuing "create_wave_config" 
              config in the TCL console.
	8)  Once all the waveform are up, issue "run 50us" command in TCL console.
	9)  To run the test script, issue command 
             "cd "PATH to LMAC3-vc709-2015-4-gate_level directory"/hardware/sources/"
	10) Next issue command "source test_mem/script_test_siml"
	11) After running the script enter "run 10us" command for see the waveforms.
