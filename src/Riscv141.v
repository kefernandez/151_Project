
module Riscv141(
    input clk, //
    input reset,

    // Memory system ports
    output [31:0] dcache_addr,//
    output [31:0] icache_addr, //
    output [3:0] dcache_we, //
    output dcache_re, //
    output icache_re, //
    output [31:0] dcache_din, //
    input [31:0] dcache_dout, //
    input [31:0] icache_dout, //never give a name to this
    input stall,
    output [31:0] csr //

);
   //PC related wires
   wire [31:0] PC, PCplus4_ID;
   wire [31:0] PC_imm, PCplus4_imm_prime_EX;
   wire [31:0] PCprime, PCplus4_EX, PCplus4_imm_WB; 
   wire [31:0] PCprime_EX, PC_rel;
   wire [31:0] data_byte_in, data_byte_out;
   //Reg file related wires
   wire [4:0] RAddr1_ID, RAddr2_ID, WAddr_ID, WAddr_WB;
   //coming from IM cache - need assign statements
   wire [31:0] write_data_reg_EX, RF_data1_ID, RF_data2_ID;
   //to and from reg file
   wire [31:0]  RF_data1_EX, RF_data2_EX, RAddr2_EX, write_data_reg_ID, write_data_reg_ID_prev, data_write, write_data_reg_ID; //reg
   wire write_data_mux;
   //Branch, JAL, JALR, AUIPC related wires
   wire [31:0] 	rs2_or_JALRimm, compare_result, JAL_SE_ID_shift, branch_rs1, branch_rs2, PCplus4_imm_prime_ID;

   
   //csrw wires
   wire [4:0]  csrwi_imm_ID;
   wire [4:0] csrwi_imm_EX; //reg
   wire [31:0] csrwi_zimm, csrw_result;
   wire [31:0] tohost;//reg

 
   //Immediate related wires
   wire [11:0] SE_imm_br_str;
   wire [11:0] SE_imm_br_str_piped, SE_imm_load_JALR;
   wire [19:0] SE_imm_JAL, ZE_imm_LUI_AUI;   
   wire [31:0] ZE_data_ID, immediate_load_SE_ID, immediate_branch_store_SE_ID, JAL_SE_ID;
   wire [31:0] ZE_data_EX, immediate_load_SE_EX, JAL_SE_EX; //reg
   wire [31:0] immediate_branch_store_SE_EX;
   wire [31:0] branch_store_shift,JAL_SE_EX_shift;
     
	          
   //ALU wires
   wire [31:0] ALU_src1, ALU_src2, ALU_result, ALU_res_zLSB, ALU_mux_out;
   wire [3:0]  ALUop;
   wire [6:0]  opcode_ID, opcode_EX;
   wire [2:0]  funct_ID, funct_EX, funct_WB;
   wire add_rshift_type_ID, add_rshift_type_EX;
   
   
   //DM wires
   wire [31:0] DM_data,dcache_addr_prev, DM_data_SM,DM_data_ZE, DM_ALU_data_WB;
   wire [31:0]  DM_write, DM_ALU_data_EX; //reg	        	       
	       
   //controls
   wire [6:0]  last_opcode;
   wire [2:0]  last_funct3;
   wire  add_rshift_type;
   wire take_branch;
   wire [1:0] PC_Mux_ID, PC_Mux_EX, PC_Mux_WB;
   wire WrEn_RF_WB;
   wire [1:0] WD_Mux_EX, ALU_Mux_EX, Branch_Mux_ID, Branch_Mux_EX; //wire
   wire WrEn_DM_EX, SE2_Ctrl_ID;
   wire [1:0] RByteEn_DM_EX, DM_Mux_EX, DM_Mux_ID, CSRW_Mux_EX;
   wire [3:0] WByteEn_DM_EX, WByteEn_DM_ID;
   wire [1:0] Branch_comp_mux1_ctrl, Branch_comp_mux2_ctrl;
   
   wire WrEn_RF_ID; //reg
   wire [1:0] WD_Mux_WB, RByteEn_DM_WB, DM_Mux_WB; //reg
   wire [3:0] WByteEn_DM_WB; //reg
   wire WrEn_DM_WB; //reg
   wire PCplus4_Mux_ctrl_ID, PCplus4_Mux_ctrl_EX;
   wire PC_Mux_IDplus1;      //reg
   wire [1:0] ALU_hazmux2_sel_ID, ALU_hazmux1_sel_ID, ALU_hazmux2_sel_EX, ALU_hazmux1_sel_EX;
   wire ALU_result_mux_ctrl_ID, ALU_result_mux_ctrl_EX;
   wire [31:0] Branch_mux_in0;
   wire JALR_comparator_mux_ctrl;
   
   wire [0:0] datapath_contents;
   wire [0:0]  dpath_controls_i;
   wire [0:0]  exec_controls_x;
   wire [0:0]  hazard_controls;

   assign dcache_we =  WByteEn_DM_EX;
   assign dcache_re = 1'b1;
   assign  icache_re = 1'b1;

   assign data_byte_in = ALU_mux_out;
   
   
   assign last_opcode = icache_dout[6:0];
   assign last_funct3 = icache_dout[14:12]; 
   assign take_branch = compare_result[0];


   //PC assignments
   /*always @(posedge clk)begin
      if(reset == 1) icache_addr <= 32'h2000; 
      else icache_addr <= PC; end*/
   assign icache_addr = PC;
   
   //Reg file assignments
   assign RAddr1_ID = icache_dout[19:15];
   assign RAddr2_ID = icache_dout[24:20];
   assign WAddr_ID = icache_dout[11:7];

   
   //csrw assignments
   assign csrwi_imm_ID = icache_dout[19:15];
   assign csr = tohost;

   //immediate assignments
   assign ZE_imm_LUI_AUI = icache_dout[31:12];
   assign SE_imm_load_JALR = icache_dout[31:20];
   assign SE_imm_br_str = {icache_dout[31:25],icache_dout[11:7]};
   assign SE_imm_JAL = {icache_dout[31],icache_dout[19:12],icache_dout[20],icache_dout[30:21]};
   //shifted immediate assignments 
   assign branch_store_shift = immediate_branch_store_SE_ID << 1;
   assign JAL_SE_ID_shift = JAL_SE_ID << 1;
   
   //ALU assignments
   assign ALU_res_zLSB = {compare_result[31:1],1'b0};
   assign dcache_addr = ALU_result;
   assign add_rshift_type = dcache_dout[30];
   assign opcode_ID = icache_dout[6:0];
   assign funct_ID = icache_dout[14:12];
   assign add_rshift_type_ID = icache_dout[30];
   
   //DM Assignments
   assign dcache_din = data_byte_out;
   assign DM_data = dcache_dout;
   
    /*controller ctrl(
        .datapath_contents(datapath_contents),
        .dpath_controls_i(dpath_controls_i),
        .exec_controls_x(exec_controls_x),
        .hazard_controls(hazard_controls)
    );

    datapath dpath(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .dpath_controls_i(dpath_controls_i),
        .exec_controls_x(exec_controls_x),
        .hazard_controls(hazard_controls),
        .datapath_contents(datapath_contents),
        .dcache_addr(dcache_addr),
        .icache_addr(icache_addr),
        .dcache_we(dcache_we),
        .dcache_re(dcache_re),
        .icache_re(icache_re),
        .dcache_din(dcache_din),
        .dcache_dout(dcache_dout),
        .icache_dout(icache_dout),
        .csr_tohost(csr)
    );*/


   //1
   mux_3x1 PC_mux(
	//.clk(clk),
	//.reset(reset),
	.in0(PCplus4_ID),
	.in1(PCplus4_imm_prime_ID),
	.in2(PC_imm),	 
        .sel(PC_Mux_ID),
        .out(PC)
    );

   //2
   sum PC_sum1(
	//.reset(reset),      
	.in0(PCprime),
	.in1(32'b100),
	.out(PCplus4_ID)
    );

   //3
   zero_extender_LUI ZE_LUI_AUI(
	.ZE1_in(ZE_imm_LUI_AUI),
	.ZE1_out(ZE_data_ID)
    );

   //4
   sign_extender_load_JALR SE_load_JALR(
        .SE1_in(SE_imm_load_JALR),
        .SE1_out(immediate_load_SE_ID)
    );

   //5
   sign_extender_br_str SE_branch_store(
        .SE2_in(SE_imm_br_str),
        .SE2_out(immediate_branch_store_SE_ID),
	.SE2_ctrl(SE2_Ctrl_ID)      
    );
   
   //6
   sign_extender_JAL SE_JAL(
        .SE3_in(SE_imm_JAL),
	.SE3_out(JAL_SE_ID)
    );
   
   //7
   mux_4x1 ALU_mux(
	.in0(ALU_mux_out),
	.in1(RAddr2_EX), //might not need
        .in2(immediate_load_SE_EX),
        .in3(immediate_branch_store_SE_EX),
	.sel(ALU_Mux_EX),  
	.out(ALU_src2)
    );
   
   //8
   mux_4x1 WD_mux(     
	.in0(ALU_result),
	.in1(ZE_data_EX),
        .in2(PCplus4_EX),
	.in3(PCplus4_imm_prime_EX),
        .sel(WD_Mux_WB),
        .out(write_data_reg_EX)
    ); 

   //9
   mux_4x1 Branch_mux(
	.in0(ALU_res_zLSB),
	.in1(ZE_data_ID),
	.in2(branch_store_shift), //ask if we need
	.in3(JAL_SE_ID_shift),
	.out(PC_imm),
        .sel(Branch_Mux_ID)		    
    );

   //10
   sum jump_sum(
	.in0(PC_imm),
	.in1(PCprime),
        .out(PCplus4_imm_prime_ID)
    );
   
   //11
   zero_extender_CSRW ZE_CSRW(
       .ZE2_in(csrwi_imm_EX),
       .ZE2_out(csrwi_zimm)			      
    );
   
   //12
   mux_3x1 CSRW_mux(
	.in0(32'b0),
	.in1(RF_data1_EX),
        .in2(csrwi_zimm),	    
        .out(csrw_result),
        .sel(CSRW_Mux_EX)
    );
   
   //13
   sign_extender_DM SE_DM(
        .SE4_in(DM_data),
        .RByteEn_DM(funct_WB),
        .SE4_out(DM_data_SM),
        .byte_sel(dcache_addr_prev[1:0]) 			  
			  
    );
   
   //14
   zero_extender_DM ZE_DM(
	.ZE3_in(DM_data),
        .RByteEn_DM(funct_WB),
        .ZE3_out(DM_data_ZE),
	.byte_sel(dcache_addr_prev[1:0])
			  
    );

   //15
   mux_3x1 DM_mux(
        //.in0(ALU_result),
        .in0(DM_data),
        .in1(DM_data_SM),
        .in2(DM_data_ZE),
	.sel(DM_Mux_WB),		  
	.out(DM_ALU_data_WB)
    );

   //16
   ALU ALU1(
        .A(ALU_src1), 
	.B(ALU_src2),
        .ALUop(ALUop),
        .Out(ALU_result)	 
    );
   

   //17
   ALUdec ALUdec1(
	.opcode(opcode_EX), //problem?
        .funct(funct_EX), //problem?
	.add_rshift_type(add_rshift_type_EX), //problem?
	.ALUop(ALUop)
    );

   //18
   regfile regfile1(.clk(clk),
		    .reset(reset),
		    .RAddr1_RF(RAddr1_ID), 
		    .RAddr2_RF(RAddr2_ID), 
		    .WAddr_RF(WAddr_WB), 
		    .WrEn_RF(WrEn_RF_WB),
		    .WD_RF(data_write), 
		    .RD1_RF(RF_data1_ID), 
		    .RD2_RF(RF_data2_ID)
    );
		     

   //19
   control control1( .clk(clk),
		     .last_opcode(last_opcode),
		     .last_funct3(last_funct3), 
		     .take_branch(take_branch),
		     .write_data_mux(write_data_mux),
		     .PC_Mux(PC_Mux_ID), 
		     .WrEn_RF(WrEn_RF_ID), 
		     .WD_Mux(WD_Mux_EX), 
		     .ALU_Mux(ALU_Mux_EX), 
		     .CSRW_Mux(CSRW_Mux_EX), 
		     .Branch_Mux(Branch_Mux_ID),
		     .RByteEn_DM(RByteEn_DM_EX), 
		     .WByteEn_DM(WByteEn_DM_EX),
		     .DM_Mux(DM_Mux_ID), 
		     .SE2_Ctrl(SE2_Ctrl_ID),
		     .rd(WAddr_ID),
		     .rs1(RAddr1_ID),
		     .rs2(RAddr2_ID),
		     .ALU_hazmux1_sel(ALU_hazmux1_sel_ID),
		     .ALU_hazmux2_sel(ALU_hazmux2_sel_ID),
		     .PCplus4_Mux_ctrl(PCplus4_Mux_ctrl_ID),
		     .PCprime(PCprime),
		     .ALU_result_mux_ctrl(ALU_result_mux_ctrl_ID),
		     .Branch_comp_mux1_ctrl(Branch_comp_mux1_ctrl),
		     .Branch_comp_mux2_ctrl(Branch_comp_mux2_ctrl),
		     .JALR_comparator_mux_ctrl(JALR_comparator_mux_ctrl),
		     .DM_data_offset(ALU_result[1:0]),
		     .data_byte_in(data_byte_in),
		     .data_byte_out(data_byte_out)
		     //.PC_Mux_ID(PC_MuxID)		     
		    
    );
    
   //20
   pipeline1 pipeline(.clk(clk),
		      .reset(reset),
		      .csrwi_imm_ID(csrwi_imm_ID),
		      .immediate_branch_store_SE_ID(immediate_branch_store_SE_ID),
		      .immediate_branch_store_SE_EX(immediate_branch_store_SE_EX),
		      .RF_data1_ID(RF_data1_ID), 
		      .RF_data2_ID(RF_data2_ID), 
		      .RAddr2_ID(RAddr2_ID),
		      .WAddr_ID(WAddr_ID),
		      .write_data_reg_EX(write_data_reg_EX), 
		      .csrwi_imm_EX(csrwi_imm_EX),
		      .WAddr_WB(WAddr_WB),
		      .RF_data1_EX(RF_data1_EX), 
		      .RF_data2_EX(RF_data2_EX), 
		      .RAddr2_EX(RAddr2_EX), 
		      .data_write(data_write),
		      .ZE_data_ID(ZE_data_ID), 
		      .immediate_load_SE_ID(immediate_load_SE_ID), 
		      .JAL_SE_ID(JAL_SE_ID),
		      .dcache_addr(dcache_addr),
		      .dcache_addr_prev(dcache_addr_prev),
		      .PCplus4_ID(PCplus4_ID), 
		      .ZE_data_EX(ZE_data_EX), 
		      .immediate_load_SE_EX(immediate_load_SE_EX), 
		      .JAL_SE_EX(JAL_SE_EX), 
		      .PCplus4_EX(PCplus4_EX), 
		      //.DM_ALU_data_WB(DM_ALU_data_WB), 
		      .PCplus4_imm_prime_ID(PCplus4_imm_prime_ID),
		      .PCplus4_imm_prime_EX(PCplus4_imm_prime_EX), 
		      //.DM_ALU_data_EX(DM_ALU_data_EX), 
		      //.PCplus4_imm_ID(PCplus4_imm_ID), 
		      .DM_write(DM_write),
		      .PC(PC), 
		      .csrw_result(csrw_result),
		      .PCprime(PCprime),
		      .PCprime_EX(PCprime_EX),
		      .tohost(tohost), 
		      .WrEn_RF_ID(WrEn_RF_ID), 
		      .WD_Mux_EX(WD_Mux_EX), 
		      .RByteEn_DM_EX(RByteEn_DM_EX),
		      .WByteEn_DM_EX(WByteEn_DM_EX), 
		      //.DM_Mux_EX(DM_Mux_EX),
		      .WrEn_RF_WB(WrEn_RF_WB), 
		      .WD_Mux_WB(WD_Mux_WB), 
		      .RByteEn_DM_WB(RByteEn_DM_WB),
		      .WByteEn_DM_WB(WByteEn_DM_WB), 
		      .DM_Mux_WB(DM_Mux_WB),
		      .DM_Mux_ID(DM_Mux_ID),
		      .PC_Mux_IDplus1(PC_Mux_IDplus1),
		      .opcode_EX(opcode_EX),
		      .opcode_ID(opcode_ID),
		      .funct_EX(funct_EX),
		      .funct_ID(funct_ID),
		      .funct_WB(funct_WB),
		      .add_rshift_type_EX(add_rshift_type_EX),
		      .write_data_reg_ID_prev(write_data_reg_ID_prev),
		      .add_rshift_type_ID(add_rshift_type_ID),
		      .ALU_hazmux2_sel_ID(ALU_hazmux2_sel_ID),
		      .ALU_hazmux1_sel_ID(ALU_hazmux1_sel_ID),
		      .ALU_hazmux2_sel_EX(ALU_hazmux2_sel_EX),
		      .ALU_hazmux1_sel_EX(ALU_hazmux1_sel_EX),
		      .Branch_Mux_ID(Branch_Mux_ID),
		      .Branch_Mux_EX(Branch_Mux_EX),
		      .PCplus4_Mux_ctrl_ID(PCplus4_Mux_ctrl_ID),
		      .PCplus4_Mux_ctrl_EX(PCplus4_Mux_ctrl_EX),
		      .ALU_result_mux_ctrl_ID(ALU_result_mux_ctrl_ID),
		      .ALU_result_mux_ctrl_EX(ALU_result_mux_ctrl_EX),
		      .write_data_reg_ID(write_data_reg_ID)
		
     );

   //21
   mux_3x1 ALU_hazmux1(.in0(RF_data1_EX),
		       .in1(data_write),
		       .in2(write_data_reg_ID_prev),
		       .sel(ALU_hazmux1_sel_EX),
		       .out(ALU_src1)
		       );

   //22
   mux_3x1 ALU_hazmux2(.in0(RF_data2_EX),
		       .in1(data_write),
		       .in2(write_data_reg_ID_prev),
		       .sel(ALU_hazmux2_sel_EX),
		       .out(ALU_mux_out)
		       );
   //23
   mux_2x1 PCplus4_Mux(
		    .in0(PCprime),
		    .in1(PCplus4_ID),		    
		    .out(PC_rel),
		    .sel(PCplus4_Mux_ctrl_ID)
    );

  /* //24
   mux_2x1 ALU_result_mux(
		    .in0(ALU_res_zLSB),
		    .in1(ALU_result),		    
		    .out(Branch_mux_in0),
		    .sel(ALU_result_mux_ctrl_EX)
    );*/

   //25
   mux_3x1 Branch_rs1_Mux(
		       .in0(RF_data1_ID),
		       .in1(write_data_reg_EX),
		       .in2(data_write),
		       .sel(Branch_comp_mux1_ctrl),
		       .out(branch_rs1)
		       );
   //26
   mux_3x1 Branch_rs2_Mux(
		    .in0(RF_data2_ID),
		    .in1(write_data_reg_EX),
		    .in2(data_write),
		    .out(branch_rs2),
		    .sel(Branch_comp_mux2_ctrl)
    );

   //27
   comparator_sum Branch_comparator(
		    .rs1(branch_rs1),
		    .rs2(rs2_or_JALRimm),
		    .opcode(opcode_ID),
		    .funct(funct_ID),
		    .out(compare_result)
    ); 

   //28
   mux_2x1 JALR_comparator_mux(
		    .in0(branch_rs2),
		    .in1(immediate_load_SE_ID),		    
		    .out(rs2_or_JALRimm),
		    .sel(JALR_comparator_mux_ctrl)
    );
		  
   //29
   mux_2x1 Load_or_WD_Mux(
		    .in0(write_data_reg_ID),
		    .in1(DM_ALU_data_WB),
		    .sel(write_data_mux),
		    .out(data_write)
			  
    );  
			  
   
endmodule
