library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs_gen is
  generic ( n : integer := 4); -- this determines taps vector size               
    Port ( clk          : in    STD_LOGIC;
           reset        : in    STD_LOGIC;
           gen_data     : in    STD_LOGIC; 
         --  enc_gen_data : in    std_logic; --let's prbs gen know to continue output
           gen_err      : in    STD_LOGIC; 
           taps         : in    STD_LOGIC_VECTOR(0 to (n-1));
           data_valid_out   : out   STD_LOGIC; --lets data receiver know valid data is being produced
           bit_out      : out   STD_LOGIC);
end prbs_gen;
  
architecture Behavioral of prbs_gen is
    SIGNAL gen_err_r,gen_err_temp, mux_bit,temp_cmpr_bit  : STD_LOGIC := '0';
    SIGNAL fdbk_bit : STD_LOGIC := '1';
    signal gen_data_r : std_logic := '0';  --This will delay prbs output by 1 to get last bit out.
    --signal bit_out_r : std_logic := '0';
    signal enc_ready : std_logic := '0';  --tells when the encoder has had a valid_output and PRBS can continue.
    --signal cnt : integer := 0; -- makes sure only one prbs bit is output prior to enc_ready signalling encoder is ready
begin 

  debounce: entity work.debouncer port map (clk => clk, signal_in => gen_err, signal_out => gen_err_temp);

    Process(clk)
      VARIABLE temp_reg : STD_LOGIC_VECTOR(0 to 31) := (0=>'1',OTHERS=>'0');
      VARIABLE temp_mem,temp_taps : STD_LOGIC_VECTOR(0 to 31) := (OTHERS => '0');
      VARIABLE temp_fdbk_bit : STD_LOGIC:='0';
    Begin
      IF rising_edge(clk) Then
        gen_data_r <= gen_data; --delay prbs output by 1
        if (taps'LENGTH /= 32) Then
          temp_taps(taps'range) := taps;
        end IF;
        if gen_data = '1' then 
          gen_err_r   <= gen_err_temp;
          data_valid_out <= '1';
          --if enc_gen_data = '1' or cnt < 1 then --if enc_gen_data = '1' or cnt < 1 then
            temp_fdbk_bit := '0'; --make sure it start as 0 
            temp_mem := temp_reg AND temp_taps;
            --------------- FEEDBACK LOOP -------------------
            Feedback:for i in taps'RANGE loop
              temp_fdbk_bit := temp_mem(i) XOR temp_fdbk_bit;
            END loop;
            -------------------------------------------------
            temp_reg      := temp_fdbk_bit & temp_reg(0 to 30); --shift right and place new bit in front register
            temp_mem      := temp_reg AND temp_taps; --get feedback lines to XOR        
            --data_valid_out <= '1';
          --end if;
          --if enc_gen_data = '0' then
          --  cnt <= 1; --make sure only one prbs bit is output when encoder not ready
          --else
          --  cnt <= 0; 
          --end if;
          
          ----------- Generate Error Logic -----------------
          if (gen_err_r = '0' and gen_err_temp = '1') then -- generate only one error on gen_error high signal after debouncer
            bit_out  <= not temp_fdbk_bit;
          else
            bit_out  <= temp_fdbk_bit;
          end if;
          -------------------------------------------------
        else
          data_valid_out <= '0'; --send signal that no valid data is being output
          bit_out <= temp_fdbk_bit; --keep sending the same value out if valid data not high
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
