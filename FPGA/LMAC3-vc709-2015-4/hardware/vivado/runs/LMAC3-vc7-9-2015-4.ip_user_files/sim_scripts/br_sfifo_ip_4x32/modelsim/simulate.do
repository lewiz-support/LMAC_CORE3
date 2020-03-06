onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L secureip -L fifo_generator_v13_0_1 -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.br_sfifo_ip_4x32

do {wave.do}

view wave
view structure
view signals

do {br_sfifo_ip_4x32.udo}

run -all

quit -force
