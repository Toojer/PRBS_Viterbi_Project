library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs_det is
  generic ( n : integer := 4); -- this determines taps vector size               
    Port ( clk          : in    STD_LOGIC;
           reset        : in    STD_LOGIC;
           valid_data   : in    STD_LOGIC;--needed for detect        
           bit_in       : in    STD_LOGIC;
           taps         : in    STD_LOGIC_VECTOR(0 to (n-1));
           lock         : out   STD_LOGIC;
           sync         : out   STD_LOGIC;
           errors       : out   INTEGER);
end prbs_det;

architecture Behavioral of prbs_det is
    SIGNAL gen_err_r, mux_bit,temp_cmpr_bit  : STD_LOGIC := '0';
    Signal temp_lock : STD_LOGIC := '0';   
    SIGNAL fdbk_bit : STD_LOGIC := '1';  --starting out as one for gen PRBS we need to start at 1 and not 0 and det PRBS will take bitin
    
begin
     
    Process(clk)
      VARIABLE temp_reg : STD_LOGIC_VECTOR(0 to 31) := (OTHERS=>'0');
      VARIABLE temp_mem,temp_taps : STD_LOGIC_VECTOR(0 to 31) := (OTHERS => '0');
      VARIABLE temp_fdbk_bit : STD_LOGIC:='0';
      VARIABLE count,temp_errors : INTEGER := 0;
    Begin
      IF rising_edge(clk) Then
        IF (taps'LENGTH /= 32) Then
          temp_taps(taps'range) := taps;
        End IF;
        temp_fdbk_bit := '0'; --make sure it start as 0
        --------------- FEEDBACK LOOP -------------------
        Feedback:for i in taps'RANGE loop
          temp_fdbk_bit := temp_mem(i) XOR temp_fdbk_bit;
        END loop;
        -------------------------------------------------
        if valid_data = '1' then        
          --------- Count Errors for feedback loop when detecting --------
          if ((count > taps'length)) then 
            temp_lock <= '1';
          else
            temp_lock <= '0';
          end if;
      
          if (temp_lock = '1') then          
            CountErr:IF ((bit_in XOR temp_fdbk_bit) = '1') then --((temp_cmpr_bit XOR temp_fdbk_bit)='1') Then
              temp_errors := temp_errors+1;
            end if;
            temp_reg := temp_fdbk_bit & temp_reg(0 to 30); --shift right and place new bit in front register
          
            if temp_errors > 100 then
              temp_lock  <= '0';
              count      := 0;
              sync       <= '0';
              temp_errors:= 0;
            else
              temp_lock  <= '1';
              sync       <= '1';
            end if;
          else
            temp_reg := bit_in & temp_reg(0 to 30);
            sync <= '0';
          end if;
        else
          temp_reg := '0'& temp_reg(0 to 30);--if not valid data just put 0's into LFSR
        end if; --valid_data if
        temp_mem      := temp_reg AND temp_taps; --get feedback lines to XOR      
        count         := count+1; --count the number of times bit_in added to mem_reg
          
               
        ----------------------------------------------------------------  
        
        --fdbk_bit <= temp_fdbk_bit;  
        errors   <= temp_errors;
        lock     <= temp_lock;
        temp_cmpr_bit <= bit_in;
        
        ------------   IF RESET IS PRESSED --------------
        IF reset = '1' Then
         -- fdbk_bit    <= '0';
          temp_errors := 0;
          count       := 0;     
          temp_reg    := (OTHERS=>'0'); 
          lock        <= '0';
          sync        <= '0';
          temp_lock   <= '0';
        END IF;
        -------------------------------------------------
      END IF;              
    END PROCESS;   

end Behavioral;
