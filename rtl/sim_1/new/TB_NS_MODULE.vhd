library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.NUMERIC_STD.ALL;
use WORK.global.all;

entity TB_NS_MODULE is
end TB_NS_MODULE;

architecture Behavioral of TB_NS_MODULE is
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
    
    signal REQ_NS : std_logic;
    signal REQ_F : floor_pin_t;
    signal CURR_F : floor_vec_t;
           
    signal REQ_PENDING : std_logic;
    signal CLK : std_logic;
            
    signal CLR : std_logic;
            
    signal DIR_UP : std_logic;
    signal DIR_DN : std_logic;
    signal NS : std_logic;
    signal NS_FLOOR_REACHED : std_logic;
            
    signal HARD_RESET : std_logic;

begin
    DEVICE: NS_MODULE
         port map(
            REQ_NS => REQ_NS,
            REQ_F => REQ_F,
            CURR_F => CURR_F,
            REQ_PENDING => REQ_PENDING,
            CLK => CLK,
            CLR => CLR,
            DIR_UP => DIR_UP,
            DIR_DN => DIR_DN,
            NS => NS,
            NS_FLOOR_REACHED => NS_FLOOR_REACHED,
            HARD_RESET => HARD_RESET
         );

    stimuli : process
    begin
       HARD_RESET <= '1';
       wait for 1 ps;   
       HARD_RESET <= '0';
       CLR <= '0';
       CLK <= '0';
       HARD_RESET <= '0';
       CURR_F <= "0011";
       REQ_NS <= '0';
       REQ_PENDING <= '0';
       REQ_F <= "000000000";
		
        wait for 1 ps;
		
	   REQ_NS <= '1';
	   REQ_F <= "000000001";
	
	   CLK <= '1';
       wait for 1 ps;
       CLK <= '0';
       wait for 1 ps;

        REQ_NS <= '0';
        REQ_F <= "000000000";
        CURR_F <= "0010";
    
        CLK <= '1';
        wait for 1 ps;
        CLK <= '0';
        wait for 1 ps;
    
        CURR_F <= "0001";
    
        CLK <= '1';
        wait for 1 ps;
        CLK <= '0';
        wait for 1 ps;
        
        CURR_F <= "0000";
            
        CLK <= '1';
        wait for 1 ps;
        CLK <= '0';
        wait for 1 ps;
    
        CLR <= '1';
    
        CLK <= '1';
        wait for 1 ps;
        CLK <= '0';
        wait for 1 ps;
    
        CLR <= '0';
    
        CLK <= '1';
        wait for 1 ps;
        CLK <= '0';
        wait for 1 ps;

        wait;
    end process;
end Behavioral;
