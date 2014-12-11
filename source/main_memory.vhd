library ieee;
use ieee.std_logic_1164.all;


entity main_memory is
	generic ( mem_file: string);
	port (
		clk:     	in std_logic; 
		reset:		in std_logic; 
		address:	   in std_logic_vector(31 downto 0); 
		--L2_Miss: 	in std_logic; --reading
		main_write: 	in std_logic; --writing
		data_in: 	in std_logic_vector (511 downto 0);
		data_valid_read: 	out std_logic;
		--data_valid_write: 	out std_logic;
		data_out_with_tag: 	out std_logic_vector(2069 downto 0)
	);
end main_memory;

architecture structural of main_memory is

signal counter_out, muxed_reset,adder_out,address_offset, addressPlusOffset, syncram0: std_logic_vector(31 downto 0);
signal temp_in, temp_out : std_logic_vector(2047 downto 0);

begin


syncram_map:   entity work.syncram generic map (mem_file => mem_file)
   port map (clk=>clk, cs=>'1', oe=>'1', we=>main_write, addr=>addressPlusOffset, din=>data_in(511 downto 480), dout=>syncram0);
mux1: entity work.mux_n generic map (n=>32) port map (reset, adder_out,X"00000000",muxed_reset);
ff1: entity work.dff_32 port map (clk, muxed_reset, counter_out);

adder1: entity work.fulladder_32 port map (cin=>'1',x=>counter_out,y=>X"00000000", z=>adder_out);

cmp: entity work.cmp_n generic map (n=>32) port map (a=>adder_out, b=>X"0000002F", a_eq_b=>data_valid_read);

address_offset<=adder_out(26 downto 0) & B"00000";
adder2: entity work.fulladder_32 port map (cin=>'0', x=>address, y=>address_offset, z=>addressPlusOffset);

memeTemp: entity work.dff_2048 port map (clk, temp_in, temp_out);
temp_in<=temp_out(2015 downto 0) & syncram0;

data_out_with_tag<=address(31 downto 10)&temp_out;
   
end architecture structural;
