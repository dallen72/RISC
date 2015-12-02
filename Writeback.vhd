
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
    branch_en : out std_logic;
    RetI : out std_logic    
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
  DOUT: out std_logic_vector (WIDTH-1 downto 0) := (others => '0') -- read data
  );
end MEMORY;


Architecture behav of MEMORY is

Type memory is ARRAY (0 to (2**ADDRESS_WIDTH)-1) of STD_LOGIC_VECTOR (WIDTH-1 downto 0);
Signal sig_mem : memory := (others => (others => '0'));
signal sig_pulse_wr_en : std_logic;

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
  begin
    if (sig_pulse_wr_en = '1') then
      sig_mem(to_integer(unsigned(ADDR))) <= DIN;
    end if;
    
    if ( (rising_edge(clk)) and (rd = '1') ) then
      DOUT <= sig_mem(to_integer(unsigned(ADDR)));
    end if;

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
begin
  

  mem1 : entity work.MEMORY
    generic map(ADDRESS_WIDTH => ADDRESS_WIDTH, WIDTH => DATA_WIDTH)
    port map(
      clk => clk,
      ADDR => mem_addr,
      DIN => sig_mem_din,
      WR => sig_mem_wr_en,
      rd => mem_rd_en,
      DOUT => sig_mem_dout
    );
    
    
  SYNC: process(clk_stage, clk, opcode)
  begin
    if (rising_edge(clk)) then
      
      if (opcode(7 downto 4) = x"F") then -- tell the interrupt handler to return from interrupt
        RetI <= '1';
      else
        RetI <= '0';
      end if;
  
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
