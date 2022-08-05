/******************************************************************************/
//	Filename:		cpu_cache_wrap_bitconv.v
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
//	CPU + cache(dm_wb) + bus interface + bit_convertor (64->16)
/******************************************************************************/

module cpu_cache_wrap_bitconv( rst, clk,
					m_bus_address, m_bus_datain, m_bus_dataout,
					m_bus_rd, m_bus_wr, m_bus_ready,
					m_bus_req, m_bus_gnt);
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
	
	input rst;
	input clk;								
	
	// Master_Bus_Inerface
	output [BUS_ADR_WIDTH-1:0] m_bus_address;							// master address to Bus					
	input  [BUS_DATA_WIDTH-1:0] m_bus_datain;							// master datain from bus
	output [BUS_DATA_WIDTH-1:0] m_bus_dataout;							// master dataout to bus
	output m_bus_rd;													// master read to bus
	output m_bus_wr;													// master write to bus
	input  m_bus_ready;													// master ready to bus
	
	output m_bus_req;													// master request to bus
	input  m_bus_gnt;													// master grant from bus
	
	// reg & wires--------------------------------------------------
	
	// cpu_cahce_wrap (Cache) -> bit_converter
	wire [CACHE_ADR_WIDTH-1:0]  m_address;							// master address to Bus					
	wire [CACHE_DATA_WIDTH-1:0] m_datain;							// master datain from bus
	wire [CACHE_DATA_WIDTH-1:0] m_dataout;							// master dataout to bus
	wire m_rd;														// master read to bus
	wire m_wr;														// master write to bus
	wire m_ready;													// master ready to bus
	
	// CPU interface
	wire [ADR_WIDTH-1:0] c_address;						
	wire [DATA_WIDTH-1:0] c_data;									// cpu <-> cache
	wire c_ready;													// cache -> cpu
	wire c_rd, c_wr;
	
	
	// datapath-----------------------------------------------------
	
	// CPU_cache_wrap
	cpu_cache_wrap_x 
				#(	.CACHE_DATA_WIDTH(CACHE_DATA_WIDTH),
					.CACHE_ADR_WIDTH(CACHE_ADR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.ADR_WIDTH(ADR_WIDTH),
					.OFFSET_WIDTH(OFFSET_WIDTH))
		CPU_CACHE_WRAP
				(	.rst(rst),
					.clk(clk),
					.m_bus_address(m_address),
					.m_bus_datain(m_datain),
					.m_bus_dataout(m_dataout),
					.m_bus_rd(m_rd),
					.m_bus_wr(m_wr),
					.m_bus_ready(m_ready),
					.m_bus_req(m_bus_req),
					.m_bus_gnt(m_bus_gnt) );
	
	// CPU_cache_wrap -> bit_converter
	
	// bit_converter
	bit_converter
				#(	.MASTER_DATA_WIDTH(CACHE_DATA_WIDTH),
					.MASTER_ADR_WIDTH(CACHE_ADR_WIDTH),
					.SLAVE_DATA_WIDTH(BUS_DATA_WIDTH),
					.SLAVE_ADR_WIDTH(BUS_ADR_WIDTH) )
		BIT_CONV
				( 	.rst(rst),
					.clk(clk),
					// from Cache
					.m_address(m_address),
					.m_dataout(m_dataout),
					.m_datain(m_datain),
					.m_ready(m_ready),
					.m_rd(m_rd),
					.m_wr(m_wr),
					// BUS (this module interface)
					.s_address(m_bus_address),
					.s_datain(m_bus_dataout),
					.s_dataout(m_bus_datain),
					.s_ready(m_bus_ready),
					.s_rd(m_bus_rd),
					.s_wr(m_bus_wr) );
	
	
	
	
endmodule 
