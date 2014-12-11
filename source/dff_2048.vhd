library ieee;
use ieee.std_logic_1164.all;

entity dff_2048 is 
  port(
    clock : in std_logic;
    input : in std_logic_vector(2047 downto 0);
    output: out std_logic_vector(2047 downto 0)
  );
end dff_2048;

architecture struct of dff_2048 is
  
  component dff is
  port (
	clk	: in  std_logic;
	d	: in  std_logic;
	q	: out std_logic:='0'
  );
end component;
  
begin
    FFGEN:
     for n in 0 to 2047 generate
      dffX : dff port map (clock, input(n),output(n));
   end generate FFGEN;

end struct;