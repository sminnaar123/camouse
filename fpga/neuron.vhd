library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity neuron is
generic
(
	first_weight 	: integer;
	second_weight 	: integer;
	third_weight 	: integer;
	bias				: integer
);
port
(
	clk_in 		: in std_logic;
	first_in 	: in integer;
	second_in 	: in integer;
	third_in 	: in integer;
	result 		: out integer := 0
);
end neuron;

architecture behavior of neuron is begin

process begin

	wait until rising_edge(clk_in);
	
	result <= (first_weight * first_in + second_weight * second_in + third_weight * third_in + bias);

end process;

end behavior;