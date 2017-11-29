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

   
endmodule
