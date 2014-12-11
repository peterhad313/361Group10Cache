library ieee;
use ieee.std_logic_1164.all;

entity l1Cache is
  port (
	clock : in std_logic;
	addr  : in std_logic_vector (31 downto 0);
	write_data : in std_logic_vector(31 downto 0);
	writeEn : in std_logic;
   	L2_hit: in std_logic;
   	L2_Block_In: std_logic_vector(511 downto 0); --Input from L2 to write


	hit : out std_logic;
	miss : out std_logic;
	evict: out std_logic;
	dataOut: out std_logic_vector(31 downto 0);
	data_out_to_L2: out std_logic_vector(511 downto 0) --Output to send to L2
  ) ;
end entity ; -- l1Cache

architecture struct of l1Cache is

	signal tagFromAddr, L1_current_tag: std_logic_vector (21 downto 0);
    signal indexFromAddr: std_logic_vector ( 3 downto 0);
    signal offsetFromAddr, offset_inv, output_shift_amount: std_logic_vector ( 5 downto 0);

    signal L1_Line_Out,tagged_L2_in,tagged_L1_with_new_data: std_logic_vector (534 downto 0);

    signal L1_Line_Out_Data,shifted_L1_Out,write_to_L1,shiftTemp0,shiftTemp1: std_logic_vector ( 511 downto 0);
    signal validFromL1, tag_match, tag_miss: std_logic;

    --masks and stuff used for writing
    signal dataMask,clearMask,invertedClearMask,selectivlyClearedLine,L1_with_new_data,selectivlyClearedBlock: std_logic_vector ( 511 downto 0);

    --TEMP NEED TO REPLACE
    signal REPLACETHIS:std_logic;
    
begin 

tagFromAddr <= addr ( 31 downto 10);
indexFromAddr <= addr (9 downto 6);
offsetFromAddr <= addr (5 downto 0);

--535 by 16 memory
L1_csram: entity work.csram generic map ( INDEX_WIDTH => 4, BIT_WIDTH => 535 )
                port map ( cs => '1', oe => '1', we => writeEn, index => indexFromAddr, din => write_to_L1, dout => L1_Line_Out);

L1_current_tag <= L1_Line_Out(533 downto 512);
validFromL1 <= L1_Line_Out(534);
L1_Line_Out_Data<=L1_Line_Out(511 downto 0);

Comparator_L1: entity work.cmp_n generic map ( n => 22 ) port map ( a => L1_current_tag, b => tagFromAddr, a_eq_b => tag_match); 


--set the hit and miss
n1: entity work.not_gate port map (tag_match, tag_miss);
hit <= tag_match;
miss <= tag_miss;


--create masks to clear and then write
shiftTemp0 <= X"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & write_data;
shiftTemp1 <= X"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & X"11111111";

shift0: entity work.shift_32_512 port map ( shiftTemp0, offsetFromAddr(5 downto 2), dataMask);
shift1: entity work.shift_32_512 port map ( shiftTemp1, offsetFromAddr(5 downto 2), clearMask);
n2: entity work.not_gate_n generic map (n=>512) port map ( clearMask, invertedClearMask );
and_map_L1: entity work.and_gate_n generic map (n=>512) port map (invertedClearMask, L1_Line_Out (511 downto 0), selectivlyClearedLine);
or_map_L1: entity work.or_gate_n generic map (n=>512) port map (selectivlyClearedBlock, dataMask, L1_with_new_data);



tagged_L2_in <= '0' & tagFromAddr & L2_Block_In;
tagged_L1_with_new_data <= '1'&tagFromAddr&L1_with_new_data;
L1_data_in_mux_map: entity work.mux_n generic map (n => 535) port map ( writeEn, tagged_L1_with_new_data, tagged_L2_in, write_to_L1);

--add tag and valid to write

shift2: entity work.shift_32_512 port map (L1_Line_Out_Data,offsetFromAddr(5 downto 2),shifted_L1_Out);
dataOut<=shifted_L1_Out(511 downto 480);


end struct; -- struct