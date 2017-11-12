
module Riscv141(
    input clk,
    input reset,

    // Memory system ports
    output [31:0] dcache_addr,
    output [31:0] icache_addr,
    output [3:0] dcache_we,
    output dcache_re,
    output icache_re,
    output [31:0] dcache_din,
    input [31:0] dcache_dout,
    input [31:0] icache_dout,
    input stall,
    output [31:0] csr

);
   //PC related wires
   wire [31:0] PC, PCprime, PCplus4_ID, PCplus4_EX, PCplus4_imm_WB, 
   wire [31:0] PC_imm, PCplus4_imm_prime_EX, 	       
   
   assign i_cache_addr = PC;
	       
   //Reg file related wires
   wire [31:0] RAddr1_ID, RAddr2_ID, WAddr_ID, //coming from IM cache - need assign statements
   wire [31:0] write_data_reg_ID, RF_data1_ID, RF_data2_ID, //to and from reg file
   wire [31:0] RF_data1_EX, RF_data2_EX, RAddr2_EX, write_data_reg_EX,

   assign RAddr1 = icache_dout[19:15];
   assign RAddr2 = icache_dout[24:20];
   assign WAddr_ID = icache_dout[11:7];

   //csrw wires
   wire [4:0] csrwi_imm_ID, csrwi_imm_EX, 
   wire [31:0] csrwi_zimm,csrw_result, tohost,
   assign csrwi_imm_ID = icache_dout[19:15];
   

   //Immediate related wires
   wire [31:0] ZE_imm_LUI_AUI, SE_imm_load_JALR, SE_imm_br_str, SE_imm_br_str_piped, SE_imm_JAL,
   wire [31:0] ZE_data_ID, immediate_load_SE_ID, immediate_branch_store_SE_ID, JAL_SE_ID,
   wire [31:0] ZE_data_EX, immediate_load_SE_EX,immediate_branch_store_SE_EX, JAL_SE_EX,
   wire [31:0] branch_store_shift,JAL_SE_EX_shift,     
	       
   assign ZE_imm_LUI_AUI = icache_dout[31:12];
   assign SE_imm_Load_JALR = icache_dout[31:20];
   assign SE_imm_br_str = {icache_dout[31:25],icache_dout[11:7]};
   assign SE_imm_JAL = {icache_dout[31],icache_dout[19:12],icache_dout[20],icache_dout[30:21]};
   
   assign branch_store_shift = immediate_branch_store_SE_EX << 1;
   assign JAL_SE_EX_shift = JAL_SE_EX << 1;
   
   //ALU wires
   wire [31:0] ALU_src2, ALU_result, ALU_res_zLSB
   assign ALU_res_zLSB = {ALU_result[31:1],1'b0};
	       
   //DM wires
   wire [31:0] DM_write, DM_data, DM_data_SM, DM_data_ZM, DM_ALU_data_WB, DM_ALU_data_WB	       
	       

  
   //controls - need from Russell
   wire [6:0]  opcode, funct7;
   wire [2:0] funct;
   wire [3:0] ALU_op;
   wire add_rshift_type;
   output reg [3:0] ALUop;

   assign opcode = icache_dout[6:0];
   assign funct = icache_dout[14:12];
   assign funct7 = icache_dout[31:25];
   assign add_rshift_type = icache_dout[30];
   
   
 	  
    wire [0:0] datapath_contents;
    wire [0:0]   dpath_controls_i;
    wire [0:0]  exec_controls_x;
    wire [0:0]   hazard_controls;
   

    controller ctrl(
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
    );




   //1
   mux_2x1 PC_mux( 
	.in0(PCplus4_ID),
	.in1(PCplus4_imm_WB),
        .sel(),
        .out(PC)
    );

   //2
   sum PC_sum(
	.in0(PC_prime),
	.in1(32'b100),
	.out(PCplus4_ID)
    );

   //3
   zero_extender_LUI_JAL ZE_LUI_AUI(
	.ZE1_in(ZE_imm_LUI_AUI),
	.ZE1_out(ZE_data_ID)
    );

   //4
   sign_extender_load_JALR SE_load_JALR(
        .SE1_in(SE_imm_load_JALR),
        .SE1_out(immediate_load_ID)
    );

   //5
   sign_extender_br_str SE_branch_store(
        .SE2_in(SE_imm_br_str_piped),
        .SE2_out(immediate_branch_store_ID),
	.SE2_ctrl()      
    );
   
   //6
   sign_extender_JAL SE_JAL(
        .SE3_in(SE_imm_JAL),
	.SE3_out(JAL_SE_ID)
    );
   
   //7
   mux_4x1 ALU_mux(
	.in0(RF_data2_EX),
	.in1(RAddr2_EX), //might not need
        .in2(immediate_load_SE_EX),
        .in3(immediate_branch_store_SE_EX)
	.sel(),  
	.out(ALU_src2)
    );
   
   //8
   mux_3x1 WD_mux(     
	.in0(DM_ALU_data_EX),
	.in1(ZE_data_EX),
        .in2(PCplus4_imm_EX),
        .sel(),
        .out(write_data_reg_EX)
    ); 

   //9
   mux_4x1 Branch_mux(
	.in0(ALU_res_zLSB),
	.in1(ZE_data_EX),
	.in2(branch_store_shift), //ask if we need
	.in3(JAL_SE_EX_shift),
	.out(PC_imm),
        .sel()		    
    );

   //10
   sum jump_sum(
	.in0(PC_imm),
	.in1(PCplus4_EX),
        .out(PCplus4_imm_prime_EX)
    );
   
   //11
   zero_extender_CSRW ZE_CSRW(
       .ZE2_in(csrwi_imm_EX),
       .ZE2_out(csrwi_zimm)			      
    );
   
   //12
   mux_2x1 CSRW_mux(
	.in0(RF_data1_EX),
        .in1(csrwi_zimm),		    
        .out(csrw_result),
        .sel()
    );
   
   //13
   sign_extender_DM SE_DM(
        .SE4_in(DM_data),
        .RByteEn_DM(),
        .SE4_out(DM_data_SM)
    );
   
   //14
   zero_extender_DM ZE_DM(
	.ZE3_in(DM_data),
        .RByteEn_DM(),
        .ZE3_out(DM_data_ZE)
    );

   //15
   mux_4x1 DM_mux(
        .in0(ALU_result),
        .in1(DM_data),
        .in2(DM_data_SM),
        .in3(DM_data_ZE),
	.sel(),		  
	.out(DM_ALU_data_WB)
    );

   //16
   ALU ALU1(
        .A(RF_data1_EX), 
	.B(RF_data2_EX),
        .ALUop(ALUop),
        .Out(ALU_result)	 
    );
   

   //17
   ALUdec ALUdec1(
	.opcode(opcode),
        .funct(funct),
	.add_rshift_type(add_rshift_type),
	.ALUop(ALUop)
    ); 

   //1
   pipeline1 pipeline(
        .clk(clk),
        .csrwi_imm_ID(csrwi_imm_ID), .RF_data1_ID(RF_data1_ID), .RF_data2_ID(RF_data2_ID), .RAddr2_ID(RAddr2_ID),  .write_data_reg_EX(write_data_reg_EX), 
        .csrwi_imm_EX(csrwi_imm_EX), .RF_data1_EX(RF_data1_EX), .RF_data2_EX(RF_data2_EX), .RAddr2_EX(RAddr2_EX), .write_data_reg_ID(write_data_reg_ID),
        .ZE_data_ID(ZE_data_ID), .immediate_load_SE_ID(immediate_load_SE_ID), .SE_imm_br_str(SE_imm_br_str), .JAL_SE_ID(JAL_SE_ID), .PCplus4_ID(PCplus4_ID), 
        .ZE_data_EX(ZE_data_EX), .immediate_load_SE_EX(immediate_load_SE_EX), .SE_imm_br_str_piped(SE_imm_br_str_piped), .JAL_SE_EX(JAL_SE_EX), .PCplus4_EX(PCplus4_EX), 
        .DM_ALU_data_WB(DM_ALU_data_WB), .PCplus4_imm_prime_EX(PCplus4_imm_prime_EX),
        .DM_ALU_data_EX(DM_ALU_data_EX), .PCplus4_imm_WB(PCplus4_imm_WB),
        .PC(PC), .csrw_result(csrw_result),
        .PCprime(PCprime), .tohost(tohost) 
    );
   
		  

endmodule
