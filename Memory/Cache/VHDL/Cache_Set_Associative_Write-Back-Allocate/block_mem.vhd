--*****************************************************************************/
--	Filename:		block_mem.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			19 July 2022
--	Authors:	 	Alireza
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
--	Its main part is a memory that keeps block-datas (Values) fetched from mem to cache.
--	This memory consisted of 4 (n) mem modules. (mem is a simple SRAM memory)
--	This module:
--		find Hit/Miss(!Hit)
--		handle write a data (16-bit) from cpu
--		handle write a block (64-bit ) from mem
--		handle read a block (64-bit) to Cache Mem (to select a 16-bit data to cpu)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY block_mem IS
	GENERIC (
		INDEX_WIDTH			: INTEGER := 8;
		DATA_WIDTH			: INTEGER := 16;
		OFFSET_WIDTH		: INTEGER := 2;		-- 4 data per block -> block_width = 4 * 16 = 64
		DATA_PER_BLOCK		: INTEGER := 4		-- 2**OFFSET_WIDTH
	);
	PORT (
		clk           	    : IN  STD_LOGIC;
		sel_all        	    : IN  STD_LOGIC;	-- select all mem => read from or write to the all mems (64-bit)
		rd                	: IN  STD_LOGIC;
		wr                	: IN  STD_LOGIC;
		index_adr		   	: IN  STD_LOGIC_VECTOR (INDEX_WIDTH - 1 DOWNTO 0);					-- index field of main address = mems address here
		offset_adr		   	: IN  STD_LOGIC_VECTOR (OFFSET_WIDTH - 1 DOWNTO 0);                 -- offset field of main address -> select a mem of all 4 mems
		c_datain	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);                   -- cache data_in
		m_blockin	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH*DATA_PER_BLOCK - 1 DOWNTO 0);	-- memory block_in (64-bit)	
		blockout 		   	: OUT STD_LOGIC_VECTOR (DATA_WIDTH*DATA_PER_BLOCK - 1 DOWNTO 0)     -- block_out (64-bit) selected from cache (it will be send to th cpu)
	);		
END ENTITY block_mem;

ARCHITECTURE behavioral OF block_mem IS
	
	TYPE mem IS ARRAY (0 TO DATA_PER_BLOCK-1) of std_logic_vector(DATA_WIDTH -1 DOWNTO 0);
	
	SIGNAL sel 			: STD_LOGIC_VECTOR (0 TO DATA_PER_BLOCK-1);
	SIGNAL mem_datain	: mem;
	SIGNAL mem_dataout	: mem;
	
	
BEGIN
	
	BLOCK_FOR: for i in 0 to DATA_PER_BLOCK-1 generate
		
		mem_datain(i) <= m_blockin( (i+1)*DATA_WIDTH-1 DOWNTO i*DATA_WIDTH ) WHEN sel_all = '1' ELSE c_datain;
		
		sel(i) <= '1' WHEN offset_adr = std_logic_vector(to_unsigned(i,offset_adr'length)) ELSE sel_all;
		
		D_MEM : ENTITY WORK.mem
				GENERIC MAP(
					ADR_WIDTH => INDEX_WIDTH,
					DATA_WIDTH => DATA_WIDTH)
				PORT MAP(
					clk => clk, 
					sel => sel(i), 
					rd => rd, 
					wr => wr,
					address => index_adr, 
					datain => mem_datain(i),
					dataout => mem_dataout(i) );
		
		blockout( (i+1)*DATA_WIDTH-1 DOWNTO i*DATA_WIDTH) <= mem_dataout(i);
		
	end generate BLOCK_FOR;
	
END ARCHITECTURE behavioral;