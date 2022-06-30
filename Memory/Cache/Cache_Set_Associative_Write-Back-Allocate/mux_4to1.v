/******************************************************************************/
//	Filename:		mux_4to1.v
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
//	a simple multiplexer 4 to 1 ( 2-bit select)
/******************************************************************************/
module mux_4to1 (in, sel, out);
	input [3:0] in;
	input [1:0] sel;
	output reg out;
	
	always @(in, sel) begin
		out = 0;
		case ( sel )
			0 : begin
				out = in[0];
			end
			1 : begin
				out = in[1];
			end
			2 : begin
				out = in[2];
			end
			3 : begin
				out = in[3];
			end
		endcase	
	end
	
endmodule