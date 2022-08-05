/******************************************************************************/
//	Filename:		bit_converter.v
//	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
//  Version:		2.000
//	History:		-
//	Date:			26 June 2022
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
//	bit_converter: convert DATA_WIDTH & ADR_WIDTH between a pir of {master, slave}
//	it transfer data between maaster and slave with different width
/******************************************************************************/

`define	IDLE				0
`define	WRITE_0				1
`define	WRITE_LOOP			2
`define	WRITE_WAIT_SLAVE	3
`define	WRITE_DONE			4
`define	READ_LOOP			5
`define	READ_WAIT_SLAVE		6
`define	READ_DONE			7

module bit_converter( 	rst, clk,
						m_address, m_dataout, m_datain, m_ready, m_rd, m_wr,
						s_address, s_datain, s_dataout, s_ready, s_rd, s_wr );
	
	parameter SLAVE_DATA_WIDTH = 16;
	parameter MASTER_DATA_WIDTH = 64;			// assert: MASTER_DATA_WIDTH = K *  SLAVE_DATA_WIDTH, K is an integer
	parameter SLAVE_ADR_WIDTH = 16;
	parameter MASTER_ADR_WIDTH = 14;
	
	parameter TRANS_COUNT = MASTER_DATA_WIDTH / SLAVE_DATA_WIDTH;
	parameter COUNTER_WIDTH = SLAVE_ADR_WIDTH - MASTER_ADR_WIDTH;
	
	input rst, clk;								
	
	// in or out refer to the device (master or slave)
	
	// Master interface
	input  [MASTER_ADR_WIDTH-1:0] m_address;							// master	-> converter
	input  [MASTER_DATA_WIDTH-1:0] m_dataout;							// master  	-> converter
	output [MASTER_DATA_WIDTH-1:0] m_datain;							// converter-> master
	output reg m_ready;													// converter-> master
	input  m_rd, m_wr;													// master  	-> converter
	// Slave interface
	output [SLAVE_ADR_WIDTH-1:0] s_address;								// converter-> slave
	output [SLAVE_DATA_WIDTH-1:0] s_datain;								// converter-> slave
	input  [SLAVE_DATA_WIDTH-1:0] s_dataout;							// slave  	-> converter
	input  s_ready;														// slave  	-> converter
	output reg s_wr;														// converter-> slave
	output reg s_rd;														// converter-> slave
	
	// reg & wires--------------------------------------------------
	
	reg [SLAVE_DATA_WIDTH-1:0] buf_reg [0:TRANS_COUNT-1];
	wire ld_buf [0:TRANS_COUNT-1];
	wire [SLAVE_DATA_WIDTH-1:0] buf_datain [0:TRANS_COUNT-1];
	
	reg [MASTER_ADR_WIDTH-1:0] adr_reg;
	
	reg [2:0] ps, ns;
	reg [COUNTER_WIDTH-1:0] count;
	reg inc;
	wire co;
	wire [TRANS_COUNT-1:0] dcd;
	reg ld_all, ld_adr, d_on_master;

	// datapath-----------------------------------------------------
					
	assign m_datain = (d_on_master) ? {buf_reg[3], buf_reg[2], buf_reg[1], buf_reg[0]} : {MASTER_DATA_WIDTH{1'bz}};
	
	genvar i;
	generate
		for (i=0; i<TRANS_COUNT; i=i+1) begin: BUF_REG_ALL
			always @(posedge clk) begin: BUF_REG_i
				if (rst)
					buf_reg[i] <= 0;
				else if (ld_buf[i])
					buf_reg[i]  <= buf_datain[i];	//m_dataout[((i+1)*SLAVE_DATA_WIDTH)-1:i*SLAVE_DATA_WIDTH];
			end
			
			assign buf_datain[i] = (ld_all) ? m_dataout[((i+1)*SLAVE_DATA_WIDTH)-1:i*SLAVE_DATA_WIDTH] :	// write
												s_dataout;												// read
			
			assign ld_buf[i] = ld_all || (dcd[i] && s_ready && m_rd);		// s_ready && m_rd (instead of ld)
		end
	endgenerate
	
	// counter
	always @(posedge clk) begin: COUNTER
		if (rst)
			count <= 0;
		else if (inc)
			count <= count + 1;
	end
	assign co = &count;
	
	// dedoder
	assign dcd = 		(count == 2'b00) ? 4'b0001 :
						(count == 2'b01) ? 4'b0010 :
						(count == 2'b10) ? 4'b0100 : 4'b1000;

	// slave datain
	assign s_datain = (count == 2'b00) ? buf_reg[0] :
						(count == 2'b01) ? buf_reg[1] :
						(count == 2'b10) ? buf_reg[2] : buf_reg[3];
	
	// adr_reg:
	always @(posedge clk) begin: ADR_REG
		if (rst)
			adr_reg <= 0;
		else if (ld_adr)
			adr_reg <= m_address;
	end
	
	// slave address
	assign s_address = {adr_reg, count};
	
	// controller--------------------------------------------------
	// present state - sequential logic
	always @(posedge clk ) begin
		if( rst )
			ps <= `IDLE;
		else
			ps <= ns;
	end
	// next state - combinational logic
	always @( ps, m_rd, m_wr, co, s_ready ) begin
		ns = `IDLE;		// ns inactive value:
		case ( ps )
			`IDLE : begin
				if( m_wr )
					ns = `WRITE_0;
				else if( m_rd )
					ns = `READ_WAIT_SLAVE;
				else
					ns = `IDLE;
			end
			`WRITE_0 : begin
				ns = `WRITE_WAIT_SLAVE;
			end
			`WRITE_WAIT_SLAVE : begin
				if( s_ready )
					ns = `WRITE_LOOP;
				else
					ns = `WRITE_WAIT_SLAVE;
			end
			`WRITE_LOOP : begin
				if( co )
					ns = `WRITE_DONE;
				else
					ns = `WRITE_WAIT_SLAVE;
			end
			`WRITE_DONE : begin
				ns = `IDLE;
			end
			`READ_WAIT_SLAVE : begin
				if( s_ready )
					ns = `READ_LOOP;
				else
					ns = `READ_WAIT_SLAVE;
			end
			`READ_LOOP : begin
				if( co )
					ns = `READ_DONE;
				else
					ns = `READ_WAIT_SLAVE;
			end
			`READ_DONE : begin
				ns = `IDLE;
			end
		endcase
	end
	// output signals - combinational logic
	always @( ps ) begin
		inc = 0;
		m_ready = 0;
		ld_adr = 0;
		ld_all = 0;
		s_wr = 0;
		s_rd = 0;
		d_on_master = 0;
		case ( ps )
			`IDLE : begin
				ld_adr = 1;
			end
			`WRITE_0 : begin
				ld_all = 1;				
			end
			`WRITE_LOOP : begin
				inc = 1;
			end
			`WRITE_WAIT_SLAVE : begin
				s_wr = 1;
			end
			`WRITE_DONE : begin
				m_ready = 1;
			end
			`READ_LOOP : begin
				inc = 1;
			end
			`READ_WAIT_SLAVE : begin
				s_rd = 1;
			end
			`READ_DONE : begin
				m_ready = 1;
				d_on_master = 1;
			end
		endcase
	end
endmodule 
