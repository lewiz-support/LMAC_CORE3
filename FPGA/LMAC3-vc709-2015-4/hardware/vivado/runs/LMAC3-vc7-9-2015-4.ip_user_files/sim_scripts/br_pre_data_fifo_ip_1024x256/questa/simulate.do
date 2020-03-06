onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib br_pre_data_fifo_ip_1024x256_opt

do {wave.do}

view wave
view structure
view signals

do {br_pre_data_fifo_ip_1024x256.udo}

run -all

quit -force
