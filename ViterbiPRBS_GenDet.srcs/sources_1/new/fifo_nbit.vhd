library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_nbit is
  generic( n :integer:= 2);
  port (
    clk        : in  std_logic;
    valid_bit  : in  std_logic;
    word_in    : in  std_logic_vector(0 to n-1);  -- input bit
    data_req   : in  std_logic;
    fifo_full  : out std_logic;
    bit_out    : out std_logic_vector(0 to n-1);         -- bit out FIFO
    valid_data : out std_logic);        -- strobe to signal valid data output
end fifo_nbit;

architecture Behavioral of fifo_nbit is
    signal valid_bit_r,bit_out_r,data_req_r : std_logic := '0';
    signal fifo_rdy    : std_logic := '0';
    constant fifo_sz : integer := 127;
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
        fifo_buf(indx to (indx+(n-1))) := word_in;
        indx := indx + n;
      end if; -- end if valid_word
      
      if indx > 64 then
        fifo_rdy <= '1';
      end if;
      --if (data_req = '1' and fifo_rdy = '1') then
      if (data_req = '1' and data_req_r = '1' and fifo_rdy = '1') then
       if indx > 0 then
         valid_data <= '1';
         bit_out <= fifo_buf(0 to n-1);
         fifo_buf(0 to fifo_buf'right-n) := fifo_buf(n to fifo_sz); --shift and fill with ones 
         indx := indx - n;
         if indx < 0 then 
           indx := 0;
           fifo_rdy<='0'; 
         end if;
       ----------------------------------------------------------------
       elsif data_req = '1' and data_req_r = '0' and fifo_rdy = '1' then
         valid_data <= '1';
         bit_out <= fifo_buf(0 to n-1); 
       ------------------------------------------------------------------
       else
         valid_data <= '0';
         -----------------------------
         bit_out <= fifo_buf(0 to n-1);
         -------------------------------
       end if;
       
      end if;
      if (indx+n > fifo_sz) then
        fifo_full <= '1';
      end if;
      data_req_r <= data_req;
      --bit_out_r  <= bit_out;
      --valid_bit_r <= valid_bit; --make sure to only store the word once.
    end if; -- end rising_edge if
  end process;

end Behavioral;
