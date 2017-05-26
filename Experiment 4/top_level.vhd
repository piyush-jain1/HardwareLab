library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	port(
		-- FX2 interface -----------------------------------------------------------------------------
		fx2Clk_in     : in    std_logic;                    -- 48MHz clock from FX2
		fx2Addr_out   : out   std_logic_vector(1 downto 0); -- select FIFO: "10" for EP6OUT, "11" for EP8IN
		fx2Data_io    : inout std_logic_vector(7 downto 0); -- 8-bit data to/from FX2

		-- When EP6OUT selected:
		fx2Read_out   : out   std_logic;                    -- asserted (active-low) when reading from FX2
		fx2OE_out     : out   std_logic;                    -- asserted (active-low) to tell FX2 to drive bus
		fx2GotData_in : in    std_logic;                    -- asserted (active-high) when FX2 has data for us

		-- When EP8IN selected:
		fx2Write_out  : out   std_logic;                    -- asserted (active-low) when writing to FX2
		fx2GotRoom_in : in    std_logic;                    -- asserted (active-high) when FX2 has room for more data from us
		fx2PktEnd_out : out   std_logic;                    -- asserted (active-low) when a host read needs to be committed early

		-- Onboard peripherals -----------------------------------------------------------------------
		led_out       : out   std_logic_vector(7 downto 0); -- eight LEDs
		slide_sw_in   : in    std_logic_vector(7 downto 0)  -- eight slide switches
	);
end top_level;

architecture behavioural of top_level is
	type fsm_state is (
		idle,
		writing_A1,
		writing A2,
		reading_B,
		calc_C
		);

	signal curr_state , next_state : fsm_state := writing_A1;
	-- Channel read/write interface -----------------------------------------------------------------
	signal chanAddr  : std_logic_vector(6 downto 0);  -- the selected channel (0-127)

	-- Host >> FPGA pipe:
	signal h2fData   : std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
	signal h2fValid  : std_logic;                     -- '1' means "on the next clock rising edge, please accept the data on h2fData"
	signal h2fReady  : std_logic;                     -- channel logic can drive this low to say "I'm not ready for more data yet"

	-- Host << FPGA pipe:
	signal f2hData   : std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
	signal f2hValid  : std_logic;                     -- channel logic can drive this low to say "I don't have data ready for you"
	signal f2hReady  : std_logic;                     -- '1' means "on the next clock rising edge, put your next byte of data on f2hData"
	-- ----------------------------------------------------------------------------------------------

	-- Needed so that the comm_fpga_fx2 module can drive both fx2Read_out and fx2OE_out
	signal fx2Read                 : std_logic;

	component MODULES is
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
	end component;

	signal to_B, to_B_next, to_C, to_C_next  : std_logic = '0';
	signal enable_dsp, reset_dsp : std_logic := '0';

	signal we_ram_select : std_logic = '0';
	signal we_ram : std_logic_vector(7 downto 0) := (others => '0');
	signal we_ram_next : std_logic_vector(7 downto 0) := (others => '0');
	signal in_ram_x, in_ram_y, in_ram_x_next, in_ram_y_next :  std_logic_vector(7 downto 0) := (others => '0');
	type out_ram is array (0 to 7) of std_logic_vector(7 downto 0);
	signal out_ram_x , out_ram_y : out_ram := (others => (others => '0'));
	signal temp_addr_min, temp_addr_max : std_logic_vector(2 downto 0) := (others => '0');
	signal check_addr-min, check_addr_max : std_logic_vector(6 downto 0) := (others => '0');


begin
	process(fx2Clk_in)
	begin
		if(rising_edge(fx2Clk_in)) then
			curr_state <= next_state;
			to_B <= to_B_next;
			to_C <= to_C_next;
			in_ram_x <= in_ram_x_next;
			in_ram_y <= in_ram_y_next;
			we_ram <= we_ram_next;
		end if;
	end process;

	process(chanAddr)
	begin
		we_ram_next <= "00000000";

		CASE curr_state is
			WHEN writing_A1 =>
				we_ram_select <= '0';	-- select first RAM
				READ_A1 : FOR i in 0 to 7 loop
					temp_addr_min <= std_logic_vector(to_unsigned(i, 3));
					temp_addr_max <= std_logic_vector(to_unsigned(i+1, 3));
					check_addr_min = temp_addr_min & "0000";
					check_addr_max = temp_addr_max & "0000";
					if(chanAddr >= check_addr_min and chanAddr < check_addr_max) then
						we_ram_next <= ( i  => h2fValid,  others => '0');
						exit;
					end if;
				end loop READ_A1;

				if(h2fValid = '1') then
					in_ram_x_next <= h2fData;
				end if;

				if(chanAddr = "1111111") then
					next_state <= writing_A2;
				else
					next_state <= writing_A1;
				end if;

			WHEN writing_A2 =>
				we_ram_select <= '1' --select second RAM
				READ_A2 : FOR i in 0 to 7 loop
					temp_addr_min <= std_logic_vector(to_unsigned(i, 3));
					temp_addr_max <= std_logic_vector(to_unsigned(i+1, 3));
					check_addr_min = temp_addr_min & "0000";
					check_addr_max = temp_addr_max & "0000";
					if(chanAddr >= check_addr_min and chanAddr < check_addr_max) then
						we_ram_next <= ( i  => h2fValid,  others => '0');
						exit;
					end if;
					to_B_next <= '1';
				end loop READ_A2;

				if(h2fValid = '1') then
					in_ram_y_next <= h2fData;
				end if;

				if(chanAddr = "1111111" and to_B = '1') then
					next_state <= reading_B;
				else
					next_state <= writing_A2;
				end if;

			WHEN reading_B =>
				if(h2fValid = '1') then
					enable_dsp <= '1';
					in_RAM_x_next <= h2fData;
					in_RAM_y_next <= h2fData;
				else
					enable_dsp <= '0';
				end if;

				if(chanAddr = "0101111") then
					next_state <= calc_C;
				else
					next_state <= reading_B;
				end if;

			WHEN calc_C =>
				to_C_next <= '1';
				WHILE (chanAddr(3 downto 0) >= "0000" and chanAddr(3 downto 0) <= "0111") loop
					f2hData <= out_ram_x(to_integer(unsigned(chanAddr(3 downto 0)), 4));
				end loop;
				WHILE (chanAddr(3 downto 0) >= "1000" and chanAddr(3 downto 0) <= "1111") loop
					f2hData <= out_ram_y(to_integer(unsigned(chanAddr(3 downto 0)) - 8, 4));
				end loop;

				if(chanAddr = "1001111") then
					next_state <= idle;
				elsif (chanAddr = "0001111") then
					next_state <= reading_B;
				else
					next_state <= calc_C;
				end if;

			WHEN others =>
				next_state <= idle;
		end case;
	end process;

	-- instantiating 8 modules
	begin
		GEN_MODULES: 
		for I in 0 to 7 generate
			MODULESX : MODULES port map (
				Clk			:	fx2Clk_in;
				address 	:	to_integer(unsigned(chanAddr(3 downto 0)));
				we 			:	we_ram(I);
				select_ram	:	we_ram_select;
				data_i_x 	: 	in_ram_x;
				data_i_y 	: 	in_ram_y;
		        data_o_x 	: 	out_ram_x(I);
				data_o_y 	: 	out_ram_y(I);
				enable_dsp 	:	enable_dsp;
				reset_dsp	:	reset_dsp; 
			);
	end generate GEN_MODULES;

-- Assert that there's always data for reading, and always room for writing
	f2hValid <= '1';
	h2fReady <= '1';								--END_SNIPPET(registers)

	-- CommFPGA module
	fx2Read_out <= fx2Read;
	fx2OE_out <= fx2Read;
	fx2Addr_out(1) <= '1';  -- Use EP6OUT/EP8IN, not EP2OUT/EP4IN.
	comm_fpga_fx2 : entity work.comm_fpga_fx2
		port map(
			-- FX2 interface
			fx2Clk_in      => fx2Clk_in,
			fx2FifoSel_out => fx2Addr_out(0),
			fx2Data_io     => fx2Data_io,
			fx2Read_out    => fx2Read,
			fx2GotData_in  => fx2GotData_in,
			fx2Write_out   => fx2Write_out,
			fx2GotRoom_in  => fx2GotRoom_in,
			fx2PktEnd_out  => fx2PktEnd_out,

			-- Channel read/write interface
			chanAddr_out   => chanAddr,
			h2fData_out    => h2fData,
			h2fValid_out   => h2fValid,
			h2fReady_in    => h2fReady,
			f2hData_in     => f2hData,
			f2hValid_in    => f2hValid,
			f2hReady_out   => f2hReady
		);

	-- LEDs
	--led_out <= f2hData;
end behavioural;

				









