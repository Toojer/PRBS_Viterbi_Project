library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_prbs_gen_det is
--  Port ( );
end tb_prbs_gen_det;

architecture Behavioral of tb_prbs_gen_det is

component prbs_gen is
    generic (
      n       : integer);                     -- size of taps
    port(
      clk     : in std_logic;                     
      reset   : in std_logic;              -- resets
      gen_data: in std_logic;              --****tells PRBS to start generating
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
    
 -- signal tap_vector : std_logic_vector(0 to 15) := "0000000000101101";  -- 1 + x^11 + x^13 + x^14 + x^16
  signal tap_vector : std_logic_vector(0 to 4) := "00101";  -- make sure this vecotr is correct
  signal strt_det,clock,rst,gen_err,prbs_loop_lock,prbs_bit,prbs_sync : std_logic := '0';
  signal prbs_errors : std_logic_vector(15 downto 0) := (others=>'0');
  signal gen_data : STD_LOGIC := '0';     --************ tells prbs when to generate data
begin

 
  PRBSGenerator : entity work.prbs_gen
  generic map (
  n => 5) -- set taps vector size
  port map (
  clk     => clock,
  reset   => rst,
  gen_data=> gen_data, ---******added after*******
  gen_err => gen_err,
  taps    => tap_vector,
  data_valid_out => strt_det, --tell PRBS detect when to start
  bit_out => prbs_bit);

  PRBSDetect : entity work.prbs_det
  generic map (
  n => 5) -- set taps vector size
  port map (
  clk     => clock,
  reset   => rst,
  valid_data => strt_det,
  bit_in  => prbs_bit, --output bit from PRBSGenerator
  taps    => tap_vector,
  lock    => prbs_loop_lock,
  sync    => prbs_sync,
  errors  => prbs_errors);


  --  performs prbs generate and detect
  clock_gen: process 
  begin  -- process prbs_test
    wait for 1 ns;
    clock <= not clock;
  end process clock_gen;

  gen_errors: process
  begin  -- process prbs_tests
    if prbs_sync = '1' then 
      wait for 200 ns;
      gen_err <= '1';
      wait for 2 ns;
      gen_err <= '0';
    else
      wait for 40 ns;
    end if;    
  end process gen_errors;

  prbs_reset: process
  begin  -- process prbs_reset
    rst <= '1';
    --gen_data <= '1';
    wait for 4 ns;
    rst <= '0';
    wait for 4 ns;
    gen_data <='1';--**************added after
    wait for 100 ns;
    gen_data <='0';
    wait for 40 ns;
    gen_data <= '1';
    wait for 1120 ns;
    rst <= '1';
    wait for 4 ns;
    rst <= '0';
  end process prbs_reset;

end Behavioral;
