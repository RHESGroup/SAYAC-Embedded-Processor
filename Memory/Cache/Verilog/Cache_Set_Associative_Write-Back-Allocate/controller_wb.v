/******************************************************************************/
//	Filename:		controller_wb.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		1.000
//	History:		-
//	Date:			28 June 2022
//	Authors:	 	Alireza, Sepideh
//	Last Author: 	Alireza
//  Copyright (C) 2022 University of Teheran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//

/******************************************************************************/
//	File content description:
//	set associative cache controller
//	Write-Back (Write-Allocate Policy): 
//		if Miss ->
//			read block from mem (hope of Hit in future)
//			write to cache and dirty_wr (from CPU)
//		if Hit -> 
//			write to cache and dirty_wr (from CPU)
//		----------------------------------------------------
//		if read block from mem to cache (READ_MISS, WRITE_MISS) ->
//			if valid & dirty ->
//				write block to mem (from cache)
//	moore controller: (output signals only depend on current state)
/******************************************************************************/

`define	IDLE							0
`define	READ_HIT						1
`define	READ_MISS_DIRTY_WRITETOMEM		2
`define	READ_MISS_WAIT					3
`define	READ_MISS_DONE					4
`define	READ_MISS						5
`define	WRITE_HIT						6
`define	WRITE_MISS_DIRTY_WRITETOMEM		7
`define	WRITE_MISS_ALLOCATE_WAIT		8
`define	WRITE_MISS_ALLOCATE_DONE		9
`define	WRITE_MISS						10

module controller_wb(rst, clk,
					 Hit, valid, dirty_wr, dirty, sel_all, rd, wr,
					 d_on_cpu, d_on_mem, adr_on_mem, drt_adr_on_mem,
					 update, en_replacement,
					 c_rd, c_wr, c_ready,
					 m_ready, m_rd, m_wr);                    
	// system                                         
	input rst, clk;	
	
	// datapath interface:
	input Hit;										// CM output, [from datapath]
	input valid;									// CM output, [from datapath]
	output reg dirty_wr;							// CM inputs, [to datapath]
	input dirty;									// CM output, [from datapath]
	output reg sel_all, rd, wr;						// CM inputs, [to datapath]
	output reg d_on_cpu, d_on_mem, adr_on_mem;		// tri-state buff, data or address on buss or not, [to datapath]
	output reg drt_adr_on_mem;						// dirty address on memory address buss
		// for set-associative
	output reg update;                              // to datapath (For replacement block when Miss accurs)
	output en_replacement;							// to replacement policy module
	
	// CPU interface:
	input c_rd, c_wr;								// cache read and write, [cpu interface]
	output reg c_ready;								// cache ready, [cpu interface]
	
	// Mem interface:
	input m_ready;									// memory ready, [mem interface]
	output reg m_rd, m_wr;							// memory read and write, [mem interface]
	
	
	reg [3:0] ps, ns;								// present state and next state, 8 state -> 3-bit so if any more state is needed widh must be increased.
	
	assign en_replacement = c_rd | c_wr;
	
	// present state - sequential logic
	always @(posedge clk ) begin
		if( rst )
			ps <= `IDLE;
		else
			ps <= ns;
	end
	
	// next state - combinational logic
	always @( ps, c_rd, c_wr, m_ready, Hit, valid, dirty ) begin
		
		ns = `IDLE;	//0	// ns inactive value:
		case(ps)
			`IDLE : begin //1
				if( c_rd && Hit )
					ns = `READ_HIT;
				else if ( c_rd && !(Hit) && (valid && dirty) )
					ns = `READ_MISS_DIRTY_WRITETOMEM;
				else if ( c_rd && !(Hit) && !(valid && dirty) )
					ns = `READ_MISS_WAIT;
				else if ( c_wr && Hit )
					ns = `WRITE_HIT;
				else if ( c_wr && !(Hit) && (valid && dirty) )
					ns = `WRITE_MISS_DIRTY_WRITETOMEM;
				else if ( c_wr && !(Hit) && !(valid && dirty) )
					ns = `WRITE_MISS_ALLOCATE_WAIT;
				else
					ns = `IDLE;
			end
			`READ_HIT: begin //2
				ns = `IDLE;
			end
						
			`READ_MISS_DIRTY_WRITETOMEM : begin //3
				if( m_ready )
					ns = `READ_MISS_WAIT;
				else
					ns = `READ_MISS_DIRTY_WRITETOMEM;
			end
			
			`READ_MISS_WAIT : begin //4
				if( m_ready )
					ns = `READ_MISS_DONE;
				else
					ns = `READ_MISS_WAIT;
			end
			
			`READ_MISS_DONE : begin //5
				ns = `READ_MISS;
			end
			
			`READ_MISS : begin //6
				ns = `IDLE;
			end
			
			`WRITE_HIT: begin //7
				ns = `IDLE;
			end
			
			`WRITE_MISS_DIRTY_WRITETOMEM : begin //8
				if( m_ready )
					ns = `WRITE_MISS_ALLOCATE_WAIT;
				else
					ns = `WRITE_MISS_DIRTY_WRITETOMEM;
			end
			
			`WRITE_MISS_ALLOCATE_WAIT : begin //9
				if( m_ready )
					ns = `WRITE_MISS_ALLOCATE_DONE;
				else
					ns = `WRITE_MISS_ALLOCATE_WAIT;
			end
			
			`WRITE_MISS_ALLOCATE_DONE : begin //10
				ns = `WRITE_MISS;
			end
			
			`WRITE_MISS : begin //11
				ns = `IDLE;
			end
			
		endcase
	end
			
	// output signals - combinational logic
	always @( ps, Hit ) begin
		// inactive values:
		c_ready = 0;							
		sel_all	= 0;
		rd = 0;
		wr = 0;	
		dirty_wr = 0;
		m_rd = 0;
		m_wr = 0;						
		d_on_cpu = 0;
		d_on_mem = 0;
		adr_on_mem = 0;
		drt_adr_on_mem = 0;
		update = 0;

		case ( ps )
			`IDLE : begin //0
				rd = 1;
			end
			//---------------------------------------
			//---------------------------------------
			`READ_HIT: begin //2
				rd = 1;
				d_on_cpu = 1;
				c_ready = 1;
				update = 1;
			end
			//---------------------------------------
			`READ_MISS_DIRTY_WRITETOMEM : begin //3
				m_wr = 1;
				drt_adr_on_mem = 1;
				d_on_mem = 1;
				rd = 1;
				sel_all = 1;
			end
			
			`READ_MISS_WAIT : begin //4
				m_rd = 1;
				adr_on_mem = 1;
			end
			
			`READ_MISS_DONE : begin //5
				sel_all = 1;
				wr = 1;
				//m_rd = 1;			// ?
				//adr_on_mem = 1;		// ?
				update = 1;
			end
			
			`READ_MISS: begin //6
				rd = 1;
				d_on_cpu = 1;
				c_ready = 1;
			end
			//---------------------------------------
			//---------------------------------------
			`WRITE_HIT : begin //7
				wr = 1;
				rd = 1;					// new 6/29
				dirty_wr = 1;
				c_ready = 1;
				update = 1;
			end
			//---------------------------------------
			`WRITE_MISS_DIRTY_WRITETOMEM : begin //8
				m_wr = 1;
				drt_adr_on_mem = 1;
				d_on_mem = 1;
				rd = 1;
				sel_all = 1;
			end
			
			`WRITE_MISS_ALLOCATE_WAIT : begin //9
				m_rd = 1;
				adr_on_mem = 1;
			end
			
			`WRITE_MISS_ALLOCATE_DONE : begin //10
				sel_all = 1;
				wr = 1;
				//m_rd = 1;			// ?
				//adr_on_mem = 1;		// ?
				update = 1;
			end
			
			`WRITE_MISS : begin //11
				wr = 1;
				rd = 1;					// new 6/29
				c_ready = 1;
				dirty_wr = 1;
			end

		endcase
	end
	
endmodule 