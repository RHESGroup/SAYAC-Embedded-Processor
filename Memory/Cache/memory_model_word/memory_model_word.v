/******************************************************************************/
//	Filename:		memory_model_word.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			12 June 2022
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
//	A memory model with a word level = 16-bit intefrace
//	it has a DELAY_FACTOR (read and write after around 2^DELAY_FACTOR clk cycle)
/******************************************************************************/

`define	IDLE				0
`define	WAIT_MEM			1
`define	DONE_MEM			2

module memory_model_word( rst, clk,
					address, datain, dataout,
					ready, rd, wr);
	
	parameter DATA_WIDTH = 16;										// cpu data
	parameter ADR_WIDTH = 16;										// cpu address
	parameter DELAY_FACTOR = 2;
	parameter MEM_SIZE = 1 << ADR_WIDTH;							// 1024
	
	input rst, clk;								
	
	input  [ADR_WIDTH-1:0] address;						
	input  [DATA_WIDTH-1:0] datain;	
	output [DATA_WIDTH-1:0] dataout;
	
	output reg ready;												// memory ready
	input  rd, wr;													// memory read and write
	
	// reg & wires--------------------------------------------------
	reg [DATA_WIDTH-1:0] data [0:MEM_SIZE-1];
	
	reg [ADR_WIDTH-1:0] adr_reg;
	reg [DATA_WIDTH-1:0] data_reg;
	
	reg [1:0] ps, ns;
	reg [DELAY_FACTOR-1:0] count;										// OFFSET_WIDTH-1
	reg mem_wait, inc, ld_adr;
	wire co;
	
	// datapath-----------------------------------------------------
	// WRITE & READ: first part -> data_reg
	always @(posedge clk) begin: DATA_REG
		if (rst)
			data_reg <= 0;
		else if (wr)
			data_reg <= datain;
		else if (rd)
			data_reg <= data[adr_reg];
	end
	
	// WRITE: second part
	always @(posedge clk) begin: WRITE_CMPLT
		if (wr && co)
			data[adr_reg] <= data_reg;
	end
	
	// READ: second part
	assign dataout = (!mem_wait && rd) ? data_reg : {DATA_WIDTH{1'bz}};
	
	// adr_reg:
	always @(posedge clk) begin: ADR_REG
		if (rst)
			adr_reg <= 0;
		else if (ld_adr)
			adr_reg <= address;
	end
	
	// counter (for controller):
	always @(posedge clk) begin: COUNTER
		if (rst)
			count <= 0;
		else if (inc)
			count <= count + 1;
	end
	assign co = &count;
	
	// controller--------------------------------------------------
	// present state - sequential logic
	always @(posedge clk ) begin
		if( rst )
			ps <= `IDLE;
		else
			ps <= ns;
	end
	// next state - combinational logic
	always @( ps, rd, wr, co ) begin
		ns = `IDLE;		// ns inactive value:
		case ( ps )
			`IDLE : begin
				if( rd || wr )
					ns = `WAIT_MEM;
				else
					ns = `IDLE;
			end
			`WAIT_MEM : begin
				if( co )
					ns = `DONE_MEM;
				else
					ns = `WAIT_MEM;
			end
			`DONE_MEM : begin
				ns = `IDLE;
			end
		endcase
	end
	// output signals - combinational logic
	always @( ps ) begin
		mem_wait = 0;							
		inc = 0;
		ready = 0;
		ld_adr = 0;
		case ( ps )
			`IDLE : begin
				mem_wait = 1;
				ld_adr = 1;
			end
			`WAIT_MEM : begin
				inc = 1;
				mem_wait = 1;
			end
			`DONE_MEM : begin
				ready = 1;
			end
		endcase
	end
endmodule 