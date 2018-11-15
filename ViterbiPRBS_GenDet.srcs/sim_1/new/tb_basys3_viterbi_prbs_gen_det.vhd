library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_basys3_viterbi_prbs_gen_det is
--  Port ( );
end tb_basys3_viterbi_prbs_gen_det;

architecture Behavioral of tb_basys3_viterbi_prbs_gen_det is

component basys3_viterbi_prbs_gen_det is
  port (
    clk      : in  std_logic;                       -- input clock 100MHz
    reset    : in  std_logic;                       -- reset
    gen_data : in  std_logic;                       -- switched flipped to generate data
    prbs_gen_error : in std_logic;                       -- generate error for PRBS sequence
    enc_gen_error  : in std_logic;
    enc_gen10_err  : in std_logic;
    enc_gen30_err  : in std_logic;
    bits_in : in std_logic_vector(0 to 1);          -- input from viterbi encoder
    valid_data_in : in std_logic;                   -- To PRBS_det flag to start tracking data
    word_start_in : in std_logic;                   -- strobe that new word started
    word_start_out: out std_logic;                  -- strobe that new word started
    valid_data_out: out std_logic;                  -- flag from viterbi enc data is valid
    bits_out  : out std_logic_vector(0 to 1);       -- bits out from viterbi encoder
    --------added Fifo_out clk_out to help with debugging ----
    fifo_out    : out std_logic; 
    fifo_valid  : out std_logic;
    enc_rdy     : out std_logic;
    dec_rdy     : out std_logic;
    prbs_val_data: out std_logic;
    prbsgen_dec_ready: out std_logic;
    enc_dec_ready : out std_logic;
    --clk_out   : out std_logic;                     
    --------------------------------------------------
    enc_err    : out std_logic;
    digit    : out std_logic_vector(6 downto 0);    -- digit displayed on 7 segment display
    anode_en : out std_logic_vector(3 downto 0);   -- anode enabled for 7 segment display
    lock     : out std_logic;                       -- lock prbs
    sync     : out std_logic);                       -- sync
end component basys3_viterbi_prbs_gen_det;

signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal gen_data : std_logic := '1';
signal gen_err: std_logic := '0';
signal bits : std_logic_vector(0 to 1) := "00";
signal vit_valid_data : std_logic := '1';
signal word_start : std_logic := '1';
signal digits : std_logic_vector(6 downto 0) := (others => '0');
signal an_en : std_logic_vector(3 downto 0) := (others => '0');
signal prbs_sync,prbs_lock : std_logic := '0';
signal enc_gen_err,enc_gen10_err,enc_gen30_err,fifo_out,fifo_valid,encod_rdy,decoder_rdy,prbs_valid_data,prbsgen_dec_rdy,enc_dec_rdy:std_logic := '0';
signal encoder_led : std_logic := '0';
begin

  basys3_viterbi_dec: entity work.basys3_viterbi_prbs_gen_det
    port map (
      clk            => clk,
      reset          => reset,
      gen_data       => gen_data,
      prbs_gen_error => gen_err,
      enc_gen_err    => enc_gen_err,
      enc_gen10_err  => enc_gen10_err,
      enc_gen30_err  => enc_gen30_err,
      bits_in        => bits,
      valid_data_in  => vit_valid_data,
      word_start_in  => word_start,
      word_start_out => word_start,
      valid_data_out => vit_valid_data,
      bits_out       => bits,
      --------added Fifo_out clk_out to help with debugging ----
      fifo_out          => fifo_out,
      fifo_valid        => fifo_valid,
      enc_rdy           => encod_rdy,   
      dec_rdy           => decoder_rdy,
      prbs_val_data     => prbs_valid_data,
      prbsgen_dec_ready => prbsgen_dec_rdy,
      enc_dec_ready     => enc_dec_rdy,       
       --------------------------------------------------
      encoder_err        => encoder_led,
      digit          => digits,
      anode_en       => an_en,
      lock           => prbs_lock,
      sync           => prbs_sync);

process
begin
    wait for 1 ns;
    clk <= not clk;    
end process;
process
begin
  enc_gen_err <= '1';
  wait for 1000 us;
  enc_gen_err <= '0';
  wait for 10 ns;
  
  wait for 5 ns;
  enc_gen10_err <= '1';
  wait for 1000 us;
  enc_gen10_err <= '0';
  wait for 50 ns;
  
  wait for 10 ns;
  enc_gen30_err <= '1';
  wait for 1000 us;
  enc_gen30_err <= '0';
  wait for 70 ns; 
end process;
end Behavioral;


