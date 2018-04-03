library IEEE;
use IEEE.std_logic_1164.all;

-----------------------------------------------
--Bridge module that serve as an adaptation layer from controller to the specific board
-----------------------------------------------

entity MAIN is
  Port (SW_SEL : in std_logic_vector (3 downto 0);          -- 4 bit floor selector
        BTN_UP : in std_logic;                              -- floor button up outside elevator
        BTN_DN : in std_logic;                              -- floor button down outside elevator
        BTN_EL : in std_logic;                              -- floor button inside elevator
        
        BTN_NS : in std_logic;                              -- non stop operation request
        BTN_RST : in std_logic;                             -- reset request
        SW_EM_ON : in std_logic;                            -- emergency mode turnkey on
        SW_EM_OFF : in std_logic;                           -- emergency mode turnkey off
        
        CLK100MHZ : in std_logic;                           -- main driving clock 100MHz
        
        DISP_7SEG : out std_logic_vector ( 6 downto 0);     -- 7 segment display output
        DISP_LED_UP : out std_logic;                        -- moving up indicator normal operation
        DISP_LED_DN : out std_logic;                        -- moving down indicator normal operation
        DISP_LED_NS_UP : out std_logic;                     -- moving up indicator non stop operation
        DISP_LED_NS_DN : out std_logic;                     -- moving down indicator non stop operation
        DISP_LED_RST_UP : out std_logic;                    -- moving up indicator reset operation
        DISP_LED_RST_DN : out std_logic;                    -- moving down indicator reset operation
        
        HARD_RESET : in std_logic;                          -- hard reset(should be locked from access)
        LED_TRAV : out std_logic;                           -- elevator moving indicator
        LED_DO : out std_logic;                             -- door open cycle indicator
        LED_BTN : out std_logic_vector ( 8 downto 0);       -- 9 indicator showing floor button press
        LED_E_EN : out std_logic;                           -- emergency mode on indicator
        OUT_7SEG_MASK : out std_logic_vector(7 downto 0));  -- 7 segment mask for swithing only selected display
end MAIN;

architecture Behavioral of MAIN is

component CLK_DIVIDER is
    generic (FREQ_HZ : natural := 10);
    Port ( CLK100MHZ : in STD_LOGIC;
           CLK : out STD_LOGIC);
end component;

component DEMUX_1_TO_9 is
    Port ( INPUT : in std_logic;
           SEL : in std_logic_vector (3 downto 0);
           OUTPUT : out std_logic_vector (8 downto 0));
end component;

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

component BIN4_TO_7SEG is
  Port (IN4 : in std_logic_vector (3 downto 0);
        EN_L : in std_logic;
        OUT7 : out std_logic_vector ( 6 downto 0));
end component;

component ELEVATOR_CTRL is
  Port (F_UP : in std_logic_vector(8 downto 0);
        F_DN : in std_logic_vector(8 downto 0);
        F_EL : in std_logic_vector(8 downto 0);
        
        REQ_NS : in std_logic;
        REQ_RST : in std_logic;
        E_ENABLE : in std_logic;
        E_DISABLE : in std_logic;
        
        FA : in std_logic;
        DC : in std_logic;
        
        CLK : in std_logic;
        
        FLOOR : out std_logic_vector(3 downto 0);
        DIR_UP : out std_logic;
        DIR_DN : out std_logic;
        DOOR_OPEN : out std_logic;
        TRAV : out std_logic;
        
        HARD_RESET : in std_logic;
            
        NS_EN : out std_logic;
        RST_EN : out std_logic;
        
        E_EN : out std_logic);
end component;

    signal clk_100Hz : std_logic;
    signal input_btn_up : std_logic_vector ( 8 downto 0);
    signal input_btn_dn : std_logic_vector ( 8 downto 0);
    signal input_btn_el : std_logic_vector ( 8 downto 0);
    
    signal buff_7seg : std_logic_vector ( 6 downto 0);
    
    signal U20_TRAV : std_logic;
    signal U20_DO : std_logic;
    signal U20_FLOOR : std_logic_vector ( 3 downto 0);
    signal U20_DIR_UP : std_logic;
    signal U20_DIR_DN : std_logic;
    
    signal U20_NS_EN : std_logic;
    signal U20_RST_EN : std_logic;
    signal U20_E_EN : std_logic;
    
    signal U5_FA : std_logic;
    signal U5_DC : std_logic;
    
    signal inv_HARD_RESET : std_logic;
    
begin
    CLK_GEN: CLK_DIVIDER
            generic map (FREQ_HZ => 100)
            port map(
                CLK100MHZ => CLK100MHZ,
                CLK => clk_100Hz);
     
    INPUT_BTN_UP_DEMUX: DEMUX_1_TO_9
            port map (
                INPUT => BTN_UP,
                SEL => SW_SEL,
                OUTPUT => input_btn_up); 
     
    INPUT_BTN_DN_DEMUX: DEMUX_1_TO_9
            port map (
                INPUT => BTN_DN,
                SEL => SW_SEL,
                OUTPUT => input_btn_dn);
                
    INPUT_BTN_EL_DEMUX: DEMUX_1_TO_9
            port map (
                INPUT => BTN_EL,
                SEL => SW_SEL,
                OUTPUT => input_btn_el);          
    
    U5: SHAFT_SIM
            generic map( DELAY => 50)
            port map (
                TRAV => U20_TRAV,
                UP => U20_DIR_UP,
                DN => U20_DIR_DN,
                DO => U20_DO,
                CLK => clk_100Hz,
                FA => U5_FA,
                DC => U5_DC);
                  
    INV_HARD_RESET <= not HARD_RESET;
    
    U20 : ELEVATOR_CTRL
            port map (
                F_UP => input_btn_up,
                F_DN => input_btn_dn,
                F_EL => input_btn_el,
                REQ_NS => BTN_NS,
                REQ_RST => BTN_RST,
                E_ENABLE => SW_EM_ON,
                E_DISABLE => SW_EM_OFF,
                FA => U5_FA,
                DC => U5_DC,
                CLK => clk_100Hz,
                FLOOR => U20_FLOOR,
                DIR_UP => U20_DIR_UP,
                DIR_DN => U20_DIR_DN,
                DOOR_OPEN => U20_DO,
                TRAV => U20_TRAV,
                HARD_RESET => INV_HARD_RESET,
                NS_EN => U20_NS_EN,
                RST_EN => U20_RST_EN,
                E_EN => U20_E_EN);
                  
     OUT_7SEG_MASK <= "11111110";
     
     USER_OUTPUT: BIN4_TO_7SEG
            port map (
                IN4 => U20_FLOOR,
                EN_L => '1',
                OUT7 => buff_7seg);
                   
     DISP_LED_UP <= U20_DIR_UP when (U20_NS_EN = '0' and U20_RST_EN = '0') else '0' ;
     DISP_LED_DN <= U20_DIR_DN when (U20_NS_EN = '0' and U20_RST_EN = '0') else '0' ;
     DISP_LED_NS_UP <= U20_DIR_UP when (U20_NS_EN = '1' and U20_RST_EN = '0') else '0' ;
     DISP_LED_NS_DN <= U20_DIR_DN when (U20_NS_EN = '1' and U20_RST_EN = '0') else '0' ;
     DISP_LED_RST_UP <= U20_DIR_UP when (U20_NS_EN = '0' and U20_RST_EN = '1') else '0' ;
     DISP_LED_RST_DN <= U20_DIR_DN when (U20_NS_EN = '0' and U20_RST_EN = '1') else '0' ;
     DISP_7SEG <= not buff_7seg;
         
     LED_TRAV <= U20_TRAV;
     LED_DO <= U20_DO;
     LED_BTN <= input_btn_up or input_btn_dn or input_btn_el;
     LED_E_EN <= U20_E_EN; 
end Behavioral;
