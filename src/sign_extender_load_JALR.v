module sign_extender_load_JALR(
    input[11:0] SE1_in,
    output [31:0] SE1_out	       
);

   assign SE1_out = {{21{SE1_in[11]}}, SE1_in[10:0]};
   
endmodule  
