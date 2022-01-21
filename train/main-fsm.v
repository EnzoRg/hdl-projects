`timescale 1ns / 1ps

module fsm(

input clk, s1, s2, s3, s4, s5, reset, p, d, g, // p =1 avance, p=0 parado; d = 0 antihorario, d=1 horario;
output reg sw1, sw2, sw3, ta0, ta1, tb0, tb1,

output reg [3:0] anodos,
output reg [6:0] led

);

parameter frecuencia = 1000000;
parameter freq_out = 5000;
parameter max_count = frecuencia/(2 * freq_out);

reg [3:0] estado;

reg [10:0] count;
reg clk_out;
reg [1:0] sel;

initial begin
	count = 0;
	clk_out = 0;
	sel = 0;
	estado = 0;
	led = 0;
	anodos = 0;
end

parameter e0=0, e1=1, e2=2, e3=3, e4=4, e5=5, e6=6, e7=7, e8=8, e9=9, e10=10, e11=11;

always @ (estado)
     begin
          case (estado)
               e0:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1100000;
               e1:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1100010;
               e2:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b0001010;
               e3:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b0001000;
               e4:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1101010;
               e5:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1110100;
               e6:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1110001;
               e7:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1111000;
               e8:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1100101;
               e9:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1100100;
               e10:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b0000100;
               e11:
                  {sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1100001;
					default:
						{sw1, sw2, sw3, ta0, ta1, tb0, tb1} = 7'b1100000;
          endcase
     end

always @(posedge clk, negedge reset)
begin
	if (reset == 0)
		estado <= e0;
	else
	begin
		case (estado)

		e0:
			if (d == 0 && p == 1) //Antihorario
				estado <= e1;
			else if (d == 1 && p == 1 && g == 0) //Horario
				estado <= e8;
			else if (d == 1 && p == 1 && g == 1) //Guardar
				estado <= e5;
			else
				estado <= e0;
		e1:
			if (s3 == 1 && p == 1)
				estado <= e2;
			else if (s2 == 1 && p == 1)
				estado <= e3;
			else if (s2 == 1 && p == 0)
				estado <= e0;
			else
				estado <= e1;
		e2:
			if (s2 == 1)
				estado <= e3;
			else
				estado <= e2;
		e3:
			if (s4 == 1)
				estado <= e4;
			else
				estado <= e3;
		e4:
			if (s1 == 1)
				estado <= e1;
			else
				estado <= e4;
		e5:
			if (s5 == 1)
				estado <= e6;
			else
				estado <= e5;
		e6:
			if (g == 0 && s2 == 1)
				estado <= e7;
			else
				estado <= e6; // g == 1
		e7:
			if (s1 == 1 && d == 0 && p == 1)
				estado <= e1;
			else if (s1 == 1 && p == 0)
				estado <= e0;
			else if (s1 == 1 && d == 1 && p == 1)
				estado <= e8;
			else
				estado <= e7;
		e8:
			if (s3 == 1)
				estado <= e9;
			else
				estado <= e8;
		e9:
			if (s4 == 1)
				estado <= e10;
			else
				estado <= e9;
		e10:
			if (s1 == 1)
				estado <= e11;
			else
				estado <= e10;
		e11:
			if (s2 == 1 && p == 1)
				estado <= e8;
			else if (s2 == 1 && p == 0)
				estado <= e0;
			else
				estado <= e11;
		endcase
		end
end

always @ (posedge clk) //divisior de frecuencia
begin
	if (count == max_count)
		begin
			clk_out = ~clk_out;
			count = 0;
		end
		else
			count = count + 1;
end

always @ (posedge clk_out) //
begin
	if (sel == 1)
		sel <= 0;
	else
		sel <= sel + 1;
end

always @(posedge clk_out) //conmuta transistores
	case (sel)
		2'b00 : anodos <= 4'b1110;
		2'b01 : anodos <= 4'b1101;
	endcase


always @(*)
	begin
		case({estado, sel})
		6'b0000_00: led <= 7'b1001111; //trenA s1
		6'b0000_01: led <= 7'b0010010; //trenB s2

		6'b0001_00: led <= 7'b1001111; //trenA s1
		6'b0001_01: led <= 7'b1100000; //trenB mov

		6'b0010_00: led <= 7'b0001000; //trenA mov
		6'b0010_01: led <= 7'b1100000; //trenB mov

		6'b0011_00: led <= 7'b0001000; //trenA mov
		6'b0011_01: led <= 7'b0010010; //trenB s2

		6'b0100_00: led <= 7'b0001000; //trenA mov
		6'b0100_01: led <= 7'b1100000; //trenB mov

		6'b0101_00: led <= 7'b0001000; //trenA mov
		6'b0101_01: led <= 7'b0010010; //trenB s2

		6'b0110_00: led <= 7'b0100100; //trenA s5
		6'b0110_01: led <= 7'b1100000; //trenB mov

		6'b0111_00: led <= 7'b0001000; //trenA mov
		6'b0111_01: led <= 7'b0010010; //trenB s2

		6'b1000_00: led <= 7'b0001000; //trenA mov
		6'b1000_01: led <= 7'b1100000; //trenB mov

		6'b1001_00: led <= 7'b0001000; //trenA mov
		6'b1001_01: led <= 7'b0000110; //trenB s3

		6'b1010_00: led <= 7'b0001000; //trenA mov
		6'b1010_01: led <= 7'b0000110; //trenB s3

		6'b1011_00: led <= 7'b1001111; //trenA s1
		6'b1011_01: led <= 7'b1100000; //trenB mov
		default: led <= 7'b1111111;

	endcase 
	end 
endmodule 
