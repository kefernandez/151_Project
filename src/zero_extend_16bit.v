module zero_extend_16bit(
    input [31:0] A       
    output [31:0] Out
);

   assign Out[7:0] = {12'b0,A[11:0]};
