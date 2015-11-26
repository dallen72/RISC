vsim work.risc_processor(structural)
add wave -position 0  sim:/risc_processor/rst
add wave -position 1  sim:/risc_processor/clk
add wave -position end  sim:/risc_processor/clk_stage
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_in_one_instruction
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_out_one_instruction
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_in_two_instruction
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_out_two_instruction
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_in_three_instruction
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_out_three_instruction
add wave -radix unsigned -position insertpoint  sim:/risc_processor/execute_stage/r_bank/reg(0)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/execute_stage/r_bank/reg(1)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/execute_stage/r_bank/reg(2)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/execute_stage/r_bank/reg(3)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/writeback_stage/mem1/sig_mem(0)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/writeback_stage/mem1/sig_mem(1)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/writeback_stage/mem1/sig_mem(2)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/writeback_stage/mem1/sig_mem(3)
add wave -radix unsigned -position insertpoint  sim:/risc_processor/writeback_stage/mem1/sig_mem(4)
add wave -position end  sim:/risc_processor/fetch_stage/rst
add wave -position end  sim:/risc_processor/fetch_stage/jump_enable
add wave -position end  sim:/risc_processor/fetch_stage/jump_address
add wave -position end  sim:/risc_processor/fetch_stage/clk
add wave -position end  sim:/risc_processor/fetch_stage/clk_stage
add wave -position end  sim:/risc_processor/fetch_stage/offset_enable
add wave -position end  sim:/risc_processor/fetch_stage/offset_value
add wave -position end  sim:/risc_processor/fetch_stage/out_instruction
add wave -position end  sim:/risc_processor/fetch_stage/counter
add wave -position end  sim:/risc_processor/fetch_stage/sig_bubble
add wave -position end  sim:/risc_processor/fetch_stage/sig_counter_reversed
add wave -position end  sim:/risc_processor/fetch_stage/sig_counter_reversed_bubble
add wave -position end  sim:/risc_processor/fetch_stage/sig_counter_reversed_no_bubble
add wave -position end  sim:/risc_processor/fetch_stage/sig_delay_bubble
add wave -position end  sim:/risc_processor/fetch_stage/instruction
add wave -position end  sim:/risc_processor/fetch_stage/instruction_shift_reg
add wave -position end  sim:/risc_processor/fetch_stage/instruction_Rx_shift_reg
add wave -position end  sim:/risc_processor/fetch_stage/bubble_counter
add wave -position end  sim:/risc_processor/fetch_stage/sig_bubble_lag



force -freeze sim:/risc_processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/risc_processor/clk_stage 1 0, 0 {200 ps} -r 400
run
force -freeze sim:/risc_processor/rst 1 0
run
run
run
run
force -freeze sim:/risc_processor/rst 0 0
run
run
run
run
run
run
run
run
run
run 50000 ps