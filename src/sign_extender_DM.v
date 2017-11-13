module sign_extender_DM(
    input  [31:0] SE4_in,
    input  [1:0] RByteEn_DM,			
    output reg [31:0] SE4_out	       
);

   //reg [31:0] 	  SE4_out;
   
   always@(*)begin
      if(RByteEn_DM == 2'b0) SE4_out <= {{25{SE4_in[7]}},SE4_out[6:0]};
      else if(RByteEn_DM == 2'b01) SE4_out <= {{17{SE4_in[15]}},SE4_out[14:0]};
      else if(RByteEn_DM == 2'b10) SE4_out <= SE4_in;
      end
				       
endmodule  
