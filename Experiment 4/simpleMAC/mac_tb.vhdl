-------------------------------------------------------------------------------
-- Title      : Testbench for design "mac"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : mac_tb.vhdl
-- Author     : 
-- Company    : 
-- Created    : 2007-03-29
-- Last update: 2007-03-30
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-03-29  1.0      toms	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity mac_tb is

end mac_tb;

-------------------------------------------------------------------------------

architecture a of mac_tb is

  component mac
    port (
      a, b     : in  signed(3 downto 0);
      clk, rst : in  std_logic;
      acc      : out signed(7 downto 0));
  end component;

  -- component ports
  signal a, b     : signed(3 downto 0);
  signal acc      : signed(7 downto 0);

  -- clock
  signal clk : std_logic := '1';
  signal reset : std_logic := '1';

begin  -- a

  -- component instantiation
  DUT: mac
    port map (
      a   => a,
      b   => b,
      clk => clk,
      rst => reset,
      acc => acc);

  -- clock generation
  clk <= not clk after 10 ns;
  reset <= '0' after 5 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    a <= "0000";                        -- 0
    b <= "0000";                        -- 0
    wait until Clk = '1';
    a <= "0010";                        -- 2
    b <= "0011";                        -- 3
    wait until Clk = '1';
    a <= "0100";                        --4
    b <= "0110";                        --6
    wait until Clk = '1';    
    a <= "0110";                        -- 6
    b <= "1001";                        -- -7
    wait until Clk = '1';
    a <= "1000";                        -- -8
    b <= "1000";                        -- -8
    wait until Clk = '1';
    a <= "1010";                        -- -6
    b <= "1000";                        -- -8
    wait until Clk = '1';
    a <= "1100";                        -- -4
    b <= "1000";                        -- -8
    wait until Clk = '1';
    a <= "1110";                        -- -2
    b <= "1000";                        -- -8

    assert false report "end of test" severity note;
    wait;

  end process WaveGen_Proc;

  

end a;

-------------------------------------------------------------------------------

configuration mac_tb_a_cfg of mac_tb is
  for a
  end for;
end mac_tb_a_cfg;

-------------------------------------------------------------------------------
