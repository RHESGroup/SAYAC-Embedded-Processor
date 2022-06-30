/******************************************************************************/
//	Filename:		arbiter.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			8 June 2022
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
//	A very simple bus "arbiter"
//	proiority-based: DEVICE_0, DEVICE_1, ...
/******************************************************************************/

`define	IDLE		0
`define	DEVICE_0	1
`define	DEVICE_1	2

module arbiter( rst, clk,
				req_0, gnt_0, req_1, gnt_1);
	
	input rst, clk;								
	
	// device 0
	input req_0;
	output reg gnt_0;
	
	// device 1
	input req_1;
	output reg gnt_1;
	
	reg [1:0] ps, ns;
	// main ------------------------------------------------------------------------------------------
	// present state - sequential logic
	always @(posedge clk ) begin
		if( rst )
			ps <= `IDLE;
		else
			ps <= ns;
	end
	// next state - combinational logic
	always @( ps, req_0, req_1 ) begin
		ns = `IDLE;		// ns inactive value:
		case ( ps )
			`IDLE : begin
				if( req_0 )
					ns = `DEVICE_0;
				else if (req_1)
					ns = `DEVICE_1;
				else
					ns = `IDLE;
			end
			
			`DEVICE_0: begin
				if( req_0 )
					ns = `DEVICE_0;
				else
					ns = `IDLE;
			end
			
			`DEVICE_1: begin
				if( req_1 )
					ns = `DEVICE_1;
				else
					ns = `IDLE;
			end
			
		endcase
	end
			
	// output signals - combinational logic
	always @( ps ) begin
		// inactive values:
		gnt_0 = 0;
		gnt_1 = 0;

		case ( ps )
			`IDLE : begin
				gnt_0 = 0;
				gnt_1 = 0;
			end
			
			`DEVICE_0: begin
				gnt_0 = 1;
			end
			
			`DEVICE_1 : begin
				gnt_1 = 1;
			end

		endcase
	end
	
	// arbiter
	
	
	
endmodule 
