library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity main_memory is 
  
  port(
    
        clk: in std_logic;
        
        dirty_bit_A, dirty_bit_B: in std_logic; --Enables overwriting the value of the input memory address
        request_A, request_B: in std_logic; --Used to request an address and value from Main Memory to Data Memory
        
        overwrite_address_A, overwrite_address_B: in std_logic_vector(7 downto 0); --Memory address being overwritten
        overwrite_value_A, overwrite_value_B: in std_logic_vector(7 downto 0); --Value to overwrite former value at overwrite_address
        
        requested_address_A, requested_address_B: in std_logic_vector(7 downto 0); --Address being requested by Data Memory to Main Memory
        
        request_response_value_A, request_response_value_B: out std_logic_vector(7 downto 0); --Value outputted when requested by Data Memory
        request_response_address_A, request_response_address_B: out std_logic_vector(7 downto 0); --Memory address outputted when requested by Data Memory
        request_response_enable_A, request_response_enable_B: out std_logic; --Indicates the requested address and its associated value are being outputted
        
        correct_value_A, correct_value_B: out std_logic_vector(7 downto 0); --Value outputted to other Data Memory to keep consistency
        correct_address_A, correct_address_B: out std_logic_vector(7 downto 0); --Memory Address associated with correct_value
        correct_enable_A, correct_enable_B: out std_logic); --Indicates a change has been made to Main Memory and the address/value need to be checked in Data Memory
        
        
        
        
end main_memory;

architecture behavior of main_memory is
type mem is array(255 downto 0) of std_logic_vector(7 downto 0);
signal mem1_1 : mem; --Needs to be initialized

  
begin
        
  memory: process(clk)        
  begin
  
  if(rising_edge(clk)) then
    
    correct_enable_A <= '0'; --Reset output enables
    correct_enable_B <= '0';
    request_response_enable_A <= '0';
    request_response_enable_B <= '0';
  
    if(dirty_bit_A = '1') then --A value in Data Memory A has been changed. The value in Main Memory must be changed.
      
      mem1_1(conv_integer(overwrite_address_A)) <= overwrite_value_A; --Change the value in Main Memory
      correct_value_B <= overwrite_value_A; --Output the new value to Data Memory B for a consistency check
      correct_address_B <= overwrite_address_A; --Output the new value's address to Data Memory B for a consistency check
      correct_enable_B <= '1'; --Indicate to Data Memory B that a change has occurred to Main Memory at correct_address_B and, if it has that address, overwrite the value for that address with correct_value_B
      
    end if;
    
    if(dirty_bit_B = '1') then --Same as above, but from Data Memory B to Data Memory A
      
      mem1_1(conv_integer(overwrite_address_B)) <= overwrite_value_B;
      correct_value_A <= overwrite_value_B;
      correct_address_A <= overwrite_address_B;
      correct_enable_A <= '1';
      
    end if;
    
    if(request_A = '1') then --Data Memory A is requesting an address and its value from Main Memory
    
      request_response_value_A <= mem1_1(conv_integer(requested_address_A)); --Return the requested value to Data Memory A
      request_response_address_A <= requested_address_A; --Return the requested address to Data Memory A
      request_response_enable_A <= '1'; --Indicate to Data Memory A that the requested information is being outputted
      
    end if;
    
    if(request_B = '1') then --Same as above, but for Data Memory B
    
      request_response_value_B <= mem1_1(conv_integer(requested_address_B));
      request_response_address_B <= requested_address_B;
      request_response_enable_B <= '1';
      
    end if;
    
  end if;
  
  end process;
        
end behavior;


