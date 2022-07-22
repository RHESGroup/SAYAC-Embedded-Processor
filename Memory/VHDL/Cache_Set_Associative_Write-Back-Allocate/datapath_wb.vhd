--*****************************************************************************/
--	Filename:		datapath_wb.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			20 July 2022
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
--	datapath of cahce (supports write-back policy)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY datapath_wb IS
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
		-- Controller interface
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		sel_all        	    : IN  STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
		rd                	: IN  STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
		wr                	: IN  STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
		update             	: IN  STD_LOGIC;	-- From controller ,CM (cache_mem needs them)
		d_on_cpu			: IN  STD_LOGIC;	-- tri-state select, data or address on buss or not
		d_on_mem			: IN  STD_LOGIC;	-- tri-state select, data or address on buss or not
		adr_on_mem			: IN  STD_LOGIC;	-- tri-state select, data or address on buss or not
		drt_adr_on_mem		: IN  STD_LOGIC;	-- tri-state select, dirty address on memory address buss
		Hit					: OUT STD_LOGIC;	-- CM provides this, To controller & Replacement_Policy module (in datapath)
		valid		    	: OUT STD_LOGIC;	-- To controller - from selected way_mem
		dirty_wr			: IN  STD_LOGIC;	-- From controller
		dirty	 		   	: OUT STD_LOGIC;	-- To controller - from selected way_mem 
		en_replacement		: IN  STD_LOGIC;	-- From controller
		-- CPU interface
		c_address		   	: IN  STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);	-- address from cpu
		c_datain	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- cache data_in from cpu
		c_dataout	    	: OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- CPU dataout (to cpu)  
		-- memory interface
		m_ready				: IN  STD_LOGIC;
		m_address			: OUT STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);-- address to memory (bus)
		m_blockin	    	: IN  STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);	-- memory block_in (64-bit), Mem provides a block (not a data)
		m_blockout 		   	: OUT STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0)	-- memory block_out(64-bit), Mem provides a block (not a data)
	);		
END ENTITY datapath_wb;

ARCHITECTURE behavioral OF datapath_wb IS
	
	-- Replacement_Policy interface:
	SIGNAL replace_way		: STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);
	SIGNAL hit_way			: STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);
	--
	SIGNAL m_blockin_reg	: STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);
	SIGNAL blockout			: STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);
	SIGNAL dataout			: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL tagout			: STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0);
	SIGNAL index_adr		: STD_LOGIC_VECTOR (INDEX_WIDTH - 1 DOWNTO 0);
	
	SIGNAL Hit_sig			: STD_LOGIC;
	
BEGIN

	-- register m_blockin_reg to keep blockin for the next cycle
	-- this delay produced by controller and this register compensate the delay
	PROCESS (clk) BEGIN 	
		IF clk = '1' AND clk'EVENT THEN
			IF rst = '1' THEN	
				m_blockin_reg <= (OTHERS=>'0'); 
			ELSIF m_ready = '1'THEN				
				m_blockin_reg <= m_blockin; 
			END IF; 
		END IF;
	END PROCESS;

	
	SM : ENTITY WORK.set_mem
		GENERIC MAP(
			DATA_WIDTH => DATA_WIDTH,
			ADR_WIDTH => ADR_WIDTH,
			INDEX_WIDTH => INDEX_WIDTH,
			OFFSET_WIDTH => OFFSET_WIDTH,
			SET_WIDTH => SET_WIDTH )
		PORT MAP(
			rst => rst,
			clk => clk, 
			sel_all => sel_all,
			rd => rd, 
			wr => wr,
			Hit => Hit_sig,
			valid => valid,
			dirty_wr => dirty_wr,
			dirty => dirty,
			
			hit_way => hit_way,
			replace_way => replace_way,
			
			address => c_address,
			c_datain => c_datain,
			c_dataout => dataout,
			
			m_blockin => m_blockin_reg,
			m_blockout => blockout,
			tagout => tagout );
			
	Hit <= Hit_sig;

	PLRU_REPLACE : ENTITY WORK.plru_replacement
		GENERIC MAP(
			INDEX_WIDTH => INDEX_WIDTH,
			SET_WIDTH => SET_WIDTH )
		PORT MAP(
			rst => rst,
			clk => clk, 
			en => en_replacement,
			update => update, 
			hit_update => Hit_sig,			
			index_adr => index_adr,
			hit_way => hit_way,
			replace_way => replace_way );

	
	index_adr <= c_address(ADR_WIDTH-TAG_WIDTH-1 DOWNTO ADR_WIDTH-TAG_WIDTH-INDEX_WIDTH);
	
	-- tri-state buffers
	c_dataout  <= dataout  WHEN d_on_cpu = '1' ELSE (OTHERS=>'Z');
	m_blockout <= blockout WHEN d_on_mem = '1' ELSE (OTHERS=>'Z');
	m_address  <= c_address(ADR_WIDTH-1 DOWNTO OFFSET_WIDTH)					WHEN adr_on_mem = '1' ELSE 
				  tagout & c_address(ADR_WIDTH-TAG_WIDTH-1 DOWNTO OFFSET_WIDTH)	WHEN drt_adr_on_mem = '1'
				  ELSE (OTHERS=>'Z');
	
END ARCHITECTURE behavioral;