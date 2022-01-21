--Conversor BCD a 7 segmentos

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity BCDa7 is
port(
	entradas: in std_logic_vector(3 downto 0);
	display: out std_logic_vector(0 to 6));
end BCDa7;

architecture Behavioral of BCDa7 is
begin
	process(entradas)
	begin
		case entradas is
			when "0000" => display <= "0000001";
			when "0001" => display <= "1001111";
			when "0010" => display <= "0010010";
			when "0011" => display <= "0000110";
			when "0100" => display <= "1001100";
			when "0101" => display <= "0100100";
			when "0110" => display <= "0100000";
			when "0111" => display <= "0001111";
			when "1000" => display <= "0000000";
			when "1001" => display <= "0000100";
			when others => display <= "0110000";
		end case;
	end process;
	
end Behavioral;