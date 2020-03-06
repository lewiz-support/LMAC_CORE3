onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ten_gig_eth_pcs_pma_ip_shared_logic_in_core_opt

do {wave.do}

view wave
view structure
view signals

do {ten_gig_eth_pcs_pma_ip_shared_logic_in_core.udo}

run -all

quit -force
