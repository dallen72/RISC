
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity interrupt_handler_final is
  port (
    clk : in std_logic;
    rst : in std_logic;
    interrupt : in std_logic;
    En : in std_logic_vector(3 downto 0);
    RetI : in std_logic;
    interrupt_address : out integer;
    wr_to_scratchpad : out std_logic;
    wr_back_scratchpad : out std_logic
  );
end entity interrupt_handler_final;

architecture behav of interrupt_handler_final is
  
signal current_state : std_logic_vector(2 downto 0);
signal next_state : std_logic_vector(2 downto 0);
  
begin


INTERRUPT_CYCLE : process(clk, interrupt, rst)

variable var_counter : integer := 0;
variable int_count : integer := 0;

begin
  
  if (rst = '1') then
    interrupt_address <= 0;
    next_state <= (others => '0');
    wr_to_scratchpad <= '0';
    wr_back_scratchpad <= '0';    
    
  elsif (rising_edge(clk)) then
    
    
    if (current_state = "000") then -- wait state
      var_counter := 0;
      int_count := 0;
      if (interrupt = '1') then
        if (En(0) = '1' or En(1) = '1' or En(2) = '1' or En(3) = '1') then
          next_state <= "001";
          wr_to_scratchpad <= '1';
        end if;
      end if;
      
    elsif (current_state = "001") then -- writing state
      var_counter := var_counter + 1;
      if (var_counter = 16) then
        next_state <= "010";
        var_counter := 0;
        wr_to_scratchpad <= '0';        
      end if;
      
    elsif (current_state = "010") then -- check en state
      int_count := int_count + 1;
      if (int_count = 1 and En(0) = '1') then
        next_state <= "011";
        interrupt_address <= 1;        
      elsif (int_count = 2 and En(1) = '1') then
        next_state <= "100";
        interrupt_address <= 2;
      elsif (int_count = 3 and En(2) = '1') then
        next_state <= "101";     
        interrupt_address <= 3;            
      elsif (int_count = 4 and En(3) = '1') then
        next_state <= "110";        
        interrupt_address <= 4;         
      elsif (int_count > 4) then
        next_state <= "111";
        interrupt_address <= 0;   
        wr_back_scratchpad <= '1';     
      end if;
      
    elsif (current_state = "011") then -- int1 state
      if (RetI = '1') then
        next_state <= "010";
      end if;
    elsif (current_state = "100") then -- int2 state
      if (RetI = '1') then
        next_state <= "010";
      end if;
      
    elsif (current_state = "101") then -- int3 state
      if (RetI = '1') then
        next_state <= "010";
      end if;  
          
    elsif (current_state = "110") then -- int4 state
      if (RetI = '1') then
        next_state <= "010";
      end if;  
      
    elsif (current_state = "111") then -- writeback state
      var_counter := var_counter + 1;
      if (var_counter = 16) then
        next_state <= "000";
        var_counter := 0;
        wr_back_scratchpad <= '0';             
      end if;
      
      
    end if;
    
  end if;

end process;


SYNC : process (clk)

begin

  if (rst = '1') then
    current_state <= (others => '0');
  elsif (rising_edge(clk)) then
    current_state <= next_state;
  end if;

end process;

end behav;
