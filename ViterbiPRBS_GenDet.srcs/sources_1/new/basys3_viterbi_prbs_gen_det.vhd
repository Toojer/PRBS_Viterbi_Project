library IEEE;
library unisim;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package convEncPackage is
  type enc_info is record
    enc_bits    : std_logic_vector(0 to 1); -- half rate encoder 2 bits for every 1 input
    word_start  : std_logic;  -- indicates when a word starts
  end record enc_info;
  
  constant encInfo_defaults : enc_info :=( enc_bits   => "11",
                                             word_start => '0');
  constant fifo_size : integer := 64;
  
  type encInfo_array is array(0 to fifo_size-1) of enc_info;
    
  
end package convEncPackage; 

library IEEE;
library unisim;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use unisim.vcomponents.all;

entity basys3_viterbi_prbs_gen_det is
  port (
    clk      : in  std_logic;                       -- input clock 100MHz
    reset    : in  std_logic;                       -- reset
    gen_data : in  std_logic;                       -- switched flipped to generate data
    prbs_gen_error : in std_logic;                  -- generate error for PRBS sequence
    enc_gen_err    : in std_logic;                  -- generate error on output of conv encoder
    enc_gen10_err  : in std_logic;
    enc_gen30_err  : in std_logic;
    --enc_gen3_errors: in std_logic;
    bits_in : in std_logic_vector(0 to 1);          -- input from viterbi encoder
    valid_data_in : in std_logic;                   -- To PRBS_det flag to start tracking data
    word_start_in : in std_logic;                   -- strobe that new word started
    word_start_out: out std_logic;                  -- strobe that new word started
    valid_data_out: out std_logic;                  -- flag from viterbi enc data is valid
    bits_out  : out std_logic_vector(0 to 1);       -- bits out from viterbi encoder
    --------added to help with debugging ----
    fifo_out    : out std_logic; 
    fifo_valid  : out std_logic;
    enc_rdy     : out std_logic;
    dec_rdy     : out std_logic;
    prbs_val_data: out std_logic;
    prbsgen_dec_ready: out std_logic;
    enc_dec_ready : out std_logic;
    --clk_out       : out std_logic;
    decoded_word0  : out std_logic;
    decoded_word1  : out std_logic;
    --------------------------------------------------
    encoder_err  : out std_logic;
    digit    : out std_logic_vector(6 downto 0);    -- digit displayed on 7 segment display
    anode_en : out std_logic_vector(3 downto 0);   -- anode enabled for 7 segment display
    lock     : out std_logic;                       -- lock prbs
    sync     : out std_logic);                       -- sync
end basys3_viterbi_prbs_gen_det;

architecture Behavioral of basys3_viterbi_prbs_gen_det is
  constant word_size : integer := 31;--13;   -- size of the word sent
  constant m : integer := 5; --2;            -- memory register size
  --signal taps_vector : std_logic_vector(0 to 15) := "0000000000101101";  -- 1 + x^11 + x^13 + x^14 + x^16
  signal taps_vector : std_logic_vector(4 downto 0) := "00101";  -- 1+x^3+x^5
  signal prbs_bit : std_logic := '0';   -- prbs gen output bit
  signal prbs_errors : std_logic_vector(15 downto 0) := (others =>'0');    -- prbs errors count
  signal gen_poly1 : std_logic_vector(0 to m-1):="11111";--37 --"11" ;--3 
  signal gen_poly2 : std_logic_vector(0 to m-1):="10001";--21 --"01" ;--1
  signal bit_in : std_logic := '1';     -- bit input to encoder
  signal prbs_valid_data : std_logic := '0';
  signal enc_dec_rdy,prbsgen_dec_rdy : std_logic := '0';
  signal decoder_rdy : std_logic := '0';  -- generate data strobe
  signal encoder_rdy : std_logic := '0';  -- encoder's ready strobe
  signal decoded_word : std_logic_vector(0 to word_size-1):=(others => 'U');  -- decoded word
  signal fifo_val_data,prbs_fifo_full,prbs_fifo_full_n : std_logic := '0';
  signal fifo_bit_out : std_logic := '0';
  signal enc_valid_data,word_start1 : std_logic :='0';
  signal word_start : std_logic := '0';
  signal clk_6mhz,clk_deb,clk_deb_r,clk1: std_logic := '0';
  signal bits_out1: std_logic_vector(0 to 1):="00";
  signal clk_cnt :  unsigned(15 downto 0) := (others =>'0'); --clk debug count
  signal valid_word: std_logic := '0';
  signal prbs_bit_in ,prbs_fifo_bit,prbs_fifo_val,enc_fifo_data_val,enc_fifo_wrdsrt_val : std_logic:= '0'; --prbs output bit from fifo
  signal enc_fifo_bits : std_logic_vector(0 to 1):="00";
  signal enc_fifo_val_data,enc_fifo_wrdsrt,enc_data_fifo_full,enc_wrdstrt_fifo_full : std_logic := '0';
  signal enc_gen_data : std_logic := '0';
  signal enc_gen_error_r:std_logic := '0';
  --signal bits_out_r : std_logic_vector := "00";
  signal bits_out2  : std_logic_vector(0 to 1) := "00";
  signal word_start2: std_logic := '0';
begin


  bufr_clk: bufr
    generic map (
      BUFR_DIVIDE => "7", --6 gives ~6MHz --1 this should divide by 2 giving 50MHz clock
      SIM_DEVICE  => "7SERIES"
    )
    port map(
        O   => clk_6mhz,
        CE  => '1',
        CLR => '0',
        I   => clk);
        
 
   
  prbs_generate : entity work.prbs_gen generic map (
    n => 5)
    port map (
    clk            => clk_6mhz, --clk_6mhz_deb,
    reset          => reset,
    gen_data       => prbs_fifo_full_n,
    gen_err        => prbs_gen_error,
    taps           => taps_vector,
    data_valid_out => prbs_valid_data,
    bit_out        => bit_in);

  prbs_fifo: entity work.fifo_1bit
   port map(
     clk        => clk_6mhz,
     valid_bit  => prbs_valid_data,
     word_in    => bit_in,
     data_req   => encoder_rdy,
     fifo_full  => prbs_fifo_full,
     bit_out    => prbs_fifo_bit,
     valid_data => prbs_fifo_val);
     
  prbs_fifo_full_n <= not prbs_fifo_full;
  enc_gen_data     <= prbs_fifo_val and not(enc_data_fifo_full or enc_wrdstrt_fifo_full);
  
  vit_encoder : entity work.fdfwd_conv_enc
    generic map (
      m => m,
      word_sz => word_size)
    port map (
      clk        => clk_6mhz, 
      gen_poly1  => gen_poly1,
      gen_poly2  => gen_poly2,
      bit_in     => prbs_fifo_bit,
      gen_data   => enc_gen_data,
      bits_out   => bits_out1,  
      valid_data => enc_valid_data,
      word_start => word_start1, 
      ready      => encoder_rdy);
      
--  enc_errrors: entity work.enc_gen_errors
--    port map(
--      clk       => clk_6mhz,
--      gen_error => enc_gen_err,
--      gen_10err => enc_gen10_err,
--      gen_30err => enc_gen30_err,
--      bits_in   => bits_out1,
--      --word_start=> word_start1,
--      bits_out  => bits_out2,
--      --wrd_strt_out=>word_start2,
--      enc_err   => encoder_err);
      
  enc_fifo_data: entity work.fifo_nbit
    generic map ( n=>2 )
    port map(
      clk        => clk_6mhz,
      valid_bit  => enc_valid_data,
      word_in    => bits_out1,
      data_req   => decoder_rdy,
      fifo_full  => enc_data_fifo_full,
      bit_out    => enc_fifo_bits,
      valid_data => enc_fifo_data_val);
      
  enc_fifo_wordstart: entity work.fifo_1bit
    port map(
      clk        => clk_6mhz,
      valid_bit  => enc_valid_data,
      word_in    => word_start1,
      data_req   => decoder_rdy,
      fifo_full  => enc_wrdstrt_fifo_full,
      bit_out    => enc_fifo_wrdsrt,
      valid_data => enc_fifo_wrdsrt_val);
      
  --enc_fifo_val_data <= enc_fifo_data_val and enc_fifo_wrdsrt_val;
      
  vit_decoder : entity work.fdfwd_viterbi_dec
    generic map (
      m      => m,
      wrd_sz => word_size)
    port map (
      clk         => clk_6mhz, 
      gen_poly1   => gen_poly1,
      gen_poly2   => gen_poly2,
      valid_data  => enc_fifo_data_val,--enc_fifo_val_data,
      word_start  => enc_fifo_wrdsrt,
      bits_in     => enc_fifo_bits,
      ml_word_out => decoded_word,
      valid_word  => valid_word,
      ready       => decoder_rdy);
     
     
  decoder_fifo: entity work.dec_fifo
     port map(
        clk        => clk_6mhz,
        valid_word => valid_word,
        word_in    => decoded_word,
        data_req   => '1', --always output if there is valid data to output.
        bit_out    => fifo_bit_out,
        valid_data => fifo_val_data);  
      
  prbs_detect :  entity work.prbs_det 
    generic map (
      n => 5)
    port map (
      clk        => clk_6mhz,
      reset      => reset,
      valid_data => fifo_val_data,
      bit_in     => fifo_bit_out,
      taps       => taps_vector,
      lock       => lock,
      sync       => sync,
      errors     => prbs_errors);
    
  Seg7Disp : entity work.seven_seg_display port map (
    number   => prbs_errors, 
    clk      => clk,
    reset    => reset,
    digit    => digit,
    anode_en => anode_en);
  
  bits_out          <= enc_fifo_bits;
  fifo_out          <= fifo_bit_out;
  fifo_valid        <= fifo_val_data;
  enc_rdy           <= encoder_rdy;
  dec_rdy           <= decoder_rdy;
  prbs_val_data     <= prbs_valid_data;
  prbsgen_dec_ready <= prbsgen_dec_rdy;
  enc_dec_ready     <= valid_word;
  word_start_out    <= enc_fifo_wrdsrt;
  valid_data_out    <= enc_fifo_val_data;
  decoded_word0     <= decoded_word(7);
  decoded_word1     <= decoded_word(8);
    
end architecture Behavioral;
