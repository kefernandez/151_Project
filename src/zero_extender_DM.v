module zero_extender_DM(
    input[31:0] ZE3_in,			
    input[2:0] RByteEn_DM,
    input [1:0] byte_sel,			
    output reg [31:0] ZE3_out	       
);

   //reg [31:0] 	  ZE3_out;
   
   always@(*)begin
      if(RByteEn_DM[1:0] == 2'b0)begin
	 if(byte_sel == 2'b00) ZE3_out <= {24'b0,ZE3_in[7:0]}; //LBU
	 else if(byte_sel == 2'b01) ZE3_out <= {24'b0, ZE3_in[15:8]};
	 else if(byte_sel == 2'b10) ZE3_out <= {24'b0, ZE3_in[23:16]};
	 else ZE3_out <= {24'b0, ZE3_in[31:24]}; end
      else if(RByteEn_DM[1:0] == 2'b01) begin
	  if(byte_sel == 2'b00 || byte_sel == 2'b01) ZE3_out <= {16'b0,ZE3_in[15:0]}; //LH
	  else ZE3_out <= {16'b0,ZE3_in[31:16]}; end
      
      else ZE3_out <= ZE3_in; //LW
      end
				       
endmodule 
 
