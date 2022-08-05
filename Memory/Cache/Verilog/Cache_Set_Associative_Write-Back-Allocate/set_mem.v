/******************************************************************************/
//	Filename:		set_mem.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			29 June 2022
//	Authors:	 	Sepideh, Alireza
//	Last Author: 	Alireza
//  Copyright (C) 2022 University of Teheran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//

/******************************************************************************/
//	File content description:
//	set associative mem: this block includes n(4) ways(way_mem modules),
//	way_mem (X4) + encoder_4to2 + decoder_2to4 + ...
//	circuites for producing Hit signal, 
//	way selection circuitary for read or write to cache (get replace_way input from Replacement_Policy module)
/******************************************************************************/

module set_mem( rst, clk, sel_all, rd, wr, Hit, valid, dirty_wr, dirty,
				hit_way, replace_way,
				address, c_datain, c_dataout, m_blockin, m_blockout, tagout );
	
	parameter DATA_WIDTH = 16;
	parameter ADR_WIDTH = 16;
	parameter INDEX_WIDTH = 8;
	parameter OFFSET_WIDTH = 2;
	parameter SET_WIDTH = 2;				// 4-way set : 2^SET_WIDTH
	parameter SET_SIZE = 1 << SET_WIDTH;	// 4 (4-way set)
	parameter MEM_SIZE = 1 << INDEX_WIDTH;	// 256
	parameter TAG_WIDTH = ADR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;	// TAG_WIDTH = 6
	parameter DATA_PER_BLOCK = 1 << OFFSET_WIDTH;
	parameter BLOCK_SIZE = DATA_WIDTH*DATA_PER_BLOCK;				// 16
	
	// Controller interface
	input  rst, clk;
	input  sel_all;			                             	// From controller
	input  rd, wr;         				               		// From controller
	output Hit;												// To controller & Replacement_Policy module (in datapath)
	output valid;                                       	// To controller - from selected way_mem      
	input  dirty_wr;                                    	// from controller
	output dirty;                                       	// To controller - from selected way_mem    
	
	// Replacement_Policy interface
	output [SET_WIDTH-1:0] hit_way;         				// to Replacement_Policy module (in datapath)
	input  [SET_WIDTH-1:0] replace_way;				    	// from Replacement_Policy module (in datapath)
	
	// CPU interface
	input  [ADR_WIDTH-1:0] address;                     	// address from cpu
	input  [DATA_WIDTH-1:0] c_datain;						// cache data_in from cpu
	output [DATA_WIDTH-1:0] c_dataout;                  	// CPU dataout (to cpu)  
	
	// memory interface
	input  [BLOCK_SIZE-1:0] m_blockin;		// memory block_in (64-bit)
	output [BLOCK_SIZE-1:0] m_blockout;	// memory block_out (to memory)
	output [TAG_WIDTH-1:0] tagout;                      	// to generate address to memory
	
	                                         
	
	//wire & reg	
	wire [OFFSET_WIDTH-1:0] offset;							// offset field of main address -> select a mem of all 4 mems
	wire [BLOCK_SIZE-1:0] blockout_way	[0: SET_SIZE-1];
	wire [TAG_WIDTH-1:0]  tagout_way 	[0: SET_SIZE-1];
	wire [SET_SIZE-1:0] Hit_way;
	wire [SET_SIZE-1:0] Replace_way;
	wire [SET_SIZE-1:0] selected_way;
	wire [SET_SIZE-1:0] equal_way;
	wire [SET_SIZE-1:0] wr_way;
	wire [SET_SIZE-1:0] valid_way;
	wire [SET_SIZE-1:0] dirty_way;
	
	wire  [DATA_WIDTH-1:0] block_dataout [0:DATA_PER_BLOCK-1];
	
	// hit_way & replace_way -> 2-bit |
	// Hit_way & Replace_way -> 4-bit |
	
	
	genvar i;
	generate
		for (i=0; i<DATA_PER_BLOCK; i=i+1) begin: MEM_WAY_i    // 4-way set accociative (Tag+Block Mem)
			
			way_mem	# (	.DATA_WIDTH(DATA_WIDTH),
						.ADR_WIDTH(ADR_WIDTH),
						.INDEX_WIDTH(INDEX_WIDTH),
						.OFFSET_WIDTH(OFFSET_WIDTH) )
			WAY_MEM	( 	.rst(rst), 
						.clk(clk),
						.sel_all(sel_all),
						.rd(rd),
						.wr(wr_way[i]),
						.Hit(Hit_way[i]),
						.valid(valid_way[i]), 
						.dirty_wr(dirty_wr),
						.dirty(dirty_way[i]),
						.address(address),
						.tagout(tagout_way[i]),
						.c_datain(c_datain), 
						.m_blockin(m_blockin),
						.blockout(blockout_way[i]) );
		end
	endgenerate
	
	assign Hit = | (Hit_way);
	
	encoder_4to2 ENC (	.in(Hit_way),
						.out(hit_way) );
	decoder_2to4 DEC (	.in(replace_way),
						.out(Replace_way) );
	
	assign selected_way = (Hit) ? Hit_way : Replace_way;
	
	assign wr_way = selected_way & {SET_SIZE{wr}};
	assign valid  = | (selected_way & valid_way);
	assign dirty  = | (selected_way & dirty_way);
	
	assign tagout = (selected_way[0]) ? tagout_way[0] : {TAG_WIDTH{1'bz}};
	assign tagout = (selected_way[1]) ? tagout_way[1] : {TAG_WIDTH{1'bz}};
	assign tagout = (selected_way[2]) ? tagout_way[2] : {TAG_WIDTH{1'bz}};
	assign tagout = (selected_way[3]) ? tagout_way[3] : {TAG_WIDTH{1'bz}};
	
	assign m_blockout = (selected_way[0]) ? blockout_way[0] : {DATA_WIDTH*DATA_PER_BLOCK{1'bz}};
	assign m_blockout = (selected_way[1]) ? blockout_way[1] : {DATA_WIDTH*DATA_PER_BLOCK{1'bz}};
	assign m_blockout = (selected_way[2]) ? blockout_way[2] : {DATA_WIDTH*DATA_PER_BLOCK{1'bz}};
	assign m_blockout = (selected_way[3]) ? blockout_way[3] : {DATA_WIDTH*DATA_PER_BLOCK{1'bz}};
	
	assign offset = address[OFFSET_WIDTH-1:0];
	
	/* // wiring
	generate
		for (i=0; i<DATA_PER_BLOCK; i=i+1) begin: block_to_data
			assign block_dataout[i] = m_blockout[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH];
		end
	endgenerate
	
	assign c_dataout = block_dataout[offset];		// MUX: offset selection */
	assign c_dataout =  (offset == 0) ? m_blockout[DATA_WIDTH-1:0] :
						(offset == 1) ? m_blockout[2*DATA_WIDTH-1:DATA_WIDTH] :
						(offset == 2) ? m_blockout[3*DATA_WIDTH-1:2*DATA_WIDTH] :
						(offset == 3) ? m_blockout[4*DATA_WIDTH-1:3*DATA_WIDTH] : {DATA_WIDTH{1'bz}};

endmodule 