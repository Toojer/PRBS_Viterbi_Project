library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_fifo_nbit is
--  Port ( );
end tb_fifo_nbit;

architecture Behavioral of tb_fifo_nbit is

component fifo_nbit is
generic(n:integer);
port (
    clk        : in  std_logic;
    valid_bit : in  std_logic;
    word_in    : in  std_logic_vector(0 to 30);  -- input word length 31
    data_req   : in  std_logic;
    fifo_full  : out std_logic;
    bit_out    : out std_logic;         -- bit out FIFO
    valid_data : out std_logic);        -- strobe to signal valid data output
end component;
constant n : integer := 2;
signal clk,valid_word1,valid_data1,data_request1,fifo_full: std_logic :='0';
signal word_in1, bit_out1 : std_logic_vector(0 to n-1) := (others =>'0');
signal word1 : unsigned(0 to n-1) := (others =>'0');

begin

 fifo_N_BIT: entity work.fifo_nbit
  generic map ( n => n)
  port map (
    clk => clk,
    valid_bit  => valid_word1,
    data_req   => data_request1,
    word_in    => word_in1,
    fifo_full  => fifo_full,
    bit_out    => bit_out1,
    valid_data => valid_data1);

process
begin
  wait for 1 ns;
  clk <= not clk;
end process;

process
begin
  wait for 10 ns;
  --word1       <=  not word1;
  word1 <= word1 + 1;
  word_in1    <= std_logic_vector(word1);
  valid_word1 <= '1';
  wait for 20 ns;
  valid_word1 <= '0';
  
end process;

process
begin
  wait for 20 ns;
  data_request1 <= '0';
  wait for 10 ns; 
  data_request1 <= '1';
end process;

end Behavioral;
