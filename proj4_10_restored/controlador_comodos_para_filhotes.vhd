library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlador_comodos_para_filhotes is
	port
	(
		i_clock, i_reset: in std_logic;
		i_ligado, i_modo, i_portaX, i_portaY: in std_logic;
		o_porta0, o_porta1, o_portaX, o_portaY: out std_logic; -- porta em 0 é aberta em 1 é fechada
		
		i_filhote: in std_logic; 
		
		i_echo: in std_logic;
		o_pwm, o_pwmX, o_trigger: out std_logic;
		db_medida: out std_logic_vector(15 downto 0);
		db_reset: out std_logic;
		db_proximo: out std_logic;
		db_pwmx: out std_logic;
		db_pwm: out std_logic;
		
		o_display0: out std_logic_vector(6 downto 0); 
		o_display1: out std_logic_vector(6 downto 0); 
		o_display2: out std_logic_vector(6 downto 0)
	);
end entity;

architecture arch_controlador of controlador_comodos_para_filhotes is

	signal s_esta_proximo, s_porta0, s_porta1, s_portaX, s_portaY, s_medir_distancia, s_pwm, s_pronto_HCSR04, s_pwmx: std_logic;
	signal s_medida_distancia_em_BCD: std_logic_vector (15 downto 0);

	
component controlador_comodos_para_filhotes_uc is 
  port 
  ( 	
		i_clock, i_reset: in std_logic;
		i_ligado, i_modo, i_portaX, i_portaY, i_esta_proximo: in std_logic;
		i_pronto_HCSR04: in std_logic;
		o_porta0, o_porta1, o_portaX, o_portaY: out std_logic; -- porta em 0 é aberta em 1 é fechada
		o_medir_distancia: out std_logic;
		db_estado: out std_logic_vector(1 downto 0)
	);	
end component; 
	
component controle_servo is
port (
      i_clock, i_reset: in  std_logic;
      i_posicao : in  std_logic;  
      o_pwm: out std_logic;
		db_reset: out std_logic;
		db_pwm: out std_logic;
		db_posicao: out std_logic
		);
end component; 

component interface_hcsr04 is
	port
	(
		i_clock, i_reset : in std_logic;
		i_medir, i_echo: in std_logic;
		o_trigger, o_pronto: out std_logic;
		o_medida: out std_logic_vector (15 downto 0);
	   db_medir: out std_logic;	
		db_estado: out std_logic_vector (2 downto 0)
	);
end component;

component comparador_menor_30cm is -- usei 30cm como exemplo apenas, a ideia é modificar o componente para o valor exato a ser calculado
    port (
        i_clock, i_reset: in std_logic;
        i_medida: in std_logic_vector (15 downto 0);
        o_entrada_eh_menor_que_30cm: out std_logic
    );
end component;


component hexa7seg is
	port(
		hexa : in std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
	);
end component;


begin

		UC: controlador_comodos_para_filhotes_uc port map (
																	      i_clock, i_reset,
																			i_ligado, i_modo, i_portaX, i_portaY, s_esta_proximo,
																		   s_pronto_HCSR04, 
																			s_porta0, s_porta1, s_portaX, s_portaY,
																			s_medir_distancia,
																			open
																			);

		PORTA0: controle_servo port map (
														 i_clock, i_reset,
														 s_porta0,
														 s_pwm,
														 open,
														 open,
														 open
														 );
														 
		PORTA1: controle_servo port map ( -- essa e as seguintes foram colocadas sem ter uma saida pwm pois por enquanto nao temos servos motores o suficiente
														 i_clock, i_reset,
														 s_porta1,
														 open,
														 open,
														 open,
														 open
														 );	
														 
		PORTAX: controle_servo port map (
														 i_clock, i_reset,
														 s_portaX,
														 s_pwmx,
														 open,
														 open,
														 open
														 );	
														 
		PORTAY: controle_servo port map (
														 i_clock, i_reset,
														 s_portaY,
														 open,
														 open,
														 open,
														 open
														 );
														 
		--HCSR04: interface_hcsr04  port map (
		--												i_clock, i_reset,
		--												s_medir_distancia, i_echo,
		--												o_trigger, s_pronto_HCSR04,
		--												s_medida_distancia_em_BCD,
		--												open,
		--												open
		--											   );
														

		COMPARADOR_MEDIDA: comparador_menor_30cm  port map  (
																			  i_clock, i_reset,
																			  s_medida_distancia_em_BCD,
																			  s_esta_proximo
																		    );		
												
		with i_filhote select 
			s_medida_distancia_em_BCD <= "0001000000000000" when '1', --100cm
												  "0000000000010000" when '0', --0,1 cm
												  "0000000000000000" when others;
														 
		o_porta0 <= s_porta0;
		o_porta1 <= s_porta1;
		o_portaX <= s_portaX;
		o_portaY <= s_portaY;	
		db_reset <= i_reset;
		db_proximo <= s_esta_proximo;
		db_medida <= s_medida_distancia_em_BCD;
		
		db_pwmx <= s_pwmx;
		o_pwmx <= s_pwmx;
		o_pwm <= s_pwm;
		db_pwm <= s_pwm;
		
		HEX0: hexa7seg port map (
										s_medida_distancia_em_BCD(7 downto 4),
										o_display0
										);
										
		HEX1: hexa7seg port map (
										s_medida_distancia_em_BCD(11 downto 8),
										o_display1
										);
		
		HEX2: hexa7seg port map (
										s_medida_distancia_em_BCD(15 downto 12),
										o_display2
										);		

		
end arch_controlador;
