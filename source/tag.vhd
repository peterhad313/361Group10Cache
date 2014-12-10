library ieee;
use ieee.std_logic_1164.all;

entity tag is 
  port(
    clock : in std_logic;
    we    : in std_logic;
    input : in std_logic_vector(23 downto 0);
    output: out std_logic_vector(23 downto 0)
  );
end tag;

architecture struct of tag is
	
	signal muxed : std_logic_vector(23 downto 0);
	signal outTemp : std_logic_vector(23 downto 0);

begin
	mux0: entity work.mux_24 port map (we, outTemp, input, muxed);
	tag0: entity work.dff_24 port map (clock, muxed, outTemp);
	output<=outTemp;

end architecture ; -- struct