module regfile(input clk,
	       input reset,
	       
	       //////////////
	       // Input ports
	       //////////////
	       
	       // Read and write addresses
	       input [4:0] RAddr1_RF,
	       input [4:0] RAddr2_RF,
	       input [4:0] WAddr_RF,

	       // Write enable input
	       input WrEn_RF,

	       // Write data input
	       input [31:0] WD_RF,

	       ///////////////
	       // Output ports
	       ///////////////

	       // Output data
	       output [31:0] RD1_RF,
	       output [31:0] RD2_RF);

   // Define register file
   reg [31:0] 			 register_file [0:31];

   // Read functionality
   assign RD1_RF = register_file[RAddr1_RF];
   assign RD2_RF = register_file[RAddr2_RF];

   // Write functionality
   integer 			 i;
   always @ (posedge clk) begin
      if (reset) begin
	 for (i = 0; i < 32; i = i+1) begin
	    register_file[i] <= 0;
	 end
      end 
      else begin
	 if (WrEn_RF && WAddr_RF != 0) register_file[WAddr_RF] <= WD_RF;
      end
   end	       
endmodule
	       
