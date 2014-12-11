library ieee;
use ieee.std_logic_1164.all;

entity l1Cache is
  port (
	clock : in std_logic;
	addr  : in std_logic_vector (31 downto 0);
	write_data : in std_logic_vector(31 downto 0);
	writeEn : in std_logic;
	Memory_Valid_Write: in std_logic;
 	Memory_Block_Data_Valid : in std_logic;
   	L2_hit: in std_logic;
   	Enable: in std_logic;
   	L2_Block_In: std_logic_vector(511 downto 0);


	hit : out std_logic;
	miss : out std_logic;
	dataOut: out std_logic_vector(31 downto 0);
	data_out_to_L2: out std_logic_vector(511 downto 0);
	Write_Main_Memory: out std_logic --Eviction notice, written back to cache

  ) ;
end entity ; -- l1Cache

architecture struct of l1Cache is

	signal tagFromAddr, L1_current_tag: std_logic_vector (21 downto 0);
    signal indexFromAddr: std_logic_vector ( 3 downto 0);
    signal offsetFromAddr, offset_inv, output_shift_amount: std_logic_vector ( 5 downto 0);

    signal L1_Block_Out: std_logic_vector (534 downto 0);

    signal L1_Block_Out_Data,shifted_L1_Out: std_logic_vector ( 511 downto 0);
    signal validFromL1, tag_match, tag_miss: std_logic;
    
begin 

tagFromAddr <= addr ( 31 downto 10);
indexFromAddr <= addr (9 downto 6);
offsetFromAddr <= addr (5 downto 0);

--535 by 16 memory
L1_csram: entity work.csram generic map ( INDEX_WIDTH => 4, BIT_WIDTH => 535 )
                port map ( cs => '1', oe => '1', we => writeEn, index => indexFromAddr, din => write_data, dout => L1_Block_Out);

L1_current_tag <= L1_Block_Out(533 downto 512);
validFromL1 <= L1_Block_Out(534);
L1_Block_Out_Data<=L1_Block_Out(511 downto 0);

Comparator_L1: entity work.cmp_n generic map ( n => 22 ) port map ( a => L1_current_tag, b => tagFromAddr, a_eq_b => tag_match); 


--set the hit and miss
n1: entity work.not_gate port map (tag_match, tag_miss);
hit <= tag_match;
miss <= tag_miss;



mux1: entity work.shift_32_512 port map (L1_Block_Out_Data,offsetFromAddr(5 downto 2),shifted_L1_Out);
dataOut<=shifted_L1_Out(511 downto 480);


end struct; -- struct