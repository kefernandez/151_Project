module ALU(
    input clk,
	   
    //pipeline1	   
    input [31:0] csrwi_imm_ID, RF_data1_ID, RF_data2_ID, RAddr2_ID,  write_data_reg_EX, 
    output reg [31:0] csrwi_imm_EX, RF_data1_EX, RF_data2_EX, RAddr2_EX, write_data_reg_ID,
    input [31:0] ZE_data_ID, Immediate_Load_SE_ID, Immediate_Branch_Store_SE_ID, Jal_SE_ID, PCplus4_ID, 
    output reg [31:0] ZE_data_EX, Immediate_Load_SE_EX, Immediate_Branch_Store_SE_EX, Jal_SE_EX, PCplus4_EX, 
	   
    
    //pipeline2
    input [31:0] DM_ALU_data_WB, PCplus4_imm_prime_EX,
    output reg [31:0] DM_ALU_data_EX, PCplus4_imm_ID,
    
    //misc pipeline
    input [31:0] PC, csrw_result,
    output reg [31:0] PCprime, tohost 	    	   
);

   reg [31:0] PCplus4_imm_WB, PCplus4_imm_EX;


   always @(posedge clk)begin
      csrwi_imm_EX <= csrwi_imm_ID;
      
      RF_data1_EX <= RF_data1_ID;
      RF_data2_EX <= RF_data2_ID;
      RAddr2_EX <= RAddr2_ID;
      write_data_reg_ID <= write_data_reg_EX;
      
      ZE_data_EX <= ZE_data_ID;
      Immediate_Load_SE_EX <= Immediate_Load_SE_ID;
      Immediate_Branch_Store_SE_EX <= Immediate_Branch_Store_SE_ID;
      Jal_SE_EX <= Jal_SE_ID;
      
      PCplus4_EX <= PCplus4_ID;
      PCplus4_imm_WB <= PCplus4_imm_prime_EX;
      PCplus4_imm_EX <= PCplus4_imm_WB;
      PCplus4_imm_ID <= PCplus4_imm_EX;
      
      DM_ALU_data_EX <= DM_ALU_data_WB;
      tohost <= csrw_result;
      PCprime <= PC;
      
   end // always @ (posedge clk)
endmodule   
      
      

	   
	   

 
