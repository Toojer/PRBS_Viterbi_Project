library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.convEncPackage.all;

entity tb_interleaver_deinterleaver is
--  Port ( );
end tb_interleaver_deinterleaver;

architecture Behavioral of tb_interleaver_deinterleaver is
component interleave is
  generic( row : integer := 16;
           col : integer := 16);
  port ( clk : in std_logic;
         reset: in std_logic;
         enc_data : in enc_info ;
         valid_data_in : in STD_LOGIC;
         intrlv_data : out enc_info;
         valid_data_out : out STD_LOGIC );
end component;

component de_interleave is
  generic( row : integer := 16;
           col : integer := 16);
  Port ( clk : in std_logic;
         reset: in std_logic;
         intlv_data : in enc_info ;
         valid_data_in : in STD_LOGIC;
         de_intrlv_data : out enc_info;
         valid_data_out : out STD_LOGIC );
end component;

constant row, col : integer := 16;
constant encInfo_defaults : enc_info :=( enc_bits   => "11", word_start => '0');
signal clk : std_logic := '0';
signal val_data_in : std_logic := '1';
signal val_data_out,val_data_de_int,reset: std_logic := '0';
signal enc_data_in,enc_data_out,de_int_data : enc_info := encInfo_defaults;
signal data_cnt : integer := 1; 
begin
  
interleaver: entity work.interleave
    port map(clk            => clk, 
             reset          => reset,
             enc_data       => enc_data_in,
             valid_data_in  => val_data_in,
             intrlv_data    => enc_data_out,
             valid_data_out => val_data_out);

de_interleaver: entity work.de_interleave
    port map(clk            => clk, 
             reset          => reset,
             intlv_data     => enc_data_out,
             valid_data_in  => val_data_out,
             de_intrlv_data => de_int_data,
             valid_data_out => val_data_de_int);

data: process
variable temp_bits : unsigned(1 downto 0):= "00";
begin  -- process data
 
 wait for 1 ns;
 if clk='1' then
   if (data_cnt mod 16) /= 0 then
     data_cnt <= data_cnt + 1;
   else
     temp_bits:= unsigned(enc_data_in.enc_bits);
     enc_data_in.enc_bits <=  std_logic_vector(temp_bits+1);
     --enc_data_in.enc_bits <= not enc_data_in.enc_bits;
     enc_data_in.word_start <= not enc_data_in.word_start;
     data_cnt<=data_cnt+1;
   end if;
   
   if (data_cnt > 45 and data_cnt < 50) or (data_cnt > 145 and data_cnt < 155) then
     val_data_in <= '0';
   else
     val_data_in <= '1';
   end if;
 end if;
  clk <= not clk;
end process data;

end Behavioral;

