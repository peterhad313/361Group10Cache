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
	evict : out std_logic; --eviction notice, written back to cache
	dataOut : out std_logic_vector(511 downto 0)
	
	);
end l2cache;
	
architecture struct of l2cache is
	
	signal tag : std_logic_vector(21 downto 0);
	signal setNumber : std_logic_vector(1 downto 0);
	signal setIndex : std_logic_vector (1 downto 0); 
	signal subblockIndex : std_logic_vector(1 downto 0);
	signal sel_set : std_logic_vector(3 downto 0);
	signal sel_subblock : std_logic_vector(3 downto 0);
	signal byteOffset : std_logic_vector (3 downto 0);

	--tags from sets
	signal set1_tag : std_logic_vector(21 downto 0);
	signal set2_tag : std_logic_vector(21 downto 0);
	signal set3_tag : std_logic_vector(21 downto 0);
	signal set4_tag : std_logic_vector(21 downto 0);

	--write enable sets
	signal set1_write : std_logic;
	signal set2_write : std_logic;
	signal set3_write : std_logic;
	signal set4_write : std_logic;
	
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
	
	--signals for writing
	signal write_data : std_logic_vector(2047 downto 0);

	signal hit_temp : std_logic;
	signal miss_temp : std_logic;
	signal dataOut_temp : std_logic_vector(2047 downto 0);

	signal zeros : std_logic_vector(511 downto 0);
	signal ones : std_logic_vector(511 downto 0);
	signal shiftTemp0 : std_logic_vector(2047 downto 0);
	signal shiftTemp1 : std_logic_vector(2047 downto 0);

	signal write_to_L2,tagged_L2,tagged_line_from_mem: std_logic_vector (2070 downto 0);
    --masks and stuff used for writing
    signal dataMask,clearMask,invertedClearMask,selectivlyClearedLine,L2_with_new_data: std_logic_vector (2047 downto 0);
	
begin

	tag<=addr(31 downto 10);
	setNumber<=addr(9 downto 8);
	setIndex<=addr(7 downto 6);
	subblockIndex<=addr(5 downto 4);
	byteOffset<=addr(3 downto 0);

	--Write data logic
	--create masks to clear and then write
	zeros <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
	ones <= X"11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
	shiftTemp0 <= zeros&zeros&zeros&dataFromL1;
	shiftTemp1 <= zeros&zeros&zeros&ones;

	shift0: entity work.shift_512_2048 port map ( shiftTemp0, subblockIndex, dataMask);
	shift1: entity work.shift_512_2048 port map ( shiftTemp1, subblockIndex, clearMask);
	n2: entity work.not_gate_n generic map (n=>2048) port map ( clearMask, invertedClearMask );
	and_map_L1: entity work.and_gate_n generic map (n=>2048) port map (invertedClearMask, dataOut_temp, selectivlyClearedLine);
	or_map_L1: entity work.or_gate_n generic map (n=>2048) port map (selectivlyClearedLine, dataMask, L2_with_new_data);


	tagged_L2 <= '1' & tag & L2_with_new_data;
	tagged_line_from_mem <= '1'&tag&dataFromMemory;
	L1_data_in_mux_map: entity work.mux_n generic map (n => 2071) port map ( miss_temp, tagged_L2, tagged_line_from_mem, write_to_L2);

	--write enable logic for a write miss
	dec0: entity work.dec_n generic map(n=>2) port map(src=>setNumber, z=>sel_set);
	wrS1: entity work.and_gate port map (
			x=>sel_set(0), y=>writeIn, z=>set1_write
		);
	wrS2: entity work.and_gate port map (
			x=>sel_set(1), y=>writeIn, z=>set2_write
		);
	wrS3: entity work.and_gate port map (
			x=>sel_set(2), y=>writeIn, z=>set3_write
		);
	wrS4: entity work.and_gate port map (
			x=>sel_set(3), y=>writeIn, z=>set4_write
		);
	
	--CSRAM storage
	csram_1: entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>set1_write, index=>setIndex, din=>write_data, dout=>set1_data
			);
	set1_tag<=set1_data(2069 downto 2048);
	set1_valid<=set1_data(2070);

	csram_2:  entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>set2_write, index=>setIndex, din=>write_data, dout=>set2_data
			);
		set2_tag<=set2_data(2069 downto 2048);
		set2_valid<=set2_data(2070);

	csram_3:  entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>set3_write, index=>setIndex, din=>write_data, dout=>set3_data
			);
		set3_tag<=set3_data(2069 downto 2048);
		set3_valid<=set3_data(2070);

	csram_4:  entity work.csram
		generic map(
			INDEX_WIDTH=>2,
			BIT_WIDTH=>2071
			)
		port map(
			cs=>'1', oe=>'1', we=>set4_write, index=>setIndex, din=>write_data, dout=>set4_data
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
		port map (x => hit_temp, z=>miss_temp);
	miss<=miss_temp;

	--mux for final data selection
	mux1_map : entity work.mux_4_to_1_2048bit
		port map(sel(0) => and1, sel(1) => and2, 
		sel(2) => and3, sel(3) => and4,
		src0 => set1_data(2047 downto 0), src1 => set2_data(2047 downto 0),
		src2 => set3_data(2047 downto 0), src3 => set4_data(2047 downto 0), z => dataOut_temp);

	--mux to determine subblock to output
	dec1: entity work.dec_n generic map(n=>2) port map(src=>subblockIndex, z=>sel_subblock);
	mux2_map : entity work.mux_4_to_1_512bit port map (
		sel=>sel_subblock, src0=>dataOut_temp(511 downto 0), src1=>dataOut_temp(1023 downto 512), src2=>dataOut_temp(1535 downto 1024), src3=>dataOut_temp(2047 downto 1536), z=>dataOut
		);
		
end struct;