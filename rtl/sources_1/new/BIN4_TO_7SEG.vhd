library IEEE;
use IEEE.std_logic_1164.all;

----------------------------------------------
-- Simple 4 bit binaty to 7 segment decoder. 
-- As an additional functionality the decoder has an EN_L signal that when High
-- is showing letter L instead of 0;
----------------------------------------------

entity BIN4_TO_7SEG is
  Port (IN4 : in std_logic_vector (3 downto 0);
        EN_L : in std_logic;
        OUT7 : out std_logic_vector ( 6 downto 0));
end BIN4_TO_7SEG;

architecture Behavioral of BIN4_TO_7SEG is
begin
    MAIN: process( IN4, EN_L) is
        variable result : std_logic_vector ( 6 downto 0);
    begin
        case IN4 is
            when x"0" => 
                if(EN_L = '0')  then
                    result := "1111110";
                else
                    result := "0001110";
                end if;
            when x"1" => result := "0110000";
            when x"2" => result := "1101101";
            when x"3" => result := "1111001";
            when x"4" => result := "0110011";
            when x"5" => result := "1011011";
            when x"6" => result := "1011111";
            when x"7" => result := "1110000";
            when x"8" => result := "1111111";
            when x"9" => result := "1111011";
            when x"A" => result := "1110111";
            when x"B" => result := "0011111";
            when x"C" => result := "1001110";
            when x"D" => result := "0111101";
            when x"E" => result := "1001111";
            when x"F" => result := "1000111";
            when others => result := "0110111";
        end case;
        
        OUT7 <= result;
    end process;
end Behavioral;
