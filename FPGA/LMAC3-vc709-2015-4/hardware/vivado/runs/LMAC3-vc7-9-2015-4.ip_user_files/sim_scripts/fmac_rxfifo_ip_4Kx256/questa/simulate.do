onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fmac_rxfifo_ip_4Kx256_opt

do {wave.do}

view wave
view structure
view signals

do {fmac_rxfifo_ip_4Kx256.udo}

run -all

quit -force
