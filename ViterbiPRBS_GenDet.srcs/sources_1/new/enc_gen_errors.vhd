library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.convEncPackage.all;

entity enc_gen_errors is
  port ( 
         clk       : in std_logic;
         gen_error : in std_logic;
         gen_2bit_err : in std_logic;
         gen_3bit_err : in std_logic;
         num_errs  : in std_logic_vector(7 downto 0);
         data_in   : in enc_info;
         data_out  : out enc_info;
         enc_err   : out std_logic
        );
end enc_gen_errors;

architecture Behavioral of enc_gen_errors is

  signal gen_err_r,gen_2err_r,gen_3err_r : std_logic := '0';  -- make sure only one instance of error is caught
  signal gen_err_temp,gen_2err_temp,gen_3err_temp : std_logic := '0';  -- output from debouncer
  signal err_limit,err_count  : integer := 0;
  signal enc_led : unsigned(15 downto 0) := X"0000";
  signal gen_err_state : integer := 0;
  signal bit_cnt : integer := 0;
begin

  gen_1error : entity work.debouncer port map (clk => clk, signal_in => gen_error, signal_out => gen_err_temp);
  gen_2biterr: entity work.debouncer port map (clk => clk, signal_in => gen_2bit_err, signal_out => gen_2err_temp); 
  gen_3biterr: entity work.debouncer port map (clk => clk, signal_in => gen_3bit_err, signal_out => gen_3err_temp);
  
  
  process(clk)
  begin 
    if rising_edge(clk) then 
      gen_err_r  <= gen_err_temp;
      gen_2err_r <= gen_2err_temp;
      gen_3err_r <= gen_3err_temp; 
      data_out.word_start <= data_in.word_start;    

      case gen_err_state is
        
       when 0 => 
         
         if enc_led > 0 then
           enc_led <= enc_led-1;
         else
           enc_err <= '0';
           enc_led <= X"0000";
         end if;
         if gen_err_r = '0' and gen_err_temp = '1' then 
           gen_err_state <= 1;
         end if;
         if gen_2err_r = '0' and gen_2err_temp = '1' then 
           gen_err_state <= 2;
         end if;
         if gen_3err_r = '0' and gen_3err_temp = '1' then 
           gen_err_state <= 3;
         end if;
         err_limit <= to_integer(unsigned(num_errs));
         data_out.enc_bits  <= data_in.enc_bits;
         
       when 1 =>
         
         if err_count < err_limit then
           enc_err   <= '1';
           enc_led   <= X"FFFF";
           data_out.enc_bits(0)  <= not data_in.enc_bits(0);
           data_out.enc_bits(1)  <= data_in.enc_bits(1);
           err_count <= err_count+1;
           bit_cnt <= bit_cnt + 1;
         else
           data_out.enc_bits  <= data_in.enc_bits;
           gen_err_state <= 0;
           err_count <= 0;
           bit_cnt <= 0;
         end if;
         
       when 2 =>
         if bit_cnt < 2 then --every third bit insert error
           if err_count < err_limit then
             enc_err   <= '1';
             enc_led   <= X"FFFF";
             data_out.enc_bits  <= data_in.enc_bits;
             bit_cnt <= bit_cnt +1;
           else
             data_out.enc_bits  <= data_in.enc_bits;
             bit_cnt <= 0;
             gen_err_state <= 0;
             err_count <= 0;
           end if;
         else
           err_count <= err_count + 1;
           data_out.enc_bits(0)  <= not data_in.enc_bits(0);
           data_out.enc_bits(1)  <= data_in.enc_bits(1);
           if err_count < err_limit then
             gen_err_state <= 2;
           else
             data_out.enc_bits  <= data_in.enc_bits;
             gen_err_state <= 0;
             err_count <= 0;
           end if;
           bit_cnt <= 0;
         end if;
         
       when 3 =>
          if bit_cnt < 3 then --every fourth bit insert error
            if err_count < err_limit then
              enc_err   <= '1';
              enc_led   <= X"FFFF";
              data_out.enc_bits  <= data_in.enc_bits;
              bit_cnt <= bit_cnt +1;
            else
              data_out.enc_bits  <= data_in.enc_bits;
              bit_cnt <= 0;
              gen_err_state <= 0;
              err_count <= 0;
            end if;
          else  --if we are at bit 3 then corrupt the bit
            data_out.enc_bits(0)  <= not data_in.enc_bits(0);
            data_out.enc_bits(1)  <= data_in.enc_bits(1);
            err_count <= err_count + 1;
            if err_count < err_limit then
              gen_err_state <= 3;
            else
              data_out.enc_bits  <= data_in.enc_bits;
              gen_err_state <= 0;
              err_count <= 0;
            end if;
            bit_cnt <= 0;
          end if;
       when others => 
         enc_err    <= '0';
         err_count  <= 0;
         bit_cnt    <= 0;
         gen_err_state <= 0;
         data_out.enc_bits  <= data_in.enc_bits;
     end case; 
    end if;
  end process;   

end Behavioral;
