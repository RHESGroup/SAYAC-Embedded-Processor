--*****************************************************************************/
--	Filename:		cpu_cache_wrap_bitconv.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
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
--	CPU + cache(dm_wb) + bus interface + bit_convertor (64->16)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY cpu_cache_wrap_bitconv IS
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
		DATA_PER_BLOCK		: INTEGER := 4     	--  DATA_PER_BLOCK = 4
	);                                              
	PORT (
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- Master_Bus_Inerface
		m_bus_address		: OUT STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);	-- master address to Bus
		m_bus_datain	    : IN  STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0); -- master datain from bus
		m_bus_dataout	    : OUT STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0); -- master dataout to bus
		m_bus_rd			: OUT STD_LOGIC;                                        -- master read to bus
		m_bus_wr			: OUT STD_LOGIC;                                        -- master write to bus
		m_bus_ready	    	: IN  STD_LOGIC;                                        -- master ready to bus
		m_bus_req			: OUT STD_LOGIC;                                        -- master request to bus
		m_bus_gnt 		   	: IN  STD_LOGIC                                         -- master grant from bus
	);		
END ENTITY cpu_cache_wrap_bitconv;

ARCHITECTURE behavioral OF cpu_cache_wrap_bitconv IS
	
	-- cpu_cahce_wrap (Cache) -> bit_converter
	SIGNAL m_address		: STD_LOGIC_VECTOR (CACHE_ADR_WIDTH - 1 DOWNTO 0);		-- master address to Bus
	SIGNAL m_datain			: STD_LOGIC_VECTOR (CACHE_DATA_WIDTH - 1 DOWNTO 0);		-- master datain from bus
	SIGNAL m_dataout		: STD_LOGIC_VECTOR (CACHE_DATA_WIDTH - 1 DOWNTO 0); 	-- master dataout to bus
	SIGNAL m_rd				: STD_LOGIC;                                        	-- master write to bus
	SIGNAL m_wr				: STD_LOGIC;                                        	-- master ready to bus
	SIGNAL m_ready			: STD_LOGIC;                                        	-- master read to bus
	
BEGIN

	-- datapath-----------------------------------------------------
	
	-- CPU_cache_wrap
	CPU_CACHE_WRAP : ENTITY WORK.cpu_cache_wrap_x
		GENERIC MAP(
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
			m_bus_address => m_address,
			m_bus_datain => m_datain,
			m_bus_dataout => m_dataout,
			m_bus_rd => m_rd,
			m_bus_wr => m_wr,
			m_bus_ready => m_ready,
			m_bus_req => m_bus_req,
			m_bus_gnt => m_bus_gnt );

	-- CPU_cache_wrap -> bit_converter
	
	-- bit_converter
	BIT_CONV : ENTITY WORK.bit_converter
		GENERIC MAP(
			MASTER_DATA_WIDTH => CACHE_DATA_WIDTH,
			MASTER_ADR_WIDTH => CACHE_ADR_WIDTH,
			SLAVE_DATA_WIDTH => BUS_DATA_WIDTH,
			SLAVE_ADR_WIDTH => BUS_ADR_WIDTH )
		PORT MAP(
			rst => rst,
			clk => clk, 
			-- from Cache
			m_address => m_address,
			m_dataout => m_dataout,
			m_datain => m_datain,
			m_ready => m_ready,
			m_rd => m_rd,
			m_wr => m_wr,
			-- BUS (this module interface)
			s_address => m_bus_address,
			s_datain => m_bus_dataout,
			s_dataout => m_bus_datain,
			s_ready => m_bus_ready,
			s_rd => m_bus_rd,
			s_wr => m_bus_wr );
	
END ARCHITECTURE behavioral;