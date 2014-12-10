library ieee;
use ieee.std_logic_1164.all;

entity SetL1 is
  port (
	clock   	: in  std_logic;
	valid_in   	: in  std_logic;
	tag_in   	: in  std_logic_vector(23 downto 0);
	data_block_in: in  std_logic_vector(31 downto 0);
	we 			: in std_logic;
	block_offset  : in std_logic_vector(3 downto 0);
	
	valid_out 	: out std_logic;
	tag_out	    : out std_logic_vector(23 downto 0);
	data_block_out : out std_logic_vector(31 downto 0)
  );
end SetL1;

architecture struct of SetL1 is


begin

csram0: entity work.csramL1Cache port map('1','1',we,block_offset,data_block_in,data_block_out);
valid0: entity work.valid port map (clock, we, valid_in,valid_out);
tag0: entity work.tag port map (clock, we, tag_in, tag_out);

end architecture ; -- struct
