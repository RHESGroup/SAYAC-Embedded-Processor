/******************************************************************************/
//	Filename:		decoder_2to4.v
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
//	a simple decoder 2 to 4
/******************************************************************************/
module decoder_2to4 (in, out);
	input [1:0] in;
	output reg [3:0] out;
	
	always @(in) begin
		out = 0;
		case ( in )
			0 : begin
				out = 4'b0001;
			end
			1 : begin
				out = 4'b0010;
			end
			2 : begin
				out = 4'b0100;
			end
			3 : begin
				out = 4'b1000;
			end
		endcase	
	end
	
endmodule