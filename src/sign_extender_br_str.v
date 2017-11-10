module sign_extender_br_str(
    input[11:0] SEin,
    input SE2_ctrl,			       
    output [31:0] SEout	       
);
    
   always@(*)begin
      if(SE2_ctrl) SEout <= {{21{SEin[11]}},SEin[0], SEin[10:5],SEin[4:1]};
      else SEout <= {{21{SEin[11]}},SE[10:0]};
   end
 endmodule
