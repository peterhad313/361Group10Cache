library ieee;
use ieee.std_logic_1164.all;

-- 16-to-1 mux with 24-bit inputs
entity mux_16_to_1_32bit is
   port( 
		sel	: in std_logic_vector(3 downto 0); -- the selector switches
		src0, src1, src2, src3, src4, src5, src6, src7 : in std_logic_vector(31 downto 0); --the options
		src8, src9, src10, src11, src12, src13, src14, src15 : in std_logic_vector(31 downto 0); -- the options
		z 	: out std_logic_vector(31 downto 0) --output
		);
end mux_16_to_1_32bit;
--
architecture struct of mux_16_to_1_32bit is
   signal mux_out1, mux_out2, mux_out3, mux_out4, mux_out5, mux_out6, mux_out7, mux_out8 : std_logic_vector(31 downto 0); --Mux outputs for level 1
   signal mux2_out1, mux2_out2, mux2_out3, mux2_out4 : std_logic_vector(31 downto 0); --Mux outputs for level 2 
   signal mux3_out1, mux3_out2 : std_logic_vector(31 downto 0); --Mux outputs for level 3

begin
	--Level 1 of Muxes
	mux1: entity work.mux_32
		port map (sel=>sel(3), src0=>src0, src1=>src8, z=>mux_out1);
	mux2: entity work.mux_32
		port map (sel=>sel(3), src0=>src1, src1=>src9, z=>mux_out2);
	mux3: entity work.mux_32
		port map (sel=>sel(3), src0=>src2, src1=>src10, z=>mux_out3);
	mux4: entity work.mux_32
		port map (sel=>sel(3), src0=>src3, src1=>src11, z=>mux_out4);
	mux5: entity work.mux_32
		port map (sel=>sel(3), src0=>src4, src1=>src12, z=>mux_out5);
	mux6: entity work.mux_32
		port map (sel=>sel(3), src0=>src5, src1=>src13, z=>mux_out6);
	mux7: entity work.mux_32
		port map (sel=>sel(3), src0=>src6, src1=>src14, z=>mux_out7);
	mux8: entity work.mux_32
		port map (sel=>sel(3), src0=>src7, src1=>src15, z=>mux_out8);
	--Level 2 of Muxes
	mux2_1: entity work.mux_32
		port map (sel=>sel(2), src0=>mux_out1, src1=>mux_out5, z=>mux2_out1);
	mux2_2: entity work.mux_32
		port map (sel=>sel(2), src0=>mux_out2, src1=>mux_out6, z=>mux2_out2);
	mux2_3: entity work.mux_32
		port map (sel=>sel(2), src0=>mux_out3, src1=>mux_out7, z=>mux2_out3);
	mux2_4: entity work.mux_32
		port map (sel=>sel(2), src0=>mux_out4, src1=>mux_out8, z=>mux2_out4);
	--Level 3 of Muxes
	mux3_1: entity work.mux_32
		port map (sel=>sel(1), src0=>mux2_out1, src1=>mux2_out3, z=>mux3_out1);
	mux3_2: entity work.mux_32
		port map (sel=>sel(1), src0=>mux2_out2, src1=>mux2_out4, z=>mux3_out2);
	--Last Mux
	mux4_1: entity work.mux_32
		port map (sel=>sel(0), src0=>mux3_out1, src1=>mux3_out2, z=>z);

end struct;