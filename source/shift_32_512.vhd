
library ieee;
use ieee.std_logic_1164.all;


entity shift_32_512 is
	port (
		x: 	in std_logic_vector(511 downto 0);
		y: 	in std_logic_vector(3 downto 0);  
		z: 	out std_logic_vector(511 downto 0) -- Output
	);
end shift_32_512;

architecture struct of shift_32_512 is

signal muxed1, muxed2, muxed3: std_logic_vector(511 downto 0);

begin
    
	mux0:	entity work.mux_n generic map (n=>512)	 port map (sel=>y(3), src0=>x, src1(511 downto 256)=>x(255 downto 0), src1(255 downto 0)=>X"0000000000000000000000000000000000000000000000000000000000000000", z=>muxed1);
	mux1:	entity work.mux_n generic map (n=>512)	 port map (sel=>y(2), src0=>muxed1, src1(511 downto 128)=>muxed2(383 downto 0),src1(127 downto 0)=>X"00000000000000000000000000000000", z=>muxed2);
	mux2:	entity work.mux_n generic map (n=>512)	 port map (sel=>y(1), src0=>muxed2, src1(511 downto 64)=>muxed2(447 downto 0),src1(63 downto 0)=>X"0000000000000000", z=>muxed3);
   	mux3:	entity work.mux_n generic map (n=>512)	 port map (sel=>y(0), src0=>muxed3, src1(511 downto 32)=>muxed3(479 downto 0),src1(31 downto 0)=>X"0000", z=>z);
	
end architecture struct;