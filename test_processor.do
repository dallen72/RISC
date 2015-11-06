vsim work.risc_processor(structural)
add wave -position insertpoint sim:/risc_processor/*
force -freeze sim:/risc_processor/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/risc_processor/rst 1 0
run
run
force -freeze sim:/risc_processor/rst 0 0
run
