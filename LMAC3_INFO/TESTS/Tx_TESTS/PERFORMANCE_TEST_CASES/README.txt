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



The test cases in this diectory are used for testing the performance of the LMAC transmitting functionality.

The test plan invloves 
	10 test cases for   10G mode
	10 test cases for  25G mode
	10 test cases for   40G mode.
	10 test cases for   50G mode.
	10 test cases for 100G mode
---------------------------------------------------------------------------
In 100G and 10G mode, each test cases will be sending 8 various length packet back-to-back with accurate gen_en_wr signal activited to ensure maximum performance during the transmission.

---------------------------------------------------------------------------
In 50G, 40G mode, each test cases will be sending 8 various length packet back-to-back with accurate gen_en_wr signal activited to ensure maximum performance during the transmission.

---------------------------------------------------------------------------
In 25G mode, each test cases will be sending 8 various length packet back-to-back with accurate gen_en_wr signal activited to ensure maximum performance during the transmission.

 
Further details can be seen in the documentation in each test case.