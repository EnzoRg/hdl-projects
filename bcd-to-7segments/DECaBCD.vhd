--Conversor decimal a BCD

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;

entity DECaBCD is
port(
	DEC: in integer;
	BCD: out std_logic_vector(3 downto 0));
end DECaBCD;

architecture Conversor of DECaBCD is
	
begin
	with DEC select
		BCD <= "0000" when 0,
				"0001" when 1,
				"0010" when 2,
				"0011" when 3,
				"0100" when 4,
				"0101" when 5,
				"0110" when 6,
				"0111" when 7,
				"1000" when 8,
				"1001" when 9,
				"1111" when others;
	
end Conversor;
