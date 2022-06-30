/******************************************************************************/
//	Filename:		cpu_model_1.v
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
//	A cpu model (SAYAC)
/******************************************************************************/

`define WRITE(ADR, DATA) @(posedge clk); rd = 0; wr = 1; address = ADR; dataout = DATA; @(posedge ready);					// `WRITE(ADR, DATA)
`define READ(ADR) @(posedge clk); rd = 1; wr = 0; address = ADR; dataout = 16'hzzzz; @(posedge ready);						// `READ(ADR)
`define NOP @(posedge clk); rd = 0; wr = 0; address = 16'hzzzz;	dataout = 16'hzzzz;											// `NOP
		
module cpu_model_1( rst, clk,
					address, datain, dataout,
					ready, rd, wr);
	
	parameter DATA_WIDTH = 16;										// cpu data
	parameter ADR_WIDTH = 16;										// cpu address
	parameter OFFSET_WIDTH = 2;										// 4 data per block -> block_width = 4 * 16 = 64
	parameter MEM_SIZE = 1 << ADR_WIDTH;							// 1024
	parameter DATA_PER_BLOCK = 1 << OFFSET_WIDTH;					// DATA_PER_BLOCK = 4
	
	input rst, clk;								
	
	output reg [ADR_WIDTH-1:0] address;						
	input  [DATA_WIDTH-1:0] datain;									// cpu reads datain from mem
	output reg [DATA_WIDTH-1:0] dataout;							// cpu writes dataout to mem
	input  ready;													// memory ready
	output reg rd, wr;												// cpu read and write
	
	reg [DATA_WIDTH-1:0] data_reg;
	
	initial begin
		rd = 0;
		wr = 0;
		address = 16'hzzz;
		dataout = 16'hzzz;
		
		@(posedge rst);
		@(negedge rst);

		// `WRITE(ADR, DATA)
		// data_reg = `READ(ADR)
		
		`WRITE(16'h0010, 16'h0751)	
		`NOP
		`NOP
		`WRITE(16'h0011, 16'h1111)	
		`WRITE(16'h0012, 16'h2222)	
		`READ(16'h0010)
		`READ(16'h0011)
		`NOP
		`READ(16'h0012)
		`NOP
		
		$stop;	
	end
	
	
endmodule 
