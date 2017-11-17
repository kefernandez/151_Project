module comparator_sum(
    input [31:0] rs1,rs2,
    input [6:0] opcode,	
    input [2:0] funct,		      
    output reg [31:0] out
);
   wire signed [31:0] rs1_signed = rs1;
   wire signed [31:0] rs2_signed = rs2;
   always@(*)begin
      case(opcode)
	7'b1100011: begin //Branches
	   case(funct) 
	     3'b000: 
	       if(rs1 == rs2) out <= 32'b01; //BEQ ALU checks if rs1 == rs2 
	       else out <= 32'b0;
	     3'b001: 
	       if(rs1 != rs2) out<= 32'b01; //BNE ALU checks if rs1 != rs2
	       else out <= 32'b0;
	     3'b100: 
	       if( rs1_signed < rs2_signed) out <= 32'b01; //BLT ALU checks if rs1 < rs2 (signed)
	       else out <= 32'b0;
	     3'b110: 
	       if(rs1 < rs2) out <= 32'b01;  //BLTU ALU checks if rs1 < rs2 (unsigned)
	       else out <= 32'b0;
	     3'b101: 
	       if(rs1_signed >= rs2_signed) out<= 32'b01; //BGE ALU checks if rs1 > rs2 (signed)
	       else out <= 32'b0;
	     3'b111: 
	       if(rs1 >= rs2) out <= 32'b01; //BGEU ALU checks if rs1 > rs2 (unsigned)
	       else out <= 32'b0;
	   endcase end // case (funct)
	7'b1100111: begin //JALR
	   out <= rs1 + rs2; 
	end endcase 
      end
endmodule
