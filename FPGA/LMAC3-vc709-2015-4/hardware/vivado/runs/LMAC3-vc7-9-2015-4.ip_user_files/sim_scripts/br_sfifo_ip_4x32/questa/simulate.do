onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib br_sfifo_ip_4x32_opt

do {wave.do}

view wave
view structure
view signals

do {br_sfifo_ip_4x32.udo}

run -all

quit -force
