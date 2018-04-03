library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.global.all;

------------------------------------------------------------
-- This module is testing if the if statements activate properly
-----------------------------------------------------------

entity TB_DIRECTION_DETECTOR is
end;

architecture bench of TB_DIRECTION_DETECTOR is

  component DIRECTION_DETECTOR
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
  end component;

  signal UP_F: floor_pin_t;
  signal DN_F: floor_pin_t;
  signal CURR_F: floor_vec_t;
  signal CURR_D_UP: std_logic;
  signal CURR_D_DN: std_logic;
  signal DIR_UP: std_logic;
  signal DIR_DN: std_logic;
  signal FLOOR_REACHED: std_logic;
  signal CLR_UP: std_logic;
  signal CLR_DN: std_logic;
  
  signal ref_DIR_UP: std_logic;
  signal ref_DIR_DN: std_logic;
  signal ref_FLOOR_REACHED: std_logic;
  signal ref_CLR_UP: std_logic;
  signal ref_CLR_DN: std_logic;
  signal PHASE : std_logic;

begin
    uut: DIRECTION_DETECTOR port map ( UP_F          => UP_F,
                                       DN_F          => DN_F,
                                       CURR_F        => CURR_F,
                                       CURR_D_UP     => CURR_D_UP,
                                       CURR_D_DN     => CURR_D_DN,
                                       DIR_UP        => DIR_UP,
                                       DIR_DN        => DIR_DN,
                                       FLOOR_REACHED => FLOOR_REACHED,
                                       CLR_UP        => CLR_UP,
                                       CLR_DN        => CLR_DN );

  stimulus: process
  begin
  
  ---- Phase 1 directions
    UP_F <= "000000000";
    DN_F <= "000000000";
    CURR_F <= "0000";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
    
    -- EXPECTED DIR_UP=0, DIR_DN=0
    
    UP_F <= "000000100";
    DN_F <= "000000000";
    CURR_F <= "0000";
    CURR_D_UP <= '1';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '1';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
        
    -- EXPECTED DIR_UP=1, DIR_DN=0
    
    UP_F <= "000000001";
    DN_F <= "000010000";
    CURR_F <= "0010";
    CURR_D_UP <= '1';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '1';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
            
    -- EXPECTED DIR_UP=1, DIR_DN=0
    
    UP_F <= "000000001";
    DN_F <= "000000000";
    CURR_F <= "0010";
    CURR_D_UP <= '1';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '1';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
        
    -- EXPECTED DIR_UP=0, DIR_DN=1
       
    UP_F <= "000000000";
    DN_F <= "000000001";
    CURR_F <= "0100";
    CURR_D_UP <= '0';
    CURR_D_DN <= '1';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '1';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
            
    -- EXPECTED DIR_UP=0, DIR_DN=1
    
    UP_F <= "000000010";
    DN_F <= "010000000";
    CURR_F <= "0100";
    CURR_D_UP <= '0';
    CURR_D_DN <= '1';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '1';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
                
    -- EXPECTED DIR_UP=0, DIR_DN=1
    
    UP_F <= "100000000";
    DN_F <= "010000000";
    CURR_F <= "0010";
    CURR_D_UP <= '0';
    CURR_D_DN <= '1';
    
    
    ref_DIR_UP <= '1';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
    
    -- EXPECTED DIR_UP=1, DIR_DN=0
    
    UP_F <= "000000100";
    DN_F <= "000000000";
    CURR_F <= "0010";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
 
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
        
    -- EXPECTED DIR_UP=0, DIR_DN=0
    
    UP_F <= "000000000";
    DN_F <= "000000100";
    CURR_F <= "0010";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
            
    -- EXPECTED DIR_UP=0, DIR_DN=0
    
    UP_F <= "010000000";
    DN_F <= "000000000";
    CURR_F <= "0100";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '1';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
        
    -- EXPECTED DIR_UP=1, DIR_DN=0
    
    UP_F <= "000000000";
    DN_F <= "010000000";
    CURR_F <= "0100";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '1';
    ref_DIR_DN <= '0';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
            
    -- EXPECTED DIR_UP=1, DIR_DN=0
        
    UP_F <= "000000100";
    DN_F <= "000000000";
    CURR_F <= "0100";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '1';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
                
    -- EXPECTED DIR_UP=0, DIR_DN=1
            
    UP_F <= "000000000";
    DN_F <= "000000100";
    CURR_F <= "0100";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= '0';
    ref_DIR_DN <= '1';
    ref_FLOOR_REACHED <= 'X';
    ref_CLR_UP <= 'X';
    ref_CLR_DN <= 'X';
    PHASE <= '0';
    wait for 1ps;
                    
    -- EXPECTED DIR_UP=0, DIR_DN=1
    
 ----- Phase 2 clear
 
    UP_F <= "000000000";
    DN_F <= "000000000";
    CURR_F <= "0000";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '0';
    ref_CLR_UP <= '0';
    ref_CLR_DN <= '0';
    PHASE <= '1';
    wait for 1ps;
    -- FLOOR_REACHED=0, CLR_UP=0 CLR_DN=0
     
    UP_F <= "000000010";
    DN_F <= "000000000";
    CURR_F <= "0001";
    CURR_D_UP <= '1';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '1';
    ref_CLR_UP <= '1';
    ref_CLR_DN <= '0';
    PHASE <= '1';
    wait for 1ps;
         
    -- FLOOR_REACHED=1, CLR_UP=1 CLR_DN=0
     
    UP_F <= "000000001";
    DN_F <= "000010000";
    CURR_F <= "0100";
    CURR_D_UP <= '1';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '1';
    ref_CLR_UP <= '0';
    ref_CLR_DN <= '1';
    PHASE <= '1';
    wait for 1ps;
         
    -- FLOOR_REACHED=1, CLR_UP=0 CLR_DN=1
        
    UP_F <= "000000000";
    DN_F <= "000000010";
    CURR_F <= "0001";
    CURR_D_UP <= '0';
    CURR_D_DN <= '1';
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '1';
    ref_CLR_UP <= '0';
    ref_CLR_DN <= '1';
    PHASE <= '1';
    wait for 1ps;
             
    -- FLOOR_REACHED=1, CLR_UP=0 CLR_DN=1
     
    UP_F <= "000000010";
    DN_F <= "001000000";
    CURR_F <= "0001";
    CURR_D_UP <= '0';
    CURR_D_DN <= '1';--
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '1';
    ref_CLR_UP <= '1';
    ref_CLR_DN <= '0';
    PHASE <= '1';
    wait for 1ps;
     
    -- FLOOR_REACHED=0, CLR_UP=0 CLR_DN=0
     
    UP_F <= "000000010";
    DN_F <= "000000000";
    CURR_F <= "0001";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '1';
    ref_CLR_UP <= '1';
    ref_CLR_DN <= '0';
    PHASE <= '1';
    wait for 1ps;
         
    -- FLOOR_REACHED=0, CLR_UP=0 CLR_DN=0
     
    UP_F <= "000000000";
    DN_F <= "000000010";
    CURR_F <= "0001";
    CURR_D_UP <= '0';
    CURR_D_DN <= '0';
    
    ref_DIR_UP <= 'X';
    ref_DIR_DN <= 'X';
    ref_FLOOR_REACHED <= '1';
    ref_CLR_UP <= '0';
    ref_CLR_DN <= '1';
    PHASE <= '1';
    wait for 1ps;
         
    -- FLOOR_REACHED=0, CLR_UP=0 CLR_DN=0
        
    wait;
  end process;


end;