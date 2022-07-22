--*****************************************************************************/
--	Filename:		tag_mem_wb.vhd
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
--	tag_mem_wb: tag memory write-back (it supports write-back policy because of dirty-bit for each line)
--	A memory with 1-bit valid(v) field, 1-bit dirty(d) field and TAG_WIDTH tag field
--	index input is as an index
--	all valid bits will be 0 when rst is issued, valid bit will be 1 when a tag comes to tag_mem.
--	dirty bit indicate that a cache line is consistent with main memory or not. (0 means consistent)
--	dirty-bit will be 1 when WRITE is happened (specially WRITE HIT) - inconsistency is accurred
--	outputs are tag_out and valid-bit 
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tag_mem_wb IS
	GENERIC (
		DATA_WIDTH			: INTEGER := 16;
		TAG_WIDTH			: INTEGER := 6;
		INDEX_WIDTH			: INTEGER := 8
	);
	PORT (
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		rd                	: IN  STD_LOGIC;
		wr                	: IN  STD_LOGIC;
		index_adr		   	: IN  STD_LOGIC_VECTOR (INDEX_WIDTH - 1 DOWNTO 0);					-- index field of main address = mems address here
		tagin			   	: IN  STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0);                 -- offset field of main address -> select a tag_mem of all 4 mems
		tagout	 		   	: OUT STD_LOGIC_VECTOR (TAG_WIDTH - 1 DOWNTO 0);                   -- cache data_in
		valid		    	: OUT STD_LOGIC;
		dirty_wr			: IN  STD_LOGIC;
		dirty	 		   	: OUT STD_LOGIC
	);		
END ENTITY tag_mem_wb;


ARCHITECTURE behavioral OF tag_mem_wb IS
	
	CONSTANT MEM_SIZE : INTEGER := 2**INDEX_WIDTH;
	TYPE tag_mem IS ARRAY (0 TO MEM_SIZE-1) of std_logic_vector(TAG_WIDTH -1 DOWNTO 0);
	TYPE bit_mem IS ARRAY (0 TO MEM_SIZE-1) of std_logic;
	
	SIGNAL tag_data		: tag_mem;
	SIGNAL valid_data	: STD_LOGIC_VECTOR (MEM_SIZE - 1 DOWNTO 0);
	SIGNAL dirty_data	: STD_LOGIC_VECTOR (MEM_SIZE - 1 DOWNTO 0);
	
	
BEGIN
	-- Initialization only for simulation:		
	--FOR i IN tag_data'RANGE LOOP 
	--	tag_data(i)<= (OTHERS=>'0'); 
	--END LOOP; 
		

	PROCESS (clk)		
	BEGIN 	
		IF clk = '1' AND clk'EVENT THEN
			IF rst = '1' THEN	
				valid_data <= (OTHERS=>'0');
				dirty_data <= (OTHERS=>'0');
			ELSIF wr = '1' THEN				
				tag_data(to_integer(unsigned(index_adr)))<= tagin;
				valid_data(to_integer(unsigned(index_adr)))<= '1';
				IF dirty_wr = '1' THEN	
					dirty_data(to_integer(unsigned(index_adr))) <= '1';
				ELSE
					dirty_data(to_integer(unsigned(index_adr))) <= '0';
				END IF;
			END IF; 
		END IF;
	END PROCESS;
	
	tagout <= tag_data(to_integer(unsigned(index_adr))) WHEN rd = '1' ELSE (OTHERS => '0');
	valid  <= valid_data(to_integer(unsigned(index_adr))) WHEN rd = '1' OR wr = '1' ELSE '0';
	dirty  <= dirty_data(to_integer(unsigned(index_adr))) WHEN rd = '1' ELSE '0';
	
END ARCHITECTURE behavioral;