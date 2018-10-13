library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------- Trellis Package --------------------------------------------
package trellis_package is
--  generic (
--    m      : integer;                   -- defines length of memory size
--    wrd_sz : integer);                  -- defines length of word size
  
  type trellis_info is record           -- trellis information record
    path_metric : integer;              -- trellis path metric
    bits_out    : std_logic_vector(0 to 11);--(0 to 12);     -- contains the word being decoded
    valid_data   : std_logic;  -- tells whether to calculate this element or not
  end record trellis_info;
  
  type trellis_array is array(0 to 1) of trellis_info;

  -- defaults the trellis when starting over
  constant trellis_defaults : trellis_info :=( path_metric => 0,
                                               bits_out    => (others => '0'),
                                               valid_data   => '0');
  -- defaults the trellis when starting over
  constant trellis_start: trellis_info :=( path_metric => 0,
                                           bits_out    => (others => '0'),
                                           valid_data  => '1');
  --calculate the next state
  function next_state (
    curr_state  : in std_logic_vector(1 downto 0); 
    bit_in      : in std_logic)  -- memory register current state
    return std_logic_vector;
  --calculate next predicted output
  function next_output(
    next_state  : in std_logic_vector(0 to 1);
    gen_poly1   : in std_logic_vector(0 to 1);
    gen_poly2   : in std_logic_vector(0 to 1))
    return std_logic_vector;
  --calculate branch metric
  function branch_metric (
    bits_in     : std_logic_vector(0 to 1);  -- bits in
    next_out    : std_logic_vector(0 to 1))  -- predicted output
    return integer;
  function correct_state(
    vector_in   : std_logic_vector(1 downto 0))
    return integer;
    
end package trellis_package;

package body trellis_package is
  
  function correct_state(
    vector_in   : std_logic_vector(1 downto 0))
    return integer is
    variable temp_vector : std_logic_vector(1 downto 0);
  begin
    --for i in vector_in'range loop
    --  temp_vector(i) := vector_in(i);
    --end loop;
    temp_vector := '0' & vector_in(1);
    return to_integer(unsigned(temp_vector));
  end;
  
  
  function next_state(
    curr_state : std_logic_vector(1 downto 0);
    bit_in     : std_logic)  -- input current state
    return std_logic_vector is
  begin
    return  bit_in & curr_state(0);
  end;
  
  function next_output(
    next_state : std_logic_vector(0 to 1);
    gen_poly1  : std_logic_vector(0 to 1);
    gen_poly2  : std_logic_vector(0 to 1))
    return std_logic_vector is
    variable temp1,temp2 : std_logic_vector(0 to 1):= (others => '0');
    variable bit_temp1,bit_temp2: std_logic := '0';
    --variable nx_ste_flip : std_logic_vector(1 downto 0);
  begin
    --for i in next_state'range loop
    --  nx_ste_flip(i) := next_state(i);
    --end loop;
    temp1 := next_state and gen_poly1;
    temp2 := next_state and gen_poly2;
    bit_temp1 := '0';
    bit_temp2 := '0';
    for j in temp1'range loop
      bit_temp1 := temp1(j) xor bit_temp1;
      bit_temp2 := temp2(j) xor bit_temp2;
    end loop;
    return bit_temp1 & bit_temp2;
  end;

  -- purpose: calculate branch metric
  function branch_metric (
    bits_in     : std_logic_vector(0 to 1);  -- bits in
    next_out : std_logic_vector(0 to 1))  -- next predicted output
    return integer is
    variable temp : std_logic_vector(0 to 1) := "00";
    variable temp_metric : integer := 0;  -- temp metric
  begin  -- function branch_metric
    temp := bits_in xor next_out;
    temp_metric := 0;
    for k in temp'range loop
      if temp(k) = '1' then
        temp_metric := temp_metric + 1; 
      end if;
    end loop;
    return temp_metric;
  end function branch_metric;
end package body trellis_package;
----------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.trellis_package.all;

entity fdfwd_viterbi_dec is
    generic(m      : integer := 2;
            wrd_sz : integer := 32); --memory size and word size
    Port ( clk : in std_logic;
           gen_poly1: in std_logic_vector(0 to m-1);
           gen_poly2: in std_logic_vector(0 to m-1); 
           valid_data: in std_logic;
           word_start : in std_logic;
           bits_in : in std_logic_vector(0 to 1);
           ml_word_out : out std_logic_vector(0 to wrd_sz-1);
           ready : out std_logic);
end fdfwd_viterbi_dec;

--package tr_pack is new work.trellis_package generic map (m=>m,wrd_sz=>wrd_sz);

architecture Behavioral of fdfwd_viterbi_dec is
--This trellis architecture uses the index inside the trellis diagram to indicate what the state of the memory registers
--are.  I attempted to make the package generic, but have not found a way to make it work as a generic package
  signal trellis : trellis_array := (0=>trellis_start,others => trellis_defaults);  -- these is the previous values of the trellis
  signal word_start_r : std_logic := '0';
begin
  decode: process (clk)
    variable t,temp_p_metric,temp0,temp1,temp_state0,temp_state1 : integer := 0;
    variable temp_trellis : trellis_array := (others =>trellis_defaults);--represents-the nextstage-of-the trellis
    variable nxt_output0,nxt_output1 : std_logic_vector(0 to 1) := (others => '0');  -- memory registers
    variable nxt_state0, nxt_state1 : std_logic_vector(0 to 1) := (others => '0'); -- next state calculation
    variable temp_bits_out : std_logic_vector(0 to wrd_sz-1) := (others => '0');  -- temp bits out placeholder
  begin  -- process decode
    
    if (rising_edge(clk)) then  -- rising clock edge and valid data
      ready        <= '1';
      word_start_r <= word_start;
      if valid_data = '1' then
      -------  Loop on trellis array building the trellis  -------------
        tr_loop:for i in trellis'range loop
          if ((word_start_r = '0') and (word_start = '1') and i=0) then --starting at state 0 of trellis
            temp_trellis                  := (others => trellis_defaults);
            temp_trellis(0).valid_data    := '1'; --this will cause the loop to calculate the next output
            temp_trellis(0).path_metric   := 100; --this will garauntee that we replace path_metric on the first loop
            ml_word_out                   <= (others => 'U');
            t                             := 0;
          end if;
          --verify trellis has a value before calculating-------------
          if trellis(i).valid_data = '1' then 
            --multiply the next states by mem_regs to get the predicted outputs and states.  States used as indices for array placement
            nxt_state0    := next_state(std_logic_vector(to_unsigned(i,m)),'0'); --get next state for 0 and 1 paths
            nxt_state1    := next_state(std_logic_vector(to_unsigned(i,m)),'1');  
            nxt_output0   := next_output(nxt_state0,gen_poly1,gen_poly2); --get next output for 0 and 1 paths
            nxt_output1   := next_output(nxt_state1,gen_poly1,gen_poly2);
            --compare that to bits_in to get the path_metric and bits_out 
            temp_p_metric := trellis(i).path_metric;    --store metric values
            temp_bits_out := trellis(i).bits_out;       --store bits out
            temp0         := temp_p_metric + branch_metric(bits_in,nxt_output0);
            temp1         := temp_p_metric + branch_metric(bits_in,nxt_output1);
            temp_state0   := correct_state(nxt_state0);
            temp_state1   := correct_state(nxt_state1);
            if i=0 then temp_trellis := (others => trellis_defaults); end if;
            
            if t < (wrd_sz-(m-1)) then--building up and going through the trellis
               
              -- Set the zero path ---
              if temp_trellis(temp_state0).valid_data = '1' then --if the 1st path has already assigned find the smallest metric and store it
                if (temp_trellis(temp_state0).path_metric > temp0) then
                  temp_trellis(temp_state0).path_metric := temp0; --replace this path metric because its lower
                  temp_trellis(temp_state0).bits_out    := temp_bits_out;
                  temp_trellis(temp_state0).bits_out(t) := '0'; -- place the 0 in t position of trellis.               
                end if;
              else --if not set fill in trellis position and mark as set
                temp_trellis(temp_state0).path_metric   := temp0; -- fill empty trellis state
                temp_trellis(temp_state0).bits_out      := temp_bits_out;
                temp_trellis(temp_state0).bits_out(t)   := '0';   -- place the 0 in t position of trellis.
                temp_trellis(temp_state0).valid_data    := '1';   -- set flag that this is set
              end if;
              ------------------------
          
              -- Set the one path ----
              if temp_trellis(temp_state1).valid_data = '1' then 
                if (temp_trellis(temp_state1).path_metric > temp1) then 
                  temp_trellis(temp_state1).path_metric := temp1; --replace this path metric because its lower
                  temp_trellis(temp_state1).bits_out    := temp_bits_out;          
                  temp_trellis(temp_state1).bits_out(t) := '1'; -- place the 1 in t position of trellis.               
                end if;
              else --if not set fill in trellis position and mark as set
                temp_trellis(temp_state1).path_metric   := temp1; -- fill empty trellis state
                temp_trellis(temp_state1).bits_out      := temp_bits_out;
                temp_trellis(temp_state1).bits_out(t)   := '1';   -- place the 1 in t position of trellis representing the bit for this position.
                temp_trellis(temp_state1).valid_data    := '1';   -- set flag that this is set       
              end if;
              ------------------------
          
            elsif ((t >= wrd_sz-(m-1)) and (t < wrd_sz+(m-2))) then --terminating trellis

              -- Set the zero path ----
              if trellis(temp_state0).valid_data = '1' then --if the 1st path has already assigned find the smallest metric and store it
                if (trellis(temp_state0).path_metric > temp0) then 
                  temp_trellis(temp_state0).path_metric   := temp0; --replace this path metric because its lower
                  temp_trellis(temp_state0).bits_out      := temp_bits_out;                                                              
                  temp_trellis(temp_state0).bits_out(t)   := '0'; -- place the 0 in t position of trellis. 
                  temp_trellis(temp_state0).valid_data    := '1';              
                end if;
              else --if not set fill in trellis position and mark as set
                temp_trellis(temp_state0).path_metric     := temp0; -- fill empty trellis state
                temp_trellis(temp_state0).bits_out        := temp_bits_out;
                temp_trellis(temp_state0).bits_out(t)     := '0';   -- place the 0 in t position of trellis.
                temp_trellis(temp_state0).valid_data      := '1';   -- set flag that this is set
              end if;
             
            ------------------------
            else--we've reached the end of the word input and need to output decoded word
              for cnt in trellis'range loop
                if trellis(cnt).valid_data = '1' then
                  ml_word_out <= trellis(cnt).bits_out;
                  trellis     <= (0 => trellis_start,others => trellis_defaults);
                  t           := 0; --start at zero
                end if;
              end loop;
              exit tr_loop; -- exit the for loop we've already found the word.
            end if; --end trellis if statements
          
          end if;--end trellis(i).valid_data='1'
        
         end loop;
          trellis <= temp_trellis;
          t := t+1;
          if t = wrd_sz+(m-2) then ready <= '0'; end if; --send signal so no more bits are input
        end if; --valid_data = 1
      end if; -- end rising edge clock if statement
    end process decode;
      
end Behavioral;
