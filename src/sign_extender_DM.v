module sign_extender_DM(
    input[31:0] SEin,
    input[1:0] SEbyte,			
    output [31:0] SEout	       
);
   always@(*)begin
      if(SEbyte == 2'b0) SEout <= {{25{SEin[7]}},SEout[6:0]};
      else if(SEbyte == 2'b01) SEout <= {{17{SEin[15]}},SEout[14:0]};
      else if(SEbyte == 2'b10) SEout <= SEin;
      end
				       
endmodule  
