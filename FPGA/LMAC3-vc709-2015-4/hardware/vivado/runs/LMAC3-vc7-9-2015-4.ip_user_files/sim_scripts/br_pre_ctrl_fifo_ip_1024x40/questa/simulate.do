onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib br_pre_ctrl_fifo_ip_1024x40_opt

do {wave.do}

view wave
view structure
view signals

do {br_pre_ctrl_fifo_ip_1024x40.udo}

run -all

quit -force
