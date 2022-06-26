-- Sydney Minnaar - 4753046
-- 26-06-2021

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity nn_processing is
port
(
	red_nn				: in std_logic;
	green_nn				: in std_logic;
	x						: in std_logic_vector(12 downto 0);
	y						: in std_logic_vector(12 downto 0);
	
	data 					: out std_logic_vector(15 downto 0);
	address 				: out std_logic_vector(19 downto 0);
	enable				: inout std_logic
);
end nn_processing;

architecture behavior of nn_processing is

	signal color_turn 	:	std_logic;	-- 0 = green, 	1 = red
	signal coord_turn 	: 	std_logic;	-- 0 = x, 	  	1 = y

begin

process(red_nn, green_nn) begin

	if (enable = '1') then
	
		enable <= '0';
	
	--elsif (color_turn = '0') then
	
	elsif (green_nn = '1') then

		data 		<= (others => '1');
		address 	<= (others => '0');
		enable 	<= '1';

	elsif (green_nn = '0') then

		data 		<= (others => '0');
		address 	<= (others => '0');
		enable 	<= '1';
	
	end if;
			
			--color_turn 	<= '1';
	
--	else
		
--			if (red_nn = '1') then

--					if (coord_turn = '0') then
				
--						data 		<= std_logic_vector(resize(unsigned(x), data'length));
--						address 	<= std_logic_vector(to_unsigned(16, address'length));
--						enable 	<= '1';
--						coord_turn 	<= '1';
				
--					else
				
--						data 		<= std_logic_vector(resize(unsigned(y), data'length));
--						address 	<= std_logic_vector(to_unsigned(32, address'length));
--						enable 	<= '1';
--						coord_turn 	<= '0';
				
--					end if;
			
--			end if;
			
--			color_turn 	<= '0';
			
	-- end if;

end process;

end behavior;