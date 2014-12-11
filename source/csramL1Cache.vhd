library ieee;
use ieee.std_logic_1164.all;

entity csramL1Cache is
  port (
	cs	  : in	std_logic;
	oe	  :	in	std_logic;
	we	  :	in	std_logic;
	index : in	std_logic_vector(3 downto 0);
	din	  :	in	std_logic_vector(31 downto 0);
	dout  :	out std_logic_vector(31 downto 0)
  );
end entity ; -- csramL1Cache

architecture struct of csramL1Cache is

component csram is
  generic (
    INDEX_WIDTH : integer;
    BIT_WIDTH : integer
  );
  port (
	cs	  : in	std_logic;
	oe	  :	in	std_logic;
	we	  :	in	std_logic;
	index : in	std_logic_vector(INDEX_WIDTH-1 downto 0);
	din	  :	in	std_logic_vector(BIT_WIDTH-1 downto 0);
	dout  :	out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end component;



begin 

  csr : csram
    generic map (INDEX_WIDTH => 4, BIT_WIDTH => 512)
    port map (cs,oe,we,index,din,dout);
end architecture ; -- struct