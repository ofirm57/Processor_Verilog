module proc (DIN, Resetn, Clock, Run, Done, BusWires,R0m, R1m,R2m,R3m,R4m,R5m,R6m,R7m,Tstep_Q, Nstep_Q); 
input wire [8:0] DIN;
input wire Resetn, Clock, Run;
output reg Done;
output wire [8:0] BusWires;
//wire [8:0] IR,R0m,R1m,R2m,R3m,R4m,R5m,R6m,R7m,ALU_in_A,ALU_out;
wire [8:0] IR,ALU_in_A;
wire [8:0] G_mux ,ALU_out;
reg [7:0] R_out;
reg D_out ,G_out;
reg A_in,IRin;
reg [1:0] add_sub ;
output reg [1:0] Tstep_Q, Nstep_Q;/////test
reg G_in;
output wire [8:0]R0m, R1m,R2m,R3m,R4m,R5m,R6m,R7m;
wire [7:0] Xreg,Yreg;
reg [7:0] Rin;
wire [2:0] I;



parameter
T0 = 2'b00,
T1 = 2'b01,
T2 = 2'b10,
T3 = 2'b11, 
 
MV = 3'b000,
MVi= 3'b001,
ADD = 3'b010,
SUB = 3'b011,
ONES= 3'b100;
 


Alu shimon(.in(BusWires), .in_from_A(ALU_in_A), .en(add_sub), .out(ALU_out));

regn R0(.R(BusWires), .Rin(Rin[0]),.Clock(Clock), .Q(R0m));
regn R1(.R(BusWires), .Rin(Rin[1]), .Clock(Clock), .Q(R1m));
regn R2(.R(BusWires), .Rin(Rin[2]), .Clock(Clock), .Q(R2m));
regn R3(.R(BusWires), .Rin(Rin[3]), .Clock(Clock), .Q(R3m));
regn R4(.R(BusWires), .Rin(Rin[4]), .Clock(Clock), .Q(R4m));
regn R5(.R(BusWires), .Rin(Rin[5]), .Clock(Clock), .Q(R5m));
regn R6(.R(BusWires), .Rin(Rin[6]), .Clock(Clock), .Q(R6m));
regn R7(.R(BusWires), .Rin(Rin[7]), .Clock(Clock), .Q(R7m));

regn R_A(.R(BusWires), .Rin(A_in), .Clock(Clock), .Q(ALU_in_A));
regn R_G(.R(ALU_out), .Rin(G_in), .Clock(Clock), .Q(G_mux));
regn IR_R(.R(DIN), .Rin(IRin), .Clock(Clock), .Q(IR));

the_best_mux mux(.mux_out(BusWires), .R_out(R_out), .G_out(G_out), .DIN_out(D_out), .G_to_mux(G_mux), .DIN_to_mux(DIN),.R_I0(R0m),.R_I1(R1m),.R_I2(R2m),.R_I3(R3m),.R_I4(R4m),.R_I5(R5m),.R_I6(R6m),.R_I7(R7m));


assign I = IR[8:6];
dec3to8 decX (IR[5:3], 1'b1, Xreg); ///dec3to8(W, En, Y);
dec3to8 decY (IR[2:0], 1'b1, Yreg);


// Control FSM outputs
always @(posedge Clock or negedge Resetn)/////////////////////////////////////
begin 
if (~Resetn)
	  Tstep_Q <= T0;
else 
	  
	  Tstep_Q <= Nstep_Q;
	  
end



// Control FSM state table
always @( Tstep_Q )begin//or posedge Run or posedge Done) begin
	case (Tstep_Q)
	T0: Nstep_Q = Run ? T1 : T0;
	T1: Nstep_Q = Done ? T0 : T2;
	T2: Nstep_Q = Done ? T0 : T3;///????????????????????????????
	T3: Nstep_Q =  T0 ; 
	default Nstep_Q = T0;
	endcase
// data is loaded into IR in this time step 
//if (!Run) Tstep_D = T0; else Tstep_D = T1; T1: ... endcase
end


	
	
//always @(posedge Clock or negedge Resetn)
always @(Tstep_Q )//or I or Xreg or Yreg)
 begin
//... specify initial values case (Tstep_Q) 
	case(Tstep_Q)
	T0: begin 
	// store DIN in IR in time step 0 begin
			Done <= 1'b0;///////////////////////////////////////////////////
			IRin <= 1'b1;
			Rin <= 7'b0000000;
			G_in <= 1'b0;
			A_in <= 1'b0;
			add_sub <= 2'b00;

			R_out <= 8'b00000000;  ;
			D_out <= 1'b0 ;
			G_out <= 1'b0  ;
		end
		
	T1: begin
		case (I)
				MV:
				begin 
				IRin <= 1'b0;
				G_in <= 1'b0;
				A_in <= 1'b0;
				Rin <= Xreg;

				Done <= 1'b1;
				R_out <= Yreg;  
				D_out <= 1'b0 ;
				G_out <= 1'b0  ;

				end
				
			
            MVi:begin
				IRin <= 1'b0;
				G_in <= 1'b0;
				A_in <= 1'b0;

				R_out <= 8'b00000000;  
				D_out <= 1'b1 ;
				G_out <= 1'b0;
				Rin <= Xreg;
				Done <= 1'b1;
				end
				

																					///{DIN,G_out,Yreg}
				SUB:begin
				IRin <= 1'b0;
				G_in <= 1'b0;
	
				A_in <= 1'b1;
				Done <= 1'b0;
				R_out <= Xreg;  
				D_out <= 1'b0;
				G_out <= 1'b0;
				
				end


				
				ADD:begin
 
					IRin <= 1'b0;
					G_in <= 1'b0;
	
					A_in <= 1'b1;
					Done <= 1'b0;
					R_out <= Xreg;  
					D_out <= 1'b0;
					G_out <= 1'b0;
					end
					
				ONES:begin
 
					IRin <= 1'b0;
					G_in <= 1'b1;
					A_in <= 1'b0;
					Done <= 1'b0;
					R_out <= Xreg;  
					D_out <= 1'b0;
					G_out <= 1'b0;
					add_sub <= 2'b11;
					
 
		end
		endcase
				
		end	
	T2:begin
	
			case (I)
	
				
				SUB:
				begin 
				IRin <= 1'b0;
				R_out <= Yreg;  
				D_out <= 1'b0;
				G_out <= 1'b0;
				add_sub <= 2'b10;
				G_in <= 1'b1;
				end
				
				
				ADD:begin 
				IRin <= 1'b0;
				R_out <= Yreg;  
				D_out <= 1'b0;
				G_out <= 1'b0;
				add_sub <= 2'b01;
				G_in = 1'b1;
				end
				
				ONES:begin
				IRin <= 1'b0;
				G_in <= 1'b0;
				R_out <= 8'b0000000;  
				D_out <= 1'b0;
				G_out <= 1'b1;	
				A_in <= 1'b0;
				Rin <= Yreg;
				Done <= 1'b1;
				end
		
		    endcase
		
				
		end
				
	T3:begin 
				case (I)
				SUB:
				begin 
				G_in <= 1'b0;
				Rin <= Xreg;
				R_out <= 8'b0000000;  
				D_out <= 1'b0;
				G_out <= 1'b1;	
				
				Done <= 1'b1;
				end
				
				
				ADD:begin 
				A_in <= 1'b0;
				G_in <= 1'b0;
				R_out <= 8'b0000000;  
				D_out <= 1'b0;
				G_out <= 1'b1;	
				Rin <= Xreg;
				Done <= 1'b1;
				end
				
				
	      	endcase
	   end
	endcase
end
//
//
//
//
//// Control FSM flip-flops always @(posedge Clock, negedge Resetn) if (!Resetn) ...
////regn reg_0 (BusWires, Rin[0], Clock, R0);
////... instantiate other registers and the adder/subtractor unit
////... define the bus 

endmodule














//
//
//module proc (DIN, Resetn, Clock, Run, Done, BusWires,en_mux,Rin ,I, Tstep_Q, Nstep_Q,R1m,R2m,R3m,R4m,R5m,R6m,R7m); 
//input wire [8:0] DIN;
//input wire Resetn, Clock, Run;
//output reg Done;
//output wire [8:0] BusWires;/////otpt wire?
////wire [8:0] IR,R0m,R1m,R2m,R3m,R4m,R5m,R6m,R7m,ALU_in_A,ALU_out;
//wire [8:0] IR,ALU_in_A,ALU_out;
//wire [8:0] G_mux;
//output reg [9:0] en_mux;
//reg G_in,A_in,add_sub;
//reg IRin;
//output reg [1:0] Tstep_Q, Nstep_Q;
////reg [1:0] Nstep_Q;
//output wire [7:0] R1m,R2m,R3m,R4m,R5m,R6m,R7m;
//wire [7:0] Xreg,Yreg;
//output reg [7:0] Rin;
//output wire [2:0] I;
//parameter
//T0 = 2'b00,
//T1 = 2'b01,
//T2 = 2'b10,
//T3 = 2'b11, 
// 
//MV = 3'b000,
//MVi= 3'b001,
//ADD = 3'b010,
//SUB = 3'b011,
//ONES= 3'b011;
// 
//
//
//
//Alu shimon(.in(BusWires), .in_from_A(ALU_in_A), .en(add_sub), .out(ALU_out));
//
//regn R0(BusWires, Rin[0], Clock, R0m);
//regn R1(.R(BusWires), .Rin(Rin[1]), .Clock(Clock), .Q(R1m));
//regn R2(.R(BusWires), .Rin(Rin[2]), .Clock(Clock), .Q(R2m));
//regn R3(.R(BusWires), .Rin(Rin[3]), .Clock(Clock), .Q(R3m));
//regn R4(.R(BusWires), .Rin(Rin[4]), .Clock(Clock), .Q(R4m));
//regn R5(.R(BusWires), .Rin(Rin[5]), .Clock(Clock), .Q(R5m));
//regn R6(.R(BusWires), .Rin(Rin[6]), .Clock(Clock), .Q(R6m));
//regn R7(.R(BusWires), .Rin(Rin[7]), .Clock(Clock), .Q(R7m));
//
//regn R_A(.R(BusWires), .Rin(A_in), .Clock(Clock), .Q(ALU_in_A));
//regn R_G(.R(ALU_out), .Rin(G_in), .Clock(Clock), .Q(G_mux));
//regn IR_R(.R(DIN), .Rin(IRin), .Clock(Clock), .Q(IR));
//
//mux ofir(.mux_out(BusWires),.G_in(g_mux),.en(en_mux),.Din(DIN),.R_I0(R0m),.R_I1(R1m),.R_I2(R2m),.R_I3(R3m),.R_I4(R4m),.R_I5(R5m),.R_I6(R6m),.R_I7(R7m));  // (mux_out,G_in,en,Din,R_I0,R_I1,R_I2,R_I3,R_I4,R_I5,R_I6,R_I7);
//
//
//
//assign I = IR[8:6];
//dec3to8 decX (IR[5:3], 1'b1, Xreg); ///dec3to8(W, En, Y);
//dec3to8 decY (IR[2:0], 1'b1, Yreg);
//
//
//// Control FSM outputs
//always @(posedge Clock or negedge Resetn)/////////////////////////////////////
//begin 
//if (~Resetn)
//	  Tstep_Q <= T0;
//else 
//	  
//	  Tstep_Q <= Nstep_Q;
//	  
//end
//
//
//
//// Control FSM state table
//always @( Tstep_Q )begin//or posedge Run or posedge Done) begin
//	case (Tstep_Q)
//	T0: Nstep_Q = Run ? T1 : T0;
//	T1: Nstep_Q = Done ? T0 : T2;
//	T2: Nstep_Q = T3;///????????????????????????????
//	T3: Nstep_Q =  T0 ; 
//	default Nstep_Q = T0;
//	endcase
//// data is loaded into IR in this time step 
////if (!Run) Tstep_D = T0; else Tstep_D = T1; T1: ... endcase
//end
//
//
//	
//	
////always @(posedge Clock or negedge Resetn)
//always @(Tstep_Q )//or I or Xreg or Yreg)
// begin
////... specify initial values case (Tstep_Q) 
//	case(Tstep_Q)
//	T0: begin 
//	// store DIN in IR in time step 0 begin
//			Done <= 1'b0;///////////////////////////////////////////////////
//			IRin <= 1'b1;
//			Rin <= 7'b0000000;
//			
//		end
//		
//	T1: begin
//		case (I)
//				MV:
//				begin 
//				IRin <= 1'b0;
//				G_in <= 1'b0;
//				A_in <= 1'b0;
//				Rin <= Xreg;
//				en_mux = {Yreg,1'b0,1'b0};/////////////
//				Done <= 1'b1;
//
//				end
//				
//			
//            MVi:begin
//				IRin <= 1'b0;
//				G_in <= 1'b0;
//				A_in <= 1'b0;
//				en_mux = 10'b000000001;
//				Rin <= Xreg;
//				Done <= 1'b1;
//				end
//				
//
//																					///{DIN,G_out,Yreg}
//				SUB:begin
//				IRin <= 1'b0;
//				G_in <= 1'b0;
//				en_mux = {Xreg,1'b0,1'b0};/////////////	
//				A_in <= 1'b1;
//				Done <= 1'b0;
//				end
//
//
//				ADD:begin
// 
//					IRin <= 1'b0;
//					G_in <= 1'b0;
//					en_mux = {Xreg,1'b0,1'b0};/////////////	
//					A_in <= 1'b1;
//					Done <= 1'b0;
// 
//		end
//		endcase
//				
//		end	
//	T2:begin
//	
//			case (I)
//	
//				
//				SUB:
//				begin 
//				IRin <= 1'b0;
//				en_mux = {Yreg,1'b0,1'b0};
//				add_sub <= 1'b0;
//				G_in <= 1'b1;
//				end
//				
//				
//				ADD:begin 
//				IRin <= 1'b0;
//				en_mux = {Yreg,1'b0,1'b0};
//				add_sub <= 1'b1;
//				G_in = 1'b1;
//				end
//		
//		    endcase
//		
//				
//		end
//				
//	T3:begin 
//				case (I)
//				SUB:
//				begin 
//				G_in <= 1'b0;
//				Rin <= Xreg;
//				en_mux = 10'b0100000000;
//				Done <= 1'b1;
//				end
//				
//				
//				ADD:begin 
//				G_in <= 1'b0;
//				en_mux = 10'b0100000000;
//				Rin <= Xreg;
//				Done <= 1'b1;
//				end
//			 
//		
//	      	endcase
//	   end
//	endcase
//end
////
////
////
////
////// Control FSM flip-flops always @(posedge Clock, negedge Resetn) if (!Resetn) ...
//////regn reg_0 (BusWires, Rin[0], Clock, R0);
//////... instantiate other registers and the adder/subtractor unit
//////... define the bus 
//
//endmodule

