module sign_extender_DM(
    input  [31:0] SE4_in,
    input  [2:0] RByteEn_DM,
    input [1:0] byte_sel,			
    output reg [31:0] SE4_out	       
);

   //reg [31:0] 	  SE4_out;
   
   always@(*)begin
      if(RByteEn_DM[1:0] == 2'b0) begin //LB
	 if(byte_sel == 2'b00) SE4_out <= { { 24{ SE4_in[7]} }, SE4_in[7:0] };
	 else if(byte_sel == 2'b01) SE4_out <= {  { 24{ SE4_in[15]} }, SE4_in[15:8] };
	 else if(byte_sel == 2'b10) SE4_out <= {  { 24{ SE4_in[23]} }, SE4_in[23:16] };
	 else SE4_out <= {  { 24{ SE4_in[31]} }, SE4_in[31:24] };end
      else if(RByteEn_DM[1:0] == 2'b01) begin
	 if(byte_sel == 2'b00 || byte_sel == 2'b01) SE4_out <= {{16{SE4_in[15]}},SE4_in[15:0]}; //LH
	 else SE4_out <= {{16{SE4_in[31]}},SE4_in[31:16]};end
      else SE4_out <= SE4_in; //if LW
      end
				       
endmodule  
