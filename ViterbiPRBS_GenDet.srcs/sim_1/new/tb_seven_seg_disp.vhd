library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_seven_seg_disp is
--  Port ( );
end tb_seven_seg_disp;

architecture Behavioral of tb_seven_seg_disp is

component seven_seg_display is
  port (
    number   : in std_logic_vector(15 downto 0);
    clk      : in std_logic;            -- clock
    reset    : in std_logic;            -- reset
    digit    : in std_logic_vector(6 downto 0);  -- output digit for sev segment display
    anode_en : in std_logic_vector(3 downto 0));
end component seven_seg_display;

signal anode_enable : std_logic_vector(3 downto 0) := (others => '0');
signal digit_out : std_logic_vector(6 downto 0) := (others => '0');
signal num_input : std_logic_vector(15 downto 0) := (others => '0');
signal clk : std_logic := '0';
signal anode_en_out : std_logic_vector(3 downto 0) := (others => '0');
signal rst : std_logic := '0';

  
begin
DUT : entity work.seven_seg_display port map (
  number   => num_input,
  clk      => clk,
  reset    => rst,
  digit    => digit_out,
  anode_en => anode_en_out);
  
  clk_gen: process
  begin  -- process clk_gen
    clk <= not clk;
    wait for 1 ns;
  end process clk_gen;

  number: process
    variable number : unsigned(15 downto 0) := (others => '0');
  begin  -- process number
    wait for 1 ns;
    number := number + 1;
    num_input <= std_logic_vector(number);   
  end process number;
  
end Behavioral;
