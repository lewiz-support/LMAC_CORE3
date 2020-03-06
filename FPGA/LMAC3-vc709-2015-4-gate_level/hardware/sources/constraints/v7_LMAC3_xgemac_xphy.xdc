##
##
##
## Copyright (C) 2018 LeWiz Communications, Inc. 
## 
## This library is free software; you can redistribute it and/or
## modify it under the terms of the GNU Lesser General Public
## License as published by the Free Software Foundation; either
## version 2.1 of the License, or (at your option) any later version.
## 
## This library is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## Lesser General Public License for more details.
## 
## You should have received a copy of the GNU Lesser General Public
## License along with this library release; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
## 
## LeWiz can be contacted at:  support@lewiz.com
## or address:  
## PO Box 9276
## San Jose, CA 95157-9276
## www.lewiz.com
## 
##

## XGEMAC & 10GBASE-R constraints

##---------------------------------------------------------------------------------------
## 10GBASE-R constraints
##---------------------------------------------------------------------------------------
## SFP+ Cage mapping on VC709
# P2 --> X1Y13
# P3 --> X1Y12
# P4 --> X1Y14
# P5 --> X1Y15
## GT placement ## MGT_BANK_113

set_property PACKAGE_PIN AN5 [get_ports xphy0_rxn]
set_property PACKAGE_PIN AN6 [get_ports xphy0_rxp]
set_property PACKAGE_PIN AP3 [get_ports xphy0_txn]
set_property PACKAGE_PIN AP4 [get_ports xphy0_txp]

#set_property PACKAGE_PIN AM7 [get_ports xphy1_rxn]
#set_property PACKAGE_PIN AM8 [get_ports xphy1_rxp]
#set_property PACKAGE_PIN AN1 [get_ports xphy1_txn]
#set_property PACKAGE_PIN AN2 [get_ports xphy1_txp]

#set_property PACKAGE_PIN AL5 [get_ports xphy2_rxn]
#set_property PACKAGE_PIN AL6 [get_ports xphy2_rxp]
#set_property PACKAGE_PIN AM3 [get_ports xphy2_txn]
#set_property PACKAGE_PIN AM4 [get_ports xphy2_txp]

#set_property PACKAGE_PIN AJ5 [get_ports xphy3_rxn]
#set_property PACKAGE_PIN AJ6 [get_ports xphy3_rxp]
#set_property PACKAGE_PIN AL1 [get_ports xphy3_txn]
#set_property PACKAGE_PIN AL2 [get_ports xphy3_txp]