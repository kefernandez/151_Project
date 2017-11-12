module sign_extender_br_str(
    input[11:0] SE2_in,
    input SE2_ctrl,			       
    output [31:0] SE2_out	       
);

   reg [31:0] 	  SE2_out;
    
   always@(*)begin
      if(SE2_ctrl) SE2_out <= {{21{SE2_in[11]}},SE2_in[0], SE2_in[10:5],SE2_in[4:1]};
      else SE2_out <= {{21{SE2_in[11]}},SE2_in[10:0]};
   end
 endmodule
