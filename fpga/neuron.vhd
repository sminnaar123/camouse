library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity neuron is
generic
(
	first_weight 	: integer;
	second_weight 	: integer;
	third_weight 	: integer;
	bias				: integer;
)
port
(
	clk 				: in std_logic;
	first_input 	: in integer;
	second_input 	: in integer;
	third_input 	: in integer;
	output 			: out integer := 0;
)
end neuron;

architecture behavior of neuron is begin

process begin

	wait until rising_edge(clk);
	
	output <= (first_weight * first_input + second_weight * second_input + third_weight * third_input + bias);

end process;