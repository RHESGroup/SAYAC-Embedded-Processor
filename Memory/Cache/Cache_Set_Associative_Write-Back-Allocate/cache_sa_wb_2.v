/******************************************************************************/
//	Filename:		cache_sa_wb_2.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		2.000
//	History:		-
//	Date:			25 June 2022
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
//	top module of cache: Set Associative cache with Write Back policy (and Write-Allocate)
//		datapath + controller
// 	version 2: BUS_ADR_WIDTH = 14
/******************************************************************************/

module cache_sa_wb_2( rst, clk,
					c_address, c_datain, c_dataout,
					c_rd, c_wr, c_ready,
					m_address, m_blockin, m_blockout,
					m_ready, m_rd, m_wr);
	
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
	
	// system -----------------------------------------------------
	input rst, clk;								
	
	// CPU interface-LEFT------------------------------------------
		// datapath
	input [ADR_WIDTH-1:0] c_address;
	input [DATA_WIDTH-1:0] c_datain;
	output[DATA_WIDTH-1:0] c_dataout;
		// controller
	input c_rd, c_wr;												// cache read and write
	output c_ready;													// cache ready
	
	// Mem interface-RIGHT------------------------------------------
		// datapath
	output[BUS_ADR_WIDTH-1:0] m_address;						
	input [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockin;				// Mem provides a block (not a data)
	output[DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockout;				// Mem recieves a block (not a data)
		// controller
	input m_ready;													// memory ready
	output m_rd, m_wr;												// memory read and write
	
	// reg & wires--------------------------------------------------
	// controller <-> datapath
	wire sel_all, rd, wr, dirty_wr;									// 		controller -> datapath (CM)
	wire d_on_cpu, d_on_mem, adr_on_mem, drt_adr_on_mem;			// 		controller -> datapath (tri-state buffers)
	wire Hit, valid, dirty;											// (CM) datapath   -> controller
	wire update;
	wire en_replacement;
	
	// datapath-----------------------------------------------------
	datapath_wb #	(	.DATA_WIDTH(DATA_WIDTH),
						.ADR_WIDTH(ADR_WIDTH),
						.INDEX_WIDTH(INDEX_WIDTH),
						.OFFSET_WIDTH(OFFSET_WIDTH),
						.SET_WIDTH(SET_WIDTH))
			DP (	 	.rst(rst),
						.clk(clk),
						// CTRL
						.sel_all(sel_all),
						.rd(rd),
						.wr(wr),
						.update(update),
						.d_on_cpu(d_on_cpu),
						.d_on_mem(d_on_mem),
						.adr_on_mem(adr_on_mem),
						.drt_adr_on_mem(drt_adr_on_mem),
						.Hit(Hit),
						.valid(valid),
						.dirty_wr(dirty_wr),
						.dirty(dirty),
						.en_replacement(en_replacement),
						// CPU
						.c_address(c_address),
						.c_datain(c_datain),
						.c_dataout(c_dataout),
						// MEM
						.m_ready(m_ready),
						.m_address(m_address),
						.m_blockin(m_blockin),
						.m_blockout(m_blockout));
	
	// controller
	controller_wb 
			CTRL (	 	.rst(rst),
						.clk(clk),
						// CTRL
						.sel_all(sel_all),
						.rd(rd),
						.wr(wr),
						.d_on_cpu(d_on_cpu),
						.d_on_mem(d_on_mem),
						.adr_on_mem(adr_on_mem),
						.drt_adr_on_mem(drt_adr_on_mem),
						.Hit(Hit),
						.valid(valid),
						.dirty_wr(dirty_wr),
						.dirty(dirty),
						.update(update),
						.en_replacement(en_replacement),
						// CPU
						.c_rd(c_rd),
						.c_wr(c_wr),
						.c_ready(c_ready),
						// MEM
						.m_ready(m_ready),
						.m_rd(m_rd),
						.m_wr(m_wr));
	
endmodule 