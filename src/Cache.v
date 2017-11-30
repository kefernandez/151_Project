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
  parameter CPU_WIDTH = `CPU_INST_BITS, // = 32
  parameter WORD_ADDR_BITS = `CPU_ADDR_BITS-`ceilLog2(`CPU_INST_BITS/8) // = 32 - 2 = 30
)
(
  input clk,
  input reset,

  input                       cpu_req_val,
  output reg                      cpu_req_rdy, //cache is ready for cpu memory transaction
  input [WORD_ADDR_BITS-1:0]  cpu_req_addr, //[29:0]
  input [CPU_WIDTH-1:0]       cpu_req_data,
  input [3:0]                 cpu_req_write,

  output reg                     cpu_resp_val, //cpu has valid data to output
  output reg [CPU_WIDTH-1:0]      cpu_resp_data, //[31:0] data that I output for reads
  output reg                    mem_req_val, //cache is requesting main memory for transaction
  input                       mem_req_rdy,
  output reg [WORD_ADDR_BITS-1:`ceilLog2(`MEM_DATA_BITS/CPU_WIDTH)] mem_req_addr, //[29:2] 4 words per set in mem so no need for last 2 bits
  output reg                          mem_req_rw, //reading mem = 0, writing mem = 1
  output reg                           mem_req_data_valid, //set to 1 if I want to write to memory
  input                            mem_req_data_ready,  //main mem is ready to provide data (always 1)
  output reg [`MEM_DATA_BITS-1:0]      mem_req_data_bits, //data I'm writing to main mem
  // byte level masking
  output [(`MEM_DATA_BITS/8)-1:0]  mem_req_data_mask, // set = to 16'hFFFF

  input                       mem_resp_val,
  input [`MEM_DATA_BITS-1:0]  mem_resp_data //data that memory gives to cache [127:0]
);
<<<<<<< HEAD
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
   wire [`ceilLog2(LINES)-1:0]  sram_addr;
   reg [25-`ceilLog2(LINES):0] 	tag, load_tag;
   reg [31:0] 			tag_sram_out, tag_sram_in, dirty_bit_wire, write_mask;
   reg [127:0] 			data_sram0_out, data_sram1_out, data_sram2_out, data_sram3_out;
   reg [127:0] 			data_sram0_in, data_sram1_in, data_sram2_in, data_sram3_in;
   wire 		        write_enable_bar, write_enable_bar0, write_enable_bar1, write_enable_bar2, write_enable_bar3;
   
   // FSM state registers
   reg [3:0] 			current_state, next_state; 			
   
   ////////////////////////////
   // Control signal assignment
   ////////////////////////////

   assign mem_req_rw = ( 0 | cpu_req_write );
//   assign cpu_req_fire = cpu_req_valid & cpu_req_rdy;
//   assign mem_req_fire = mem_req_val & mem_req_rdy;
   assign hit = ( tag == ( cpu_req_addr >> ( 6+`ceilLog2(LINES) ) ) && ( tag_sram_out[31] == 1 ) && cpu_req_val );
   assign dirty = ~( tag_sram_out[30:27] == 4'b0000 );
   assign tag = tag_sram_out[25-`ceilLog2(LINES):0];
   assign mem_req_data_mask = 16'hFFFF;

   // Address connections
   assign sram_addr = cpu_req_addr[5+`ceilLog2(LINES):6];
   assign block_sel = cpu_req_addr[5:4];
   assign word_sel = cpu_req_addr[3:2];
   assign byte_sel = cpu_req_addr[1:0];

   // SRAM write connections
   assign write_enable_bar = ~(cpu_req_val & cpu_req_write);
   assign write_enable_bar0 = ~(~write_enable_bar && block_sel == 0);
   assign write_enable_bar1 = ~(~write_enable_bar && block_sel == 1);
   assign write_enable_bar2 = ~(~write_enable_bar && block_sel == 2);
   assign write_enable_bar3 = ~(~write_enable_bar && block_sel == 3);
=======

   wire [7:0] cpu_req_cache_addr;
   reg [15:0] cache_byte_mask; //determined by cpu_req_write
   reg  RW_cache0, RW_cache1, RW_cache2, RW_cache3, RW_cache_tag, RW_cache_write; //1 = read, 0 = write
   wire valid_bit, dirty_bit;
   wire [127:0]  read_data_cache0, read_data_cache1, read_data_cache2, read_data_cache3;
   reg [127:0] 	 read_data_cache;
   reg [127:0] write_data_cache;
   reg [31:0] 	write_data_cache_tag;
   //wire [31:0] 	write_hit_data_cache;
   wire [2:0] 	cpu_set_offset;
   wire [3:0] 	cpu_word_offset;
   wire [22:0] 	cpu_tag;
   wire read;
   wire [2:0] IDLE, Read_Mem1, Read_Mem2, Read_Mem3, Read_Mem4, Write_to_Mem2, Write_to_Mem3, Write_to_Mem4;
   wire [31:0] read_data_cache_tag;
	      
   reg [2:0]  next_state, current_state;
   reg [2:0] cpu_set_offset_reg;
   reg [3:0] cpu_word_offset_reg, cpu_req_write_reg;
   reg [22:0] cpu_tag_reg;
   reg [7:0] cache_addr_reg, cache_addr;
   reg [31:0] cpu_req_data_reg;
   reg [2:0] stall;
   reg [29:0] cpu_req_addr_reg;
   
   assign cpu_req_cache_addr = {5'b0,cpu_req_addr[6:4]};
   assign valid_bit = read_data_cache_tag[31];
   assign dirty_bit = read_data_cache_tag[30];
   assign mem_req_data_mask = 16'hFFFF;
   assign cpu_set_offset = cpu_req_addr[6:4];
   assign cpu_word_offset = cpu_req_addr[3:0];
   assign cpu_tag = cpu_req_addr[29:7];

   assign IDLE = 3'b000;
   assign Read_Mem1 = 3'b001;
   assign Read_Mem2 = 3'b010;
   assign Read_Mem3 = 3'b011;
   assign Read_Mem4 = 3'b100;
   assign  Write_to_Mem2 = 3'b101;
   assign  Write_to_Mem3 = 3'b110;
   assign  Write_to_Mem4 = 3'b111;
   
>>>>>>> 787326bc7aad52459ec2ff46ca017d6883a1538b
   

<<<<<<< HEAD
   // FSM state transition (positive clock edge)
   always @ (posedge clk) begin
      current_state <= next_state;
   end

   // FSM encoding
   always @ (*) begin
      // Default transition - return to IDLE state
      next_state = IDLE;
      // Default outputs - set all to zero
      cpu_req_rdy = 1'b0;
      cpu_resp_val = 1'b0;
      mem_req_val = 1'b0;
      mem_req_data_valid = 1'b0;
      
      case ( current_state )
	IDLE: begin
	   // Set ready bit
	   cpu_req_rdy = 1'b1;
	   // Hit - read
	   if ( hit & mem_req_rw ) next_state = READ;
	   // Hit - write
	   if ( hit & ~mem_req_rw ) next_state = WRITE;
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
	end // case: IDLE

	READ: begin
	   // Route proper SRAM to output
	   case ( block_sel )
	     0: cpu_resp_data <= data_sram0_out[word_sel*32 +: 32];
	     1: cpu_resp_data <= data_sram1_out[word_sel*32 +: 32];
	     2: cpu_resp_data <= data_sram2_out[word_sel*32 +: 32];
	     3: cpu_resp_data <= data_sram3_out[word_sel*32 +: 32];
	   endcase // case ( block_sel )
	   // Set response as valid, transition back to IDLE
	   cpu_resp_val = 1'b1;
	   next_state = IDLE;
	end

	WRITE: begin
	   // Set write mask, route data to proper SRAM
	   write_mask <= cpu_req_write << ( word_sel * 4 );
	   // Route input to proper SRAM
	   case ( block_sel )
	     0: data_sram0_in <= cpu_req_data << ( word_sel * 4 );
	     1: data_sram1_in <= cpu_req_data << ( word_sel * 4 );
	     2: data_sram2_in <= cpu_req_data << ( word_sel * 4 );
	     3: data_sram3_in <= cpu_req_data << ( word_sel * 4 );
	   endcase // case ( block_sel )
	   // Set dirty bit
	   dirty_bit_wire <= ( tag_sram_out & ( ~(1'b1 << (27 + block_sel) ) ) );
	   tag_sram_in <= ( dirty_bit_wire | (1'b1 << (27 + block_sel) ) );
	   // Transition back to IDLE
	   next_state = IDLE;
	end // case: WRITE

	LOAD0: begin
	   // Get load tag
	   load_tag <= tag;
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_addr <= { load_tag, 6'b0 };
	      // Transfer data from main memory to cache, transition to next state
	      if ( mem_resp_val ) begin
		 data_sram0_in <= mem_resp_data;
		 next_state = LOAD1;
	      end
	   end
	end // case: LOAD0

	LOAD1: begin
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_addr <= { load_tag, 6'b010000 };
	      // Transfer data from main memory to cache, transition to next state
	      if ( mem_resp_val ) begin
		 data_sram1_in <= mem_resp_data;
		 next_state = LOAD2;
	      end
	   end
	end // case: LOAD1
	   
	LOAD2: begin
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_addr <= { load_tag, 6'b100000 };
	      // Transfer data from main memory to cache, transition to next state
	      if ( mem_resp_val ) begin
		 data_sram2_in <= mem_resp_data;
		 next_state = LOAD3;
	      end
	   end
	end // case: LOAD2   
	
	LOAD3: begin
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_addr <= { load_tag, 6'b110000 };
	      // Transfer data from main memory to cache, write tag with valid bit
	      if ( mem_resp_val ) begin
		 data_sram3_in <= mem_resp_data;
		 tag_sram_in <= 32'h8000 + load_tag;
		 // Determine next state
		 if ( mem_req_rw ) next_state = WRITE;
		 else if ( ~mem_req_rw ) next_state = READ;
	      end
	   end
	end // case: LOAD3   

	WRITE_BACK0: begin
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      mem_req_addr <= { tag, 6'b0 };
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits <= data_sram0_out;
		 // Determine next state
		 if ( tag[30:28] == 3'bxx1 ) next_state = WRITE_BACK1;
		 else if ( tag[30:29] == 2'bx1 ) next_state = WRITE_BACK2;
		 else if ( tag[30] == 1'b1 ) next_state = WRITE_BACK3;
		 else next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK0

	WRITE_BACK1: begin
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      mem_req_addr <= { tag, 6'b010000 };
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
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      mem_req_addr <= { tag, 6'b100000 };
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits <= data_sram2_out;
		 // Determine next state
		 if ( tag[30] == 1'b1 ) next_state = WRITE_BACK3;
		 else next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK2

	WRITE_BACK3: begin
	   // Request main memory transaction, proceed when ready
	   if ( mem_req_rdy ) begin
	      mem_req_val = 1'b1;
	      mem_req_data_valid = 1'b1;
	      mem_req_addr <= { tag, 6'b110000 };
	      // Transfer data from cache to main memory
	      if ( mem_req_data_ready ) begin
		 mem_req_data_bits <= data_sram3_out;
		 // Set next state
		 next_state = LOAD0;
	      end
	   end // if ( mem_req_rdy )
	end // case: WRITE_BACK3
      endcase // case ( current_state )
      end // always @ (*)
   
   //////////
   // Modules
   //////////

   SRAM1RW256x128 way1_data0(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar0),
			     .A(sram_addr0),
			     .I(data_sram0_in),
			     .O(data_sram0_out),
			     .BYTEMASK(write_mask)
			     );

   SRAM1RW256x128 way1_data1(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar1),
			     .A(sram_addr),
			     .I(data_sram1_in),
			     .O(data_sram1_out),
			     .BYTEMASK(write_mask)
			     );

   SRAM1RW256x128 way1_data2(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar2),
			     .A(sram_addr),
			     .I(data_sram2_in),
			     .O(data_sram2_out),
			     .BYTEMASK(write_mask)
			     );

   SRAM1RW256x128 way1_data3(.CE(clk),
			     .OEB(ground),
			     .CSB(ground),
			     .WEB(write_enable_bar3),
			     .A(sram_addr),
			     .I(data_sram3_in),
			     .O(data_sram3_out),
			     .BYTEMASK(write_mask)
			     );
   
   SRAM1RW256x32 way1_tag(.CE(clk),
			  .OEB(ground),
			  .CSB(ground),
			  .WEB(write_enable_bar),
			  .A(sram_addr),
			  .I(tag_sram_in),
			  .O(tag_sram_out)
			  );

=======
 

   always @(*) begin
      
	 
      if (~reset) begin
      case(current_state)
	
	IDLE: begin

	   if((read_data_cache_tag[25:3] == cpu_tag_reg[29:7]) && (valid_bit)) //hit!
	     begin
		RW_cache0 = 1'b1;
		RW_cache1 = 1'b1;
		RW_cache2 = 1'b1;
		RW_cache3 = 1'b1;
		RW_cache_tag = 1'b1;

		
		cpu_req_rdy = 1'b1;
		cpu_resp_val = 1'b1;
		mem_req_val = 1'b0;
		mem_req_rw = 1'b0;
		mem_req_data_valid = 1'b0;
		next_state <= IDLE;
		
		if(cpu_req_write_reg == 4'b0000) //read hit
		  begin
		     case(cpu_word_offset_reg[3:2])
		       2'b00: read_data_cache = read_data_cache0;
		       2'b01: read_data_cache = read_data_cache1;
		       2'b10: read_data_cache = read_data_cache2;
		       2'b11: read_data_cache = read_data_cache3;
		     endcase

		     case(cpu_word_offset_reg[1:0])
		       2'b00: cpu_resp_data = read_data_cache[31:0];
		       2'b01: cpu_resp_data = read_data_cache[63:32];
		       2'b10: cpu_resp_data = read_data_cache[95:64];
		       2'b11: cpu_resp_data = read_data_cache[127:96];
		     endcase
		     
		  end 
		
		else //write hit - need to write this section
		  begin
		     write_data_cache <= {cpu_req_data_reg,cpu_req_data_reg,cpu_req_data_reg,cpu_req_data_reg};
		     RW_cache_tag = 1'b0;
		     write_data_cache_tag <= {write_data_cache_tag[31], 1'b1, write_data_cache_tag[29:0]};
	     	     
		     case(cpu_word_offset_reg[3:2])
		       2'b00: begin
			  RW_cache0 <= 1'b0;
			  RW_cache1 <= 1'b1;
			  RW_cache2 <= 1'b1;
			  RW_cache3 <= 1'b1; end
		       2'b01: begin
			  RW_cache0 <= 1'b1;
			  RW_cache1 <= 1'b0;
			  RW_cache2 <= 1'b1;
			  RW_cache3 <= 1'b1; end
		       2'b10: begin
			  RW_cache0 <= 1'b1;
			  RW_cache1 <= 1'b1;
			  RW_cache2 <= 1'b0;
			  RW_cache3 <= 1'b1; end
		       2'b11: begin
			  RW_cache0 <= 1'b1;
			  RW_cache1 <= 1'b1;
			  RW_cache2 <= 1'b1;
			  RW_cache3 <= 1'b0; end
		     endcase 
		     
		     case(cpu_word_offset_reg[1:0])
		       2'b00: cache_byte_mask = {12'b0, cpu_req_write_reg};
		       2'b01: cache_byte_mask = {8'b0, cpu_req_write_reg,4'b0};
		       2'b10: cache_byte_mask = {4'b0, cpu_req_write_reg,8'b0};
		       2'b11: cache_byte_mask = {12'b0, cpu_req_write_reg};
		     endcase 	    
		     
		  end 
	     end

	   else //got a miss
	     
	     begin
		
		if ( ((read_data_cache_tag[25:3] != cpu_tag_reg[29:7]) && ~(dirty_bit)) || ~(valid_bit)) //no write to mem,read from mem
		  begin
		     if (stall != 3'b100)begin
		     RW_cache0 <= 1'b0;
		     RW_cache_tag <= 1'b0;
		     
		     cpu_req_rdy = 1'b0;
		     cpu_resp_val = 1'b0;
		     mem_req_val = 1'b1;
		     mem_req_rw = 1'b0;
		     mem_req_data_valid = 1'b0;
		     
		     write_data_cache_tag <= {1'b1, 5'b0,cpu_req_addr[29:4]};
		     mem_req_addr = {cpu_tag_reg,cpu_set_offset_reg,2'b00};
		     write_data_cache <= mem_resp_data;
		     next_state <= Read_Mem2;
		     // if (stall= 2'b00)
		     next_state <= IDLE;
		     end
		     
		     else next_state = Read_Mem2;	     
		  end
	     		
		else if( (read_data_cache_tag[25:3] != cpu_tag_reg[29:7]) && (valid_bit) && (dirty_bit)) //need to write to mem
		  begin

		     //if(stall == 2'b00)begin
		     RW_cache0 = 1'b1;
		     RW_cache1 = 1'b1;
		     RW_cache2 = 1'b1;
		     RW_cache3 = 1'b1;
		     RW_cache_tag = 1'b1;
		     
		     cpu_req_rdy = 1'b0;
		     cpu_resp_val = 1'b0;
		     mem_req_val = 1'b1;
		     mem_req_rw = 1'b1;
		     mem_req_data_valid = 1'b1;
		     next_state <= Write_to_Mem2;
		     
		     mem_req_addr = {cpu_tag_reg, cpu_set_offset_reg, 2'b00};
		     mem_req_data_bits = read_data_cache0;
		     next_state = Write_to_Mem2;
		  end
		    // end // if (stall == 2'b00)

		 
		
	     end // else: !if((read_data_cache_tag[25:3] == cpu_tag_reg[29:7]) && (valid_bit))
	   
	end // case: IDLE
	
	Read_Mem1: begin
	   RW_cache0 <= 1'b0;
	   RW_cache_tag <= 1'b0;
	   
	   mem_req_rw = 1'b0;
	   mem_req_data_valid = 1'b0;
	   
	   write_data_cache_tag <= {1'b1, 5'b0,cpu_req_addr[29:4]};
	   mem_req_addr = {cpu_tag_reg,cpu_set_offset_reg,2'b00};
	   write_data_cache <= mem_resp_data;
	   next_state <= Read_Mem2;
	end
	
	Read_Mem2: begin
	   if(stall != 3'b011)
	     begin
		//RW_cache0 <= 1'b1;
		//RW_cache_tag <= 1'b1;
		RW_cache1 <= 1'b0;
		mem_req_addr = {cpu_tag_reg,cpu_set_offset_reg,2'b01};
		next_state <= Read_Mem2;
	     end
	   else next_state <= Read_Mem3;
	end
	
	Read_Mem3: begin
	   RW_cache0 <= 1'b1;
	   RW_cache_tag <= 1'b1;
	   if(stall != 3'b011)begin
	      
	   RW_cache1 <= 1'b1;
	   RW_cache2 <= 1'b0;
	   mem_req_addr = {cpu_tag_reg,cpu_set_offset_reg,2'b10};
	   next_state = Read_Mem3;
	      
	   end
	   else next_state <= Read_Mem4;
	   
	end

	Read_Mem4: begin
	   if(stall != 3'b011)begin
	      RW_cache2 <= 1'b1;
	      RW_cache3 <= 1'b0;
	      mem_req_addr = {cpu_tag_reg,cpu_set_offset_reg,2'b11};
	      next_state <= Read_Mem4;
	   end
	   else next_state <= IDLE;
	end


	Write_to_Mem2: 
	  begin
	     mem_req_addr = {cpu_tag_reg, 2'b01};
	     mem_req_data_bits = read_data_cache1;
	     next_state = Write_to_Mem3;   
	  end

	Write_to_Mem3: 
	  begin
	     mem_req_addr = {cpu_tag_reg, 2'b10};
	     mem_req_data_bits = read_data_cache2;
	     next_state = Write_to_Mem4;
	  end

	Write_to_Mem4: 
	  begin
	     mem_req_addr = {cpu_tag_reg, 2'b11};
	     mem_req_data_bits = read_data_cache3;
	     
	     next_state = Read_Mem1;
	  end
        
	endcase // case (current_state)

      
      if(cpu_req_rdy) begin
	 cache_addr <= cpu_req_cache_addr;
      end
      else begin
	 cache_addr <= cache_addr_reg;
	 end
	 
      end
   end
   
      always @(posedge clk) begin
      
      if(reset)begin
	 cpu_req_rdy <= 1'b0;
	 cpu_resp_val <= 1'b0;
	 mem_req_val <= 1'b0;
	 mem_req_rw <= 1'b0;
	 mem_req_data_valid <= 1'b0;
	 stall <= 2'b0;
	 
      end
	 
      
      else begin
	 current_state <= next_state;
	 
	 
	 if(cpu_req_rdy || (current_state == IDLE && stall ==3'b001))
	   begin
	      cpu_set_offset_reg <= cpu_set_offset;
	      cpu_word_offset_reg <= cpu_word_offset;
	      cpu_tag_reg <= cpu_tag;
	      cache_addr_reg <= cache_addr;
	      cpu_req_write_reg <= cpu_req_write;
	      cpu_req_data_reg <= cpu_req_data;
	      cpu_req_addr_reg <= cpu_req_addr;
	      if(current_state == IDLE) stall = stall +3'b001;
	      
	   end
	 else begin
	    if(current_state == IDLE)begin
	       if(stall != 3'b100) stall <= stall + 3'b001;
	       else stall <= 3'b000; end
	    else begin
	       if(stall != 3'b011) stall <= stall +3'b001;
	       else stall <= 3'b000;
	    end
	 end
      end // always @ (posedge clk)
   end

      always @(negedge reset) begin
	 next_state <= IDLE;
	 stall <= 3'b000;
      end
      
   
     
   SRAM1RW256x128 cache3(
			 .CE(clk),
			 .OEB(1'b0),
			 .CSB(1'b0),
			 .WEB(RW_cache3),
			 .A(cache_addr),
			 .I(write_data_cache),
			 .O(read_data_cache3),
			 .BYTEMASK(cache_byte_mask)
			 );

   SRAM1RW256x128 cache2(
			 .CE(clk),
			 .OEB(1'b0),
			 .CSB(1'b0),
			 .WEB(RW_cache2),
			 .A(cache_addr),
			 .I(write_data_cache),
			 .O(read_data_cache2),
			 .BYTEMASK(cache_byte_mask)
			 );

   SRAM1RW256x128 cache1(
			 .CE(clk),
			 .OEB(1'b0),
			 .CSB(1'b0),
			 .WEB(RW_cache1),
			 .A(cache_addr),
			 .I(write_data_cache),
			 .O(read_data_cache1),
			 .BYTEMASK(cache_byte_mask)
			 );

   SRAM1RW256x128 cache0(
			 .CE(clk),
			 .OEB(1'b0),
			 .CSB(1'b0),
			 .WEB(RW_cache0),
			 .A(cache_addr),
			 .I(write_data_cache),
			 .O(read_data_cache0),
			 .BYTEMASK(cache_byte_mask)
			 );
   
   SRAM1RW256x32 cache_tag(
			  .CE(clk),
			  .OEB(1'b0),
			  .CSB(1'b0),
			  .WEB(RW_cache_tag),
			  .A(cache_addr),
			  .I(write_data_cache_tag),
			  .O(read_data_cache_tag)
			  //.BYTEMASK(16'hFFFF) 
			  );

   
>>>>>>> 787326bc7aad52459ec2ff46ca017d6883a1538b
endmodule
