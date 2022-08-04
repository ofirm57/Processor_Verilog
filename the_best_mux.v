module the_best_mux(mux_out, R_out, G_out, DIN_out, G_to_mux, DIN_to_mux,R_I0,R_I1,R_I2,R_I3,R_I4,R_I5,R_I6,R_I7);
			

input wire [8:0] R_I0,R_I1,R_I2,R_I3,R_I4,R_I5,R_I6,R_I7,G_to_mux,DIN_to_mux ;
input wire [7:0] R_out;
input wire  G_out, DIN_out;
output wire [8:0] mux_out;


assign mux_out = DIN_out ? DIN_to_mux: 
					  G_out ? G_to_mux : 
					  (R_out == 8'b00000001) ? R_I0 : 
					  (R_out == 8'b00000010) ? R_I1 : 
					  (R_out == 8'b00000100) ? R_I2 : 
					  (R_out == 8'b00001000) ? R_I3 : 
					  (R_out == 8'b00010000) ? R_I4 : 
					  (R_out == 8'b00100000) ? R_I5 : 
					  (R_out == 8'b01000000) ? R_I6 : 
					  (R_out == 8'b10000000) ? R_I7 :
					  9'b0;
endmodule
										  