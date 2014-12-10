library ieee;
use ieee.std_logic_1164.all;

entity l1Cache is
  port (
	clock : in std_logic;
	addr  : in std_logic_vector (31 downto 0);
	write_data : in std_logic_vector(31 downto 0);
	writeEn : in std_logic;

	miss : std_logic;
	dataOut: std_logic_vector(31 downto 0);
	writeBack: std_logic

  ) ;
end entity ; -- l1Cache

architecture struct of l1Cache is

	signal tag : std_logic_vector(23 downto 0);
	signal blockOfset : std_logic_vector(3 downto 0);
	signal setIndex : std_logic_vector(3 downto 0);
	signal readEn : std_logic;
	signal set_0_Out, set_1_Out, set_2_Out, set_3_Out, set_4_Out, set_5_Out, set_6_Out, set_7_Out, set_8_Out, set_9_Out,
	set_10_Out, set_11_Out, set_12_Out, set_13_Out, set_14_Out, set_15_Out : std_logic_vector(31 downto 0)

	signal valid_0_Out, valid_1_Out, valid_2_Out, valid_3_Out, valid_4_Out, valid_5_Out, valid_6_Out, valid_7_Out, valid_8_Out, valid_9_Out,
	valid_10_Out, valid_11_Out, valid_12_Out, valid_13_Out, valid_14_Out, valid_15_Out : std_logic

	signal valid_0_in, valid_1_in, valid_2_in, valid_3_in, valid_4_in, valid_5_in, valid_6_in, valid_7_in, valid_8_in, valid_9_in,
	valid_10_in, valid_11_in, valid_12_in, valid_13_in, valid_14_in, valid_15_in : std_logic

	signal tag_0_Out, tag_1_Out, tag_2_Out, tag_3_Out, tag_4_Out, tag_5_Out, tag_6_Out, tag_7_Out, tag_8_Out, tag_9_Out,
	tag_10_Out, tag_11_Out, tag_12_Out, tag_13_Out, tag_14_Out, tag_15_Out : std_logic(23 downto 0)

	signal tag_0_in, tag_1_in, tag_2_in, tag_3_in, tag_4_in, tag_5_in, tag_6_in, tag_7_in, tag_8_in, tag_9_in,
	tag_10_in, tag_11_in, tag_12_in, tag_13_in, tag_14_in, tag_15_in : std_logic(23 downto 0)

	signal writeSetDecoded std_logic_vector(15 downto 0);


begin
readEn<= not writeEn;

--set1
csram1: entity work.csramL1Cache port map('1',readEn,writeEn(DECODETHIS),blockOfset,write_data,set_0_Out);
valid1: entity work.dff port map (clock,valid_0_in,valid_0_Out);
tag1: entity work.dff_24 port map (clock, tag_0_in, tag_0_Out);


end architecture ; -- struct