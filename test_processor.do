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
add wave -radix unsigned -position end  sim:/risc_processor/execute_stage/r_bank/reg
add wave -position end  sim:/risc_processor/execute_stage/r_bank/X
add wave -position end  sim:/risc_processor/execute_stage/r_bank/Y
add wave -position end  sim:/risc_processor/execute_stage/r_bank/Rx
add wave -position end  sim:/risc_processor/execute_stage/r_bank/Ry
add wave -position end  sim:/risc_processor/execute_stage/alu_unit/output
add wave -position 12  sim:/risc_processor/execute_stage/Rx
add wave -position 13  sim:/risc_processor/execute_stage/Ry
add wave -position 9  sim:/risc_processor/decode_stage/Rx
add wave -position 10  sim:/risc_processor/decode_stage/Ry
add wave -position end  sim:/risc_processor/fetch_stage/rst
add wave -position end  sim:/risc_processor/fetch_stage/jump_enable
add wave -position end  sim:/risc_processor/fetch_stage/jump_address
add wave -position end  sim:/risc_processor/fetch_stage/clk
add wave -position end  sim:/risc_processor/fetch_stage/clk_stage
add wave -position end  sim:/risc_processor/fetch_stage/offset_enable
add wave -position end  sim:/risc_processor/fetch_stage/offset_value
add wave -radix hex -position end  sim:/risc_processor/fetch_stage/out_instruction
add wave -radix unsigned -position end  sim:/risc_processor/fetch_stage/counter
add wave -position end  sim:/risc_processor/fetch_stage/sig_bubble
add wave -radix hex -position end  sim:/risc_processor/fetch_stage/instruction
add wave -radix unsigned -position end  sim:/risc_processor/fetch_stage/bubble_counter
add wave -position 14  sim:/risc_processor/execute_stage/writeback
add wave -position 15  sim:/risc_processor/execute_stage/writeAdd
add wave -radix unsigned -position 16  sim:/risc_processor/execute_stage/output
add wave -position 17  sim:/risc_processor/execute_stage/sig_X
add wave -position 18  sim:/risc_processor/execute_stage/sig_Y
add wave -position 17  sim:/risc_processor/pipeline_in_two_reg_file_wr_en
add wave -position 18  sim:/risc_processor/pipeline_out_two_reg_file_wr_en
add wave -position 19  sim:/risc_processor/pipeline_in_three_reg_file_wr_en
add wave -position 20  sim:/risc_processor/pipeline_out_three_reg_file_wr_en
add wave -position 16  sim:/risc_processor/execute_stage/sig_pulse_writeEnable
add wave -radix unsigned -position 18  sim:/risc_processor/writeback_stage/reg_file_Din
add wave -radix unsigned -position 18  sim:/risc_processor/pipeline_in_three_ALU_out
add wave -radix unsigned -position 19  sim:/risc_processor/pipeline_out_three_ALU_out
add wave -radix hex -position 43  sim:/risc_processor/fetch_stage/instruction_shift_reg
add wave -radix hex -position 44  sim:/risc_processor/fetch_stage/instruction_Rx_shift_reg
add wave -position 42  sim:/risc_processor/fetch_stage/sig_delay_bubble
add wave -position 15  sim:/risc_processor/writeback_stage/reg_file_wr_addr
add wave -position 17  sim:/risc_processor/pipeline_out_three_reg_file_Din_sel
add wave -position 17  sim:/risc_processor/pipeline_in_three_reg_file_Din_sel
add wave -position 17  sim:/risc_processor/pipeline_out_two_reg_file_Din_sel
add wave -position 17  sim:/risc_processor/pipeline_in_two_reg_file_Din_sel
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
run 80000 ps