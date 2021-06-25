-- contador_bcd_4digitos.vhd
--
-- contador bcd com 4 digitos (modulo 10.000)
-- (descricao VHDL comportamental)
-- LabDig - v1.2 - 26/09/2020

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_bcd_4digitos is 
    port ( clock, zera, conta:     in  std_logic;
           dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
           fim:                    out std_logic
    );
end contador_bcd_4digitos;


architecture comportamental of contador_bcd_4digitos is

    signal s_dig3, s_dig2, s_dig1, s_dig0 : integer range 0 to 9;

begin

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (zera = '1') then  -- reset sincrono
                s_dig0 <= 0;
                s_dig1 <= 0;
                s_dig2 <= 0;
                s_dig3 <= 0;
            elsif ( conta = '1' ) then
                if (s_dig0 = 9) then
                    s_dig0 <= 0;
                    if (s_dig1 = 9) then
                        s_dig1 <= 0;
                        if (s_dig2 = 9) then
                            s_dig2 <= 0;
                            if (s_dig3 = 9) then
                                s_dig3 <= 0;
                            else
                                s_dig3 <= s_dig3 + 1;
                            end if;
                        else
                            s_dig2 <= s_dig2 + 1;
                        end if;
                    else
                        s_dig1 <= s_dig1 + 1;
                    end if;
                else
                    s_dig0 <= s_dig0 + 1;
                end if;
            end if;
        end if;
    end process;

    -- fim de contagem (comando VHDL when else)
    fim <= '1' when s_dig3=9 and s_dig2=9 and 
                    s_dig1=9 and s_dig0=9 else 
           '0';

    -- saidas
    dig3 <= std_logic_vector(to_unsigned(s_dig3, dig3'length));
    dig2 <= std_logic_vector(to_unsigned(s_dig2, dig2'length));
    dig1 <= std_logic_vector(to_unsigned(s_dig1, dig1'length));
    dig0 <= std_logic_vector(to_unsigned(s_dig0, dig0'length));

end comportamental;
