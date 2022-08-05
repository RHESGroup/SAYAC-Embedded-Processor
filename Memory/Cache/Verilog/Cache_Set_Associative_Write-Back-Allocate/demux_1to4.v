/******************************************************************************/
//	Filename:		demux_1to4.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			25 June 2022
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
//	a simple demultiplexer 1 to 4 ( 2-bit select)
/******************************************************************************/
module demux_1to4 (in, sel, out);
	input in;
	input [1:0] sel;
	output reg [3:0] out;
	
	always @(in, sel) begin
		out = 0;
		case ( sel )
			0 : begin
				out[0] = in;
			end
			1 : begin
				out[1] = in;
			end
			2 : begin
				out[2] = in;
			end
			3 : begin
				out[3] = in;
			end
		endcase	
	end
	
endmodule