library ieee;
use ieee.std_logic_1164.all;

entity l1Cache is
  port (
	clock : in std_logic;
	addr  : in std_logic_vector (31 downto 0);
	write_data : in std_logic_vector(31 downto 0);
	writeEn : in std_logic;

	hit : out std_logic;
	miss : out std_logic;
	dataOut: out std_logic_vector(31 downto 0);
	writeBack: out std_logic

  ) ;
end entity ; -- l1Cache

architecture struct of l1Cache is

	signal tag : std_logic_vector(23 downto 0);
	signal blockOffset : std_logic_vector(3 downto 0);
	signal setIndex : std_logic_vector(3 downto 0);

	signal readEn : std_logic;
	signal set_0_Out, set_1_Out, set_2_Out, set_3_Out, set_4_Out, set_5_Out, set_6_Out, set_7_Out, set_8_Out, set_9_Out, set_10_Out, set_11_Out, set_12_Out, set_13_Out, set_14_Out, set_15_Out : std_logic_vector(31 downto 0);
	signal valid_0_Out, valid_1_Out, valid_2_Out, valid_3_Out, valid_4_Out, valid_5_Out, valid_6_Out, valid_7_Out, valid_8_Out, valid_9_Out, valid_10_Out, valid_11_Out, valid_12_Out, valid_13_Out, valid_14_Out, valid_15_Out : std_logic;
	signal valid_0_in, valid_1_in, valid_2_in, valid_3_in, valid_4_in, valid_5_in, valid_6_in, valid_7_in, valid_8_in, valid_9_in, valid_10_in, valid_11_in, valid_12_in, valid_13_in, valid_14_in, valid_15_in : std_logic;

	signal tag_0_Out, tag_1_Out, tag_2_Out, tag_3_Out, tag_4_Out, tag_5_Out, tag_6_Out, tag_7_Out, tag_8_Out, tag_9_Out, tag_10_Out, tag_11_Out, tag_12_Out, tag_13_Out, tag_14_Out, tag_15_Out : std_logic_vector(23 downto 0);

	--signal tag_0_in, tag_1_in, tag_2_in, tag_3_in, tag_4_in, tag_5_in, tag_6_in, tag_7_in, tag_8_in, tag_9_in, tag_10_in, tag_11_in, tag_12_in, tag_13_in, tag_14_in, tag_15_in : std_logic_vector(23 downto 0);

	signal writeSetDecoded : std_logic_vector(15 downto 0);

	signal tagsMuxed : std_logic_vector(23 downto 0);
	signal tagCmp: std_logic;
	signal validsMuxed : std_logic;
	signal dataMuxed : std_logic_vector(31 downto 0);
	signal hit_temp : std_logic;

begin
tag<=addr(31 downto 8);
setIndex<= addr(7 downto 4);
blockOffset<= addr(3 downto 0);
readEn<= not writeEn;


dec0: entity work.dec_4 port map (setIndex, writeSetDecoded);
set0: entity work.SetL1 port map (clock,valid_0_in, tag,write_data,writeSetDecoded(0),	blockOffset, valid_0_out, tag_0_out, set_0_Out);
set1: entity work.SetL1 port map (clock,valid_1_in, tag,write_data,writeSetDecoded(1),	blockOffset, valid_1_out, tag_1_out, set_1_Out);
set2: entity work.SetL1 port map (clock,valid_2_in, tag,write_data,writeSetDecoded(2),	blockOffset, valid_2_out, tag_2_out, set_2_Out);
set3: entity work.SetL1 port map (clock,valid_3_in, tag,write_data,writeSetDecoded(3),	blockOffset, valid_3_out, tag_3_out, set_3_Out);
set4: entity work.SetL1 port map (clock,valid_4_in, tag,write_data,writeSetDecoded(4),	blockOffset, valid_4_out, tag_4_out, set_4_Out);
set5: entity work.SetL1 port map (clock,valid_5_in, tag,write_data,writeSetDecoded(5),	blockOffset, valid_5_out, tag_5_out, set_5_Out);
set6: entity work.SetL1 port map (clock,valid_6_in, tag,write_data,writeSetDecoded(6),	blockOffset, valid_6_out, tag_6_out, set_6_Out);
set7: entity work.SetL1 port map (clock,valid_7_in, tag,write_data,writeSetDecoded(7),	blockOffset, valid_7_out, tag_7_out, set_7_Out);
set8: entity work.SetL1 port map (clock,valid_8_in, tag,write_data,writeSetDecoded(8),	blockOffset, valid_8_out, tag_8_out, set_8_Out);
set9: entity work.SetL1 port map (clock,valid_9_in, tag,write_data,writeSetDecoded(9),	blockOffset, valid_9_out, tag_9_out, set_9_Out);
set10: entity work.SetL1 port map (clock,valid_10_in, tag,write_data,writeSetDecoded(10),	blockOffset, valid_10_out, tag_10_out, set_10_Out);
set11: entity work.SetL1 port map (clock,valid_11_in, tag,write_data,writeSetDecoded(11),	blockOffset, valid_11_out, tag_11_out, set_11_Out);
set12: entity work.SetL1 port map (clock,valid_12_in, tag,write_data,writeSetDecoded(12),	blockOffset, valid_12_out, tag_12_out, set_12_Out);
set13: entity work.SetL1 port map (clock,valid_13_in, tag,write_data,writeSetDecoded(13),	blockOffset, valid_13_out, tag_13_out, set_13_Out);
set14: entity work.SetL1 port map (clock,valid_14_in, tag,write_data,writeSetDecoded(14),	blockOffset, valid_14_out, tag_14_out, set_14_Out);
set15: entity work.SetL1 port map (clock,valid_15_in, tag,write_data,writeSetDecoded(15),	blockOffset, valid_15_out, tag_15_out, set_15_Out);

mux1: entity work.mux_16_to_1 port map (setIndex, tag_0_Out, tag_1_Out, tag_2_Out, tag_3_Out, tag_4_Out,tag_5_Out,tag_6_Out, tag_7_Out, 
								 		tag_8_Out,tag_9_Out, tag_10_Out, tag_11_Out, tag_12_Out,tag_13_Out, tag_14_Out, tag_15_Out, tagsMuxed);

mux2: entity work.mux_16_to_1_bit port map (setIndex, valid_0_Out, valid_1_Out, valid_2_Out, valid_3_Out, valid_4_Out,valid_5_Out,valid_6_Out, valid_7_Out, 
								 		valid_8_Out,valid_9_Out, valid_10_Out, valid_11_Out, valid_12_Out,valid_13_Out, valid_14_Out, valid_15_Out, validsMuxed);

mux3: entity work.mux_16_to_1_32bit port map (setIndex, set_0_Out, set_1_Out, set_2_Out, set_3_Out, set_4_Out,set_5_Out,set_6_Out, set_7_Out, 
								 		set_8_Out,set_9_Out, set_10_Out, set_11_Out, set_12_Out,set_13_Out, set_14_Out, set_15_Out, dataMuxed);

cmp: entity work.cmp_n generic map (n=>24) port map (a=>tagsMuxed, b=>tag, a_eq_b=>tagCmp);
and0: entity work.and_gate port map (tagCmp, validsMuxed, hit_temp);
not0: entity work.not_gate port map (hit_temp, miss);
hit<=hit_temp;
dataOut<= dataMuxed;

end struct; -- struct