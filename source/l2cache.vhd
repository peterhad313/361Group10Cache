library ieee;
use ieee.std_logic_1164.all;

entity l2cache is
	port(
	
	addr : in std_logic_vector(31 downto 0);
	clock : in std_logic;
	write_data : in std_logic_vector(31 downto 0);
	writeIn : in std_logic;
	
	hit : out std_logic;
	miss : out std_logic;
	dataOut : out std_logic_vector(31 downto 0)
	
	);
	end l2cache;
	
architecture struct of l2cache is
	
	signal tag : std_logic_vector(23 downto 0);
	signal setIndex : std_logic_vector (2 downto 0);
	signal byteOffset : std_logic_vector (6 downto 0);
	
	--valid bits from sets
	signal set1_valid : std_logic;
	signal set2_valid : std_logic;
	signal set3_valid : std_logic;
	signal set4_valid : std_logic;
	
	--tags from sets
	signal set1_tag : std_logic_vector (23 downto 0);
	signal set2_tag : std_logic_vector (23 downto 0);
	signal set3_tag : std_logic_vector (23 downto 0);
	signal set4_tag : std_logic_vector (23 downto 0);
	
	--data from sets
	signal set1_data : std_logic_vector (31 downto 0);
	signal set2_data : std_logic_vector (31 downto 0);
	signal set3_data : std_logic_vector (31 downto 0);
	signal set4_data : std_logic_vector (31 downto 0);
	
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
	
	--signals for muxes for indexes
	signal set1_mux, set2_mux, set3_mux, set4_mux : std_logic_vector(23 downto 0);

	signal hit_temp : std_logic;
	
begin

	--muxes for indexes
	-- set1_valid_mux : entity work.mux_4_to_1_bit
		-- port map ();
	
	--and gates for detecting both valid bits and tag matches
	and1_map : entity work.and_gate 
		port map (x => set1_valid, y => set1_match, z => and1);
	and2_map : entity work.and_gate 
		port map (x => set2_valid, y => set2_match, z => and2);
	and3_map : entity work.and_gate 
		port map (x => set3_valid, y => set3_match, z => and3);
	and4_map : entity work.and_gate 
		port map (x => set4_valid, y => set4_match, z => and4);
		
	--comparators for comparing tags
	comp1_map : entity work.cmp_n
		generic map (n => 24)
		port map (a => addr(31 downto 8), b => set1_tag, a_eq_b => set1_match);
	comp2_map : entity work.cmp_n
		generic map (n => 24)
		port map (a => addr(31 downto 8), b => set2_tag, a_eq_b => set2_match);
	comp3_map : entity work.cmp_n
		generic map (n => 24)
		port map (a => addr(31 downto 8), b => set3_tag, a_eq_b => set3_match);
	comp4_map : entity work.cmp_n
		generic map (n => 24)
		port map (a => addr(31 downto 8), b => set4_tag, a_eq_b => set4_match);
		
	--or gate for hit
	or1_map : entity work.or_4
		port map (a =>  and1, b => and2, c => and3, d => and4, z => hit_temp);
	hit<=hit_temp;

	--not gate for miss
	not_hit : entity work.not_gate
		port map (x => hit_temp, z=>miss);

	--mux for final data selection
	mux1_map : entity work.mux_4_to_1_32bit
		port map(sel(0) => and1, sel(1) => and2, 
		sel(2) => and3, sel(3) => and4,
		src0 => set1_data, src1 => set2_data,
		src2 => set3_data, src3 => set4_data, z => dataOut);
		
end struct;