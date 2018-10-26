library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_display is
    Port ( number : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           digit : out STD_LOGIC_VECTOR (6 downto 0);
           anode_en : out STD_LOGIC_VECTOR (3 downto 0));
end seven_seg_display;

architecture Behavioral of seven_seg_display is
 
begin

  --divide clock for anode enable
  clk_div: process (clk) is
    variable clkdiv : unsigned(19 downto 0) := (others => '0'); --used to be 19 downto 0
    variable s : unsigned(1 downto 0) := "00";  -- this is used to control the anode_en using the clock division
    variable indx : integer := 0;
    variable temp_digit : std_logic_vector(3 downto 0) := (others => '0');  -- temp digit output
    variable temp_anode_en : std_logic_vector(3 downto 0) := (others => '1');  -- temp anode enable out
  begin  -- process clk_div
    if rising_edge(clk) then  -- rising clock edge
      clkdiv := clkdiv+1;  --1_048_575 --this makes it roughly 95Hz clock
    
      s := clkdiv(19 downto 18);
    
      case s is
        when "00" =>
          temp_digit := number(3 downto 0);
          indx := 0;
        when "01" =>
          temp_digit := number(7 downto 4);
          indx := 1;
        when "10" =>
          temp_digit := number(11 downto 8);
          indx := 2;
        when "11" =>
          temp_digit := number(15 downto 12);
          indx := 3;      
        when others =>
          temp_digit := number(3 downto 0);
          indx:= 0;
      end case;

      case temp_digit is        
        when "0000" => digit <= "1000000";--0                   
        when "0001" => digit <= "1111001";--1             
        when "0010" => digit <= "0100100";--2     
        when "0011" => digit <= "0110000";--3            
        when "0100" => digit <= "0011001";--4           
        when "0101" => digit <= "0010010";--5                                          
        when "0110" => digit <= "0000010";--6
        when "0111" => digit <= "1111000";--7
        when "1000" => digit <= "0000000";--8
        when "1001" => digit <= "0010000";--9
        when "1010" => digit <= "0100000";--a
        when "1011" => digit <= "0000011";--b
        when "1100" => digit <= "0100111";--c
        when "1101" => digit <= "0100001";--d
        when "1110" => digit <= "0000110";--E
        when "1111" => digit <= "0001110";--F
        When OTHERS => digit <= "1101111";--all off
      end case;
      --make sure that then anode is only enabled once every ~90-100Hz
      if clkdiv >= "00100000000000000000" then
        if temp_anode_en(indx) = '1' then
          temp_anode_en := (others => '1');
          temp_anode_en(indx) := '0';
        end if;
      else
        temp_anode_en := (others => '1');
      end if;
    
      anode_en <= temp_anode_en;
    end if;
  end process clk_div;

  
end Behavioral;
