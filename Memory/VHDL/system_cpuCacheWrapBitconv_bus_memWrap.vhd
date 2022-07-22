--*****************************************************************************/
--	Filename:		system_cpuCacheWrapBitconv_bus_memWrap.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		2.000
--	History:		-
--	Date:			22 July 2022
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
--	(A cpu model + cache (WB) + wrapper + bit_convertoer(16-bit)) + Bus(16-bit) + (memory_model(16-bit))
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY system_cpuCacheWrapBitconv_bus_memWrap IS
	GENERIC (
		-- BUS
		BUS_DATA_WIDTH		: INTEGER := 16;	--  bus data
		BUS_ADR_WIDTH		: INTEGER := 16;    --  bus address
		-- CACHE
		CACHE_DATA_WIDTH	: INTEGER := 64;	--  cache data
		CACHE_ADR_WIDTH		: INTEGER := 14;    --  cache address
		-- CPU
		DATA_WIDTH			: INTEGER := 16;    --  cpu data
		ADR_WIDTH			: INTEGER := 16;    --  cpu address
		INDEX_WIDTH			: INTEGER := 8;
		TAG_WIDTH			: INTEGER := 6;
		OFFSET_WIDTH		: INTEGER := 2;     --  4 data per block -> block_width = 4 * 16 = 64
		SET_WIDTH			: INTEGER := 2;		-- 4-way set : 2^SET_WIDTH
		SET_SIZE			: INTEGER := 4;		-- 2**SET_WIDTH
		DATA_PER_BLOCK		: INTEGER := 4;    	--  DATA_PER_BLOCK = 4
		MEM_DELAY_FACTOR	: INTEGER := 2
	);                                              		
END ENTITY system_cpuCacheWrapBitconv_bus_memWrap;

ARCHITECTURE behavioral OF system_cpuCacheWrapBitconv_bus_memWrap IS
	
	-- System
	SIGNAL		rst				: STD_LOGIC;
	SIGNAL		clk				: STD_LOGIC;
	-- Master_Bus_Inerface
	SIGNAL		m_bus_address	: STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);	-- master address to Bus
	SIGNAL		m_bus_datain	: STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0); 	-- cpu <- bus	- cpu datain
	SIGNAL		m_bus_dataout   : STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0); 	-- cpu -> bus	- cpu dataout
	SIGNAL		m_bus_rd		: STD_LOGIC;                                      	-- cpu -> bus
	SIGNAL		m_bus_wr		: STD_LOGIC;                                      	-- cpu -> bus
	SIGNAL		m_bus_ready	    : STD_LOGIC;                                      	-- cpu <- bus
	SIGNAL		m_bus_req		: STD_LOGIC;                                      	-- cpu -> bus
	SIGNAL		m_bus_gnt 		: STD_LOGIC;                                        -- cpu -> bus
	-- cpu_cahce_wrap (Cache) -> bit_converter
	SIGNAL		s_bus_address	: STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);	-- bus -> mem	- mem address
	SIGNAL		s_bus_datain	: STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0); 	-- bus -> mem	- mem datain
	SIGNAL		s_bus_dataout	: STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0); 	-- bus <- mem	- mem dataout
	SIGNAL		s_bus_rd		: STD_LOGIC;                                      	-- bus -> mem
	SIGNAL		s_bus_wr		: STD_LOGIC;                                      	-- bus -> mem
	SIGNAL		s_bus_ready	    : STD_LOGIC;                                    	-- bus <- mem

BEGIN
	
	-- CPU(cache wrapped)
	CPU_CACHE_WRAP_BCONV : ENTITY WORK.cpu_cache_wrap_bitconv
		GENERIC MAP(
			BUS_DATA_WIDTH => BUS_DATA_WIDTH,
			BUS_ADR_WIDTH => BUS_ADR_WIDTH,
			CACHE_DATA_WIDTH => CACHE_DATA_WIDTH,
			CACHE_ADR_WIDTH => CACHE_ADR_WIDTH,
			DATA_WIDTH => DATA_WIDTH,
			ADR_WIDTH => ADR_WIDTH,
			INDEX_WIDTH => INDEX_WIDTH,
			TAG_WIDTH => TAG_WIDTH,
			OFFSET_WIDTH => OFFSET_WIDTH,
            SET_WIDTH => SET_WIDTH,
            SET_SIZE => SET_SIZE,
            DATA_PER_BLOCK => DATA_PER_BLOCK)
		PORT MAP(
			rst => rst,
			clk => clk, 
			m_bus_address => m_bus_address,
			m_bus_datain => m_bus_datain,
			m_bus_dataout => m_bus_dataout,
			m_bus_rd => m_bus_rd,
			m_bus_wr => m_bus_wr,
			m_bus_ready => m_bus_ready,
			m_bus_req => m_bus_req,
			m_bus_gnt => m_bus_gnt );

	-- BUS
	BUS_INST : ENTITY WORK.bus_2
		GENERIC MAP(
			BUS_DATA_WIDTH => BUS_DATA_WIDTH,
			BUS_ADR_WIDTH => BUS_ADR_WIDTH )
		PORT MAP(
			rst => rst,
			clk => clk, 
			-- MASTER
			m_bus_address => m_bus_address,
			m_bus_datain => m_bus_datain,
			m_bus_dataout => m_bus_dataout,
			m_bus_rd => m_bus_rd,
			m_bus_wr => m_bus_wr,
			m_bus_ready => m_bus_ready,
			m_bus_req => m_bus_req,
			m_bus_gnt => m_bus_gnt,
			-- SLAVE
			s_bus_address => s_bus_address,
			s_bus_datain => s_bus_datain,
			s_bus_dataout => s_bus_dataout,
			s_bus_rd => s_bus_rd,
			s_bus_wr => s_bus_wr,
			s_bus_ready => s_bus_ready );
	
	-- Memory
	MEM_INST : ENTITY WORK.memory_model_3
		GENERIC MAP(
			DATA_WIDTH => BUS_DATA_WIDTH,
			ADR_WIDTH => BUS_ADR_WIDTH,
			DELAY_FACTOR => MEM_DELAY_FACTOR )
		PORT MAP(
			rst => rst,
			clk => clk, 
			address => s_bus_address,
			datain => s_bus_datain,
			dataout => s_bus_dataout,
			rd => s_bus_rd,
			wr => s_bus_wr,
			ready => s_bus_ready );
			
	PROCESS
    BEGIN
		rst <= '0';
		
		WAIT FOR 10 ns;
		rst <= '1';
		WAIT FOR 10 ns;
		rst <= '0';
		
		WAIT;
    END PROCESS;
	
	PROCESS
	BEGIN
		WAIT FOR 5 ns;
		clk <= '1';
		WAIT FOR 5 ns;
		clk <= '0';
	END PROCESS;
END ARCHITECTURE behavioral;