proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7vx690tffg1761-2
  set_property board_part xilinx.com:vc709:part0:1.7 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.cache/wt [current_project]
  set_property parent.project_path C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.xpr [current_project]
  set_property ip_repo_paths c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.cache/ip [current_project]
  set_property ip_output_repo c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.cache/ip [current_project]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/synth_1/LMAC3_vc709_2015_4.dcp
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/br_pre_ctrl_fifo_ip_1024x40_synth_1/br_pre_ctrl_fifo_ip_1024x40.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/br_pre_ctrl_fifo_ip_1024x40_synth_1/br_pre_ctrl_fifo_ip_1024x40.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/br_pre_data_fifo_ip_1024x256_synth_1/br_pre_data_fifo_ip_1024x256.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/br_pre_data_fifo_ip_1024x256_synth_1/br_pre_data_fifo_ip_1024x256.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/br_sfifo_ip_4x32_synth_1/br_sfifo_ip_4x32.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/br_sfifo_ip_4x32_synth_1/br_sfifo_ip_4x32.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/pktctrl_fifo_ip_4kx32_synth_1/pktctrl_fifo_ip_4kx32.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/pktctrl_fifo_ip_4kx32_synth_1/pktctrl_fifo_ip_4kx32.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/ipcs_fifo_ip_512x64_synth_1/ipcs_fifo_ip_512x64.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/ipcs_fifo_ip_512x64_synth_1/ipcs_fifo_ip_512x64.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/fmac_rxfifo_ip_4Kx256_synth_1/fmac_rxfifo_ip_4Kx256.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/fmac_rxfifo_ip_4Kx256_synth_1/fmac_rxfifo_ip_4Kx256.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/txfifo_ip_1024x256_synth_1/txfifo_ip_1024x256.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/txfifo_ip_1024x256_synth_1/txfifo_ip_1024x256.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/x2c_bcnt_fifo_ip_256x32_synth_1/x2c_bcnt_fifo_ip_256x32.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/x2c_bcnt_fifo_ip_256x32_synth_1/x2c_bcnt_fifo_ip_256x32.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/x2c_ctrl_fifo_ip_1024x32_synth_1/x2c_ctrl_fifo_ip_1024x32.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/x2c_ctrl_fifo_ip_1024x32_synth_1/x2c_ctrl_fifo_ip_1024x32.dcp]
  add_files -quiet C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/x2c_data_fifo_ip_1024x256_synth_1/x2c_data_fifo_ip_1024x256.dcp
  set_property netlist_only true [get_files C:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.runs/x2c_data_fifo_ip_1024x256_synth_1/x2c_data_fifo_ip_1024x256.dcp]
  read_xdc -ref ten_gig_eth_pcs_pma_ip_shared_logic_in_core -cells inst c:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core.xdc]
  read_xdc -mode out_of_context -ref br_pre_ctrl_fifo_ip_1024x40 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_ctrl_fifo_ip_1024x40/br_pre_ctrl_fifo_ip_1024x40_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_ctrl_fifo_ip_1024x40/br_pre_ctrl_fifo_ip_1024x40_ooc.xdc]
  read_xdc -ref br_pre_ctrl_fifo_ip_1024x40 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_ctrl_fifo_ip_1024x40/br_pre_ctrl_fifo_ip_1024x40/br_pre_ctrl_fifo_ip_1024x40.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_ctrl_fifo_ip_1024x40/br_pre_ctrl_fifo_ip_1024x40/br_pre_ctrl_fifo_ip_1024x40.xdc]
  read_xdc -mode out_of_context -ref br_pre_data_fifo_ip_1024x256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_data_fifo_ip_1024x256/br_pre_data_fifo_ip_1024x256_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_data_fifo_ip_1024x256/br_pre_data_fifo_ip_1024x256_ooc.xdc]
  read_xdc -ref br_pre_data_fifo_ip_1024x256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_data_fifo_ip_1024x256/br_pre_data_fifo_ip_1024x256/br_pre_data_fifo_ip_1024x256.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_pre_data_fifo_ip_1024x256/br_pre_data_fifo_ip_1024x256/br_pre_data_fifo_ip_1024x256.xdc]
  read_xdc -mode out_of_context -ref br_sfifo_ip_4x32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_sfifo_ip_4x32/br_sfifo_ip_4x32_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_sfifo_ip_4x32/br_sfifo_ip_4x32_ooc.xdc]
  read_xdc -ref br_sfifo_ip_4x32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_sfifo_ip_4x32/br_sfifo_ip_4x32/br_sfifo_ip_4x32.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/br_sfifo_ip_4x32/br_sfifo_ip_4x32/br_sfifo_ip_4x32.xdc]
  read_xdc -mode out_of_context -ref pktctrl_fifo_ip_4kx32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/pktctrl_fifo_ip_4kx32/pktctrl_fifo_ip_4kx32_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/pktctrl_fifo_ip_4kx32/pktctrl_fifo_ip_4kx32_ooc.xdc]
  read_xdc -ref pktctrl_fifo_ip_4kx32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/pktctrl_fifo_ip_4kx32/pktctrl_fifo_ip_4kx32/pktctrl_fifo_ip_4kx32.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/pktctrl_fifo_ip_4kx32/pktctrl_fifo_ip_4kx32/pktctrl_fifo_ip_4kx32.xdc]
  read_xdc -mode out_of_context -ref ipcs_fifo_ip_512x64 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/ipcs_fifo_ip_512x64/ipcs_fifo_ip_512x64_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/ipcs_fifo_ip_512x64/ipcs_fifo_ip_512x64_ooc.xdc]
  read_xdc -ref ipcs_fifo_ip_512x64 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/ipcs_fifo_ip_512x64/ipcs_fifo_ip_512x64/ipcs_fifo_ip_512x64.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/ipcs_fifo_ip_512x64/ipcs_fifo_ip_512x64/ipcs_fifo_ip_512x64.xdc]
  read_xdc -mode out_of_context -ref fmac_rxfifo_ip_4Kx256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/fmac_rxfifo_ip_4Kx256/fmac_rxfifo_ip_4Kx256_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/fmac_rxfifo_ip_4Kx256/fmac_rxfifo_ip_4Kx256_ooc.xdc]
  read_xdc -ref fmac_rxfifo_ip_4Kx256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/fmac_rxfifo_ip_4Kx256/fmac_rxfifo_ip_4Kx256/fmac_rxfifo_ip_4Kx256.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/fmac_rxfifo_ip_4Kx256/fmac_rxfifo_ip_4Kx256/fmac_rxfifo_ip_4Kx256.xdc]
  read_xdc -mode out_of_context -ref txfifo_ip_1024x256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/txfifo_ip_1024x256/txfifo_ip_1024x256_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/txfifo_ip_1024x256/txfifo_ip_1024x256_ooc.xdc]
  read_xdc -ref txfifo_ip_1024x256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/txfifo_ip_1024x256/txfifo_ip_1024x256/txfifo_ip_1024x256.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/txfifo_ip_1024x256/txfifo_ip_1024x256/txfifo_ip_1024x256.xdc]
  read_xdc -mode out_of_context -ref x2c_bcnt_fifo_ip_256x32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_bcnt_fifo_ip_256x32/x2c_bcnt_fifo_ip_256x32_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_bcnt_fifo_ip_256x32/x2c_bcnt_fifo_ip_256x32_ooc.xdc]
  read_xdc -ref x2c_bcnt_fifo_ip_256x32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_bcnt_fifo_ip_256x32/x2c_bcnt_fifo_ip_256x32/x2c_bcnt_fifo_ip_256x32.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_bcnt_fifo_ip_256x32/x2c_bcnt_fifo_ip_256x32/x2c_bcnt_fifo_ip_256x32.xdc]
  read_xdc -mode out_of_context -ref x2c_ctrl_fifo_ip_1024x32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_ctrl_fifo_ip_1024x32/x2c_ctrl_fifo_ip_1024x32_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_ctrl_fifo_ip_1024x32/x2c_ctrl_fifo_ip_1024x32_ooc.xdc]
  read_xdc -ref x2c_ctrl_fifo_ip_1024x32 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_ctrl_fifo_ip_1024x32/x2c_ctrl_fifo_ip_1024x32/x2c_ctrl_fifo_ip_1024x32.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_ctrl_fifo_ip_1024x32/x2c_ctrl_fifo_ip_1024x32/x2c_ctrl_fifo_ip_1024x32.xdc]
  read_xdc -mode out_of_context -ref x2c_data_fifo_ip_1024x256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256_ooc.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256_ooc.xdc]
  read_xdc -ref x2c_data_fifo_ip_1024x256 -cells U0 c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256.xdc
  set_property processing_order EARLY [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/vivado/runs/LMAC3-vc7-9-2015-4.srcs/sources_1/ip/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256/x2c_data_fifo_ip_1024x256.xdc]
  read_xdc C:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/constraints/v7_LMAC3_base.xdc
  read_xdc C:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/constraints/v7_LMAC3_bit_rev1_0.xdc
  read_xdc C:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/constraints/v7_LMAC3_xgemac_xphy.xdc
  read_xdc -ref ten_gig_eth_pcs_pma_ip_shared_logic_in_core -cells inst c:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_clocks.xdc
  set_property processing_order LATE [get_files c:/SUNNY2/LMAC3-vc709-2015-4/hardware/sources/ip_catalog/ten_gig_eth_pcs_pma_ip_shared_logic_in_core/synth/ten_gig_eth_pcs_pma_ip_shared_logic_in_core_clocks.xdc]
  link_design -top LMAC3_vc709_2015_4 -part xc7vx690tffg1761-2
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design -directive Explore
  write_checkpoint -force LMAC3_vc709_2015_4_opt.dcp
  report_drc -file LMAC3_vc709_2015_4_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file LMAC3_vc709_2015_4.hwdef}
  place_design -directive Explore
  write_checkpoint -force LMAC3_vc709_2015_4_placed.dcp
  report_io -file LMAC3_vc709_2015_4_io_placed.rpt
  report_utilization -file LMAC3_vc709_2015_4_utilization_placed.rpt -pb LMAC3_vc709_2015_4_utilization_placed.pb
  report_control_sets -verbose -file LMAC3_vc709_2015_4_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step phys_opt_design
set rc [catch {
  create_msg_db phys_opt_design.pb
  phys_opt_design -directive Explore
  write_checkpoint -force LMAC3_vc709_2015_4_physopt.dcp
  close_msg_db -file phys_opt_design.pb
} RESULT]
if {$rc} {
  step_failed phys_opt_design
  return -code error $RESULT
} else {
  end_step phys_opt_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design -directive Explore
  write_checkpoint -force LMAC3_vc709_2015_4_routed.dcp
  report_drc -file LMAC3_vc709_2015_4_drc_routed.rpt -pb LMAC3_vc709_2015_4_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file LMAC3_vc709_2015_4_timing_summary_routed.rpt -rpx LMAC3_vc709_2015_4_timing_summary_routed.rpx
  report_power -file LMAC3_vc709_2015_4_power_routed.rpt -pb LMAC3_vc709_2015_4_power_summary_routed.pb
  report_route_status -file LMAC3_vc709_2015_4_route_status.rpt -pb LMAC3_vc709_2015_4_route_status.pb
  report_clock_utilization -file LMAC3_vc709_2015_4_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

