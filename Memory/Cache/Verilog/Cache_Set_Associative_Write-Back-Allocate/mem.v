/******************************************************************************/
//	Filename:		mem.v
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
//	A simple single port SRAM memory
//	one cycle to write & combinational read
//	sel signal : activate the memory (chip select)
//	rd & wr : only one of them can be issued
/******************************************************************************/

module mem( clk, sel, rd, wr, address, datain, dataout );
	
	parameter ADR_WIDTH = 8;
	parameter DATA_WIDTH = 16;
	parameter MEM_SIZE = 1 << ADR_WIDTH;	// 256
	
	input clk, sel, rd, wr;
	input  [ADR_WIDTH-1:0]  address;
	input  [DATA_WIDTH-1:0] datain;
	output [DATA_WIDTH-1:0] dataout;
	
	reg [DATA_WIDTH-1:0] data [0:MEM_SIZE-1];
	
	integer i;
	
	// only for simulation:						// Delete for Synthesis
	initial begin								// Delete for Synthesis
		for (i=0; i<MEM_SIZE; i=i+1)			// Delete for Synthesis
			data[i] <= 0;//$random;				// Delete for Synthesis
	end	

	always @(posedge clk)
		if (sel && wr)
			data[address] <= datain;

	assign dataout = (sel && rd) ? data[address] : {DATA_WIDTH{1'bz}};
   
endmodule 