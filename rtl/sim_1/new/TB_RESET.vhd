library ieee;
use ieee.std_logic_1164.all;

entity TB_RESET is
end TB_RESET;

architecture TB of TB_RESET is

    component RESET
        port (REQ_RST           : in std_logic;
              CURR_F            : in std_logic_vector (3 downto 0);
              CLR               : in std_logic;
              CLK               : in std_logic;
              RST               : out std_logic;
              DIR_UP            : out std_logic;
              DIR_DN            : out std_logic;
              RST_FLOOR_REACHED : out std_logic;
              HARD_RESET        : in  std_logic);
    end component;

    signal REQ_RST           : std_logic;
    signal CURR_F            : std_logic_vector (3 downto 0);
    signal CLR               : std_logic;
    signal CLK               : std_logic;
    signal RST               : std_logic;
    signal DIR_UP            : std_logic;
    signal DIR_DN            : std_logic;
    signal RST_FLOOR_REACHED : std_logic;
    signal HARD_RESET        : std_logic;

begin

    dut : RESET
    port map (REQ_RST           => REQ_RST,
              CURR_F            => CURR_F,
              CLR               => CLR,
              CLK               => CLK,
              RST               => RST,
              DIR_UP            => DIR_UP,
              DIR_DN            => DIR_DN,
              RST_FLOOR_REACHED => RST_FLOOR_REACHED,
              HARD_RESET        => HARD_RESET);

stimuli : process
begin
     
    HARD_RESET <= '1';
    wait for 1 ps;   
    HARD_RESET <= '0';
    CLR <= '0';
    CLK <= '0';
    HARD_RESET <= '0';
    CURR_F <= "0011";
    REQ_RST <= '0';
		
    wait for 1 ps;
		
	REQ_RST <= '1';
	
	CLK <= '1';
    wait for 1 ps;
    CLK <= '0';
    wait for 1 ps;

    REQ_RST <= '0';
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

end TB;
