
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
entity rams_01 is
    port (CLK  : in std_logic;
          WE   : in std_logic;
          EN   : in std_logic;
          ADDR : in std_logic_vector(5 downto 0);
          DI   : in std_logic_vector(15 downto 0);
          DO   : out std_logic_vector(15 downto 0));
end rams_01;

architecture syn of rams_01 is
    type ram_type is array (63 downto 0) of std_logic_vector (15 downto 0);
    signal RAM: ram_type;
	 attribute ram_style : string;
	 attribute ram_style of RAM : signal is "block";
begin
    process (CLK)
	 
    begin
        if CLK'event and CLK = '1' then
            if EN = '1' then
                if WE = '1' then
						  RAM(conv_integer(ADDR)) <= DI;			
                end if;
				 DO <= RAM(conv_integer(ADDR)) ;
            end if;
        end if;
    end process;

end syn;

					