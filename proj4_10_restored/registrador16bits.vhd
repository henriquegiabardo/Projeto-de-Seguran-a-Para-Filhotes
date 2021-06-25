library IEEE;
use IEEE.std_logic_1164.all;

entity registrador16bits is
  port ( clock:         in  std_logic;
         clear, enable: in  std_logic;
         D:             in  std_logic_vector (15 downto 0);
         Q:             out std_logic_vector (15 downto 0) 
       );
end registrador16bits;

architecture comportamental of registrador16bits is 
  signal IQ: std_logic_vector (15 downto 0);
begin

  process(clock)
  begin
      if clock'event and clock='1' then
        if clear = '1' then 
          IQ <= (others => '0');
        elsif enable ='1' then 
          IQ <= D;
        else
          IQ <= IQ; -- para evitar inferencia de latches
        end if;
      end if;
  end process;
  
  Q <= IQ;
  
end comportamental;