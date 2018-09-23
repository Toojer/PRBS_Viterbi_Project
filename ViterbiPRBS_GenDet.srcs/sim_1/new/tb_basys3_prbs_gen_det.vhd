library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_basys3_prbs_gen_det is
--  Port ( );
end tb_basys3_prbs_gen_det;

architecture Behavioral of tb_basys3_prbs_gen_det is

--  component prbs_gen is
--    generic (
--      n       : integer);                     -- size of taps
--    port(
--      clk     : in std_logic;                     
--      reset   : in std_logic;              -- resets
--      gen_data: in std_logic;              --****tells PRBS to start generating
--      gen_err : in std_logic;              -- high signal will generate 1 error
--      taps    : in std_logic_vector(0 to n);  -- taps vector
--      data_valid_out : out std_logic;        -- used as flag to signal valid data generating
--      bit_out : out std_logic);             -- bit out when generating data
--  end component prbs_gen;
  
--  component prbs_det is
--     generic (
--       n       : integer);                     -- size of taps
--     port(
--       clk     : in std_logic;                     
--       reset   : in std_logic;              -- resets
--       valid_data: in std_logic;            -- used to tell when to start detecting
--       bit_in  : in std_logic;              -- input bit when detecting
--       taps    : in std_logic_vector(0 to n);  -- taps vector
--       lock    : out std_logic;              -- tells when the prbs loop is locked
--       sync    : out std_logic;              -- confirms sync
--       errors  : out integer);                -- shows error amount
--   end component prbs_det;

--  component seven_seg_display is
--    port (
--      number   : in  std_logic_vector(15 downto 0);  -- number input
--      clk      : in  std_logic;         -- clock
--      reset    : in  std_logic;         -- reset
--      digit    : out std_logic_vector(6 downto 0);   -- output hex digit
--      anode_en : out std_logic_vector(3 downto 0));  -- output anode enable for display
--  end component seven_seg_display;

component basys3_prbs_gen_det is
    port (
      clk            : in  std_logic;   -- clk from basys3 100MHz
      reset          : in  std_logic;   -- reset from button bassy3
      gen_data       : in  std_logic;   -- switch from basys3
      gen_error      : in  std_logic;   -- button from basys3
      prbs_bit_in    : in  std_logic;  -- Rx of prbs bit, into basys3 peripheral
      valid_data_in  : in  std_logic;  -- prbs_det input flag start detect,input on basys3 periph
      valid_data_out : out std_logic;  -- prbs_gen flag, inputs to prbs_det  basys3 peripheral
      prbs_bit_out   : out std_logic;   -- output bit from basys3 peripheral
      digit          : out std_logic_vector(6 downto 0);  -- digit to 7 segment display basys3
      anode_en       : out std_logic_vector(3 downto 0);  -- anode enable 7 segment disp basys3
      lock           : out std_logic;  -- output to LED basys3 to signal prbs lock
      sync           : out std_logic);  -- output to LED basys3 signal prbs sync
  end component basys3_prbs_gen_det;  
    
 -- signal tap_vector : std_logic_vector(0 to 15) := "0000000000101101";  -- 1 + x^11 + x^13 + x^14 + x^16
 -- signal tap_vector : std_logic_vector(0 to 4) := "00101";  -- make sure this vecotr is correct
  signal valid_data_sig,clock,rst,gen_err,prbs_loop_lock,prbs_bit,prbs_sync : std_logic := '0';
 -- signal prbs_errors : std_logic_vector(15 downto 0) := (others=>'0');
  signal gen_data : STD_LOGIC := '0';     --************ tells prbs when to generate data
  signal digit_out : std_logic_vector(6 downto 0) := (others => '0');
  --signal clk : std_logic := '0';
  signal anode_en_out : std_logic_vector(3 downto 0) := (others => '0');
  
begin
--  PRBSGenerator : entity work.prbs_gen
--    generic map (
--      n => 5) -- set taps vector size
--    port map (
--      clk     => clk,
--      reset   => rst,
--      gen_data=> gen_data, ---******added after*******
--      gen_err => gen_err,
--      taps    => tap_vector,
--      data_valid_out => strt_det, --tell PRBS detect when to start
--      bit_out => prbs_bit);

--  PRBSDetect : entity work.prbs_det
--    generic map (
--      n => 5) -- set taps vector size
--    port map (
--      clk     => clk,
--      reset   => rst,
--      valid_data => strt_det,
--      bit_in  => prbs_bit, --output bit from PRBSGenerator
--      taps    => tap_vector,
--      lock    => prbs_loop_lock,
--      sync    => prbs_sync,
--      errors  => prbs_errors);

--  Seg7Disp : entity work.seven_seg_display port map (
--    number   => prbs_errors,
--    clk      => clk,
--    reset    => rst,
--    digit    => digit_out,
--    anode_en => anode_en_out);

basys3_PRBS : entity work.basys3_prbs_gen_det port map (
  clk           => clock,
  reset         => rst,
  gen_data      => gen_data,
  gen_error     => gen_err,
  prbs_bit_in   => prbs_bit,
  valid_data_in => valid_data_sig,
  valid_data_out => valid_data_sig,
  prbs_bit_out  => prbs_bit,
  digit         => digit_out,
  anode_en      => anode_en_out,
  lock          => prbs_loop_lock,
  sync          => prbs_sync);
  
  
  clk_gen: process
  begin  -- process clk_gen
    clock <= not clock;
    wait for 1 ns;
  end process clk_gen;

  gen_errors: process
  begin  -- process prbs_tests
    if prbs_sync = '1' then 
      wait for 20 ns;
      gen_err <= '1';
      wait for 20 ms;
      gen_err <= '0';
      wait for 1 ms;
    else
      wait for 400 ns;
    end if;    
  end process gen_errors;

  prbs_reset: process
  begin  -- process prbs_reset
    rst <= '1';
    gen_data <= '1';
    wait for 10 ns;
    rst <= '0';
    wait for 4 ns;
    --gen_data <='1';--**************added after
    wait for 7 ms;
    gen_data <='0';
    wait for 40 ns;
    gen_data <= '1';
   -- wait for 5 ms;
    --rst <= '1';
   -- wait for 4 ns;
   -- rst <= '0';
  end process prbs_reset;


end Behavioral;
