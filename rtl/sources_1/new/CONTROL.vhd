library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

------------------------------------------------
-- This module is the central state machine driving the entire module
-- The state machine is split between two subsets of states
-- One subset of states is servicing all modes excluding emergency mode
-- second is for the purposes of emergency mode only.
--States:
--S_SELECT - initial state where state machine can transition into S_TRAV state when elevator needs to travel to other floor
--           alternatively it could transition to the floor state immediately if request is made for the same floor as current
--           and all that is needed is the door cycle only. Also when emergrncy mode is enabled the state transition to
--           S_E_WAIT state.
--S_TRAV -   state during which the trav signal is emitted that sauce shaft module to move motor in given direction.
--S_FLOOR-   state occuring when the FA signal was recieved indicating that we are arriving at floor. Durinf this state the state
--           machine determines whether to stop and initiate door cycle and if request should be cleared
--           or directly transition to S_SELECT for next cycle.
--S_DOOR     the state during which door cycle is initiated. The state loops and waits for the doors to close (DC signal).
--           When doors are closed it transition back to S_SELECT or S_E_WAIT is emergency mode is active.
--
-- Second subset is the set of states servicing emergency mode. The emergency mode is a special mode when the entire system 
-- of floor requests is disconnected and replaced by much simpler fifo mechanism. Emergency mode is intended to use
-- is there is an error in circuit that prevent the elevator from operating correctly. The redundant set of states guarantees
-- minimal exposeure to regression errors that might occur duuring updates.
-- S_E_WAIT - similar to S_SELECT but working only with emergency module.
-- S_E_TRAV - emergency mode version to TRAV state
-- S_E_FLOOR - emergency mode version of S_FLOOR. This state still transition to the S_DOOR state to avoid significant redundancy in code.
---------------------------------------------------- 
 

entity CONTROL is
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
        E_CLR : out std_logic;
        
        CLR_UP : out std_logic;
        CLR_DN : out std_logic;
        
        HARD_RESET : in std_logic);
end CONTROL;

architecture Behavioral of CONTROL is
    type STATE_T is (S_SELECT, S_TRAV, S_FLOOR, S_DOOR, S_E_WAIT, S_E_TRAV, S_E_FLOOR);
    signal cs, ns : STATE_T;
    signal m_direction : dir_vec_t;
    signal m_rst_direction : dir_vec_t;
    signal m_ns_direction : dir_vec_t;
    signal m_e_direction : dir_vec_t;
    
begin

    SEQ_LOGIC: process(CLK, HARD_RESET)
    begin
        if(HARD_RESET = '1') then
            cs <= S_SELECT;
            m_direction <= "00";
            m_rst_direction <= "00";
            m_ns_direction <= "00";
            m_e_direction <= "00";
        elsif(rising_edge(CLK)) then
            cs <= ns;
            
            
            -- the direction for next cycle is gathered synchronously to prevent feedback loop between
            -- state machine travel direction and DIRECTION_DETECTOR output
            -- in addition the new travel direction is obtained only during select and door states
            -- during which the elevator is not currently travelling and floor request clear operation is finished.
            if(cs = S_SELECT or cs = S_DOOR) then
                m_direction <= (DIR_DN, DIR_UP);
                m_rst_direction <= (RST_DIR_DN, RST_DIR_UP);
                m_ns_direction <= (NS_DIR_DN, NS_DIR_UP);
            end if;
            
            if(cs = S_E_WAIT or cs = S_DOOR) then
                m_e_direction <= (E_DIR_DN, E_DIR_UP);
            end if;
        end if;
    end process;

    COMB_LOGIC: process(cs, m_direction, REACHED, IN_CLR_UP, IN_CLR_DN, FA, DC, HARD_RESET,
                        RST_ON, RST_REACHED, m_rst_direction,
                        NS_ON, NS_REACHED, m_ns_direction,
                        E_ON, E_REACHED, m_e_direction)
        variable result_ns : STATE_T;
        variable result_m_clr_updn : std_logic_vector (1 downto 0);
        variable result_rst_clr : std_logic;       
        variable result_ns_clr : std_logic;
        variable result_e_clr : std_logic;
    begin
    
        result_m_clr_updn := "00";
        result_rst_clr := '0';
        result_ns_clr := '0';
        result_e_clr := '0';
        
        case cs is
            when S_SELECT => 
                if(E_ON = '1') then -- transition to emergency mode if enabled
                    result_ns := S_E_WAIT;
                elsif(RST_ON = '1') then -- if reset requested
                    if(RST_REACHED = '1') then -- request for the current floor is made, initiate door cycle
                        result_ns := S_FLOOR;
                    elsif( m_rst_direction(0) = '1' or m_rst_direction(1) = '1') then 
                        result_ns := S_TRAV; -- if any direction present then travel
                    else
                        result_ns := S_SELECT; -- otherwise loop in state
                    end if;
                elsif(NS_ON = '1') then -- if non stop requested
                    if(NS_REACHED = '1') then -- request for the current floor is made, initiate door cycle
                        result_ns := S_DOOR;
                    elsif( m_ns_direction(0) = '1' or m_ns_direction(1) = '1') then
                        result_ns := S_TRAV; -- if any direction present then travel
                    else
                        result_ns := S_SELECT; -- otherwise loop in state
                    end if;
                else -- in normal mode operation
                    if(REACHED = '1') then
                        result_ns := S_FLOOR; -- request for the current floor is made, initiate door cycle
                    elsif( m_direction(0) = '1' or m_direction(1) = '1') then
                        result_ns := S_TRAV; -- if any direction present then travel
                    else
                        result_ns := S_SELECT; -- otherwise loop in state
                    end if;
                end if;
            when S_TRAV => 
                if(FA = '0') then -- if floor arrived signal not present loop
                    result_ns := S_TRAV;
                else -- otherwise transition to FLOOR state (floor arrived signal present)
                    result_ns := S_FLOOR;
                end if;
            when S_FLOOR =>
                if(RST_ON = '1') then 
                    if( FA = '1') then --wait for floor arrived signal to clear
                        result_ns := S_FLOOR;
                    -- If fa cleared and destination floor reached clear reset mode 
                    -- Reset mode does not initiate door cycle
                    elsif(RST_REACHED = '1' and FA = '0') then
                        result_rst_clr := '1';
                    end if;
                    result_ns := S_SELECT;
                elsif(NS_ON = '1') then
                    if( FA = '1') then --wait for floor arrived signal to clear
                        result_ns := S_FLOOR;
                    -- If fa cleared and destination floor reached clear non stop mode
                    -- and transition to door cycle
                    -- otherwise if destination floor is not reached loop back without
                    -- door cycle 
                    elsif(NS_REACHED = '1' and FA = '0') then
                        result_ns_clr := '1';
                        result_ns := S_DOOR;
                    else
                        result_ns := S_SELECT;
                    end if;
                else
                    if( FA = '1') then --wait for floor arrived signal to clear
                        result_ns := S_FLOOR;
                    -- If fa cleared and destination floor reached clear request
                    -- and transition to door cycle
                    -- otherwise if destination floor is not reached loop back without
                    -- door cycle
                    elsif(REACHED = '1' and FA = '0') then
                        result_ns := S_DOOR;
                        result_m_clr_updn := (IN_CLR_DN, IN_CLR_UP);
                    else
                        result_ns := S_SELECT;
                    end if;
                end if;
            when S_DOOR =>
                -- if door closed and not in emergency mode loop back
                if(DC = '1' and E_ON = '0') then 
                    result_ns := S_SELECT;
                -- if door closed and in emergency mode loop back to emergency mode S_E_WAIT
                elsif(DC = '1' and E_ON = '1') then
                    result_ns := S_E_WAIT;
                else -- DC= 0 and E_ON = 0 wait on door close
                    result_ns := S_DOOR;
                end if;
            when S_E_WAIT =>
                if(E_ON = '1') then -- while emergency mode enabled stay in emergency mode
                    if(m_e_direction = "11") then -- initiate door cycle if request made for current floor (special value for stability reasons)
                        result_ns := S_E_FLOOR;
                    elsif( m_e_direction(0) = '1' or m_e_direction(1) = '1') then -- travel is any direction present
                        result_ns := S_E_TRAV;
                    else
                        result_ns := S_E_WAIT;
                    end if;
                else -- transition back to normal operation if emergency mode disabled
                    result_ns := S_SELECT;
                end if;
            when S_E_TRAV =>
                if(FA = '0') then
                    result_ns := S_E_TRAV;
                else
                    result_ns := S_E_FLOOR;
                end if;
            when S_E_FLOOR =>
                if( FA = '1') then
                    result_ns := S_E_FLOOR; --wait for FA to clear
                -- if fa cleared and current floor is the destination floor initiate door cycle 
                elsif(E_REACHED = '1' and FA = '0') then
                    result_ns := S_DOOR;
                    result_e_clr := '1';
                -- otherwise loop back
                else
                    result_ns := S_E_WAIT;
                end if;
        end case;
        
        ns <= result_ns;
        
        CLR_UP <= result_m_clr_updn(0);
        CLR_DN <= result_m_clr_updn(1);
        RST_CLR <= result_rst_clr;
        NS_CLR <= result_ns_clr;
        E_CLR <= result_e_clr;
    end process;

    
    TRAV <= '1' when cs = S_TRAV or cs = S_E_TRAV else '0'; 
    DOOR_OPEN <= '1' when cs = S_DOOR else '0';
    
    process(m_direction, m_rst_direction, m_ns_direction, m_e_direction, RST_ON, NS_ON, E_ON)
    begin
        if(RST_ON = '1') then
            TRAV_UP <= m_rst_direction(0);
            TRAV_DN <= m_rst_direction(1);
        elsif(NS_ON = '1') then
            TRAV_UP <= m_ns_direction(0);
            TRAV_DN <= m_ns_direction(1);
        elsif(E_ON = '1') then
            if(m_e_direction = "11") then
                TRAV_UP <= '0';
                TRAV_DN <= '0';
            else
                TRAV_UP <= m_e_direction(0);
                TRAV_DN <= m_e_direction(1);
            end if;
        else
            TRAV_UP <= m_direction(0);
            TRAV_DN <= m_direction(1);
        end if;
    end process;
    

end Behavioral;
