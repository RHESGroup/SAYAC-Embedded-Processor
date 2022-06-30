/******************************************************************************/
//	Filename:		plru_replacement.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			28 June 2022
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

module plru_replacement( rst, clk, en, update, hit_update, index, hit_way, replace_way);
	
	parameter INDEX_WIDTH = 8;
	parameter SET_WIDTH = 2;    // width of replacement output -> 2^2 = 4 way
	parameter MEM_SIZE = 1 << INDEX_WIDTH;	// 256
		
	input rst;
	input clk;
	input en;
	input update;
	input hit_update;
	input  [INDEX_WIDTH-1:0] index;
	input  [SET_WIDTH-1:0] hit_way;
	output [SET_WIDTH-1:0] replace_way;
	
	// reg & wire
	reg [2:0] history_mem [0:MEM_SIZE-1]; 	// register file for keeping and producing index for fifo policy
	integer i;
	wire [SET_WIDTH-1:0] out_way;
	
	wire   [2:0] history;
	wire  [2:0] history_in;
	wire  [SET_WIDTH-1:0] selected_way;					//
	wire  left, right;
	
	// main:
	
	decoder_1to2 DEC1 (selected_way[1], left, right);	// left:0, right:1
	
	assign history_in[2] = selected_way[1];
	assign history_in[1] = (left) ? selected_way[0] : history[1];	// left
	assign history_in[0] = (right) ? selected_way[0] : history[0];	// right
	
	assign selected_way = (hit_update) ? hit_way : out_way;
	
	assign out_way[1] = ~history[2];
	assign out_way[0] = (history[2]) ? ~history[1] : ~history[0];	// left or right
	
	always @(posedge clk)
	begin
		if (rst) begin
			for(i = 0 ; i < MEM_SIZE ; i = i+1) 
			begin
				history_mem [i] <= 3'b00; // for initialization
			end	
		end
		else if (update) begin     // when Miss accurs
			history_mem [index] <= history_in;	
		end		
    end
	assign history = history_mem [index];
/* 	always @(posedge clk)
	begin
		if (rst)
			history <= 0;
		else if (update)
			history <= history_in;			
    end */
	
	assign replace_way = (en) ? out_way : 0; 
	
endmodule 

module decoder_1to2 (in, out0, out1);
	input in;
	output reg out0;
	output reg out1;
	
	always @(in) begin
		out0 = 0;
		out1 = 0;
		case ( in )
			0 : begin
				out0 = 1;
				out1 = 0;
			end
			
			1: begin
				out0 = 0;
				out1 = 1;
			end
		endcase	
	end
	
endmodule



// just for simulation: ----------------------------------------------------------	// remove for synthesis
module tb_plru_replacement();                                                       // remove for synthesis
																					// remove for synthesis
	parameter INDEX_WIDTH = 8;
	parameter SET_WIDTH = 2;    // width of replacement output -> 2^2 = 4 way
	parameter MEM_SIZE = 1 << INDEX_WIDTH;	// 256
	// control signals:                                                             // remove for synthesis
	reg rst, clk;
	reg en;
	reg hit_update;                                                                 // remove for synthesis
	reg update;
	reg [INDEX_WIDTH-1:0] index;
																					// remove for synthesis
	// datapath signals:                                                            // remove for synthesis
	reg  [SET_WIDTH-1:0] hit_way;						//                          // remove for synthesis
	wire [SET_WIDTH-1:0] replace_way;					//                          // remove for synthesis

	plru_replacement PLRU( rst, clk, en, update, hit_update,
							index, hit_way, replace_way);
																					// remove for synthesis
																					// remove for synthesis
	initial begin                                                                   // remove for synthesis
		clk = 1;                                                                    // remove for synthesis
		rst = 0;
		en = 1;
		index = 0;
		hit_update = 0;                                                             // remove for synthesis
		update = 0;                                                                 // remove for synthesis
		hit_way = 0;                                                                // remove for synthesis
		# 10; rst = 1;                                                              // remove for synthesis
		# 10; rst = 0;                                                              // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 1; update = 1; hit_way = 2'b11;	// 3        // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis		
		@(posedge clk); hit_update = 1; update = 1; hit_way = 2'b00;	// 1        // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 1; update = 1; hit_way = 2'b10;	// 3        // remove for synthesis
																					// remove for synthesis		
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		
		//--------------------------------------------------------------------------
		index = 1;
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 1; update = 1; hit_way = 2'b11;	// 3        // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis		
		@(posedge clk); hit_update = 1; update = 1; hit_way = 2'b00;	// 1        // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis
		@(posedge clk); hit_update = 1; update = 1; hit_way = 2'b10;	// 3        // remove for synthesis
																					// remove for synthesis		
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
		@(posedge clk); hit_update = 0; update = 1;                                 // remove for synthesis
																					// remove for synthesis
																					// remove for synthesis
		$stop;	                                                                    // remove for synthesis
	end                                                                             // remove for synthesis
																					// remove for synthesis
	always                                                                          // remove for synthesis
      #5 clk = ~clk;                                                                // remove for synthesis
endmodule                                                                           // remove for synthesis