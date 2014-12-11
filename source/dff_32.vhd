library ieee;
use ieee.std_logic_1164.all;

entity dff_32 is 
  port(
    clock : in std_logic;
    input : in std_logic_vector(31 downto 0);
    output: out std_logic_vector(31 downto 0)
  );
end dff_32;

architecture struct of dff_32 is
  
  component dffr is
  port (
	clk	: in  std_logic;
	d	: in  std_logic;
	q	: out std_logic:='0'
  );
end component;
  
begin
  
	  dffr0: dffr port map (clock,input(0),output(0));
    dffr1: dffr port map (clock,input(1),output(1));
    dffr2: dffr port map (clock,input(2),output(2));
    dffr3: dffr port map (clock,input(3),output(3));
    dffr4: dffr port map (clock,input(4),output(4));
    dffr5: dffr port map (clock,input(5),output(5));
    dffr6: dffr port map (clock,input(6),output(6));
    dffr7: dffr port map (clock,input(7),output(7));
    dffr8: dffr port map (clock,input(8),output(8));
    dffr9: dffr port map (clock,input(9),output(9));
    dffr10: dffr port map (clock,input(10),output(10));
    dffr11: dffr port map (clock,input(11),output(11));
    dffr12: dffr port map (clock,input(12),output(12));
    dffr13: dffr port map (clock,input(13),output(13));
    dffr14: dffr port map (clock,input(14),output(14));
    dffr15: dffr port map (clock,input(15),output(15));
    dffr16: dffr port map (clock,input(16),output(16));
    dffr17: dffr port map (clock,input(17),output(17));
    dffr18: dffr port map (clock,input(18),output(18));
    dffr19: dffr port map (clock,input(19),output(19));
    dffr20: dffr port map (clock,input(20),output(20));
    dffr21: dffr port map (clock,input(21),output(21));
    dffr22: dffr port map (clock,input(22),output(22));
    dffr23: dffr port map (clock,input(23),output(23));
    dffr24: dffr port map (clock,input(24),output(24));
    dffr25: dffr port map (clock,input(25),output(25));
    dffr26: dffr port map (clock,input(26),output(26));
    dffr27: dffr port map (clock,input(27),output(27));
    dffr28: dffr port map (clock,input(28),output(28));
    dffr29: dffr port map (clock,input(29),output(29));
    dffr30: dffr port map (clock,input(30),output(30));
    dffr31: dffr port map (clock,input(31),output(31));
  
end struct;