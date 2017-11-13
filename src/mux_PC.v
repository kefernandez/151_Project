module mux_PC(
    input clk, reset,
    input [31:0] in0,in1,
    input  sel,	       
    output reg [31:0] out
);

   /*always @ (posedge clk) begin
      if (reset) out <= 32'h2000;
   end*/
   
   always @ (*) begin
      if (reset) out <= 32'h2000;
      else if (sel) out <= in1;
      else out <= in0;
   end
endmodule
