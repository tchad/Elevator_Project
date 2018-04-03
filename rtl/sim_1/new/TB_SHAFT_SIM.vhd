library ieee;
use ieee.std_logic_1164.all;

------------------------------------------
-- Module tests whether the shafr sim is going into proper signal cycle
-- DN and DO signals do not have any effect in this version
------------------------------------------

entity TB_SHAFT_SIM is
end TB_SHAFT_SIM;

architecture tb of TB_SHAFT_SIM is

    component SHAFT_SIM is
        Generic( DELAY : natural := 100000);
        Port (TRAV : in std_logic;
              UP : in std_logic;
              DN : in std_logic;
              DO : in std_logic;
              CLK : in std_logic;
              FA : out std_logic;
              DC : out std_logic);
    end component;


    signal TRAV : std_logic;
    signal UP   : std_logic;
    signal DN   : std_logic;
    signal DO   : std_logic;
    signal CLK  : std_logic := '0';
    signal FA   : std_logic;
    signal DC   : std_logic;

begin

    dut : SHAFT_SIM
    generic map ( DELAY => 2)
    port map (TRAV => TRAV,
              UP   => UP,
              DN   => DN,
              DO   => DO,
              CLK  => CLK,
              FA   => FA,
              DC   => DC);

    -- Clock generation
    CLK <= not CLK after 1ps;

    stimuli : process
    begin
        TRAV <= '0';
        UP <= '0';
        DN <= '0';
        DO <= '0';
		wait for 4ps;
		
		TRAV <= '1';
        DO <= '0';
		wait for 8 ps;
		        
		TRAV <= '0';
        DO <= '1';
		wait for 10 ps;
		DO <= '0';
		
        wait;
    end process;

end tb;
