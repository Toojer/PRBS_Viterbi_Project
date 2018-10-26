library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity word_feeder is
  port (
    clk        : in  std_logic;
    word_in    : in  std_logic_vector(0 to 30);  -- input word length 31
    bit_out    : out std_logic;         -- bit out FIFO
    valid_data : out std_logic);        -- strobe to signal valid data output
end word_feeder;

architecture Behavioral of word_feeder is
    signal valid_word_r : std_logic := '0';
begin

  process(clk)
    variable fifo_buf  : std_logic_vector(0 to 30) := (others => 'U');  -- fifo buffer for output
    variable fifo_buf1 : std_logic_vector(0 to 30) := (others => 'U');  --fifo_buffer_for_input_to fifo_buf
    variable fifo_buf2 : std_logic_vector(0 to 30) := (others => 'U');  -- fifo buffer for direct input
    variable valid_word: std_logic := '0';  -- confirms a new word is present
    constant empty_buf : std_logic_vector(0 to 30) := (others => 'U');  -- empty buffer constant
  begin
    if rising_edge(clk) then
      if (word_in /= empty_buf) then
        valid_word := '1';
      else
        valid_word := '0';
      end if;
      if (valid_word ='1' and valid_word_r = '0') then --if there is a decoded word input
        if (fifo_buf2 = empty_buf) then
          if (fifo_buf1 = empty_buf) then 
            if fifo_buf = empty_buf then 
              fifo_buf := word_in;
            else
              fifo_buf1:= word_in;
            end if;
          else
            fifo_buf  := fifo_buf1;
            fifo_buf1 := fifo_buf2;
            fifo_buf2 := word_in;
          end if; -- end fifo_buf1
        else
          --crap I hope this never happens
        end if; --end fifo_buf2
      end if; -- end word_in not empty
      if fifo_buf(0) /= 'U' then
        valid_data <= '1';
      else
        valid_data <= '0';
      end if;
      bit_out      <= fifo_buf(0);
      fifo_buf     := (fifo_buf(1 to (fifo_buf'right)) & 'U'); --shift left by one fill with 'U'
      valid_word_r <= valid_word;
    end if; -- end rising_edge if
  end process;

end Behavioral;
