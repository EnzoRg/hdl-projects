library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity P1b is
port(
	A, B, Reset: in std_logic;
	Clk: in std_logic;
	PWMout: out std_logic;
	Display: out std_logic_vector(0 to 6);
	TR: out std_logic_vector(1 downto 0));
end P1b;

architecture ControlMotor of P1b is
	COMPONENT Decod 
	port(
		A, B, Clk, reset: in std_logic;
		P, dir: out std_logic);
	end COMPONENT; 
	
	COMPONENT Contador
	port(
		UpDown: in std_logic;
		Clk: in std_logic;
		MuxClk: in std_logic;
		PWMo: out std_logic;
		Salida: out std_logic_vector(0 to 6);
		TR_D, TR_U: out std_logic);
	end COMPONENT;
	
	COMPONENT Clk_div 
	port(
		ClkIN: in std_logic;
		ClkOUT: out std_logic);
	end COMPONENT;
	
	signal ClkMUX: std_logic;
	signal Pulsos, direccion: std_logic;
	signal TR1, TR0: std_logic;
	signal DisplayS: std_logic_vector(0 to 6);
	signal PWMs: std_logic;
	
begin	
	Inst_Clk_div: Clk_div PORT MAP(
		ClkIN => Clk,
		ClkOUT => ClkMUX
	);
	
	Inst_Decod: Decod PORT MAP(
		A => A,
		B => B,
		Clk => Clk,
		reset => not Reset,
		P => Pulsos,
		dir => direccion
	);
	
	Inst_Contador: Contador PORT MAP(
		UpDown => direccion,
		Clk => Pulsos,
		MuxClk => ClkMUX,
		PWMo => PWMs,
		Salida => DisplayS,
		TR_D => TR1,
		TR_U => TR0
	);
	
	Display <= DisplayS;
	TR(1) <= TR1;
	TR(0) <= TR0;
	
	PWMout <= not PWMs;
	
end ControlMotor;