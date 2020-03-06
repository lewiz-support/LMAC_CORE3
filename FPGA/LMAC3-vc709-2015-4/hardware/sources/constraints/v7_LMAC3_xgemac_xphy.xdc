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