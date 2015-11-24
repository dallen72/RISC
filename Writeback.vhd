
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.ALL;


entity Writeback is
  generic (ADDRESS_WIDTH : integer := 8; DATA_WIDTH : integer := 8);
  port(
    rst : in std_logic;
    clk : in std_logic;
    Rx : in std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);
    Ry : in std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0);
    opcode : in std_logic_vector(DATA_WIDTH-1 downto 0);    
    mem_addr : in std_logic_vector(ADDRESS_WIDTH-1 downto 0); -- from execute
    ALU_output : in std_logic_vector(DATA_WIDTH-1 downto 0); -- from execute
    mem_wr_en : in std_logic; -- comes from decode, through execute to writeback
    reg_file_Din_sel : in std_logic; -- comes from decode, through execute to writeback
    reg_file_Din : out std_logic_vector(DATA_WIDTH-1 downto 0);
    reg_file_wr_addr : out std_logic_vector((ADDRESS_WIDTH/2)-1 downto 0)      
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
ADDR: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
DIN: in std_logic_vector (WIDTH-1 downto 0); -- write data
DOUT: out std_logic_vector (WIDTH-1 downto 0) := (others => '0'); -- read data
WR: in STD_LOGIC) ; -- active high write enable
end MEMORY;


Architecture behav of MEMORY is

Type memory is ARRAY (0 to (2**ADDRESS_WIDTH)-1) of STD_LOGIC_VECTOR (WIDTH-1 downto 0);
Signal sig_mem : memory := (others => (others => '0'));

begin
      
  process(WR, ADDR)
  begin
    if (WR = '1') then
    sig_mem(to_integer(unsigned(ADDR))) <= DIN;
    end if;
    DOUT <= sig_mem(to_integer(unsigned(ADDR)));

  end process;
end behav;

------------------------------------------------------------------------------


architecture behav of Writeback is
  signal sig_mem_dout : std_logic_vector(7 downto 0);
begin
  

  mem1 : entity work.MEMORY
    generic map(ADDRESS_WIDTH => ADDRESS_WIDTH, WIDTH => DATA_WIDTH)
    port map(
      ADDR => mem_addr,
      DIN => ALU_output,
      DOUT => sig_mem_dout,
      WR => mem_wr_en
    );
    
    
    
  SYNC : process (clk, rst)
  begin

    if (clk'event and clk = '1') then
      
      if (rst = '1') then
        reg_file_Din <= (others => '0');
        reg_file_wr_addr <= (others => '0');
      elsif ( reg_file_Din_sel = '1' ) then
        reg_file_Din <= sig_mem_dout;
        reg_file_wr_addr <= ALU_output(3 downto 0);
      else
        if (opcode = "01011000") then
          reg_file_wr_addr <= Ry;
        else
          reg_file_wr_addr <= Rx;
        end if;
        
        reg_file_Din <= ALU_output;
      end if;
    
    end if;
    
  end process;

end behav;
