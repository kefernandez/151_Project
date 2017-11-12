module zero_extender_LUI(
    input[19:0] ZE1_in,
    output [31:0] ZE1_out	       
);
   
   assign ZE1_out = {ZE1_in,12'b0};
   
endmodule  
