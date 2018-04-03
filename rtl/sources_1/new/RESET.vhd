library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

---------------------------------------------------------------
-- This component handles the reset operation cycle 
-- Once reset signal is present the reset operation will enable
-- The RST signal will stay on until the CLR signal is given from 
-- state machine.
---------------------------------------------------------------

entity RESET is
    Port ( REQ_RST : in std_logic;
           CURR_F : in std_logic_vector (3 downto 0);
           CLK : in std_logic;
           CLR : in std_logic;
           
           RST : out std_logic;
           DIR_UP : out std_logic;
           DIR_DN : out std_logic;
           RST_FLOOR_REACHED : out std_logic;
           
           HARD_RESET : in std_logic);
end RESET;

architecture Behavioral of RESET is
    signal m_rst: std_logic;
    signal m_dir: dir_vec_t;
        
begin
    MAIN_SYNC: process(CLK, HARD_RESET)
        variable reset : std_logic;
        variable direction : dir_vec_t;
    begin
        if(HARD_RESET = '1') then
            m_rst <= '0';
            m_dir <= "00";
        elsif (rising_edge(CLK)) then
            direction := calculateDirection(CURR_F, RST_DST_FLOOR);
            reset := m_rst;
            
            -- if m_rst = 0 then reset operation is not currently active
            -- when request is present it activates the reset operation
            --if reset operation is already active then the request is ignored
            if(m_rst = '0' and REQ_RST = '1') then
                reset := '1';
            elsif(CLR = '1') then
                reset := '0';
            end if;
            
            m_rst <= reset;
            m_dir <= direction;
        end if;
    end process;

    --asynchronously determine if elevator is on correct floor
    ASYNC_FLOOR_REACHED: RST_FLOOR_REACHED <= isOnFloor(CURR_F, RST_DST_FLOOR);
    --propagate internal state to outputs
    ASYNC_DIRECTION_B0: DIR_UP <= m_dir(0); 
    ASYNC_DIRECTION_B1: DIR_DN <= m_dir(1);
    ASYNC_RST: RST <= m_rst; 
        
end Behavioral;
