onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L unisims_ver -L unimacro_ver -L secureip -L ten_gig_eth_pcs_pma_v6_0_3 -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.ten_gig_eth_pcs_pma_ip_shared_logic_in_core xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ten_gig_eth_pcs_pma_ip_shared_logic_in_core.udo}

run -all

quit -force
