library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------
-- Basic clocl divider tuned to recieve 100MHz driving signal
-- The desired frequency is set as a generic argument in unit Hertz
-------------------------------------------

entity CLK_DIVIDER is
    Generic (FREQ_HZ : natural := 10);
    Port ( CLK100MHZ : in STD_LOGIC;
           CLK : out STD_LOGIC);
end CLK_DIVIDER;

architecture Behavioral of CLK_DIVIDER is
    signal counter : natural;
    signal out_clk : std_logic;
begin
    MAIN: process(CLK100MHZ) 
    begin
        if(rising_edge(CLK100MHZ)) then
            if(counter > 100000000/FREQ_HZ) then
                counter <= 0;
                out_clk <= not out_clk;
            else 
                counter <= counter +1;
            end if;
        end if;
    end process;
    
    CLK <= out_clk;
end Behavioral;
