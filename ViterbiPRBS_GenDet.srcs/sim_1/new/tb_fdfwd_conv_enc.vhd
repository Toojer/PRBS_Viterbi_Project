library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fdfwd_conv_enc is
--  Port ( );
end tb_fdfwd_conv_enc;

architecture Behavioral of tb_fdfwd_conv_enc is
 component fdfwd_conv_enc is
 generic (
    n : integer := 2);                  -- generator polynomial size
  port (
    clk        : in std_logic;         -- clock signal
    gen_poly1   : in  std_logic_vector(0 to n-1); -- generator polynomials for encoder
    gen_poly2   : in std_logic_vector(0 to n-1);
    bit_in     : in  std_logic;        -- input bit from PRBS Generator
    gen_data   : in  std_logic;          -- generate data flag from PRBS generator
    bits_out   : out std_logic_vector(0 to 1); -- output bits for 1/2 rate encoder
    valid_data : out std_logic;       -- output data valid flag
    word_start : out std_logic;
    ready      : out std_logic);
  end component fdfwd_conv_enc;
signal genpoly_1 : std_logic_vector(0 to 4) := "11111";--37   "11";--3  
signal genpoly_2 : std_logic_vector(0 to 4) := "10001";--21   "01";--1 
signal word_start,clk,gen_data,valid_data,ready : std_logic := '0';
signal bit_in : std_logic := '1';
signal bits_out : std_logic_vector(0 to 1) := "00";
signal bit_in_vector : std_logic_vector(0 to 11) := "101110100110";  -- input bit vector

begin
 
DUT: fdfwd_conv_enc generic map (n=>5) 
port map(clk=>clk,gen_poly1=>genpoly_1,gen_poly2=>genpoly_2,bit_in=>bit_in, gen_data=>gen_data,bits_out => bits_out,valid_data=>valid_data,word_start => word_start,ready=>ready);

data: process
  variable i : integer := 0;            -- count
begin  -- process data
 
 wait for 1 ns;
 if i >= bit_in_vector'length-1 then
     gen_data<='0';
 else
    if clk='0' then
        gen_data<='1';
        bit_in<=bit_in_vector(i);
        i := i+1;
    end if;
 end if;
 clk <= not clk;
 
 
end process data;

end Behavioral;
