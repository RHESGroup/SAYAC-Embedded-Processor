/******************************************************************************/
//	Filename:		cpu_sayac_model_1.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			7 June 2022
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
//	A cpu model (SAYAC)
/******************************************************************************/

`define WRITE(ADR, DATA) @(posedge clk); rd = 0; wr = 1; address = ADR; data = DATA; @(posedge ready);			// `WRITE(ADR, DATA)
`define READ(ADR) @(posedge clk); rd = 1; wr = 0; address = ADR; @(posedge ready); read_data_reg = data_bus;	// `READ(ADR)
`define NOP @(posedge clk); rd = 0; wr = 0;																		// `NOP
		
module cpu_sayac_model_1( rst, clk,
					address_bus, data_bus,
					ready, rd, wr);
	
	parameter DATA_WIDTH = 16;										// cpu data
	parameter ADR_WIDTH = 16;										// cpu address
	parameter OFFSET_WIDTH = 2;										// 4 data per block -> block_width = 4 * 16 = 64
	parameter MEM_SIZE = 1 << ADR_WIDTH;							// 1024
	parameter DATA_PER_BLOCK = 1 << OFFSET_WIDTH;					// DATA_PER_BLOCK = 4
	
	input rst, clk;								
	
	output [ADR_WIDTH-1:0] address_bus;						
	inout  [DATA_WIDTH-1:0] data_bus;								// cpu read & write data
	input  ready;													// memory ready
	output reg rd, wr;												// cpu read and write
	
	reg  [DATA_WIDTH-1:0] data;
	reg  [ADR_WIDTH-1:0]  address;	
	
	reg [DATA_WIDTH-1:0] read_data_reg;
	
	// ------------------------------------------------------------
	assign data_bus = (wr) ? data : 16'hzzzz;
	assign address_bus = (wr || rd) ? address : 16'hzzzz;
	
	initial begin
		rd = 0;
		wr = 0;
		
		@(posedge rst);
		@(negedge rst);

		// `WRITE(ADR, DATA)
		// data_reg = `READ(ADR)
		
		`WRITE(16'h0010, 16'h1001)	
		`NOP
		`NOP
		`WRITE(16'h0011, 16'h1101)	
		`WRITE(16'h0012, 16'h1201)	
		`READ(16'h0010)
		`READ(16'h0011)
		`NOP
		`READ(16'h0012)
		`NOP
		`WRITE(16'h0012, 16'h1202)	
		`WRITE(16'h0013, 16'h1302)	
		`WRITE(16'h0017, 16'h1701)	
		`WRITE(16'h0015, 16'h1501)	
		`READ(16'h0012)
		`READ(16'h0013)
		`READ(16'h0017)
		`READ(16'h0015)
		
		`WRITE(16'h1010, 16'h10a1)	
		`WRITE(16'h1011, 16'h11a1)	
		`WRITE(16'h1012, 16'h12a1)	
		`WRITE(16'h1013, 16'h13a1)	
		`READ(16'h1012)
		`READ(16'h1013)
		
		`WRITE(16'h1015, 16'h15a1)	
		`WRITE(16'h1017, 16'h17a1)	
		`READ(16'h1015)
		`READ(16'h1017)
		
		`READ(16'h0015)
		`READ(16'h0017)
		
		$stop;	
	end
	
	
endmodule 