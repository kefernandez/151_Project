module zero_extender_DM(
    input[31:0] ZEin,
    input[1:0] RByteEn_DM,			
    output [31:0] ZEout	       
);
   always@(*)begin
      if(RByteEn_DM == 2'b0) SEout <= {25'b0,SEout[7:0]};
      else if(RByteEn_DM == 2'b01) SEout <= {17'b0,SEout[15:0]};
      else if(RByteEn_DM == 2'b10) SEout <= SEin;
      end
				       
endmodule  
