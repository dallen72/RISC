library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity decoder is
  port (
    rst : in std_logic;
    instruction : in std_logic_vector(15 downto 0); -- comes in from fetch pipeline
    mem_wr_en : out std_logic; -- goes out to execute
    mem_addr_sel : out std_logic_vector(1 downto 0); -- goes out to execute
    reg_file_Din_sel : out std_logic; -- goes out to execute.Determines if An arithmetic instruction or Load instruction
    jmp_en : out std_logic; -- goes out to execute
    reg_file_wr_en : out std_logic -- goes out to execute
  );
end decoder;

architecture behav of decoder is
begin
  
  decode : process(instruction)
  variable var_opcode : std_logic_vector(7 downto 0);
  begin

    var_opcode := instruction(15 downto 8);


    if ( (var_opcode(7 downto 6) = "00") or (var_opcode (7 downto 4) = "0101") or (var_opcode(7 downto 4) = "1000") or (var_opcode(7 downto 4) = "1010") ) then
      reg_file_wr_en <= '1';
    else
      reg_file_wr_en <= '0';
    end if;
    

    if ( (var_opcode(7 downto 4) = "1010") or (var_opcode(7 downto 4) = "1000") ) then -- LD Register, LD Indirect
      reg_file_Din_sel <= '1';
    else
      reg_file_Din_sel <= '0';
    end if;


    if (var_opcode(7 downto 4) = "1000") then -- LD Indirect
      mem_addr_sel <= "01"; -- set to Y
    elsif ( (var_opcode(7 downto 4) = "1010") or (var_opcode(7 downto 4) = "1011") ) then -- LD Register, STR Register
      mem_addr_sel <= "10"; -- set to lower 8 bits of instruction
    else
       mem_addr_sel <= "00";
    end if;

 --   if (var_opcode = "01011000") then -- MOV Instruction
 --     reg_file_Din_sel <= '1'; -- set to write to R[y]
--    else
--      reg_file_Din_sel <= '0'; -- set to write to R[x]
--    end if;
    
    if ( (var_opcode(7 downto 4) = "1001") or (var_opcode(7 downto 4) = "1011") ) then -- store indirect and store register
      mem_wr_en <= '1';
    else
      mem_wr_en <= '0';
    end if;
    
    if (var_opcode(7 downto 4) = "1100") then
      jmp_en <= '1';
    else
      jmp_en <= '0';
    end if;


  end process;
  
end behav;
