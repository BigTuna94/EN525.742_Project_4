onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+fir_compiler_1 -L xil_defaultlib -L xpm -L xbip_utils_v3_0_8 -L axi_utils_v2_0_4 -L fir_compiler_v7_2_10 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fir_compiler_1 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {fir_compiler_1.udo}

run -all

endsim

quit -force
