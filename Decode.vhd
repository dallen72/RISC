library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity decoder is
  port (
    instruction : in std_logic_vector(15 downto 0);
    reg_wr_addr_sel : out std_logic;
    mem_addr_sel : out std_logic_vector(1 downto 0);
    opcode : out std_logic_vector(7 downto 0); -- ALU select
    instr_lower_bits : out std_logic_vector(7 downto 0);
    is_branch_instruction : out std_logic;  -- tells if the opcode is a branch istruction
    reg_file_wr_sel : out std_logic
  );
end decoder;

architecture behav of decoder is
begin
  
  decode : process(instruction)
  variable var_opcode : std_logic_vector(7 downto 0);
  begin

    var_opcode := instruction(15 downto 8);


    if ( (var_opcode(7 downto 4) = "1010") or (var_opcode(7 downto 4) = "1000") ) then -- LD Register, LD Indirect
      reg_wr_addr_sel <= '1';
    else
      reg_wr_addr_sel <= '0';
    end if;


    if (var_opcode(7 downto 4) = "1000") then -- LD Indirect
      mem_addr_sel <= "01"; -- set to Y
    elsif ( (var_opcode(7 downto 4) = "1010") or (var_opcode(7 downto 4) = "1011") ) then -- LD Register, STR Register
      mem_addr_sel <= "10"; -- set to lower 8 bits of instruction
    else
      mem_addr_sel <= "00";
    end if;

    if (var_opcode = "01011000") then -- MOV Instruction
      reg_file_wr_sel <= '1'; -- set to write to R[y]
    else
      reg_file_wr_sel <= '0'; -- set to write to R[x]
    end if;
    
    if (var_opcode(7 downto 6) = "11") then
      is_branch_instruction <= '1';
    else
      is_branch_instruction <= '0';
    end if;

    opcode <= var_opcode;
    instr_lower_bits <= instruction(7 downto 0);

  end process;
  
end behav;

