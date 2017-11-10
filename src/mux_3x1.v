
module mux_3x1(
    input [31:0] In0,In1,In2,
    input [1:0] sel,	       
    output reg [31:0] Out
);

   always@(*)begin
      if(sel == 2'b00) Out <= In0;
      else if (sel == 2'b01) Out <= In1;
      else Out <= In2;
   end
endmodule
