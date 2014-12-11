library ieee;
use ieee.std_logic_1164.all;

entity memory is
	port (
	
	clk : in std_logic;
	addr : in std_logic_vector (31 downto 0);
	
	output_block : out std_logic_vector (2047 downto 0);
	);
	
end memory;

architect struct is 
	signal 