--Divisor de frecuencia

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Clk_div is
port(
	ClkIN: in std_logic;
	ClkOUT: out std_logic);
end Clk_div;

architecture Behavioral of Clk_div is
	signal temporal: std_logic;
	signal contador: integer range 0 to 24999 := 0;
	
begin
	process(ClkIN)
	begin
		if rising_edge(ClkIN) then
			if (contador = 24999) then
				temporal <= NOT(temporal);
            contador <= 0;
         else
				contador <= contador+1;
         end if;
      end if;
	end process;
	
	ClkOUT <= temporal;
	
end Behavioral;