module zero_extend_8bit(
    input [31:0] A       
    output [31:0] Out
);

   assign Out[7:0] = {24'b0,A[7:0]};
   
   
