
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

-- for syncing the program counter with the bubble
entity two_to1mux1bit is
  port(
    in1 : in std_logic;
    in2 : in std_logic;
    sel : in std_logic;
    out1 : out std_logic
  );
end two_to1mux1bit;

architecture struct of two_to1mux1bit is
  begin
    behav: process (in1, in2, sel)
    begin
      if (sel = '1') then
        out1 <= in2;
      else
        out1 <= in1;
      end if;
    end process;
end struct;

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
  clk_stage : in std_logic;
  offset_enable: in std_logic;
  offset_value: in std_logic_vector(7 downto 0);
  out_instruction: out std_logic_vector (15 downto 0));
end fetch;

architecture structural of fetch is
  
component two_to1mux1bit
  port (
    in1 : in std_logic;
    in2 : in std_logic;
    sel : in std_logic;
    out1 : out std_logic
  );
end component;
  
signal counter : std_logic_vector(7 downto 0) := (others => '0');
signal sig_bubble : std_logic := '0';
signal sig_counter_reversed : std_logic := '1'; -- these three used for decrementing the counter after a bubble has began
signal sig_counter_reversed_bubble : std_logic := '1';
signal sig_counter_reversed_no_bubble : std_logic := '0';
signal sig_delay_bubble : std_logic := '0';
signal temp_counter : std_logic_vector(7 downto 0);
signal instruction : std_logic_vector(15 downto 0);
signal instruction_shift_reg : std_logic_vector(47 downto 0) := (others => '0'); -- shifts last three instructions
signal instruction_Rx_shift_reg : std_logic_vector(11 downto 0) := (others => '0'); -- shifts Rx's of last three instructions
signal bubble_counter : integer := 0;

begin --PORT MAP
 
counter_reversed_mux : two_to1mux1bit
  port map(
    in1 => sig_counter_reversed_bubble,
    in2 => sig_counter_reversed_no_bubble,
    sel => sig_bubble,
    out1 => sig_counter_reversed
  );
 
instruction_fetch: process(counter, clk)
variable var_no_op_bubble : std_logic := '0'; -- to send a no op during bubble
begin
  
-- assumption: offset of branch instructions is in R[y]   
  
if (rising_edge(clk_stage)) then
  

if(counter = "00000000") then
instruction <= "0000000000000000";
elsif(counter = "00000001") then
instruction <= x"1108";  -- ADD Immediate $r1 ($r1 = 8)
elsif(counter = "00000010") then
instruction <= x"3020";  -- Increment $r2 ($r2 = 1)
elsif(counter = "00000011") then
instruction <= x"4110";  -- Shift Right $r1 ($r1 = 4)
elsif(counter = "00000100") then
instruction <= x"4020";  -- Shift Left $r2 ($r2 = 2)
elsif(counter = "00000101") then
instruction <= x"5010";  -- Not $r1,$r1 ($r1 = 251)
elsif(counter = "00000110") then
instruction <= x"5111";  -- Nor $r1, $r1 ($r1 = 4)
elsif(counter = "00000111") then
instruction <= x"5212";  -- Nand $r1, $r2 ($r1 = 251)
elsif(counter = "00001000") then
instruction <= x"3110";  -- decrement $r1 ($r1 = 250)
elsif(counter = "00001001") then
instruction <= "1101000100010000";  -- Branch if zero $r1, $r1 (no branch)
elsif(counter = "00001010") then
instruction <= "1110000000000001";  -- Branch if not zero $r0, $r1 (no branch)
elsif(counter = "00001011") then
instruction <= "0101011100010000";  -- Set $r1 ($r1 = 1)
elsif(counter = "00001100") then
instruction <= "0101011000010000";  -- Clear $r1 ($r1 = 0)
elsif(counter = "00001101") then
instruction <= "0101111100010010";  -- Set if less than $r1, $r2 ($r1 = 1)
elsif(counter = "00001110") then
instruction <= "0101010100010010";  -- OR $r1, $r2 ($r1 = 3)
elsif(counter = "00001111") then
instruction <= "0101010000010010";  -- And $r1, $r2 ($r1 = 2)
elsif(counter = "00010000") then
instruction <= "0101001100010010";  -- Xor $r1, $r2 ($r1 = 0)
elsif(counter = "00010001") then
instruction <= "0101100000100001";  -- Move $r1, $r2 ($r1 = $r2 = 2)
elsif(counter = "00010010") then
instruction <= "0010000100010010";  -- Subtract $r1, $r2 ($r1 = 0)
elsif(counter = "00010011") then
instruction <= "1100000000110010";  -- jump to instruction 50
elsif(counter = "00010100") then
instruction <= "0000000000000000";  
elsif(counter = "00010101") then
instruction <= "0000000000000000";
elsif(counter = "00010110") then
instruction <= "0000000000000000";  
elsif(counter = "00010111") then
instruction <= "0000000000000000";
elsif(counter = "00011000") then
instruction <= "0000000000000000";  
elsif(counter = "00011001") then
instruction <= "0000000000000000";
elsif(counter = "00011010") then
instruction <= "0000000000000000";  
elsif(counter = "00011011") then
instruction <= "0000000000000000";
elsif(counter = "00011100") then
instruction <= "0000000000000000";  
elsif(counter = "00011101") then
instruction <= "0000000000000000";
elsif(counter = "00011110") then
instruction <= "0000000000000000";  
elsif(counter = "00011111") then
instruction <= "0000000000000000";
elsif(counter = "00100000") then
instruction <= "0000000000000000";  
elsif(counter = "00100001") then
instruction <= "0000000000000000";
elsif(counter = "00100010") then
instruction <= "0000000000000000";
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
instruction <= "0010000000010010";  -- Add $r1, $r2 ($r1 = 4)
elsif(counter = "00110101") then
instruction <= "1001000000010010";  -- Store Indirect $r1, $r2 (MEM[4] = 2)
elsif(counter = "00110110") then
instruction <= "1000000000110001";  -- Load Indirect $r3, $r1 ($r3 = 2)
elsif(counter = "00110111") then
instruction <= "0000000000000000";
elsif(counter = "00111000") then
instruction <= "0000000000000000";
elsif(counter = "00111001") then
instruction <= "0000000000000000";
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

end if;

-- bubble for hazards
-------------------------------------

-- set Rx

if (rising_edge(clk)) then
    
  
if ((bubble_counter > 2) and (sig_delay_bubble = '0') ) then -- if bubble time is over, continue counting
  sig_bubble <= '0';
  bubble_counter <= 0;
-- check Rx to set bubble
elsif ( (sig_bubble = '0') and (counter > 0)
and (instruction /= "0000000000000000")
and (instruction_Rx_shift_reg(3 downto 0) /= x"0") ) then
  if ( (instruction_Rx_shift_reg(7 downto 4) = instruction_Rx_shift_reg(11 downto 8))
  or (instruction_Rx_shift_reg(3 downto 0) = instruction_Rx_shift_reg(11 downto 8)) ) then
    sig_bubble <= '1';
    sig_delay_bubble <= '1';
  end if; 
elsif ( (sig_bubble = '1') and (rising_edge(clk_stage)) ) then -- increment bubble counter
  bubble_counter <= bubble_counter + 1;
end if;

if (rising_edge(clk_stage)) then
  if ( (sig_bubble = '0') or (bubble_counter > 3) ) then
    sig_delay_bubble <= '0';
  end if;
end if;
 
if ( (var_no_op_bubble = '1') and (rising_edge(clk_stage)) ) then
    out_instruction <= "0000000000000000";
elsif ( (sig_bubble = '0') ) then
    out_instruction <= instruction_shift_reg(15 downto 0);
    var_no_op_bubble := '0';
elsif (sig_bubble = '1') then
  var_no_op_bubble := '1';
end if;

end if;

-------------------------------------

end process;

-- shift right the instructions for the bubble
shift_instructions: process (clk_stage)
begin
if (rising_edge(clk_stage)) then
  
  if ( (sig_bubble = '0') or (bubble_counter > 3) ) then
    
    instruction_shift_reg <= instruction & instruction_shift_reg(47 downto 16);
    if(instruction(15 downto 12) = "0001") then --If add immediate, Rx is in bits 11 - 8.
      instruction_Rx_shift_reg <= instruction(11 downto 8) & instruction_Rx_shift_reg(11 downto 4);
    else
      instruction_Rx_shift_reg <= instruction(7 downto 4) & instruction_Rx_shift_reg(11 downto 4);
    end if;
  end if;
end if;

end process;

count: process(jump_enable,jump_address,clk_stage,offset_enable,offset_value, rst, sig_bubble)
variable var_count : integer := 0;

begin
  if (rst = '1') then
    counter <= (others => '0');
  elsif ( (sig_bubble = '1') and (sig_counter_reversed = '0') ) then
    --decrement counter minus one to ensure the next instruction after bubble ends is not one ahead
    counter  <= counter - 1;
    sig_counter_reversed_no_bubble <= '1';
  elsif ( (rising_edge(clk_stage)) and (bubble_counter = 4) ) then
    counter <= counter + "00000001";
  elsif ( rising_edge(clk_stage) and (sig_bubble = '0') ) then
    sig_counter_reversed_no_bubble <= '0';
    
    if(jump_enable = '1') then --If jump instruction, jump to specified address
      counter <= jump_address;
    elsif(offset_enable = '1') then --If branch instruction, add offset
      counter <= counter + offset_value;
    else --Increment counter by default
      counter <= counter + "00000001";
    end if;
    
  end if;

end process;

end structural;
