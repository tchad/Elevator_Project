LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY TB_BIN4_TO_7SEG IS
END TB_BIN4_TO_7SEG;
 
ARCHITECTURE behavior OF TB_BIN4_TO_7SEG IS
 
-- Component Declaration 
 
component BIN4_TO_7SEG is
  Port (IN4 : in std_logic_vector (3 downto 0);
        EN_L : in std_logic;
        OUT7 : out std_logic_vector ( 6 downto 0));
end component;
 
--Inputs
signal FLOOR : std_logic_vector(3 downto 0) := (others => '0');
signal L_EN : std_logic;
 
--Outputs
signal Seven_Segment : std_logic_vector(6 downto 0);

 
BEGIN
 
uut: BIN4_TO_7SEG PORT MAP (
    IN4 => FLOOR,
    EN_L => L_EN,
    OUT7 => Seven_Segment
);
 
-- Stimulus process
stim_proc: process
begin
L_EN <= '1';
FLOOR <= "0000";
wait for 1 ps;

L_EN <= '0';
FLOOR <= "0000";
wait for 1 ps;

FLOOR <= "0001";
wait for 1 ps;
FLOOR <= "0010";
wait for 1 ps;
FLOOR <= "0011";
wait for 1 ps;
FLOOR <= "0100";
wait for 1 ps;
FLOOR <= "0101";
wait for 1 ps;
FLOOR <= "0110";
wait for 1 ps;
FLOOR <= "0111";
wait for 1 ps;
FLOOR <= "1000";
wait for 1 ps;
FLOOR <= "1001";
wait for 1 ps;
FLOOR <= "1010";
wait for 1 ps;
FLOOR <= "1011";
wait for 1 ps;
FLOOR <= "1100";
wait for 1 ps;
FLOOR <= "1101";
wait for 1 ps;
FLOOR <= "1110";
wait for 1 ps;
FLOOR <= "1111";
wait for 1 ps;
end process;
 
END;
