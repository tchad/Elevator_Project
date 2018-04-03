library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TB_DEMUX_1_TO_9 is
end TB_DEMUX_1_TO_9;

architecture tb of TB_DEMUX_1_TO_9 is

    component DEMUX_1_TO_9
        port (INPUT  : in std_logic;
              SEL    : in std_logic_vector (3 downto 0);
              OUTPUT : out std_logic_vector (8 downto 0));
    end component;

    signal INPUT  : std_logic;
    signal SEL    : std_logic_vector (3 downto 0);
    signal OUTPUT : std_logic_vector (8 downto 0);

begin

    dut : DEMUX_1_TO_9
    port map (INPUT  => INPUT,
              SEL    => SEL,
              OUTPUT => OUTPUT);

stimulus : process
begin
    for addr in 0 to 8 loop
        SEL <= std_logic_vector(to_unsigned(addr,4));
        INPUT <= '0';
        wait for 1 ps;
        INPUT <= '1';
        wait for 1 ps;
    end loop;

    wait;
end process;

end tb;
