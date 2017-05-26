library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_functions.all;

-------------------------------------------------------------------------------
entity mac is
  port (
    a, b     : in  signed(3 downto 0);
    clk, rst : in  std_logic;
    acc      : out signed(7 downto 0));
end mac;

architecture a of mac is

  signal prod,reg1 : signed(7 downto 0);
begin
  process (rst,clk)
    variable sum : signed(7 downto 0);
  begin  -- process
    prod <=  a * b;
    if (rst ='1') then
      reg1 <= (others => '0');
    elsif (clk'event and clk='1') then
      sum := add_truncate(prod, reg1, 8);
      reg1 <= sum;
    end if;
    acc <= reg1;
  end process;
      
end a;

