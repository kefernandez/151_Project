module mux_2x1(
    input [31:0] in0,in1,
    input  sel,	       
    output reg [31:0] out
);

   always@(*)begin
      if(sel) out <= in1;
      else out <= in0;
   end
endmodule
