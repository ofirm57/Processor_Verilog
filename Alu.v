module Alu(in, in_from_A, en, out);
input wire  [8:0] in;
input wire  [8:0] in_from_A;
input wire [1:0] en;
output reg [8:0] out;


always @(in_from_A)begin
if(en == 2'b01)
	out <= in + in_from_A;//01 is add
else if(en == 2'b10) ///10 sub
	out <= in_from_A - in ;
else if(en == 2'b11) 
	out <= in[0] + in[1] + in[2] + in[3] + in[4] + in[5] + in[6] + in[7] + in[8] ;
else out <= 9'b000000000;
end
endmodule
