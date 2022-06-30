/******************************************************************************/
//	Filename:		datapath_wb.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			27 June 2022
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
//	datapath of cahce (supports write-back policy)
/******************************************************************************/

module datapath_wb( rst, clk, sel_all, rd, wr, update, d_on_cpu, d_on_mem, adr_on_mem, 
                    drt_adr_on_mem, Hit, valid, dirty_wr, dirty, en_replacement,
					c_address, c_datain, c_dataout,
					m_ready, m_address, m_blockin, m_blockout);
	
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
	parameter BUS_ADR_WIDTH = ADR_WIDTH - OFFSET_WIDTH;	
	
	// system
	input rst, clk;								
	
	// controller interface:
	input sel_all, rd, wr, update;									// CM (cache_mem needs them)
	input d_on_cpu, d_on_mem, adr_on_mem;							// tri-state select, data or address on buss or not
	input drt_adr_on_mem;											// tri-state select, dirty address on memory address buss
	output Hit;												        // CM provides this
	output valid;
	input dirty_wr;                                       
	output dirty;
	input en_replacement;
	
	
	// CPU interface:
	input [ADR_WIDTH-1:0] c_address;
	input [DATA_WIDTH-1:0] c_datain;
	output[DATA_WIDTH-1:0] c_dataout;
	
	// Mem interface:
	input m_ready;													// this is a control signal that Mem provides
	output[BUS_ADR_WIDTH-1:0] m_address;						
	input [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockin;				// Mem provides a block (not a data)
	output[DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockout;				// Mem recieves a block (not a data)
	
	// reg & wire
	
	// Replacement_Policy interface:
	wire [SET_WIDTH-1:0] replace_way;
	wire [SET_WIDTH-1:0] hit_way;
	
	// reg & wires
	reg [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockin_reg;				// register block-in comes from Mem
	wire [DATA_WIDTH-1:0] dataout;
	wire [DATA_WIDTH*DATA_PER_BLOCK-1:0] blockout;
	wire [TAG_WIDTH-1:0] tagout;
	wire [INDEX_WIDTH-1:0] index;
	
	
									// concat to c_address then will be on m_address when adr_on_mem
	
	// register m_blockin_reg to keep blockin for the next cycle
	// this delay produced by controller and this register compensate the delay
	always @(posedge clk)
		if (rst)
			m_blockin_reg <= 0;
		else if (m_ready)
			m_blockin_reg <= m_blockin;
	
	// CM
	set_mem			 #(	.DATA_WIDTH(DATA_WIDTH),
						.ADR_WIDTH(ADR_WIDTH),
						.INDEX_WIDTH(INDEX_WIDTH),
						.OFFSET_WIDTH(OFFSET_WIDTH),
						.SET_WIDTH(SET_WIDTH) )
			SM (	  	.rst(rst),
						.clk(clk),
						.sel_all(sel_all),
						.rd(rd),
						.wr(wr),
						.Hit(Hit),
						.valid(valid),
						.dirty_wr(dirty_wr),
						.dirty(dirty),
						
						.hit_way(hit_way),
						.replace_way(replace_way),
						
						.address(c_address),
						.c_datain(c_datain),
						.c_dataout(dataout),
						
						.m_blockin(m_blockin_reg),
						.m_blockout(blockout),
						.tagout(tagout) );

	plru_replacement #(	.INDEX_WIDTH(INDEX_WIDTH),
						.SET_WIDTH(SET_WIDTH) )
		PLRU_REPLACE(	.rst(rst), 
						.clk(clk),
						.en(en_replacement),
						.update(update),
						.hit_update(Hit),
						.index(index),
						.hit_way(hit_way),
						.replace_way(replace_way) );
							   
	assign index = c_address[ADR_WIDTH-TAG_WIDTH-1:ADR_WIDTH-TAG_WIDTH-INDEX_WIDTH];
	
	// tri-state buffers
	assign c_dataout = (d_on_cpu) ? dataout : {DATA_WIDTH{1'bz}};
	assign m_blockout= (d_on_mem) ? blockout : {(DATA_WIDTH*DATA_PER_BLOCK){1'bz}};
	assign m_address = (adr_on_mem) ? c_address[ADR_WIDTH-1:OFFSET_WIDTH] :
						(drt_adr_on_mem) ? {tagout, c_address[ADR_WIDTH-TAG_WIDTH-1:OFFSET_WIDTH]} : {BUS_ADR_WIDTH{1'bz}};
	
endmodule 