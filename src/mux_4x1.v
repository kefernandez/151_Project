module mux_4x1(
    input [31:0] A,B,C,D
    input [1:0] sel,	       
    output reg [31:0] Out
);

   always@(*)begin
      if(sel == 2'b00) Out <= A;
      else if (sel == 2'b01) Out <= B;
      else if (sel ==2'b10) Out <= C;
      else Out <= D;
   end
