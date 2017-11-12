module sign_extender_JAL(
    input[19:0] SE3_in,
    output [31:0] SE3_out	       
);
   
   assign  SE3_out = {{13{SE3_in[19]}},SE3_in[18:0]};
   
endmodule  
