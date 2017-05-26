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

	-- Registers implementing the channels
	signal reg0, reg0_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg1, reg1_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg2, reg2_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg3, reg3_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg4, reg4_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg5, reg5_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg6, reg6_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg7, reg7_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg8, reg8_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg9, reg9_next         : std_logic_vector(7 downto 0)  := x"00";
	signal reg10, reg10_next        : std_logic_vector(7 downto 0)  := x"00";

	
begin													-- BEGIN_SNIPPET(registers)
	-- Infer registers
	process(fx2Clk_in)
	begin
		if ( rising_edge(fx2Clk_in) ) then
			--checksum <= checksum_next;
			reg0 <= reg0_next;
			reg1 <= reg1_next;
			reg2 <= reg2_next;
			reg3 <= reg3_next;
			reg4 <= reg4_next;
			reg5 <= reg5_next;
			reg6 <= reg6_next;
			reg7 <= reg7_next;
			reg8 <= reg8_next;
			reg9 <= reg9_next;
			reg10 <= reg10_next;
			
		end if;
	end process;

	-- Drive register inputs for each channel when the host is writing
	reg0_next <= h2fData when chanAddr = "0000000" and h2fValid = '1' else reg0;
	reg1_next <= h2fData when chanAddr = "0000001" and h2fValid = '1' else reg1;
	reg2_next <= h2fData when chanAddr = "0000010" and h2fValid = '1' else reg2;
	reg3_next <= h2fData when chanAddr = "0000011" and h2fValid = '1' else reg3;
	reg4_next <= h2fData when chanAddr = "0000100" and h2fValid = '1' else reg4;
	reg5_next <= h2fData when chanAddr = "0000101" and h2fValid = '1' else reg5;
	reg6_next <= h2fData when chanAddr = "0000110" and h2fValid = '1' else reg6;
	reg7_next <= h2fData when chanAddr = "0000111" and h2fValid = '1' else reg7;
	reg8_next <= h2fData when chanAddr = "0001000" and h2fValid = '1' else reg8;
	reg9_next <= h2fData when chanAddr = "0001001" and h2fValid = '1' else reg9;
	reg10_next <= std_logic_vector(unsigned(reg1(7 downto 0))/9 + unsigned(reg2(7 downto 0))/9 + unsigned(reg3(7 downto 0))/9 + unsigned(reg4(7 downto 0))/9 + unsigned(reg5(7 downto 0))/9 + unsigned(reg6(7 downto 0))/9 + unsigned(reg7(7 downto 0))/9 + unsigned(reg8(7 downto 0))/9 + unsigned(reg9(7 downto 0))/9);
	
	-- Select values to return for each channel when the host is reading
	with chanAddr select f2hData <=
		slide_sw_in		 	when "0000000", -- return status of slide switches when reading R0
		reg1 				when "0000001",
		reg2 				when "0000010",
		reg3 				when "0000011",
		reg4 				when "0000100",
		reg5 				when "0000101",
		reg6 				when "0000110",
		reg7 				when "0000111",
		reg8 				when "0001000",
		reg9 				when "0001001",
		reg10 			when "0001010",
		x"00" 			when others;

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
	led_out <= reg0;
end behavioural;
