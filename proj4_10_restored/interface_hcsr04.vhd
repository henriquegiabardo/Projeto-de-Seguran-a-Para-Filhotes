library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04 is
	port
	(
		i_clock, i_reset : in std_logic;
		i_medir, i_echo: in std_logic;
		o_trigger, o_pronto: out std_logic;
		o_medida: out std_logic_vector (15 downto 0);
	   db_medir: out std_logic;	
		db_estado: out std_logic_vector (2 downto 0)
	);
end entity;

architecture arch_interface_hcsr04 of interface_hcsr04 is

	signal s_acionar_trigger, s_pronto_trigger, s_medir_echo, s_pronto_medidor: std_logic;

component interface_sensor_de_distancia_UC is 
  port ( 
			i_clock, i_reset,
			medir, pronto_trigger, pronto_medidor, echo: in std_logic;
         acionar_trigger, medir_echo, fim: out std_logic;
			db_estado: out std_logic_vector(2 downto 0)
		 );
end component;

component gerador_pulso is
   generic (
      largura: integer:= 25
   );
   port(
      clock, reset:  in  std_logic;
      gera, para:    in  std_logic;
      pulso, pronto: out std_logic
   );
end component;

component medidor_de_distancia is
	port(
		i_clock, i_reset : in std_logic;
		i_zera: in std_logic;
		i_echo: in std_logic;
		o_pronto: out std_logic;
		o_medida: out std_logic_vector (15 downto 0)	
	);
end component;

begin

		GERADOR_DE_TRIGGER: gerador_pulso generic map (largura => 500) port map(
																i_clock, i_reset,
																s_acionar_trigger, '0',
																o_trigger, s_pronto_trigger
																);
																
		UC: interface_sensor_de_distancia_UC port map(
																	i_clock, i_reset,
																	i_medir, s_pronto_trigger, s_pronto_medidor, i_echo,
																	s_acionar_trigger, s_medir_echo, o_pronto,
																	db_estado
																	);
		MEDIDOR: medidor_de_distancia port map(
															i_clock, i_reset,
															s_acionar_trigger,
															i_echo,
															s_pronto_medidor,
															o_medida
															);	
	
		db_medir <= i_medir;
											
										   
end arch_interface_hcsr04;