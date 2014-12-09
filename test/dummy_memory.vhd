library ieee;
use ieee.std_logic_1164.all;
use work.eecs361.syncram;

entity memory_hierarchy is
  generic (
    mem_file : string
  );
  port (
    clk : in std_logic;
    EN : in std_logic;
    WR : in std_logic;
    Addr : in std_logic_vector(31 downto 0);
    DataIn : in std_logic_vector(31 downto 0);
    Ready : out std_logic;
    DataOut : out std_logic_vector(31 downto 0);
    l1_hit_cnt : out std_logic_vector(31 downto 0);
    l1_miss_cnt : out std_logic_vector(31 downto 0);
    l1_evict_cnt : out std_logic_vector(31 downto 0);
    l2_hit_cnt : out std_logic_vector(31 downto 0);
    l2_miss_cnt : out std_logic_vector(31 downto 0);
    l2_evict_cnt : out std_logic_vector(31 downto 0)
  );
end entity memory_hierarchy;

architecture mix of memory_hierarchy is
signal clkinv : std_logic;
begin
  clkinv <= clk;
  ram_map : syncram
    generic map (
      mem_file => mem_file
    )
    port map (
      clk => clkinv,
      cs => EN,
      oe => EN,
      we => WR,
      addr => Addr,
      din => DataIn,
      dout => DataOut
    );
  Ready <= EN and clkinv;
  l1_hit_cnt <= (others => '0');
  l1_miss_cnt <= (others => '0');
  l1_evict_cnt <= (others => '0');
  l2_hit_cnt <= (others => '0');
  l2_miss_cnt <= (others => '0');
  l2_evict_cnt <= (others => '0');
end architecture mix;
