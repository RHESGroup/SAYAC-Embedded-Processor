/******************************************************************************/
//	Filename:		cpu_model_3_1.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		3.100
//	History:		-
//	Date:			27 June 2022
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


// `define BASE_ADDR_A  16'h0100

module cpu_model_3_1( rst, clk,
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
		
		@(posedge rst);
		@(negedge rst);
		
		
		WRITE(0, 16'd888);
		WRITE(1, 16'd111);
		WRITE(2, 16'd222);
		WRITE(3, 16'd333);
		
		READ(1024, reg_file[0]);
		WRITE(1025, 16'd777);
		READ(1025, reg_file[0]);
		READ(1027, reg_file[0]);
		
		READ(2047, reg_file[0]);
		WRITE(2049, 16'd555);
		
		READ(3072, reg_file[0]);
		
		READ(4096, reg_file[0]);
		
		READ(2048, reg_file[0]);
		
		WRITE(0, 16'd444);
		
		READ(5120, reg_file[0]);
		
		READ(1024, reg_file[0]);
		
		READ(7168, reg_file[0]);
		
		READ(9216, reg_file[0]);
		
		NOP();
		NOP();
		NOP();
		NOP();
		
		$stop;	
	end
	
	
	
	
endmodule 