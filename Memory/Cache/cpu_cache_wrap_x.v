/******************************************************************************/
//	Filename:		cpu_cache_wrap_x.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			13 June 2022
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
//	CPU_3 + cache(sa_wb) + bus interface
//	version 2: BUS_ADR_WIDTH = 14
//	version 3: BUS name is changed to CACHE -> CACHE_DATA_WIDTH = 64
/******************************************************************************/

module cpu_cache_wrap_x( rst, clk,
					m_bus_address, m_bus_datain, m_bus_dataout,
					m_bus_rd, m_bus_wr, m_bus_ready,
					m_bus_req, m_bus_gnt);
	
	parameter CACHE_DATA_WIDTH = 64;									// bus data
	parameter CACHE_ADR_WIDTH = 14;										// bus address
	
	parameter DATA_WIDTH = 16;											// cpu data
	parameter ADR_WIDTH = 16;											// cpu address
	parameter OFFSET_WIDTH = 2;											// 4 data per block -> block_width = 4 * 16 = 64
	parameter DATA_PER_BLOCK = 1 << OFFSET_WIDTH;						// DATA_PER_BLOCK = 4
	
	input rst;
	input clk;								
	
	// Master_Bus_Inerface
	output [CACHE_ADR_WIDTH-1:0] m_bus_address;							// master address to Bus					
	input  [CACHE_DATA_WIDTH-1:0] m_bus_datain;							// master datain from bus
	output [CACHE_DATA_WIDTH-1:0] m_bus_dataout;						// master dataout to bus
	output m_bus_rd;													// master read to bus
	output m_bus_wr;													// master write to bus
	input  m_bus_ready;													// master ready to bus
	output m_bus_req;													// master request to bus
	input  m_bus_gnt;													// master grant from bus
	
	// reg & wires--------------------------------------------------
	
	// CPU interface
	wire [ADR_WIDTH-1:0] c_address;						
	wire [DATA_WIDTH-1:0] c_data;									// cpu <-> cache
	wire c_ready;													// cache -> cpu
	wire c_rd, c_wr;
	
	// Cache-CPU interface
	wire [DATA_WIDTH-1:0] cpu2cache_data;							// cpu -> cache
	wire [DATA_WIDTH-1:0] cache2cpu_data;							// cache -> cpu
	
	// Memory interface
	wire [CACHE_ADR_WIDTH-1:0] m_address;						
	wire [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockin;					// mem -> cache
	wire [DATA_WIDTH*DATA_PER_BLOCK-1:0] m_blockout;				// cache -> mem
	wire m_ready;													// memory ready -> cache
	wire m_rd, m_wr;												// cache -> memory read and write
	
	// datapath-----------------------------------------------------
	
	// CPU
	cpu_model_3_1 
		CPU		   (.rst(rst),
					.clk(clk),
					.address_bus(c_address),
					.data_bus(c_data),
					.ready(c_ready),
					.rd(c_rd),
					.wr(c_wr) );
	
	// CPU to Cache
	assign cpu2cache_data = (c_wr && !(c_rd)) ? c_data 			: {DATA_WIDTH{1'bz}};
	assign c_data		  = (c_rd && !(c_wr)) ? cache2cpu_data  : {DATA_WIDTH{1'bz}};
					
	// Cache					
	cache_sa_wb_2
				#(	.DATA_WIDTH(DATA_WIDTH),
					.ADR_WIDTH(ADR_WIDTH),
					.OFFSET_WIDTH(OFFSET_WIDTH))
		CACHE	  ( .rst(rst),
					.clk(clk),
					//cache back-en interface
					.c_address(c_address),			// cache_address
					.c_datain(cpu2cache_data),		// cache_datain
					.c_dataout(cache2cpu_data),		// cache_dataout
					.c_rd(c_rd),					// cache_rd
					.c_wr(c_wr),					// cache_wr
					.c_ready(c_ready),				// cache_ready - output2cpu
					// cache front-end interface
					.m_address(m_address),			// width(m_address) == CACHE_ADR_WIDTH 		
					.m_blockin(m_blockin),
					.m_blockout(m_blockout),
					.m_ready(m_ready),
					.m_rd(m_rd),
					.m_wr(m_wr) );
	
	// Cache to Bus
	assign m_bus_address = (m_bus_gnt) ? m_address : {CACHE_ADR_WIDTH{1'bz}};				// -> bus
	assign m_blockin = m_bus_datain;													// <- bus
	assign m_bus_dataout = (m_bus_gnt) ? m_blockout : {CACHE_ADR_WIDTH{1'bz}};			// -> bus
	assign m_bus_rd = (m_bus_gnt) ? m_rd : 1'bz;										// -> bus
	assign m_bus_wr = (m_bus_gnt) ? m_wr : 1'bz;										// -> bus
	assign m_ready = m_bus_ready;														// <- bus
	assign m_bus_req = m_rd | m_wr;
	
	
endmodule 
