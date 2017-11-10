module sign_extender_load_JALR(
    input[11:0] SEin,
    output [31:0] SEout	       
);

   assign SEout = {{21{SEin[11]}}, SEin[10:0]};
   
endmodule  
