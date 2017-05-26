----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:09:44 03/03/2014 
-- Design Name: 
-- Module Name:    Top - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
entity Top is
     port(
           sys_clk    : in std_logic; 
           reset_btn  : in std_logic;
           uart_rx    : in std_logic;
           uart_tx    : out std_logic;
           led        : out std_logic_vector(7 downto 0);
			  ram_output : out std_logic_vector(15 downto 0)
      );
end Top;
architecture arch of Top is
component rams_01 is
		port (CLK  : in std_logic;
          WE   : in std_logic;
          EN   : in std_logic;
          ADDR : in std_logic_vector(5 downto 0);
          DI   : in std_logic_vector(15 downto 0);
          DO   : out std_logic_vector(15 downto 0));
	end component;

component uartRxTx is
   generic (
       DIVISOR: natural
   );
   port (
        clk       : in std_logic;                       
        reset     : in std_logic;
        rx_data   : out std_logic_vector(7 downto 0);   
        rx_enable : out std_logic;                      
        tx_data   : in std_logic_vector(7 downto 0);  
        tx_enable : in std_logic;                       
        tx_ready  : out std_logic;                   
        rx        : in std_logic;
        tx        : out std_logic
  );
end component;

type fsm_state_t is (idle, received, emitting);
type state_t is
     record
       fsm_state: fsm_state_t; 
       tx_data: std_logic_vector(7 downto 0);
       tx_enable: std_logic;
   end record;
signal reset: std_logic;
signal uart_rx_data: std_logic_vector(7 downto 0);
signal uart_rx_enable: std_logic;
signal uart_tx_data: std_logic_vector(7 downto 0);
signal uart_tx_enable: std_logic;
signal uart_tx_ready: std_logic;
signal ram_CLK 	:  std_logic;
signal ram_WE 	   :  std_logic;
signal ram_EN     : std_logic;
signal ram_ADDR   : std_logic_vector(5 downto 0);
signal ram_DI     :  std_logic_vector(15 downto 0);
signal temp : std_logic_vector(15 downto 0);
signal ram_DO : std_logic_vector(15 downto 0);
signal state,state_next: state_t;
shared variable count : integer := 0;
shared variable average : integer := 0;
begin
	--count <= "00000000";
	ram_output <= ram_DO;
	ram2 : rams_01
		port map ( 
			CLK => sys_clk,
			WE => ram_WE,
			EN => ram_EN,
			ADDR => ram_ADDR,
			DI => ram_DI,
			DO => ram_DO
		);
  unitRxTx: uartRxTx
  generic map (DIVISOR => 651) 
  port map (
    clk => sys_clk, reset => reset,
    rx_data => uart_rx_data, rx_enable => uart_rx_enable,
    tx_data => uart_tx_data, tx_enable => uart_tx_enable, tx_ready => uart_tx_ready,
    rx => uart_rx,
    tx => uart_tx
  );
  
  ram_EN <= '1';
  reset_control: process (reset_btn) is
                   begin
                       if reset_btn = '1' then
                          reset <= '0';
                       else
                          reset <= '1';
                       end if;
                 end process;
  
 
  fsm_clk: process (sys_clk,reset) is
            begin
              if reset = '1' then
                   state.fsm_state <= idle;
                   state.tx_data <= (others => '0');
                   state.tx_enable <= '0';
              else
                  if rising_edge(sys_clk) then
                     state <= state_next;
									if state.fsm_state = emitting  then
									count := count + 1;
										if(count = 20) then
											count := 0;
											average := 0;
										end if;
									else if state.fsm_state = idle then
									average := conv_integer(ram_DI)/9 + average;
									end if;
								end if;
						 end if;
              end if;
  end process;
  
  fsm_next: process (state,uart_rx_enable,uart_rx_data,uart_tx_ready) is
             begin
               state_next <= state;
                  case state.fsm_state is
                    when idle =>
                          if uart_rx_enable = '1' then
                             state_next.tx_data <= uart_rx_data;
                             state_next.tx_enable <= '0';
									  ram_WE <= '1';
									  ram_ADDR <= conv_std_logic_vector(count,6);
									  ram_DI <= "00000000"&uart_rx_data;
                             ram_WE<= '0';
									  state_next.fsm_state <= received;
                          end if;
  
                   when received =>
							
                         if uart_tx_ready = '1' then
                             state_next.tx_enable <= '1';
                             state_next.fsm_state <= emitting;
                         end if;
      
                   when emitting =>
                         if uart_tx_ready = '0' then
                            state_next.tx_enable <= '0';
                            state_next.fsm_state <= idle;
                         end if;
      
                 end case;
           end process;
  
  fsm_output: process (state) is
               begin
                  uart_tx_enable <= state.tx_enable;
                  uart_tx_data <= conv_std_logic_vector(average,8);
                  led <= conv_std_logic_vector(count,8);
						--led <= x"00";
              end process;
  
end arch;