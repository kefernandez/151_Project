module mux_PC(
    //input clk 
    //input reset,
    input [31:0] in0,in1,
    input  sel,	       
    output reg [31:0] out
);

   /*always @ (posedge clk) begin
      if (reset) out <= 32'h2000;
   end*/
   
   //always @ (posedge clk) begin
   always @ (*) begin
      //if (reset) out <= (32'h2000 - 4);
      if (sel) out <= in1;
      else out <= in0;
   end
endmodule
