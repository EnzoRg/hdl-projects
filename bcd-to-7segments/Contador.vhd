--En este bloque se reciben las señales P y dir, en base a ellas se realiza la cuenta Up/Down
--La cuenta se muestra en 3 displays de 7 segmentos multiplexados

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;

entity Contador is
port(
	UpDown: in std_logic;
	Clk: in std_logic;
	MuxClk: in std_logic;
	PWMo: out std_logic;
	Salida: out std_logic_vector(0 to 6);
	TR_D, TR_U: out std_logic);
end Contador;

architecture ContUpDown of Contador is

	COMPONENT DECaBCD
	port(
		DEC: in integer;
		BCD: out std_logic_vector(3 downto 0));
	end COMPONENT;
	
	COMPONENT BCDa7
	port(
		entradas: in std_logic_vector(3 downto 0);
		display: out std_logic_vector(0 to 6));
	end COMPONENT;
	
	COMPONENT PWM
	port(
		U: in integer;
		D: in integer;
		Clk: in std_logic;
		PWMsal: out std_logic);
	end COMPONENT;
	
	signal contador: integer range 0 to 1 := 0;
	signal unidad: integer range 0 to 9 := 0;
	signal decena: integer range 0 to 9 := 0;
	signal centena: integer range 0 to 9 := 0;
	signal BCD_U, BCD_D: std_logic_vector(3 downto 0);
	signal display_U, display_D: std_logic_vector(0 to 6);
	signal PWMs: std_logic;
	
begin
	
	--Contador para la multiplexacion de los displays
	clock_Mux: process(MuxClk)
	begin
		if rising_edge(MuxClk) then
			if (contador = 1) then
            contador <= 0;
         else
				contador <= contador+1;
         end if;
      end if;
	end process;
	
	
	--Contador UpDown de 00 a 99
	Contador_UpDown: process(Clk)
	begin
		if Clk'event and Clk='1' then
			if decena<9 and unidad=9 and UpDown='1' then
				unidad <= 0;
				decena <= decena+1;
				
			elsif decena=9 and unidad=9 and UpDown='1' then
				unidad <= 0;
				decena <= 0;
			
			elsif decena>0 and unidad=0 and UpDown='0' then
				unidad <= 9;
				decena <= decena-1;
				
			elsif decena=0 and unidad=0 and UpDown='0' then
				unidad <= 9;
				decena <= 9;
			
			elsif unidad<9 and UpDown='1' then
				unidad <= unidad+1;
			
			elsif unidad>0 and UpDown='0' then
				unidad <= unidad-1;
			end if;
		end if;
	end process;
	
	--Instanciacion de conversores decimal->BCD y BCD->7Segmentos
	Inst_DECaBCD_1: DECaBCD PORT MAP(
		DEC => unidad,
		BCD => BCD_U
	);
	
	Inst_BCDa7_1: BCDa7 PORT MAP(
		entradas => BCD_U,
		display => display_U
	);
	
	Inst_DECaBCD_2: DECaBCD PORT MAP(
		DEC => decena,
		BCD => BCD_D
	);
	
	Inst_BCDa7_2: BCDa7 PORT MAP(
		entradas => BCD_D,
		display => display_D
	);
	
	Inst_PWM: PWM PORT MAP(
		U => unidad,
		D => decena,
		Clk => MuxClk,
		PWMsal => PWMs
	);
	
--Multiplexacion de los Displays
	with contador select
		Salida <= display_U when 0,
					display_D when others;
	
	TR_D <= '0' when contador=1 else '1';
	TR_U <= '0' when contador=0 else '1';
	
	PWMo <= PWMs;

end ContUpDown;