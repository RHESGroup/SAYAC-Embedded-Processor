--*****************************************************************************/
--	Filename:		cache_sa_wb_2.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		2.000
--	History:		-
--	Date:			20 July 2022
--	Authors:	 	Sepideh, Alireza
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
--	top module of cache: Set Associative cache with Write Back policy (and Write-Allocate)
--		datapath + controller
-- 	version 2: BUS_ADR_WIDTH = 14
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY cache_sa_wb_2 IS
	GENERIC (
		DATA_WIDTH			: INTEGER := 16;
		ADR_WIDTH			: INTEGER := 16;
		INDEX_WIDTH			: INTEGER := 8;
		OFFSET_WIDTH		: INTEGER := 2;		-- 4 data per block -> block_width = 4 * 16 = 64
		SET_WIDTH			: INTEGER := 2;		-- 4-way set : 2^SET_WIDTH
		SET_SIZE			: INTEGER := 4;		-- 2**SET_WIDTH
		TAG_WIDTH			: INTEGER := 6;
		DATA_PER_BLOCK		: INTEGER := 4;		-- 2**OFFSET_WIDTH
		BLOCK_SIZE			: INTEGER := 64;	-- DATA_WIDTH*DATA_PER_BLOCK
		BUS_ADR_WIDTH		: INTEGER := 14		-- ADR_WIDTH - OFFSET_WIDTH;	-- 16-2 = 14
	);
	PORT (
		-- system ----------------------------------------------------------
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- CPU interface-LEFT-----------------------------------------------
		-- -- datapath
		c_address		   	: IN  STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);	-- address from cpu
		c_datain	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- cache data_in from cpu
		c_dataout	    	: OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- CPU dataout (to cpu)  
		-- -- controller
		c_rd				: IN  STD_LOGIC;
		c_wr				: IN  STD_LOGIC;
		c_ready				: OUT STD_LOGIC;
		-- Mem interface-RIGHT----------------------------------------------
		-- -- datapath
		m_address			: OUT STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);-- address to memory (bus)
		m_blockin	    	: IN  STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);	-- memory block_in (64-bit), Mem provides a block (not a data)
		m_blockout 		   	: OUT STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);	-- memory block_out(64-bit), Mem provides a block (not a data)
		-- -- controller
		m_ready				: IN  STD_LOGIC;
		m_rd				: OUT STD_LOGIC;
		m_wr				: OUT STD_LOGIC
	);		
END ENTITY cache_sa_wb_2;

ARCHITECTURE behavioral OF cache_sa_wb_2 IS

	SIGNAL sel_all    	    : STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
	SIGNAL rd              	: STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
	SIGNAL wr              	: STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
	SIGNAL dirty_wr			: STD_LOGIC;	-- From controller
	
	SIGNAL d_on_cpu			: STD_LOGIC;	-- tri-state select, data or address on buss or not
	SIGNAL d_on_mem			: STD_LOGIC;	-- tri-state select, data or address on buss or not
	SIGNAL adr_on_mem		: STD_LOGIC;	-- tri-state select, data or address on buss or not
	SIGNAL drt_adr_on_mem	: STD_LOGIC;	-- tri-state select, dirty address on memory address buss
	
	SIGNAL Hit				: STD_LOGIC;	-- CM provides this, To controller & Replacement_Policy module (in datapath)
	SIGNAL valid		    : STD_LOGIC;	-- To controller - from selected way_mem
	SIGNAL dirty	 		: STD_LOGIC;	-- To controller - from selected way_mem 
	SIGNAL update          	: STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
	SIGNAL en_replacement	: STD_LOGIC;	-- From controller
	
BEGIN

	DP : ENTITY WORK.datapath_wb
		GENERIC MAP(
			DATA_WIDTH => DATA_WIDTH,
			ADR_WIDTH => ADR_WIDTH,
			INDEX_WIDTH => INDEX_WIDTH,
			OFFSET_WIDTH => OFFSET_WIDTH,
			SET_WIDTH => SET_WIDTH )
		PORT MAP(
			rst => rst,
			clk => clk, 
			-- CTRL
			sel_all => sel_all,
			rd => rd, 
			wr => wr,
			update => update,
			d_on_cpu => d_on_cpu,
			d_on_mem => d_on_mem,
			adr_on_mem => adr_on_mem,
			drt_adr_on_mem => drt_adr_on_mem,
			Hit => Hit,
			valid => valid,
			dirty_wr => dirty_wr,
			dirty => dirty,
			en_replacement => en_replacement,
			-- CPU			
			c_address => c_address,
			c_datain => c_datain,
			c_dataout => c_dataout,
			-- MEM
			m_ready => m_ready,
			m_address => m_address,
			m_blockin => m_blockin,
			m_blockout => m_blockout );
			
	CTRL : ENTITY WORK.controller_wb
		PORT MAP(
			rst => rst,
			clk => clk, 
			-- CTRL
			sel_all => sel_all,
			rd => rd, 
			wr => wr,
			update => update,
			d_on_cpu => d_on_cpu,
			d_on_mem => d_on_mem,
			adr_on_mem => adr_on_mem,
			drt_adr_on_mem => drt_adr_on_mem,
			Hit => Hit,
			valid => valid,
			dirty_wr => dirty_wr,
			dirty => dirty,
			en_replacement => en_replacement,
			-- CPU			
			c_rd => c_rd,
			c_wr => c_wr,
			c_ready => c_ready,
			-- MEM
			m_ready => m_ready,
			m_rd => m_rd,
			m_wr => m_wr );
	
END ARCHITECTURE behavioral;