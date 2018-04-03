library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

-----------------------------------------------------------------
-- UP/DOWN counter used to store the current floor number we are on
-- In this iteration we do not assume an error occuring in the counter
-- causing the system to loose track of the floors

-- The component diverge from standard up/down counter by having 
-- the reset pin setting value of 1 instead of 0. The RST1 is used 
-- during the final stage of reset operation.

-- Also the reset operation (RST1) in this case is synchronous to prevent unexpected spikes 
-- at the output from breaking the controler stability.
-----------------------------------------------------------------

entity UD_COUNTER is
    Port ( U : in std_logic;
           D : in std_logic;
           RST1 : in std_logic;
           CLK : in std_logic;
           COUNT : out floor_vec_t;
           HARD_RESET : in std_logic);
end UD_COUNTER;

architecture Behavioral of UD_COUNTER is
    signal m_count : floor_vec_t;
begin

    MAIN: process(CLK, HARD_RESET)
        variable result: floor_uint_t;
    begin
        if( HARD_RESET = '1') then
                 result := x"0";
                 m_count <= floor_vec_t(result);
        elsif (rising_edge(CLK)) then           
            if(RST1 = '1') then
                result := x"1";
            else
                result := floor_uint_t(m_count);
                
                if (U = '1' and D = '0') then
                    result := result + x"1";
                elsif (U = '0' and D = '1') then
                    result := result - x"1";
                end if;
            end if;
            
            m_count <= floor_vec_t(result);
        end if;
    end process;
    
    OUTPUT_ASSIGN: COUNT <= m_count;

end Behavioral;
