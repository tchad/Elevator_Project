library ieee;
use IEEE.std_logic_1164.all;
use WORK.global.all;

-------------------------------------------------------
-- This module tests the correctness of pin functioning in the IO_PANEL
-- Since every pin is connected to the same function it is represnetative to test single pin 
-- and there is no need to run full permutation of inputs
-------------------------------------------------------

entity TB_IO_MODULE is
end TB_IO_MODULE;

architecture TB of TB_IO_MODULE is

component IO_PANEL is
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
end component;

    signal F_UP          : floor_pin_t;
    signal F_DN          : floor_pin_t;
    signal F_EL          : floor_pin_t;
    signal CURR_F        : floor_vec_t;
    signal DISABLE_INPUT : std_logic;
    signal CLR           : std_logic;
    signal CLR_UP        : std_logic;
    signal CLR_DN        : std_logic;
    signal CLK           : std_logic := '0';
    signal UP_F          : floor_pin_t;
    signal DN_F          : floor_pin_t;
    signal REQ_PENDING   : std_logic;
    signal HARD_RESET    : std_logic;

begin

    dut : IO_PANEL
    port map (F_UP          => F_UP,
              F_DN          => F_DN,
              F_EL          => F_EL,
              CURR_F        => CURR_F,
              DISABLE_INPUT => DISABLE_INPUT,
              CLR           => CLR,
              CLR_UP        => CLR_UP,
              CLR_DN        => CLR_DN,
              CLK           => CLK,
              UP_F          => UP_F,
              DN_F          => DN_F,
              REQ_PENDING   => REQ_PENDING,
              HARD_RESET    => HARD_RESET);

stimuli : process
begin
       
    F_UP <= "000000000";
    F_DN <= "000000000";
    F_EL <= "000000000";
    CURR_F <= "0000";
    DISABLE_INPUT <= '0';
    CLR <= '0';
    CLR_UP <= '0';
    CLR_DN <= '0';
    HARD_RESET <= '1';
    wait for 1ps;
    
    HARD_RESET <= '0';
    wait for 1ps;
    
    F_UP <= "100000000";
    F_DN <= "100000001";
    F_EL <= "000100100"; -- will be assigned based on current floor position
    CURR_F <= "0100";
    
    CLK <= '1';
    wait for 1 ps;
    CLK <= '0';
    wait for 1 ps;
    
    --EXPECTED F8, F5 in Up set, F8 FL F2 in dn set
    
    F_UP <= "000000000";
    F_DN <= "000000000";
    F_EL <= "000000000"; -- will be assigned based on current floor position
    CURR_F <= "1000";
    CLR_UP <= '1';
    CLR_DN <= '0';

    CLK <= '1';
    wait for 1 ps;
    CLK <= '0';
    wait for 1 ps;
    
    --EXPECTED: F8 will be removed from up set but left intact in down set
    
    CURR_F <= "1000";
    CLR_UP <= '0';
    CLR_DN <= '1';
    
    CLK <= '1';
    wait for 1 ps;
    CLK <= '0';
    wait for 1 ps;
    
    --EXPECTED F8 will be removed from down set
    
    CLR <= '1';
    CLK <= '1';
    wait for 1 ps;
    CLK <= '0';
    wait for 1 ps;
    
    -- EXPECTED entire state to be cleared

		
    wait;
end process;

end tb;