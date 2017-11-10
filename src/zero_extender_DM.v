module zero_extender_DM(
    input[31:0] ZEin,
    input[1:0] ZEbyte,			
    output [31:0] ZEout	       
);
   always@(*)begin
      if(ZEbyte == 2'b0) SEout <= {25'b0,SEout[7:0]};
      else if(SEbyte == 2'b01) SEout <= {17'b0,SEout[15:0]};
      else if(SEbyte == 2'b10) SEout <= SEin;
      end
				       
endmodule  
