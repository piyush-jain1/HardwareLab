library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ram_example is
port (Clk : in std_logic;
        address : in integer;
        we : in std_logic;
        data_i_x : in std_logic_vector(7 downto 0);
		  data_i_y : in std_logic_vector(7 downto 0);
        data_o_x : out std_logic_vector(7 downto 0);
		  data_o_y : out std_logic_vector(7 downto 0)
     );
end ram_example;

architecture Behavioral of ram_example is

--Declaration of type and signal of a 256 element RAM
--with each element being 8 bit wide.
type ram_t is array (0 to 255) of std_logic_vector(7 downto 0);
signal ram_x, ram_y : ram_t := (others => (others => '0'));

begin

--process for read and write operation.
PROCESS(Clk)
BEGIN
    if(rising_edge(Clk)) then
        if(we='1') then
            ram_x(address) <= data_i_x;
				ram_y(address) <= data_i_y;
        end if;
        data_o_x <= ram_x(address);
		data_o_y <= ram_y(address);
    end if;
END PROCESS;

end Behavioral;