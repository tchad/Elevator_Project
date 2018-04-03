library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

-----------------------------------------
--This module determines the next direction for the elevator and whether the current floor
-- request for the floor on which the elevavor is currently on has to be cleared and for which set

-- This is the central part of the design that allow the four state (notmal operation) state machine design
-- This is an alternative design allowing for significant reduction of but at the cost of more complicated
-- combinational logic.

-- ELABORATION 1 (explanation of alogorithm later in the code)
-- FLOOR_REACHED signal is equal to triggering the door cycle in state machine otherwise if the signal does not occur
-- the state machine will skip the door cycle and loop back.

-- There are two cases possible
-- CASE 1 floors 2 and 7 have request up and floor 5 has request down. Because the elevator is currently going up
-- and the request on floor 5 indicate that the passenger will go down with respect to floor 5. the elevator will skip
-- floor 5 while going up to prevend overcrowding. When all up requests are servicesd the elevator will begin going down 
-- and then stop on floor 5.

--CASE 2: floors 2 and 4 have request up and floor 6 have request down. Because the elevator is going up and the preference is to service 
-- all requests during travel upward. Even though the request on floor 6 is a down request, it is still required for the elevator to pick
-- up the passenger and since it is the "last" request in the "queue" it can be serviced. Therefore in this scenario the elevator will travel 
-- to floor 6 immediately after floor 4 unless a floor request higher than 6 will appear in the mean time.

--Same approach applies in other direction but inverted  
------------------------------------------------------------------------------- 

entity DIRECTION_DETECTOR is
  Port (UP_F : in floor_pin_t;
        DN_F : in floor_pin_t;
        CURR_F : in floor_vec_t;
        
        CURR_D_UP : in std_logic;
        CURR_D_DN : in std_logic;
        
        DIR_UP : out std_logic;
        DIR_DN : out std_logic;
        
        FLOOR_REACHED : out std_logic;
        CLR_UP : out std_logic;
        CLR_DN : out std_logic);
end DIRECTION_DETECTOR;

architecture Behavioral of DIRECTION_DETECTOR is
    
    -- determine the highest number of floor from the current requests in
    -- given(up or down) request set
    function highestFloorNumber(f : floor_pin_t) return floor_uint_t is
    begin
        for i in f'length -1 downto 0 loop
            if(f(i) = '1') then 
                return to_unsigned(i, floor_uint_t'length);
            end if;
        end loop;
        return x"0";
    end highestFloorNumber;
    
    -- determine the lowest number of floor from the current requests in
    -- given(up or down) request set
    function lowestFloorNumber(f : floor_pin_t) return floor_uint_t is
    begin
        for i in 0 to f'length -1 loop
            if(f(i) = '1') then 
                return to_unsigned(i, floor_uint_t'length);
            end if;
        end loop;
        return x"8";
    end lowestFloorNumber;
    
    -- function tests if given floor number is in request set
    function isInReqSet(current: floor_vec_t; req_set : floor_pin_t) return std_logic is
        variable current_1hot : floor_pin_t;
        variable ret : std_logic;
        
    begin
        current_1hot := convertBinTo1Hot(current);
        if ((current_1hot and req_set) /= FLOOR_PIN_ZERO) then
            return '1';
        else 
            return '0';
        end if;
    end isInReqSet;
    
begin

    MAIN_ASYNC: process(UP_F, DN_F, CURR_F, CURR_D_UP, CURR_D_DN)
        variable ret_d_up : std_logic;
        variable ret_d_dn : std_logic;
        variable ret_floor_reached : std_logic;
        variable ret_clr_up : std_logic;
        variable ret_clr_dn : std_logic;
        
        variable x : floor_uint_t;
        variable y : floor_uint_t;
        variable current : floor_uint_t;
        
    begin
        ret_d_up := '0';
        ret_d_dn := '0';
        ret_floor_reached := '0';
        ret_clr_up := '0';
        ret_clr_dn := '0';
        current := floor_uint_t(CURR_F);
        
        -------PART 1: Algorithm for determination of next floor direction
        
        -- if both request sets are empty indicate no nest cycle direction
        if(UP_F = FLOOR_PIN_ZERO and DN_F = FLOOR_PIN_ZERO) then
            ret_d_up := '0';
            ret_d_dn := '0';
        
        -- if the current direction is UP
        elsif(CURR_D_UP = '1' and CURR_D_DN ='0') then
            x := highestFloorNumber(UP_F);
            y := highestFloorNumber(DN_F);
            -- go up: if there is any request in up set that its floor number is higher than current floor
            -- or all requests in up set are below current floor but there is a request in down set that
            -- its floor number is above current floor  
            if((x > current) or (x <= current and y > current)) then
                 ret_d_up := '1'; 
            -- otherwise go down ( we know that the request sets are not empty because of the first if statement)
            else 
                 ret_d_dn := '1';  
            end if;                  
        -- if the current direction is down 
        elsif (CURR_D_UP = '0' and CURR_D_DN ='1') then
            x := lowestFloorNumber(DN_F);
            y := lowestFloorNumber(UP_F);
            -- go down: if there is any request in down set that its floor number is lower than current floor
            -- or all requests in down set are above current floor but there is a request in up set that
            -- its floor number is below current floor  
            if((x < current) or (x >= current and y < current)) then
                ret_d_dn := '1';
            -- otherwise go up ( we know that the request sets are not empty because of the first if statement)
            else --DN_F /= FLOOR_PIN_ZERO and x > current)
                ret_d_up := '1';
            end if;
        -- if current direction is neighter up or down (stand still)
        elsif (CURR_D_UP = '0' and CURR_D_DN ='0') then
            x := highestFloorNumber(UP_F);
            y := highestFloorNumber(DN_F);
            -- if there is a request in any request set that matches the current (stay on the floor)
            -- this condition is to ensure the door cycle for wituation when request button is pressed
            -- at a floor at hich the elevator is currently on to allow passengers to enter/leave
            if(isInReqSet(CURR_F, UP_F) = '1' or isInReqSet(CURR_F, DN_F) = '1') then
                ret_d_up := '0';
                ret_d_dn := '0'; 
            --otherwise if there is a request in any set that it's floor number is above current
            --  go up (favor up direction over down
            elsif( x > current or y > current) then
                 ret_d_up := '1';
            --otherwise if there is a request in any set that it's floor number is below current gow down 
            elsif (x < current or y < current) then
                 ret_d_dn := '1';
            end if;
        end if;
        
        ------PART 2 Algorithm to determine whether a floor requested is reached by elebator and if that
        -- request should be cleared
        
        -- if both request sets are empty do nothing
         if(UP_F = FLOOR_PIN_ZERO and DN_F = FLOOR_PIN_ZERO) then
            ret_floor_reached := '0';
            ret_clr_up := '0';
            ret_clr_dn := '0';
        -- if current direction is up
        elsif(CURR_D_UP = '1' and CURR_D_DN ='0') then
            -- clear from up and floor reached if there is a request in up set that matches current floor
            if(isInReqSet(CURR_F, UP_F) = '1') then
                ret_floor_reached := '1';
                ret_clr_up := '1';
            --clear down and floor reached if there is a request in down set and all requests
            -- in up set are below currend floor (SEE ELABORATION 1)
            elsif( (isInReqSet(CURR_F, DN_F) = '1') and (highestFloorNumber(UP_F) < current)) then
                ret_floor_reached := '1';
                ret_clr_dn := '1';
            end if;        
        
        -- if current direction is down            
        elsif (CURR_D_UP = '0' and CURR_D_DN ='1') then
            -- clear from down and floor reached if there is a request in down set that matches current floor
            if(isInReqSet(CURR_F, DN_F) = '1') then
                ret_floor_reached := '1';
                ret_clr_dn := '1';
            --clear up and floor reached if there is a request in up set and all requests
            -- in down set are above currend floor (SEE ELABORATION 1)
            elsif( (isInReqSet(CURR_F, UP_F) = '1') and (lowestFloorNumber(DN_F) > current)) then
                ret_floor_reached := '1';
                ret_clr_up := '1';
            end if;
        -- if current direction is neighter up or down (stand still)
        -- this part is foe the case when request was made from the same floor at which the elevator is
        --currently on to trigger door cycle and allow passengers to enter/leave
        elsif (CURR_D_UP = '0' and CURR_D_DN ='0') then
                --if there is a request in up set that matches current dloor then floor reached and clear up
                if(isInReqSet(CURR_F, UP_F) = '1') then
                    ret_floor_reached := '1';
                    ret_clr_up := '1';
                end if;
                --if there is a request in down set that matches current floor then floor reached and clear down
                if(isInReqSet(CURR_F, DN_F) = '1') then
                    ret_floor_reached := '1';
                    ret_clr_dn := '1';
                end if;
        end if;
        
        DIR_UP <= ret_d_up;
        DIR_DN <= ret_d_dn;
        FLOOR_REACHED <= ret_floor_reached;
        CLR_UP <= ret_clr_up;
        CLR_DN <= ret_clr_dn;
    end process;

end Behavioral;
