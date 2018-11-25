--This always has at least on bit missing when decoding.  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.convEncPackage.all;
----------------------------------------------------------------------------------
entity fdfwd_conv_enc_v2 is
  generic (
    m       : integer := 5;--2;
    word_sz : integer := 32);                  -- generator polynomial size
  port (
    clk        : in std_logic;         -- clock signal
    gen_poly1  : in  std_logic_vector(0 to m-1); -- generator polynomials for encoder
    gen_poly2  : in std_logic_vector(0 to m-1);
    bit_in     : in  std_logic;        -- input bit from PRBS Generator
    gen_data   : in  std_logic;          -- generate data flag from PRBS generator
    data_out   : out enc_info; -- output bits for 1/2 rate encoder
    valid_data : out std_logic;       -- output data valid flag
    ready      : out std_logic);
end fdfwd_conv_enc_v2;
------------------------------------------------------------------------------------

architecture Behavioral of fdfwd_conv_enc_v2 is
  signal gen_data_r : std_logic := '0';  -- check to see if this is the start of a word
  signal bit_in_r : std_logic := '0'; --keeps track of previous bit so we don't miss first bit of prbs_gen
  signal wrdstrt_count : integer := 0;
begin
  encode: process (clk) is
    variable mem_regs : std_logic_vector(0 to 31):= (others => '0');
    variable temp_val1, temp_val2 : std_logic_vector(0 to 31) := (others => '0');
    variable temp_bit1,temp_bit2 : std_logic := '0';
    variable temp_gen_poly1,temp_gen_poly2 : std_logic_vector(0 to 31) := (others =>'0');
    variable wrd_cnt,count : integer := 0;
  begin
    if rising_edge(clk) then 
      -- make sure gen_poly is 32 bits in length--
      if gen_poly1'Length /= 32 then
        temp_gen_poly1(gen_poly1'range) := gen_poly1;
        temp_gen_poly2(gen_poly2'range) := gen_poly2;
      end if;
      --------------------------------------------
      bit_in_r <= bit_in;
      gen_data_r <= gen_data;
      if gen_data = '1' then 
      --if gen_data = '1' and wrdstrt_count > 1 then
        if (wrd_cnt < (word_sz-1)) then
        --if (wrd_cnt < word_sz+(m-1)) then
          mem_regs  := bit_in_r & mem_regs(0 to 30); --shift right and put in input bit
          if wrd_cnt = 0 then
            data_out.word_start <= '1';
          else
            data_out.word_start <= '0';
          end if;
          ready <= '1';
          valid_data <= '1';
          wrd_cnt := wrd_cnt+1;
          if wrd_cnt >= word_sz-1 then
            ready <= '0';
          end if;
        elsif (count < m-1 and wrd_cnt >= word_sz-1) then --terminate word
          mem_regs := '0' & mem_regs(0 to 30); --fill with zeros
          data_out.word_start <= '0';
          ready      <= '0';
          valid_data <= '1';
          count      := count+1;
          wrd_cnt    := wrd_cnt+1;
        end if;-- end wrd_cnt < word_sz-1 when gen_data is high
      elsif (count <= m-1 and wrd_cnt >= word_sz-1) then --terminate word when gen_data is low
        mem_regs := '0' & mem_regs(0 to 30); --fill with zeros
        data_out.word_start <= '0';
        ready      <= '0';
        valid_data <= '1';
        count      := count+1;
        wrd_cnt    := wrd_cnt+1;
      else --any case where word_sz doesn't match previous cases
       data_out.word_start <= '0';
       ready      <= '1';
       valid_data <= '0';
     end if;
     if (wrd_cnt) > ((word_sz-1)+(m-1)) then
      count   := 0; --start the count over for memory termination
      wrd_cnt := 0; --start the word size count over
      ready   <= '1'; --ready for more data word is finished.
     end if;
    -------- perform convolutional encoding ---------
     temp_val1 := mem_regs and temp_gen_poly1;
     temp_val2 := mem_regs and temp_gen_poly2;
     temp_bit1 :='0';
     temp_bit2 :='0';  
     Bit1:for j in gen_poly1'RANGE loop
       temp_bit1 := temp_val1(j) XOR temp_bit1;
     END loop;
     Bit2:for k in gen_poly2'RANGE loop
       temp_bit2 := temp_val2(k) XOR temp_bit2;
     END loop;
     data_out.enc_bits(0)<=temp_bit1; 
     data_out.enc_bits(1)<=temp_bit2;
     --------------------------------------------------
    end if; --end if rising_edge(clk)
    gen_data_r <= gen_data;
  end process encode;
 
end Behavioral;
