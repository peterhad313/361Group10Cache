library ieee;
use ieee.std_logic_1164.all;

entity memory_hierarchy is
	generic (
	--mem_file is used to initialize your main memory.
	mem_file : string
	);
	port (
	--clock
	clk : in std_logic;
	--EN = ‘1’ means the inputs are ready in the coming rising edge.
	EN : in std_logic;
	--WR = ‘1’ means the next request is a write request.
	WR : in std_logic;
	--Addr is the address of the request.
	Addr : in std_logic_vector(31 downto 0);
	--DataIn is the data to be written. It is only valid when the request is a write request.
	DataIn : in std_logic_vector(31 downto 0);
	--Ready = ‘1’ means your cache have finish the current request. Before you rise Ready to ‘1’, your cache should either finished the write
	--request, or you have get the data of the read request at DataOut port.
	Ready : out std_logic;
	--DataOut is the data for read requests.
	DataOut : out std_logic_vector(31 downto 0);
	--Below are the counters of your caches.
	l1_hit_cnt : out std_logic_vector(31 downto 0);
	l1_miss_cnt : out std_logic_vector(31 downto 0);
	l1_evict_cnt : out std_logic_vector(31 downto 0);
	l2_hit_cnt : out std_logic_vector(31 downto 0);
	l2_miss_cnt : out std_logic_vector(31 downto 0);
	l2_evict_cnt : out std_logic_vector(31 downto 0)
	);
end memory_hierarchy;

architecture struct of memory_hierarchy is 
	-- Signals for hits and misses
	signal hit_L1, hit_L2, miss_L1, miss_L2, evict_L1, evict_L2 : std_logic;
	--Counter signals
	signal l1_hit_cnt_temp, l1_miss_cnt_temp, l1_evict_cnt_temp, l2_hit_cnt_temp, l2_miss_cnt_temp, l2_evict_cnt_temp : std_logic_vector(31 downto 0);
	-- Temporary data signals
	signal dataOut_L1, dataOut_caches : std_logic_vector(31 downto 0);
	signal dataOut_L2 : std_logic_vector(511 downto 0);
	signal dataOut_mem : std_logic_vector(2047 downto 0);
	--Logic signals for L1
	signal L1_dataIn : std_logic_vector(31 downto 0);
	signal wr_L1 : std_logic;
	signal wr_temp_L1: std_logic;
	--Logic signals for L2
	signal wr_L2 : std_logic;
	--Logic signals for memory
	signal MemActive : std_logic;

	signal L2_from_L1 : std_logic_vector(511 downto 0);
	signal memoryValid : std_logic;

begin
	--Set temp counter signals
	l1_hit_cnt_temp<=x"00000000";
	l1_miss_cnt_temp<=x"00000000";
	l1_evict_cnt_temp<=x"00000000";
	l2_hit_cnt_temp<=x"00000000";
	l2_miss_cnt_temp<=x"00000000";
	l2_evict_cnt_temp<=x"00000000";

	--Level 1 cache
	--Level 1 cache writes if the write signal is applied or if it misses and needs to be written into
	and_wrL1: entity work.and_gate port map(
		x=>miss_L1, y=>hit_L2, z=>wr_temp_L1
		);
	or_wrL1: entity work.or_gate port map(
		x=>WR, y=>wr_temp_L1, z=>wr_L1
		);
	L1: entity work.l1Cache port map (
		clock=>clk, addr=>Addr, write_data=>L1_dataIn, writeEn=>wr_L1, L2_hit=>hit_L2, L2_Block_In=>dataOut_L2, hit=>hit_L1, miss=>miss_L1, evict=>evict_L1, dataOut=>dataOut_L1, data_out_to_L2=>L2_from_L1
		);

	--Level 2 cache, gets initial Addr and Data_In
	--Only receives write signal if there is a miss or if there is an eviction from L1
	and_wrL2: entity work.and_gate port map (
		x=>miss_L2, y=>evict_L1, z=>wr_L2
		);
	L2: entity work.l2cache port map (
		addr=>Addr, clock=>clk, writeIn=>wr_L2, memoryValid=>memoryValid, dataFromL1=>L2_from_L1, dataFromMemory=>dataOut_mem, hit=>hit_L2, miss=>miss_L2, evict=>evict_L2, dataOut=>dataOut_L2
		);

	--Memory, SRAM for now but can be changed
	--cs (Memory active) is only set if both L1 and L2 missed
	--Right now oe is always set, need logic for oe and we
	and_cs: entity work.and_gate port map (
		x=>miss_L1, y=>miss_L2, z=>MemActive
		);
	mem: entity work.sram 
		generic map ("mem_init")
		port map (
			cs=>MemActive, oe=>'1', we=>'0', addr=>Addr, din=>DataIn, dout=>dataOut_mem(31 downto 0)
		);

	--Muxes to select DataOut from data signals
	--cache_mux is dataout_L1 if hit in L1, otherwise dataout_L2
	--cache_mux: entity work.mux_32 port map (
	--	sel=>hit_L1, src0=>dataOut_L2, src1=>dataOut_L1, z=>dataOut_caches
	--	);
	--data_mux is dataOut_Mem if MemActive=1, otherwise dataOut_caches
	--data_mux: entity work.mux_32 port map (
	--	sel=>MemActive, src0=>dataOut_caches, src1=>dataOut_Mem, z=>DataOut
	--	);
	dataOut<=dataout_L1;

	--OR gate to decide if Data is ready: this logic will need to change as design complexity increases
	or_ready: entity work.or_3 port map (
		a=>hit_L1, b=>hit_L2, c=>MemActive
		);

	--Increment counters
	inc_hitL1: entity work.fulladder_32 port map  (
		cin=>hit_L1, x=>l1_hit_cnt_temp, y=>x"00000000", z=>l1_hit_cnt
		);
	inc_missL1: entity work.fulladder_32 port map  (
		cin=>miss_L1, x=>l1_miss_cnt_temp, y=>x"00000000", z=>l1_miss_cnt
		);
	inc_evictL1: entity work.fulladder_32 port map  (
		cin=>evict_L1, x=>l1_evict_cnt_temp, y=>x"00000000", z=>l1_evict_cnt
		);
	inc_hitL2: entity work.fulladder_32 port map  (
		cin=>hit_L2, x=>l2_hit_cnt_temp, y=>x"00000000", z=>l2_hit_cnt
		);
	inc_missL2: entity work.fulladder_32 port map  (
		cin=>miss_L2, x=>l2_miss_cnt_temp, y=>x"00000000", z=>l2_miss_cnt
		);
	inc_evictL2: entity work.fulladder_32 port map  (
		cin=>evict_L2, x=>l2_evict_cnt_temp, y=>x"00000000", z=>l2_evict_cnt
		);

end struct ; -- struct