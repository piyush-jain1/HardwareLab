library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity modules is
port (	Clk			:	in std_logic;
		address 	:	in integer;
		we 			:	in std_logic;
		select_ram	:	in std_logic;
		data_i_x 	: 	in std_logic_vector(7 downto 0);
		data_i_y 	: 	in std_logic_vector(7 downto 0);
        data_o_x 	: 	out std_logic_vector(7 downto 0);
		data_o_y 	: 	out std_logic_vector(7 downto 0);
		enable_dsp 	:	in std_logic;
		reset_dsp	:	in std_logic; 
);
end modules;

architecture Behavioral of block-ram is
--Declaration of type and signal of a 16 element RAM
--with each element being 8 bit wide.
type ram_t is array (0 to 15) of std_logic_vector(7 downto 0);
signal ram_x, ram_y : ram_t := (others => (others => '0'));
signal acc_x, acc_y, acc_x_prev, acc_y_prev :std_logic_vector(7 downto 0) := (others => '0');
signal prod_x, prod_y	: signed(15 downto 0);

--process for read and write operation
PROCESS(clk)
BEGIN
	if(rising_edge(Clk)) then
		if(we = '1') then
			if(select_ram = '0') then
				ram_x(address) <= data_i_x;
			elsif(select_ram = '1') then
				ram_y(address) <= data_i_y;
			end if;
		elsif(enable_dsp = '1') then
			prod_x <= unsigned(ram_x(address))*unsigned(data_i_x);
			data_o_x <= std_logic_vector(prod_x(7 downto 0)	+ unsigned(acc_x_prev));
			prod_y <= unsigned(ram_y(address))*unsigned(data_i_y);
			data_o_y <= unsigned(ram_y(address))*unsigned(acc_y_prev);
		elsif(reset_dsp = '1') then
			acc_x = '00000000';
			acc_y = '00000000';
			acc_x_prev = '00000000';
			acc_y_prev = '00000000';
		end if;
		acc_x_prev = acc_x;
		acc_y_prev = acc_y;
		data_o_x <= acc;
		data_o_y <= acc;

END PROCESS;
end Behavioral;
