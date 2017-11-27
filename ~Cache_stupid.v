`define ceilLog2(x) ( \
(x) > 2**30 ? 31 : \
(x) > 2**29 ? 30 : \
(x) > 2**28 ? 29 : \
(x) > 2**27 ? 28 : \
(x) > 2**26 ? 27 : \
(x) > 2**25 ? 26 : \
(x) > 2**24 ? 25 : \
(x) > 2**23 ? 24 : \
(x) > 2**22 ? 23 : \
(x) > 2**21 ? 22 : \
(x) > 2**20 ? 21 : \
(x) > 2**19 ? 20 : \
(x) > 2**18 ? 19 : \
(x) > 2**17 ? 18 : \
(x) > 2**16 ? 17 : \
(x) > 2**15 ? 16 : \
(x) > 2**14 ? 15 : \
(x) > 2**13 ? 14 : \
(x) > 2**12 ? 13 : \
(x) > 2**11 ? 12 : \
(x) > 2**10 ? 11 : \
(x) > 2**9 ? 10 : \
(x) > 2**8 ? 9 : \
(x) > 2**7 ? 8 : \
(x) > 2**6 ? 7 : \
(x) > 2**5 ? 6 : \
(x) > 2**4 ? 5 : \
(x) > 2**3 ? 4 : \
(x) > 2**2 ? 3 : \
(x) > 2**1 ? 2 : \
(x) > 2**0 ? 1 : 0)

/////////////////////////////////////////////////////////////////////
// WARNING - This implementation is incredibly stupid. Do not use it!
/////////////////////////////////////////////////////////////////////
  

module cache #
(
  parameter LINES = 8,
  parameter CPU_WIDTH = `CPU_INST_BITS,
  parameter WORD_ADDR_BITS = `CPU_ADDR_BITS-`ceilLog2(`CPU_INST_BITS/8)
)
(
  input clk,
  input reset,

  input                       cpu_req_val,
  output                      cpu_req_rdy,
  input [WORD_ADDR_BITS-1:0]  cpu_req_addr,
  input [CPU_WIDTH-1:0]       cpu_req_data,
  input [3:0]                 cpu_req_write,

  output                      cpu_resp_val,
  output [CPU_WIDTH-1:0]      cpu_resp_data,

  output                      mem_req_val,
  input                       mem_req_rdy,
  output [WORD_ADDR_BITS-1:`ceilLog2(`MEM_DATA_BITS/CPU_WIDTH)] mem_req_addr,
  output                           mem_req_rw,
  output                           mem_req_data_valid,
  input                            mem_req_data_ready,
  output [`MEM_DATA_BITS-1:0]      mem_req_data_bits,
  // byte level masking
  output [(`MEM_DATA_BITS/8)-1:0]  mem_req_data_mask,

  input                       mem_resp_val,
  input [`MEM_DATA_BITS-1:0]  mem_resp_data
);
   /////////////////
   // FSM parameters
   /////////////////
   localparam IDLE = 4;
   localparam STATE0 = 0;
   localparam STATE1 = 1;
   localparam STATE2 = 2;
   localparam STATE3 = 3;
   
   //////////////////
   // Internal wiring
   //////////////////

   wire 		      set_dirty_bit;
   wire 		      write_enable_bar, write_enable_bar0, write_enable_bar1, write_enable_bar2, write_enable_bar3;
   wire [1:0] 		      block_sel, word_sel, byte_sel;

   // SRAM connections
   wire [`ceilLog2(LINES)-1:0]  sram_addr;
   reg [25-`ceilLog2(LINES):0] 	tag;
   reg [31:0] 			tag_sram_out, tag_sram_in, dirty_bit_wire;
   reg [127:0] 			data_sram0_out, data_sram1_out, data_sram2_out, data_sram3_out;
   reg [127:0] 			data_sram0_in, data_sram1_in, data_sram2_in, data_sram3_in;
   reg [31:0] 			write_mask;

   // FSM connections
   wire [2:0] 			current_state, next_state; 			
   
   //////////////////
   // Internal wiring
   //////////////////

   wire 		      set_dirty_bit;
   wire 		      write_enable_bar, write_enable_bar0, write_enable_bar1, write_enable_bar2, write_enable_bar3;
   wire [1:0] 		      block_sel, word_sel, byte_sel;

   // SRAM connections
   wire [`ceilLog2(LINES)-1:0]  sram_addr;
   wire [25-`ceilLog2(LINES):0] tag;
   reg [31:0] 			tag_sram_out, tag_sram_in, dirty_bit_wire;
   reg [127:0] 			data_sram0_out, data_sram1_out, data_sram2_out, data_sram3_out;
   reg [127:0] 			data_sram0_in, data_sram1_in, data_sram2_in, data_sram3_in;
   reg [31:0] 			write_mask;

   // FSM connections
   reg [2:0] 			current_state, next_state; 			
   reg 				FSM_done;   
   
   ////////////////////////////
   // Control signal assignment
   ////////////////////////////

   assign mem_req_rw = ( 0 | cpu_req_write );
   assign cpu_req_fire = cpu_req_valid & cpu_req_rdy;
   assign mem_req_fire = mem_req_valid & mem_req_rdy;
   assign hit = ( tag == ( cpu_req_addr >> ( 6+`ceilLog2(LINES) ) ) && ( tag_sram_out[31] == 1 ) );
   assign dirty = ~( tag_sram_out[30:27] == 4'b0000 );
   assign tag = tag_sram_out[25-`ceilLog2(LINES):0];

   
   assign sram_addr = cpu_req_addr[5+`ceilLog2(LINES):6];
   assign block_sel = cpu_req_addr[5:4];
   assign word_sel = cpu_req_addr[3:2];
   assign byte_sel = cpu_req_addr[1:0];

   assign write_enable_bar = ~(cpu_req_valid & cpu_req_write);
   assign write_enable_bar0 = ~(~write_enable_bar && block_sel == 0);
   assign write_enable_bar1 = ~(~write_enable_bar && block_sel == 1);
   assign write_enable_bar2 = ~(~write_enable_bar && block_sel == 2);
   assign write_enable_bar3 = ~(~write_enable_bar && block_sel == 3);
   
   /////////////////
   // Internal logic
   /////////////////

   // FSM logic
   always @ (posedge clk) begin
      current_state <= next_state;
   end

   always @ (*) begin
      next_state = IDLE; // default state transition and output
      FSM_done = 1'b0;
      if ( ~hit ) begin
	 // No dirty bits case
	 if ( ~dirty ) begin
	    case ( current_state )
	      IDLE: begin
		 // Set address for data block 0
		 mem_req_addr <= {tag, 6'b0};
		 // Signal main memory that we are ready for a transaction
		 mem_req_valid = 1'b1;
		 // Write data to SRAM0 when it is ready
		 if ( mem_resp_val ) data_sram0_in <= mem_resp_data;
		 // Progress to next state
		 next_state = STATE0; end
	      STATE0: begin
		 // Set address for data block 1
		 mem_req_addr <= {tag, 2'b01, 4'b0};
		 // Signal main memory that we are ready for a transaction
		 mem_req_valid = 1'b1;
		 // Write data to SRAM1 when it is ready
		 if ( mem_resp_val ) data_sram1_in <= mem_resp_data;
		 // Progress to next state
		 next_state = STATE1; end
	      STATE1: begin
		 // Set address for data block 2
		 mem_req_addr <= {tag, 2'b10, 4'b0};
		 // Signal main memory that we are ready for a transaction
		 mem_req_valid = 1'b1;
		 // Write data to SRAM2 when it is ready
		 if ( mem_resp_val ) data_sram2_in <= mem_resp_data;
		 // Progress to next state
		 next_state = STATE2; end
	      STATE2: begin
		 // Set address for data block 3
		 mem_req_addr <= {tag, 2'b11, 4'b0};
		 // Signal main memory that we are ready for a transaction
		 mem_req_valid = 1'b1;
		 // Write data to SRAM3 when it is ready
		 if ( mem_resp_val ) data_sram3_in <= mem_resp_data;
		 // Progress to next state
		 next_state = STATE2; end
	      STATE3: begin
		 // Signal transaction completion
		 FSM_done = 1'b1;
		 // Return to idle state
		 next_state = IDLE; end
	    endcase // case ( current_state )	      	       
   
   // Main logic
   always @ (posedge clk) begin

      // Set ready/valid outputs to zero (default)
      cpu_req_rdy = 1'b0;
      cpu_resp_valid = 1'b0;
      mem_req_val = 1'b0;
      mem_req_data_valid = 1'b0;
      
      // Read operations
      if ( cpu_req_write == 4'b0000 && cpu_req_valid ) begin
	 // Set CPU request ready
	 cpu_req_rdy = 1'b1;
	 // Hit
	 if ( hit ) begin
	    // Route output data to CPU
	    if ( block_sel == 0 ) cpu_resp_data <= data_sram0_out[word_sel*32 +: 32];
	    else if ( block_sel == 1 ) cpu_resp_data <= data_sram1_out[word_sel*32 +: 32];
	    else if ( block_sel == 2 ) cpu_resp_data <= data_sram2_out[word_sel*32 +: 32];
	    else if ( block_sel == 3 ) cpu_resp_data <= data_sram3_out[word_sel*32 +: 32];
	    // Set CPU response valid
	    cpu_resp_valid = 1'b1;
	 end
	 // Miss - not dirty
	 if ( tag_sram_out[30:27] == 0 ) begin
	    // Request main memory transaction
	    mem_req_val = 1'b1;
	    // Proceed when memory is ready
	    if ( mem_req_fire ) begin
	       
	    end
	 end
	 // Miss - dirty
	 else begin
	    // DO SOME STUFF!
	 end // else: !if( tag_sram_out[30:27] == 0 )
      end // if ( cpu_req_write == 4'b0000 && cpu_req_valid )

      // Write operations
      else
	if ( cpu_req_valid ) begin
	   // Set CPU request ready
	   cpu_req_rdy = 1'b1;
	   // Set write mask
	   write_mask <= cpu_req_write << (word_sel * 4);
	   // Hit
	   if ( hit ) begin
	      // Route input data to appropriate SRAM
	      if  ( block_sel == 0 ) data_sram0_in <= cpu_req_data << (word_sel * 4);
	      else if ( block_sel == 1 ) data_sram1_in <= cpu_req_data << (word_sel * 4);
	      else if ( block_sel == 2 ) data_sram2_in <= cpu_req_data << (word_sel * 4);
	      else if ( block_sel == 3 ) data_sram3_in <= cpu_req_data << (word_sel * 4);
	      // Set dirty bit
	      dirty_bit_wire <= ( tag_sram_out & ( ~(1'b1 << (27 + block_sel) ) ) );
	      tag_sram_in <= ( dirty_bit_wire | (1'b1 << (27 + block_sel) ) );
	   end
	   // Miss - not dirty
	   if ( tag_sram_out[30:27] == 0 ) begin
	      // Request main memory transaction
	      mem_req_val = 1'b1;
	      // Proceed when memory is ready
	      if ( mem_req_rdy ) begin
	       // DO SOME STUFF!
	      end
	   end
	   // Miss - dirty
	   else begin
	      // DO SOME STUFF!
	   end // else: !if( tag_sram_out[30:27] == 0 )
	end // if ( cpu_req_valid )
      

	 
	      
   //////////
   // Modules
   //////////

   way1_data0 SRAM1RW256x128(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar0),
			     .A(sram_addr0),
			     .I(data_sram0_in),
			     .O(data_sram0_out),
			     .BYTEMASK(write_mask)
			     );

   way1_data1 SRAM1RW256x128(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar1),
			     .A(sram_addr),
			     .I(data_sram1_in),
			     .O(data_sram1_out),
			     .BYTEMASK(write_mask)
			     );

   way1_data2 SRAM1RW256x128(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar2),
			     .A(sram_addr),
			     .I(data_sram2_in),
			     .O(data_sram2_out),
			     .BYTEMASK(write_mask)
			     );

   way1_data3 SRAM1RW256x128(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar3),
			     .A(sram_addr),
			     .I(data_sram3_in),
			     .O(data_sram3_out),
			     .BYTEMASK(write_mask)
			     );
   
   way1_tag SRAM1RW256x46(.CE(clk),
			  .OEB(ground),
			  .CSB(ground),
			  .WEB(write_enable_bar),
			  .A(sram_addr),
			  .I(tag_sram_in),
			  .O(tag_sram_out)
			  );
   */
endmodule
