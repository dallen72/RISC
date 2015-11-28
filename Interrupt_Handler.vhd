library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity interrupt_handler is
  port (
    rst : in std_logic;
    clk : in std_logic;
    intrpt : in std_logic; -- from top level
    Din : in std_logic_vector(7 downto 0); -- from execute
    in_ret_addr : in std_logic_vector(7 downto 0);  -- from fetch
    RetI : in std_logic; -- from fetch
    en_intrpt : in std_logic_vector(3 downto 0); -- from fetch
    Dout : out std_logic_vector(7 downto 0); -- to execute
    out_jump_addr : out std_logic_vector(7 downto 0) 
  );
  
end interrupt_handler;

-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.ALL;

entity counter is
  generic(WIDTH : integer := 16);
  port (
    clk : in std_logic;
    en : in std_logic;
    ld : in std_logic;
    Din : in std_logic_vector(WIDTH-1 downto 0);
    Dout : out std_logic_vector(WIDTH-1 downto 0)
  );
end counter;

architecture behav of counter is
  signal temp_vector : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  begin


calc: process (clk)
begin
  
  if (clk'event and clk = '1') then
    
    if (ld = '1') then
      temp_vector <= Din;
    end if;
  
    if (en = '1') then
      temp_vector <= temp_vector + 1;
    end if;
    
    Dout <= temp_vector;
  end if;
  
end process;

end behav;

--------------------------------------------------------------------------------------------------------------------------

architecture behav of interrupt_handler is
  signal sig_Din_reg : std_logic_vector(7 downto 0);
  signal sig_wr_reg : std_logic;
  signal sig_addr_reg : std_logic_vector(3 downto 0);
  signal sig_ret_addr : std_logic_vector(7 downto 0);
  signal sig_wr_count : std_logic_vector(3 downto 0); 
  signal sig_wr_count_en : std_logic;
  signal sig_current_intrpt : std_logic_vector(2 downto 0);
  signal sig_next_current_intrpt : std_logic_vector(2 downto 0);
  
  type intrpt_addr_array is array(0 to 3) of std_logic_vector(7 downto 0);
  signal intrpt_addr : intrpt_addr_array := (others => (others => '0'));
  
    -- store which intrpts are enabled  
  signal sig_reg_en_intrpt : std_logic_vector(4 downto 0) := (others => '0');
  signal sig_in_intrpt : std_logic;
  
  component counter
  generic(WIDTH : integer := 8);
  port (
    clk : in std_logic;
    en : in std_logic;
    ld : in std_logic;
    Din : in std_logic_vector(WIDTH-1 downto 0);
    Dout : out std_logic_vector(WIDTH-1 downto 0)
  );
  
  end component;

begin
  
  
  scratchpad_reg : entity work.register_bank
      port map (
        rst => rst,
        instruction_in => x"0000",
        clk => clk,
        Rx => sig_addr_reg,
        Ry => x"0",
        writeback => sig_Din_reg,
        writeEnable => sig_wr_reg,
        writeAdd => sig_addr_reg,
        X => Dout
      );
      
   write_counter : component counter
   generic map(WIDTH => 4)
   port map (  
     clk => clk,
     en => sig_wr_count_en,
     ld => '0',
     Din => (others => '0'),
     Dout => sig_wr_count
  );
 
      
  SCRATCHPAD : process (intrpt, rst, sig_wr_reg, sig_addr_reg, sig_Din_reg)
    begin
      If (rst = '1') then
        sig_ret_addr <= (others => '0');
      elsif (intrpt = '1') then
        sig_ret_addr <= in_ret_addr;
      end if;
      
  end process; 
      
  -- drives the scratchpad
 -- WRITER : process ()
 -- end process;
 
 
  -- stores which intrpts are enabled
  -- stores interrupt instruction addresses
  -- feeds the Priority Handler
  STORE_INTRPT : process (clk, en_intrpt)
  begin
    if (rising_edge(clk)) then

      -- default
      sig_reg_en_intrpt(0) <= '0';
    
      intrpt_addr(0) <= x"7D"; -- 125
      intrpt_addr(1) <= x"96"; -- 150
      intrpt_addr(2) <= x"AF"; -- 175      
      intrpt_addr(3) <= x"c8"; -- 175      
    
    -- store which intrpts are enabled
      if ( (en_intrpt(0) = '1') or (en_intrpt(1) = '1') or (en_intrpt(2) = '1') or (en_intrpt(3) = '1') ) then
        sig_reg_en_intrpt(0) <= en_intrpt(0);
        sig_reg_en_intrpt(1) <= en_intrpt(1);
        sig_reg_en_intrpt(2) <= en_intrpt(2);
        sig_reg_en_intrpt(3) <= en_intrpt(3);
      end if;
    
    
    end if;
  end process;
  
  SYNC: process (rst, clk)
  begin
    if (rst = '1') then
      sig_current_intrpt <= "000";
    elsif (clk'event) then
      sig_current_intrpt <= sig_next_current_intrpt;
    end if;
  end process;
  
  -- controls the writer
  -- output the return address
  PRIORITY_HANDLER : process (clk, intrpt, en_intrpt, RetI, sig_ret_addr)
  variable var_in_main : std_logic := '1';
  begin
  
  
  if (rst = '1') then
      sig_next_current_intrpt <= "000"; 
  elsif (rising_edge(clk)) then
    -- set the output current address to the main return address.
    -- LSB is highest prority interrupt
    
    if (sig_current_intrpt = "000") then
      if (intrpt = '1') then
        sig_next_current_intrpt <= "001";                             
        out_jump_addr <= intrpt_addr(0);         
      end if;  
      
    -- first interrupt state
    elsif (sig_current_intrpt = "001") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(0) = '0') ) then
        sig_next_current_intrpt <= "010";                            
        out_jump_addr <= intrpt_addr(1);            
      end if;  
    
    -- second interrupt state      
    elsif (sig_current_intrpt = "010") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(1) = '0') ) then
        sig_next_current_intrpt <= "011";               
        out_jump_addr <= intrpt_addr(2);                   
      end if;  
    
    -- third interrupt state    
    elsif (sig_current_intrpt = "011") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(2) = '0') ) then
        sig_next_current_intrpt <= "100";                               
        out_jump_addr <= intrpt_addr(3);                                            
      end if;
  
    -- fourth interrupt state  
    elsif (sig_current_intrpt = "100") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(3) = '0') ) then
        sig_next_current_intrpt <= "000";               
        out_jump_addr <= sig_ret_addr;                         
      end if;

    end if;

  end if;
  
  end process;
  
  
  
end architecture;
