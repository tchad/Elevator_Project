library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

--------------------------------------------------------------------
--This module implements the emenrgrncy mode operation. The emergrncy mode is activated by turning
-- key toward direction that corresponds to the enable signal and disabled by turning key toward
-- the direction that corresponds to the disable signal
-- During emergency mode the elevator works in as a fifo system. If a floor was selected then the elevator
-- travels to it uninterrupted. All requests occuring during travel are ignored until current request is 
-- completed.
-- The purpose of this module is to engage the emergency mode that superseeds any other operation isn state machine.
-- Then the module captures fgloor request, compute the direction and determines if the elevator arrived on requested floor
-- When requests is fulfilled the state machine sends clear signal that clears current request but does not disable the
-- emergency mode.   

entity EM_MODULE is
  Port (REQ_F : in floor_pin_t;
        CURR_F : in floor_vec_t;
        E_ENABLE : in std_logic;
        E_DISABLE : in std_logic;
        
        CLR : in std_logic;
        CLK : in std_logic;
        
        DIR_UP : out std_logic;
        DIR_DN : out std_logic;
        
        E_ON : out std_logic;
        E_FLOOR_REACHED : out std_logic;
        
        HARD_RESET : in std_logic);
end EM_MODULE;

architecture Behavioral of EM_MODULE is
    signal enabled : std_logic;
    signal target : floor_uint_t;
    signal direction : dir_vec_t;
begin    
    
    ENABLE_SYNC: process(CLK, E_ENABLE, E_DISABLE, HARD_RESET)
        variable en : std_logic;
    begin
        en := enabled;
        if(HARD_RESET = '1') then
            enabled <= '0';
        elsif(rising_edge(CLK)) then
            if(E_ENABLE = '1') then
                en := '1';
            elsif(E_DISABLE = '1') then
                en := '0';
            end if;
        
            enabled <= en;
        end if;
    end process;
    
    MAIN_SYNC: process(CLK, HARD_RESET)
    variable result_direction : dir_vec_t;
    variable result_target : floor_uint_t;
    
    begin
        result_target := target;
        result_direction := direction;
        
        if(HARD_RESET = '1') then
            direction <= "00";
            target <= "0000";
        elsif(rising_edge(CLK)) then
            if(enabled = '1') then
                if(CLR = '1') then
                    result_direction := "00";
                -- if current target = current floor (no request in progress
                --and there is a request waiting on the input pins
                elsif(result_target = floor_uint_t(CURR_F) and REQ_F /= FLOOR_PIN_ZERO) then
                    --compute new target
                    result_target := floor_uint_t(convert1HotToBin(REQ_F));
                    
                    --if target turns out to be the same as current floor mark the direction as 11
                    -- which will cause the state machine to traverse to the door cycle
                    --but will not cause any elevator movement
                    if(result_target = floor_uint_t(CURR_F)) then
                        result_direction := "11";
                    else
                        --otherwise calculate new direction that will cause the elevator to move
                        result_direction := calculateDirection(CURR_F, result_target);
                    end if;
                end if;
            else
                result_target := floor_uint_t(CURR_F);
            end if;
            target <= result_target;
            direction <= result_direction;
        end if;
        
        
    end process;

    E_ON <= enabled; 
    E_FLOOR_REACHED <= isOnFloor(CURR_F, target);
    DIR_UP <= direction(0);
    DIR_DN <= direction(1);

end Behavioral;
