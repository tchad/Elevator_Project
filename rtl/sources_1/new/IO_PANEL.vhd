library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

-------------------------------------------------------------------
-- The IO_PANEM module serve as an aggregator for requests in regular mode of operation
-- The requests are grouped into two sets up set and down set. The reason behind two sets is to
-- prevent the elevator from frequently changing its travel direction. When elevator is 
-- traveling in one direction it will attempt to finish requests in that direction first before switching.
-- There are four types of sources for requests per floor, current state of request(on or off), request 
-- from up and down buttons coming from outside of elevator and requests coming from within the elevator.
-- The requests coming from withing the elevator are assigned to up or down set based on the current position fo elevator.
-- 
-- In addition the state machine can order the io panel to clear floor request corresponding to current floor
-- either from up or down set. This happens when the door cycle is finished by the state machine and floor request is considered finished.

-- The disable signal willt turn off propagating requests from all sources excelt feedback of the curren request
-------------------------------------------------------------------  

entity IO_PANEL is
  Port (F_UP : in floor_pin_t;
        F_DN : in floor_pin_t;
        F_EL : in floor_pin_t;
        CURR_F : in floor_vec_t;
        
        DISABLE_INPUT : in std_logic;
        CLR : in std_logic;
        
        CLR_UP : in std_logic;
        CLR_DN : in std_logic;
        
        CLK : in std_logic;
        
        UP_F : out floor_pin_t;
        DN_F : out floor_pin_t;
        
        REQ_PENDING : out std_logic;
        
        HARD_RESET : in std_logic
        );
end IO_PANEL;

architecture Behavioral of IO_PANEL is

    signal up_set : floor_pin_t;
    signal dn_set : floor_pin_t;
    
    -- function propagate the signal if the signal is coming from floor matching or above the current floor
    function propagateIfAbove(current_f : floor_vec_t; in_f_num : integer; in_f : std_logic) return std_logic is
        variable ret : std_logic;
        variable f : floor_uint_t;
    begin
        f := floor_uint_t(current_f);
        if( in_f_num >= f) then -- if elevator in the requested floor we assign anyway to trigger door open
            ret := in_f;
        else 
            ret := '0';
        end if;
        
        return ret;        
    end propagateIfAbove;
    
    -- function propagate the signal if the signal is coming from floor below the current floor
    function propagateIfBelow(current_f : floor_vec_t; in_f_num : integer; in_f : std_logic) return std_logic is
        variable ret : std_logic;
        variable f : floor_uint_t;
    begin
        f := floor_uint_t(current_f);
        if( in_f_num < f) then
            ret := in_f;
        else 
            ret := '0';
        end if;
                
        return ret;
    end propagateIfBelow;
    
    -- function will emit high signal for the given floor request in the up set based on the four inputs and the clear request
    function assignToUpSet(f_feedback : std_logic; 
                           f_elevator_panel : std_logic;
                           f_outside_panel : std_logic;
                           floor_clr : std_logic;
                           f_current : floor_vec_t;
                           f_num : integer;
                           disable : std_logic) return std_logic is
        variable result : std_logic;
        variable f_prop_el : std_logic;
    begin
        -- clear if requested floor is equal to current floor and there is a clear request
        if(f_num = unsigned(f_current) and floor_clr = '1') then
            result := '0';
        -- assign only feedback if the io panel input is disabled through disable signal 
        elsif(disable = '1') then
            result := f_feedback;
        else
            f_prop_el := propagateIfAbove(f_current, f_num, f_elevator_panel);
            result := f_feedback or f_outside_panel or f_prop_el; 
        end if;
        
        return result;
    end assignToUpSet;
    
    -- function will emit high signal for the given floor request in the down set based on the four inputs and the clear request
    function assignToDnSet(f_feedback : std_logic; 
                           f_elevator_panel : std_logic;
                           f_outside_panel : std_logic; 
                           floor_clr : std_logic;
                           f_current : floor_vec_t;
                           f_num : integer;
                           disable : std_logic) return std_logic is
        variable result : std_logic;
        variable f_prop_el : std_logic;
    begin
        if(f_num = unsigned(f_current) and floor_clr = '1') then
            result := '0';
        elsif(disable = '1') then
            result := f_feedback;
        else
            f_prop_el := propagateIfBelow(f_current, f_num, f_elevator_panel);
            result := f_feedback or f_outside_panel or f_prop_el; 
        end if;
            
        return result;
    end assignToDnSet;
                      
begin
    MAIN: process(CLK, HARD_RESET)
        variable tmp_up_set : floor_pin_t;
        variable tmp_dn_set : floor_pin_t;
    begin
        if (HARD_RESET = '1') then
            up_set <= FLOOR_PIN_ZERO;
            dn_set <= FLOOR_PIN_ZERO; 
        elsif (rising_edge(CLK)) then
            -- clear state on CLE signal
            if (CLR = '1') then
                tmp_up_set := FLOOR_PIN_ZERO;
                tmp_dn_set := FLOOR_PIN_ZERO;
            else
            -- assign state to all pins of each request set
                tmp_up_set(0) :=  assignToUpSet(up_set(0), F_EL(0), F_UP(0), CLR_UP, CURR_F, 0, DISABLE_INPUT);
                tmp_up_set(1) :=  assignToUpSet(up_set(1), F_EL(1), F_UP(1), CLR_UP, CURR_F, 1, DISABLE_INPUT);
                tmp_up_set(2) :=  assignToUpSet(up_set(2), F_EL(2), F_UP(2), CLR_UP, CURR_F, 2, DISABLE_INPUT);
                tmp_up_set(3) :=  assignToUpSet(up_set(3), F_EL(3), F_UP(3), CLR_UP, CURR_F, 3, DISABLE_INPUT);
                tmp_up_set(4) :=  assignToUpSet(up_set(4), F_EL(4), F_UP(4), CLR_UP, CURR_F, 4, DISABLE_INPUT);
                tmp_up_set(5) :=  assignToUpSet(up_set(5), F_EL(5), F_UP(5), CLR_UP, CURR_F, 5, DISABLE_INPUT);
                tmp_up_set(6) :=  assignToUpSet(up_set(6), F_EL(6), F_UP(6), CLR_UP, CURR_F, 6, DISABLE_INPUT);
                tmp_up_set(7) :=  assignToUpSet(up_set(7), F_EL(7), F_UP(7), CLR_UP, CURR_F, 7, DISABLE_INPUT);
                tmp_up_set(8) :=  assignToUpSet(up_set(8), F_EL(8), F_UP(8), CLR_UP, CURR_F, 8, DISABLE_INPUT);
                
                tmp_dn_set(0) :=  assignToDnSet(dn_set(0), F_EL(0), F_DN(0), CLR_DN, CURR_F, 0, DISABLE_INPUT);
                tmp_dn_set(1) :=  assignToDnSet(dn_set(1), F_EL(1), F_DN(1), CLR_DN, CURR_F, 1, DISABLE_INPUT);
                tmp_dn_set(2) :=  assignToDnSet(dn_set(2), F_EL(2), F_DN(2), CLR_DN, CURR_F, 2, DISABLE_INPUT);
                tmp_dn_set(3) :=  assignToDnSet(dn_set(3), F_EL(3), F_DN(3), CLR_DN, CURR_F, 3, DISABLE_INPUT);
                tmp_dn_set(4) :=  assignToDnSet(dn_set(4), F_EL(4), F_DN(4), CLR_DN, CURR_F, 4, DISABLE_INPUT);
                tmp_dn_set(5) :=  assignToDnSet(dn_set(5), F_EL(5), F_DN(5), CLR_DN, CURR_F, 5, DISABLE_INPUT);
                tmp_dn_set(6) :=  assignToDnSet(dn_set(6), F_EL(6), F_DN(6), CLR_DN, CURR_F, 6, DISABLE_INPUT);
                tmp_dn_set(7) :=  assignToDnSet(dn_set(7), F_EL(7), F_DN(7), CLR_DN, CURR_F, 7, DISABLE_INPUT);
                tmp_dn_set(8) :=  assignToDnSet(dn_set(8), F_EL(8), F_DN(8), CLR_DN, CURR_F, 8, DISABLE_INPUT);
            end if;
            
            up_set <= tmp_up_set;
            dn_set <= tmp_dn_set;
        end if;
    end process;
    
    ASYNC_REQ_PENDING: REQ_PENDING <= '1' when ((unsigned(up_set) > 0) or (unsigned(dn_set) > 0)) else '0';
    ASYNC_UP_OUT: UP_F <= up_set;
    ASYNC_DN_OUT: DN_F <= dn_set;

end Behavioral;
