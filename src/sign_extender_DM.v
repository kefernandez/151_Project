module sign_extender_DM(
    input[31:0] SEin,
    input[1:0] RByteEn_DM,			
    output [31:0] SEout	       
);
   always@(*)begin
      if(RByteEn_DM == 2'b0) SEout <= {{25{SEin[7]}},SEout[6:0]};
      else if(RByteEn_DM == 2'b01) SEout <= {{17{SEin[15]}},SEout[14:0]};
      else if(RByteEn_DM == 2'b10) SEout <= SEin;
      end
				       
endmodule  
