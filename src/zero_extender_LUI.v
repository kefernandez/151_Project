module zero_extender_LUI(
    input[19:0] ZEin,
    output [31:0] ZEout	       
);
   
   assign ZEout = {ZEin,12'b0};
   
endmodule  
