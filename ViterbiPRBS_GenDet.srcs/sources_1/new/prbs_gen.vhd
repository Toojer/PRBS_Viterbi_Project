library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs_gen is
  generic ( n : integer := 4); -- this determines taps vector size               
    Port ( clk          : in    STD_LOGIC;
           reset        : in    STD_LOGIC;
           gen_data     : in    STD_LOGIC; ---***************added after
           gen_err      : in    STD_LOGIC; 
           taps         : in    STD_LOGIC_VECTOR(0 to (n-1));
           data_valid_out   : out   STD_LOGIC; --lets data receiver know valid data is being produced
           bit_out      : out   STD_LOGIC);
end prbs_gen;
  
architecture Behavioral of prbs_gen is
    SIGNAL gen_err_r,gen_err_temp, mux_bit,temp_cmpr_bit  : STD_LOGIC := '0';
    SIGNAL fdbk_bit : STD_LOGIC := '1';

begin 

  debounce: entity work.debouncer port map (clk => clk, signal_in => gen_err, signal_out => gen_err_temp);

    Process(clk)
      VARIABLE temp_reg : STD_LOGIC_VECTOR(0 to 31) := (0=>'1',OTHERS=>'0');
      VARIABLE temp_mem,temp_taps : STD_LOGIC_VECTOR(0 to 31) := (OTHERS => '0');
      VARIABLE temp_fdbk_bit : STD_LOGIC:='0';
    Begin
      IF rising_edge(clk) Then
        if (taps'LENGTH /= 32) Then
          temp_taps(taps'range) := taps;
        end IF;
        if gen_data = '1' then --*****make sure that gen_data is high***
          gen_err_r   <= gen_err_temp;
          temp_fdbk_bit := '0'; --make sure it start as 0 
          --------------- FEEDBACK LOOP -------------------
          Feedback:for i in taps'RANGE loop
            temp_fdbk_bit := temp_mem(i) XOR temp_fdbk_bit;
          END loop;
          -------------------------------------------------
          temp_reg      := temp_fdbk_bit & temp_reg(0 to 30); --shift right and place new bit in front register
          temp_mem      := temp_reg AND temp_taps; --get feedback lines to XOR        
          data_valid_out <= '1';
          
          ----------- Generate Error Logic -----------------
          if (gen_err_r = '0' and gen_err_temp = '1') then -- generate only one error on gen_error high signal after debouncer
            bit_out  <= not temp_fdbk_bit;
          else
            bit_out  <= temp_fdbk_bit;
          end if;
          -------------------------------------------------
        else
          data_valid_out <= '0'; --send signal that no valid data is being output
        end if; --******making sure gen_data is high before outputing data
        ------------   IF RESET IS PRESSED --------------
        IF reset = '1' Then
          fdbk_bit    <= '0';    
          temp_reg    := (0=>'1' ,OTHERS=>'0'); --start at 1
          data_valid_out  <= '0';
        END IF;
        -------------------------------------------------
      END IF;              
    END PROCESS;   

end Behavioral;
