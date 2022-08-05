/******************************************************************************/
//	Filename:		cpu_model_3.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		3.000
//	History:		-
//	Date:			21 June 2022
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
//	dot product example
/******************************************************************************/


`define BASE_ADDR_A  16'h0100
`define BASE_ADDR_B  16'h0200
`define BASE_ADDR_AB  16'h0400
		
module cpu_model_3( rst, clk,
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
	
	reg  [ADR_WIDTH-1:0]  address_reg;
	reg  [DATA_WIDTH-1:0] data_reg;				// write data
	reg [DATA_WIDTH-1:0] read_data_reg;			// read data
	
	
	reg [DATA_WIDTH-1:0] reg_file [0:15];
	reg [DATA_WIDTH-1:0] A [0:15];
	reg [DATA_WIDTH-1:0] B [0:15];
	integer i, j;
	
	// ------------------------------------------------------------
	// `WRITE(ADR, DATA)
	task WRITE( input [ADR_WIDTH-1:0] ADR, input [DATA_WIDTH-1:0] DATA );
	begin
		@(posedge clk);
		rd = 0; 
		wr = 1;
		address = ADR;
		data = DATA;
		@(posedge ready);
	end
	endtask
	// `READ(ADR, DATA)
	task READ(input [ADR_WIDTH-1:0] ADR, output [DATA_WIDTH-1:0] DATA );
	begin
		@(posedge clk);
		rd = 1; 
		wr = 0;
		address = ADR;
		@(posedge ready);
		DATA = data_bus;
	end
	endtask
	// `NOP
	task NOP();
	begin
		@(posedge clk);
		rd = 0; wr = 0;
	end
	endtask
	
	// ------------------------------------------------------------
	assign data_bus = (wr) ? data : 16'hzzzz;
	assign address_bus = (wr || rd) ? address : 16'hzzzz;
	
	initial begin
		rd = 0;
		wr = 0;
		
		for (i=0; i<16; i=i+1)
			reg_file[i] = 0;
		
		for (i=0; i<16; i=i+1) begin
				A[i] = i-5;
				B[i] = 8-i;
		end
		
		
		@(posedge rst);
		@(negedge rst);
		
		for (i=0; i<16; i=i+1) begin
			WRITE(`BASE_ADDR_A + i, A[i]);
		end
		for (i=0; i<16; i=i+1) begin
			WRITE(`BASE_ADDR_B+i, B[i]);
		end
		for (i=0; i<16; i=i+1) begin
			READ(`BASE_ADDR_A+i, reg_file[0]);
			//reg_file[0] = read_data_reg;
			READ(`BASE_ADDR_B+i, reg_file[1]);
			//reg_file[1] = read_data_reg;
			
			reg_file[2] = reg_file[2] + (reg_file[0] * reg_file[1]);
			NOP();
		end
		WRITE(`BASE_ADDR_AB, reg_file[2]);
		NOP();
		
		$stop;	
	end
	
	
	
	
endmodule 