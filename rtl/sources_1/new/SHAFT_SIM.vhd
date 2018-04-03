library IEEE;
use IEEE.std_logic_1164.all;

---------------------------------------------------
--Module simulating  elevator shaft system. In order to operate correctly
-- the elevator controller need feedback from system that manages the "physical" part
-- of the elevator. Such system would recieve signals when to turn the motors and which direction 
-- as well as signal to open the doors(TRAV, UP, DN, DO). 
-- As feed back the system shat simulator send signal indicating arriving on a floor and signal
-- indicating that the doors are closed(FA, DC)
-- The artificial delay of a travel between floors or door cycle can be set through generic property 
----------------------------------------------------

entity SHAFT_SIM is
  Generic( DELAY : natural := 100000);
  Port (TRAV : in std_logic;
        UP : in std_logic;
        DN : in std_logic;
        DO : in std_logic;
        
        CLK : in std_logic;
        
        FA : out std_logic;
        DC : out std_logic);
end SHAFT_SIM;

--The implementation is organized into a state machine
--States:
--  S_STAND: indicate an idle state when the simulator can recieve either travel or door open signal
--  S_DELAY_TRAV: simulate travel delay between floors
--  S_FA: simulate the feedback floor arrived signal
--  S_DELAY_DOOR: simulate the door open/close delay cycle
--  S_DC: simulate the feedback door closed signal 

architecture Behavioral of SHAFT_SIM is
    type STATE_T is (S_STAND, S_DELAY_TRAV, S_DELAY_DOOR, S_FA, S_DC);
    
    signal cs, ns : STATE_T;
    signal delay_counter : natural;
    signal counter_enable : std_logic;

begin
    SEQ_LOGIC: process(CLK) 
    begin
        if(rising_edge(CLK)) then
            cs <= ns;
            
            if( counter_enable = '1') then
                delay_counter <= delay_counter + 1;
            else
                delay_counter <= 0;
            end if;
        end if;
    end process;

    COMB_LOGIC: process(cs, TRAV, DO, delay_counter)
        variable result_m_ns : STATE_T;
        variable result_m_fa : std_logic;
        variable result_m_dc : std_logic;
        variable result_ce : std_logic;
    begin
        result_m_fa := '0';
        result_m_dc := '0';
        result_ce := '0';
        
        case cs is
            when S_STAND =>
                if( TRAV = '0' and DO = '0') then
                    result_m_ns := S_STAND;
                elsif ( TRAV = '1' and DO = '0' ) then
                    result_m_ns := S_DELAY_TRAV; 
                elsif ( TRAV = '0' and DO = '1' ) then
                    result_m_ns := S_DELAY_DOOR;
                end if;
            
            when S_DELAY_TRAV =>
                if( delay_counter >= DELAY) then
                    result_m_ns := S_FA;
                else
                    result_m_ns := S_DELAY_TRAV;
                    result_ce := '1';
                end if;
            
            when S_DELAY_DOOR =>
                if( delay_counter >= DELAY ) then
                    result_m_ns := S_DC;
                else
                    result_m_ns := S_DELAY_DOOR;
                    result_ce := '1';
                end if;
            
            when S_FA =>
                result_m_ns := S_STAND;
                result_m_fa := '1';
            when S_DC =>
                result_m_ns := S_STAND;
                result_m_dc := '1';
        end case;
        
        FA <= result_m_fa;
        DC <= result_m_dc;
        counter_enable <= result_ce;
        ns <= result_m_ns;
    end process;
end Behavioral;
