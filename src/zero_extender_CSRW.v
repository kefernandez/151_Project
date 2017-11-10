module zero_extender_CRSW(
    input[4:0] ZEin,
    output [31:0] ZEout	       
);
   
   assign ZEout = {27'b0,ZEin};
   
endmodule  
