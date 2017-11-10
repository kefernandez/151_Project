module control (
		/////////
		// Inputs
		/////////
		
		input [6:0] opcode,
		input [2:0] funct3,
		//input [6:0] funct7,  // this is only needed if ALU control is implemented here
		input [31:0] ALU_result,
		input equal,

		//////////
		// Outputs
		//////////

		output PC_Mux,
		output WrEn_RF,
		output [1:0] WD_Mux,
		output [1:0] ALU_Mux,
		output [1:0] Branch_Mux,
		output CSRW_Mux,
		output WrEn_DM,
		output [1:0] RByteEn_DM,
		output [1:0] WByteEn_DM,
		output [1:0] DM_Mux,
		output SE2_Ctrl

		assign

		// PC mux control
		PC_mux = ( opcode == 7'b0010111 || opcode[6:4] == 3'b110 ); // this needs to incorporate ALU_result and equal for branching decision
		// Register file write enable
		WrEn_RF = ( opcode != 7'b1100011 && opcode != 7'b0100011 );
		// Data cache write enable
		WrEn_DM = ( opcode == 7'b0100011 );
		// CSRW/I instruction mux control
		CSRW_Mux = ( opcode == 7'b1110011 && funct3[2] == 1'b1 );
		// Sign extension 2 control
		SE2_Ctrl = ( opcode == 7'b1100011 );
		// Read byte enable data cache control
		RByteEn_DM = funct3[1:0];
		// Write byte enable data cache control
		WByteEn_DM = funct3[1:0];
		// Write Data mux control
		opcode == 7'b0110111 ? WD_Mux[0] = 1'b1 : WD_Mux[0] = 1'b0;
		opcode == 7'b0010111 ? WD_Mux[1] = 1'b1 : WD_Mux[1] = 1'b0;
		// ALU mux control
		ALU_Mux[0] = ( ( opcode == 7'b0010011 && funct3[1:0] == 2'b01 ) || opcode[5:0] == 6'b100011 );
		ALU_Mux[1] = ( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b0010011 || opcode[5:0] == 6'b100011 );
		// Data cache mux control
		( opcode == 7'b0000011 && ( funct3 == 3'b010 || funct3[2:1] == 2'b10 ) ) ? DM_Mux[0] = 1'b1 : DM_Mux[0] = 1'b0;
		( opcode == 7'b0000011 && funct3[1] == 1'b0 ) ? DM_Mux[1] = 1'b1 : DM_Mux[1] = 1'b0;
		// Branch mux control
		( opcode == 7'b0x10111 || opcode == 7'b1101111 ) ? Branch_Mux[0] = 1'b1 : Branch_Mux[0] = 1'b0;
		( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b1101111 ) ? Branch_Mux[1] = 1'b1 : Branch_Mux[1] = 1'b0;
		
endmodule
