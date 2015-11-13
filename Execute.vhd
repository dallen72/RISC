library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity execute is --Declare the top-level entity and all major inputs/outputs
  port ( 
          rst : in std_logic;
          instruction_in: in std_logic_vector(15 downto 0);
          clk: in std_logic;
          writeback: in std_logic_vector(7 downto 0);
          writeEnable: in std_logic;
          writeAdd: in std_logic_vector(3 downto 0);
          instruction_out: out std_logic_vector(15 downto 0);
          output: out std_logic_vector(7 downto 0);
          out_wr_en : out std_logic;
          reg_file_wr_addr: out std_logic_vector(3 downto 0)
          );
end execute;

architecture structural of execute is 

signal Rx, Ry : std_logic_vector(7 downto 0);

component ALU --Declare each component and their respetive inputs/outputs
  port(
          Rx,Ry: in std_logic_vector(7 downto 0);
          rst : in std_logic;
          clk: in std_logic;
          instruction_in: in std_logic_vector(15 downto 0);
          instruction_out: out std_logic_vector(15 downto 0);
          output: out std_logic_vector(7 downto 0);
          reg_file_wr_en : out std_logic;
          reg_file_wr_addr: out std_logic_vector(3 downto 0)
          );
end component;

component register_bank
  port(
        rst : in std_logic;
        instruction_in: in std_logic_vector(15 downto 0);
        instruction_out: out std_logic_vector(15 downto 0);
        clk: in std_logic;
        writeback: in std_logic_vector (7 downto 0);
        writeEnable: in std_logic;
        writeAdd: in std_logic_vector(3 downto 0);
        Rx, Ry: out std_logic_vector(7 downto 0));
      end component;
      
      begin --PORT MAP
        alu_unit : ALU port map (Rx, Ry, rst, clk, instruction_in, instruction_out, output, out_wr_en, reg_file_wr_addr);
        r_bank : register_bank port map (rst, instruction_in, instruction_out, clk, writeback, writeEnable, writeAdd, Rx, Ry);
        
end structural;
      
      
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;      


entity ALU is
  port(Rx,Ry: in std_logic_vector(7 downto 0);
    rst : in std_logic;
    clk: in std_logic;
    instruction_in: in std_logic_vector(15 downto 0);
    instruction_out: out std_logic_vector(15 downto 0);
    output: out std_logic_vector(7 downto 0);
    reg_file_wr_en : out std_logic;
    reg_file_wr_addr : out std_logic_vector(3 downto 0)
    );
  end ALU;
  
  architecture BEHAVIOR of ALU is
  begin 
    
    CALCULATE:process(clk)
    begin
      
      if(rising_edge(clk)) then
      
        instruction_out <= instruction_in;
      
        if (rst = '0') then
          reg_file_wr_en <= '0';
          output <= (others => '0');
          
        elsif(instruction_in(15 downto 8)="00100000") then --Addition. Confirmed Working
          output <= (Rx + Ry);
          reg_file_wr_en <= '1';
      
        elsif(instruction_in(15 downto 8)="00100001") then --Subtraction. Confirmed Working
          output <= (Rx - Ry);
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="00110000") then --Increment. Confirmed Working
          output <= (Rx + "00000001");
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="00110001") then --Decrement. Confirmed Working
          output <= (Rx - "00000001");
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01000000") then --Left Shift. Confirmed Working
          output <= std_logic_vector(unsigned(Rx) sll conv_integer(Ry));
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01000001") then --Right Shift. Confirmed Working
          output <= std_logic_vector(unsigned(Rx) srl conv_integer(Ry));
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01010000") then --Logical NOT. Confirmed Working. 
          output <= (not Rx);
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01010001") then --Logical NOR. Confirmed Working.
          output <= (Rx NOR Ry);
          reg_file_wr_en <= '1';          
    
        elsif(instruction_in(15 downto 8)="01010010") then --Logical NAND. Confirmed Working.
          output <= (Rx NAND Ry);
          reg_file_wr_en <= '1';
      
        elsif(instruction_in(15 downto 8)="01010011") then --Logical XOR. Confirmed Working.
          output <= (Rx XOR Ry);
          reg_file_wr_en <= '1';      
      
        elsif(instruction_in(15 downto 8)="01010100") then --Logical AND. Confirmed Working.
          output <= (Rx AND Ry);
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01010101") then --Logical OR. Confirmed Working.
          output <= (Rx OR Ry);
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01010110") then --Clear. Confirmed Working.
          output <= "00000000";
          reg_file_wr_en <= '1';          
      
        elsif(instruction_in(15 downto 8)="01010111") then --Set. Confirmed Working
          output <= "11111111";
          reg_file_wr_en <= '1';          
      
        elsif((instruction_in(15 downto 8)="01011111") and (Rx < Ry)) then --Set on Less Than. Confirmed Working.
          output <= "11111111";
          reg_file_wr_en <= '1';          
        
        elsif(instruction_in(15 downto 12)="0001") then --Add Immediate. Confirmed Working.
          output <= Rx + instruction_in(7 downto 0);
          reg_file_wr_en <= '1';          
          
        elsif(instruction_in(15 downto 8)="01011000") then --Move. Confirmed Working.
          output <= Rx;
          reg_file_wr_en <= '1';          
          
        elsif((instruction_in(15 downto 12)="1101") and (Rx="00000000")) then --Branch If 0. Confirmed Working.
          output <= Ry;
          reg_file_wr_en <= '0';          
          
        elsif((instruction_in(15 downto 12)="1110") and (not(Rx="00000000"))) then --Branch If Not 0. Confirmed Working.
          output <= Ry;
          reg_file_wr_en <= '0';          
        else
          output <= (others => '0');
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
        rst : in std_logic;
        instruction_in: in std_logic_vector(15 downto 0);
        instruction_out: out std_logic_vector(15 downto 0);
        clk: in std_logic;
        writeback: in std_logic_vector (7 downto 0);
        writeEnable: in std_logic;
        writeAdd: in std_logic_vector(3 downto 0);
        Rx, Ry: out std_logic_vector(7 downto 0));        
end register_bank;

architecture behavior of register_bank is
  
  type vector_array is array(0 to 15) of std_logic_vector(7 downto 0);
  signal reg : vector_array := (others => (others => '0'));
  signal sig_writeAddInt : integer := 0; -- for coverstion to register file index
  signal sig_RxInt : integer := 0; -- for conversion to Register X output
  signal sig_RyInt : integer := 0;
  
begin
        
  find_Rx_Ry: process(clk)
          
  begin
    
    if(rising_edge(clk)) then
      
      instruction_out <= instruction_in;
      
      if (rst = '1') then
        reg <= (others => (others => '0'));     
      
      elsif(writeEnable='1') then --Allows overwriting register values
        
        sig_writeAddInt <= to_integer(unsigned(writeAdd));
        reg(sig_writeAddInt) <= writeback;   
        
      end if;
        
  --------------------------------------------------------    
      
      if(instruction_in(15 downto 12)="0001") then --If add immediate, Rx is in bits 11 - 8.
        sig_RxInt <= to_integer(unsigned(instruction_in(11 downto 8)));
        Rx <= reg(sig_RxInt);
        
      else  --For non add immediate instructions, Rx is in bits 7 - 4.
        sig_RxInt <= to_integer(unsigned(instruction_in(7 downto 4)));
        Rx <= reg(sig_RxInt);
      end if;
        
------------------------------------------------------------
      sig_RyInt <= to_integer(unsigned(instruction_in(3 downto 0))); --Ry is always in the lowest 4 bits.
      Ry <= reg(sig_RyInt);
  
    end if; 
               
  end process;
        
end behavior;




-------------------------------------------------------------------------------------------------