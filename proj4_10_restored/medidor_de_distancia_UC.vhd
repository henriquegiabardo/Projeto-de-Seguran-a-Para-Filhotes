library ieee;
use ieee.std_logic_1164.all;

entity medidor_de_distancia_UC is 
  port ( 
			i_clock, i_reset,
			i_echo: in std_logic;
         o_pronto_medidor: out std_logic;
			db_estado: out std_logic_vector(1 downto 0)
		 );
end;

architecture arch of medidor_de_distancia_UC is

    type tipo_estado is (inicial, medindo, final, esperando);
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
  process (i_echo, Eatual) 
  begin

    case Eatual is

      when inicial =>      if i_echo='1' then Eprox <= medindo;
                           else              Eprox <= inicial;
                           end if;				
										
		when medindo => 		   if i_echo='0' then 		Eprox <= final;
												else 					Eprox <= medindo;
												end if;
												
		when final => 				  Eprox <= esperando;
												
												
		when esperando => 		      if i_echo='1' then 		Eprox <= medindo;
												else 						   Eprox <= esperando;
												end if;
									
      when others =>       Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)
  with Eatual select 
      o_pronto_medidor <= '1' when final, '0' when others;
		
	
  with Eatual select
      db_estado <= "00" when inicial,
						 "01" when medindo,	
						 "10" when final,
						 "11" when esperando,
						 "11" when others;	
	

end arch;