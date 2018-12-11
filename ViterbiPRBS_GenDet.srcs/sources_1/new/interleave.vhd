library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.convEncPackage.all;

entity interleave is
  generic(row : integer := 16;
          col : integer := 16);
  Port ( clk : in std_logic;
         reset : in std_logic;
         enc_data : in enc_info ;
         valid_data_in : in STD_LOGIC;
         intrlv_data : out enc_info;
         valid_data_out : out STD_LOGIC );
end interleave;

architecture Behavioral of interleave is
  constant enc_info_defaults : enc_info :=( enc_bits   => "11",
                                             word_start => '0');
  type mtrx_array is array (row-1 downto 0,col-1 downto 0 ) of enc_info;
  signal temp_intrlv_mtrx,intrlv_mtrx : mtrx_array;
  signal temp_row,temp_col,temp_row_f,temp_col_f,temp_col_r : integer := 0;       -- counts throught the matrix
  signal mtrx_full : std_logic := '0';
begin
  process (clk)
    variable mtrx_full_v: std_logic := '0';
  begin
   if rising_edge(clk) then
   valid_data_out <= '0';
    if valid_data_in = '1' then
      temp_col_r <= temp_col;
      temp_intrlv_mtrx(temp_row,temp_col) <= enc_data;    
      -------------- count the rows and columns -----
      if temp_row >= row-1 and temp_col >= col-1 then
        temp_row <= 0;
        temp_col <= 0;
        --mtrx_full := not mtrx_full;
      else
        if temp_col >= col-1 then
          temp_col <= 0;
          temp_row <= temp_row + 1;
        else
          temp_col <= temp_col+1;
        end if;
      end if;
      if temp_row = 0 and temp_col = 0 and temp_col_r /=0 then--temp_col = col-1 then
        mtrx_full <= '1';
        intrlv_mtrx <= temp_intrlv_mtrx;
      end if; 
      -----------------------------------------------
      
    end if; --end if valid_data_in
    
    if mtrx_full = '1' then --Output Matrix Data when full.
      if temp_row_f >= row-1 and temp_col_f >= col-1 then
        temp_row_f <= 0;
       -- if mtrx_full_v = '0' then
        mtrx_full <= '0';
       -- end if;
        temp_col_f <= 0;
        --mtrx_full := not mtrx_full;
      else
        if temp_col_f >= col-1 then
          temp_col_f <= 0;
          temp_row_f <= temp_row_f + 1;
        else
          temp_col_f <= temp_col_f+1;
        end if;
      end if;
      
      valid_data_out    <= '1';
      intrlv_data       <= intrlv_mtrx(temp_col_f,(temp_row_f));
    else
      valid_data_out <= '0';
      temp_row_f <= 0;
      temp_col_f <= 0;
    end if; -- end if mtrx_full
    if reset = '1' then
      temp_col_f <=0;
      temp_col <= 0;
      temp_row_f <= 0;
      temp_row <= 0;
      mtrx_full <= '0';
      valid_data_out <= '0';
    end if;
   end if;  --end if rising_edge(clk) 
  end process;
end Behavioral;
