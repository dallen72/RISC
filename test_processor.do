vsim work.risc_processor(structural)
<<<<<<< HEAD
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
add wave -position insertpoint sim:/risc_processor/sig_reg_wr_addr
add wave -position insertpoint sim:/risc_processor/sig_reg_file_Din
add wave -position insertpoint sim:/risc_processor/sig_reg_file_wr_en
add wave -position insertpoint sim:/risc_processor/sig_jump_en
=======
add wave -position insertpoint sim:/risc_processor/*
>>>>>>> 433bdae731163f4d92e057a05cb3b6d7b31c8eaf
force -freeze sim:/risc_processor/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/risc_processor/rst 1 0
run
run
force -freeze sim:/risc_processor/rst 0 0
run
<<<<<<< HEAD
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
=======
>>>>>>> 433bdae731163f4d92e057a05cb3b6d7b31c8eaf
