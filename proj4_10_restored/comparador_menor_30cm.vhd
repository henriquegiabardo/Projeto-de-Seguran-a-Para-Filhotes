library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador_menor_30cm is
    port (
        i_clock, i_reset: in std_logic;
        i_medida: in std_logic_vector (15 downto 0);
        o_entrada_eh_menor_que_30cm: out std_logic
    );
end comparador_menor_30cm;

architecture arch_comparador_menor_30cm of comparador_menor_30cm is

  signal s_medida0, s_medida1, s_medida2: integer range 0 to 9;
  signal s_0, s_3: integer range 0 to 9; -- 30 em BCD é 0000 0000 0011 0000
  signal s_entrada_eh_maior_que_30cm: std_logic;

 begin
 
	s_0 <= 0;
	s_3 <= 3;
	
	s_medida0 <= to_integer(unsigned(i_medida(7 downto 4)));
	s_medida1 <= to_integer(unsigned(i_medida(11 downto 8)));
	s_medida2 <= to_integer(unsigned(i_medida(15 downto 12)));
	
  
	process (i_clock, i_reset, s_medida0, s_medida1, s_medida2, s_0, s_3)
	begin
		
		if s_0 < s_medida2 then s_entrada_eh_maior_que_30cm <= '1';
		elsif s_3 < s_medida1 then s_entrada_eh_maior_que_30cm <= '1';
		elsif s_0 < s_medida0 and s_3 = s_medida1 then s_entrada_eh_maior_que_30cm <= '1';
		elsif s_medida0 = s_0 and s_medida1 = s_0 and s_medida2 = s_0 then s_entrada_eh_maior_que_30cm <= '1';
		else s_entrada_eh_maior_que_30cm <= '0';
		end if;

	end process;

	
	o_entrada_eh_menor_que_30cm <= not s_entrada_eh_maior_que_30cm;
	
	
end arch_comparador_menor_30cm;