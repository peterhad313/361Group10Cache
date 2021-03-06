library ieee;
use ieee.std_logic_1164.all;

-- 16-to-1 mux with 32-bit inputs
entity mux_4_to_1_32bit is
   port( 
		sel	: in std_logic_vector(3 downto 0); -- the selector switches
		src0, src1, src2, src3 : in std_logic_vector(31 downto 0); --the options
		z 	: out std_logic_vector(31 downto 0) --output
		);
end mux_4_to_1_32bit;
--
architecture struct of mux_4_to_1_32bit is
   signal mux_out1, mux_out2: std_logic_vector(31 downto 0); --Mux outputs for level 1
   signal mux2_out1 : std_logic_vector(31 downto 0); --Mux outputs for level 2 
	signal or_1: std_logic;
	
begin
	--Level 1 of Muxes
	mux1: entity work.mux_32
		port map (sel=>sel(1), src0=>src0, src1=>src1, z=>mux_out1);
	mux2: entity work.mux_32
		port map (sel=>sel(3), src0=>src2, src1=>src3, z=>mux_out2);
	
	--or gate for selector for last mux
	or_map: entity work.or_gate
		port map (x => sel(0), y => sel(1),  z => or_1);

	--Last Mux
	mux4_1: entity work.mux_32
		port map (sel=> or_1, src0=>mux_out2, src1=>mux_out1, z=>z);

end struct;