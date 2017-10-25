// UC Berkeley CS150
// Lab 3, Fall 2014
// Module: ALU.v
// Desc:   32-bit ALU for the MIPS150 Processor
// Inputs: 
//    A: 32-bit value
//    B: 32-bit value
//    ALUop: Selects the ALU's operation 
// 						
// Outputs:
//    Out: The chosen function mapped to A and B.

`include "Opcode.vh"
`include "ALUop.vh"

module ALU(
    input [31:0] A,B,
    input [3:0] ALUop,
    output reg [31:0] Out
);
   wire [4:0] shift_amt; 
   wire signed [31:0] A_signed = A;
   wire signed [31:0] B_signed = B;
   reg i;
   
   assign shift_amt = B[4:0];
   
   always@(A or B or ALUop) begin
      case(ALUop)
	4'b0000:begin  //checks if A = B
	   if(A==B) Out <= 32'd1;
	   else Out <= 32'd0;
	end
	4'b0001: begin //Checks if A != B
	   if(A==B) Out <= 32'd0;
	   else Out <= 32'd1;
	end
	4'b0010:begin //Checks if A < B (signed) 
	   if (A_signed < B_signed) Out <= 32'd1;
	   else Out <= 32'd0;
	end
	4'b0011:begin //Checks if A < B (unsigned)
	   if (A < B) Out <= 32'd1;
	   else Out <= 32'd0;
	end
	4'b0100:begin //Checks if A > B (signed) 
	   if (A_signed > B_signed) Out <= 32'd1;
	   else Out <= 32'd0;
	end
	4'b0101:begin //Checks if A > B (unsigned)
	   if (A > B) Out <= 32'd1;
	   else Out <= 32'd0;
	end
	4'b0110: Out <= A + B; //Adds A + B
	4'b0111: Out <=  B; //for LUI
	4'b1000: Out <= A ^ B; //bitwise XOR A B
	4'b1001: Out <= A | B; //bitwise OR A B
	4'b1010: Out <= A & B; //bitwise And of A B
	4'b1011: begin //Logical left shift of A
	   Out <= (A << shift_amt);
	   i <= 1;end
	4'b1100: Out <= A >>> shift_amt; //Arithmetic right shift of A
	4'b1101: Out <= A >> shift_amt; //logical right shift of A
	4'b1110: Out <= A - B; //Subtraction of A and B
	4'b1111: Out <= A+B; //When ALU is not needed
      endcase
   end 

    // Implement your ALU here, then delete this comment

endmodule
