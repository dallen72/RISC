
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity risc_processor is
  generic (ADDRESS_WIDTH : integer := 8; DATA_WIDTH : integer := 8);
  port (
    clk : in std_logic;
    rst : in std_logic
    -- add external interrupt input?
  );
end risc_processor;

architecture structural of risc_processor is

--  four stage pipeline (three pipelines)  
--  pipeline one comes from first stage (fetch), pipeline two from second stage (decode), pipeline three comes from execute
---------------------------------------------------------------------------------------------------------
  
  signal pipeline_in_one_instruction : std_logic_vector(15 downto 0) := (others => '0');
  
  signal pipeline_in_two_mem_addr_sel : std_logic_vector(1 downto 0) := (others => '0');
  signal pipeline_in_two_instruction : std_logic_vector(15 downto 0);
  signal pipeline_in_two_jump_en : std_logic;
  signal pipeline_in_two_mem_wr_en : std_logic;
  signal pipeline_in_two_reg_file_Din_sel : std_logic;
  signal pipeline_in_two_reg_file_wr_en : std_logic;
  signal pipeline_in_two_reg_wr_addr_sel : std_logic;
  
  signal pipeline_in_three_instruction : std_logic_vector(15 downto 0);
  signal pipeline_in_three_mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal pipeline_in_three_ALU_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pipeline_in_three_jump_en : std_logic;
  signal pipeline_in_three_offset_en : std_logic;
  signal pipeline_in_three_mem_wr_en : std_logic;
  signal pipeline_in_three_reg_file_Din_sel : std_logic;
  signal pipeline_in_three_reg_file_wr_en : std_logic;
  
--- in and out signals to simulate registers (in pipeline process)
  signal pipeline_out_one_instruction : std_logic_vector(15 downto 0);
  
  signal pipeline_out_two_mem_addr_sel : std_logic_vector(1 downto 0);
  signal pipeline_out_two_instruction : std_logic_vector(15 downto 0);
  signal pipeline_out_two_jump_en : std_logic;
  signal pipeline_out_two_mem_wr_en : std_logic;
  signal pipeline_out_two_reg_file_Din_sel : std_logic;
  signal pipeline_out_two_reg_file_wr_en : std_logic;
  signal pipeline_out_two_reg_wr_addr_sel : std_logic;
  
  signal sig_reg_wr_addr : std_logic_vector(3 downto 0);
  signal sig_reg_file_Din : std_logic_vector(7 downto 0);
  signal sig_reg_file_wr_en : std_logic;
  
  signal pipeline_out_three_instruction : std_logic_vector(15 downto 0);
  signal pipeline_out_three_mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal pipeline_out_three_ALU_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pipeline_out_three_jump_en : std_logic;
  signal pipeline_out_three_offset_en : std_logic;
  signal pipeline_out_three_mem_wr_en : std_logic;
  signal pipeline_out_three_reg_file_Din_sel : std_logic;
  signal pipeline_out_three_reg_file_wr_en : std_logic;

---------------------------------------------------------------------------------------------------------

  signal sig_to_exec_reg_file_wr_address : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal sig_jump_en : std_logic;
  signal sig_jump_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0);


begin

  fetch_stage : entity work.fetch
    port map (
      rst => rst,
      jump_enable => sig_jump_en,
      jump_address => pipeline_out_three_instruction(7 downto 0),
      clk => clk,
      offset_enable => pipeline_out_three_offset_en,
      offset_value => pipeline_out_three_instruction(7 downto 0),
      instruction => pipeline_in_one_instruction
      );
      
  decode_stage : entity work.decoder
    port map (
      rst => rst,
      instruction => pipeline_out_one_instruction,
      mem_wr_en => pipeline_in_two_mem_wr_en,
      mem_addr_sel => pipeline_in_two_mem_addr_sel,
      reg_file_Din_sel => pipeline_in_two_reg_file_Din_sel,
      jmp_en => pipeline_in_two_jump_en,
      reg_file_wr_en => pipeline_in_two_reg_file_wr_en
      );
      
  execute_stage : entity work.execute
    port map (
        instruction_in => pipeline_out_two_instruction,
        clk => clk,
        writeEnable => sig_reg_file_wr_en,
        ALU_output => pipeline_in_three_ALU_out,
        writeback => sig_reg_file_Din,
        writeAdd => sig_reg_wr_addr
      );
      
  writeback_stage : entity work.writeback
    port map (
      rst => rst,
      clk => clk,
      mem_addr => pipeline_out_three_mem_addr, -- from execute
      ALU_output => pipeline_out_three_ALU_out, -- from execute
      mem_wr_en => pipeline_out_two_mem_wr_en, -- comes from decode, through execute to writeback
      reg_file_Din_sel => pipeline_out_three_reg_file_Din_sel, -- comes from decode, through execute to writeback
      reg_file_wr_addr => sig_reg_wr_addr, -- determined in the writeback from reg_file_Din_sel
  
      reg_file_Din => sig_reg_file_Din
      );


  PIPELINE : process (clk)
  begin
    if (clk'event and clk = '1') then
      
      pipeline_out_one_instruction <= pipeline_in_one_instruction;
      
      pipeline_in_two_instruction <= pipeline_out_one_instruction;
  
      pipeline_out_two_mem_addr_sel <= pipeline_in_two_mem_addr_sel;
      pipeline_out_two_instruction <= pipeline_in_two_instruction;
      pipeline_out_two_jump_en <= pipeline_in_two_jump_en;
      pipeline_out_two_mem_wr_en <= pipeline_in_two_mem_wr_en;
      pipeline_out_two_reg_file_Din_sel <= pipeline_in_two_reg_file_Din_sel;
      pipeline_out_two_reg_file_wr_en <= pipeline_in_two_reg_file_wr_en;
      pipeline_out_two_reg_wr_addr_sel <= pipeline_in_two_reg_wr_addr_sel;
  
      pipeline_in_three_reg_file_wr_en <= pipeline_out_two_reg_file_wr_en;
      pipeline_in_three_instruction <= pipeline_out_two_instruction;
  
      pipeline_out_three_instruction <= pipeline_in_three_instruction;
      pipeline_out_three_mem_addr <= pipeline_in_three_mem_addr;
      pipeline_out_three_ALU_out <= pipeline_in_three_ALU_out;
      pipeline_out_three_jump_en <= pipeline_in_three_jump_en;
      pipeline_out_three_offset_en <= pipeline_in_three_offset_en;
      pipeline_out_three_mem_wr_en <= pipeline_in_three_mem_wr_en;
      pipeline_out_three_reg_file_Din_sel <= pipeline_in_three_reg_file_Din_sel;
      pipeline_out_three_reg_file_wr_en <= pipeline_in_three_reg_file_wr_en; -- goes back to execute stage
      
    end if;
  end process;
  
 
end structural;
