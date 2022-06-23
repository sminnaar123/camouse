-- Sydney Minnaar - 4753046
-- 23-06-2021

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity sram_controller is
port
(
	-- clock for regulating write and read speed
	clk				: in std_logic;

	-- user controls
	read_or_write	: in std_logic; -- 0 = read, 1 = write
	data_input		: in std_logic_vector(15 downto 0);
	data_output		: out std_logic_vector(15 downto 0);
	addr_input		: buffer std_logic_vector(19 downto 0);
	
	-- SRAM
	data 				: buffer std_logic_vector(15 downto 0);
	address 			: out std_logic_vector(19 downto 0);
	output_enable 	: out std_logic := '0';
	write_enable	: out std_logic := '0';
	chip_select		: out std_logic := '1';
	ub					: out std_logic := '0';
	lb					: out std_logic := '0'
);
end sram_controller;

architecture behavior of sram_controller is begin
	
process begin

	wait until (rising_edge(clk));
	
	-- disable write_enable on next rising clock edge
	write_enable <= '0';
	-- prep address line
	address <= addr_input;

	if (read_or_write = '1') then
		-- disable read
		output_enable <= '0';
		-- prep data line
		data <= data_input;
		-- Write to chip
		write_enable <= '1';
	else
		-- enable read
		output_enable <= '1';
		-- read from chip
		data_output <= data;
	end if;
		
end process;

end behavior;