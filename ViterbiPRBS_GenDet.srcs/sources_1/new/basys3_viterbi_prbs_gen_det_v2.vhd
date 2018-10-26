library IEEE;
library unisim;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use unisim.vcomponents.all;
  
 entity basys3_viterbi_prbs_gen_det_v2 is
   Port (
     clk      : in std_logic;
     digit    : out std_logic_vector(6 downto 0);    -- digit displayed on 7 segment display
     anode_en : out std_logic_vector(3 downto 0);   -- anode enabled for 7 segment display
     lock     : out std_logic;                       -- lock prbs
     sync     : out std_logic);
end basys3_viterbi_prbs_gen_det_v2;

 architecture Behavioral of basys3_viterbi_prbs_gen_det_v2 is

  constant word_size : integer := 31;--13;   -- size of the word sent
  constant m : integer := 2;            -- memory register size
  --constant prbs_word : std_logic_vector(0 to 31) :="10011110111001111011101110011100"; --u = 110101101010110
  --"10111001011110110010011100";  -- prbs word for u=101110100110 
  signal gen_poly1 : std_logic_vector(0 to m-1):="11" ;--3 
  signal gen_poly2 : std_logic_vector(0 to m-1):="01" ;--1
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
  signal enc_dec_rdy,prbsgen_dec_rdy : std_logic := '1';
  signal fifo_val_data : std_logic := '0';
  signal fifo_bit_out : std_logic := '0';
  signal prbs_errors : std_logic_vector(15 downto 0) := (others => '0');
  signal clk1:std_logic :='0';
  
    
  
begin
   bufr_clk: bufr
      generic map (
        BUFR_DIVIDE => "1",
        SIM_DEVICE  => "7SERIES"
      )
      port map(
          O   => clk1,
          CE  => '1',
          CLR => '0',
          I   => clk);        

   prbs_generate: entity work.prbs_gen
      generic map (
         n => 5)
      port map (
        clk            => clk1,
        reset          => reset,
        gen_data       => enc_dec_rdy,
        gen_err        => generate_err,
        taps           => prbs_taps,
        data_valid_out => prbs_valid_data,
        bit_out        => bit_in);
    
   vit_encoder : entity work.fdfwd_conv_enc
     generic map (
       m => m,
       word_sz => word_size)
     port map (
       clk        => clk1,
       gen_poly1  => gen_poly1,
       gen_poly2  => gen_poly2,
       bit_in     => bit_in,
       gen_data   => prbsgen_dec_rdy,
       bits_out   => encoded_bits,
       valid_data => enc_valid_data,
       word_start => word_start,
       ready      => encoder_rdy);
       
   vit_decoder : entity work.fdfwd_viterbi_dec
    generic map (
      m      => m,
      wrd_sz => word_size)
    port map (
      clk         => clk1,
      gen_poly1   => gen_poly1,
      gen_poly2   => gen_poly2,
      valid_data  => enc_valid_data,
      word_start  => word_start,
      bits_in     => encoded_bits,
      ml_word_out => decoded_word,
      ready       => decoder_rdy);
      
   fifo: entity work.word_feeder
     port map (
       clk        => clk1,
       word_in    => decoded_word,
       bit_out    => fifo_bit_out,
       valid_data => fifo_val_data);
       
   prbs_detect: entity work.prbs_det
     generic map (
       n => 5)                       -- taps size
     port map (
       clk        => clk1,
       reset      => reset,
       valid_data => fifo_val_data,
       bit_in     => fifo_bit_out,
       taps       => prbs_taps,
       lock       => lock,
       sync       => sync,
       errors     => prbs_errors);
    
   Seg7Disp : entity work.seven_seg_display port map (
       number   => prbs_errors,
       clk      => clk,
       reset    => reset,
       digit    => digit,
       anode_en => anode_en);
data: process (clk)
begin  -- process data
 
-- wait for 1 ns;
 if clk1='1' then
  prbsgen_dec_rdy <= prbs_valid_data and decoder_rdy;
  enc_dec_rdy     <= encoder_rdy and decoder_rdy;
 end if;
--  clk <= not clk;
end process data;

--errors: process
--begin
--  wait for 1ns;
--  if (clk='1' and prbs_sync = '1') then
--    generate_err <= not generate_err;
--  end if; 
--end process;
 
  
 end Behavioral;
