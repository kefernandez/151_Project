module control (input clk,
		
		//////////////
		// Input ports
		//////////////

		input [6:0] last_opcode,
		input [2:0] last_funct3,
		input take_branch, // this input signal is delayed by one cycle
		input [4:0] rs1, rs2, rd,
		input [31:0] PCprime,
		output ALU_result_mux_ctrl,
		///////////////
		// Output ports
		///////////////
		output PCplus4_Mux_ctrl,
		output reg PC_Mux,
		output WrEn_RF,
		output reg [1:0] WD_Mux,
		output [1:0] ALU_Mux,
		output reg [1:0] Branch_Mux,
		output CSRW_Mux,
		output [1:0] RByteEn_DM,
		output [3:0] WByteEn_DM,
		output reg [1:0] DM_Mux,
		output SE2_Ctrl,
                output reg [1:0] ALU_hazmux1_sel, ALU_hazmux2_sel);
		//////////////////
		// Internal wiring
		//////////////////
                
                reg [6:0] opcode;
   		reg [2:0] funct3;
                reg i = 0;
   		reg WD_0 = 1'b0;
   		reg WD_1 = 1'b0;
   		reg DM_0 = 1'b0;
   		reg DM_1 = 1'b0;
   		//reg Branch_0;
   		//reg Branch_1;
   		reg [3:0] WByteEn_DM;
                reg [6:0] prev_opcode, prev2_opcode;
                reg [4:0] rd_prev, rd_2prev;
		/////////////////
		// Internal logic
		/////////////////

                //PC plus 4Mux control
                assign PCplus4_Mux_ctrl = (last_opcode == 7'b1100111 || last_opcode == 7'b1101111) ? 1 : 0;
   		// Write data mux control
   		//assign WD_Mux[0] = WD_0;
   		//assign WD_Mux[1] = WD_1;
   		// Data cache mux control
   		//assign DM_Mux[0] = DM_0;
   		//assign DM_Mux[1] = DM_1;
   		// Branch mux control
   		//assign Branch_Mux[0] = Branch_0;
   		//assign Branch_Mux[1] = Branch_1;
		// PC mux control


                assign ALU_result_mux_ctrl = (last_opcode == 7'b1100111) ? 1 : 0;
		// Register file write enable
		assign WrEn_RF = ( last_opcode != 7'b1100011 && last_opcode != 7'b0100011 );
		// CSRW/I instruction mux control
		assign CSRW_Mux = ( opcode == 7'b1110011 && funct3[2] == 1'b1 );
		// Sign extension 2 control
		assign SE2_Ctrl = ( opcode == 7'b1100011 );
		// Read byte enable data cache control
		assign RByteEn_DM = funct3[1:0];
		// ALU mux control
		assign ALU_Mux[0] = ( ( opcode == 7'b0010011 && funct3[1:0] == 2'b01 ) || opcode[5:0] == 6'b100011 );
		assign ALU_Mux[1] = ( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b0010011 || opcode[5:0] == 6'b100011 );

                always @(posedge clk) begin
		   opcode = last_opcode;
		   funct3 = last_funct3;
		   //rd <= last_rd;
		   rd_prev <= rd;
		   rd_2prev <= rd_prev;
		   prev_opcode <= last_opcode;
		   prev2_opcode <= prev_opcode;
		   end
   
       		// delay incoming opcode and funct3 blocks to match take_branch
		always @ (*) begin
		   

		   
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
		   if (opcode == 7'b1100111 || opcode == 7'b1101111 || ( opcode == 7'b1100011 && take_branch ) ) PC_Mux <= 1;
		   else PC_Mux <= 0;

		   if(last_opcode == 7'b0110111) WD_Mux <= 2'b01;
		   else if(last_opcode == 7'b0010111 || last_opcode == 7'b1101111 || last_opcode == 7'b1100111) WD_Mux <= 2'b10;
		   else WD_Mux <= 2'b00;
		   
		   //WD_0 <= ( last_opcode == 7'b0110111 );
		   //WD_1 <= ( last_opcode == 7'b0010111 );

		   if(last_opcode == 7'b0110111) DM_Mux <= 2'b01;
		   else if ((last_opcode == 7'b0010111) || (last_opcode == 7'b1101111) || (last_opcode == 7'b1100111)) DM_Mux <= 2'b10;
		   else DM_Mux <= 2'b00;
		   //DM_0 <= ( opcode == 7'b0000011 && ( funct3 == 3'b010 || funct3[2:1] == 2'b10 ) );
		   //DM_1 <= ( opcode == 7'b0000011 && funct3[1] == 1'b0 );

		  /* if ( last_opcode == 7'b0x10111 || last_opcode == 7'b1101111 ) Branch_0 <= 1;
		   else Branch_0 <= 0;

		   if ( last_opcode == 7'b1100111 || last_opcode == 7'b0000011 || last_opcode == 7'b1101111 ) Branch_1 <= 1;
		   else Branch_1 <= 0;*/

		    if ( last_opcode == 7'b1101111) Branch_Mux <= 2'b11;
		    else if ( last_opcode == 7'b1100011) Branch_Mux <= 2'b10;
		    else if ( last_opcode == 7'b0010111) Branch_Mux <= 2'b01;
		    else Branch_Mux <= 2'b00;

		   // Write byte enable data cache control
   		   if ( opcode == 7'b0100011 ) begin
		      case (funct3)
			0: WByteEn_DM = 4'b0001;
			1: WByteEn_DM = 4'b0011;
			2: WByteEn_DM = 4'b1111;
		      endcase
		   end


		   //******hazard control************
		   if ( ((last_opcode == 7'b1100011) ||  (last_opcode == 7'b0100011) ||   (last_opcode == 7'b0110011)) && PCprime != 32'h2000 ) begin	      
		      //set rs1 mux
		      
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs1 == rd_prev) )begin  
			    ALU_hazmux1_sel = 2'b01; end	      
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs1 == rd_2prev))begin
			    ALU_hazmux1_sel = 2'b10; end
		      else  ALU_hazmux1_sel = 2'b00;

		      // set rs2 mux
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) &&  (rs2 == rd_prev))begin 
			ALU_hazmux2_sel = 2'b01; end
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs2 == rd_2prev))begin
			 ALU_hazmux2_sel = 2'b10;end
		      else  ALU_hazmux2_sel = 2'b00;
		   
		   end // if (opcode == 7'b1100011)

		   //if not branch instruction

		   else if( ((last_opcode == 7'b0000011) || (last_opcode == 7'b0010011) || (last_opcode == 7'b1100111) || (last_opcode == 7'b1110011)) && (PCprime != 32'h2000))begin
		      ALU_hazmux2_sel = 2'b00;
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs1 == rd_prev) )begin  
			    ALU_hazmux1_sel = 2'b01; end	      
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011)) && (rs1 == rd_2prev))begin
			    ALU_hazmux1_sel = 2'b10; end
		      else  ALU_hazmux1_sel = 2'b00;
		   end		      
		   
		   else begin
		      i <= 1'b0;
		      ALU_hazmux1_sel = 2'b00;
		      ALU_hazmux2_sel = 2'b00; end
		   
		     //******end hazard control************
			 
		     
		   
		end



endmodule
