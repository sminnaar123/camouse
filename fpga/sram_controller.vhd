-- Sydney Minnaar - 4753046
-- 23-06-2021

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity sram_controller is
port
(
	clk					: in std_logic;
	reset					: in std_logic;

	-- Schematic side
	enable				: in std_logic; -- 0 = nios read, 1 = schematic write
	data_input			: in std_logic_vector(15 downto 0);
	addr_input			: in std_logic_vector(19 downto 0);
	
	-- SRAM side
	data 					: inout std_logic_vector(15 downto 0);
	address 				: out std_logic_vector(19 downto 0);
	output_enable 		: out std_logic := '0';
	write_enable		: buffer std_logic := '0';
	
	-- static
	chip_select			: out std_logic := '1';
	ub						: out std_logic := '0';
	lb						: out std_logic := '0'
);
end sram_controller;

architecture behavior of sram_controller is

	-- NIOS side
	signal data_sgnl				: std_logic_vector(15 downto 0) := (others => '0');
	signal address_sgnl 			: std_logic_vector(19 downto 0) := (others => '0');

begin
	
process begin

	wait until rising_edge(clk);
	
	if (write_enable = '1') then
	
		-- reset write and skip a clock cycle
		write_enable 	<= '0';
		
	elsif (enable = '0') then
	
		-- nios read
		address 				<= address_sgnl;
		output_enable 		<= '1';
		write_enable 		<= '0';
		data_sgnl 			<= data;
		
	else
	
		address 				<= addr_input;
		data 					<= data_input;
		output_enable 		<= '0';
		write_enable 		<= '1';

	end if;
		
end process;

-- NIOS II Processor
display : entity work.display
port map
(
	clk_clk			=>	clk,
	reset_reset_n	=>	reset,
	sram_DQ			=>	data_sgnl,
	sram_ADDR		=>	address_sgnl
);

end behavior;