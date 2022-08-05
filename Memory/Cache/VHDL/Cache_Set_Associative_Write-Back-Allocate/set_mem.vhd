--*****************************************************************************/
--	Filename:		set_mem.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			19 July 2022
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
--	set associative mem: this block includes n(4) ways(way_mem modules),
--	way_mem (X4) + encoder_4to2 + decoder_2to4 + ...
--	circuites for producing Hit signal, 
--	way selection circuitary for read or write to cache (get replace_way input from Replacement_Policy module)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY set_mem IS
	GENERIC (
		DATA_WIDTH			: INTEGER := 16;
		ADR_WIDTH			: INTEGER := 16;
		INDEX_WIDTH			: INTEGER := 8;
		OFFSET_WIDTH		: INTEGER := 2;		-- 4 data per block -> block_width = 4 * 16 = 64
		TAG_WIDTH			: INTEGER := 6;
		DATA_PER_BLOCK		: INTEGER := 4;		-- 2**OFFSET_WIDTH
		BLOCK_SIZE			: INTEGER := 64;	-- DATA_WIDTH*DATA_PER_BLOCK
		SET_WIDTH			: INTEGER := 2;		-- 4-way set : 2^SET_WIDTH
		SET_SIZE			: INTEGER := 4		-- 2**SET_WIDTH
	);
	PORT (
		-- Controller interface
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		sel_all        	    : IN  STD_LOGIC;	-- From controller
		rd                	: IN  STD_LOGIC;	-- From controller
		wr                	: IN  STD_LOGIC;	-- From controller
		Hit					: OUT STD_LOGIC;	-- To controller & Replacement_Policy module (in datapath)
		valid		    	: OUT STD_LOGIC;	-- To controller - from selected way_mem
		dirty_wr			: IN  STD_LOGIC;	-- From controller
		dirty	 		   	: OUT STD_LOGIC;	-- To controller - from selected way_mem 
		-- Replacement_Policy interface
		hit_way				: OUT STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);	-- to Replacement_Policy module (in datapath)
		replace_way			: IN  STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);	-- from Replacement_Policy module (in datapath)
		-- CPU interface
		address			   	: IN  STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);	-- address from cpu
		c_datain	    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- cache data_in from cpu
		c_dataout	    	: OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);   -- CPU dataout (to cpu)  
		-- memory interface
		m_blockin	    	: IN  STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);	-- memory block_in (64-bit)
		m_blockout 		   	: OUT STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);   -- memory block_out(64-bit)
		tagout			   	: OUT STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0)     -- to generate address to memory
	);		
END ENTITY set_mem;

ARCHITECTURE behavioral OF set_mem IS
	
	TYPE block_set_mem IS ARRAY (0 TO SET_SIZE-1) of std_logic_vector(BLOCK_SIZE -1 DOWNTO 0);
	TYPE tag_set_mem   IS ARRAY (0 TO SET_SIZE-1) of std_logic_vector(TAG_WIDTH -1 DOWNTO 0);
	TYPE block_mem IS ARRAY (0 TO DATA_PER_BLOCK-1) of std_logic_vector(DATA_WIDTH -1 DOWNTO 0);
	
	SIGNAL offset			: STD_LOGIC_VECTOR (OFFSET_WIDTH - 1 DOWNTO 0);
	SIGNAL blockout_way		: block_set_mem;
	SIGNAL tagout_way		: tag_set_mem;
	SIGNAL hit_way_exp		: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL replace_way_exp	: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL selected_way		: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL equal_way		: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL wr_way			: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL valid_way		: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL dirty_way		: STD_LOGIC_VECTOR (SET_SIZE - 1 DOWNTO 0);
	SIGNAL block_dataout	: block_mem;
	SIGNAL Hit_sig			: STD_LOGIC;
	SIGNAL hit_way_sig		: STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);
	SIGNAL m_blockout_sig	: STD_LOGIC_VECTOR (BLOCK_SIZE - 1 DOWNTO 0);
	
	-- hit_way 		& replace_way 		& hit_way_sig 	-> 2-bit |
	-- hit_way_exp 	& replace_way_exp 					-> 4-bit |
	
	FUNCTION or_reduce( V: STD_LOGIC_VECTOR ) RETURN STD_LOGIC is
      VARIABLE result: STD_LOGIC;
    BEGIN
      FOR i IN V'RANGE LOOP
        IF i = V'LEFT THEN
          result := V(i);
        ELSE
          result := result OR V(i);
        END IF;
        EXIT WHEN result = '1';
      END LOOP;
      RETURN result;
    END or_reduce;
	
BEGIN

	WAY_FOR: for i in 0 to SET_SIZE-1 generate
		
		WAY_MEM : ENTITY WORK.way_mem
			GENERIC MAP(
				DATA_WIDTH => DATA_WIDTH,
				ADR_WIDTH => ADR_WIDTH,
				INDEX_WIDTH => INDEX_WIDTH,
				OFFSET_WIDTH => OFFSET_WIDTH)
			PORT MAP(
				rst => rst,
				clk => clk, 
				sel_all => sel_all,
				rd => rd, 
				wr => wr_way(i),
				Hit => hit_way_exp(i),
				valid => valid_way(i),
				dirty_wr => dirty_wr,
				dirty => dirty_way(i),
				address => address,
				tagout => tagout_way(i),
				c_datain => c_datain,
				m_blockin => m_blockin,
				blockout => blockout_way(i) );
				
				tagout 			<= tagout_way(i) 	WHEN selected_way(i) = '1' ELSE (OTHERS=>'Z');
				m_blockout_sig 	<= blockout_way(i)	WHEN selected_way(i) = '1' ELSE (OTHERS=>'Z');
				
	end generate WAY_FOR;
	
	m_blockout <= m_blockout_sig;
	
	Hit_sig <= or_reduce(hit_way_exp);
	Hit <= Hit_sig;
	
	ENC : ENTITY WORK.encoder_4to2
		PORT MAP(
			datain => hit_way_exp,
			dataout => hit_way_sig);
	
	hit_way <= hit_way_sig;
			
	DEC : ENTITY WORK.decoder_2to4
		PORT MAP(
			datain => replace_way,
			dataout => replace_way_exp);
	
	selected_way <= hit_way_exp WHEN Hit_sig = '1' ELSE replace_way_exp;
	
	wr_way <= selected_way AND (SET_SIZE - 1 DOWNTO 0 => wr);
	valid  <= or_reduce(selected_way AND valid_way);
	dirty  <= or_reduce(selected_way AND dirty_way);
	
	offset <= address(OFFSET_WIDTH - 1 DOWNTO 0);
	
	c_dataout <= m_blockout_sig(DATA_WIDTH-1 	DOWNTO 0) 			 WHEN offset = "00" ELSE
				 m_blockout_sig(2*DATA_WIDTH-1 	DOWNTO DATA_WIDTH) 	 WHEN offset = "01" ELSE
				 m_blockout_sig(3*DATA_WIDTH-1	DOWNTO 2*DATA_WIDTH) WHEN offset = "10" ELSE
				 m_blockout_sig(4*DATA_WIDTH-1	DOWNTO 3*DATA_WIDTH) WHEN offset = "11" ELSE (OTHERS => 'Z');
	
END ARCHITECTURE behavioral;