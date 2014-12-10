library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dec_n;

entity dec_4 is 
	port (
		src	: in std_logic_vector(3 downto 0);
		z	: out std_logic_vector(15 downto 0)
	);
end dec_4;

architecture struct of dec_4 is
begin
	dec_map: entity work.dec_n
		generic map (n=>3)
		port map (
			src=>src, z=>z
		);
end struct;