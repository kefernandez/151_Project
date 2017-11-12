module pipeline1(
    input clk,
	   
    //pipeline1	   
    input [31:0] RF_data1_ID, RF_data2_ID, RAddr2_ID,  write_data_reg_EX,
    input [4:0] csrwi_imm_ID,		 
    output reg [31:0] RF_data1_EX, RF_data2_EX, RAddr2_EX, write_data_reg_ID,
    output reg [4:0] csrwi_imm_EX,
    input [31:0] ZE_data_ID, immediate_load_SE_ID, SE_imm_br_str,  jal_SE_ID, PCplus4_ID, 
    output reg [31:0] ZE_data_EX, immediate_load_SE_EX, SE_imm_br_str_piped, jal_SE_EX, PCplus4_EX, 
	   
    
    //pipeline2
    input [31:0] DM_ALU_data_WB, PCplus4_imm_prime_EX, RF_data2_EX,
    output reg [31:0] DM_ALU_data_EX, PCplus4_imm_WB, DM_write,
    
    //csrw and PC pipeline
    input [31:0] PC, csrw_result,
    output reg [31:0] PCprime, tohost 	  
    
    //control pipeline
    input PC_Mux_EX, WrEN_RF_EX;
    output reg PC_Mux_IDplus1, WrEn_RF_WB;
    input [1:0] WD_Mux_EX, RByteEn_DM_EX;
    input [3:0] WByteEn_DM_EX;
    output reg [1:0] WD_Mux_WB, RByteEn_DM_WB;
    output reg [3:0] WByteEn_DM_WB;		 		 
    input [1:0] DM_Mux_EX;
    output reg[1:0] DM_Mux_WB;		 
);

   reg PC_Mux_WB;
   

   always @(posedge clk)begin
      csrwi_imm_EX <= csrwi_imm_ID;
      
      RF_data1_EX <= RF_data1_ID;
      RF_data2_EX <= RF_data2_ID;
      RAddr2_EX <= RAddr2_ID;
      write_data_reg_ID <= write_data_reg_EX;
      
      ZE_data_EX <= ZE_data_ID;
      immediate_load_SE_EX <= immediate_load_SE_ID;
      SE_imm_br_str_piped <= SE_imm_br_str;
      jal_SE_EX <= jal_SE_ID;

      PCplus4_EX <= PCplus4_ID;
      PCplus4_WB <= PCplus4_imm_prime_EX;
      DM_write <= RF_data2_EX;
      
      
      DM_ALU_data_EX <= DM_ALU_data_WB;
      tohost <= csrw_result;
      PCprime <= PC;

      PC_Mux_WB <= PC_Mux_EX;
      PC_Mux_IDplus1 <= PC_Mux_WB;
      WrEn_RF_WB <= WrEn_RF_EX;
      WD_Mux_WB <= WD_Mux_EX;
      RByteEn_DM_WB <= RByteEn_DM_EX;
      WByteEn_DM_WB <= WByteEn_DM_EX;
      DM_Mux_WB <= DM_Mux_EX;
      
      
   end // always @ (posedge clk)
endmodule   
      
      

	   
	   

 
