library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity green_neural_network is
port
(
	clk		: in std_logic;										-- Clock frequency will the same as the VGA clock frequency
	red		: in std_logic_vector(7 downto 0);
	green 	: in std_logic_vector(7 downto 0);
	blue 		: in std_logic_vector(7 downto 0);
	output 	: out std_logic;
)
end neural_network;

architecture behavior of neural_network is

	signal red_in, green_in, blue_in	: integer;
	signal first_hidden_output 		: integer range 0 to 255;
	signal second_hidden_output 		: integer range 0 to 255;
	signal third_hidden_output 		: integer range 0 to 255;
	signal result 							: integer range 0 to 255;
	
begin

first_hidden_neuron : entity neuron is
generic map
(
	first_weight 	=>	10,
	second_weight 	=> -7,
	third_weight 	=>	8,
	bias				=> 866
)
port map
(
	clk 				=> clk,
	first_input 	=> red_in,
	second_input 	=> green_in,
	third_input		=> blue_in,
	output			=> first_hidden_output
);


second_hidden_neuron : entity neuron is
generic map
(
	first_weight 	=>	0,
	second_weight 	=> 1,
	third_weight 	=>	-3,
	bias				=> 9340
)
port map
(
	clk 				=> clk,
	first_input 	=> red_in,
	second_input 	=> green_in,
	third_input		=> blue_in,
	output			=> second_hidden_output
);

third_hidden_neuron : entity neuron is
generic map
(
	first_weight 	=>	-9,
	second_weight 	=> 10,
	third_weight 	=>	-9,
	bias				=> -6017
)
port map
(
	clk 				=> clk,
	first_input 	=> red_in,
	second_input 	=> green_in,
	third_input		=> blue_in,
	output			=> third_hidden_output
);


output_neuron : entity neuron is
generic map
(
	first_weight 	=>	2,
	second_weight 	=> -31,
	third_weight 	=>	19,
	bias				=> -17852
)
port map
(
	clk 				=> clk,
	first_input 	=> first_hidden_output,
	second_input 	=> second_hidden_output,
	third_input		=> third_hidden_output,
	output			=> result
);

process begin

	if (result <= 0) then
		output <= "0";
	else (result > 0)
		output <= "1";
	end if;
	
end process;

end behavior;