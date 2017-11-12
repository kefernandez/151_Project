module zero_extender_DM(
    input[31:0] ZE3_in,
    input[1:0] RByteEn_DM,			
    output [31:0] ZE3_out	       
);

   reg [31:0] 	  ZE3_out;
   
   always@(*)begin
      if(RByteEn_DM == 2'b0) ZE3_out <= {25'b0,ZE3_in[7:0]};
      else if(RByteEn_DM == 2'b01) ZE3_out <= {17'b0,ZE3_in[15:0]};
      else if(RByteEn_DM == 2'b10) ZE3_out <= ZE3_in;
      end
				       
endmodule  
