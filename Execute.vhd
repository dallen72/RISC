library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity execute is --Declare the top-level entity and all major inputs/outputs
  port ( 
          rst : in std_logic;
          instruction_in: in std_logic_vector(15 downto 0);
          clk: in std_logic;
          clk_stage: in std_logic;
          Rx, Ry : in std_logic_vector(3 downto 0);
          writeback: in std_logic_vector(7 downto 0);
          writeEnable: in std_logic;
          writeAdd: in std_logic_vector(3 downto 0);
          instruction_out: out std_logic_vector(15 downto 0);
          output: out std_logic_vector(7 downto 0)
          );
end execute;

architecture structural of execute is 

signal sig_X, sig_Y : std_logic_vector(7 downto 0);
signal sig_pulse_writeEnable : std_logic;

component ALU --Declare each component and their respetive inputs/outputs
  port(
          X,Y: in std_logic_vector(7 downto 0);
          clk: in std_logic;
          clk_stage: in std_logic;
          instruction_in: in std_logic_vector(15 downto 0);
          instruction_out: out std_logic_vector(15 downto 0);
          output: out std_logic_vector(7 downto 0)
          );
end component;

component register_bank
  port(
        rst : in std_logic;
        instruction_in: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        Rx, Ry : in std_logic_vector(3 downto 0);
        writeback: in std_logic_vector (7 downto 0);
        writeEnable: in std_logic;
        writeAdd: in std_logic_vector(3 downto 0);
        X, Y: out std_logic_vector(7 downto 0));
end component;
      
begin --PORT MAP
  alu_unit : ALU port map (
        X => sig_X,
        Y => sig_Y,
        clk => clk,
        clk_stage => clk_stage,
        instruction_in => instruction_in,
        instruction_out => instruction_out,
        output => output
    );
        
  r_bank : register_bank port map (rst, instruction_in, clk, Rx, Ry, writeback, sig_pulse_writeEnable, writeAdd, sig_X, sig_Y);
        
  SYNC : process (clk)
  variable var_counter : integer := 2;
  begin
    
    if (clk'event) then
    if (writeEnable = '1') then
      
      if (var_counter MOD 8 = 0) then
        sig_pulse_writeEnable <= '1';
      else
        sig_pulse_writeEnable <= '0';
      end if;
      
      var_counter := var_counter + 1;  
    
    else
      var_counter := 2;
    end if; 
    end if; 
    
  end process;    
        
end structural;
      
      
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;      


entity ALU is
  port(
    X,Y: in std_logic_vector(7 downto 0);
    clk: in std_logic;
    clk_stage: in std_logic;
    instruction_in: in std_logic_vector(15 downto 0);
    instruction_out: out std_logic_vector(15 downto 0);
    output: out std_logic_vector(7 downto 0)
    );
  end ALU;
  
  architecture BEHAVIOR of ALU is
  begin 
    
    CALCULATE:process(clk_stage)
    begin
      
     
      if(rising_edge(clk_stage)) then
                            
          
        if(instruction_in(15 downto 8)="00100000") then --Addition. Confirmed Working
          output <= (X + Y);
          
      
        elsif(instruction_in(15 downto 8)="00100001") then --Subtraction. Confirmed Working
          output <= (X - Y);         
      
        elsif(instruction_in(15 downto 8)="00110000") then --Increment. Confirmed Working
          output <= (X + "00000001");        
      
        elsif(instruction_in(15 downto 8)="00110001") then --Decrement. Confirmed Working
          output <= (X - "00000001");       
      
        elsif(instruction_in(15 downto 8)="01000000") then --Left Shift. Confirmed Working
          output <= X(6 downto 0) & '0'; 
      
        elsif(instruction_in(15 downto 8)="01000001") then --Right Shift. Confirmed Working
          output <= '0' & X(7 downto 1);       
      
        elsif(instruction_in(15 downto 8)="01010000") then --Logical NOT. Confirmed Working. 
          output <= (not X);      
      
        elsif(instruction_in(15 downto 8)="01010001") then --Logical NOR. Confirmed Working.
          output <= (X NOR Y);      
    
        elsif(instruction_in(15 downto 8)="01010010") then --Logical NAND. Confirmed Working.
          output <= (X NAND Y);
      
        elsif(instruction_in(15 downto 8)="01010011") then --Logical XOR. Confirmed Working.
          output <= (X XOR Y);   
      
        elsif(instruction_in(15 downto 8)="01010100") then --Logical AND. Confirmed Working.
          output <= (X AND Y);         
      
        elsif(instruction_in(15 downto 8)="01010101") then --Logical OR. Confirmed Working.
          output <= (X OR Y);         
      
        elsif(instruction_in(15 downto 8)="01010110") then --Clear. Confirmed Working.
          output <= "00000000";       
      
        elsif(instruction_in(15 downto 8)="01010111") then --Set. Confirmed Working
          output <= "11111111";         
      
        elsif((instruction_in(15 downto 8)="01011111") and (X < Y)) then --Set on Less Than. Confirmed Working.
          output <= "11111111";         
        
        elsif(instruction_in(15 downto 12)="0001") then --Add Immediate. Confirmed Working.
          output <= X + instruction_in(7 downto 0);    
          
        elsif(instruction_in(15 downto 8)="01011000") then --Move. Confirmed Working.
          output <= X;     
          
        elsif((instruction_in(15 downto 12)="1101") and (X="00000000")) then --Branch If 0. Confirmed Working.
          output <= Y;      
          
        elsif((instruction_in(15 downto 12)="1110") and (not(X="00000000"))) then --Branch If Not 0. Confirmed Working.
          output <= Y;       
        else
          output <= (others => '0');               
        end if;
      
      end if;
    
    end process;
    
    SYNC: process(instruction_in)
    begin
      instruction_out <= instruction_in;
    end process;
    
  end BEHAVIOR;
  
  -----------------------------------------------------------------------------------------------------------------------------------
  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity register_bank is 
  
  port(
        rst : in std_logic;
        instruction_in: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        Rx, Ry : in std_logic_vector(3 downto 0);
        writeback: in std_logic_vector (7 downto 0);
        writeEnable: in std_logic;
        writeAdd: in std_logic_vector(3 downto 0);
        X, Y : out std_logic_vector(7 downto 0));        
end register_bank;

architecture behavior of register_bank is
  
  type vector_array is array(0 to 15) of std_logic_vector(7 downto 0);
  signal reg : vector_array := (others => (others => '0'));

  
begin
        
  find_X_Y: process(clk)
          
  begin
    
    if(rising_edge(clk)) then
      
      if (rst = '1') then
        reg <= (others => (others => '0'));     
      
      elsif(writeEnable='1') then --Allows overwriting register values
        reg(to_integer(unsigned(writeAdd))) <= writeback;
      end if;
      
      X <= reg(to_integer(unsigned(Rx)));
      Y <= reg(to_integer(unsigned(Ry)));  
  
    end if; 
               
  end process;
        
end behavior;




-------------------------------------------------------------------------------------------------