/******************************************************************************/
//	Filename:		bus_2.v
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
//	A very simple bus
//	- shared bus
//	bus_2 vs bus_v1: BUS_ADR_WIDTH = CPU_ADR_WIDTH - log2(BUS_DATA_WIDTH/CPU_DATA_WIDTH) := 14 (instead of 16)
/******************************************************************************/

module bus_2( rst, clk,
			  m_bus_address, m_bus_datain, m_bus_dataout, m_bus_rd, m_bus_wr, m_bus_ready, m_bus_req, m_bus_gnt,
			  s_bus_address, s_bus_datain, s_bus_dataout, s_bus_rd, s_bus_wr, s_bus_ready );
	
	parameter BUS_DATA_WIDTH = 64;								// bus data
	parameter BUS_ADR_WIDTH = 14;								// bus address
	
	input rst, clk;								
	
	// Master interface
	input  [BUS_ADR_WIDTH-1:0] m_bus_address;					// master -> bus	- maaster address
	output [BUS_DATA_WIDTH-1:0] m_bus_datain;					// master <- bus	- master datain
	input  [BUS_DATA_WIDTH-1:0] m_bus_dataout;					// master -> bus	- master dataout
	input  m_bus_rd;											// master -> bus
	input  m_bus_wr;											// master -> bus
	output m_bus_ready;											// master <- bus
	input  m_bus_req;											// master -> bus
	output m_bus_gnt;											// master -> bus
	
	// Slave Bus interface
	output [BUS_ADR_WIDTH-1:0] s_bus_address;					// bus -> slave	- slave address
	output [BUS_DATA_WIDTH-1:0] s_bus_datain;					// bus -> slave	- slave datain
	input  [BUS_DATA_WIDTH-1:0] s_bus_dataout;					// bus <- slave	- slave dataout
	output s_bus_rd;											// bus -> slave
	output s_bus_wr;											// bus -> slave
	input  s_bus_ready;											// bus <- slave
	
	// main ------------------------------------------------------------------------------------------
	
	assign s_bus_address = m_bus_address;
	assign s_bus_datain = m_bus_dataout;
	assign m_bus_datain = s_bus_dataout;
	assign s_bus_rd = m_bus_rd;
	assign s_bus_wr = m_bus_wr;
	assign m_bus_ready = s_bus_ready;
	
	// arbiter
	arbiter ARBITER(.rst(rst),
					.clk(clk),
					.req_0(m_bus_req),
					.gnt_0(m_bus_gnt),
					.req_1(),
					.gnt_1() );
	
	
endmodule 