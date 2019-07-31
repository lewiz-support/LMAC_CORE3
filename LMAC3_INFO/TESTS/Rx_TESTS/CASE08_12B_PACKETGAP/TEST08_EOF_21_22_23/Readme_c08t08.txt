// The following COPYRIGHT and legend (marked as comment "//") are applicable for this
// README file and the images (*.PNG file) associated with this test.
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
//    Author: LeWiz Communications, Inc.
//    Language: Verilog
//


--> Case08-Test08

	- Packet Gap				 : 12 Bytes of idle patterns between packets 1 and 2.
	                             
	- Packet1 : Multicast		 : 1st QWD Destination MAC: "0000_005e_0001" 
				Normal IP Packet : 2nd QWD "0045_0008"
				Size			 : 98 Bytes				                 
	                             
	- Packet2 : Broadcast		 : 1st QWD Destination MAC: "ffff_ffff_ffff"
				Normal IP Packet : 2nd QWD "0045_0008"
				Size			 : 77 Bytes
				                 
	- Packet3 : Unicast		 	 : 1st QWD Destination MAC: "af4e_0032_1200"
				Normal IP Packet : 2nd QWD "0045_0008"
				Size			 : 398 Bytes
				                 
	- Packet4 : Multicast	 	 : 1st QWD Destination MAC: "0000_005e_0001"
				ARP Packet		 : 2nd QWD "0100_0608"
				Size			 : 591 Bytes 
				                 
	- Packet5 : Broadcast	 	 : 1st QWD Destination MAC: "ffff_ffff_ffff"
				Normal IP Packet : 2nd QWD "0045_0008"
				Size			 : 150 Bytes   
				                           
	- Data Memory File			 : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/rx_pkt_gen_data.mem
                                                                
	- Control Memory File		 : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/rx_pkt_gen_ctrl.mem
	                                                            
	- Simulation Script File 10G : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/Script4_RxPath_Test_c08t08_10G.txt
							 25G : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/Script4_RxPath_Test_c08t08_25G.txt
							 40G : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/Script4_RxPath_Test_c08t08_40G.txt
							 50G : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/Script4_RxPath_Test_c08t08_50G.txt
						    100G : C:/LMAC3_INFO/TESTS/Rx_TESTS/CASE08_12B_PACKETGAP/TEST08_EOF_21_22_23/Script4_RxPath_Test_c08t08_100G.txt