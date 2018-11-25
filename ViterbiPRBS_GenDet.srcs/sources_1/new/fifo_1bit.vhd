library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_1bit is
  port (
    clk        : in  std_logic;
    valid_bit  : in  std_logic;
    word_in    : in  std_logic;  -- input bit
    data_req   : in  std_logic;
    fifo_full  : out std_logic;
    bit_out    : out std_logic;         -- bit out FIFO
    valid_data : out std_logic);        -- strobe to signal valid data output
end fifo_1bit;

architecture Behavioral of fifo_1bit is
    signal valid_bit_r,data_req_r : std_logic := '0';
    signal fifo_rdy    : std_logic := '0';
    constant fifo_sz : integer := 63;
begin

  process(clk)
    
    constant empty_buf : std_logic_vector(0 to fifo_sz) := (others => '1');  -- empty buffer constant
    variable fifo_buf  : std_logic_vector(0 to fifo_sz) := (others => '1');  -- fifo buffer.
    variable indx      : integer := 0;
  begin
    if rising_edge(clk) then
      valid_data <= '0';
      fifo_full <= '0';
      if (valid_bit ='1' and indx <= fifo_sz) then --if there is a decoded word input
        fifo_buf(indx) := word_in;
        indx := indx + 1;
      end if; -- end if valid_word
     
      if indx > 32 then
        fifo_rdy <= '1';
      end if;
            
      --if (data_req = '1' and fifo_rdy = '1') then
      if (data_req = '1' and data_req_r = '1' and fifo_rdy = '1') then
       if indx > 0 then
         valid_data <= '1';
         bit_out <= fifo_buf(0);
         fifo_buf(0 to fifo_buf'right-1) := fifo_buf(1 to fifo_sz); --shift and fill with ones 
         indx := indx - 1;
         if indx < 0 then 
           indx := 0; 
           fifo_rdy <= '0';
         end if;
       ---------------------------------------------------------------------
       elsif data_req = '1' and data_req_r = '0' and fifo_rdy = '1' then
         valid_data <= '1';
         bit_out <= fifo_buf(0); 
       ---------------------------------------------------------------------
       else
         valid_data <= '0';
         -----------------------------
         bit_out <= fifo_buf(0);
         -----------------------------
       end if;
       
      end if;
      if (indx+1 > fifo_sz) then
        fifo_full <= '1';
      end if;
      --valid_bit_r <= valid_bit; --make sure to only store the word once.
      data_req_r <= data_req;
    end if; -- end rising_edge if
  end process;

end Behavioral;
