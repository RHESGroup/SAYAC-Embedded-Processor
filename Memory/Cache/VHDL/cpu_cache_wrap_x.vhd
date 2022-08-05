--*****************************************************************************/
--	Filename:		cpu_cache_wrap_x.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			21 July 2022
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
--	CPU_3 + cache(sa_wb) + bus interface
--	version 2: BUS_ADR_WIDTH = 14
--	version 3: BUS name is changed to CACHE -> CACHE_DATA_WIDTH = 64
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY cpu_cache_wrap_x IS
	GENERIC (
		CACHE_DATA_WIDTH	: INTEGER := 64;	--  bus data
		CACHE_ADR_WIDTH		: INTEGER := 14;    --  bus address
		DATA_WIDTH			: INTEGER := 16;    --  cpu data
		ADR_WIDTH			: INTEGER := 16;    --  cpu address
		INDEX_WIDTH			: INTEGER := 8;
		TAG_WIDTH			: INTEGER := 6;
		OFFSET_WIDTH		: INTEGER := 2;     --  4 data per block -> block_width = 4 * 16 = 64
		SET_WIDTH			: INTEGER := 2;		-- 4-way set : 2^SET_WIDTH
		SET_SIZE			: INTEGER := 4;		-- 2**SET_WIDTH
		DATA_PER_BLOCK		: INTEGER := 4     --  DATA_PER_BLOCK = 4
	);                                              
	PORT (
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- Master_Bus_Inerface
		m_bus_address		: OUT STD_LOGIC_VECTOR (CACHE_ADR_WIDTH - 1 DOWNTO 0);	-- master address to Bus
		m_bus_datain	    : IN  STD_LOGIC_VECTOR (CACHE_DATA_WIDTH - 1 DOWNTO 0); -- master datain from bus
		m_bus_dataout	    : OUT STD_LOGIC_VECTOR (CACHE_DATA_WIDTH - 1 DOWNTO 0); -- master dataout to bus
		m_bus_rd			: OUT STD_LOGIC;                                        -- master read to bus
		m_bus_wr			: OUT STD_LOGIC;                                        -- master write to bus
		m_bus_ready	    	: IN  STD_LOGIC;                                        -- master ready to bus
		m_bus_req			: OUT STD_LOGIC;                                        -- master request to bus
		m_bus_gnt 		   	: IN  STD_LOGIC                                         -- master grant from bus
	);		
END ENTITY cpu_cache_wrap_x;

ARCHITECTURE behavioral OF cpu_cache_wrap_x IS
	
	-- CPU interface
	SIGNAL c_address		: STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
	SIGNAL c_data			: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);	-- cpu <-> cache
	SIGNAL c_ready			: STD_LOGIC;                                    -- cache -> cpu
	SIGNAL c_rd				: STD_LOGIC;
	SIGNAL c_wr				: STD_LOGIC;
	-- Cache-CPU interface
	SIGNAL cpu2cache_data	: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- cpu -> cache
	SIGNAL cache2cpu_data	: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- cache -> cpu
	-- Memory interface	
	SIGNAL m_address		: STD_LOGIC_VECTOR (CACHE_ADR_WIDTH - 1 DOWNTO 0);
	SIGNAL m_blockin		: STD_LOGIC_VECTOR (CACHE_DATA_WIDTH - 1 DOWNTO 0);	-- mem -> cache
	SIGNAL m_blockout		: STD_LOGIC_VECTOR (CACHE_DATA_WIDTH - 1 DOWNTO 0); -- cache -> mem
	SIGNAL m_ready			: STD_LOGIC;                                        -- memory ready -> cache
	SIGNAL m_rd				: STD_LOGIC;                                        -- cache -> memory read and write
	SIGNAL m_wr				: STD_LOGIC;                                        -- cache -> memory read and write
	
BEGIN

	-- datapath-----------------------------------------------------
	
	-- CPU
	CPU : ENTITY WORK.cpu_model_3_1
		PORT MAP(
			rst => rst,
			clk => clk, 
			address_bus => c_address,
			data_bus => c_data,
			ready => c_ready,
			rd => c_rd,
			wr => c_wr );
			
	-- CPU to Cache
	cpu2cache_data	<= c_data 			WHEN c_wr = '1' AND c_rd = '0' ELSE (OTHERS=>'Z');
	c_data			<= cache2cpu_data	WHEN c_wr = '0' AND c_rd = '1' ELSE (OTHERS=>'Z');

	-- Cache
	CACHE : ENTITY WORK.cache_sa_wb_2
		GENERIC MAP(
			DATA_WIDTH => DATA_WIDTH,
			ADR_WIDTH => ADR_WIDTH,
			INDEX_WIDTH => INDEX_WIDTH,
			OFFSET_WIDTH => OFFSET_WIDTH,
            SET_WIDTH => SET_WIDTH,
            SET_SIZE => SET_SIZE,	
            TAG_WIDTH => TAG_WIDTH,
            DATA_PER_BLOCK => DATA_PER_BLOCK,
            BLOCK_SIZE => CACHE_DATA_WIDTH,
            BUS_ADR_WIDTH => CACHE_ADR_WIDTH )
		PORT MAP(
			rst => rst,
			clk => clk, 
			-- cache back-en interface
			c_address => c_address,
			c_datain => cpu2cache_data,
			c_dataout => cache2cpu_data,
			c_rd => c_rd,
			c_wr => c_wr,
			c_ready => c_ready,
			-- cache front-end interface
			m_address => m_address,
			m_blockin => m_blockin,
			m_blockout => m_blockout,
			m_ready => m_ready,
			m_rd => m_rd,
			m_wr => m_wr );

	-- Cache to Bus
	m_bus_address <= m_address WHEN m_bus_gnt = '1' ELSE (OTHERS=>'Z');
	m_blockin <= m_bus_datain;
	m_bus_dataout  <= m_blockout  WHEN m_bus_gnt = '1' ELSE (OTHERS=>'Z');
	m_bus_rd <= m_rd WHEN m_bus_gnt = '1' ELSE 'Z';
	m_bus_wr <= m_wr WHEN m_bus_gnt = '1' ELSE 'Z';
	m_ready <= m_bus_ready;
	m_bus_req <= m_rd OR m_wr;
	
END ARCHITECTURE behavioral;