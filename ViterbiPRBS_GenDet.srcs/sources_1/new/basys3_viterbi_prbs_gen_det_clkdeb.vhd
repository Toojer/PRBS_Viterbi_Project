library IEEE;
library unisim;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use unisim.vcomponents.all;

entity basys3_viterbi_prbs_gen_det_clkdeb is
  port (
    clk      : in  std_logic;                       -- input clock 100MHz
    reset    : in  std_logic;                       -- reset
    gen_data : in  std_logic;                       -- switched flipped to generate data
    gen_error : in std_logic;                       -- generate error for PRBS sequence
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
    decoded_word0  : out std_logic;
    decoded_word1  : out std_logic;
    clk_led   : out std_logic;    
    clk_btn  : in std_logic;                 
    --------------------------------------------------
    digit    : out std_logic_vector(6 downto 0);    -- digit displayed on 7 segment display
    anode_en : out std_logic_vector(3 downto 0);   -- anode enabled for 7 segment display
    lock     : out std_logic;                       -- lock prbs
    sync     : out std_logic);                       -- sync
end basys3_viterbi_prbs_gen_det_clkdeb;

architecture Behavioral of basys3_viterbi_prbs_gen_det_clkdeb is
  constant word_size : integer := 31;--13;   -- size of the word sent
  constant m : integer := 2;            -- memory register size
  --signal taps_vector : std_logic_vector(0 to 15) := "0000000000101101";  -- 1 + x^11 + x^13 + x^14 + x^16
  signal taps_vector : std_logic_vector(4 downto 0) := "00101";  -- 1+x^3+x^5
  signal prbs_bit : std_logic := '0';   -- prbs gen output bit
  signal prbs_errors : std_logic_vector(15 downto 0) := (others =>'0');    -- prbs errors count
  signal gen_poly1 : std_logic_vector(0 to m-1):="11" ;--3 
  signal gen_poly2 : std_logic_vector(0 to m-1):="01" ;--1
  signal bit_in : std_logic := '1';     -- bit input to encoder
  signal prbs_valid_data : std_logic := '0';
  signal enc_dec_rdy,prbsgen_dec_rdy : std_logic := '0';
  signal decoder_rdy : std_logic := '0';  -- generate data strobe
  signal encoder_rdy : std_logic := '0';  -- encoder's ready strobe
  signal decoded_word : std_logic_vector(0 to word_size-1):=(others => 'U');  -- decoded word
  signal fifo_val_data : std_logic := '0';
  signal fifo_bit_out : std_logic := '0';
  signal valid_data,word_start1 : std_logic :='0';
  signal word_start : std_logic := '0';
  signal clk_25mhz,clk_deb,clk_deb_r,clk1: std_logic := '0';
  signal bits_out1: std_logic_vector(0 to 1):="00";
  signal clk_cnt :  unsigned(15 downto 0) := (others =>'0'); --clk debug count
begin



debounce: entity work.debouncer port map (clk => clk, signal_in => clk_btn, signal_out => clk1); 
  
  process(clk1)
     begin
         if rising_edge(clk1) then
           clk_deb <= not clk_deb; 
           clk_led <= not clk_deb;
         end if;
  end process; 
  
  process(clk_deb)
    begin
        if rising_edge(clk_deb) then
          clk_cnt <= clk_cnt + 1;
          prbsgen_dec_rdy <= prbs_valid_data and decoder_rdy and gen_data;
          enc_dec_rdy     <= encoder_rdy and decoder_rdy;
        end if;
        
  end process;   
     
    
  prbs_generate : entity work.prbs_gen generic map (
    n => 5)
    port map (
    clk            => clk_deb,
    reset          => reset,
    gen_data       => enc_dec_rdy,
--    enc_gen_data   => valid_data,
    gen_err        => gen_error,
    taps           => taps_vector,
    data_valid_out => prbs_valid_data,
    bit_out        => bit_in);

  vit_encoder : entity work.fdfwd_conv_enc
    generic map (
      m => m,
      word_sz => word_size)
    port map (
      clk        => clk_deb,
      gen_poly1  => gen_poly1,
      gen_poly2  => gen_poly2,
      bit_in     => bit_in,
      gen_data   => prbsgen_dec_rdy,
      bits_out   => bits_out1,
      valid_data => valid_data,
      word_start => word_start1,
      ready      => encoder_rdy);
      
  vit_decoder : entity work.fdfwd_viterbi_dec
    generic map (
      m      => m,
      wrd_sz => word_size)
    port map (
      clk         => clk_deb,
      gen_poly1   => gen_poly1,
      gen_poly2   => gen_poly2,
      valid_data  => valid_data,
      word_start  => word_start1,
      bits_in     => bits_out1,
      ml_word_out => decoded_word,
      ready       => decoder_rdy);
      
   fifo: entity work.word_feeder
     port map (
       clk        => clk_deb,
       word_in    => decoded_word,
       bit_out    => fifo_bit_out,
       valid_data => fifo_val_data);
          

  prbs_detect :  entity work.prbs_det generic map (
    n => 5)
    port map (
    clk        => clk_deb,
    reset      => reset,
    valid_data => fifo_val_data,
    bit_in     => fifo_bit_out,
    taps       => taps_vector,
    lock       => lock,
    sync       => sync,
    errors     => prbs_errors);
    
  Seg7Disp : entity work.seven_seg_display port map (
    number   => std_logic_vector(clk_cnt),
    clk      => clk,
    reset    => reset,
    digit    => digit,
    anode_en => anode_en);
  
  bits_out          <= bits_out1;
  fifo_out          <= fifo_bit_out;
  fifo_valid        <= fifo_val_data;
  enc_rdy           <= encoder_rdy;
  dec_rdy           <= decoder_rdy;
  prbs_val_data     <= prbs_valid_data;
  prbsgen_dec_ready <= prbsgen_dec_rdy;
  enc_dec_ready     <= enc_dec_rdy;
  word_start_out    <= word_start1;
  valid_data_out    <= valid_data;
 -- clk_out           <= clk_deb;
  decoded_word0     <= decoded_word(0);
  decoded_word1     <= decoded_word(1);
  
    
       
     
     -- clk_out  <= clk1; 
    
end architecture Behavioral;
