

module mux_2x1(
    input [31:0] A,B,
    input sel,	       
    output reg [31:0] Out
);

   always@(*)begin
      if(sel) Out <= B;
      else Out <= A;
   end
