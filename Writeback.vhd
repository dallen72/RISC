
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.ALL;


entity Writeback is
  generic (ADDRESS_WIDTH : integer := 8; DATA_WIDTH : integer := 8);
  port(
    rst : in std_logic;
    clk : in std_logic;
    clk_stage : in std_logic;
    Rx : in std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);
    Ry : in std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);
    opcode : in std_logic_vector(DATA_WIDTH-1 downto 0);    
    mem_addr : in std_logic_vector(ADDRESS_WIDTH-1 downto 0); -- from execute
    ALU_output : in std_logic_vector(DATA_WIDTH-1 downto 0); -- from execute
    mem_wr_en : in std_logic; -- comes from decode, through execute to writeback
    mem_rd_en : in std_logic;
    reg_file_Din_sel : in std_logic; -- comes from decode, through execute to writeback
    X : in std_logic_vector(7 downto 0);
    Y : in std_logic_vector(7 downto 0);   
    reg_file_Din : out std_logic_vector(DATA_WIDTH-1 downto 0);
    reg_file_wr_addr : out std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);
    branch_en : out std_logic
  );
end entity;


------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.ALL;


Entity MEMORY is
generic (ADDRESS_WIDTH : integer := 8; WIDTH : integer := 8); -- number of address and data bits
port (
  clk : in std_logic;
  ADDR: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
  DIN: in std_logic_vector (WIDTH-1 downto 0); -- write data
  WR: in STD_LOGIC;  -- active high write enable
  rd : in std_logic;
  
  
  correct_value: in std_logic_vector(WIDTH-1 downto 0);---------------------------------------------------------------------Value obtained from Main Memory when other processor made a change to memory
  correct_address: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);------------------------------------------------------------Address associated with correct_value
  correct_enable: in std_logic;----------------------------------------------------------------------------------------------Allows Main Memory to overwrite an address in Data Memory
  
  request_value : in std_logic_vector(WIDTH-1 downto 0); ---------------------------------------------------------------------Value obtained from Main Memory upon request from Data Memory
  request_address: in std_logic_vector(ADDRESS_WIDTH-1 downto 0); ------------------------------------------------------------Address associated with request_value
  
  DOUT: out std_logic_vector (WIDTH-1 downto 0) := (others => '0'); -- read data
  
  MM_ADDRESS: out std_logic_vector (ADDRESS_WIDTH-1 downto 0);-------------------------------------------------------------- Address of modified value sent to Main Memory
  MM_VALUE: out std_logic_vector (WIDTH-1 downto 0);------------------------------------------------------------------------- Value associated with MM_ADDRESS
  MM_DB: out std_logic--------------------------------------------------------------------------------------------------------- Indicates to Main Memory a Dirty Bit has been found
  );
end MEMORY;


Architecture behav of MEMORY is

Type memory is ARRAY (0 to (2**(ADDRESS_WIDTH-3))-1) of STD_LOGIC_VECTOR (WIDTH-1 downto 0);
Signal sig_mem : memory := (others => (others => '0'));
signal sig_pulse_wr_en : std_logic;

Type dirty_bits is ARRAY (0 to (2**(ADDRESS_WIDTH-3))-1) of STD_LOGIC;-----------------------------------------------------------
signal sig_db : dirty_bits := (others => '0');-------------------------------------------------------------------------------Array of dirty bits to accompany addresses in Data Memory

Type addr_array is ARRAY (0 to (2**(ADDRESS_WIDTH-3))-1) of STD_LOGIC_VECTOR (WIDTH-1 downto 0); ------------------------------Array of addresses in Data Memory
signal add_arr : addr_array := ("00000000", "00000001", "00000010", "00000011", "00000100", "00000101", "00000110", "00000111",
                                "00001000", "00001001", "00001010", "00001011", "00001100", "00001101", "00001110", "00001111",
                                "00010000", "00010001", "00010010", "00010011", "00010011", "00010100", "00010100", "00010101",
                                "00010110", "00010111", "00011000", "00011001", "00011010", "00011011", "00011100", "00011101");
signal data_mem_ptr : integer := 0; --------------------------------------------------------------------------------------------Pointer used to select which address to overwrite in Data Memory when a new address is requested from Main Memory

begin
      
  WR_PULSE: process (clk)
  variable var_pulse_written : std_logic;
  begin
    
    if (WR = '0') then
      var_pulse_written := '0';
    elsif (var_pulse_written = '1') then
      sig_pulse_wr_en <= '0';
    else
      sig_pulse_wr_en <= '1';
      var_pulse_written := '1';
    end if;
  end process;
      
  SYNC: process (clk, WR, rd)
    variable need_request : std_logic;--------------------------------------------------------------------------------Used to indicate when a request is to be made
    
    begin
    
    need_request := '1';----------------------------------------------------------------------------------------------------Reset need_request
    MM_DB <= '0';-----------------------------------------------------------------------------------------------------------Reset MM_DB
    
    if (falling_edge(clk)) then
      for I in 0 to ((2**(ADDRESS_WIDTH-3))-1) loop
        if ((unsigned(add_arr(I)) = unsigned(ADDR))) then ------------------------------------------------------------------If the input ADDR matches any address in Data Memory, a request to Main Memory does not need to be made
          need_request := '0';
        end if;
      end loop;
      
      if (need_request = '1') then-------------------------------------------------------------------------------If a request is made...
        add_arr(data_mem_ptr) <= request_address;---------------------------------------------------------------Pointed to address is overwritten by address obtained from Main Memory
        sig_mem(data_mem_ptr) <= request_value;-----------------------------------------------------------------Pointed to value is overwritten by value obtained from Main Memory
        data_mem_ptr <= data_mem_ptr + 1;-----------------------------------------------------------------------Move pointer to next array location
        if (data_mem_ptr = 32) then----------------------------------------------------------------------------If pointed exceeds maximum array location...
          data_mem_ptr <= 0;------------------------------------------------------------------------------------Reset pointer to 0
        end if;
      end if;
    end if;
    
    if (correct_enable = '1') then------------------------------------------------------------------------------------------If a change has been made to Main Memory by the other processor...
      for I in 0 to ((2**(ADDRESS_WIDTH-3))-1) loop
        if (unsigned(add_arr(I)) = unsigned(correct_address)) then
          sig_mem(I) <= correct_value;--------------------------------------------------------------------------------------If the address for the changed value is in Data Memory, change to the new value
        end if;
      end loop;
    end if;----------------------------------------------------------------------------------------------------------------
    
    if (sig_pulse_wr_en = '1') then
      for I in 0 to ((2**(ADDRESS_WIDTH-3))-1) loop
        if (unsigned(add_arr(I)) = unsigned(ADDR)) then
          sig_mem(I) <= DIN;
          sig_db(I) <= '1';-------------------------------------------------------------------------------------------The dirty bit for the address goes high whenever the value in the address has been written to
        end if;
      end loop;
    end if;
    
    if ( (rising_edge(clk)) and (rd = '1') ) then
      for I in 0 to ((2**(ADDRESS_WIDTH-3))-1) loop
        if (unsigned(add_arr(I)) = unsigned(ADDR)) then
          DOUT <= sig_mem(I);
        end if;
      end loop;
    end if;

  for I in 0 to ((2**(ADDRESS_WIDTH-3))-1) loop----------------------------------------------------------------------
    if (sig_db(I) = '1') then -------------------------------------------------------------------------------------If a dirty bit is high...
       MM_ADDRESS <= add_arr(I);-----------------------------------------------------------------------------------Output the address to Main Memory
       MM_VALUE <= sig_mem(I);-------------------------------------------------------------------------------------Output the value to Main Memory
       sig_db(I) <= '0';------------------------------------------------------------------------------------------Reset the dirty bit
       MM_DB <= '1';-----------------------------------------------------------------------------------------------Send a flag to Main Memory indicating a dirty bit has been found
    end if;---------------------------------------------------------------------------------------------------------------
  end loop;-----------------------------------------------------------------------------------------------------------

  

  end process;
end behav;
------------------------------------------------------------------------------


architecture behav of Writeback is
  signal sig_mem_Din : std_logic_vector(7 downto 0) := (others => '0');
  signal sig_mem_Dout : std_logic_vector(7 downto 0);
  signal sig_mem_wr_en : std_logic := '0';
  signal sig_indirect_Din_X : std_logic_vector(7 downto 0); -- to delay X and Y for indirect instructions
  signal sig_indirect_Din_Y : std_logic_vector(7 downto 0);
  signal sig_branch_en : std_logic := '0';
  signal correct_value: std_logic_vector(7 downto 0);-----------------------------------------------------------------------------
  signal correct_address: std_logic_vector(7 downto 0);-------------------------------------------------------------------------
  signal correct_enable: std_logic;--------------------------------------------------------------------------------------------------------
  signal request_value : std_logic_vector(7 downto 0);
  signal request_address: std_logic_vector(7 downto 0);
  signal request_enable: std_logic;
  signal MM_ADDRESS: std_logic_vector(7 downto 0);---------------------------------------------------------------------------------------
  signal MM_VALUE: std_logic_vector(7 downto 0);------------------------------------------------------------------------------------
  signal MM_DB: std_logic;
  
  
begin
  

  mem1 : entity work.MEMORY
    generic map(ADDRESS_WIDTH => ADDRESS_WIDTH, WIDTH => DATA_WIDTH)
    port map(
      clk => clk,
      ADDR => mem_addr,
      DIN => sig_mem_din,
      WR => sig_mem_wr_en,
      rd => mem_rd_en,
      
      correct_value => correct_value,--------------------------------------------------------------------------------------------
      correct_address => correct_address,--------------------------------------------------------------------------------
      correct_enable => correct_enable,--------------------------------------------------------------------------
      
      request_value => request_value,
      request_address => request_address,
      
      DOUT => sig_mem_dout,
      
      MM_ADDRESS => MM_ADDRESS,---------------------------------------------------------------------------
      MM_VALUE => MM_VALUE,-------------------------------------------------------------------------------------------
      MM_DB => MM_DB------------------------------------------------------------------------------------------------------------
      
      
    );
    
    
  SYNC: process(clk_stage, clk)
  begin
    if (rising_edge(clk)) then
      if ( (opcode(7 downto 4) = x"D") and (X = x"00") ) then
        sig_branch_en <= '1';
      elsif ( (opcode(7 downto 4) = x"E") and (X /= x"00") ) then
        sig_branch_en <= '1';
      else
        sig_branch_en <= '0';
      end if;
      
      branch_en <= sig_branch_en;
      
    end if;
    
    if (rising_edge(clk_stage)) then
      sig_indirect_Din_X <= X;
      sig_indirect_Din_Y <= Y;
    end if;
  end process;
    
  MUXES : process (clk, rst)
  begin

    if (clk'event and clk = '1') then
      
      sig_mem_wr_en <= mem_wr_en;
      
      -- Din for memory
      if (opcode /= x"00") then
        if (opcode(7 downto 4) = x"8") then -- LD indirect
        elsif (opcode(7 downto 4) = x"9") then -- ST indirect
          sig_mem_Din <= sig_indirect_Din_Y;
        elsif (opcode(7 downto 4) = x"A") then -- LD Reg     
        elsif (opcode(7 downto 4) = x"B") then -- ST Reg
          sig_mem_Din <= sig_indirect_Din_X;        
        end if;
      end if;    
      
      
      
      if (rst = '1') then
        reg_file_Din <= (others => '0');
        reg_file_wr_addr <= (others => '0');
      elsif (opcode /= x"00") then
        
        if ( (opcode = x"56") -- Clear
          or (opcode = x"57") -- Set
          or (opcode = x"5F") ) then-- Set if less than
          
          reg_file_wr_addr <= ALU_output(3 downto 0);
          
        elsif (opcode = x"58") then -- move
          reg_file_wr_addr <= Ry;
        else
          reg_file_wr_addr <= Rx; -- all other instructions             
        end if;
      end if;
    
      -- reg file Din
      if (reg_file_Din_sel = '1') then
        reg_file_Din <= sig_mem_dout;
      else
        reg_file_Din <= ALU_output;
      end if;        
    
    end if;
    
  end process;

end behav;
