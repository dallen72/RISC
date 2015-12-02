
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity risc_processor is
  generic (ADDRESS_WIDTH : integer := 8; DATA_WIDTH : integer := 8);
  port (
    clk : in std_logic;
    clk_stage : in std_logic; -- period must be four times clk
    rst : in std_logic;
    intrpt : in std_logic
  );
end risc_processor;

architecture structural of risc_processor is

--  four stage pipeline (three pipelines)  
--  pipeline one comes from first stage (fetch), pipeline two from second stage (decode), pipeline three comes from execute
---------------------------------------------------------------------------------------------------------
  
  
  signal pipeline_in_one_instruction : std_logic_vector(15 downto 0) := (others => '0');
  
  signal pipeline_in_two_Rx : std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);  
  signal pipeline_in_two_Ry : std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);         
  signal pipeline_in_two_mem_addr_sel : std_logic_vector(1 downto 0) := (others => '0');
  signal pipeline_in_two_instruction : std_logic_vector(15 downto 0);
  signal pipeline_in_two_jump_en : std_logic;
  signal pipeline_in_two_mem_wr_en : std_logic;
  signal pipeline_in_two_reg_file_Din_sel : std_logic;
  signal pipeline_in_two_reg_file_wr_en : std_logic;
  signal pipeline_in_two_reg_wr_addr_sel : std_logic;
  signal pipeline_in_two_mem_rd_en : std_logic;
 
  
  signal pipeline_in_three_Rx : std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);      
  signal pipeline_in_three_Ry : std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);    
  signal pipeline_in_three_instruction : std_logic_vector(15 downto 0);
  signal pipeline_in_three_mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal pipeline_in_three_ALU_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pipeline_in_three_jump_en : std_logic;
  signal pipeline_in_three_offset_en : std_logic;
  signal pipeline_in_three_mem_wr_en : std_logic;
  signal pipeline_in_three_reg_file_Din_sel : std_logic;
  signal pipeline_in_three_reg_file_wr_en : std_logic;
  signal pipeline_in_three_X : std_logic_vector(7 downto 0);
  signal pipeline_in_three_Y : std_logic_vector(7 downto 0);  
  signal pipeline_in_three_reg_file_wr_addr : std_logic_vector(3 downto 0);  
  signal pipeline_in_three_mem_rd_en : std_logic;  
  
--- in and out signals to simulate registers (in pipeline process)
  signal pipeline_out_one_instruction : std_logic_vector(15 downto 0);
  
  signal pipeline_out_two_Rx : std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);      
  signal pipeline_out_two_Ry : std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);  
  signal pipeline_out_two_mem_addr_sel : std_logic_vector(1 downto 0);
  signal pipeline_out_two_instruction : std_logic_vector(15 downto 0);
  signal pipeline_out_two_jump_en : std_logic;
  signal pipeline_out_two_mem_wr_en : std_logic;
  signal pipeline_out_two_reg_file_Din_sel : std_logic;
  signal pipeline_out_two_reg_file_wr_en : std_logic;
  signal pipeline_out_two_reg_wr_addr_sel : std_logic;
  signal pipeline_out_two_mem_rd_en : std_logic;  
  
  signal sig_reg_file_Din : std_logic_vector(7 downto 0);
  signal sig_reg_file_wr_en : std_logic;
  signal sig_reg_file_wr_addr : std_logic_vector(3 downto 0);

  signal pipeline_out_three_Rx :  std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);      
  signal pipeline_out_three_Ry :  std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);  
  signal pipeline_out_three_instruction : std_logic_vector(15 downto 0);
  signal pipeline_out_three_mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal pipeline_out_three_ALU_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pipeline_out_three_jump_en : std_logic;
  signal pipeline_out_three_offset_en : std_logic;
  signal pipeline_out_three_mem_wr_en : std_logic;
  signal pipeline_out_three_reg_file_Din_sel : std_logic;
  signal pipeline_out_three_reg_file_wr_en : std_logic;
  signal pipeline_out_three_reg_file_wr_addr : std_logic_vector(3 downto 0);
  signal pipeline_out_three_X : std_logic_vector(7 downto 0);
  signal pipeline_out_three_Y : std_logic_vector(7 downto 0);
  signal pipeline_out_three_mem_rd_en : std_logic;    

---------------------------------------------------------------------------------------------------------

  signal sig_to_exec_reg_file_wr_address : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal sig_branch_en : std_logic;
  signal sig_ALU_out : std_logic_vector(7 downto 0) := (others => '0');
  
  -- interrupt signals
  signal sig_intrpt_Din : std_logic_vector(7 downto 0);
  -- to/from execute
  signal sig_intrpt_output_en : std_logic;
  signal sig_intrpt_wr_reg : std_logic;    
  signal sig_intrpt_Dout : std_logic_vector(7 downto 0);
  signal sig_intrpt_reg_addr : std_logic_vector(3 downto 0);
    
  -- from fetch 
  signal sig_intrpt_RetI : std_logic;    
  signal sig_intrpt_in_ret_addr : std_logic_vector(7 downto 0);    
  signal sig_intrpt_en_intrpt : std_logic_vector(3 downto 0);    
  -- to fetch        
  signal sig_intrpt_store_addr : std_logic;
  signal sig_intrpt_out_jump_addr : std_logic_vector(7 downto 0);
  signal sig_intrpt_pc_cont_counting : std_logic;

begin

  interrupt_handler : entity work.interrupt_handler
  port map (
    rst => rst,
    clk => clk,
    intrpt => intrpt,
    
    -- from execute
    Din => sig_intrpt_Din,
    -- to execute
    output_en_intrpt_handler => sig_intrpt_output_en,
    wr_reg => sig_intrpt_wr_reg,    
    Dout => sig_intrpt_Dout,
    reg_addr => sig_intrpt_reg_addr,
    
    -- from fetch
    in_RetI => sig_intrpt_RetI,    
    in_ret_addr => sig_intrpt_in_ret_addr,    
    en_intrpt => sig_intrpt_en_intrpt,    
    -- to fetch        
    store_addr => sig_intrpt_store_addr,
    out_jump_addr => sig_intrpt_out_jump_addr,
    pc_cont_counting => sig_intrpt_pc_cont_counting
  );

  fetch_stage : entity work.fetch
    port map (
      rst => rst,
      intrpt => intrpt,
      branch_en => sig_branch_en,
      branch_addr => pipeline_out_three_instruction(7 downto 0),
      clk => clk,
      clk_stage => clk_stage,
      offset_enable => pipeline_out_three_offset_en,
      offset_value => pipeline_out_three_instruction(7 downto 0),
      out_instruction => pipeline_in_one_instruction,
      en_intrpts => sig_intrpt_en_intrpt,
      intrpt_in_ret_addr => sig_intrpt_in_ret_addr,
      intrpt_pc_cont_counting => sig_intrpt_pc_cont_counting,
      intrpt_out_jump_addr => sig_intrpt_out_jump_addr,
      intrpt_store_addr => sig_intrpt_store_addr,
      RetI => sig_intrpt_RetI
      );
      
  decode_stage : entity work.decoder
    port map (
      rst => rst,
      clk => clk_stage,
      instruction_in => pipeline_out_one_instruction,
      Rx => pipeline_in_two_Rx,
      Ry => pipeline_in_two_Ry,
      mem_wr_en => pipeline_in_two_mem_wr_en,
      mem_addr_sel => pipeline_in_two_mem_addr_sel,
      reg_file_Din_sel => pipeline_in_two_reg_file_Din_sel,
      jmp_en => pipeline_in_two_jump_en,
      reg_file_wr_en => pipeline_in_two_reg_file_wr_en,
      mem_rd_en => pipeline_in_two_mem_rd_en
      );
      
  execute_stage : entity work.execute
    port map (
        rst => rst,
        instruction_in => pipeline_out_two_instruction,
        clk => clk,
        clk_stage => clk_stage,
        Rx => pipeline_out_two_Rx,
        Ry => pipeline_out_two_Ry,
        mem_addr_sel => pipeline_out_two_mem_addr_sel,
        writeback => sig_reg_file_Din,
        writeEnable => pipeline_out_three_reg_file_wr_en,
        writeAdd => sig_reg_file_wr_addr,  
        output => sig_ALU_out,
        mem_addr => pipeline_in_three_mem_addr,
        X => pipeline_in_three_X,
        Y => pipeline_in_three_Y,
        
        intrpt_output_en => sig_intrpt_output_en,
        intrpt_wr_reg => sig_intrpt_wr_reg,   
        intrpt_Dout => sig_intrpt_Dout,
        intrpt_reg_addr => sig_intrpt_reg_addr,
        intrpt_Din => sig_intrpt_Din
      );
      
  writeback_stage : entity work.writeback
    port map (
      rst => rst,
      clk => clk,
      clk_stage => clk_stage,
      opcode => pipeline_out_three_instruction(15 downto 8),
      Rx => pipeline_out_three_Rx,
      Ry => pipeline_out_three_Ry,  
      X => pipeline_out_three_X,
      Y => pipeline_out_three_Y,    
      mem_addr => pipeline_out_three_mem_addr, -- from execute
      mem_rd_en => pipeline_out_three_mem_rd_en,
      ALU_output => pipeline_out_three_ALU_out, -- from execute
      mem_wr_en => pipeline_out_three_mem_wr_en, -- comes from decode, through execute to writeback
      reg_file_Din_sel => pipeline_out_three_reg_file_Din_sel, -- comes from decode, through execute to writeback
      reg_file_Din => sig_reg_file_Din,
      reg_file_wr_addr => sig_reg_file_wr_addr,
      branch_en => sig_branch_en
      );


  

  PIPELINE : process (clk_stage)
  begin
    if (clk_stage'event and clk_stage = '1') then
      
      if (rst = '1') then
        
        pipeline_out_one_instruction <= (others => '0');
      
        pipeline_in_two_instruction <=  (others => '0');
  
        pipeline_out_two_mem_addr_sel <=  (others => '0');
        pipeline_out_two_instruction <=  (others => '0');
        pipeline_out_two_jump_en <= '0';
        pipeline_out_two_mem_wr_en <= '0';
        pipeline_out_two_reg_file_Din_sel <= '0';
        pipeline_out_two_reg_file_wr_en <= '0';
        pipeline_out_two_reg_wr_addr_sel <= '0';      
  
        pipeline_in_three_reg_file_wr_en <= '0';
        pipeline_in_three_instruction <=  (others => '0');
        pipeline_in_three_offset_en <= '0';
        pipeline_in_three_reg_file_wr_addr <= (others => '0');
        pipeline_in_three_reg_file_Din_sel <= '0';
  
        pipeline_out_three_instruction <=  (others => '0');
        pipeline_out_three_mem_addr <=  (others => '0');
        pipeline_out_three_ALU_out <=  (others => '0');
        pipeline_out_three_jump_en <= '0';
        pipeline_out_three_offset_en <=  '0';
        pipeline_out_three_mem_wr_en <=  '0';
        pipeline_out_three_reg_file_Din_sel <= '0';
        pipeline_out_three_reg_file_wr_addr <= (others => '0');
        pipeline_out_three_Rx <= (others => '0');
        pipeline_out_three_Ry <= (others => '0');    
        
        pipeline_in_three_ALU_out <= (others => '0');
        
      else
        pipeline_out_one_instruction <= pipeline_in_one_instruction;
      
        pipeline_in_two_instruction <= pipeline_out_one_instruction;        

        pipeline_out_two_Rx <= pipeline_in_two_Rx;   
        pipeline_out_two_Ry <= pipeline_in_two_Ry;     
        pipeline_out_two_mem_addr_sel <= pipeline_in_two_mem_addr_sel;
        pipeline_out_two_instruction <= pipeline_in_two_instruction;
        pipeline_out_two_jump_en <= pipeline_in_two_jump_en;
        pipeline_out_two_mem_wr_en <= pipeline_in_two_mem_wr_en;
        pipeline_out_two_reg_file_Din_sel <= pipeline_in_two_reg_file_Din_sel;
        pipeline_out_two_reg_file_wr_en <= pipeline_in_two_reg_file_wr_en;
        pipeline_out_two_reg_wr_addr_sel <= pipeline_in_two_reg_wr_addr_sel;
        pipeline_out_two_mem_rd_en <= pipeline_in_two_mem_rd_en;            
  
        pipeline_in_three_mem_wr_en <= pipeline_out_two_mem_wr_en;
        pipeline_in_three_Rx <= pipeline_out_two_Rx;    
        pipeline_in_three_Ry <= pipeline_out_two_Ry;   
        pipeline_in_three_reg_file_Din_sel <= pipeline_out_two_reg_file_Din_sel;
        pipeline_in_three_instruction <= pipeline_out_two_instruction;
        pipeline_in_three_reg_file_wr_en <= pipeline_out_two_reg_file_wr_en;
        pipeline_in_three_ALU_out <= sig_ALU_out;
        pipeline_in_three_mem_rd_en <= pipeline_out_two_mem_rd_en;
  
        pipeline_out_three_Rx <= pipeline_in_three_Rx;      
        pipeline_out_three_Ry <= pipeline_in_three_Ry;    
        pipeline_out_three_instruction <= pipeline_in_three_instruction;
        pipeline_out_three_mem_addr <= pipeline_in_three_mem_addr;
        pipeline_out_three_ALU_out <= pipeline_in_three_ALU_out;
        pipeline_out_three_jump_en <= pipeline_in_three_jump_en;
        pipeline_out_three_offset_en <= pipeline_in_three_offset_en;
        pipeline_out_three_mem_wr_en <= pipeline_in_three_mem_wr_en;
        pipeline_out_three_reg_file_Din_sel <= pipeline_in_three_reg_file_Din_sel;
        pipeline_out_three_reg_file_wr_en <= pipeline_in_three_reg_file_wr_en; -- goes back to execute stage
        pipeline_out_three_X <= pipeline_in_three_X;
        pipeline_out_three_Y <= pipeline_in_three_Y; 
        pipeline_out_three_mem_rd_en <= pipeline_in_three_mem_rd_en;       
      end if;
    end if;

  end process;
  
 
end structural;

