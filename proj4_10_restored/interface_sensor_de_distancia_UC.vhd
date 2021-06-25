library ieee;
use ieee.std_logic_1164.all;

entity interface_sensor_de_distancia_UC is 
  port ( 
			i_clock, i_reset,
			medir, pronto_trigger, pronto_medidor,echo: in std_logic;
         acionar_trigger, medir_echo, fim: out std_logic;
			db_estado: out std_logic_vector(2 downto 0)
		 );
end;

architecture arch of interface_sensor_de_distancia_UC is

    type tipo_estado is (inicial, enviando_trigger, esperando_echo, medindo_echo, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin 

  -- memoria de estado
  process (i_reset, i_clock)
  begin
      if i_reset = '1' then
          Eatual <= inicial;
      elsif i_clock'event and i_clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (medir, pronto_trigger, pronto_medidor, echo, Eatual) 
  begin

    case Eatual is

      when inicial =>      if medir='1' then Eprox <= enviando_trigger;
                           else              Eprox <= inicial;
                           end if;

      when enviando_trigger =>    if pronto_trigger='1' then Eprox <= esperando_echo;
											 else Eprox <= enviando_trigger;
											 end if;

		when esperando_echo => 		if echo = '1' then Eprox <= medindo_echo;
											else Eprox <= esperando_echo;
											end if;										
										
		when medindo_echo => 		   if pronto_medidor='1' then 		Eprox <= final;
												else 						            Eprox <= medindo_echo;
												end if;
												
		when final => 		            if medir='0' then 		Eprox <= inicial;
												else 						   Eprox <= final;
												end if;
									
      when others =>       Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)
  with Eatual select 
      acionar_trigger <= '1' when enviando_trigger, '0' when others;

  with Eatual select
      medir_echo <= '1' when medindo_echo, '0' when others;	
		
  with Eatual select
      fim <= '1' when final, '0' when others;		
	
  with Eatual select
      db_estado <= "000" when inicial,
						 "001" when enviando_trigger,	
						 "011" when medindo_echo,
						 "010" when esperando_echo,
						 "100" when final,
						 "111" when others;	
	

end arch;