library IEEE;
use IEEE.std_logic_1164.all;
use WORK.global.all;

---------------------------------------------------------
--Module supporting the non stop operation
-- The puspose of this module is to capture the non stop button and floor button combination
-- After succesful capture (there are no current pending requests) the module takes over state machine
-- superseeding the normal mode operation. It determines the direction and indicate arrival on requested floor
-- Upon arriving on requested floor the state machine will send clear signal that woudl disable the module.
--------------------------------------------------------

entity NS_MODULE is
  Port (REQ_NS : in std_logic;
        REQ_F : in floor_pin_t;
        CURR_F : in floor_vec_t;
        
        REQ_PENDING : in std_logic;
        CLK : in std_logic;
        
        CLR : in std_logic;
        
        DIR_UP : out std_logic;
        DIR_DN : out std_logic;
        NS : out std_logic;
        NS_FLOOR_REACHED : out std_logic;
        
        HARD_RESET : in std_logic);
end NS_MODULE;

architecture Behavioral of NS_MODULE is
    signal enabled : std_logic;
    signal target : floor_uint_t;
    signal direction : dir_vec_t;

begin
    MAIN_SYNC: process(CLK, HARD_RESET)
        variable result_enabled : std_logic;
        variable result_direction : dir_vec_t;
        variable result_target : floor_uint_t;
    begin
        
        result_target := target;
        result_enabled := enabled;
        result_direction := direction;
        
        if(HARD_RESET = '1') then
            enabled <= '0';
            direction <= "00";
            target <= "0000";
        elsif(rising_edge(CLK)) then
            if(CLR = '1') then
                result_enabled := '0';
                result_direction := "00";
            -- if the module is currently not enabled and no request is pending and there is a floor request on the input pins
            -- activate, compute direction and target floor number
            elsif( enabled = '0' and REQ_NS = '1' and REQ_PENDING = '0' and REQ_F /= FLOOR_PIN_ZERO) then
                result_target := floor_uint_t(convert1HotToBin(REQ_F));
                result_direction := calculateDirection(CURR_F, result_target);
                result_enabled := '1';
            end if;
            
            target <= result_target;
            enabled <= result_enabled;
            direction <= result_direction;
        end if;
        
    end process;

    NS_FLOOR_REACHED <= isOnFloor(CURR_F, target) when (enabled = '1') else '0';
    NS <= enabled;
    DIR_UP <= direction(0);
    DIR_DN <= direction(1);
end Behavioral;
