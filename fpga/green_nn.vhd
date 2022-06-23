-- Sydney Minnaar - 4753046
-- 23-06-2021

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity green_nn is
port
(
	clk_in		: in std_logic;										-- Clock frequency will the same as the VGA clock frequency
	red_in		: in std_logic_vector(7 downto 0);
	green_in 	: in std_logic_vector(7 downto 0);
	blue_in 		: in std_logic_vector(7 downto 0);
	result 		: out std_logic
);
end green_nn;

architecture behavior of green_nn is

	signal red, green, blue				: integer;
	signal first_hidden_output 		: integer;
	signal second_hidden_output 		: integer;
	signal third_hidden_output 		: integer;
	signal output_neuron_result 		: integer := 0;
	
begin

first_hidden_neuron : entity work.neuron
generic map
(
	first_weight 	=>	10,
	second_weight 	=> -7,
	third_weight 	=>	8,
	bias				=> 3
)
port map
(
	clk_in 			=> clk_in,
	first_in 		=> red,
	second_in 		=> green,
	third_in			=> blue,
	result			=> first_hidden_output
);


second_hidden_neuron : entity work.neuron
generic map
(
	first_weight 	=>	0,
	second_weight 	=> 1,
	third_weight 	=>	-3,
	bias				=> 36
)
port map
(
	clk_in 			=> clk_in,
	first_in 		=> red,
	second_in 		=> green,
	third_in			=> blue,
	result			=> second_hidden_output
);

third_hidden_neuron : entity work.neuron
generic map
(
	first_weight 	=>	-9,
	second_weight 	=> 10,
	third_weight 	=>	-9,
	bias				=> -24
)
port map
(
	clk_in 			=> clk_in,
	first_in 		=> red,
	second_in 		=> green,
	third_in			=> blue,
	result			=> third_hidden_output
);


output_neuron : entity work.neuron
generic map
(
	first_weight 	=>	2,
	second_weight 	=> -31,
	third_weight 	=>	19,
	bias				=> -70
)
port map
(
	clk_in			=> clk_in,
	first_in 		=> first_hidden_output,
	second_in 		=> second_hidden_output,
	third_in			=> third_hidden_output,
	result			=> output_neuron_result
);

process begin

	wait until rising_edge(clk_in);
	
	red 	<= to_integer(unsigned(red_in));
	green <= to_integer(unsigned(green_in));
	blue 	<= to_integer(unsigned(blue_in));
	
end process;

process begin

	wait until rising_edge(clk_in);

	if (output_neuron_result >= 3000) then
		result <= '1';
	else
		result <= '0';
	end if;
	
end process;

end behavior;