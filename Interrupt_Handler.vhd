entity interrupt_handler is
  port (
    stack_ptr : in
    intrpt_addr : out
    
  );
  
end interrupt_handler;

architecture behav of interrupt_handler is
  
  scratchpad_reg : entity work.reg_file
      port map (
        Din => Din_reg,
        Rx_addr => addr_reg,
        wr => wr_reg,
        rst => rst,
        Rx => Dout
      );
      
  -- drives the scratchpad
  WRITER : process (intrpt, ret_to_main, clk)
    variable var_count : integer := 0;
    
    
    if ( ((intrpt = '1') and (within_intrpt_routine = '0')) or (ret_to_main = '1') or (var_count /= 0) ) then
      var_count := var_count + 1
    elsif (var_count = '0') then
      end_rd_scratchpad <= '0';
      end_wr_scratchpad <= '0';
    end if;
    
    
    if (ret_to_main = '1') then
      end_rd_scratchpad <= '1';
    elsif ( (intrpt = '1') and (in_intrpt_routine = '0') ) then
      end_wr_scratchpad = '1';
    end if;
    
  end process;
  
  
  -- stores interrupt instruction addresses
  -- output the return address
  PRIORITY_HANDLER : process (en_int, sig_stack_ptr)
    if (en_intrpt(0) = '1') then
      intrpt_addr <= intrpt_addr_1;
      within_intrpt_routine = '1';
    elsif (en_intrpt(1) = '1') then
      intrpt_addr <= intrpt_addr_2;
      within_intrpt_routine = '1';
    elsif (en_intrpt(2) = '1') then
      intrpt_addr <= intrpt_addr_3;
      within_intrpt_routine = '1';
    elsif (en_intrpt(3) = '1') then
      intrpt_addr <= intrpt_addr_4;
      within_intrpt_routine = '1';
    else
      intrpt_addr <= sig_stack_ptr;
      within_intrpt_routine = '0';
  end process;
  
  
  SCRATCHPAD : process (intrpt, rst, wr_reg, addr_reg)
      If (rst = '1') then
        sig_stack_ptr <= (others => '0');
      elsif (intrpt = '1') then
        sig_stack_ptr <= stack_ptr;
      end if;
      
  end process;
  
end architecture;
