
 add_fsm_encoding \
       {ten_gig_eth_pcs_pma_v6_0_3_tx_pcs_fsm.state} \
       { }  \
       {{000 00001} {001 00100} {010 01000} {011 10000} {100 00010} }

 add_fsm_encoding \
       {ten_gig_eth_pcs_pma_v6_0_3_rx_ber_mon_fsm.mcp1_state} \
       { }  \
       {{000 000001} {001 000010} {010 000100} {011 001000} {100 010000} {101 100000} }

 add_fsm_encoding \
       {ten_gig_eth_pcs_pma_v6_0_3_rx_pcs_fsm.mcp1_state} \
       { }  \
       {{000 00001} {001 01000} {010 10000} {011 00100} {100 00010} }

 add_fsm_encoding \
       {ten_gig_eth_pcs_pma_v6_0_3_mdio_interface.state} \
       { }  \
       {{0000 0000000001} {0001 0000000010} {0010 0000000100} {0011 0000001000} {0100 0000010000} {0101 0000100000} {0110 0001000000} {0111 0100000000} {1000 1000000000} {1001 0010000000} }
