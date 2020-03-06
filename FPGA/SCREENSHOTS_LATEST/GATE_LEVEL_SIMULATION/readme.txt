1_gate_level_behavioral_simulation_force_packet_at_rx
	- Shows the point at which the cgmii_rxd/rxc are forced.

2_gate_level_loopback_module
	- Shows the output of LMAC2 going as an input to the LOOPBACK_MODULE, and output of the LOOPBACK_MODULE going to TX_FIFO of LMAC3.

3_gate_level_LMAC_SYNTH_TXD
	- Shows the data going out of the LMAC3 on the cgmii_txd/txc lines (after being looped back).

4_gate_level_phy_emulator
	- Shows the data going to the PCS/PMA IP which is then looped back again and sent on the cgmii_rxd/rxc lines.

5_gate_level_lmac_synth_received_From_phy
	- Data coming back on the cgmii_rxd/rxc which will go as an input to the LMAC3 module.

6_gate_level_multiple_packet_rx_tx
	- Same packet will be looped back on both sides (LMAC and PCS/PMA IP).