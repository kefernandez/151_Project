module PC_sum(
    input [31:0] in0, in1,
    input reset,
    output [31:0] out	       
);

   assign out = (reset == 1) ? 32'h2000 : (in0 + in1);
   
endmodule   
