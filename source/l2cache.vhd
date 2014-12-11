library ieee;
use ieee.std_logic_1164.all;

entity l2cache is
	port(
	
	addr : in std_logic_vector(31 downto 0);
	clock : in std_logic;
	writeIn : in std_logic;
	memoryValid: in std_logic;
	dataFromL1: in std_logic_vector(511 downto 0);
	dataFromMemory : in std_logic_vector(2047 downto 0);

	
	hit : out std_logic;
	miss : out std_logic;
	writeBack : out std_logic; --eviction notice, written back to cache
	dataOut : out std_logic_vector(511 downto 0)
	
	);
	end l2cache;
	
architecture struct of l2cache is
	
	signal tag : std_logic_vector(21 downto 0);
	signal setIndex : std_logic_vector (1 downto 0); 
	signal subblockIndex : std_logic_vector(1 downto 0);
	signal sel_subblock : std_logic_vector(3 downto 0);
	signal byteOffset : std_logic_vector (5 downto 0);

	--tags from sets
	signal set1_tag : std_logic_vector(21 downto 0);
	signal set2_tag : std_logic_vector(21 downto 0);
	signal set3_tag : std_logic_vector(21 downto 0);
	signal set4_tag : std_logic_vector(21 downto 0);
	
	--valid bits from sets
	signal set1_valid : std_logic;
	signal set2_valid : std_logic;
	signal set3_valid : std_logic;
	signal set4_valid : std_logic;
	
	--data from sets
	signal set1_data : std_logic_vector (2070 downto 0);
	signal set2_data : std_logic_vector (2070 downto 0);
	signal set3_data : std_logic_vector (2070 downto 0);
	signal set4_data : std_logic_vector (2070 downto 0);
	
	--signals from comparators to and gates
	signal set1_match : std_logic;
	signal set2_match : std_logic;
	signal set3_match : std_logic;
	signal set4_match : std_logic;
	
	--signals from and gates to final or gate
	signal and1 : std_logic;
	signal and2 : std_logic;
	signal and3 : std_logic;
	signal and4 : std_logic;

	--Logical signal
	signal L2_write : std_logic;
	
	--signals for muxes for indexes
	--signal set1_mux, set2_mux, set3_mux, set4_mux : std_logic_vector(2047 downto 0);

	signal hit_temp : std_logic;
	signal dataOut_temp : std_logic_vector(2047 downto 0);
	
begin

	tag<=addr(31 downto 10);
	setIndex<=addr(9 downto 8);
	subblockIndex<=addr(7 downto 6);
	byteOffset<=addr(5 downto 0);
	
	--CSRAM storage
	csram_1: entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>L2_write, index=>setIndex, din=>write_data, dout=>set1_data
			);
	set1_tag<=set1_data(2069 downto 2048);
	set1_valid<=set1_data(2070);

	csram_2:  entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>L2_write, index=>setIndex, din=>write_data, dout=>set2_data
			);
		set2_tag<=set2_data(2069 downto 2048);
		set2_valid<=set2_data(2070);

	csram_3:  entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>L2_write, index=>setIndex, din=>write_data, dout=>set3_data
			);
		set3_tag<=set3_data(2069 downto 2048);
		set3_valid<=set3_data(2070);

	csram_4:  entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>L2_write, index=>setIndex, din=>write_data, dout=>set4_data
			);
		set4_tag<=set4_data(2069 downto 2048);
		set4_valid<=set4_data(2070);

	--comparators for comparing tags
	comp1_map : entity work.cmp_n
		generic map (n => 22)
		port map (a => tag, b => set1_tag, a_eq_b => set1_match);
	comp2_map : entity work.cmp_n
		generic map (n => 22)
		port map (a => tag, b => set2_tag, a_eq_b => set2_match);
	comp3_map : entity work.cmp_n
		generic map (n => 22)
		port map (a => tag, b => set3_tag, a_eq_b => set3_match);
	comp4_map : entity work.cmp_n
		generic map (n => 22)
		port map (a => tag, b => set4_tag, a_eq_b => set4_match);

	--and gates for detecting both valid bits and tag matches
	and1_map : entity work.and_gate 
		port map (x => set1_valid, y => set1_match, z => and1);
	and2_map : entity work.and_gate 
		port map (x => set2_valid, y => set2_match, z => and2);
	and3_map : entity work.and_gate 
		port map (x => set3_valid, y => set3_match, z => and3);
	and4_map : entity work.and_gate 
		port map (x => set4_valid, y => set4_match, z => and4);
		
	--or gate for hit
	or1_map : entity work.or_4
		port map (a =>  and1, b => and2, c => and3, d => and4, z => hit_temp);
	hit<=hit_temp;

	--not gate for miss
	not_hit : entity work.not_gate
		port map (x => hit_temp, z=>miss);

	--mux for final data selection
	mux1_map : entity work.mux_4_to_1_2048bit
		port map(sel(0) => and1, sel(1) => and2, 
		sel(2) => and3, sel(3) => and4,
		src0 => set1_data(2047 downto 0), src1 => set2_data(2047 downto 0),
		src2 => set3_data(2047 downto 0), src3 => set4_data(2047 downto 0), z => dataOut_temp);

	--mux to determine subblock to output
	dec0: entity work.dec_n generic map(n=>2) port map(src=>subblockIndex, z=>sel_subblock);
	mux2_map : entity work.mux_4_to_1_512bit port map (
		sel=>sel_subblock, src0=>dataOut_temp(511 downto 0), src1=>dataOut_temp(1023 downto 512), src2=>dataOut_temp(1535 downto 1024), src3=>dataOut_temp(2047 downto 1536), z=>dataOut
		);
		
end struct;