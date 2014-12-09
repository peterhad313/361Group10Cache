library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.eecs361.cache_test;
use work.eecs361.syncram;

entity cache_test_test is
end cache_test_test;

architecture mix of cache_test_test is
signal clk : std_logic := '0';
signal clkinv : std_logic;
signal tmpData : std_logic_vector(31 downto 0);
signal data : std_logic_vector(31 downto 0);
signal addr : std_logic_vector(31 downto 0);
signal rst : std_logic;
signal err : std_logic;
signal wr : std_logic;
signal ready : std_logic;
signal cs : std_logic;
begin
  clk <= not clk after 5 ns;
  clkinv <= not clk;

  rst <= '1', '0' after 2 ns;
  cs <= not rst;

  syncram_map : syncram
    generic map (
      mem_file => "data/mem_init"
    )
    port map (
      clk => clkinv,
      cs => cs,
      oe => '1',
      we => wr,
      addr => addr,
      din => data,
      dout => tmpData
    );

  cache_map : cache_test
    generic map (
      data_trace_file => "data/random_data_trace",
      addr_trace_file => "data/random_addr_trace"
    )
    port map (
      DataIn => tmpData,
      clk => clk,
      ready => ready,
      rst => rst,
      Addr => addr,
      Data => data,
      WR => wr,
      Err => err
    );

  ready <= clkinv;

  err_proc : process (err)
  begin
    if err = '1' then
        report "Err = '1'";
    end if;
  end process;

  process
  begin
    wait for 100 ns;
    wait;
  end process;
end mix;
