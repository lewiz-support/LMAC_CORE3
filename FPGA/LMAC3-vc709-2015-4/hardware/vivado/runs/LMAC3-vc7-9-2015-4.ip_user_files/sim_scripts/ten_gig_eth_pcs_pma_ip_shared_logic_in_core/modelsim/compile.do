vlib work
vlib msim

vlib msim/ten_gig_eth_pcs_pma_v6_0_3
vlib msim/xil_defaultlib

vmap ten_gig_eth_pcs_pma_v6_0_3 msim/ten_gig_eth_pcs_pma_v6_0_3
vmap xil_defaultlib msim/xil_defaultlib

vlog -work ten_gig_eth_pcs_pma_v6_0_3 -64 -incr \
"../../../ipstatic/ten_gig_eth_pcs_pma_v6_0_3/hdl/ten_gig_eth_pcs_pma_v6_0_rfs.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_gtwizard_gth_10gbaser_gt.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_gtwizard_gth_10gbaser_multi_gt.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_ff_synchronizer_rst.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_ff_synchronizer.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_local_clock_and_reset.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_sim_speedup_controller.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_cable_pull_logic.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_block.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_support.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_shared_clock_and_reset.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_gt_common.v" \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_ff_synchronizer_rst2.v" \

vlog -work xil_defaultlib -64 -incr \
"../../../../../sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core.v" \

vlog -work xil_defaultlib "glbl.v"

