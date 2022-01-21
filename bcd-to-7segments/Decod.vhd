--En este bloque se realiza la decodificacion de las señales A y B provenientes del encoder
--A partir de la relación entre los pulsos de estas dos entradas se obtiene
--La salida "P" que envia un pulso cada vez que se detecta un flanco de subida o bajada en A o B
--La salida "dir" indica sentido de giro horario(1) o antihorario(0)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;

entity Decod is
port(
	A, B, Clk, reset: in std_logic;
	P, dir: out std_logic);
end Decod; 

architecture Generador of Decod is
	signal Q1Ap, Q2Ap, Q3Ap, Q1An, Q2An, Q3An, 
			Q1Bp, Q2Bp, Q3Bp, Q1Bn, Q2Bn, Q3Bn : std_logic;
	signal QAp_OUT, QAn_OUT, QBp_OUT, QBn_OUT : std_logic;
	type state_type is (st0, st1, st2, st3); 
   signal state, next_state: state_type;
	signal prev_state: state_type := st0;
	signal AB: std_logic_vector(3 downto 0) := QAp_OUT & QAn_OUT & QBp_OUT & QBn_OUT;
			
begin
	SYNC_PROC: process (Clk) --Sincronización de la maquina de estado con el Clock
   begin
      if (Clk'event and Clk = '1') then
         if (reset = '1') then	--Reset lleva la maquina al Estado 0
            state <= st0;
         else
            state <= next_state;
				case (state) is
					when st0 =>
						if prev_state = st3 then
							dir <= '1';
						elsif prev_state = st1 then
							dir <= '0';
						end if;
						prev_state <= st0;
					when st1 =>
						if prev_state = st0 then
							dir <= '1';
						elsif prev_state = st2 then
							dir <= '0';
						end if;
						prev_state <= st1;
					when st2 =>
						if prev_state = st1 then
							dir <= '1';
						elsif prev_state = st3 then
							dir <= '0';
						end if;
						prev_state <= st2;
					when st3 =>
						if prev_state = st2 then
							dir <= '1';
						elsif prev_state = st0 then
							dir <= '0';
						end if;
						prev_state <= st3;
					when others =>
						prev_state <= st0;
				end case;
         end if;        
      end if;
   end process;

 
   NEXT_STATE_DECODE: process (state, AB) --codificacion del estado siguiente
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      case (state) is
         when st0 =>
            if AB = "1000" then
               next_state <= st1;
				elsif AB = "0010" then
					next_state <= st3;
            end if;
         when st1 =>
            if AB = "0010" then
               next_state <= st2;
				elsif AB = "0100" then
					next_state <= st0;
            end if;
         when st2 =>
            if AB = "0100" then
               next_state <= st3;
				elsif AB = "0001" then
					next_state <= st1;
            end if;
			when st3 =>
            if AB = "0001" then
               next_state <= st0;
				elsif AB = "1000" then
					next_state <= st2;
            end if;
         when others =>
            next_state <= st0;
      end case;      
   end process;
	
	
-- Descripción de 4 circuitos anti rebote 2 para A y 2 para B
-- El primero detecta flancos positivos en A y el segundo los negativos, lo mismo para B
--Las negaciones en las entradas y las salidas se debe a la logica negada de la FPGA
	FLANCOS_A_POS:process(Clk)
	begin
		if (Clk'event and Clk = '1') then
				Q1Ap <= not A;
				Q2Ap <= Q1Ap;
				Q3Ap <= Q2Ap;
		end if;
	end process;
	QAp_OUT <= Q1Ap and Q2Ap and (not Q3Ap);
	
	FLANCOS_A_NEG:process(Clk)
	begin
		if (Clk'event and Clk = '1') then
				Q1An <= not A;
				Q2An <= Q1An;
				Q3An <= Q2An;
		end if;
	end process;
	QAn_OUT <= (not Q1An) and (not Q2An) and Q3An;
	
	FLANCOS_B_POS:process(Clk)
	begin
		if (Clk'event and Clk = '1') then
				Q1Bp <= not B;
				Q2Bp <= Q1Bp;
				Q3Bp <= Q2Bp;
		end if;
	end process;
	QBp_OUT <= Q1Bp and Q2Bp and (not Q3Bp);
	
	FLANCOS_B_NEG:process(Clk)
	begin
		if (Clk'event and Clk = '1') then
				Q1Bn <= not B;
				Q2Bn <= Q1Bn;
				Q3Bn <= Q2Bn;
		end if;
	end process;
	QBn_OUT <= (not Q1Bn) and (not Q2Bn) and Q3Bn;
	
	P <= not ((not QAp_OUT) and (not QAn_OUT) and (not QBp_OUT) and (not QBn_OUT));
	
end Generador;