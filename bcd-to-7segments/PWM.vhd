--Generador PWM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;

entity PWM is
port(
	U: in integer;
	D: in integer;
	Clk: in std_logic;
	PWMsal: out std_logic);
end PWM;

architecture Generador_PWM of PWM is
	signal cuenta: integer range 0 to 99;
	signal contador: integer range 0 to 99;
	
begin
	cuenta <= (10 * D) + U;
	
	process (Clk)
	begin
		if rising_edge(Clk) then
			if (contador = 99) then
            contador <= 0;
         else
				contador <= contador+1;
         end if;
			if (contador <= cuenta) then
				PWMsal <= '1';
			else
				PWMsal <= '0';
			end if;
      end if;
	end process;
	
end Generador_PWM;