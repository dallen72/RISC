library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity interrupt_handler is
  generic (DATA_WIDTH : integer := 8; ADDRESS_WIDTH : integer := 8; REG_ADDR_WIDTH : integer := 8; INTRPT_BIT_WIDTH : integer := 4);
  port (
    rst : in std_logic;
    clk : in std_logic;
    intrpt : in std_logic; -- from top level. Signals that an interrupt has been activated
    
    -- from execute
    Din : in std_logic_vector((DATA_WIDTH-1) downto 0);
    -- to execute
    output_en_intrpt_handler : out std_logic; -- goes to execute stage. High enables write/read to scratchpad. = NOT pc_cont_counting
    wr_reg : out std_logic;    
    Dout : out std_logic_vector((DATA_WIDTH-1) downto 0);
    reg_addr : out std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
    
    -- from fetch 
    in_RetI : in std_logic;    
    in_ret_addr : in std_logic_vector((ADDRESS_WIDTH-1) downto 0);    
    en_intrpt : in std_logic_vector((INTRPT_BIT_WIDTH-1) downto 0);    
    -- to fetch        
    store_addr : out std_logic;
    out_jump_addr : out std_logic_vector((ADDRESS_WIDTH-1) downto 0);
    pc_cont_counting : out std_logic;
    pc_cont_processing : out std_logic
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
  constant STABILIZATION_DELAY : integer := 12;
  signal sig_processor_stabilized_state : std_logic;  -- for stabilization of processor after interrupt has occured ( processor has written all pipelined instructions). 0 is stable 
  signal sig_processor_stabilized_next_state : std_logic;     
  signal sig_priority_handler_stabilized : std_logic; -- the priority handler has reached a steady state
  signal sig_Din_reg : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal sig_wr_reg : std_logic;
  signal sig_addr_reg : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_ret_addr : std_logic_vector((ADDRESS_WIDTH-1) downto 0);
  signal sig_wr_count : std_logic_vector((REG_ADDR_WIDTH-1) downto 0); 
  signal sig_wr_count_en : std_logic;
  signal sig_wr_count_ld : std_logic;
  
  -- Fetch Signal
  signal sig_pc_cont_processing : std_logic;
  
  -- to synchronize the scratchpad
  signal sig_wr_count_buffer : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_wr_count_buffer_1 : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_wr_count_buffer_2 : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_wr_count_buffer_3 : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);    
  signal sig_wrback_count_buffer : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_wrback_count_buffer_1 : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_wrback_count_buffer_2 : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  signal sig_wrback_count_buffer_3 : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);   
  
  -- priority handler state machine
  signal sig_current_intrpt : std_logic_vector(2 downto 0);
  signal sig_next_current_intrpt : std_logic_vector(2 downto 0);
  signal sig_in_intrpt : std_logic;
  signal sig_processor_stabilize_counter_en : std_logic;
  signal sig_processor_stabilize_ld : std_logic;
  signal sig_processor_stabilize_count : std_logic_vector((REG_ADDR_WIDTH-1) downto 0);
  
  -- writer state machine
  signal sig_next_writer_state : std_logic_vector(1 downto 0);
  signal sig_current_writer_state : std_logic_vector(1 downto 0);  
  
  type intrpt_addr_array is array(0 to 3) of std_logic_vector((ADDRESS_WIDTH-1) downto 0);
  signal intrpt_addr : intrpt_addr_array := (others => (others => '0'));
  
    -- store which intrpts are enabled  
  signal sig_reg_en_intrpt : std_logic_vector(4 downto 0) := (others => '0');
  
  -- buffer for returning from interrupt
  signal RetI : std_logic;
  signal RetI_Timer : std_logic_vector((REG_ADDR_WIDTH-1) downto 0) := x"0";
  
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
     ld => sig_wr_count_ld,
     Din => (others => '0'),
     Dout => sig_wr_count
  );
  
  processor_stabilization_counter : component counter
  generic map(WIDTH => 4)
  port map (
     clk => clk,
     en => sig_processor_stabilize_counter_en,
     ld => sig_processor_stabilize_ld,
     Din => (others => '0'),
     dout => sig_processor_stabilize_count
  );
 
      
  SCRATCHPAD : process (intrpt, rst, sig_wr_reg, sig_addr_reg, sig_Din_reg, in_ret_addr)
    begin
      If (rst = '1') then
        sig_ret_addr <= (others => '0');
      elsif (intrpt = '1') then
        sig_ret_addr <= in_ret_addr;
      end if;
      
  end process; 
      
  TIMERS : process (clk, rst, sig_in_intrpt)
  begin
    
    if (rst = '1') then
      sig_processor_stabilize_counter_en <= '0';
      sig_processor_stabilize_ld <= '1';
      sig_processor_stabilized_next_state <= '0'; -- 0 is stable/init
    elsif (rising_edge(clk)) then
 
      if (sig_processor_stabilized_state = '0') then -- stable
        if (intrpt = '1') then
          sig_processor_stabilized_next_state <= '1';
          sig_processor_stabilize_ld <= '0';
          sig_processor_stabilize_counter_en <= '1';
        end if;
        
      elsif (sig_processor_stabilized_state = '1') then -- unstable
        if (sig_processor_stabilize_count = STABILIZATION_DELAY) then
          sig_processor_stabilized_next_state <= '0';          
          sig_processor_stabilize_ld <= '1';
          sig_processor_stabilize_counter_en <= '0';
        end if;
      end if;

    end if;
  end process;
      
  BUFFER_WRITING : process (clk)
  begin
    if (rst = '1') then
      sig_wr_count_buffer_1 <= (others => '0');
      sig_wr_count_buffer_2 <= (others => '0');      
      sig_wr_count_buffer_3 <= (others => '0');       
      sig_wr_count_buffer <= (others => '0');
      
      sig_wrback_count_buffer_1 <= (others => '0');
      sig_wrback_count_buffer_2 <= (others => '0');      
      sig_wrback_count_buffer_3 <= (others => '0');       
      sig_wrback_count_buffer <= (others => '0');
    
    elsif (rising_edge(clk)) then
      
      if (sig_current_writer_state = "00") then
        sig_wr_count_buffer_1 <= (others => '0');
        sig_wr_count_buffer_2 <= (others => '0');      
        sig_wr_count_buffer_3 <= (others => '0');       
        sig_wr_count_buffer <= (others => '0');  
          
        sig_wrback_count_buffer_1 <= (others => '0');
        sig_wrback_count_buffer_2 <= (others => '0');      
        sig_wrback_count_buffer_3 <= (others => '0');       
        sig_wrback_count_buffer <= (others => '0'); 
      
      else
        
        sig_wr_count_buffer_1 <= sig_wr_count;
        sig_wr_count_buffer_2 <= sig_wr_count_buffer_1;      
        sig_wr_count_buffer_3 <= sig_wr_count_buffer_2;       
        sig_wr_count_buffer <= sig_wr_count_buffer_3;  
          
        sig_wrback_count_buffer <= sig_wr_count;       
      end if;
  
    end if;
  end process;
      
  -- drives the scratchpad
  WRITER : process (clk, sig_in_intrpt)
  begin
    
    if (rst = '1') then
      sig_next_writer_state <= "00";
      sig_wr_count_en <= '0';
      pc_cont_counting <= '1';
      sig_pc_cont_processing <= '1';      
      output_en_intrpt_handler <= '0';
      wr_reg <= '0';         
      RetI_Timer <= x"0";
    elsif (rising_edge(clk)) then
  
  
      -- stabilizing
      if (sig_current_writer_state = "00") then
        
        if ( (sig_current_intrpt = "01")
          or (sig_processor_stabilized_state = '1')
          or ((sig_processor_stabilized_state = '0') and (sig_processor_stabilize_count = x"E")) ) then
          
          pc_cont_counting <= '0';
          sig_pc_cont_processing <= '0';          
          output_en_intrpt_handler <= '1';
        end if;
                 
        if ( (sig_processor_stabilized_state = '0') and (sig_processor_stabilize_count = x"E") ) then -- writer to scratchpad
          sig_next_writer_state <= "01";
          sig_wr_count_en <= '1';
          sig_wr_reg <= '1';
          sig_wr_count_ld <= '0';  
        end if;
      
      -- writing from the register to the scratchpad
      elsif (sig_current_writer_state = "01") then
        if (sig_addr_reg > 14) then
          sig_next_writer_state <= "10";
          sig_wr_count_en <= '0';
          sig_wr_reg <= '0';    
          sig_wr_count_ld <= '1';                 
          if (sig_priority_handler_stabilized = '1') then
            pc_cont_counting <= '1';   
            sig_pc_cont_processing <= '1';
            output_en_intrpt_handler <= '0';                                 
          end if;
        end if;

      -- inside interrupt and not writing
      elsif (sig_current_writer_state = "10") then
      
        -- to allow remaining instructions to execute after returning from interrupt
        if ( (in_RetI = '1') and (RetI_Timer = x"0") ) then
          RetI_Timer <= RetI_Timer + 1;
          pc_cont_counting <= '0';        
          output_en_intrpt_handler <= '1';              
        elsif ( (RetI_Timer > x"0") and (RetI_Timer < 15) ) then
          RetI_Timer <= RetI_Timer + 1;
          pc_cont_counting <= '0';       
          output_en_intrpt_handler <= '1';  
        -- state transition  
        elsif (RetI_Timer > 14) then
          RetI <= '1';     
          RetI_Timer <= x"0";         
        elsif ( (sig_priority_handler_stabilized = '1') and (sig_in_intrpt = '1') ) then
          pc_cont_counting <= '1';
          sig_pc_cont_processing <= '1';           
          output_en_intrpt_handler <= '0';
          RetI <= '0';                                  
        elsif (sig_in_intrpt = '0') then
          sig_next_writer_state <= "11";
          sig_wr_count_en <= '1';
          sig_wr_count_ld <= '0'; 
          pc_cont_counting <= '0';
          sig_pc_cont_processing <= '0';          
          output_en_intrpt_handler <= '1';                
          wr_reg <= '1';       
          RetI <= '0';
        else
          RetI <= '0';                               
        end if;       

      -- returning from all interrupts back to main
      elsif (sig_current_writer_state = "11") then
        if (sig_addr_reg > 14) then
          sig_next_writer_state <= "00";
          sig_wr_count_en <= '0';
          sig_wr_count_ld <='1';  
          pc_cont_counting <= '1';
          sig_pc_cont_processing <= '1';          
          output_en_intrpt_handler <= '0';             
          wr_reg <= '0';               
        end if;
  
      end if;
    
    
    end if;
    
  end process;
 
  -- drives the output signal that stores the interrupt address in the PC
  SET_PC_ADDR : process (clk, sig_priority_handler_stabilized)
  variable var_pulsed : std_logic := '0';
  begin
    if (rst = '1') then
      store_addr <= '0';
      var_pulsed := '0';
    elsif (rising_edge(clk)) then
      if ( (sig_priority_handler_stabilized = '1') and (var_pulsed = '0') ) then
        store_addr <= '1';
        var_pulsed := '1';
      elsif ( (sig_priority_handler_stabilized = '1') and (var_pulsed = '1') ) then
        store_addr <= '0';
      elsif ( (sig_priority_handler_stabilized = '0') and (var_pulsed = '1') ) then
        var_pulsed := '0';
      end if;
    end if;
  end process;
 
  -- stores which intrpts are enabled
  -- stores interrupt instruction addresses
  -- feeds the Priority Handler
  STORE_INTRPT : process (clk, en_intrpt)
  begin
    if (rising_edge(clk)) then

      -- default
    
      intrpt_addr(0) <= x"7D"; -- 125
      intrpt_addr(1) <= x"96"; -- 150
      intrpt_addr(2) <= x"AF"; -- 175      
      intrpt_addr(3) <= x"c8"; -- 175      
    
    -- store which intrpts are enabled
      sig_reg_en_intrpt(0) <= en_intrpt(0);
      sig_reg_en_intrpt(1) <= en_intrpt(1);
      sig_reg_en_intrpt(2) <= en_intrpt(2);
      sig_reg_en_intrpt(3) <= en_intrpt(3);
    
    
    end if;
  end process;
  
  SYNC: process (rst, clk)
  begin
    if (rst = '1') then
      sig_current_intrpt <= "000";
      sig_current_writer_state <= "00";  
      pc_cont_processing <= sig_pc_cont_processing;
      
    elsif (clk'event) then
      pc_cont_processing <= sig_pc_cont_processing;
      sig_current_intrpt <= sig_next_current_intrpt;
      
      if (rising_edge(clk)) then
        sig_current_writer_state <= sig_next_writer_state;
        sig_processor_stabilized_state <= sig_processor_stabilized_next_state;  
        if (sig_current_writer_state = "01") then  
          reg_addr <= sig_wr_count;
          sig_addr_reg <= sig_wr_count_buffer;                    
        else
          reg_addr <= sig_wrback_count_buffer;  
          sig_addr_reg <= sig_wr_count;                            
        end if;
        sig_Din_reg <= Din;
      end if;
      
    end if;
  end process;
  
  -- controls the writer
  -- output the return address
  PRIORITY_HANDLER : process (clk, intrpt, en_intrpt, RetI, sig_ret_addr)
  begin
  
  
  if (rst = '1') then
      sig_next_current_intrpt <= "000"; 
      sig_in_intrpt <= '0';
      sig_priority_handler_stabilized <= '1';
  elsif (rising_edge(clk)) then
    -- set the output current address to the main return address.
    -- LSB is highest prority interrupt
    
    if (sig_current_intrpt = "000") then
      if (intrpt = '1') then
        sig_next_current_intrpt <= "001";                             
        out_jump_addr <= intrpt_addr(0);
        sig_in_intrpt <= '1';     
        sig_priority_handler_stabilized <= '0';
      else
        sig_priority_handler_stabilized <= '1';       
      end if;  
      
    -- first interrupt state
    elsif (sig_current_intrpt = "001") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(0) = '0') ) then
        sig_next_current_intrpt <= "010";                            
        out_jump_addr <= intrpt_addr(1); 
        sig_priority_handler_stabilized <= '0';
      else
        sig_priority_handler_stabilized <= '1';                    
      end if;  
    
    -- second interrupt state      
    elsif (sig_current_intrpt = "010") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(1) = '0') ) then
        sig_next_current_intrpt <= "011";               
        out_jump_addr <= intrpt_addr(2); 
        sig_priority_handler_stabilized <= '0';
      else
        sig_priority_handler_stabilized <= '1';                            
      end if;  
    
    -- third interrupt state    
    elsif (sig_current_intrpt = "011") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(2) = '0') ) then
        sig_next_current_intrpt <= "100";                               
        out_jump_addr <= intrpt_addr(3); 
        sig_priority_handler_stabilized <= '0';
      else
        sig_priority_handler_stabilized <= '1';                                                     
      end if;
  
    -- fourth interrupt state  
    elsif (sig_current_intrpt = "100") then
      if ( (RetI = '1') or (sig_reg_en_intrpt(3) = '0') ) then
        sig_next_current_intrpt <= "000";               
        out_jump_addr <= in_ret_addr;     
        sig_in_intrpt <= '0';       
        sig_priority_handler_stabilized <= '0';
      else
        sig_priority_handler_stabilized <= '1';                       
      end if;

    end if;

  end if;
  
  end process;
  
  
  
end architecture;
