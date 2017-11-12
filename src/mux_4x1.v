module mux_4x1(
<<<<<<< HEAD
    input [31:0] in0,in1,in2,in3,
=======
    input [31:0] A,B,C,D,
>>>>>>> ed219fe4d149f74b959bc77c473e1a0c68119036
    input [1:0] sel,	       
    output reg [31:0] Out
);

   always@(*)begin
      if(sel == 2'b00) Out <= in0;
      else if (sel == 2'b01) Out <= in1;
      else if (sel ==2'b10) Out <= in2;
      else Out <= in3;
   end
endmodule
