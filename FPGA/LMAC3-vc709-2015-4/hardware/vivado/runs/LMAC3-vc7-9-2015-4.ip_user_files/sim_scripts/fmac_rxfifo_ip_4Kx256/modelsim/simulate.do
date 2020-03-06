onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L secureip -L fifo_generator_v13_0_1 -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.fmac_rxfifo_ip_4Kx256

do {wave.do}

view wave
view structure
view signals

do {fmac_rxfifo_ip_4Kx256.udo}

run -all

quit -force
