	library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
  
 entity tb_fdfwd_viterbi_dec is
--  Port ( );
end tb_fdfwd_viterbi_dec;
 architecture Behavioral of tb_fdfwd_viterbi_dec is
   component fdfwd_conv_enc is
    generic (
      m       : integer;
      word_sz : integer );                  -- generator polynomial size
    port (
      clk        : in std_logic;         -- clock signal
      gen_poly1  : in  std_logic_vector(0 to m-1); -- generator polynomials for encoder
      gen_poly2  : in std_logic_vector(0 to m-1);
      bit_in     : in  std_logic;        -- input bit from PRBS Generator
      gen_data   : in  std_logic;          -- generate data flag from PRBS generator
      bits_out   : out std_logic_vector(0 to 1); -- output bits for 1/2 rate encoder
      valid_data : out std_logic;       -- output data valid flag
      word_start : out std_logic;
      ready      : out std_logic);
  end component fdfwd_conv_enc;
    
  component fdfwd_viterbi_dec is
    generic (
      m       : integer;                -- memory size
      word_sz : integer);               -- word size
    port (
      clk         : in  std_logic;      -- clock
      gen_poly1   : in  std_logic_vector(0 to m-1);     -- generator polynomial
      gen_poly2   : in  std_logic_vector(0 to m-1);     -- generator polynomial
      valid_data  : in  std_logic;      -- strobe to signal valid data being received
      word_start  : in  std_logic;      -- strobe to signal word is starting
      bits_in     : in  std_logic_vector(0 to 1);  -- bits in from viterbi encoder
      ml_word_out : out std_logic_vector(0 to word_sz);  -- word output after trellis completed
      ready       : in  std_logic);  -- strobe to signal word decoded,  ready for input.
  end component fdfwd_viterbi_dec;
   constant word_size : integer := 12;--13;   -- size of the word sent
  constant m : integer := 2;            -- memory register size
  --constant prbs_word : std_logic_vector(0 to 31) :="10011110111001111011101110011100"; --u = 110101101010110
  --"10111001011110110010011100";  -- prbs word for u=101110100110 
  signal clk : std_logic := '0';
  signal gen_poly1 : std_logic_vector(0 to m-1):="11" ;--3 
  signal gen_poly2 : std_logic_vector(0 to m-1):="01" ;--1
  signal bit_in : std_logic := '1';     -- bit input to encoder
  signal generate_data : std_logic := '0';  -- generate data strobe
  signal encoded_bits : std_logic_vector(0 to 1) := "10";  -- encoded bits into decoder
  signal valid_data : std_logic := '0';  -- valid data strobe
  signal word_start,word_start_r : std_logic := '0';  -- word has started strobe
  signal encoder_rdy : std_logic := '0';  -- encoder's ready strobe
  signal decoded_word : std_logic_vector(0 to word_size-1):=(others => '0');  -- decoded word
begin
    vit_encoder : entity work.fdfwd_conv_enc
     generic map (
       m => m,
       word_sz => word_size)
     port map (
       clk        => clk,
       gen_poly1  => gen_poly1,
       gen_poly2  => gen_poly2,
       bit_in     => bit_in,
       gen_data   => generate_data,
       bits_out   => encoded_bits,
       valid_data => valid_data,
       word_start => word_start,
       ready      => encoder_rdy);
   vit_decoder : entity work.fdfwd_viterbi_dec
    generic map (
      m      => m,
      wrd_sz => word_size)
    port map (
      clk         => clk,
      gen_poly1   => gen_poly1,
      gen_poly2   => gen_poly2,
      valid_data  => valid_data,
      word_start  => word_start,
      bits_in     => encoded_bits,
      ml_word_out => decoded_word,
      ready       => generate_data);
   
data: process
  variable i : integer := 0;  -- count
  variable prbs_word : unsigned(0 to 11) :="101110100110"; 
begin  -- process data
 
 wait for 1 ns;
 if i >= word_size then
   i         := 1;
 end if; 
 
  if generate_data = '1' and encoder_rdy='1' then
   if clk='1' then
     if word_start = '1' and word_start_r='0' then
       i := 1;
     end if;
     bit_in <= prbs_word(i);
     i      := i+1;
   end if;
  end if;
 clk <= not clk;
 word_start_r <= word_start;
end process data;
 
 
  
 end Behavioral;