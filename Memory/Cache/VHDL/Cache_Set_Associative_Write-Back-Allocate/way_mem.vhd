--*****************************************************************************/
--	Filename:		way_mem.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			19 July 2022
--	Authors:	 	Alireza, Sepideh
--	Last Author: 	Alireza
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--	Way Memory = WM :
--	It contains: block_mem + tag_mem_wb (+ hit circuitary)
--	interface with CPU (c_... with 16-bit data width) & Mem (m_... with 64-bit data width)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY way_mem IS
	GENERIC (
		DATA_WIDTH			: INTEGER := 16;
		ADR_WIDTH			: INTEGER := 16;
		INDEX_WIDTH			: INTEGER := 8;
		OFFSET_WIDTH		: INTEGER := 2;		-- 4 data per block -> block_width = 4 * 16 = 64
		TAG_WIDTH			: INTEGER := 6;
		DATA_PER_BLOCK		: INTEGER := 4		-- 2**OFFSET_WIDTH
	);
	PORT (
		-- control signals:
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		sel_all        	    : IN  STD_LOGIC;	-- select all mem of a block => read from or write to the all mems (64-bit)
		rd                	: IN  STD_LOGIC;
		wr                	: IN  STD_LOGIC;
		Hit					: OUT STD_LOGIC;
		valid		    	: OUT STD_LOGIC;
		dirty_wr			: IN  STD_LOGIC;
		dirty	 		   	: OUT STD_LOGIC;
		-- datapath signals:
		address			   	: IN  STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);					-- 
		tagout			   	: OUT STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0);                	-- concat to c_address(index_part+offset) -- offset is not used! not important
		c_datain	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);                   -- cache data_in
		m_blockin	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH*DATA_PER_BLOCK - 1 DOWNTO 0);	-- memory block_in (64-bit)
		blockout 		   	: OUT STD_LOGIC_VECTOR (DATA_WIDTH*DATA_PER_BLOCK - 1 DOWNTO 0)     -- memory block_out(64-bit)
	);		
END ENTITY way_mem;

ARCHITECTURE behavioral OF way_mem IS
	
	SIGNAL tag 			: STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0);
	SIGNAL index_adr	: STD_LOGIC_VECTOR (INDEX_WIDTH - 1 DOWNTO 0);
	SIGNAL offset		: STD_LOGIC_VECTOR (OFFSET_WIDTH - 1 DOWNTO 0);

	SIGNAL equal		: STD_LOGIC;
	SIGNAL valid_sig	: STD_LOGIC;
	SIGNAL tagout_sig	: STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0);
	
BEGIN
	
	tag <= address(ADR_WIDTH-1 DOWNTO ADR_WIDTH-TAG_WIDTH);
	index_adr <= address(ADR_WIDTH-TAG_WIDTH-1 DOWNTO ADR_WIDTH-TAG_WIDTH-INDEX_WIDTH);
	offset <= address(OFFSET_WIDTH-1 DOWNTO 0);
	
	TAG_MEM : ENTITY WORK.tag_mem_wb
			GENERIC MAP(
				DATA_WIDTH => DATA_WIDTH,
				TAG_WIDTH => TAG_WIDTH,
				INDEX_WIDTH => INDEX_WIDTH)
			PORT MAP(
				rst => rst,
				clk => clk, 
				rd => rd, 
				wr => wr,
				index_adr => index_adr, 
				tagin => tag,
				tagout => tagout_sig,
				valid => valid_sig,
				dirty_wr => dirty_wr,
				dirty => dirty );
				
	BLOCK_MEM : ENTITY WORK.block_mem
			GENERIC MAP(
				DATA_WIDTH => DATA_WIDTH,
				INDEX_WIDTH => INDEX_WIDTH,
				OFFSET_WIDTH => OFFSET_WIDTH,
				DATA_PER_BLOCK => DATA_PER_BLOCK)
			PORT MAP(
				clk => clk, 
				sel_all => sel_all,
				rd => rd, 
				wr => wr,
				index_adr => index_adr, 
				offset_adr => offset,
				c_datain => c_datain,
				m_blockin => m_blockin,
				blockout => blockout);
	
	tagout <= tagout_sig;
	valid <= valid_sig;
	equal <= '1' WHEN tag = tagout_sig ELSE '0';
	Hit <= valid_sig AND equal;
	
END ARCHITECTURE behavioral;