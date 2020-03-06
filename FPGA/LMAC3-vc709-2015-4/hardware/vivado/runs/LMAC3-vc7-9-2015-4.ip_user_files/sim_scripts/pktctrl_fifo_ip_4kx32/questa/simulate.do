onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib pktctrl_fifo_ip_4kx32_opt

do {wave.do}

view wave
view structure
view signals

do {pktctrl_fifo_ip_4kx32.udo}

run -all

quit -force
