/******************************************************************************/
//	Filename:		encoder_4to2.v
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
//	a simple encoder 4 to 2
/******************************************************************************/
module encoder_4to2 (in, out);
	input [3:0] in;
	output reg [1:0] out;
	
	always @(in) begin
		out = 2'b00;
		case ( in )
			4'b0001 : begin
				out = 2'b00;
			end
			4'b0010 : begin
				out = 2'b01;
			end
			4'b0100 : begin
				out = 2'b10;
			end
			4'b1000 : begin
				out = 2'b11;
			end
			default	: begin
				out = 2'b00;
			end
		endcase	
	end
	
endmodule