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
add wave -radix unsigned -position 11  sim:/risc_processor/execute_stage/r_bank/reg(0)
add wave -radix unsigned -position 12  sim:/risc_processor/execute_stage/r_bank/reg(1)
add wave -radix unsigned -position 13  sim:/risc_processor/execute_stage/r_bank/reg(2)
add wave -radix unsigned -position 12  sim:/risc_processor/writeback_stage/mem1/sig_mem(0)
add wave -radix unsigned -position 13  sim:/risc_processor/writeback_stage/mem1/sig_mem(1)
add wave -radix unsigned -position 14  sim:/risc_processor/writeback_stage/mem1/sig_mem(2)
add wave -radix unsigned -position 15  sim:/risc_processor/writeback_stage/mem1/sig_mem(3)
add wave -position 24  sim:/risc_processor/execute_stage/sig_pulse_writeEnable
add wave -position 24  sim:/risc_processor/pipeline_in_three_reg_file_wr_en
add wave -position 12  sim:/risc_processor/writeback_stage/opcode
add wave -position 13  sim:/risc_processor/writeback_stage/mem_addr
add wave -position 14  sim:/risc_processor/writeback_stage/sig_mem_Dout
add wave -position 15  sim:/risc_processor/writeback_stage/reg_file_Din
add wave -position 16  sim:/risc_processor/writeback_stage/reg_file_wr_addr
add wave -position 13  sim:/risc_processor/execute_stage/mem_addr
add wave -position 13  sim:/risc_processor/execute_stage/mem_addr_sel
add wave -position 15  sim:/risc_processor/writeback_stage/mem1/ADDR
add wave -position 16  sim:/risc_processor/writeback_stage/mem1/DIN
add wave -position 17  sim:/risc_processor/writeback_stage/mem1/DOUT
add wave -position 9  sim:/risc_processor/execute_stage/sig_X
add wave -position 10  sim:/risc_processor/execute_stage/sig_Y
add wave -position 11  sim:/risc_processor/execute_stage/Rx
add wave -position 11  sim:/risc_processor/execute_stage/Ry
add wave -position 22  sim:/risc_processor/pipeline_out_three_mem_rd_en
add wave -position 22  sim:/risc_processor/pipeline_in_three_mem_rd_en
add wave -position 22  sim:/risc_processor/pipeline_out_two_mem_rd_en
add wave -position 22  sim:/risc_processor/pipeline_in_two_mem_rd_en
add wave -position 26  sim:/risc_processor/pipeline_out_three_ALU_out
add wave -position 31  sim:/risc_processor/writeback_stage/Rx
add wave -position 32  sim:/risc_processor/writeback_stage/X

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