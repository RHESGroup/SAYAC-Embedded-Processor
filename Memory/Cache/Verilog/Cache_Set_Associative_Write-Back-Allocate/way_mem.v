/******************************************************************************/
//	Filename:		way_mem.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			25 June 2022
//	Authors:	 	Alireza, Sepideh
//	Last Author: 	Alireza
//  Copyright (C) 2022 University of Teheran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//

/******************************************************************************/
//	File content description:
//	Way Memory = WM :
//	It contains: block_mem + tag_mem_wb (+ hit circuitary)
//	interface with CPU (c_... with 16-bit data width) & Mem (m_... with 64-bit data width)
/******************************************************************************/

module way_mem( rst, clk, sel_all, rd, wr, Hit, valid, dirty_wr, dirty,
					address, tagout, c_datain, m_blockin, blockout );
	
	parameter DATA_WIDTH = 16;										// cpu data
	parameter ADR_WIDTH = 16;										// cpu address
	parameter INDEX_WIDTH = 8;										// 1024 data (16-bit) = cache size
	parameter OFFSET_WIDTH = 2;										// 4 data per block -> block_width = 4 * 16 = 64
	parameter TAG_WIDTH = ADR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;	// TAG_WIDTH = 6
	parameter MEM_SIZE = 1 << INDEX_WIDTH;							// 1024
	parameter DATA_PER_BLOCK = 1 << OFFSET_WIDTH;					// DATA_PER_BLOCK = 4
	
	// control signals:
	input rst, clk;
	input sel_all;													// ctrl_sig for block_mem module
	input rd, wr;
	output Hit;
	output valid;
	input dirty_wr;
	output dirty;
	
	// datapath signals:
	input  [ADR_WIDTH-1:0] address;
	output [TAG_WIDTH-1:0] tagout;						// concat to c_address(index_part+offset) -- offset is not used! not important
	input  [DATA_WIDTH-1:0] c_datain;					// cache data_in
	input  [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockin;	// memory block_in (64-bit)
	output [DATA_WIDTH*DATA_PER_BLOCK-1:0] blockout;	// memory block_out(64-bit)
	
	// reg & wire
	wire  [TAG_WIDTH-1:0] tag;							// index field of main address = mems address here
	wire  [INDEX_WIDTH-1:0] index;						// index field of main address = mems address here
	wire  [OFFSET_WIDTH-1:0] offset;					// offset field of main address -> select a mem of all 4 mems
	
	wire  valid;
	wire  equal;
	
	// main:
	
	assign tag = address[ADR_WIDTH-1:ADR_WIDTH-TAG_WIDTH];
	assign index = address[ADR_WIDTH-TAG_WIDTH-1:ADR_WIDTH-TAG_WIDTH-INDEX_WIDTH];
	assign offset = address[OFFSET_WIDTH-1:0];

	tag_mem_wb #(.DATA_WIDTH(DATA_WIDTH),
				.TAG_WIDTH(TAG_WIDTH),
				.INDEX_WIDTH(INDEX_WIDTH))
			TAG_MEM( 	.rst(rst),
						.clk(clk),
						.rd(rd),
						.wr(wr),
						.index(index),
						.tagin(tag),
						.tagout(tagout),
						.valid(valid),
						.dirty_wr(dirty_wr),
						.dirty(dirty));

	block_mem #(.DATA_WIDTH(DATA_WIDTH),
				.INDEX_WIDTH(INDEX_WIDTH))
			BLOCK_MEM( 	.clk(clk),
						.sel_all(sel_all),
						.rd(rd),
						.wr(wr),
						.index(index),
						.offset(offset),
						.c_datain(c_datain),
						.m_blockin(m_blockin),
						.blockout(blockout));
						
	assign equal = ( tag == tagout ) ? 1'b1 : 1'b0;//assign equal = &(~(tag ^ tagout)) ;	// comparator - assign equal = ( tag == tagout ) ? 1'b1 : 1'b0;
	assign Hit = valid & equal;
   
endmodule 