library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_enc_gen_errors is
--  Port ( );
end tb_enc_gen_errors;


architecture Behavioral of tb_enc_gen_errors is

component enc_gen_errors is
    port (
         clk       : in std_logic;
         gen_error : in std_logic;
         gen_10err : in std_logic;
         gen_30err : in std_logic;
         bits_in   : in std_logic_vector(0 to 1);
         bits_out  : out std_logic_vector(0 to 1);
         enc_err   : out std_logic
         );
end component;

signal gen_err, gen10_err, gen30_err: std_logic := '0';
signal bits : unsigned(0 to 1) := "00";
signal bits_output: std_logic_vector(0 to 1) := "00";
signal clk,enc_led : std_logic := '0';
signal word_strt1,wrd_strt_out1 :std_logic := '0';
begin

errrs: entity work.enc_gen_errors
 port map ( 
            clk       => clk,
            gen_error => gen_err,
            gen_10err => gen10_err,
            gen_30err => gen30_err,
            --word_start=> word_strt1,
            bits_in   => std_logic_vector(bits),
            bits_out  => bits_output,
            --wrd_strt_out=> wrd_strt_out1,
            enc_err   => enc_led
          );
process
begin
    wait for 1 ns;
    clk <= not clk;    
end process;


process
begin
  wait for 10 ns;
  bits <= bits + 1;
end process;

process
begin
  gen_err <= '1';
  wait for 10 ms;
  gen_err <= '0';
  wait for 20 ns;
  
  wait for 50 ns;
  gen10_err <= '1';
  wait for 10 ms;
  gen10_err <= '0';
  wait for 50 ns;
  
  wait for 10 ns;
  gen30_err <= '1';
  wait for 10 ms;
  gen30_err <= '0';
  wait for 70 ns; 
end process;

end Behavioral;
