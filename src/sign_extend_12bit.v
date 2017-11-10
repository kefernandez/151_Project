module ALU(
    input [11:0] A,
    output [31:0] Out
);

   assign Out = {21{A[31]}, A[30:20]};

endmodule
