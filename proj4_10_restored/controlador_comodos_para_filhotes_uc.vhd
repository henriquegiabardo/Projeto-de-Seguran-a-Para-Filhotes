library ieee;
use ieee.std_logic_1164.all;

entity controlador_comodos_para_filhotes_uc is 
  port 
  ( 	
		i_clock, i_reset: in std_logic;
		i_ligado, i_modo, i_portaX, i_portaY, i_esta_proximo: in std_logic;
		i_pronto_HCSR04: in std_logic;
		o_porta0, o_porta1, o_portaX, o_portaY: out std_logic; -- porta em 0 é aberta em 1 é fechada
		o_medir_distancia: out std_logic;
		db_estado: out std_logic_vector(1 downto 0)
	);	
end entity;

architecture arch_controlador_uc of controlador_comodos_para_filhotes_uc is
	
	type tipo_estado is (inicial, modo0_porta_aberta, modo0_porta_fechada, modo1);
   signal Eatual: tipo_estado;  -- estado atual
   signal Eprox:  tipo_estado;  -- proximo estado

begin 

	process (i_reset, i_clock)
	begin
		if i_reset = '1' then
          Eatual <= inicial;
      elsif i_clock'event and i_clock = '1' then
          Eatual <= Eprox; 
      end if;
	end process;
	
	process (i_ligado, i_modo, i_esta_proximo, Eatual) 
  begin

    case Eatual is

      when inicial =>      if  i_ligado = '0' then Eprox <= inicial;
                           elsif i_modo = '0' then Eprox <= modo0_porta_aberta;
									else                Eprox <= modo1;
                           end if;
									  
		when modo0_porta_aberta =>       if    i_ligado='0'       then Eprox <= inicial;
													elsif i_modo='1'         then Eprox <= modo1;
													elsif i_esta_proximo='1' then Eprox <= modo0_porta_fechada;
													else 					       Eprox <= modo0_porta_aberta;
													end if;

		when modo0_porta_fechada =>      if    i_ligado='0'       then Eprox <= inicial;
													elsif i_modo='1'         then Eprox <= modo1;
													elsif i_esta_proximo='0' then Eprox <= modo0_porta_aberta;
													else 					        Eprox <= modo0_porta_fechada;	
													end if;
											
		when modo1 =>        if    i_ligado='0' then Eprox <= inicial;
									elsif i_modo = '0' then Eprox <= modo0_porta_aberta;
									else                Eprox <= modo1;
									end if;
									
      when others =>       					Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)
  with Eatual select
      o_porta0 <= '1' when modo0_porta_fechada, '0' when others;
  
  with Eatual select
      o_porta1 <= '1' when modo1, '0' when others;

  with Eatual select
      o_portaX <= i_portaX when modo1, '0' when others;

  with Eatual select
      o_portaY <= i_portaY when modo1, '0' when others;
		
  with Eatual select
      db_estado <= "00" when inicial,
						 "01" when modo0_porta_aberta,	
						 "10" when modo0_porta_fechada,
						 "11" when modo1;
			
	o_medir_distancia <= not i_pronto_HCSR04;
end arch_controlador_uc;