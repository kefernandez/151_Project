module zero_extender_CSRW(
    input[4:0] ZE2_in,
    output [31:0] ZE2_out	       
);
   
   assign ZE2_out = {27'b0,ZE2_in};
   
endmodule  
