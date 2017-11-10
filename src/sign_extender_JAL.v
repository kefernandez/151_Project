module sign_extender_JAL(
    input[19:0] SEin,
    output [31:0] SEout	       
);
   assign  SEout = {{13{SEin[19]}},SE[18:0]};
   
endmodule  
