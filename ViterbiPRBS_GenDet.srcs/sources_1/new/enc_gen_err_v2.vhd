library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity enc_gen_err_v2 is
  port ( 
         clk       : in std_logic;
         gen_error : in std_logic;
         gen_10err : in std_logic;
         gen_30err : in std_logic;
         bits_in   : in std_logic_vector(0 to 1);
         word_start: in std_logic;
         bits_out  : out std_logic_vector(0 to 1);
         wrd_strt_out: out std_logic;
         enc_err   : out std_logic
        );
end enc_gen_err_v2;

architecture Behavioral of enc_gen_err_v2 is

  signal gen_err_state,gen_err_r,gen_10err_r,gen_30err_r : std_logic := '0';  -- make sure only one instance of error is caught
  signal gen_err_temp,gen_10err_temp,gen_30err_temp : std_logic := '0';  -- output from debouncer
  signal err_limit,err_count  : integer := 0;
  signal enc_led : unsigned(15 downto 0) := X"0000";
begin

  gen_1error:   entity work.debouncer port map (clk => clk, signal_in => gen_error, signal_out => gen_err_temp);
  gen_10errors: entity work.debouncer port map (clk => clk, signal_in => gen_10err, signal_out => gen_10err_temp); 
  gen_30errors: entity work.debouncer port map (clk => clk, signal_in => gen_30err, signal_out => gen_30err_temp);
  
  
  process(clk)
  begin 
    if rising_edge(clk) then 
      gen_err_r   <= gen_err_temp;
      gen_10err_r <= gen_10err_temp;
      gen_30err_r <= gen_30err_temp;
      wrd_strt_out<= word_start;     
       
      case gen_err_state is
        
       when '0' => 
         
         if enc_led > 0 then
           enc_led <= enc_led-1;
         else
           enc_err <= '0';
           enc_led <= X"0000";
         end if;
         if gen_err_r = '0' and gen_err_temp = '1' then
           err_limit     <= 1;
           gen_err_state <= '1';
         end if;
         if gen_10err_r = '0' and gen_10err_temp = '1' then
           err_limit     <= 3;
           gen_err_state <= '1';
         end if;
       if gen_30err_r = '0' and gen_30err_temp = '1' then
           err_limit     <= 5;
           gen_err_state <= '1';
         end if;
         
         bits_out <= bits_in;
         
       when '1' =>
         
         if err_count < err_limit then
           enc_err   <= '1';
           enc_led   <= X"FFFF";
           err_count <= err_count + 1;
           bits_out(0)  <= not bits_in(0);
           bits_out(1)  <= bits_in(1);
         else
           --enc_err  <= '0';
           bits_out <= bits_in;
           gen_err_state <= '0';
           err_count <= 0;
         end if;
         
       when others => 
           enc_err    <= '0';
           err_count  <= 0;
           gen_err_state <= '0';
           bits_out <= bits_in;
     end case; 
    end if;
  end process;
  
  
    

end Behavioral;
