----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:30:01 01/27/2017 
-- Design Name: 
-- Module Name:    counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
	port(
		count : out std_logic_vector(3 downto 0));
		enable : in STD_LOGIC;
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
	);
end counter;

architecture Behavioral of counter is
begin

	process (enable,clk,reset) is
	begin
		if (clk = '1' and clk'event) then
			if (reset = '1') then 
				count <= "0000";
			elsif (enable = '1') then
				count <= count + 1;
			end if;
		end if;
	end process;
		

end Behavioral; 

