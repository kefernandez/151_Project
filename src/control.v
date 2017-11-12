module control (input clk,
		
		//////////////
		// Input ports
		//////////////

		input [6:0] last_opcode,
		input [2:0] last_funct3,
		input take_branch, // this input signal is delayed by one cycle

		///////////////
		// Output ports
		///////////////

		output PC_Mux,
		output WrEn_RF,
		output [1:0] WD_Mux,
		output [1:0] ALU_Mux,
		output [1:0] Branch_Mux,
		output CSRW_Mux,
		output [1:0] RByteEn_DM,
		output [3:0] WByteEn_DM,
		output [1:0] DM_Mux,
		output SE2_Ctrl);

		//////////////////
		// Internal wiring
		//////////////////
                
                reg [6:0] opcode;
   		reg [2:0] funct3;

   		reg WD_0 = 1'b0;
   		reg WD_1 = 1'b0;
   		reg DM_0 = 1'b0;
   		reg DM_1 = 1'b0;
   		reg Branch_0 = 1'b0;
   		reg Branch_1 = 1'b0;
   		reg [3:0] WByteEn_DM;
   
		/////////////////
		// Internal logic
		/////////////////
   
       		// delay incoming opcode and funct3 blocks to match take_branch
		always @ (posedge clk) begin
		   opcode = last_opcode;
		   funct3 = last_funct3;
		   
		   /*// Write data mux control
		   opcode == 7'b0110111 ? WD_Mux[0] <= 1'b1 : WD_Mux[0] <= 1'b0;
		   opcode == 7'b0010111 ? WD_Mux[1] <= 1'b1 : WD_Mux[1] <= 1'b0;
   		   // Data cache mux control
		   ( opcode == 7'b0000011 && ( funct3 == 3'b010 || funct3[2:1] == 2'b10 ) ) ? DM_Mux[0] <= 1'b1 : DM_Mux[0] <= 1'b0;
		   ( opcode == 7'b0000011 && funct3[1] == 1'b0 ) ? DM_Mux[1] <= 1'b1 : DM_Mux[1] <= 1'b0;
		   // Branch mux control
		   ( opcode == 7'b0x10111 || opcode == 7'b1101111 ) ? Branch_Mux[0] <= 1'b1 : Branch_Mux[0] <= 1'b0;
		   ( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b1101111 ) ? Branch_Mux[1] <= 1'b1 : Branch_Mux[1] <= 1'b0;*/

		   // Update parameters

		   
		   WD_0 <= ( opcode == 7'b0110111 );
		   WD_1 <= ( opcode == 7'b0010111 );

		   DM_0 <= ( opcode == 7'b0000011 && ( funct3 == 3'b010 || funct3[2:1] == 2'b10 ) );
		   DM_1 <= ( opcode == 7'b0000011 && funct3[1] == 1'b0 );

		   Branch_0 <= ( opcode == 7'b0x10111 || opcode == 7'b1101111 );
		   Branch_1 <= ( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b1101111 );

		   // Write byte enable data cache control
   		   if ( opcode == 7'b0100011 ) begin
		      case (funct3)
			0: WByteEn_DM = 4'b0001;
			1: WByteEn_DM = 4'b0011;
			2: WByteEn_DM = 4'b1111;
		      endcase
		   end
		end


   		// Write data mux control
   		assign WD_Mux[0] = WD_0;
   		assign WD_Mux[1] = WD_1;
   		// Data cache mux control
   		assign DM_Mux[0] = DM_0;
   		assign DM_Mux[1] = DM_1;
   		// Branch mux control
   		assign Branch_Mux[0] = Branch_0;
   		assign Branch_Mux[1] = Branch_1;
		// PC mux control
		assign PC_mux = ( opcode == 7'b0010111 || opcode == 7'b110x111 || ( opcode == 7'b1100011 && take_branch ) );
		// Register file write enable
		assign WrEn_RF = ( opcode != 7'b1100011 && opcode != 7'b0100011 );
		// CSRW/I instruction mux control
		assign CSRW_Mux = ( opcode == 7'b1110011 && funct3[2] == 1'b1 );
		// Sign extension 2 control
		assign SE2_Ctrl = ( opcode == 7'b1100011 );
		// Read byte enable data cache control
		assign RByteEn_DM = funct3[1:0];
		// ALU mux control
		assign ALU_Mux[0] = ( ( opcode == 7'b0010011 && funct3[1:0] == 2'b01 ) || opcode[5:0] == 6'b100011 );
		assign ALU_Mux[1] = ( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b0010011 || opcode[5:0] == 6'b100011 );

endmodule
