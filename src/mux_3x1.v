
module mux_3x1(
    input [31:0] A,B,C,
    input [1:0] sel,	       
    output reg [31:0] Out
);

   always@(*)begin
      if(sel == 2'b00) Out <= A;
      else if (sel == 2'b01) Out <= B;
      else Out <= C;
   end
