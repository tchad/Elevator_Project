library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GLOBAL.all;

entity TB_UD_COUNTER is
end TB_UD_COUNTER;

architecture Behavioral of TB_UD_COUNTER is

component UD_COUNTER is
    Port ( U : in std_logic;
           D : in std_logic;
           RST1 : in std_logic;
           CLK : in std_logic;
           COUNT : out floor_vec_t;
           HARD_RESET : in std_logic);
end component;
           signal clk : std_logic :='0';
           signal t_U : std_logic :='0';
           signal t_D : std_logic :='0';
           signal t_RST1 : std_logic :='0';
           signal t_COUNT : floor_vec_t;
           signal t_HARD_RESET : std_logic :='0';
begin

    MAIN_CLOCK: clk <= not clk after 1ps;
    
    DEVICE: UD_COUNTER port map (
            U => t_U,
            D => t_D,
            RST1 => t_RST1,
            CLK => clk,
            COUNT => t_COUNT,
            HARD_RESET => t_HARD_RESET);
            
    TEST: process
    begin
        t_U <= '0';
        t_D <= '0';
        t_RST1 <= '0';
        
        wait for 2ps;
        
        t_RST1 <= '1';
        wait for 2ps;
        
        t_RST1 <= '0';
        t_U <= '1';
        wait for 30ps;
        t_U <= '0';
        t_D <= '1';
        wait for 30ps;
        t_U <= '1';
        t_D <= '0';
        wait for 5ps;
        t_U <= '0';
        t_D <= '1';
        wait for 20ps;
        
        -- final wait
        wait;
    end process;


end Behavioral;
