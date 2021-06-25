library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity medidor_de_distancia is
	port(
		i_clock, i_reset : in std_logic;
		i_zera: in std_logic;
		i_echo: in std_logic;
		o_pronto: out std_logic;
		o_medida: out std_logic_vector (15 downto 0)	
	);
end entity;

architecture arch_medidor_de_distancia of medidor_de_distancia is

	signal s_tick, s_pronto_medidor, s_zera: std_logic;
	signal s_medida: std_logic_vector(15 downto 0);

component contador_bcd_4digitos is 
    port ( clock, zera, conta:     in  std_logic;
           dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
           fim:                    out std_logic
    );
end component;

component registrador16bits is
  port ( clock:         in  std_logic;
         clear, enable: in  std_logic;
         D:             in  std_logic_vector (15 downto 0);
         Q:             out std_logic_vector (15 downto 0) 
       );
end component;

component contador_m is
    generic (
        constant M: integer;  -- modulo do contador
        constant N: integer    -- numero de bits da saida
    );
    port (
        clock, zera, conta: in std_logic;
        Q: out std_logic_vector (N-1 downto 0);
        fim: out std_logic
    );
end component;

component medidor_de_distancia_UC is 
  port ( 
			i_clock, i_reset,
			i_echo: in std_logic;
         o_pronto_medidor: out std_logic;
			db_estado: out std_logic_vector(1 downto 0)
		 );
end component;

begin

		s_zera <= i_reset or i_zera;

		TICK: contador_m generic map (M => 294, N => 9) port map(
																i_clock, s_zera, i_echo, 
																open,
																s_tick
																);
																
		BCD: contador_bcd_4digitos port map (
														i_clock, s_zera, s_tick,
														s_medida(15 downto 12), s_medida(11 downto 8), s_medida(7 downto 4), s_medida(3 downto 0),
														open
														);
														
		REGISTRADOR: registrador16bits port map(
															i_clock,
															i_reset, s_pronto_medidor,
															s_medida,
															o_medida
															);
															
	   UC: medidor_de_distancia_UC port map(
														i_clock, i_reset,
														i_echo,
														s_pronto_medidor,
														open
														);
		
																	
		o_pronto <= s_pronto_medidor;									
										   
end arch_medidor_de_distancia;