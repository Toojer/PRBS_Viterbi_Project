library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.convEncPackage.all;

entity tb_enc_gen_err_v2 is
--  Port ( );
end tb_enc_gen_err_v2;


architecture Behavioral of tb_enc_gen_err_v2 is

component enc_gen_errors is
    port (
         clk       : in std_logic;
         gen_error : in std_logic;
         gen_2bit_err : in std_logic;
         gen_3bit_err : in std_logic;
         num_errs   : in std_logic_vector(7 downto 0);
         bits_in   : in std_logic_vector(0 to 1);
         bits_out  : out std_logic_vector(0 to 1);
         enc_err   : out std_logic
         );
end component;

signal gen_err, gen10_err, gen30_err: std_logic := '0';
--signal bits : unsigned(0 to 1) := "00";
--signal bits_output: std_logic_vector(0 to 1) := "00";
signal clk,enc_led : std_logic := '0';
--signal word_strt1,wrd_strt_out1 :std_logic := '0';
constant encInfo_defaults : enc_info :=( enc_bits   => "11",
                                             word_start => '0');
signal enc_bits,bits_out : enc_info := encInfo_defaults;
signal errors : std_logic_vector(7 downto 0) := "00000011";
begin

errrs: entity work.enc_gen_errors
 port map ( 
            clk       => clk,
            gen_error => gen_err,
            gen_2bit_err => gen10_err,
            gen_3bit_err => gen30_err,
            num_errs  => errors,
            data_in   => enc_bits,
            data_out  => bits_out,
            enc_err   => enc_led
          );
process
begin
    wait for 1 ns;
    clk <= not clk;    
end process;


--process
--begin
--  wait for 10 ns;
--  --bits <= bits + 1;
--end process;

process
begin
  gen_err <= '1';
  wait for 10 ns;
  gen_err <= '0';
  wait for 20 ns;
  
  wait for 50 ns;
  gen10_err <= '1';
  wait for 10 ns;
  gen10_err <= '0';
  wait for 50 ns;
  
  wait for 10 ns;
  gen30_err <= '1';
  wait for 10 ns;
  gen30_err <= '0';
  wait for 70 ns; 
end process;

end Behavioral;
