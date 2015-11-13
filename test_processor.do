vsim work.risc_processor(structural)
add wave -position 0  sim:/risc_processor/rst
add wave -position 1  sim:/risc_processor/clk
add wave -position insertpoint sim:/risc_processor/pipeline_in_one_instruction
add wave -position insertpoint sim:/risc_processor/pipeline_out_one_instruction
add wave -position insertpoint sim:/risc_processor/pipeline_in_two_mem_addr_sel
add wave -position insertpoint sim:/risc_processor/pipeline_in_two_instruction
add wave -position insertpoint sim:/risc_processor/pipeline_in_two_mem_wr_en
add wave -position insertpoint sim:/risc_processor/pipeline_out_two_mem_wr_en
add wave -position insertpoint sim:/risc_processor/pipeline_out_two_instruction
add wave -position insertpoint sim:/risc_processor/pipeline_in_three_instruction
add wave -position insertpoint sim:/risc_processor/pipeline_in_three_mem_addr
add wave -position insertpoint sim:/risc_processor/pipeline_in_three_ALU_out
add wave -position insertpoint sim:/risc_processor/pipeline_in_three_offset_en
add wave -position insertpoint sim:/risc_processor/pipeline_in_three_reg_file_Din_sel
add wave -position insertpoint sim:/risc_processor/pipeline_out_three_instruction
add wave -position insertpoint sim:/risc_processor/pipeline_out_three_mem_addr
add wave -position insertpoint sim:/risc_processor/pipeline_out_three_ALU_out
add wave -position insertpoint sim:/risc_processor/pipeline_out_three_offset_en
add wave -position insertpoint sim:/risc_processor/pipeline_out_three_reg_file_Din_sel
add wave -position insertpoint sim:/risc_processor/sig_reg_file_Din
add wave -position insertpoint sim:/risc_processor/sig_jump_en
add wave -position end  sim:/risc_processor/execute_stage/r_bank/reg
add wave -position end  sim:/risc_processor/writeback_stage/mem1/sig_mem
add wave -position 12  sim:/risc_processor/execute_stage/alu_unit/Rx
add wave -position 13  sim:/risc_processor/execute_stage/alu_unit/Ry
add wave -position 14  sim:/risc_processor/execute_stage/alu_unit/instruction_in
add wave -position 15  sim:/risc_processor/execute_stage/alu_unit/instruction_out
add wave -position 16  sim:/risc_processor/execute_stage/alu_unit/output
add wave -position 17  sim:/risc_processor/execute_stage/alu_unit/reg_file_wr_addr
force -freeze sim:/risc_processor/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/risc_processor/rst 1 0
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
run
run