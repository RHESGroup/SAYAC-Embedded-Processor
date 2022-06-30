/******************************************************************************/
//	Filename:		block_mem.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			16 May 2022
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
//	Its main part is a memory that keeps block-datas (Values) fetched from mem to cache.
//	This memory consisted of 4 (n) mem modules. (mem is a simple SRAM memory)
//	This module:
//		find Hit/Miss(!Hit)
//		handle write a data (16-bit) from cpu
//		handle write a block (64-bit ) from mem
//		handle read a block (64-bit) to Cache Mem (to select a 16-bit data to cpu)
/******************************************************************************/

module block_mem( clk, sel_all, rd, wr, index, offset, c_datain, m_blockin, blockout );
	
	parameter INDEX_WIDTH = 8;
	parameter DATA_WIDTH = 16;
	parameter MEM_SIZE = 1 << INDEX_WIDTH;			// 256
	
	parameter OFFSET_WIDTH = 2;						// 4 data per block -> block_width = 4 * 16 = 64
	parameter DATA_PER_BLOCK = 1 << OFFSET_WIDTH;	// DATA_PER_BLOCK = 4
	
	input clk;
	input sel_all;										// select all mem => read from or write to the all mems (64-bit)
	input rd, wr;
	
	input  [INDEX_WIDTH-1:0] index;						// index field of main address = mems address here
	input  [OFFSET_WIDTH-1:0] offset;					// offset field of main address -> select a mem of all 4 mems
	input  [DATA_WIDTH-1:0] c_datain;					// cache data_in
	input  [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockin;	// memory block_in (64-bit)
	output [DATA_WIDTH*DATA_PER_BLOCK-1:0] blockout;	// block_out (64-bit) selected from cache (it will be send to th cpu)
	
	wire sel[0:DATA_PER_BLOCK-1];
	wire [DATA_WIDTH-1:0] mem_datain [0:DATA_PER_BLOCK-1];
	wire [DATA_WIDTH-1:0] mem_dataout [0:DATA_PER_BLOCK-1];

	genvar i;
	generate
		for (i=0; i<DATA_PER_BLOCK; i=i+1) begin: MEM_i
			
			 
			assign mem_datain[i] = (sel_all) ?	m_blockin[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] :
														c_datain;
			
			assign sel[i] = (offset == i) ? 1'b1 : sel_all;	//assign sel[i] = (offset == i) ? 1'b1 : 1'b0;
			
			mem #(	.ADR_WIDTH(INDEX_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.MEM_SIZE(MEM_SIZE))

				D_MEM( 	.clk(clk),
						.sel(sel[i]),
						.rd(rd),
						.wr(wr),
						.address(index),
						.datain(mem_datain[i]),
						.dataout(mem_dataout[i]) );
		
			assign blockout[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] = mem_dataout[i];
		end		
	endgenerate	
   
endmodule 
