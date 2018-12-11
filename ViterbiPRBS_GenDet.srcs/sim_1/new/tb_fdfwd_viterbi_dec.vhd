library IEEE;
library unisim;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use unisim.vcomponents.all;
  
 entity tb_fdfwd_viterbi_dec is
--  Port ( );
end tb_fdfwd_viterbi_dec;

 architecture Behavioral of tb_fdfwd_viterbi_dec is


 
 component word_feeder is
   port (
     clk        : in  std_logic;
     word_in    : in  std_logic_vector(0 to 30);  -- input word length 31
     bit_out    : out std_logic;         -- bit out FIFO
     valid_data : out std_logic);        -- strobe to signal valid data output
 end component word_feeder;
 
 component prbs_gen is
     generic (
       n       : integer);                     -- size of taps
     port(
       clk     : in std_logic;                     
       reset   : in std_logic;              -- resets
       gen_data: in std_logic;              --tells PRBS to start generating
     --  enc_gen_data: in std_logic;  ----******added in after the fact******
       gen_err : in std_logic;              -- high signal will generate 1 error
       taps    : in std_logic_vector(0 to n);  -- taps vector
       data_valid_out : out std_logic;        -- used as flag to signal valid data generating
       bit_out : out std_logic);             -- bit out when generating data
   end component prbs_gen;
   
   component prbs_det is
      generic (
        n       : integer);                     -- size of taps
      port(
        clk     : in std_logic;                     
        reset   : in std_logic;              -- resets
        valid_data: in std_logic;            -- used to tell when to start detecting
        bit_in  : in std_logic;              -- input bit when detecting
        taps    : in std_logic_vector(0 to n);  -- taps vector
        lock    : out std_logic;              -- tells when the prbs loop is locked
        sync    : out std_logic;              -- confirms sync
        errors  : out integer);                -- shows error amount
   end component prbs_det;
   
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
      ready       : out  std_logic);  -- strobe to signal word decoded,  ready for input.
  end component fdfwd_viterbi_dec;
  constant word_size : integer := 31;--13;   -- size of the word sent
  constant m : integer := 5;            -- memory register size
  --constant prbs_word : std_logic_vector(0 to 31) :="10011110111001111011101110011100"; --u = 110101101010110
  --"10111001011110110010011100";  -- prbs word for u=101110100110 
  signal clk : std_logic := '0';
  signal gen_poly1 : std_logic_vector(0 to m-1):="11111";--"11" ;--3 
  signal gen_poly2 : std_logic_vector(0 to m-1):="10001";--"01" ;--1
  signal bit_in : std_logic := '1';     -- bit input to encoder
  signal decoder_rdy : std_logic := '0';  -- generate data strobe
  signal encoded_bits : std_logic_vector(0 to 1) := "10";  -- encoded bits into decoder
  signal enc_valid_data : std_logic := '0';  -- encoder valid data strobe
  signal word_start : std_logic := '0';  -- word has started strobe
  signal encoder_rdy : std_logic := '0';  -- encoder's ready strobe
  signal decoded_word : std_logic_vector(0 to word_size-1):=(others => '0');  -- decoded word
  signal generate_err : std_logic := '0';  -- prbs generate error
  signal prbs_taps : std_logic_vector(4 downto 0) := "00101";  -- prbs taps 1+x^3+x^5
  signal prbs_valid_data : std_logic := '0';
  signal reset : std_logic := '0';
  signal prbs_lock,prbs_sync : std_logic :='0';
  signal enc_dec_rdy,prbsgen_dec_rdy1 : std_logic := '1';
  signal fifo_val_data : std_logic := '0';
  signal fifo_bit_out : std_logic := '0';
  signal prbs_errors : std_logic_vector(15 downto 0) := (others => '0');
 -- signal clk1:std_logic :='0';
  
    
  
begin
--   bufr_clk: bufr
--      generic map (
--        BUFR_DIVIDE => "1",
--        SIM_DEVICE  => "7SERIES"
--      )
--      port map(
--          O   => clk1,
--          CE  => '0',
--          CLR => '0',
--          I   => clk);        

   prbs_generate: entity work.prbs_gen
      generic map (
         n => 5)
      port map (
        clk            => clk,
        reset          => reset,
        gen_data       => enc_dec_rdy,
--        enc_gen_data   => prbsgen_dec_rdy1,
        gen_err        => generate_err,
        taps           => prbs_taps,
        data_valid_out => prbs_valid_data,
        bit_out        => bit_in);
    
   vit_encoder : entity work.fdfwd_conv_enc
     generic map (
       m => m,
       word_sz => word_size)
     port map (
       clk        => clk,
       gen_poly1  => gen_poly1,
       gen_poly2  => gen_poly2,
       bit_in     => bit_in,
       gen_data   => prbsgen_dec_rdy1,
       bits_out   => encoded_bits,
       valid_data => enc_valid_data,
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
      valid_data  => enc_valid_data,
      word_start  => word_start,
      bits_in     => encoded_bits,
      ml_word_out => decoded_word,
      ready       => decoder_rdy);
      
   fifo: entity work.word_feeder
     port map (
       clk        => clk,
       word_in    => decoded_word,
       bit_out    => fifo_bit_out,
       valid_data => fifo_val_data);
       
   prbs_detect: entity work.prbs_det
     generic map (
       n => 5)                       -- taps size
     port map (
       clk        => clk,
       reset      => reset,
       valid_data => fifo_val_data,
       bit_in     => fifo_bit_out,
       taps       => prbs_taps,
       lock       => prbs_lock,
       sync       => prbs_sync,
       errors     => prbs_errors);
   
data: process
begin  -- process data
 
 wait for 1 ns;
 if clk='1' then
  prbsgen_dec_rdy1 <= prbs_valid_data and decoder_rdy;
  enc_dec_rdy     <= encoder_rdy and decoder_rdy;
 end if;
  clk <= not clk;
end process data;

errors: process
begin
  wait for 1ns;
  if (clk='1' and prbs_sync = '1') then
    generate_err <= not generate_err;
  end if; 
end process;
 
  
 end Behavioral;
