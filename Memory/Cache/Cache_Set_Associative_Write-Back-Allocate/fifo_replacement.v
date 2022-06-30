/******************************************************************************/
//	Filename:		fifo_replacement.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			27 MAY 2022
//	Authors:	 	Sepideh, Alireza
//	First Author: 	Sepideh
//  Copyright (C) 2022 University of Teheran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//

/******************************************************************************/
//	File content description:
//	Replacement Policy module: FIFO_POLICY (First In First Out)
//  When Miss occurs controller sends update to this block for 
//  increasing history_mem according to recieved index.
//  The output of this block was to select one of the 4 available sets based on the 
//  FIFO policy( first input is the first output)  
/******************************************************************************/

module fifo_replacement( rst, clk, en, update, Hit, index, hit_way, replace_way);
	
	parameter INDEX_WIDTH = 8;
	parameter SET_WIDTH = 2;    // width of replacement output -> 2^2 = 4 way
	parameter MEM_SIZE = 1 << INDEX_WIDTH;	// 256
		
	input rst;
	input clk;
	input en;
	input update;
	input Hit;
	input  [INDEX_WIDTH-1:0] index;
	input  [SET_WIDTH-1:0] hit_way;
	output [SET_WIDTH-1:0] replace_way;
	
	reg [SET_WIDTH-1:0] history_mem [0:MEM_SIZE-1]; // register file for keeping and producing index for fifo policy
	integer i;
	
	always @(posedge clk)
	begin
		if (rst) begin
			for(i = 0 ; i < MEM_SIZE ; i = i+1) 
			begin
				history_mem [i] <= 2'b00; // for initialization
			end	
		end
		else if (update&&(!Hit)) begin     // when Miss accurs
			history_mem [index] <= history_mem [index] + 2'b01;	
		end
		
			
    end
	
	assign replace_way = (en) ? history_mem [index] : 0; 
	
endmodule 