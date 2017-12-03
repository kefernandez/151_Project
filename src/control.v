module control (input clk,
		input stall,
		//////////////
		// Input ports
		//////////////

		input [6:0] last_opcode,
		input [2:0] last_funct3,
		input take_branch, // this input signal is delayed by one cycle
		input [4:0] rs1, rs2, rd,
		input [31:0] PCprime, data_byte_in,
		output reg [31:0] data_byte_out,
		output ALU_result_mux_ctrl,
		output JALR_comparator_mux_ctrl, 
		output reg write_data_mux,
		///////////////
		// Output ports
		///////////////
		output PCplus4_Mux_ctrl,
		input [1:0] DM_data_offset,
		output reg [1:0] PC_Mux,
		output WrEn_RF,
		output reg [1:0] WD_Mux,
		output [1:0] ALU_Mux,
		output reg [1:0] Branch_Mux,
		output reg [1:0] CSRW_Mux,
		output [1:0] RByteEn_DM,
		output [3:0] WByteEn_DM,
		output reg [1:0] DM_Mux,
		output SE2_Ctrl,
                output reg [1:0] ALU_hazmux1_sel, ALU_hazmux2_sel,
		output reg [1:0] Branch_comp_mux1_ctrl, Branch_comp_mux2_ctrl);
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

                reg [6:0] opcode_reg;
   		reg [2:0] funct3_reg;
                reg [6:0] prev_opcode_reg, prev2_opcode_reg;
                reg [4:0] rd_prev_reg, rd_2prev_reg;

                assign PCplus4_Mux_ctrl = (last_opcode == 7'b1100111 || last_opcode == 7'b1101111 ) ? 1 : 0;     
                assign ALU_result_mux_ctrl = (last_opcode == 7'b1100111) ? 1 : 0;	
		assign WrEn_RF = ( last_opcode != 7'b1100011 && last_opcode != 7'b0100011 && rd != 5'b0);	
		assign SE2_Ctrl = ( last_opcode == 7'b1100011 );	
                assign ALU_Mux[0] = (opcode[5:0] == 6'b100011);
		assign ALU_Mux[1] = ( opcode == 7'b1100111 || opcode == 7'b0000011 || opcode == 7'b0010011 || opcode[5:0] == 6'b100011 );

                assign JALR_comparator_mux_ctrl = (last_opcode == 7'b1100111) ? 1'b1 : 1'b0;

                always @(negedge clk) begin
		   opcode_reg <= opcode;
		   funct3_reg <= funct3;
		   rd_prev_reg <= rd_prev; 
		   rd_2prev_reg <= rd_2prev;
		   prev_opcode_reg <= prev_opcode;
		   prev2_opcode_reg <= prev2_opcode;
		end

		   
                always @(posedge clk) begin

		   if(~stall) begin
		      opcode <= last_opcode;
		      funct3 <= last_funct3;
		      rd_prev <= rd;
		      rd_2prev <= rd_prev;
		      prev_opcode <= last_opcode;
		      prev2_opcode <= prev_opcode;
		   end
		   
		   
		end // always @ (posedge clk)

                always @(posedge stall) begin
		   opcode <= opcode_reg;
		   funct3 <= funct3_reg;
		   rd_prev <= rd_prev_reg; 
		   rd_2prev <= rd_2prev_reg;
		   prev_opcode <= prev_opcode_reg;
		   prev2_opcode <= prev2_opcode_reg;
		end
   
       		// delay incoming opcode and funct3 blocks to match take_branch
		always @ (*) begin
		   
		   //if(~stall) begin
		   
		      if(last_opcode == 7'b1101111 || (last_opcode == 7'b1100011 && take_branch )) PC_Mux <= 2'b01;
		      else if( last_opcode == 7'b1100111) PC_Mux <= 2'b10;
		      else PC_Mux <= 2'b00;


		      if(prev2_opcode == 7'b0000011) write_data_mux <= 1'b1;
		      else write_data_mux <= 1'b0;
		   //if(funct3[1:0] == 2'b00)  
		   
		   if(opcode == 7'b1110011 && funct3 == 3'b101 ) CSRW_Mux = 2'b10;
		   else if (opcode == 7'b1110011 && funct3 == 3'b001 ) CSRW_Mux = 2'b01;
		   else CSRW_Mux = 2'b00;
		

		   if(last_opcode == 7'b0110111) WD_Mux <= 2'b01;
		   else if( last_opcode == 7'b1101111 || last_opcode == 7'b1100111) WD_Mux <= 2'b10;
		   else if (last_opcode == 7'b0010111) WD_Mux <= 2'b11;
		   else WD_Mux <= 2'b00;
		   
	

		   if(last_opcode == 7'b0000011)begin
		      if (last_funct3 == 3'b100 || last_funct3 == 3'b101) DM_Mux <= 2'b10;
		      else if(last_funct3 == 3'b000 || last_funct3 == 3'b001) DM_Mux <= 2'b01;
		   end
		   else DM_Mux <= 2'b00;
		   

		    if ( last_opcode == 7'b1101111) Branch_Mux <= 2'b11;
		    else if ( last_opcode == 7'b1100011) Branch_Mux <= 2'b10;
		    else if ( last_opcode == 7'b0010111) Branch_Mux <= 2'b01;
		    else Branch_Mux <= 2'b00;

		   // Write byte enable data cache control
   		   if ( prev_opcode == 7'b0100011 ) begin
		      case (funct3)
			3'b000: begin
			   if(DM_data_offset == 2'b00) begin
			      WByteEn_DM = 4'b0001;
			      data_byte_out <= {24'b0, data_byte_in[7:0]};
			      end
			   else if(DM_data_offset == 2'b01) begin
			      WByteEn_DM = 4'b0010;
			      data_byte_out <= {16'b0, data_byte_in[7:0],8'b0};
			      end
			   else if(DM_data_offset == 2'b10) begin
			      WByteEn_DM = 4'b0100;
			      data_byte_out <= {8'b0, data_byte_in[7:0],16'b0};
			      end
			   else  begin
			      WByteEn_DM = 4'b1000;
			      data_byte_out <= {data_byte_in[7:0],24'b0};
			      end	   
			end
			3'b001:begin
			   if(DM_data_offset == 2'b00) begin
			      WByteEn_DM = 4'b0011;
			      data_byte_out <= {16'b0, data_byte_in[15:0]};
			      end
			   else if(DM_data_offset == 2'b01) begin
			      WByteEn_DM = 4'b0110;
			      data_byte_out <= {8'b0, data_byte_in[15:0], 8'b0};
			      end
			   //else if(DM_data_offset == 2'b10) WByteEn_DM = 4'b0110;
			   else  begin
			      WByteEn_DM = 4'b1100;
			      data_byte_out <= {data_byte_in[15:0], 16'b0};
			      end
			end
			3'b010: begin
			   WByteEn_DM = 4'b1111;
			   data_byte_out <= data_byte_in; end
			default: WByteEn_DM = 4'b0000;
		      endcase // case (funct3)
		   end
		   else WByteEn_DM = 4'b0000;
		   


		   //******hazard control for Branch Comparator***** 
		   if(last_opcode == 7'b1100011)begin
		      //check is rs1 has a hazard
		        if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs1 == rd_prev)  && (rd_prev != 5'b0))begin  
			    Branch_comp_mux1_ctrl = 2'b01; end	      
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs1 == rd_2prev)  && (rd_2prev != 5'b0))begin
			    Branch_comp_mux1_ctrl = 2'b10; end
		      else  Branch_comp_mux1_ctrl = 2'b00;

		      // check if rs2 is a hazard
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) &&  (rs2 == rd_prev)   && (rd_prev != 5'b0))begin 
			Branch_comp_mux2_ctrl = 2'b01; end
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs2 == rd_2prev)   && (rd_2prev != 5'b0))begin
			 Branch_comp_mux2_ctrl = 2'b10;end
		      else  Branch_comp_mux2_ctrl = 2'b00;
		   
		   end // if (opcode == 7'b1100011)
		   else if(last_opcode == 7'b1100111) begin    //if JALR
		      Branch_comp_mux2_ctrl = 2'b00;
		      
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs1 == rd_prev)  && (rd_prev != 5'b0))begin  
			    Branch_comp_mux1_ctrl = 2'b01; end	      
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs1 == rd_2prev)  && (rd_2prev != 5'b0))begin
			    Branch_comp_mux1_ctrl = 2'b10; end
		      else  Branch_comp_mux1_ctrl = 2'b00;
		   end




		   

		   
		   //******hazard control for ALU************
		   if ((last_opcode == 7'b0100011) ||   (last_opcode == 7'b0110011)) begin	      
		      //set rs1 mux
		      
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs1 == rd_prev)   && (rd_prev != 5'b0))begin  
			    ALU_hazmux1_sel = 2'b01; end	      
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs1 == rd_2prev)   && (rd_2prev != 5'b0))begin
			    ALU_hazmux1_sel = 2'b10; end
		      else  ALU_hazmux1_sel = 2'b00;

		      // set rs2 mux
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) &&  (rs2 == rd_prev)   && (rd_prev != 5'b0))begin 
			ALU_hazmux2_sel = 2'b01; end
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011))  && (rs2 == rd_2prev)   && (rd_2prev != 5'b0))begin
			 ALU_hazmux2_sel = 2'b10;end
		      else  ALU_hazmux2_sel = 2'b00;
		   
		   end // if (opcode == 7'b1100011)

		   //if instruction that only looks at rs1 

		   else if( ((last_opcode == 7'b0000011) || (last_opcode == 7'b0010011) || (last_opcode == 7'b1110011)))begin
		      ALU_hazmux2_sel = 2'b00;
		      if (((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs1 == rd_prev)   && (rd_prev!= 5'b0) )begin  
			    ALU_hazmux1_sel = 2'b01; end	      
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011)) && (rs1 == rd_2prev)   && (rd_2prev != 5'b0))begin
			    ALU_hazmux1_sel = 2'b10; end
		      else  ALU_hazmux1_sel = 2'b00;
		   end		      
		   else if (last_opcode == 7'b0100011)begin
		      ALU_hazmux1_sel = 2'b00;
		      if(((prev_opcode == 7'b0110111) || (prev_opcode == 7'b0010111) || (prev_opcode == 7'b1101111) || (prev_opcode == 7'b1100111) || (prev_opcode == 7'b0000011) || (prev_opcode == 7'b0010011)|| (prev_opcode == 7'b0110011)) && (rs2 == rd_prev)  && (rd_prev!= 5'b0))begin		 
			 ALU_hazmux2_sel = 2'b01; end
		      else if (((prev2_opcode == 7'b0110111) || (prev2_opcode == 7'b0010111) || (prev2_opcode == 7'b1101111) || (prev2_opcode == 7'b1100111) || (prev2_opcode == 7'b0000011) || (prev2_opcode == 7'b0010011)|| (prev2_opcode == 7'b0110011)) && (rs2 == rd_2prev)   && (rd_2prev != 5'b0))begin
			 ALU_hazmux2_sel = 2'b10; end
		      else ALU_hazmux2_sel = 2'b00;
		   end
		   else begin
		      i <= 1'b0;
		      ALU_hazmux1_sel = 2'b00;
		      ALU_hazmux2_sel = 2'b00; end
		   
		     //******end hazard control************
			 
		   //end
    
		   
		end



endmodule
