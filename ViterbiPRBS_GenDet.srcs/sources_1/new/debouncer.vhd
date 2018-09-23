library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Port ( clk       : in STD_LOGIC;
           signal_in : in STD_LOGIC;
           signal_out : out STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
    --idea is the 100MHz clock will read a transient signal from the button, in order to not see this
    --the button will have to be held down for a little less than 1ms.
begin
    process(clk)
      variable debnc_cnt : unsigned(19 downto 0) := (others => '0');
    begin
     if (rising_edge(clk)) then
      if (signal_in = '1') then
        if debnc_cnt < "11111111111111111111" then
          debnc_cnt := debnc_cnt + 1;
        end if;
      else
        if debnc_cnt > 0 then
          debnc_cnt := debnc_cnt - 1;
        end if;
      end if;
      
      if debnc_cnt > "11111111111111111110" then
        signal_out <= '1';
      else
        signal_out <= '0';
      end if;
     end if;
    end process;
end Behavioral;
