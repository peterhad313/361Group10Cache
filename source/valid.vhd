library ieee;
use ieee.std_logic_1164.all;

entity valid is 
  port(
    clock : in std_logic;
    we    : in std_logic;
    input : in std_logic;
    output: out std_logic
  );
end valid;

architecture struct of valid is
	
	signal muxed : std_logic;
	signal outTemp : std_logic;

begin
	mux0: entity work.mux port map (we, outTemp, input, muxed);
	valid0: entity work.dff port map (clock, muxed, outTemp);
	output<=outTemp;

end architecture ; -- struct