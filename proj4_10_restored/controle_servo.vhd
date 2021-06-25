library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
port (
      i_clock, i_reset: in  std_logic;
      i_posicao : in  std_logic;  
      o_pwm: out std_logic;
		db_reset: out std_logic;
		db_pwm: out std_logic;
		db_posicao: out std_logic
		);
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 4KHz 
                                      
  signal s_contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(i_clock,i_reset,i_posicao, s_posicao)
  begin
    -- inicia contagem e largura
    if(i_reset='1') then
      s_contagem    <= 0;
      o_pwm         <= '0';
		db_pwm 		  <= '0';
      s_largura_pwm <= s_posicao;
    elsif(rising_edge(i_clock)) then
        -- saida
        if(s_contagem < s_largura_pwm) then
          o_pwm  <= '1';
			 db_pwm <= '1';
        else
          o_pwm  <= '0';
			 db_pwm <= '0';
        end if;
        -- atualiza contagem e largura
        if(s_contagem = CONTAGEM_MAXIMA-1) then
          s_contagem   <= 0;
          s_largura_pwm <= s_posicao;
        else
          s_contagem   <= s_contagem + 1;
        end if;
    end if;
  end process;

  process(i_posicao)
  begin
    case i_posicao is
--      when "001" =>    s_largura <=    50000;  -- pulso de 1   ms
--      when "010" =>    s_largura <=    60000;  -- pulso de 1,2 ms
--      when "011" =>    s_largura <=    70000;  -- pulso de 1,4 ms
--		  when "101" =>    s_largura <=    80000;  -- pulso de 1,6 ms
--      when "110" =>    s_largura <=    90000;  -- pulso de 1,8 ms
--      when "111" =>    s_largura <=   100000;  -- pulso de 2   ms
     
	   when '1' =>    s_posicao <=    50000;  -- pulso de 1   ms 30° ? nao lembro valor exato 
		when '0' =>    s_posicao <=    100000;  -- pulso de 1   ms 30° ? nao lembro valor exato 
      when others =>  s_posicao <=        0;  -- nulo   saida 0
    end case;
  end process;
  
	db_reset <= i_reset;
	db_posicao <= i_posicao;
  
end rtl;