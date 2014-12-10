library ieee;
use ieee.std_logic_1164.all;

entity or_3 is
  port (
    a   : in  std_logic;
    b   : in  std_logic;
    c   : in  std_logic;
    z   : out std_logic
  );
end or_3;

architecture struct of or_3 is

signal or1 : std_logic;

begin
  or1_map : entity work.or_gate
	port map (x => a, y => b, z =>or1);
  or2_map : entity work.or_gate
	port map (x => c, y => or1, z =>z);
end struct;
