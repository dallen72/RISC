
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
entity instruction_memory is
port(
counter: in std_logic_vector(7 downto 0); --Counter value obtained from PC
instruction: out std_logic_vector(15 downto 0)); --Fetched Instruction
end instruction_memory;
architecture behavior of instruction_memory is
begin
instruction_fetch: process(counter)
begin
  
-- assumption: offset of branch instructions is in R[y]

  
if(counter = "00000000") then
instruction <= "0000000000000000";
elsif(counter = "00000001") then
instruction <= "0001000100001000";  -- ADD Immediate $r1 ($r1 = 8)
elsif(counter = "00000010") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00000011") then
instruction <= "0011000000100000";  -- Increment $r2 ($r2 = 1)
elsif(counter = "00000100") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00000101") then
instruction <= "0100000100010000";  -- Shift Right $r1 ($r1 = 4)
elsif(counter = "00000110") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00000111") then
instruction <= "0100000000100000";  -- Shift Left $r2 ($r2 = 2)
elsif(counter = "00001000") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00001001") then
instruction <= "0101000000010000";  -- Not $r1,$r1 ($r1 = 251)
elsif(counter = "00001010") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00001011") then
instruction <= "0101000100010001";  -- Nor $r1, $r1 ($r1 = 4)
elsif(counter = "00001100") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00001101") then
instruction <= "0101001000010010";  -- Nand $r1, $r2 ($r1 = 251)
elsif(counter = "00001110") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00001111") then
instruction <= "0011000100010000";  -- decrement $r1 ($r1 = 250)
elsif(counter = "00010000") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00010001") then
instruction <= "1101000100010000";  -- Branch if zero $r1, $r1 (no branch)
elsif(counter = "00010010") then
instruction <= "1110000000000001";  -- Branch if not zero $r0, $r1 (no branch)
elsif(counter = "00010011") then
instruction <= "0101011100010000";  -- Set $r1 ($r1 = 1)
elsif(counter = "00010100") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00010101") then
instruction <= "0101011000010000";  -- Clear $r1 ($r1 = 0)
elsif(counter = "00010110") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00010111") then
instruction <= "0101111100010010";  -- Set if less than $r1, $r2 ($r1 = 1)
elsif(counter = "00011000") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00011001") then
instruction <= "0101010100010010";  -- OR $r1, $r2 ($r1 = 3)
elsif(counter = "00011010") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00011011") then
instruction <= "0101010000010010";  -- And $r1, $r2 ($r1 = 2)
elsif(counter = "00011100") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00011101") then
instruction <= "0101001100010010";  -- Xor $r1, $r2 ($r1 = 0)
elsif(counter = "00011110") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00011111") then
instruction <= "0101100000100001";  -- Move $r1, $r2 ($r1 = $r2 = 2)
elsif(counter = "00100000") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00100001") then
instruction <= "0010000100010010";  -- Subtract $r1, $r2 ($r1 = 0)
elsif(counter = "00100010") then
instruction <= "1100000000110010";  -- jump to instruction 50
elsif(counter = "00100011") then
instruction <= "0000000000000000";
elsif(counter = "00100100") then
instruction <= "0000000000000000";
elsif(counter = "00100101") then
instruction <= "0000000000000000";
elsif(counter = "00100110") then
instruction <= "0000000000000000";
elsif(counter = "00100111") then
instruction <= "0000000000000000";
elsif(counter = "00101000") then
instruction <= "0000000000000000";
elsif(counter = "00101001") then
instruction <= "0000000000000000";
elsif(counter = "00101010") then
instruction <= "0000000000000000";
elsif(counter = "00101011") then
instruction <= "0000000000000000";
elsif(counter = "00101100") then
instruction <= "0000000000000000";
elsif(counter = "00101101") then
instruction <= "0000000000000000";
elsif(counter = "00101110") then
instruction <= "0000000000000000";
elsif(counter = "00101111") then
instruction <= "0000000000000000";
elsif(counter = "00110000") then
instruction <= "0000000000000000";
elsif(counter = "00110001") then
instruction <= "0000000000000000";
elsif(counter = "00110010") then
instruction <= "1011001000000001";  -- Store $r2, 1 (MEM[1] = 2)
elsif(counter = "00110011") then
instruction <= "1010000100000001";  -- Load $r1 ($r1 = 2)
elsif(counter = "00110100") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00110101") then
instruction <= "0010000000010010";  -- Add $r1, $r2 ($r1 = 4)
elsif(counter = "00110110") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00110111") then
instruction <= "1001000000010010";  -- Store Indirect $r1, $r2 (MEM[4] = 2)
elsif(counter = "00111000") then
instruction <= "1000000000110001";  -- Load Indirect $r3, $r1 ($r3 = 2)
elsif(counter = "00111001") then
instruction <= "0000000000000000";  -- no op
elsif(counter = "00111010") then
instruction <= "0000000000000000";
elsif(counter = "00111011") then
instruction <= "0000000000000000";
elsif(counter = "00111100") then
instruction <= "0000000000000000";
elsif(counter = "00111101") then
instruction <= "0000000000000000";
elsif(counter = "00111110") then
instruction <= "0000000000000000";
elsif(counter = "00111111") then
instruction <= "0000000000000000";
elsif(counter = "01000000") then
instruction <= "0000000000000000";
elsif(counter = "01000001") then
instruction <= "0000000000000000";
elsif(counter = "01000010") then
instruction <= "0000000000000000";
elsif(counter = "01000011") then
instruction <= "0000000000000000";
elsif(counter = "01000100") then
instruction <= "0000000000000000";
elsif(counter = "01000101") then
instruction <= "0000000000000000";
elsif(counter = "01000110") then
instruction <= "0000000000000000";
elsif(counter = "01000111") then
instruction <= "0000000000000000";
elsif(counter = "01001000") then
instruction <= "0000000000000000";
elsif(counter = "01001001") then
instruction <= "0000000000000000";
elsif(counter = "01001010") then
instruction <= "0000000000000000";
elsif(counter = "01001011") then
instruction <= "0000000000000000";
elsif(counter = "01001100") then
instruction <= "0000000000000000";
elsif(counter = "01001101") then
instruction <= "0000000000000000";
elsif(counter = "01001110") then
instruction <= "0000000000000000";
elsif(counter = "01001111") then
instruction <= "0000000000000000";
elsif(counter = "01010000") then
instruction <= "0000000000000000";
elsif(counter = "01010001") then
instruction <= "0000000000000000";
elsif(counter = "01010010") then
instruction <= "0000000000000000";
elsif(counter = "01010011") then
instruction <= "0000000000000000";
elsif(counter = "01010100") then
instruction <= "0000000000000000";
elsif(counter = "01010101") then
instruction <= "0000000000000000";
elsif(counter = "01010110") then
instruction <= "0000000000000000";
elsif(counter = "01010111") then
instruction <= "0000000000000000";
elsif(counter = "01011000") then
instruction <= "0000000000000000";
elsif(counter = "01011001") then
instruction <= "0000000000000000";
elsif(counter = "01011010") then
instruction <= "0000000000000000";
elsif(counter = "01011011") then
instruction <= "0000000000000000";
elsif(counter = "01011100") then
instruction <= "0000000000000000";
elsif(counter = "01011101") then
instruction <= "0000000000000000";
elsif(counter = "01011110") then
instruction <= "0000000000000000";
elsif(counter = "01011111") then
instruction <= "0000000000000000";
elsif(counter = "01100000") then
instruction <= "0000000000000000";
elsif(counter = "01100001") then
instruction <= "0000000000000000";
elsif(counter = "01100010") then
instruction <= "0000000000000000";
elsif(counter = "01100011") then
instruction <= "0000000000000000";
elsif(counter = "01100100") then
instruction <= "0000000000000000";
elsif(counter = "01100101") then
instruction <= "0000000000000000";
elsif(counter = "01100110") then
instruction <= "0000000000000000";
elsif(counter = "01100111") then
instruction <= "0000000000000000";
elsif(counter = "01101000") then
instruction <= "0000000000000000";
elsif(counter = "01101001") then
instruction <= "0000000000000000";
elsif(counter = "01101010") then
instruction <= "0000000000000000";
elsif(counter = "01101011") then
instruction <= "0000000000000000";
elsif(counter = "01101100") then
instruction <= "0000000000000000";
elsif(counter = "01101101") then
instruction <= "0000000000000000";
elsif(counter = "01101110") then
instruction <= "0000000000000000";
elsif(counter = "01101111") then
instruction <= "0000000000000000";
elsif(counter = "01110000") then
instruction <= "0000000000000000";
elsif(counter = "01110001") then
instruction <= "0000000000000000";
elsif(counter = "01110010") then
instruction <= "0000000000000000";
elsif(counter = "01110011") then
instruction <= "0000000000000000";
elsif(counter = "01110100") then
instruction <= "0000000000000000";
elsif(counter = "01110101") then
instruction <= "0000000000000000";
elsif(counter = "01110110") then
instruction <= "0000000000000000";
elsif(counter = "01110111") then
instruction <= "0000000000000000";
elsif(counter = "01111000") then
instruction <= "0000000000000000";
elsif(counter = "01111001") then
instruction <= "0000000000000000";
elsif(counter = "01111010") then
instruction <= "0000000000000000";
elsif(counter = "01111011") then
instruction <= "0000000000000000";
elsif(counter = "01111100") then
instruction <= "0000000000000000";
elsif(counter = "01111101") then
instruction <= "0000000000000000";
elsif(counter = "01111110") then
instruction <= "0000000000000000";
elsif(counter = "01111111") then
instruction <= "0000000000000000";
elsif(counter = "10000000") then
instruction <= "0000000000000000";
elsif(counter = "10000001") then
instruction <= "0000000000000000";
elsif(counter = "10000010") then
instruction <= "0000000000000000";
elsif(counter = "10000011") then
instruction <= "0000000000000000";
elsif(counter = "10000100") then
instruction <= "0000000000000000";
elsif(counter = "10000101") then
instruction <= "0000000000000000";
elsif(counter = "10000110") then
instruction <= "0000000000000000";
elsif(counter = "10000111") then
instruction <= "0000000000000000";
elsif(counter = "10001000") then
instruction <= "0000000000000000";
elsif(counter = "10001001") then
instruction <= "0000000000000000";
elsif(counter = "10001010") then
instruction <= "0000000000000000";
elsif(counter = "10001011") then
instruction <= "0000000000000000";
elsif(counter = "10001100") then
instruction <= "0000000000000000";
elsif(counter = "10001101") then
instruction <= "0000000000000000";
elsif(counter = "10001110") then
instruction <= "0000000000000000";
elsif(counter = "10001111") then
instruction <= "0000000000000000";
elsif(counter = "10010000") then
instruction <= "0000000000000000";
elsif(counter = "10010001") then
instruction <= "0000000000000000";
elsif(counter = "10010010") then
instruction <= "0000000000000000";
elsif(counter = "10010011") then
instruction <= "0000000000000000";
elsif(counter = "10010100") then
instruction <= "0000000000000000";
elsif(counter = "10010101") then
instruction <= "0000000000000000";
elsif(counter = "10010110") then
instruction <= "0000000000000000";
elsif(counter = "10010111") then
instruction <= "0000000000000000";
elsif(counter = "10011000") then
instruction <= "0000000000000000";
elsif(counter = "10011001") then
instruction <= "0000000000000000";
elsif(counter = "10011010") then
instruction <= "0000000000000000";
elsif(counter = "10011011") then
instruction <= "0000000000000000";
elsif(counter = "10011100") then
instruction <= "0000000000000000";
elsif(counter = "10011101") then
instruction <= "0000000000000000";
elsif(counter = "10011110") then
instruction <= "0000000000000000";
elsif(counter = "10011111") then
instruction <= "0000000000000000";
elsif(counter = "10100000") then
instruction <= "0000000000000000";
elsif(counter = "10100001") then
instruction <= "0000000000000000";
elsif(counter = "10100010") then
instruction <= "0000000000000000";
elsif(counter = "10100011") then
instruction <= "0000000000000000";
elsif(counter = "10100100") then
instruction <= "0000000000000000";
elsif(counter = "10100101") then
instruction <= "0000000000000000";
elsif(counter = "10100110") then
instruction <= "0000000000000000";
elsif(counter = "10100111") then
instruction <= "0000000000000000";
elsif(counter = "10101000") then
instruction <= "0000000000000000";
elsif(counter = "10101001") then
instruction <= "0000000000000000";
elsif(counter = "10101010") then
instruction <= "0000000000000000";
elsif(counter = "10101011") then
instruction <= "0000000000000000";
elsif(counter = "10101100") then
instruction <= "0000000000000000";
elsif(counter = "10101101") then
instruction <= "0000000000000000";
elsif(counter = "10101110") then
instruction <= "0000000000000000";
elsif(counter = "10101111") then
instruction <= "0000000000000000";
elsif(counter = "10110000") then
instruction <= "0000000000000000";
elsif(counter = "10110001") then
instruction <= "0000000000000000";
elsif(counter = "10110010") then
instruction <= "0000000000000000";
elsif(counter = "10110011") then
instruction <= "0000000000000000";
elsif(counter = "10110100") then
instruction <= "0000000000000000";
elsif(counter = "10110101") then
instruction <= "0000000000000000";
elsif(counter = "10110110") then
instruction <= "0000000000000000";
elsif(counter = "10110111") then
instruction <= "0000000000000000";
elsif(counter = "10111000") then
instruction <= "0000000000000000";
elsif(counter = "10111001") then
instruction <= "0000000000000000";
elsif(counter = "10111010") then
instruction <= "0000000000000000";
elsif(counter = "10111011") then
instruction <= "0000000000000000";
elsif(counter = "10111100") then
instruction <= "0000000000000000";
elsif(counter = "10111101") then
instruction <= "0000000000000000";
elsif(counter = "10111110") then
instruction <= "0000000000000000";
elsif(counter = "10111111") then
instruction <= "0000000000000000";
elsif(counter = "11000000") then
instruction <= "0000000000000000";
elsif(counter = "11000001") then
instruction <= "0000000000000000";
elsif(counter = "11000010") then
instruction <= "0000000000000000";
elsif(counter = "11000011") then
instruction <= "0000000000000000";
elsif(counter = "11000100") then
instruction <= "0000000000000000";
elsif(counter = "11000101") then
instruction <= "0000000000000000";
elsif(counter = "11000110") then
instruction <= "0000000000000000";
elsif(counter = "11000111") then
instruction <= "0000000000000000";
elsif(counter = "11001000") then
instruction <= "0000000000000000";
elsif(counter = "11001001") then
instruction <= "0000000000000000";
elsif(counter = "11001010") then
instruction <= "0000000000000000";
elsif(counter = "11001011") then
instruction <= "0000000000000000";
elsif(counter = "11001100") then
instruction <= "0000000000000000";
elsif(counter = "11001101") then
instruction <= "0000000000000000";
elsif(counter = "11001110") then
instruction <= "0000000000000000";
elsif(counter = "11001111") then
instruction <= "0000000000000000";
elsif(counter = "11010000") then
instruction <= "0000000000000000";
elsif(counter = "11010001") then
instruction <= "0000000000000000";
elsif(counter = "11010010") then
instruction <= "0000000000000000";
elsif(counter = "11010011") then
instruction <= "0000000000000000";
elsif(counter = "11010100") then
instruction <= "0000000000000000";
elsif(counter = "11010101") then
instruction <= "0000000000000000";
elsif(counter = "11010110") then
instruction <= "0000000000000000";
elsif(counter = "11010111") then
instruction <= "0000000000000000";
elsif(counter = "11011000") then
instruction <= "0000000000000000";
elsif(counter = "11011001") then
instruction <= "0000000000000000";
elsif(counter = "11011010") then
instruction <= "0000000000000000";
elsif(counter = "11011011") then
instruction <= "0000000000000000";
elsif(counter = "11011100") then
instruction <= "0000000000000000";
elsif(counter = "11011101") then
instruction <= "0000000000000000";
elsif(counter = "11011110") then
instruction <= "0000000000000000";
elsif(counter = "11011111") then
instruction <= "0000000000000000";
elsif(counter = "11100000") then
instruction <= "0000000000000000";
elsif(counter = "11100001") then
instruction <= "0000000000000000";
elsif(counter = "11100010") then
instruction <= "0000000000000000";
elsif(counter = "11100011") then
instruction <= "0000000000000000";
elsif(counter = "11100100") then
instruction <= "0000000000000000";
elsif(counter = "11100101") then
instruction <= "0000000000000000";
elsif(counter = "11100110") then
instruction <= "0000000000000000";
elsif(counter = "11100111") then
instruction <= "0000000000000000";
elsif(counter = "11101000") then
instruction <= "0000000000000000";
elsif(counter = "11101001") then
instruction <= "0000000000000000";
elsif(counter = "11101010") then
instruction <= "0000000000000000";
elsif(counter = "11101011") then
instruction <= "0000000000000000";
elsif(counter = "11101100") then
instruction <= "0000000000000000";
elsif(counter = "11101101") then
instruction <= "0000000000000000";
elsif(counter = "11101110") then
instruction <= "0000000000000000";
elsif(counter = "11101111") then
instruction <= "0000000000000000";
elsif(counter = "11110000") then
instruction <= "0000000000000000";
elsif(counter = "11110001") then
instruction <= "0000000000000000";
elsif(counter = "11110010") then
instruction <= "0000000000000000";
elsif(counter = "11110011") then
instruction <= "0000000000000000";
elsif(counter = "11110100") then
instruction <= "0000000000000000";
elsif(counter = "11110101") then
instruction <= "0000000000000000";
elsif(counter = "11110110") then
instruction <= "0000000000000000";
elsif(counter = "11110111") then
instruction <= "0000000000000000";
elsif(counter = "11111000") then
instruction <= "0000000000000000";
elsif(counter = "11111001") then
instruction <= "0000000000000000";
elsif(counter = "11111010") then
instruction <= "0000000000000000";
elsif(counter = "11111011") then
instruction <= "0000000000000000";
elsif(counter = "11111100") then
instruction <= "0000000000000000";
elsif(counter = "11111101") then
instruction <= "0000000000000000";
elsif(counter = "11111110") then
instruction <= "0000000000000000";
elsif(counter = "11111111") then
instruction <= "0000000000000000";
end if;
end process;
end behavior;
------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
entity program_counter is
port(
rst : in std_logic;
jump_enable: in std_logic; --Allow jump to address
jump_address: in std_logic_vector(7 downto 0); --Address jumped to
clk: in std_logic;
offset_enable: in std_logic; --Allow for branch instructions
offset_value: in std_logic_vector(7 downto 0); --Branch offset added to counter
counter: out std_logic_vector(7 downto 0));
end program_counter;
architecture behavior of program_counter is
signal temp_counter : std_logic_vector(7 downto 0);
begin
count: process(jump_enable,jump_address,clk,offset_enable,offset_value, rst)
begin
  if (rst = '1') then
    temp_counter <= (others => '0');
  end if;
  
if (rising_edge(clk)) then
if(jump_enable = '1') then --If jump instruction, jump to specified address
temp_counter <= jump_address;
elsif(offset_enable = '1') then --If branch instruction, add offset
temp_counter <= temp_counter + offset_value;
else --Increment counter by default
temp_counter <= temp_counter + "00000001";
end if;
counter <= temp_counter;

end if;
end process;
end behavior;
-----------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity fetch is --Declare the top-level entity and all major inputs/outputs
port ( 
rst : in std_logic;
jump_enable: in std_logic;
jump_address: in std_logic_vector(7 downto 0);
clk: in std_logic;
offset_enable: in std_logic;
offset_value: in std_logic_vector(7 downto 0);
instruction: out std_logic_vector (15 downto 0));
end fetch;
architecture structural of fetch is
  
signal sig_counter : std_logic_vector(7 downto 0);

component program_counter --Declare each component and their respetive inputs/outputs
port(
rst : in std_logic;
jump_enable: in std_logic; --Allow jump to address
jump_address: in std_logic_vector(7 downto 0); --Address jumped to
clk: in std_logic;
offset_enable: in std_logic; --Allow for branch instructions
offset_value: in std_logic_vector(7 downto 0); --Branch offset added to counter
counter: out std_logic_vector(7 downto 0));
end component;

component instruction_memory
port(
counter: in std_logic_vector(7 downto 0); --Counter value obtained from PC
instruction: out std_logic_vector(15 downto 0)); --Fetched Instruction
end component;

begin --PORT MAP
pc : program_counter port map ( rst, jump_enable, jump_address, clk, offset_enable, offset_value, sig_counter);
imem : instruction_memory port map (sig_counter, instruction);
end structural;
