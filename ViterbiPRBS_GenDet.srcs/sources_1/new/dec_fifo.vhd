library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec_fifo is
  port (
    clk        : in  std_logic;
    valid_word : in  std_logic;
    word_in    : in  std_logic_vector(0 to 30);  -- input word length 31
    data_req   : in  std_logic;
    bit_out    : out std_logic;         -- bit out FIFO
    valid_data : out std_logic);        -- strobe to signal valid data output
end dec_fifo;

architecture Behavioral of dec_fifo is
    signal valid_word_r : std_logic := '0';
    
begin

  process(clk)
    
    variable fifo_buf  : std_logic_vector(0 to 30) := (others => '1');  -- fifo buffer for output
    variable fifo_buf1 : std_logic_vector(0 to 30) := (others => '1');  -- fifo_buffer_for_input_to fifo_buf
    variable fifo_buf2 : std_logic_vector(0 to 30) := (others => '1');  -- fifo buffer for direct input
    --variable valid_word: std_logic := '0';  -- confirms a new word is present
    constant empty_buf : std_logic_vector(0 to 30) := (others => '1');  -- empty buffer constant
  begin
    if rising_edge(clk) then
      if (valid_word ='1' and valid_word_r = '0')or (fifo_buf = empty_buf) then --if there is a decoded word input
        if (fifo_buf2 = empty_buf) then --if buffer2 is empty
          if (fifo_buf1 = empty_buf) then  -- if buffer 1 is empty
            if (fifo_buf = empty_buf) then  -- if buffer is empty
              fifo_buf  := word_in;
              fifo_buf1 := empty_buf;
              fifo_buf2 := empty_buf;
            else                            -- if buffer is full fill buffer1 with input word
              fifo_buf1  := word_in;
            end if;
          else                              -- if buffer1 is full fill buffer2 with input word
            fifo_buf2 := word_in;
          end if; -- end fifo_buf1
        else
          --crap I hope this never happens this means buf2 is full
        end if; --end fifo_buf2
      end if; -- end word_in not empty
      if data_req = '1' then
        if fifo_buf /= empty_buf then
          valid_data <= '1';
          bit_out    <= fifo_buf(0);
          fifo_buf   := (fifo_buf(1 to (fifo_buf'right)) & '1'); --shift left by one fill with '1'
        else
          if fifo_buf1 /=empty_buf then --if buffer empty, but buffer1 has word
            fifo_buf := fifo_buf1;
            fifo_buf1:= fifo_buf2;
            fifo_buf2:= empty_buf;
            valid_data <= '1';
          elsif fifo_buf2 /= empty_buf then --if buffer1 empty but buffer2 has word
            fifo_buf := fifo_buf2;
            fifo_buf1:= empty_buf;
            fifo_buf2:= empty_buf;
            valid_data <= '1';
          else
           --we're screwed if the buffers all fill up.
           valid_data <= '0';
          end if;
          bit_out    <= fifo_buf(0);
          fifo_buf   := (fifo_buf(1 to (fifo_buf'right)) & '1'); --shift left by one fill with '1'
        
        end if; -- end if valid_word
      end if; -- end if data_req = 1
      valid_word_r <= valid_word; --make sure to only store the word once.
    end if; -- end rising_edge if
  end process;

end Behavioral;
