library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ALU is
  port(Rx,Ry: in std_logic_vector(7 downto 0);
    clk: in std_logic;
    instruction: inout std_logic_vector(15 downto 0);
    output: out std_logic_vector(7 downto 0));
  end ALU;
  
  architecture BEHAVIOR of ALU is
  begin 
    
    CALCULATE:process(clk)
    begin
      
      if(rising_edge(clk)) then
      
        if(instruction(15 downto 8)="00100000") then --Addition. Confirmed Working
          output <= (Rx + Ry);
      
        elsif(instruction(15 downto 8)="00100001") then --Subtraction. Confirmed Working
          output <= (Rx - Ry);
      
        elsif(instruction(15 downto 8)="00110000") then --Increment. Confirmed Working
          output <= (Rx + "00000001");
      
        elsif(instruction(15 downto 8)="00110001") then --Decrement. Confirmed Working
          output <= (Rx - "00000001");
      
        elsif(instruction(15 downto 8)="01000000") then --Left Shift. Confirmed Working
          output <= std_logic_vector(unsigned(Rx) sll conv_integer(Ry));
      
        elsif(instruction(15 downto 8)="01000001") then --Right Shift. Confirmed Working
          output <= std_logic_vector(unsigned(Rx) srl conv_integer(Ry));
      
        elsif(instruction(15 downto 8)="01010000") then --Logical NOT. Confirmed Working. 
          output <= (not Rx);
      
        elsif(instruction(15 downto 8)="01010001") then --Logical NOR. Confirmed Working.
          output <= (Rx NOR Ry);
    
        elsif(instruction(15 downto 8)="01010010") then --Logical NAND. Confirmed Working.
          output <= (Rx NAND Ry);
      
        elsif(instruction(15 downto 8)="01010011") then --Logical XOR. Confirmed Working.
          output <= (Rx XOR Ry);
      
        elsif(instruction(15 downto 8)="01010100") then --Logical AND. Confirmed Working.
          output <= (Rx AND Ry);
      
        elsif(instruction(15 downto 8)="01010101") then --Logical OR. Confirmed Working.
          output <= (Rx OR Ry);
      
        elsif(instruction(15 downto 8)="01010110") then --Clear. Confirmed Working.
          output <= "00000000";
      
        elsif(instruction(15 downto 8)="01010111") then --Set. Confirmed Working
          output <= "11111111";
      
        elsif((instruction(15 downto 8)="01011111") and (Rx < Ry)) then --Set on Less Than. Confirmed Working.
          output <= "11111111";
        
        elsif(instruction(15 downto 12)="0001") then --Add Immediate. Confirmed Working.
          output <= Rx + instruction(7 downto 0);
          
        elsif(instruction(15 downto 8)="01011000") then --Move. Confirmed Working.
          output <= Rx;
          
        elsif((instruction(15 downto 12)="1101") and (Rx="00000000")) then --Branch If 0. Confirmed Working.
          output <= Ry;
          
        elsif((instruction(15 downto 12)="1110") and (not(Rx="00000000"))) then --Branch If Not 0. Confirmed Working.
          output <= Ry;
    
        end if;
      
      end if;
    
    end process;
    
  end BEHAVIOR;
  
  -----------------------------------------------------------------------------------------------------------------------------------
  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity register_bank is 
  
  port(
        instruction: inout std_logic_vector(15 downto 0);
        reg0000, reg0001, reg0010, reg0011, reg0100, reg0101, reg0110, reg0111, 
        reg1000, reg1001, reg1010, reg1011, reg1100, reg1101, reg1110, reg1111: inout std_logic_vector(7 downto 0);
        clk: in std_logic;
        writeback: in std_logic_vector (7 downto 0);
        writeEnable: in std_logic;
        writeAdd: in std_logic_vector(3 downto 0);
        Rx, Ry: out std_logic_vector(7 downto 0));        
end register_bank;

architecture behavior of register_bank is
begin
        
  find_Rx_Ry: process(clk)        
  begin
    
    if(rising_edge(clk)) then
      
      if(writeEnable='1') then --Allows overwriting register values
        
        if(writeAdd="0000") then
          reg0000 <= writeback;
        
        elsif(writeAdd="0001") then
          reg0001 <= writeback;
        
        elsif(writeAdd="0010") then
          reg0010 <= writeback;
        
        elsif(writeAdd="0011") then
          reg0011 <= writeback;
        
        elsif(writeAdd="0100") then
          reg0100 <= writeback;
        
        elsif(writeAdd="0101") then
         reg0101 <= writeback;
        
        elsif(writeAdd="0110") then
         reg0110 <= writeback;
        
        elsif(writeAdd="0111") then
         reg0111 <= writeback;
        
        elsif(writeAdd="1000") then
          reg1000 <= writeback;
        
        elsif(writeAdd="1001") then
          reg1001 <= writeback;
        
        elsif(writeAdd="1010") then
          reg1010 <= writeback;
        
        elsif(writeAdd="1011") then
          reg1011 <= writeback;
        
        elsif(writeAdd="1100") then
          reg1100 <= writeback;
        
        elsif(writeAdd="1101") then
          reg1101 <= writeback;
        
        elsif(writeAdd="1110") then
          reg1110 <= writeback;
        
        elsif(writeAdd="1111") then
          reg1111 <= writeback;
        
        end if;
        
      end if;
  --------------------------------------------------------    
      
      if(instruction(15 downto 12)="0001") then --If add immediate, Rx is in bits 11 - 8.
        if(instruction(11 downto 8)="0000") then
          Rx <= reg0000;
        
        elsif(instruction(11 downto 8)="0001") then
          Rx <= reg0001;
        
        elsif(instruction(11 downto 8)="0010") then
          Rx <= reg0010;
        
        elsif(instruction(11 downto 8)="0011") then
          Rx <= reg0011;
        
        elsif(instruction(11 downto 8)="0100") then
          Rx <= reg0100;
        
        elsif(instruction(11 downto 8)="0101") then
          Rx <= reg0101;
        
        elsif(instruction(11 downto 8)="0110") then
          Rx <= reg0110;
        
        elsif(instruction(11 downto 8)="0111") then
          Rx <= reg0111;
        
        elsif(instruction(11 downto 8)="1000") then
          Rx <= reg1000;
        
        elsif(instruction(11 downto 8)="1001") then
          Rx <= reg1001;
        
        elsif(instruction(11 downto 8)="1010") then
          Rx <= reg1010;
        
        elsif(instruction(11 downto 8)="1011") then
          Rx <= reg1011;
        
        elsif(instruction(11 downto 8)="1100") then
          Rx <= reg1100;
        
        elsif(instruction(11 downto 8)="1101") then
          Rx <= reg1101;
        
        elsif(instruction(11 downto 8)="1110") then
          Rx <= reg1110;
        
        elsif(instruction(11 downto 8)="1111") then
          Rx <= reg1111;
        
        end if;
        
      else  --For non add immediate instructions, Rx is in bits 7 - 4.
        
        if(instruction(7 downto 4)="0000") then --Find Rx
          Rx <= reg0000;
        
        elsif(instruction(7 downto 4)="0001") then
          Rx <= reg0001;
        
        elsif(instruction(7 downto 4)="0010") then
          Rx <= reg0010;
        
        elsif(instruction(7 downto 4)="0011") then
          Rx <= reg0011;
        
        elsif(instruction(7 downto 4)="0100") then
          Rx <= reg0100;
        
        elsif(instruction(7 downto 4)="0101") then
          Rx <= reg0101;
        
        elsif(instruction(7 downto 4)="0110") then
          Rx <= reg0110;
        
        elsif(instruction(7 downto 4)="0111") then
          Rx <= reg0111;
        
        elsif(instruction(7 downto 4)="1000") then
          Rx <= reg1000;
        
        elsif(instruction(7 downto 4)="1001") then
          Rx <= reg1001;
        
        elsif(instruction(7 downto 4)="1010") then
          Rx <= reg1010;
        
        elsif(instruction(7 downto 4)="1011") then
          Rx <= reg1011;
        
        elsif(instruction(7 downto 4)="1100") then
          Rx <= reg1100;
        
        elsif(instruction(7 downto 4)="1101") then
          Rx <= reg1101;
        
        elsif(instruction(7 downto 4)="1110") then
          Rx <= reg1110;
        
        elsif(instruction(7 downto 4)="1111") then
          Rx <= reg1111;
          
        end if;
        
      end if;
------------------------------------------------------------
      
      if(instruction(3 downto 0)="0000") then --Ry is always in the lowest 4 bits.
        Ry <= reg0000;
        
      elsif(instruction(3 downto 0)="0001") then
        Ry <= reg0001;
        
      elsif(instruction(3 downto 0)="0010") then
        Ry <= reg0010;
        
      elsif(instruction(3 downto 0)="0011") then
        Ry <= reg0011;
        
      elsif(instruction(3 downto 0)="0100") then
        Ry <= reg0100;
        
      elsif(instruction(3 downto 0)="0101") then
        Ry <= reg0101;
        
      elsif(instruction(3 downto 0)="0110") then
        Ry <= reg0110;
        
      elsif(instruction(3 downto 0)="0111") then
        Ry <= reg0111;
        
      elsif(instruction(3 downto 0)="1000") then
        Ry <= reg1000;
        
      elsif(instruction(3 downto 0)="1001") then
        Ry <= reg1001;
        
      elsif(instruction(3 downto 0)="1010") then
        Ry <= reg1010;
        
      elsif(instruction(3 downto 0)="1011") then
        Ry <= reg1011;
        
      elsif(instruction(3 downto 0)="1100") then
        Ry <= reg1100;
        
      elsif(instruction(3 downto 0)="1101") then
        Ry <= reg1101;
        
      elsif(instruction(3 downto 0)="1110") then
        Ry <= reg1110;
        
      elsif(instruction(3 downto 0)="1111") then
        Ry <= reg1111;
        
      end if;
 -------------------------------------------------       
  end if;
               
  end process;
        
end behavior;

-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity execute is --Declare the top-level entity and all major inputs/outputs
  port ( 
          Rx, Ry: inout std_logic_vector(7 downto 0);
          instruction: inout std_logic_vector(15 downto 0);
          clk: in std_logic;
          writeback: in std_logic_vector(7 downto 0);
          writeEnable: in std_logic;
          writeAdd: in std_logic_vector(3 downto 0);
          output: out std_logic_vector(7 downto 0);
          reg0000, reg0001, reg0010, reg0011, reg0100, reg0101, reg0110, reg0111, 
          reg1000, reg1001, reg1010, reg1011, reg1100, reg1101, reg1110, reg1111: inout std_logic_vector(7 downto 0));
end execute;

architecture structural of execute is 

component ALU --Declare each component and their respetive inputs/outputs
  port(
       Rx,Ry: in std_logic_vector(7 downto 0);
    clk: in std_logic;
    instruction: inout std_logic_vector(15 downto 0);
    output: out std_logic_vector(7 downto 0));
end component;

component register_bank
  port(
        instruction: inout std_logic_vector(15 downto 0);
        reg0000, reg0001, reg0010, reg0011, reg0100, reg0101, reg0110, reg0111, 
        reg1000, reg1001, reg1010, reg1011, reg1100, reg1101, reg1110, reg1111: inout std_logic_vector(7 downto 0);
        clk: in std_logic;
        writeback: in std_logic_vector (7 downto 0);
        writeEnable: in std_logic;
        writeAdd: in std_logic_vector(3 downto 0);
        Rx, Ry: out std_logic_vector(7 downto 0));
      end component;
      
      begin --PORT MAP
        alu_unit : ALU port map (Rx, Ry, clk, instruction, output);
        r_bank : register_bank port map (instruction,reg0000, reg0001, reg0010, reg0011, reg0100, reg0101, reg0110, reg0111, 
        reg1000, reg1001, reg1010, reg1011, reg1100, reg1101, reg1110, reg1111, clk, writeback, writeEnable, writeAdd, Rx, Ry);
        
      end structural;
      
