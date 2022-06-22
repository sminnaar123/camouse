library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity sram_test is
port
(
	-- user controls
	read_or_write	: in std_logic; -- 0 = read, 1 = write
	data_input		: in std_logic_vector(15 downto 0);
	
	-- output leds
	ledr				: out std_logic_vector(15 downto 0);
	
	-- SRAM
	data 				: buffer std_logic_vector(15 downto 0);
	address 			: out std_logic_vector(19 downto 0) := (others => '0');
	output_enable 	: out std_logic := '0';
	write_enable	: out std_logic := '0';
	chip_select		: out std_logic := '1';
	ub					: out std_logic := '0';
	lb					: out std_logic := '0'
);
end sram_test;

architecture behavior of sram_test is begin
	
process(read_or_write) begin

	if (read_or_write = '1') then
		-- disable read
		output_enable <= '0';
		-- prep data line
		data <= data_input;
		-- Write to chip
		write_enable <= '1';
	else
		-- disable write
		write_enable <= '0';
		-- enable read
		output_enable <= '1';
		-- read from chip
		ledr <= data;
	end if;
		
end process;

end behavior;