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
add wave -radix hex -position 14  sim:/risc_processor/execute_stage/alu_unit/instruction_in
add wave -radix hex -position 15  sim:/risc_processor/execute_stage/alu_unit/instruction_out
add wave -radix hex -position 11  sim:/risc_processor/execute_stage/alu_unit/output
add wave -radix hex -position insertpoint sim:/risc_processor/pipeline_in_three_ALU_out
add wave -radix hex -position end  sim:/risc_processor/pipeline_in_two_Rx
add wave -radix hex -position end  sim:/risc_processor/pipeline_in_three_Rx
add wave -radix hex -position 15  sim:/risc_processor/execute_stage/r_bank/Rx
add wave -radix unsigned -position end  sim:/risc_processor/execute_stage/r_bank/reg
add wave -radix hex -position 12  sim:/risc_processor/pipeline_out_three_ALU_out
add wave -radix hex -position 11  sim:/risc_processor/execute_stage/r_bank/X
add wave -position end  sim:/risc_processor/execute_stage/writeAdd
add wave -radix hex -position end  sim:/risc_processor/sig_reg_file_wr_addr
add wave -radix hex -position insertpoint  \
sim:/risc_processor/pipeline_in_two_mem_addr_sel
add wave -radix hex -position end  sim:/risc_processor/writeback_stage/reg_file_wr_addr
add wave -radix hex -position 19  sim:/risc_processor/writeback_stage/ALU_output
add wave -radix hex -position 19  sim:/risc_processor/writeback_stage/Rx
add wave -radix hex -position 20  sim:/risc_processor/writeback_stage/Ry
add wave -position 14  sim:/risc_processor/sig_reg_file_Din
add wave -position 16  sim:/risc_processor/execute_stage/sig_pulse_writeEnable
add wave -position end  sim:/risc_processor/pipeline_out_two_reg_file_wr_en
add wave -position end  sim:/risc_processor/pipeline_out_three_reg_file_wr_en
add wave -position 29  sim:/risc_processor/pipeline_in_three_reg_file_wr_en
add wave -position 28  sim:/risc_processor/pipeline_in_two_reg_file_wr_en
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
