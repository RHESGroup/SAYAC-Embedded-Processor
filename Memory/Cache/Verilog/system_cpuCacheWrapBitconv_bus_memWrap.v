/******************************************************************************/
//	Filename:		system_cpuCacheWrapBitconv_bus_memWrap.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		2.000
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
//	(A cpu model + cache (WB) + wrapper + bit_convertoer(16-bit)) + Bus(16-bit) + (memory_model(16-bit))
/******************************************************************************/

module system_cpuCacheWrapBitconv_bus_memWrap( );
	
	// BUS
	parameter BUS_DATA_WIDTH = 16;										// bus data
	parameter BUS_ADR_WIDTH = 16;										// bus address
	// CACHE
	parameter CACHE_DATA_WIDTH = 64;									// cache data
	parameter CACHE_ADR_WIDTH = 14;										// cache address
	// CPU
	parameter DATA_WIDTH = 16;											// cpu data
	parameter ADR_WIDTH = 16;											// cpu address
	parameter OFFSET_WIDTH = 2;											// 4 data per block -> block_width = 4 * 16 = 64
	// Memory
	parameter MEM_DELAY_FACTOR = 2;
	
	// System
	reg rst, clk;								
	
	// CPU(Master) to Bus interface
	wire [BUS_ADR_WIDTH-1:0] m_bus_address;						
	wire [BUS_DATA_WIDTH-1:0] m_bus_datain;					// cpu <- bus	- cpu datain
	wire [BUS_DATA_WIDTH-1:0] m_bus_dataout;				// cpu -> bus	- cpu dataout
	wire m_bus_rd;											// cpu -> bus
	wire m_bus_wr;											// cpu -> bus
	wire m_bus_ready;										// cpu <- bus
	wire m_bus_req;											// cpu -> bus
	wire m_bus_gnt;											// cpu -> bus
	
	// Memory(Slave) to Bus interface
	wire [BUS_ADR_WIDTH-1:0] s_bus_address;						
	wire [BUS_DATA_WIDTH-1:0] s_bus_datain;					// bus -> mem	- mem datain
	wire [BUS_DATA_WIDTH-1:0] s_bus_dataout;				// bus <- mem	- mem dataout
	wire s_bus_rd;											// bus -> mem
	wire s_bus_wr;											// bus -> mem
	wire s_bus_ready;										// bus <- mem
	
	// main ------------------------------------------------------------------------------------------
	
	// CPU(cache wrapped)
	cpu_cache_wrap_bitconv 
				#(	.BUS_DATA_WIDTH(BUS_DATA_WIDTH),
					.BUS_ADR_WIDTH(BUS_ADR_WIDTH),
					.CACHE_DATA_WIDTH(CACHE_DATA_WIDTH),
					.CACHE_ADR_WIDTH(CACHE_ADR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.ADR_WIDTH(ADR_WIDTH),
					.OFFSET_WIDTH(OFFSET_WIDTH))
		CPU_CACHE_WRAP_BITCONV
				(	.rst(rst),
					.clk(clk),
					.m_bus_address(m_bus_address),
					.m_bus_datain(m_bus_datain),
					.m_bus_dataout(m_bus_dataout),
					.m_bus_rd(m_bus_rd),
					.m_bus_wr(m_bus_wr),
					.m_bus_ready(m_bus_ready),
					.m_bus_req(m_bus_req),
					.m_bus_gnt(m_bus_gnt) );

	// BUS
	bus_2
				#(	.BUS_DATA_WIDTH(BUS_DATA_WIDTH),
					.BUS_ADR_WIDTH(BUS_ADR_WIDTH) )
		BUS
				(	.rst(rst),
					.clk(clk),
					// Master:
					.m_bus_address(m_bus_address),
					.m_bus_datain(m_bus_datain),
					.m_bus_dataout(m_bus_dataout),
					.m_bus_rd(m_bus_rd),
					.m_bus_wr(m_bus_wr),
					.m_bus_ready(m_bus_ready),
					.m_bus_req(m_bus_req),
					.m_bus_gnt(m_bus_gnt),
					// Slave:
					.s_bus_address(s_bus_address),
					.s_bus_datain(s_bus_datain),
					.s_bus_dataout(s_bus_dataout),
					.s_bus_rd(s_bus_rd),
					.s_bus_wr(s_bus_wr),
					.s_bus_ready(s_bus_ready) );
	
	// Memory
	memory_model_3
				#(	.DATA_WIDTH(BUS_DATA_WIDTH),
					.ADR_WIDTH(BUS_ADR_WIDTH),
					.DELAY_FACTOR(MEM_DELAY_FACTOR))
		MEM		  ( .rst(rst),
					.clk(clk),
					.address(s_bus_address),
					.datain(s_bus_datain),
					.dataout(s_bus_dataout),
					.ready(s_bus_ready),
					.rd(s_bus_rd),
					.wr(s_bus_wr) );
	
	initial begin
		clk = 0;
		rst = 0;
		# 10; rst = 1;
		# 10; rst = 0;
	end
	
	always
      #5 clk = ~clk;
	
	
endmodule 
