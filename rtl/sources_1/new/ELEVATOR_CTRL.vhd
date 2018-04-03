library IEEE;
use IEEE.std_logic_1164.all;
use WORK.global.all;

----------------------------------------------------
--Main module implementing the elevator controller functionality
-- Its main purpose is to connect together all the modules
-- and deliver outside interface.
-- This module does not use use the subtypes degined in global
-- in order to deliver consisten interface that does not require 
-- an additional study of the internal implementation

entity ELEVATOR_CTRL is
  Port (F_UP : in std_logic_vector(8 downto 0);     -- floor buttons up
        F_DN : in std_logic_vector(8 downto 0);     -- floor buttons down
        F_EL : in std_logic_vector(8 downto 0);     -- floor buttons inside elevator
        
        REQ_NS : in std_logic;                      -- request non stop operation
        REQ_RST : in std_logic;                     -- request reset operation
        E_ENABLE : in std_logic;                    -- emergency mode enable turnkey
        E_DISABLE : in std_logic;                   -- emergency mode disable turnkey
        
        FA : in std_logic;                          -- floor arrived input signal
        DC : in std_logic;                          -- door closed input signal
        
        CLK : in std_logic;                         -- clock
        
        FLOOR : out std_logic_vector(3 downto 0);   --current floor indicator 
        DIR_UP : out std_logic;                     -- request travel direction up
        DIR_DN : out std_logic;                     -- request travel direction down 
        DOOR_OPEN : out std_logic;                  -- request door open 
        TRAV : out std_logic;                       -- request travel
        
        NS_EN : out std_logic;                      -- non stop mode indicator
        RST_EN : out std_logic;                     -- reset mode indicator
        E_EN : out std_logic;                       -- emergency mode enabled indicator
        
        HARD_RESET : in std_logic);                 -- hard reset input
end ELEVATOR_CTRL;

architecture Behavioral of ELEVATOR_CTRL is

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
        
        HARD_RESET : in std_logic);
end component;

component DIRECTION_DETECTOR is
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

component UD_COUNTER is
    Port ( U : in std_logic;
           D : in std_logic;
           RST1 : in std_logic;
           CLK : in std_logic;
           COUNT : out floor_vec_t;
           
           HARD_RESET : in std_logic);
end component;

component CONTROL is
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
end component;

component RESET is
    Port ( REQ_RST : in std_logic;
           CURR_F : in std_logic_vector (3 downto 0);
           CLK : in std_logic;
           CLR : in std_logic;
           RST : out std_logic;
           DIR_UP : out std_logic;
           DIR_DN : out std_logic;
           RST_FLOOR_REACHED : out std_logic;
           HARD_RESET : in std_logic);
end component;

component NS_MODULE is
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
end component;

component EM_MODULE is
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
end component;
    
    -- OUTPUT signals used to connect components
    -- the convention is to dedicate signal named after output
    -- of component with id consisten with diagram
    signal U1_DIR_UP : std_logic;
    signal U1_DIR_DN : std_logic;
    signal U1_FLOOR_REACHED : std_logic;
    signal U1_CLR_UP : std_logic;
    signal U1_CLR_DN : std_logic;
    
    signal U2_IN_DISABLE_INPUT : std_logic;
    signal U2_IN_CLR : std_logic;
    signal U2_UP_F : floor_pin_t;
    signal U2_DN_F : floor_pin_t;
    signal U2_REQ_PENDING : std_logic;
    
    signal U4_CLR_UP : std_logic;
    signal U4_CLR_DN : std_logic;
    signal U4_TRAV : std_logic;
    signal U4_TRAV_UP : std_logic;
    signal U4_TRAV_DN : std_logic;
    signal U4_DOOR_OPEN : std_logic;
    signal U4_RST_CLR : std_logic;
    signal U4_NS_CLR : std_logic;
    signal U4_E_CLR : std_logic;
    
    signal U7_IN_CLK : std_logic;
    signal U7_COUNT : floor_vec_t;
    
    signal U8_RST : std_logic;
    signal U8_DIR_UP : std_logic;
    signal U8_DIR_DN : std_logic;
    signal U8_RST_FLOOR_REACHED : std_logic;
    
    signal U6_IN_CLR : std_logic;
    signal U6_DIR_UP : std_logic;
    signal U6_DIR_DN : std_logic;
    signal U6_NS : std_logic;
    signal U6_NS_FLOOR_REACHED : std_logic;
    
    signal U18_REQ_F : floor_pin_t;
    signal U18_E_ON : std_logic;
    signal U18_DIR_UP : std_logic;
    signal U18_DIR_DN : std_logic;
    signal U18_E_FLOOR_REACHED : std_logic;
    
begin

    -- IO panel input is disabled when non stop request is about to be made
    -- or when emergrncy mode is enabled
    U2_IN_DISABLE_INPUT <= REQ_NS or U18_E_ON;
    
    -- IO panel state is cleared during final stage fo the reset and
    -- when emergency mode is enabled 
    U2_IN_CLR <= U4_RST_CLR or U18_E_ON;

    U2: IO_PANEL port map (
            F_UP => F_UP,
            F_DN => F_DN,
            F_EL => F_EL,
            CURR_F => U7_COUNT,
            DISABLE_INPUT => U2_IN_DISABLE_INPUT, 
            CLR => U2_IN_CLR,
            CLR_UP => U4_CLR_UP,
            CLR_DN => U4_CLR_DN,
            CLK => CLK,
            UP_F => U2_UP_F,
            DN_F => U2_DN_F,
            REQ_PENDING => U2_REQ_PENDING,
            HARD_RESET => HARD_RESET);
     
     U1: DIRECTION_DETECTOR port map (
            UP_F => U2_UP_F,
            DN_F => U2_DN_F,
            CURR_F => U7_COUNT,
             
            CURR_D_UP => U4_TRAV_UP,
            CURR_D_DN => U4_TRAV_DN,
             
            DIR_UP => U1_DIR_UP,
            DIR_DN => U1_DIR_DN,
             
            FLOOR_REACHED => U1_FLOOR_REACHED,
            CLR_UP => U1_CLR_UP,
            CLR_DN => U1_CLR_DN);
            
     -- the falling edge of TRAV signal is used to increment or decrement the floor counter
     -- TRAV signal goes low upon state machine recieving floor arrived signal
     U7_IN_CLK <= not U4_TRAV; 
      
     U7: UD_COUNTER port map (
            U => U4_TRAV_UP,
            D => U4_TRAV_DN,
            RST1 => U4_RST_CLR,
            CLK => U7_IN_CLK,
            COUNT => U7_COUNT,
            HARD_RESET => HARD_RESET);
            
      U4: CONTROL port map (
            DIR_UP => U1_DIR_UP,
            DIR_DN => U1_DIR_DN,
            REACHED => U1_FLOOR_REACHED,
            IN_CLR_UP => U1_CLR_UP,
            IN_CLR_DN => U1_CLR_DN,
              
            E_ON => U18_E_ON,
            E_DIR_UP => U18_DIR_UP,
            E_DIR_DN => U18_DIR_DN,
            E_REACHED => U18_E_FLOOR_REACHED,
              
            NS_ON => U6_NS,
            NS_DIR_UP => U6_DIR_UP,
            NS_DIR_DN => U6_DIR_DN,
            NS_REACHED => U6_NS_FLOOR_REACHED,
             
            RST_ON => U8_RST,
            RST_DIR_UP => U8_DIR_UP,
            RST_DIR_DN => U8_DIR_DN,
            RST_REACHED => U8_RST_FLOOR_REACHED,
              
            FA => FA,
            DC => DC,
              
            CLK => CLK,
              
            TRAV => U4_TRAV,
            TRAV_UP => U4_TRAV_UP,
            TRAV_DN => U4_TRAV_DN,
              
            DOOR_OPEN => U4_DOOR_OPEN,
              
            RST_CLR => U4_RST_CLR,
            NS_CLR => U4_NS_CLR,
            E_CLR => U4_E_CLR,
              
            CLR_UP => U4_CLR_UP,
            CLR_DN => U4_CLR_DN,
            HARD_RESET => HARD_RESET);
            
      U8: RESET port map(
            REQ_RST => REQ_RST,
            CURR_F => U7_COUNT,
            CLK => CLK,
            CLR => U4_RST_CLR,
            RST => U8_RST,
            DIR_UP => U8_DIR_UP,
            DIR_DN => U8_DIR_DN,
            RST_FLOOR_REACHED => U8_RST_FLOOR_REACHED,
            HARD_RESET => HARD_RESET);
       
      -- non stop module is cleared when non stop or reset operation is finished
      U6_IN_CLR <= U4_RST_CLR or U4_NS_CLR;
      
      U6: NS_MODULE port map(
            REQ_NS => REQ_NS,
            REQ_F => F_EL, 
            CURR_F => U7_COUNT,
              
            REQ_PENDING => U2_REQ_PENDING,
            CLK => CLK,
              
            CLR => U6_IN_CLR,
              
            DIR_UP => U6_DIR_UP,
            DIR_DN => U6_DIR_DN,
            NS => U6_NS,
            NS_FLOOR_REACHED => U6_NS_FLOOR_REACHED,
              
            HARD_RESET => HARD_RESET);
      
      -- emergency module aggregate floor request input from all three sources
      -- up and down requests and inside of elevator
      U18_REQ_F <= F_UP or F_DN or F_EL;
      
      U18: EM_MODULE port map(
            REQ_F => U18_REQ_F,
            CURR_F => U7_COUNT,
            E_ENABLE => E_ENABLE,
            E_DISABLE => E_DISABLE,
            CLR => U4_E_CLR,
            CLK => CLK,
            DIR_UP => U18_DIR_UP,
            DIR_DN => U18_DIR_DN,
            E_ON => U18_E_ON,
            E_FLOOR_REACHED => U18_E_FLOOR_REACHED,
            HARD_RESET => HARD_RESET);
      
      FLOOR <= U7_COUNT;
      DIR_UP <= U4_TRAV_UP;
      DIR_DN <= U4_TRAV_DN;
      DOOR_OPEN <= U4_DOOR_OPEN;
      TRAV <= U4_TRAV;
      
      NS_EN <= U6_NS;
      RST_EN <= U8_RST; 
      E_EN <= U18_E_ON;
end Behavioral;
