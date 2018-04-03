library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GLOBAL.all;

entity TB_CONTROL is
end TB_CONTROL;


-------------------------------------------------------
-- Testbench tests the ability of state machine to got thorugh cycle
--------------------------------------------------------

architecture Behavioral of TB_CONTROL is

component CONTROL is
  Port (DIR_UP : in std_logic;
        DIR_DN : in std_logic;
        REACHED : in std_logic;
        IN_CLR_UP : in std_logic;
        IN_CLR_DN : in std_logic;
        
        E_ON : in std_logic;
        E_DIR_UP : in std_logic;
        E_DIR_DN : in std_logic;
        E_REACHED : in std_logic;
        
        NS_ON : in std_logic;
        NS_DIR_UP : in std_logic;
        NS_DIR_DN : in std_logic;
        NS_REACHED : in std_logic;
        
        RST_ON : in std_logic;
        RST_DIR_UP : in std_logic;
        RST_DIR_DN : in std_logic;
        RST_REACHED : in std_logic;
        
        FA : in std_logic;
        DC : in std_logic;
        
        CLK : in std_logic;
        
        TRAV : out std_logic;
        TRAV_UP : out std_logic;
        TRAV_DN : out std_logic;
        
        DOOR_OPEN : out std_logic;
        
        RST_CLR : out std_logic;
        NS_CLR : out std_logic;
        
        CLR_UP : out std_logic;
        CLR_DN : out std_logic;
        HARD_RESET : in std_logic);
end component;
           signal clk : std_logic :='0';
                      
           signal t_DIR_UP : std_logic  :='0';
           signal t_DIR_DN : std_logic  :='0';
           signal t_REACHED : std_logic  :='0';
           signal t_IN_CLR_UP : std_logic  :='0';
           signal t_IN_CLR_DN : std_logic  :='0';
                   
           signal t_E_ON : std_logic  :='0';
           signal t_E_DIR_UP : std_logic  :='0';
           signal t_E_DIR_DN : std_logic  :='0';
           signal t_E_REACHED : std_logic  :='0';
                   
           signal t_NS_ON : std_logic  :='0';
           signal t_NS_DIR_UP : std_logic  :='0';
           signal t_NS_DIR_DN : std_logic  :='0';
           signal t_NS_REACHED : std_logic  :='0';
                   
           signal t_RST_ON : std_logic  :='0';
           signal t_RST_DIR_UP : std_logic  :='0';
           signal t_RST_DIR_DN : std_logic  :='0';
           signal t_RST_REACHED : std_logic  :='0';
                   
           signal t_FA : std_logic  :='0';
           signal t_DC : std_logic  :='0';
                             
           signal t_TRAV : std_logic;
           signal t_TRAV_UP : std_logic;
           signal t_TRAV_DN : std_logic;
                   
           signal t_DOOR_OPEN : std_logic;
                   
           signal t_RST_CLR : std_logic;
           signal t_NS_CLR : std_logic;
                   
           signal t_CLR_UP : std_logic;
           signal t_CLR_DN : std_logic;
           
           signal t_HARD_RESET : std_logic := '0';
begin

    MAIN_CLOCK: clk <= not clk after 1ps;
    
    DEVICE: CONTROL port map (
            DIR_UP => t_DIR_UP,
            DIR_DN => t_DIR_DN,
            REACHED => t_REACHED,
            IN_CLR_UP => t_IN_CLR_UP,
            IN_CLR_DN => t_IN_CLR_DN,
            
            E_ON => t_E_ON,
            E_DIR_UP => t_E_DIR_UP,
            E_DIR_DN => t_E_DIR_DN,
            E_REACHED => t_E_REACHED,
            
            NS_ON => t_NS_ON,
            NS_DIR_UP => t_NS_DIR_UP,
            NS_DIR_DN => t_NS_DIR_DN,
            NS_REACHED => t_NS_REACHED,
            
            RST_ON => t_RST_ON,
            RST_DIR_UP => t_RST_DIR_UP,
            RST_DIR_DN => t_RST_DIR_DN,
            RST_REACHED => t_RST_REACHED,
            
            FA => t_FA,
            DC => t_DC,
            
            CLK => clk,
            
            TRAV => t_TRAV,
            TRAV_UP => t_TRAV_UP,
            TRAV_DN => t_TRAV_DN,
            
            DOOR_OPEN => t_DOOR_OPEN,
            
            RST_CLR => t_RST_CLR,
            NS_CLR => t_NS_CLR,
            
            CLR_UP => t_CLR_UP,
            CLR_DN => t_CLR_DN,
            
            HARD_RESET => t_HARD_RESET
            );
            
    TEST: process
    begin
        
        t_HARD_RESET <= '1';
        wait for 4ps;
        t_HARD_RESET <= '0';
        
        t_DIR_UP <= '1'; -- cause transition to TRAV
        wait for 4ps;
        
        t_FA <= '1'; -- cause transition to FLOOR
        wait for 4ps;
        
        t_FA <= '0';
        t_REACHED <= '0'; -- cause transition back to select
        wait for 4ps;
        
        t_FA <= '1'; -- cause transition to FLOOR
        wait for 4ps;
        
        t_FA <= '0';
        t_REACHED <= '1'; -- cause transition to DOOR
        wait for 4ps;
        
        t_DIR_UP <= '0'; --simulate response for clear signal
        t_REACHED <= '0';  --simulate response for clear signal
        t_DC <= '1';
        wait for 4ps;
        
        t_DC <= '0';

        wait;
    end process;

end Behavioral;
