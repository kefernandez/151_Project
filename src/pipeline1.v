module pipeline1(
    input clk, reset, stall,
	   
    //pipeline1	   
    input [31:0] RF_data1_ID, RF_data2_ID,  write_data_reg_EX,data_write,immediate_branch_store_SE_ID,
    input [4:0] csrwi_imm_ID, RAddr2_ID, WAddr_ID,		 
    output reg [31:0] RF_data1_EX, RF_data2_EX, RAddr2_EX, immediate_branch_store_SE_EX,
    output reg [4:0] csrwi_imm_EX, WAddr_WB,
    input [31:0] ZE_data_ID, immediate_load_SE_ID,  JAL_SE_ID, PCplus4_ID, 
    output reg [31:0] ZE_data_EX, immediate_load_SE_EX, JAL_SE_EX, PCplus4_EX, 	   
    input [31:0] dcache_addr,
    output reg [31:0] dcache_addr_prev,
    //pipeline2
    input [31:0] PCplus4_imm_prime_ID,
    output reg [31:0] DM_write, PCplus4_imm_prime_EX,write_data_reg_ID, //PCplus4_imm_EX,
    //output reg icache_re,		 
		 
    //csrw and PC pipeline
    input [31:0] PC, csrw_result,
    output reg [31:0] PCprime, PCprime_EX, tohost,	  
    
    //control pipeline 
    input WrEn_RF_ID,
    output reg PC_Mux_IDplus1, WrEn_RF_WB,
    input [1:0] WD_Mux_EX, RByteEn_DM_EX,
    input [3:0] WByteEn_DM_EX,
    output reg [1:0] WD_Mux_WB, RByteEn_DM_WB,
    output reg [3:0] WByteEn_DM_WB,		 		 
    input [1:0] DM_Mux_ID,
    output reg[1:0] DM_Mux_WB,
    input [1:0] ALU_hazmux2_sel_ID, ALU_hazmux1_sel_ID,Branch_Mux_ID,
    output reg [1:0] ALU_hazmux2_sel_EX, ALU_hazmux1_sel_EX,Branch_Mux_EX,
    input PCplus4_Mux_ctrl_ID,
    output reg PCplus4_Mux_ctrl_EX,	 
    input [6:0] opcode_ID, 
    output reg [6:0] opcode_EX,
    input [2:0]  funct_ID, 
    output reg [2:0] funct_EX, funct_WB,
    input add_rshift_type_ID,ALU_result_mux_ctrl_ID,
    output reg add_rshift_type_EX, ALU_result_mux_ctrl_EX,
    
    output reg [31:0] write_data_reg_ID_prev
);

   reg WrEn_RF_EX;
   reg [31:0] WAddr_EX;
   reg [1:0]  DM_Mux_EX;
   reg WrEn_RF_EX_reg;
   reg [31:0] WAddr_EX_reg;
   reg [1:0]  DM_Mux_EX_reg;
  
   
   reg [31:0] RF_data1_EX_reg, RF_data2_EX_reg, RAddr2_EX_reg, immediate_branch_store_SE_EX_reg;
   reg [4:0]  csrwi_imm_EX_reg, WAddr_WB_reg;
   reg [31:0] ZE_data_EX_reg, immediate_load_SE_EX_reg, JAL_SE_EX_reg, PCplus4_EX_reg;
   reg [31:0] dcache_addr_prev_reg;
   reg [31:0] DM_write_reg, PCplus4_imm_prime_EX_reg,write_data_reg_ID_reg;
   reg [31:0] PCprime_reg, PCprime_EX_reg, tohost_reg;
   reg PC_Mux_IDplus1_reg, WrEn_RF_WB_reg;
   reg [1:0]  WD_Mux_WB_reg, RByteEn_DM_WB_reg;
   reg [3:0]  WByteEn_DM_WB_reg;
   reg [1:0]  DM_Mux_WB_reg;
   reg [1:0]  ALU_hazmux2_sel_EX_reg, ALU_hazmux1_sel_EX_reg,Branch_Mux_EX_reg;
   reg  PCplus4_Mux_ctrl_EX_reg;
   reg [6:0]  opcode_EX_reg;
   reg [2:0]  funct_EX_reg, funct_WB_reg;
   reg add_rshift_type_EX_reg, ALU_result_mux_ctrl_EX_reg;
   reg [31:0] write_data_reg_ID_prev_reg;
   
   


   always @(posedge clk)begin

      if(!stall) begin
	 csrwi_imm_EX <= csrwi_imm_ID;
      
	 RF_data1_EX <= RF_data1_ID;
	 RF_data2_EX <= RF_data2_ID;
	 RAddr2_EX <= RAddr2_ID;
	 write_data_reg_ID <= write_data_reg_EX;
	 write_data_reg_ID_prev <= data_write; 
	 
	 ZE_data_EX <= ZE_data_ID;
	 immediate_load_SE_EX <= immediate_load_SE_ID;
	 JAL_SE_EX <= JAL_SE_ID;
	 
	 PCplus4_EX <= PCplus4_ID;
	 PCplus4_imm_prime_EX <= PCplus4_imm_prime_ID;
	 DM_write <= RF_data2_EX;

	 immediate_branch_store_SE_EX <= immediate_branch_store_SE_ID;
	 
	 //DM_ALU_data_EX <= DM_ALU_data_WB;
	 tohost <= csrw_result;
	 
	 if (reset) begin
	    PCprime <= 32'h2000;
	    //icache_re <= 1'b0;
	 end 
	 else PCprime <= PC;
	 
	 PCprime_EX <= PCprime;
	 
	 
	 WrEn_RF_EX <= WrEn_RF_ID;
	 WrEn_RF_WB <= WrEn_RF_EX;
	 WD_Mux_WB <= WD_Mux_EX;
	 RByteEn_DM_WB <= RByteEn_DM_EX;
	 WByteEn_DM_WB <= WByteEn_DM_EX;
	 DM_Mux_WB <= DM_Mux_EX;
	 
	 DM_Mux_EX <= DM_Mux_ID;
	 DM_Mux_WB <= DM_Mux_EX;
	 dcache_addr_prev <= dcache_addr;
	 
	 opcode_EX <= opcode_ID;
	 funct_EX <= funct_ID;
	 funct_WB <= funct_EX;
	 add_rshift_type_EX <= add_rshift_type_ID;
	 
	 WAddr_EX <= WAddr_ID;
	 WAddr_WB <= WAddr_EX;
	 
	 ALU_hazmux2_sel_EX <= ALU_hazmux2_sel_ID;
	 ALU_hazmux1_sel_EX <= ALU_hazmux1_sel_ID;
	 Branch_Mux_EX <= Branch_Mux_ID; 
	 
	 PCplus4_Mux_ctrl_EX <= PCplus4_Mux_ctrl_ID;
	 
	 ALU_result_mux_ctrl_EX <= ALU_result_mux_ctrl_ID;
     
	 //PCprime_reg <= PCprime;

	 //~~~~~~Storing values for safety


      end //if (!stall)
      
      
	 

      //~~~~~~~~~~~if stalling, need to reload values back into the registers
      /*else if(stall) begin
	   
	 
	


	 
	    
      end*/

	 
     
      
   end // always @ (posedge clk)
   

   always @(negedge clk) begin
      PCprime_reg = PCprime;
      RF_data1_EX_reg = RF_data1_EX;
      RF_data2_EX_reg <= RF_data2_EX;
      RAddr2_EX_reg <= RAddr2_EX;
      immediate_branch_store_SE_EX_reg <= immediate_branch_store_SE_EX;
      csrwi_imm_EX_reg <=  csrwi_imm_EX;
      WAddr_WB_reg <= WAddr_WB;
      ZE_data_EX_reg <=  ZE_data_EX;
      immediate_load_SE_EX_reg <= immediate_load_SE_EX;
      JAL_SE_EX_reg <=  JAL_SE_EX;
      PCplus4_EX_reg <= PCplus4_EX;
      dcache_addr_prev_reg <= dcache_addr_prev;
      DM_write_reg <= DM_write;
      PCplus4_imm_prime_EX_reg <= PCplus4_imm_prime_EX;
      write_data_reg_ID_reg <=  write_data_reg_ID;
      //PCprime_reg <=  PCprime;
      PCprime_EX_reg <= PCprime_EX;
      //tohost_reg<= tohost;
      PC_Mux_IDplus1_reg <= PC_Mux_IDplus1;
      WrEn_RF_WB_reg<=  WrEn_RF_WB;
      WD_Mux_WB_reg <= WD_Mux_WB;
      RByteEn_DM_WB_reg <= RByteEn_DM_WB;
      WByteEn_DM_WB_reg <=  WByteEn_DM_WB;
      DM_Mux_WB_reg <=  DM_Mux_WB;
      ALU_hazmux2_sel_EX_reg <=  ALU_hazmux2_sel_EX;
      ALU_hazmux1_sel_EX_reg <= ALU_hazmux1_sel_EX;
      Branch_Mux_EX_reg <= Branch_Mux_EX;
      PCplus4_Mux_ctrl_EX_reg <=  PCplus4_Mux_ctrl_EX;
      opcode_EX_reg <= opcode_EX;
      funct_EX_reg <=  funct_EX;
      funct_WB_reg <=  funct_WB;
      add_rshift_type_EX_reg <= add_rshift_type_EX;
      ALU_result_mux_ctrl_EX_reg <=  ALU_result_mux_ctrl_EX;
      write_data_reg_ID_prev_reg <=  write_data_reg_ID_prev;
      WrEn_RF_EX_reg <= WrEn_RF_EX;
      WAddr_EX_reg <= WAddr_EX;
      DM_Mux_EX_reg <= DM_Mux_EX;
   end
   
   always@ (negedge reset) begin
      PCprime <= 32'h1ffc;
      //icache_re <= 1'b1;
      end

   always@(negedge stall) begin
      //if(~clk) PCprime <= PC;
      
      
      end

   always@(posedge stall) begin
      //PC <= PCprime;
            
      PCprime <= PCprime_reg;
      RF_data1_EX <= RF_data1_EX_reg;
      RF_data2_EX <= RF_data2_EX_reg;
      RAddr2_EX <= RAddr2_EX_reg;
      immediate_branch_store_SE_EX <= immediate_branch_store_SE_EX_reg;
      csrwi_imm_EX <=  csrwi_imm_EX_reg;
      WAddr_WB <= WAddr_WB_reg;
      ZE_data_EX <=  ZE_data_EX_reg;
      immediate_load_SE_EX <= immediate_load_SE_EX_reg;
      JAL_SE_EX <=  JAL_SE_EX_reg;
      PCplus4_EX <= PCplus4_EX_reg;
      dcache_addr_prev <= dcache_addr_prev_reg;
      DM_write <= DM_write_reg;
      PCplus4_imm_prime_EX <= PCplus4_imm_prime_EX_reg;
      write_data_reg_ID <=  write_data_reg_ID_reg;
      //PCprime <=  PCprime_reg;
      PCprime_EX <= PCprime_EX_reg;
      //tohost<= tohost_reg;
      PC_Mux_IDplus1 <= PC_Mux_IDplus1_reg;
      WrEn_RF_WB<=  WrEn_RF_WB_reg;
      WD_Mux_WB <= WD_Mux_WB_reg;
      RByteEn_DM_WB <= RByteEn_DM_WB_reg;
      WByteEn_DM_WB <=  WByteEn_DM_WB_reg;
      DM_Mux_WB <=  DM_Mux_WB_reg;
      ALU_hazmux2_sel_EX <=  ALU_hazmux2_sel_EX_reg;
      ALU_hazmux1_sel_EX <= ALU_hazmux1_sel_EX_reg;
      Branch_Mux_EX <= Branch_Mux_EX_reg;
      PCplus4_Mux_ctrl_EX <=  PCplus4_Mux_ctrl_EX_reg;
      opcode_EX <= opcode_EX_reg;
      funct_EX <=  funct_EX_reg;
      funct_WB <=  funct_WB_reg;
      add_rshift_type_EX <= add_rshift_type_EX_reg;
      ALU_result_mux_ctrl_EX <=  ALU_result_mux_ctrl_EX_reg;
      write_data_reg_ID_prev <=  write_data_reg_ID_prev_reg;
      WrEn_RF_EX <= WrEn_RF_EX_reg;
      WAddr_EX <= WAddr_EX_reg;
      DM_Mux_EX <= DM_Mux_EX_reg;
   end
      
      
   
endmodule   
      
      

	   
	   

 
