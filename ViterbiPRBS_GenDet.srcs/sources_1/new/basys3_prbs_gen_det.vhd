library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity basys3_prbs_gen_det is
  port (
    clk      : in  std_logic;                       -- input clock 100MHz
    reset    : in  std_logic;                       -- reset
    gen_data : in  std_logic;                       -- switched flipped to generate data
    gen_error : in std_logic;                       -- generate error for PRBS sequence
    prbs_bit_in : in std_logic;                     -- input from PRBS Generator
    valid_data_in : in std_logic;                   -- To PRBS_det flag to start tracking data
    valid_data_out: out std_logic;                  -- flag from PRBS_gen data is valid
    prbs_bit_out  : out std_logic;                  -- bit out from prbs generator
    digit    : out std_logic_vector(6 downto 0);    -- digit displayed on 7 segment display
    anode_en : out std_logic_vector(3 downto 0);   -- anode enabled for 7 segment display
    lock     : out std_logic;                       -- lock prbs
    sync     : out std_logic);                       -- sync
end basys3_prbs_gen_det;

architecture Behavioral of basys3_prbs_gen_det is
  --signal taps_vector : std_logic_vector(0 to 15) := "0000000000101101";  -- 1 + x^11 + x^13 + x^14 + x^16
  signal taps_vector : std_logic_vector(4 downto 0) := "00101";  -- 1+x^3+x^5
  signal prbs_bit : std_logic := '0';   -- prbs gen output bit
  signal prbs_errors : std_logic_vector(15 downto 0) := (others =>'0');    -- prbs errors count
begin

  PRBS_Gen : entity work.prbs_gen generic map (
    n => 5)
    port map (
    clk            => clk,
    reset          => reset,
    gen_data       => gen_data,
    gen_err        => gen_error,
    taps           => taps_vector,
    data_valid_out => valid_data_out,
    bit_out        => prbs_bit_out);

  PRBS_Det :  entity work.prbs_det generic map (
    n => 5)
    port map (
    clk        => clk,
    reset      => reset,
    valid_data => valid_data_in,
    bit_in     => prbs_bit_in,
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
  
end architecture Behavioral;

