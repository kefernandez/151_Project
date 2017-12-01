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
  output reg                  cpu_req_rdy,
  input [WORD_ADDR_BITS-1:0]  cpu_req_addr,
  input [CPU_WIDTH-1:0]       cpu_req_data,
  input [3:0]                 cpu_req_write,

  output reg                     cpu_resp_val,
  output reg [CPU_WIDTH-1:0]      cpu_resp_data,

  output reg                     mem_req_val,
  input                       mem_req_rdy,
  output reg [WORD_ADDR_BITS-1:`ceilLog2(`MEM_DATA_BITS/CPU_WIDTH)] mem_req_addr,
  output                           mem_req_rw,
  output reg                       mem_req_data_valid,
  input                            mem_req_data_ready,
  output reg [`MEM_DATA_BITS-1:0]      mem_req_data_bits,
  // byte level masking
  output [(`MEM_DATA_BITS/8)-1:0]  mem_req_data_mask,

  input                       mem_resp_val,
  input [`MEM_DATA_BITS-1:0]  mem_resp_data
);
   /////////////////
   // FSM parameters
   /////////////////
   localparam IDLE = 0;
   localparam READ = 1;
   localparam WRITE = 2;
   localparam LOAD0 = 3;
   localparam LOAD1 = 4;
   localparam LOAD2 = 5;
   localparam LOAD3 = 6;
   localparam WRITE_BACK0 = 7;
   localparam WRITE_BACK1 = 8;
   localparam WRITE_BACK2 = 9;
   localparam WRITE_BACK3 = 10;
		      
   
   //////////////////
   // Internal wiring
   //////////////////

   // Parsed byte select values
   wire [1:0] 		        block_sel, word_sel, byte_sel;

   // SRAM connections
   wire [7:0] 			sram_addr;
   wire [25-`ceilLog2(LINES):0] tag; 
   wire [31:0] 			tag_sram_out;
   reg [31:0] 			tag_sram_in, dirty_bit_wire;
   reg [15:0] 			write_mask;
   wire [127:0] 		data_sram0_out, data_sram1_out, data_sram2_out, data_sram3_out;
   reg [127:0] 			data_sram0_in, data_sram1_in, data_sram2_in, data_sram3_in;
   wire 			write_enable_bar;
   reg 				write_enable_bar0, write_enable_bar1, write_enable_bar2, write_enable_bar3;
   
   // FSM registers
   reg [3:0] 			current_state, next_state;
   reg [25:0] 			load_addr; 			
   
   ////////////////////////////
   // Control signal assignment
   ////////////////////////////

   assign mem_req_rw = ( 0 | cpu_req_write );
   assign hit = ( tag == ( cpu_req_addr >> ( 6+`ceilLog2(LINES) ) ) && ( tag_sram_out[31] == 1 ) && cpu_req_val );
   assign dirty = ~( tag_sram_out[30:27] == 4'b0000 );
   assign tag = tag_sram_out[25-`ceilLog2(LINES):0];
   assign mem_req_data_mask = 16'hFFFF;

   // Address connections
   assign sram_addr = cpu_req_addr[5+`ceilLog2(LINES):6];
   assign block_sel = cpu_req_addr[5:4];
   assign word_sel = cpu_req_addr[3:2];
   assign byte_sel = cpu_req_addr[1:0];

   // SRAM write connection
   assign write_enable_bar = ~( (cpu_req_val & cpu_req_write) | mem_resp_val );
   
   /////////////////
   // Internal logic
   /////////////////

   // FSM state transition (positive clock edge)
   always @ (posedge clk) begin
      if (reset) current_state <= IDLE;
      else current_state <= next_state;
      // Capture load address
      if ( current_state == IDLE ) load_addr = cpu_req_addr[29:6];
   end

   // FSM encoding
   always @ (*) begin
      // Default transition - remain in current state
      next_state = current_state;
      // Default outputs - set all to zero
      cpu_req_rdy = 1'b0;
      cpu_resp_val = 1'b0;
      mem_req_val = 1'b0;
      mem_req_data_valid = 1'b0;
      
      // Default write enable bars - set all to one
      write_enable_bar0 = 1'b1;
      write_enable_bar1 = 1'b1;
      write_enable_bar2 = 1'b1;
      write_enable_bar3 = 1'b1;
      
      case ( current_state )
	IDLE: begin
	   if ( cpu_req_val && ~reset ) begin
	      // Set ready bit
	      cpu_req_rdy = 1'b1;
	      // Hit - read
	      if ( hit & ~mem_req_rw ) next_state = READ;
	      // Hit - write
	      if ( hit & mem_req_rw ) next_state = WRITE;
	      // Miss - not dirty
	      if ( ~hit & ~dirty ) next_state = LOAD0;
	      // Miss - dirty bit 0 set
	      if ( ~hit & tag_sram_out[30:27] == 4'bxxx1 ) next_state = WRITE_BACK0;
	      // Miss - dirty bit 1 set
	      if ( ~hit & tag_sram_out[30:27] == 4'bxx10 ) next_state = WRITE_BACK1;
	      // Miss - dirty bit 2 set
	      if ( ~hit & tag_sram_out[30:27] == 4'bx100 ) next_state = WRITE_BACK2;
	      // Miss - dirty bit 3 set
	      if ( ~hit & tag_sram_out[30:27] == 4'b1000 ) next_state = WRITE_BACK3;
	   end // if ( cpu_req_valid )
	end // case: IDLE

	READ: begin
	   // Set response as valid
	   cpu_resp_val = 1'b1;
	   // Route proper SRAM to output
	   case ( block_sel )
	     0: cpu_resp_data = data_sram0_out[word_sel*32 +: 32];
	     1: cpu_resp_data = data_sram1_out[word_sel*32 +: 32];
	     2: cpu_resp_data = data_sram2_out[word_sel*32 +: 32];
	     3: cpu_resp_data = data_sram3_out[word_sel*32 +: 32];
	   endcase // case ( block_sel )
	   // Transition back to IDLE
	   next_state = IDLE;
	end

	WRITE: begin
	   // Set write mask, route data to proper SRAM
	   write_mask = cpu_req_write << ( word_sel * 4 );
	   // Route input to proper SRAM
	   case ( block_sel )
	     0: data_sram0_in = cpu_req_data << ( word_sel * 4 );
	     1: data_sram1_in = cpu_req_data << ( word_sel * 4 );
	     2: data_sram2_in = cpu_req_data << ( word_sel * 4 );
	     3: data_sram3_in = cpu_req_data << ( word_sel * 4 );
	   endcase // case ( block_sel )
	   // Set dirty bit
	   dirty_bit_wire = ( tag_sram_out & ( ~(1'b1 << (27 + block_sel) ) ) );
	   tag_sram_in = ( dirty_bit_wire | (1'b1 << (27 + block_sel) ) );
	   // Transition back to IDLE
	   next_state = IDLE;
	end // case: WRITE

	LOAD0: begin
	   // Stall
	   cpu_req_rdy = 1'b0;
	   // Set memory request address
	   mem_req_addr = { load_addr, 4'b0 };
	   // Set write enable for first data SRAM
	   write_enable_bar0 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      // Transfer data from main memory to cache, transition to next state
	      if ( mem_resp_val ) begin
		 data_sram0_in = mem_resp_data;
		 next_state = LOAD1;
	      end
	   end
	end // case: LOAD0

	LOAD1: begin
	   // Set memory request address
	   mem_req_addr = { load_addr, 4'b0100 };
	   // Set write enable for second data SRAM
	   write_enable_bar1 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      // Transfer data from main memory to cache, transition to next state
	      if ( mem_resp_val ) begin
		 data_sram1_in = mem_resp_data;
		 next_state = LOAD2;
	      end
	   end
	end // case: LOAD1
	   
	LOAD2: begin
	   // Set memory request address
	   mem_req_addr = { load_addr, 4'b1000 };
	   // Set write enable for third data SRAM
	   write_enable_bar2 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      // Transfer data from main memory to cache, transition to next state
	      if ( mem_resp_val ) begin
		 data_sram2_in = mem_resp_data;
		 next_state = LOAD3;
	      end
	   end
	end // case: LOAD2   
	
	LOAD3: begin
	   // Set memory request address
	   mem_req_addr = { load_addr, 4'b1100 };
	   // Set write enable for fourth data SRAM
	   write_enable_bar3 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      // Transfer data from main memory to cache, write tag with valid bit
	      if ( mem_resp_val ) begin
		 data_sram3_in = mem_resp_data;
		 tag_sram_in = 32'h8000 + load_addr[25:`ceilLog2(LINES)+0];
		 // Determine next state
		 if ( mem_req_rw ) next_state = WRITE;
		 else if ( ~mem_req_rw ) next_state = READ;
	      end
	   end
	end // case: LOAD3   

	WRITE_BACK0: begin
	   // Set memory request address
	   mem_req_addr = { tag, 6'b0 };
	   // Set write enable for first data SRAM
	   write_enable_bar0 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits = data_sram0_out;
		 // Determine next state
		 if ( tag[30:28] == 3'bxx1 ) next_state = WRITE_BACK1;
		 else if ( tag[30:29] == 2'bx1 ) next_state = WRITE_BACK2;
		 else if ( tag[30] == 1'b1 ) next_state = WRITE_BACK3;
		 else next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK0

	WRITE_BACK1: begin
	   // Set memory request address
	   mem_req_addr = { tag, 6'b010000 };
	   // Set write enable for second data SRAM
	   write_enable_bar1 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits <= data_sram1_out;
		 // Determine next state
		 if ( tag[30:29] == 2'bx1 ) next_state = WRITE_BACK2;
		 else if ( tag[30] == 1'b1 ) next_state = WRITE_BACK3;
		 else next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK1
	
	WRITE_BACK2: begin
	   // Set memory request address
	   mem_req_addr = { tag, 6'b100000 };
	   // Set write enable for third data SRAM
	   write_enable_bar2 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits = data_sram2_out;
		 // Determine next state
		 if ( tag[30] == 1'b1 ) next_state = WRITE_BACK3;
		 else next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK2

	WRITE_BACK3: begin
	   // Set memory request address
	   mem_req_addr = { tag, 6'b110000 };
	   // Set write enable for fourth data SRAM
	   write_enable_bar3 = 1'b0;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits = data_sram3_out;
		 // Set next state
		 next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK3
      endcase // case ( current_state )
      end // always @ (*)

   //always @ ( negedge reset ) next_state <= IDLE;      
   
   //////////
   // Modules
   //////////

   SRAM1RW256x128 way1_data0(.CE(clk),
			     .OEB(1'b0),
			     .CSB(1'b0),
			     .WEB(write_enable_bar0),
			     .A(sram_addr),
			     .I(data_sram0_in),
			     .O(data_sram0_out),
			     .BYTEMASK(write_mask)
			     );

   SRAM1RW256x128 way1_data1(.CE(clk),
			     .OEB(1'b0),
			     .CSB(1'b0),
			     .WEB(write_enable_bar1),
			     .A(sram_addr),
			     .I(data_sram1_in),
			     .O(data_sram1_out),
			     .BYTEMASK(write_mask)
			     );

   SRAM1RW256x128 way1_data2(.CE(clk),
			     .OEB(1'b0),
			     .CSB(1'b0),
			     .WEB(write_enable_bar2),
			     .A(sram_addr),
			     .I(data_sram2_in),
			     .O(data_sram2_out),
			     .BYTEMASK(write_mask)
			     );

   SRAM1RW256x128 way1_data3(.CE(clk),
			     .OEB(1'b0),
			     .CSB(1'b0),
			     .WEB(write_enable_bar3),
			     .A(sram_addr),
			     .I(data_sram3_in),
			     .O(data_sram3_out),
			     .BYTEMASK(write_mask)
			     );
   
   SRAM1RW256x32 way1_tag(.CE(clk),
			  .OEB(1'b0),
			  .CSB(1'b0),
			  .WEB(write_enable_bar),
			  .A(sram_addr),
			  .I(tag_sram_in),
			  .O(tag_sram_out)
			  );

endmodule
