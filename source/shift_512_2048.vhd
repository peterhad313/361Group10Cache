
library ieee;
use ieee.std_logic_1164.all;


entity shift_512_2048 is
	port (
		x: 	in std_logic_vector(2047 downto 0);
		y: 	in std_logic_vector(1 downto 0);  
		z: 	out std_logic_vector(2047 downto 0) -- Output
	);
end shift_512_2048;

architecture struct of shift_512_2048 is

signal muxed1, muxed2, muxed3: std_logic_vector(2047 downto 0);

begin
    
	mux0:	entity work.mux_n generic map (n=>2048)	 port map (sel=>y(1), src0=>x, src1(2047 downto 1024)=>x(1023 downto 0), src1(1023 downto 0)=>X"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", z=>muxed1);
	mux1:	entity work.mux_n generic map (n=>2048)	 port map (sel=>y(0), src0=>muxed1, src1(2047 downto 512)=>muxed1(1536 downto 0),src1(511 downto 0)=>X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", z=>muxed2);

end architecture struct;