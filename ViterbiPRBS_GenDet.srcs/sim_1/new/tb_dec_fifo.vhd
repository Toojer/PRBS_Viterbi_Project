library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_dec_fifo is
--  Port ( );
end tb_dec_fifo;

architecture Behavioral of tb_dec_fifo is

component dec_fifo is
port (
    clk        : in  std_logic;
    valid_word : in  std_logic;
    word_in    : in  std_logic_vector(0 to 30);  -- input word length 31
    data_reg   : in  std_logic;
    bit_out    : out std_logic;         -- bit out FIFO
    valid_data : out std_logic);        -- strobe to signal valid data output
end component;

signal clk,valid_word,bit_out,valid_data,data_request : std_logic :='0';
signal word_in : unsigned(0 to 30):= (others=>'0');
signal word : unsigned(0 to 30):= (0 to 3 => '1',others=>'0');

begin

 decoder_fifo: entity work.dec_fifo
  port map (
    clk => clk,
    valid_word => valid_word,
    data_req => data_request,
    word_in => std_logic_vector(word_in),
    bit_out => bit_out,
    valid_data => valid_data);

process
begin
  wait for 1 ns;
  clk <= not clk;
end process;

process
begin
  wait for 58 ns;
  word <= word+2;
  word_in <= word;
  valid_word <= '1';
  wait for 2 ns;
  valid_word <= '0';
  
end process;

process
begin
  wait for 60 ns;
  data_request <= '0';
  wait for 3 ns; 
  data_request <= '1';
end process;

end Behavioral;
