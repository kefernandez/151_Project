module regfile(input clk,
	       
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

	       //////////////////
	       // Internal wiring
	       //////////////////

	       // register inputs and outputs
	       reg [31:0] x0_in, x0_out; // is x0_in needed?
	       reg [31:0] x1_in, x1_out;
	       reg [31:0] x2_in, x2_out;
	       reg [31:0] x3_in, x3_out;
	       reg [31:0] x4_in, x4_out;
	       reg [31:0] x5_in, x5_out;
	       reg [31:0] x6_in, x6_out;
	       reg [31:0] x7_in, x7_out;
	       reg [31:0] x8_in, x8_out;
	       reg [31:0] x9_in, x9_out;
	       reg [31:0] x10_in, x10_out;
	       reg [31:0] x11_in, x11_out;
	       reg [31:0] x12_in, x12_out;
	       reg [31:0] x13_in, x13_out;
	       reg [31:0] x14_in, x14_out;
	       reg [31:0] x15_in, x15_out;
	       reg [31:0] x16_in, x16_out;
	       reg [31:0] x17_in, x17_out;
	       reg [31:0] x18_in, x18_out;
	       reg [31:0] x19_in, x19_out;
	       reg [31:0] x20_in, x20_out;
	       reg [31:0] x21_in, x21_out;
	       reg [31:0] x22_in, x22_out;
	       reg [31:0] x23_in, x23_out;
	       reg [31:0] x24_in, x24_out;
	       reg [31:0] x25_in, x25_out;
	       reg [31:0] x26_in, x26_out;
	       reg [31:0] x27_in, x27_out;
	       reg [31:0] x28_in, x28_out;
	       reg [31:0] x29_in, x29_out;
	       reg [31:0] x30_in, x30_out;
	       reg [31:0] x31_in, x31_out;

	       /////////////////
	       // Internal logic
	       /////////////////
	       
	       always @ (posedge clk) begin
	       // set all non-x0 outputs equal to inputs
	       x1_out = x1_in;
	       x2_out = x2_in;
	       x3_out = x3_in;
	       x4_out = x4_in;
	       x5_out = x5_in;
	       x6_out = x6_in;
	       x7_out = x7_in;
	       x8_out = x8_in;
	       x9_out = x9_in;
	       x10_out = x10_in;
	       x11_out = x11_in;
	       x12_out = x12_in;
	       x13_out = x13_in;
	       x14_out = x14_in;
	       x15_out = x15_in;
	       x16_out = x16_in;
	       x17_out = x17_in;
	       x18_out = x18_in;
	       x19_out = x19_in;
	       x20_out = x20_in;
	       x21_out = x21_in;
	       x22_out = x22_in;
	       x23_out = x23_in;
	       x24_out = x24_in;
	       x25_out = x25_in;
	       x26_out = x26_in;
	       x27_out = x27_in;
	       x28_out = x28_in;
	       x29_out = x29_in;
	       x30_out = x30_in;
	       x31_out = x31_in;
	       //end // always @ (posedge clk)


	       // Continuous assignment signal routing

	       // set x0 output to zero always
	       x0_out = 16'h0000;
	       
	       // Register 1 output
	       case (RAddr1_RF)
	       0: RD1_RF = x0_out;
	       1: RD1_RF = x1_out;
	       2: RD1_RF = x2_out;
	       3: RD1_RF = x3_out;
	       4: RD1_RF = x4_out;
	       5: RD1_RF = x5_out;
	       6: RD1_RF = x6_out;
	       7: RD1_RF = x7_out;
	       8: RD1_RF = x8_out;
	       9: RD1_RF = x9_out;
	       10: RD1_RF = x10_out;
	       11: RD1_RF = x11_out;
	       12: RD1_RF = x12_out;
	       13: RD1_RF = x13_out;
	       14: RD1_RF = x14_out;
	       15: RD1_RF = x15_out;
	       16: RD1_RF = x16_out;
	       17: RD1_RF = x17_out;
	       18: RD1_RF = x18_out;
	       19: RD1_RF = x19_out;
	       20: RD1_RF = x20_out;
	       21: RD1_RF = x21_out;
	       22: RD1_RF = x22_out;
	       23: RD1_RF = x23_out;
	       24: RD1_RF = x24_out;
	       25: RD1_RF = x25_out;
	       26: RD1_RF = x26_out;
	       27: RD1_RF = x27_out;
	       28: RD1_RF = x28_out;
	       29: RD1_RF = x29_out;
	       30: RD1_RF = x30_out;
	       31: RD1_RF = x31_out;
	       endcase

	       // Register 2 output
	       case (RAddr2_RF)
	       0:  RD2_RF = x0_out;
	       1:  RD2_RF = x1_out;
	       2:  RD2_RF = x2_out;
	       3:  RD2_RF = x3_out;
	       4:  RD2_RF = x4_out;
	       5:  RD2_RF = x5_out;
	       6:  RD2_RF = x6_out;
	       7:  RD2_RF = x7_out;
	       8:  RD2_RF = x8_out;
	       9:  RD2_RF = x9_out;
	       10: RD2_RF = x10_out;
	       11: RD2_RF = x11_out;
	       12: RD2_RF = x12_out;
	       13: RD2_RF = x13_out;
	       14: RD2_RF = x14_out;
	       15: RD2_RF = x15_out;
	       16: RD2_RF = x16_out;
	       17: RD2_RF = x17_out;
	       18: RD2_RF = x18_out;
	       19: RD2_RF = x19_out;
	       20: RD2_RF = x20_out;
	       21: RD2_RF = x21_out;
	       22: RD2_RF = x22_out;
	       23: RD2_RF = x23_out;
	       24: RD2_RF = x24_out;
	       25: RD2_RF = x25_out;
	       26: RD2_RF = x26_out;
	       27: RD2_RF = x27_out;
	       28: RD2_RF = x28_out;
	       29: RD2_RF = x29_out;
	       30: RD2_RF = x30_out;
	       31: RD2_RF = x31_out;
	       endcase

	       // Register inputs
	      // always @ (posedge clk) begin
	       //(WrEn & WAddr == 0) ? x0_in = WD_RF : x0_in = x0_out; // this line seems unnecessary
	       (WrEn & WAddr == 1) ? x1_in = WD_RF : x1_in <= x1_out;
	       (WrEn & WAddr == 2) ? x2_in = WD_RF : x2_in <= x2_out;
	       (WrEn & WAddr == 3) ? x3_in = WD_RF : x3_in <= x3_out;
	       (WrEn & WAddr == 4) ? x4_in = WD_RF : x4_in <= x4_out;
	       (WrEn & WAddr == 5) ? x5_in = WD_RF : x5_in <= x5_out;
	       (WrEn & WAddr == 6) ? x6_in = WD_RF : x6_in <= x6_out;
	       (WrEn & WAddr == 7) ? x7_in = WD_RF : x7_in <= x7_out;
	       (WrEn & WAddr == 8) ? x8_in = WD_RF : x8_in <= x8_out;
	       (WrEn & WAddr == 9) ? x9_in = WD_RF : x9_in <= x9_out;
	       (WrEn & WAddr == 10) ? x10_in = WD_RF : x10_in <= x10_out;
	       (WrEn & WAddr == 11) ? x11_in = WD_RF : x11_in <= x11_out;
	       (WrEn & WAddr == 12) ? x12_in = WD_RF : x12_in <= x12_out;
	       (WrEn & WAddr == 13) ? x13_in = WD_RF : x13_in <= x13_out;
	       (WrEn & WAddr == 14) ? x14_in = WD_RF : x14_in <= x14_out;
	       (WrEn & WAddr == 15) ? x15_in = WD_RF : x15_in <= x15_out;
	       (WrEn & WAddr == 16) ? x16_in = WD_RF : x16_in <= x16_out;
	       (WrEn & WAddr == 17) ? x17_in = WD_RF : x17_in <= x17_out;
	       (WrEn & WAddr == 18) ? x18_in = WD_RF : x18_in <= x18_out;
	       (WrEn & WAddr == 19) ? x19_in = WD_RF : x19_in <= x19_out;
	       (WrEn & WAddr == 20) ? x20_in = WD_RF : x20_in <= x20_out;
	       (WrEn & WAddr == 21) ? x21_in = WD_RF : x21_in <= x21_out;
	       (WrEn & WAddr == 22) ? x22_in = WD_RF : x22_in <= x22_out;
	       (WrEn & WAddr == 23) ? x23_in = WD_RF : x23_in <= x23_out;
	       (WrEn & WAddr == 24) ? x24_in = WD_RF : x24_in <= x24_out;
	       (WrEn & WAddr == 25) ? x25_in = WD_RF : x25_in <= x25_out;
	       (WrEn & WAddr == 26) ? x26_in = WD_RF : x26_in <= x26_out;
	       (WrEn & WAddr == 27) ? x27_in = WD_RF : x27_in <= x27_out;
	       (WrEn & WAddr == 28) ? x28_in = WD_RF : x28_in <= x28_out;
	       (WrEn & WAddr == 29) ? x29_in = WD_RF : x29_in <= x29_out;
	       (WrEn & WAddr == 30) ? x30_in = WD_RF : x30_in <= x30_out;
	       (WrEn & WAddr == 31) ? x31_in = WD_RF : x31_in <= x31_out;
	       end
	       
endmodule
	       
