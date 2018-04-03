library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

---------------------------------------------
--Package with constants, types and functions used globally
---------------------------------------------

package GLOBAL is
    subtype floor_vec_t is std_logic_vector(3 downto 0);
    subtype floor_uint_t is unsigned (3 downto 0);
    subtype floor_pin_t is std_logic_vector (8 downto 0);
    subtype dir_vec_t is std_logic_vector (1 downto 0); -- idx(0)=up, idx(1)=dn
    
    constant RST_DST_FLOOR: unsigned := x"1";
    constant FLOOR_PIN_ZERO: floor_pin_t := (others => '0');
    
    function isOnFloor(curr_f: floor_vec_t; target_f: floor_uint_t) return std_logic;
    function calculateDirection(curr_f: floor_vec_t; target_f: floor_uint_t) return dir_vec_t;
    
    function convertBinTo1Hot(f: floor_vec_t) return floor_pin_t;
    function convert1HotToBin(f: floor_pin_t) return floor_vec_t;

end GLOBAL;



package body GLOBAL is
--test if the elevator is on the right floor
    function isOnFloor(curr_f: floor_vec_t; target_f: floor_uint_t) return std_logic is
            variable current_floor: floor_uint_t;
    begin
        current_floor := floor_uint_t(curr_f);
        if(current_floor = target_f) then
            return '1';
        else
            return '0';
        end if;        
    end isOnFloor;
    
    --calculate the direction of the lelvator with respect to current floor
    -- "01" - direction up, "10" direction down "00" -same floor
    function calculateDirection(curr_f: floor_vec_t; target_f: floor_uint_t) return dir_vec_t is
        variable ret: std_logic_vector (1 downto 0);
        variable current_floor: floor_uint_t;
    begin
        current_floor := floor_uint_t(curr_f);
        
        if(current_floor < target_f) then
            ret := "01";
        elsif(current_floor > target_f) then
            ret := "10";
        else
            ret := "00";
        end if;
        
        return ret;
    end calculateDirection;
    
    function convertBinTo1Hot(f: floor_vec_t) return floor_pin_t is
    begin
        case f is
            when x"0" => return "000000001";
            when x"1" => return "000000010";
            when x"2" => return "000000100";
            when x"3" => return "000001000";
            when x"4" => return "000010000";
            when x"5" => return "000100000";
            when x"6" => return "001000000";
            when x"7" => return "010000000";
            when x"8" => return "100000000";
            when others => report "BinTo1Hot invalid argument" & integer'image(to_integer(unsigned(f))); return "000000000";
        end case;
    end convertBinTo1Hot;
    
    function convert1HotToBin(f: floor_pin_t) return floor_vec_t is
    begin
        case f is
            when "000000001" => return x"0";
            when "000000010" => return x"1";
            when "000000100" => return x"2";
            when "000001000" => return x"3";
            when "000010000" => return x"4";
            when "000100000" => return x"5";
            when "001000000" => return x"6";
            when "010000000" => return x"7";
            when "100000000" => return x"8";
            when others => report "1HotToBin invalid argument" & integer'image(to_integer(unsigned(f))) ; return x"0";
        end case;
    end convert1HotToBin;
    
end GLOBAL;
