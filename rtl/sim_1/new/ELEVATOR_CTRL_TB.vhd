library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GLOBAL.all;

----------------------------------------------------
--This is the main test bench 
--Due to significant number of combination the test bench is testing 
--Only the corner cases plus modes are verified
--To verify the proper operation we should look dor the DOOR_OPEN signal appearing next to 
-- expected floor and floors along with door open signals shopuld appear in expected order
-- compare signals:
-- t_DOOR_OPEN
-- t_FLOOR
-- t_REQ_RST
-- t_RREQ_NS
-----------------------------------------------------

entity TB_ELEVATOR_CTRL is
end TB_ELEVATOR_CTRL;

architecture Behavioral of TB_ELEVATOR_CTRL is

component ELEVATOR_CTRL is
  Port (F_UP : in std_logic_vector(8 downto 0);
        F_DN : in std_logic_vector(8 downto 0);
        F_EL : in std_logic_vector(8 downto 0);
        
        REQ_NS : in std_logic;
        REQ_RST : in std_logic;
        E_ENABLE : in std_logic;
        E_DISABLE : in std_logic;
        
        FA : in std_logic;
        DC : in std_logic;
        
        CLK : in std_logic;
        
        FLOOR : out std_logic_vector(3 downto 0);
        DIR_UP : out std_logic;
        DIR_DN : out std_logic;
        DOOR_OPEN : out std_logic;
        TRAV : out std_logic;
        
        HARD_RESET : in std_logic;
        
        NS_EN : out std_logic;
        RST_EN : out std_logic;
        E_EN : out std_logic);
end component;

    signal clk : std_logic :='0';
           
    signal t_F_UP : std_logic_vector(8 downto 0) := FLOOR_PIN_ZERO;
    signal t_F_DN : std_logic_vector(8 downto 0) := FLOOR_PIN_ZERO;
    signal t_F_EL : std_logic_vector(8 downto 0) := FLOOR_PIN_ZERO;
                   
    signal t_REQ_NS : std_logic := '0';
    signal t_REQ_RST : std_logic := '0';
    signal t_E_ENABLE : std_logic := '0';
    signal t_E_DISABLE : std_logic := '0';
                   
    signal t_FA : std_logic := '0';
    signal t_DC : std_logic := '0';
                                     
    signal t_FLOOR : std_logic_vector(3 downto 0);
    signal t_DIR_UP : std_logic;
    signal t_DIR_DN : std_logic;
    signal t_DOOR_OPEN : std_logic;
    signal t_TRAV : std_logic;
                   
    signal t_HARD_RESET : std_logic := '0';
           
    signal t_NS_EN : std_logic;
    signal t_RST_EN : std_logic;
           
    signal t_E_EN : std_logic;
           
begin

    MAIN_CLOCK: clk <= not clk after 1ps;
    FLOOR_TRAV: process(t_TRAV, t_DOOR_OPEN)
    begin
        if(rising_edge(t_TRAV)) then
            t_FA <= transport '1' after 4ps;
            t_FA <= transport '0' after 6ps;
        end if;
        
        if(rising_edge(t_DOOR_OPEN)) then
            t_DC <= transport '1' after 4ps;
            t_DC <= transport '0' after 6ps;
        end if;
     end process;
            
    
    DEVICE: ELEVATOR_CTRL port map (
            F_UP => t_F_UP,
            F_DN =>  t_F_DN,
            F_EL =>  t_F_EL,
            
            REQ_NS =>  t_REQ_NS,
            REQ_RST =>  t_REQ_RST,
            E_ENABLE =>  t_E_ENABLE,
            E_DISABLE =>  t_E_DISABLE,
            
            FA =>  t_FA,
            DC =>  t_DC,
            
            CLK =>  clk,
            
            FLOOR => t_FLOOR,
            DIR_UP => t_DIR_UP,
            DIR_DN => t_DIR_DN,
            DOOR_OPEN => t_DOOR_OPEN,
            TRAV => t_TRAV,
            HARD_RESET => t_HARD_RESET,
            
            NS_EN => t_NS_EN,
            RST_EN => t_RST_EN,
            E_EN => t_E_EN);
            
    TEST: process
    begin
        t_HARD_RESET <= '1';
        wait for 2ps;
        t_HARD_RESET <= '0';
        wait for 2ps;
        --case 1 when travel up push pass floors with down requests untile later
        t_F_UP <= "000100010"; -- REQ F 1 and 5 up
        wait for 2ps;
        t_F_UP <= "000000000"; 
        t_F_DN <= "000010000"; -- REQ F 4 dn
        wait for 2ps;
        t_F_DN <= "000000000";
        wait for 50ps; 
        t_F_EL <= "100000100"; -- REQ F 2 dn, 8 up (elevator above floor 2 at this point in time)
        wait for 2ps;
        t_F_EL <= "000000000";
        
        -- case 1 but in down direction
        wait for 140ps;
        t_F_UP <= "100000000"; -- REQ F 8 up
        wait for 2ps;
        t_F_UP <= "000000000"; 
        wait for 100ps;
        t_F_DN <= "000010010"; -- REQ F 4 and 1 dn
        wait for 2ps;
        t_F_DN <= "000000000";
        t_F_UP <= "000100000"; -- REQ F 5 up
        wait for 2ps;
        t_F_UP <= "000000000"; 
        wait for 150ps;
        
        -- rest reset
        t_REQ_RST <= '1';
        wait for 2ps;
        t_REQ_RST <= '0';
        wait for 50ps;
        
        --case 2 if going up but highest request is down service also that request then start going down
        t_F_UP <= "000100010"; -- REQ F 1 and 5 up
        wait for 2ps;
        t_F_UP <= "000000000"; 
        t_F_DN <= "100000001"; -- REQ F L and 8 dn
        wait for 2ps;
        t_F_DN <= "000000000";
        wait for 200ps;
        
        --test ns feature
        t_REQ_NS <= '1';
        wait for 4ps;
        t_F_EL <= "100000000"; -- REQ F 8 up as non stop
        wait for 2ps;
        t_REQ_NS <= '0';
        t_F_EL <= "000000000";
        wait for 2ps; 
        t_F_UP <= "000100000"; -- REQ F 5 up (this should get services after floor 8 even though it is on the way)
        wait for 2ps;
        t_F_UP <= "000000000";
        
        
        --EXPECTED FLOOR+DOOR_OPEN PATTERN:
        -- 1 5 8 4 2 8 4 1 5 1(no door open reset) 1 5 8 L(0) 5
        -- final wait
        wait;
    end process;


end Behavioral;
