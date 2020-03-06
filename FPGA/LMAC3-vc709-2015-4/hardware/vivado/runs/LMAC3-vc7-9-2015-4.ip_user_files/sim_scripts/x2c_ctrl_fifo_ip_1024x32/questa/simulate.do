onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib x2c_ctrl_fifo_ip_1024x32_opt

do {wave.do}

view wave
view structure
view signals

do {x2c_ctrl_fifo_ip_1024x32.udo}

run -all

quit -force
