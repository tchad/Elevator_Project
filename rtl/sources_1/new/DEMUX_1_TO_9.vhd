library IEEE;
use IEEE.std_logic_1164.all;

----------------------------------------
--Demultiplexer component allowing to accomodate elevator controller
--input requirements by compressing nine signals coming from each floor
-- or from withing elevator into five. The floor number is set through
--four address pins. The selected output is forwarding the input signal while
-- the rest are rutned Low. Addresses out of range are automatically ignored.
-----------------------------------------

entity DEMUX_1_TO_9 is
    Port ( INPUT : in std_logic;
           SEL : in std_logic_vector (3 downto 0);
           OUTPUT : out std_logic_vector (8 downto 0));
end DEMUX_1_TO_9;

architecture Behavioral of DEMUX_1_TO_9 is
begin
    MAIN: process(INPUT, SEL)
        variable result : std_logic_vector (8 downto 0);
    begin
        result := "000000000";
        case SEL is
            when x"0" => result(0) := INPUT;
            when x"1" => result(1) := INPUT;
            when x"2" => result(2) := INPUT;
            when x"3" => result(3) := INPUT;
            when x"4" => result(4) := INPUT;
            when x"5" => result(5) := INPUT;
            when x"6" => result(6) := INPUT;
            when x"7" => result(7) := INPUT;
            when x"8" => result(8) := INPUT; 
            when others => result(0) := '0'; -- undefined condition
        end case;
        
        OUTPUT <= result;
    end process;
end Behavioral;
