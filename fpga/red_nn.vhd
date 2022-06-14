library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity red_nn is
port
(
	clk_in		: in std_logic;										-- Clock frequency will the same as the VGA clock frequency
	red_in		: in std_logic_vector(7 downto 0);
	green_in 	: in std_logic_vector(7 downto 0);
	blue_in 		: in std_logic_vector(7 downto 0);
	result 		: out std_logic_vector(17 downto 0)
);
end red_nn;

architecture behavior of red_nn is

	signal red, green, blue				: integer;
	signal first_hidden_output 		: integer;
	signal second_hidden_output 		: integer;
	signal third_hidden_output 		: integer;
	signal output_neuron_result 		: integer := 0;
	
begin

first_hidden_neuron : entity work.neuron
generic map
(
	first_weight 	=>	9,
	second_weight 	=> 4,
	third_weight 	=>	-8,
	bias				=> 10
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
	first_weight 	=>	-2,
	second_weight 	=> -24,
	third_weight 	=>	-19,
	bias				=> -21
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
	first_weight 	=>	-15,
	second_weight 	=> 21,
	third_weight 	=>	6,
	bias				=> 56
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
	first_weight 	=>	-9,
	second_weight 	=> 33,
	third_weight 	=>	-56,
	bias				=> -39
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

	if (output_neuron_result >= 127) then
		result <= (others => '1');
	else
		result <= (others => '0');
	end if;
	
end process;

end behavior;