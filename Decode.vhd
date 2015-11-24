library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity decoder is
  port (
    rst : in std_logic;
    clk : in std_logic;
    instruction_in : in std_logic_vector(15 downto 0); -- comes in from fetch pipeline
    Rx : out std_logic_vector(3 downto 0);
    Ry : out std_logic_vector(3 downto 0);
    mem_wr_en : out std_logic; -- goes out to execute
    mem_addr_sel : out std_logic_vector(1 downto 0); -- goes out to execute
    reg_file_Din_sel : out std_logic; -- goes out to execute.Determines if An arithmetic instruction or Load instruction
    jmp_en : out std_logic; -- goes out to execute
    reg_file_wr_en : out std_logic -- goes out to execute
  );
end decoder;

architecture behav of decoder is
signal instruction : std_logic_vector(15 downto 0);
begin
  
  sync : process(clk)
  begin
    if (rising_edge(clk)) then
      instruction <= instruction_in;
    end if;
  end process;
    
  decode : process(instruction)
  begin

    if ( ((instruction(15 downto 14) = "00") and (not(instruction = "0000000000000000"))) or 
        (instruction(15 downto 12) = "0100") or
        (instruction(15 downto 12) = "0101") or 
        (instruction(15 downto 12) = "1000") or 
        (instruction(15 downto 12) = "1010") ) then
      reg_file_wr_en <= '1';
    else
      reg_file_wr_en <= '0';
    end if;
    

    if ( (instruction(15 downto 12) = "1010") or (instruction(15 downto 12) = "1000") ) then -- LD Register, LD Indirect
      reg_file_Din_sel <= '1';
    else
      reg_file_Din_sel <= '0';
    end if;


    if (instruction(15 downto 12) = "1000") then -- LD Indirect
      mem_addr_sel <= "01"; -- set to Y
    elsif ( (instruction(15 downto 12) = "1010") or (instruction(15 downto 12) = "1011") ) then -- LD Register, STR Register
      mem_addr_sel <= "10"; -- set to lower 8 bits of instruction
    else
       mem_addr_sel <= "00";
    end if;

    
    if ( (instruction(15 downto 12) = "1001") or (instruction(15 downto 12) = "1011") ) then -- store indirect and store register
      mem_wr_en <= '1';
    else
      mem_wr_en <= '0';
    end if;
    
    if (instruction(15 downto 12) = "1100") then
      jmp_en <= '1';
    else
      jmp_en <= '0';
    end if;
      
  --------------------------------------------------------    
      
    if ( (instruction(15 downto 12)="0001") -- If add immediate, Rx is in bits 11 - 8.
      or (instruction(15 downto 13) = "101") ) then -- load/store regs
      Rx <= instruction(11 downto 8);
      Ry <= instruction(3 downto 0);
    elsif ( (instruction(15 downto 13) = "001") -- Arithmetic
          or ( instruction(15 downto 13) = "010") -- Logicals
          or ( instruction(15 downto 13) = "100") ) then -- Indirects
      Rx <= instruction(7 downto 4);
      Ry <= instruction(3 downto 0);      
    end if;
    
------------------------------------------------------------    


  end process;
  
end behav;