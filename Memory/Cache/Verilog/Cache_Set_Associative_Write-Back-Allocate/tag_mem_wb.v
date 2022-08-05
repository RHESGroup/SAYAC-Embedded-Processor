/******************************************************************************/
//	Filename:		tag_mem_wb.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			29 June 2022
//	Authors:	 	Alireza
//	Last Author: 	Alireza
//  Copyright (C) 2022 University of Teheran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//

/******************************************************************************/
//	File content description:
//	tag_mem_wb: tag memory write-back (it supports write-back policy because of dirty-bit for each line)
//	A memory with 1-bit valid(v) field, 1-bit dirty(d) field and TAG_WIDTH tag field
//	index input is as an index
//	all valid bits will be 0 when rst is issued, valid bit will be 1 when a tag comes to tag_mem.
//	dirty bit indicate that a cache line is consistent with main memory or not. (0 means consistent)
//	dirty-bit will be 1 when WRITE is happened (specially WRITE HIT) - inconsistency is accurred
//	outputs are tag_out and valid-bit 
/******************************************************************************/

module tag_mem_wb( rst, clk, rd, wr, index, tagin, tagout, valid, dirty_wr, dirty );
	
	parameter DATA_WIDTH = 16;
	parameter TAG_WIDTH = 6;
	parameter INDEX_WIDTH = 8;
	parameter MEM_SIZE = 1 << INDEX_WIDTH;	// 256
	
	input rst, clk;
	input rd, wr;
	input  [INDEX_WIDTH-1:0] index;
	input  [TAG_WIDTH-1:0] tagin;
	output [TAG_WIDTH-1:0] tagout;
	output valid;
	input dirty_wr;
	output dirty;
	
	reg [TAG_WIDTH-1:0] tag_data [0:MEM_SIZE-1];
	reg [0:MEM_SIZE-1] valid_data=0;
	reg [0:MEM_SIZE-1] dirty_data=0;
	integer i;

	// only for simulation:						// Delete for Synthesis
	initial begin								// Delete for Synthesis
		for (i=0; i<MEM_SIZE; i=i+1)			// Delete for Synthesis
			tag_data[i] <= $random;				// Delete for Synthesis
	end											// Delete for Synthesis
	
	always @(posedge clk)
	begin
		if (rst) begin
			valid_data <= 0;					// initial all valid bits to zero
			dirty_data <= 0;					// this line may be deleted (not necessory)
		end
		else if (wr) begin
			tag_data[index] <= tagin;
			valid_data[index] <= 1'b1;
			if (dirty_wr)
				dirty_data[index] <= 1'b1;
			else
				dirty_data[index] <= 1'b0;
		end
	end
	assign tagout = (rd) ? tag_data[index]		: 0;
	assign valid = (rd|wr) ? valid_data[index] 	: 0;
	assign dirty = (rd) ? dirty_data[index] 	: 0;
   
endmodule 