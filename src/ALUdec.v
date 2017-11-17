// UC Berkeley CS150
// Lab 3, Fall 2014
// Module: ALUdecoder
// Desc:   Sets the ALU operation
// Inputs: opcode: the top 6 bits of the instruction
//         funct: the funct, in the case of r-type instructions
//         add_rshift_type: selects whether an ADD vs SUB, or an SRA vs SRL
// Outputs: ALUop: Selects the ALU's operation
//

`include "Opcode.vh"
`include "ALUop.vh"

module ALUdec(
  input [6:0]       opcode,
  input [2:0]       funct,
  input             add_rshift_type,
  output reg [3:0]  ALUop
);

   always@(opcode or funct or add_rshift_type) begin
    
      
      case(opcode)
	/*7'b1100011: begin //Branches
	   case(funct) 
	     3'b000: ALUop <= 4'b0000; //BEQ ALU checks if rs1 == rs2 
	     3'b001: ALUop <= 4'b0001; //BNE ALU checks if rs1 != rs2
	     3'b100: ALUop <= 4'b0010; //BLT ALU checks if rs1 < rs2 (signed)
	     3'b110: ALUop <= 4'b0011; //BLTU ALU checks if rs1 < rs2 (unsigned)
	     3'b101: ALUop <= 4'b0100; //BGE ALU checks if rs1 > rs2 (signed)
	     3'b111: ALUop <= 4'b0101; //BGEU ALU checks if rs1 > rs2 (unsigned)
	   endcase end */
	
	7'b0000011, 7'b0100011: begin  //For loads LB, LH, LW, LBU, LHU and stores SB, SH, SW
	   ALUop <= 4'b0110; end //ALU does:  rs1 + 32 bit immediate signed extended
   
	7'b0010011: begin //for Logic Immediates 
	   case(funct)
	     3'b000: ALUop <= 4'b0110; //ADDI: ALU adds rs1 + 32 bit sign extended immediate - same as load and store function
	     3'b010: ALUop <= 4'b0010; //SLTI: ALU checks if rs1 < sign extended immediate - use 0010 from branch
	     3'b011: ALUop <= 4'b0011; //SLTIU: same as SLTI but unsigned - use 0011 from branch
	     3'b100: ALUop <= 4'b1000; //XORI bitwise xor of rs1 and immediate
	     3'b110: ALUop <= 4'b1001; //ORI bitwise or of rs1 and immediate
	     3'b111: ALUop <= 4'b1010; //ANDI bitwise and of rs1 and immediate
	     3'b001: ALUop <= 4'b1011; //SLLI shift rs1 logical left by number in lower 5 bits of sign extended immedaite
	     3'b101:begin
		if(add_rshift_type) ALUop <= 1100; //SRAI Arithemetic right shift of rs1 by number of lower 5 bits bits in immediate
		else ALUop <= 1101; //SRLI logical right shift of rs1 by number in lower 5 bits of immediate
	     end
	   endcase // case (funct)
	end
	7'b0110011: begin //for R - types -all operations are done by rs1 and rs
	   case(funct)
	     3'b000: begin
		if(add_rshift_type) ALUop <= 4'b1110; //SUB rs1 - rs2
		else ALUop <= 4'b0110; //ADD rs1 + rs2 - use same as ADD
	     end
	     3'b001: ALUop = 4'b1011; //SLL - use same as SLLI
	     3'b010: ALUop <= 4'b0010; //SLT - use same as SLTI
	     3'b011: ALUop <= 4'b0011; //SLTU - use same as SLTIU
	     3'b100: ALUop <= 4'b1000; //XOR - use same as XORI
	     3'b101: begin
		if(add_rshift_type) ALUop <= 4'b1100 ;//SRA - use same as SRAI
		else ALUop <= 4'b1101; //SRL - Use same as SRLI
	     end
	     3'b110: ALUop <= 4'b1001; //OR - use same as ORI
	     3'b111: ALUop <= 4'b1010; //AND - same as ANDI    
	   endcase // case (funct)
	end // case: 7'b0110011

	//7'b1100111: ALUop <= 4'b0110; //for JALR
	
	7'b0110111: ALUop <= 4'b0111; //for LUI
			     
	default: ALUop <= 4'b1111; //for opcodes 0110111 (LUI), 0010111 (AUIPC), 1101111 (JAL)
      
      endcase // case (opcode)
   end
endmodule
