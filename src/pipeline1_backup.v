module pipeline1(
    input clk, reset,
	   
    //pipeline1	   
    input [31:0] RF_data1_ID, RF_data2_ID,  write_data_reg_EX,
    input [4:0] csrwi_imm_ID, RAddr2_ID, WAddr_ID,		 
    output reg [31:0] RF_data1_EX, RF_data2_EX, RAddr2_EX, write_data_reg_ID,
    output reg [4:0] csrwi_imm_EX, WAddr_WB,
    input [31:0] ZE_data_ID, immediate_load_SE_ID, SE_imm_br_str,  JAL_SE_ID, PCplus4_ID, 
    output reg [31:0] ZE_data_EX, immediate_load_SE_EX, JAL_SE_EX, PCplus4_EX, 
    output reg [11:0] SE_imm_br_str_piped,	   
    
    //pipeline2
    input [31:0] PCplus4_imm_prime_EX,
    output reg [31:0] PCplus4_imm_WB, DM_write,
    
    //csrw and PC pipeline
    input [31:0] PC, csrw_result,
    output reg [31:0] PCprime, PCprime_EX, tohost,	  
    
    //control pipeline
    input PC_Mux_EX, WrEn_RF_ID,
    output reg PC_Mux_IDplus1, WrEn_RF_WB,
    input [1:0] WD_Mux_EX, RByteEn_DM_EX,
    input [3:0] WByteEn_DM_EX,
    output reg [1:0] WD_Mux_WB, RByteEn_DM_WB,
    output reg [3:0] WByteEn_DM_WB,		 		 
    input [1:0] DM_Mux_EX,
    output reg[1:0] DM_Mux_WB,
    input [1:0] ALU_hazmux2_sel_ID, ALU_hazmux1_sel_ID,Branch_Mux_ID,
    output reg [1:0] ALU_hazmux2_sel_EX, ALU_hazmux1_sel_EX,Branch_Mux_EX,
    input PCplus4_Mux_ctrl_ID,
    output reg PCplus4_Mux_ctrl_EX,	 
    input [6:0] opcode_ID, 
    output reg [6:0] opcode_EX,
    input [2:0]  funct_ID, 
    output reg [2:0] funct_EX,
    input add_rshift_type_ID,ALU_result_mux_ctrl_ID,
    output reg add_rshift_type_EX, PC_Mux_WB,ALU_result_mux_ctrl_EX,
    
    output reg [31:0] write_data_reg_ID_prev
);

   reg WrEn_RF_EX;
   reg [31:0] WAddr_EX;
   

   always @(posedge clk)begin
      csrwi_imm_EX <= csrwi_imm_ID;
      
      RF_data1_EX <= RF_data1_ID;
      RF_data2_EX <= RF_data2_ID;
      RAddr2_EX <= RAddr2_ID;
      write_data_reg_ID <= write_data_reg_EX;
      write_data_reg_ID_prev <= write_data_reg_ID; 
      
      ZE_data_EX <= ZE_data_ID;
      immediate_load_SE_EX <= immediate_load_SE_ID;
      SE_imm_br_str_piped <= SE_imm_br_str;
      JAL_SE_EX <= JAL_SE_ID;

      PCplus4_EX <= PCplus4_ID;
      PCplus4_imm_WB <= PCplus4_imm_prime_EX;
      DM_write <= RF_data2_EX;
      
      
      //DM_ALU_data_EX <= DM_ALU_data_WB;
      tohost <= csrw_result;

      if (reset) PCprime <= 32'h2000;
      else PCprime <= PC;

      PCprime_EX <= PCprime;
      
      PC_Mux_WB <= PC_Mux_EX;
      PC_Mux_IDplus1 <= PC_Mux_WB;
      WrEn_RF_EX <= WrEn_RF_ID;
      WrEn_RF_WB <= WrEn_RF_EX;
      WD_Mux_WB <= WD_Mux_EX;
      RByteEn_DM_WB <= RByteEn_DM_EX;
      WByteEn_DM_WB <= WByteEn_DM_EX;
      DM_Mux_WB <= DM_Mux_EX;

      opcode_EX <= opcode_ID;
      funct_EX <= funct_ID;
      add_rshift_type_EX <= add_rshift_type_ID;
   
      WAddr_EX <= WAddr_ID;
      WAddr_WB <= WAddr_EX;

      ALU_hazmux2_sel_EX <= ALU_hazmux2_sel_ID;
      ALU_hazmux1_sel_EX <= ALU_hazmux1_sel_ID;
      Branch_Mux_EX <= Branch_Mux_ID;

      PCplus4_Mux_ctrl_EX <= PCplus4_Mux_ctrl_ID;

      ALU_result_mux_ctrl_EX <= ALU_result_mux_ctrl_ID;
   end // always @ (posedge clk)

   always@ (negedge reset) PCprime <= 32'h1ffc;
endmodule   
      
      

	   
	   

 
