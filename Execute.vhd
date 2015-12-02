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
          mem_addr_sel : in std_logic_vector(1 downto 0);
          writeback: in std_logic_vector(7 downto 0);
          writeEnable: in std_logic;
          writeAdd: in std_logic_vector(3 downto 0);
          output: out std_logic_vector(7 downto 0);
          mem_addr: out std_logic_vector(7 downto 0);
          X, Y : out std_logic_vector(7 downto 0);
          intrpt_output_en : in std_logic;
          intrpt_wr_reg : in std_logic;
          intrpt_Din : out std_logic_vector(7 downto 0);          
          intrpt_Dout : in std_logic_vector(7 downto 0);
          intrpt_reg_addr : in std_logic_vector(3 downto 0)
          );
end execute;

architecture structural of execute is 

signal sig_X, sig_Y : std_logic_vector(7 downto 0);
signal sig_pulse_writeEnable : std_logic;

-- interrupt signals
signal sig_intrpt_Din : std_logic_vector(7 downto 0);
-- to/from execute
signal sig_intrpt_wr_reg : std_logic;    
signal sig_intrpt_Dout : std_logic_vector(7 downto 0);
signal sig_intrpt_reg_addr : std_logic_vector(3 downto 0);
signal sig_out_mux_Rx : std_logic_vector(3 downto 0);
signal sig_out_mux_writeback : std_logic_vector(7 downto 0);
signal sig_out_mux_writeEnable : std_logic;
signal sig_out_mux_writeAdd : std_logic_vector(3 downto 0);
signal sig_out_mux_sig_X : std_logic_vector(7 downto 0);
signal sig_intrpt_output_en : std_logic;

begin --PORT MAP
  alu_unit : entity work.ALU port map (
        X => sig_X,
        Y => sig_Y,
        clk => clk,
        clk_stage => clk_stage,
        instruction_in => instruction_in,
        output => output
    );
        
  r_bank : entity work.register_bank port map (
        rst => rst,
        instruction_in => instruction_in,
        clk => clk,
        Rx => sig_out_mux_Rx,
        Ry => Ry,
        writeback => sig_out_mux_writeback,
        writeEnable => sig_pulse_writeEnable,
        writeAdd => sig_out_mux_writeAdd,
        X => sig_X,
        Y => sig_Y
    );      
    
    
  INTRPT_MUX : process (clk, rst)
  begin
    if (rst = '1') then
        sig_out_mux_Rx <= (others => '0');
        sig_out_mux_writeback <= (others => '0');
        sig_out_mux_writeEnable <= '0';
        sig_out_mux_writeAdd <= (others => '0');
        intrpt_Din <= (others => '0');
    elsif (rising_edge(clk)) then
      intrpt_Din <= sig_X;
      if (sig_intrpt_output_en = '1') then
        sig_out_mux_Rx <= intrpt_reg_addr;
        sig_out_mux_writeback <= intrpt_Dout;
        sig_out_mux_writeEnable <= intrpt_wr_reg;
        sig_out_mux_writeAdd <= intrpt_reg_addr;
      else
        sig_out_mux_Rx <= Rx;
        sig_out_mux_writeback <= writeback;
        sig_out_mux_writeAdd <= writeAdd;
        sig_out_mux_writeEnable <= writeEnable;
      end if;
    end if;
  end process;
        
        
  MUX: process (clk_stage)
  begin
    
    if (rising_edge(clk_stage) and (instruction_in /= x"0000") ) then
      
      if (mem_addr_sel = "01") then -- LD Indirect
        mem_addr <= sig_Y; -- set to Y
      elsif (mem_addr_sel = "10") then -- ST Indirect
        mem_addr <= sig_X;
      elsif (mem_addr_sel = "11") then -- LD Register, STR Register
        mem_addr <= instruction_in(7 downto 0); -- set to lower 8 bits of instruction   
      end if;   
  
    end if;
  end process;
        
  -- process to pulse the register file write enable        
  SYNC : process (clk)
  variable var_counter : integer := 2;
  begin
    
    if (clk'event) then
      X <= sig_X;
      Y <= sig_Y;
      
      sig_intrpt_output_en <= intrpt_output_en;
      
      if (sig_out_mux_writeEnable = '1') then
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
    output: out std_logic_vector(7 downto 0)
    );
  end ALU;
  
  architecture BEHAVIOR of ALU is
  begin 
    
    CALCULATE:process(clk)
    begin
      
     
      if(rising_edge(clk) and (instruction_in /= x"0000") ) then
                            
          
        if(instruction_in(15 downto 8)="00100000") then --Addition. Confirmed Working
          output <= (X + Y);
          
      
        elsif(instruction_in(15 downto 8)="00100001") then --Subtraction. Confirmed Working
          output <= (X - Y);         
      
        elsif(instruction_in(15 downto 8)="00110000") then --Increment. Confirmed Working
          output <= (X + "00000001");        
      
        elsif(instruction_in(15 downto 8)="00110001") then --Decrement. Confirmed Working
          output <= (X - 1);       
      
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