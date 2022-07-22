--*****************************************************************************/
--	Filename:		memory_model_3.vhd
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
--	A memory model with a word level = 16-bit intefrace
--	it has a DELAY_FACTOR (read and write after around 2^DELAY_FACTOR clk cycle)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL; 


ENTITY memory_model_3 IS
	GENERIC (
		DATA_WIDTH			: INTEGER := 16;
		ADR_WIDTH			: INTEGER := 16;
		DELAY_FACTOR		: INTEGER := 16
		);
	PORT (
		-- system
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		address		   		: IN  STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		datain	    		: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);	  -- 
		dataout	    		: OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);	  -- 
		ready				: OUT STD_LOGIC;                                   	  -- memory ready
		rd                	: IN  STD_LOGIC;                                      -- cpu read and write
		wr                	: IN  STD_LOGIC
	);		
END ENTITY memory_model_3;

ARCHITECTURE behavioral OF memory_model_3 IS
	
	CONSTANT MEM_SIZE : INTEGER := 2**ADR_WIDTH;
	TYPE mem_type IS ARRAY (0 TO MEM_SIZE-1) of std_logic_vector(DATA_WIDTH -1 DOWNTO 0);
	CONSTANT START_ADDR : INTEGER := 0;
	CONSTANT END_ADDR : INTEGER := 16384;
	
	TYPE state IS (
		IDLE, -- 0
		WAIT_MEM, -- 1
		DONE_MEM  -- 2
	);
	
	SIGNAL p_state, n_state : state;
	
	SIGNAL data				: mem_type;
	
	SIGNAL adr_reg			: STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
	SIGNAL data_reg			: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
	
	SIGNAL count			: STD_LOGIC_VECTOR (DELAY_FACTOR - 1 DOWNTO 0);
	SIGNAL mem_wait			: STD_LOGIC;
	SIGNAL inc				: STD_LOGIC;
	SIGNAL ld_adr			: STD_LOGIC;
	SIGNAL co				: STD_LOGIC;
	
BEGIN
			
	-- datapath-----------------------------------------------------
	-- WRITE & READ: first part -> data_reg
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				data_reg <= (OTHERS=>'0');
			ELSIF wr = '1' THEN
				data_reg <= datain;
			ELSE
				data_reg <= data(to_integer(unsigned(adr_reg)));
			END IF;
		END IF;
	END PROCESS;
	
	-- WRITE: second part
	PROCESS (clk) 
		FILE stddata : TEXT; -- OPEN READ_MODE IS "data_mem.txt";
		VARIABLE lbuf : LINE; 
		VARIABLE data_i : STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
	BEGIN
		IF (rst = '1') THEN
			FILE_OPEN (stddata, "data_mem.txt", READ_MODE);
			FOR i IN 0 TO END_ADDR LOOP 						
				IF(NOT ENDFILE(stddata)) THEN
					READLINE (stddata, lbuf);				
					READ (lbuf, data_i); 					
					data(i) <= STD_LOGIC_VECTOR(data_i);	
				END IF;
			END LOOP; 										
			FILE_CLOSE (stddata);
		ELSIF (clk = '1' AND clk'EVENT) THEN
			IF wr = '1' AND co = '1' THEN
				data(to_integer(unsigned(adr_reg))) <= data_reg;
			END IF;
		END IF;
	END PROCESS;
	
	-- READ: second part
	dataout  <= data_reg  WHEN mem_wait = '0' AND rd = '1' ELSE (OTHERS=>'Z');
	
	-- adr_reg
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				adr_reg <= (OTHERS=>'0');
			ELSIF ld_adr = '1' THEN
				adr_reg <= address;
			END IF;
		END IF;
	END PROCESS;
	
	-- counter (for controller):
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				count <= (OTHERS=>'0');
			ELSIF inc = '1' THEN
				count <= count + 1;
			END IF;
		END IF;
	END PROCESS;
	co <= '1' WHEN (count = (count'RANGE => '1')) ELSE '0';
	
	-- controller--------------------------------------------------
	-- Sequential Part
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				p_state <= IDLE;
			ELSE
				p_state <= n_state;
			END IF;
		END IF;
	END PROCESS;
	
	-- Combinational Part, next state
	PROCESS(p_state, rd, wr, co ) BEGIN
		n_state <= IDLE;
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				IF rd = '1' OR wr = '1' THEN 
					n_state <= WAIT_MEM;
				ELSE
					n_state <= IDLE; 
				END IF; 
				
			WHEN WAIT_MEM => -- 1
				IF co = '1' THEN
					n_state <= DONE_MEM; 
				ELSE
					n_state <= WAIT_MEM; 
				END IF;
				
			WHEN DONE_MEM => -- 2
				n_state <= IDLE; 
			
			WHEN OTHERS => 
				n_state <= IDLE; 
		END CASE; 
	END PROCESS;
	
	-- Combinational Part, outputs
	PROCESS(p_state) BEGIN
		mem_wait <= '0';
		inc <= '0';
		ready <= '0';
		ld_adr <= '0';
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				mem_wait <= '1';
				ld_adr <= '1';				
				
			WHEN WAIT_MEM => -- 1
				inc <= '1'; 
				mem_wait <= '1';
				
			WHEN DONE_MEM => -- 2
				ready <= '1'; 
				
			WHEN OTHERS => 
				mem_wait <= '0';
				inc <= '0';
				ready <= '0';
				ld_adr <= '0';
		END CASE; 
	END PROCESS;
	
	--PROCESS 
	--	FILE stddata : TEXT; -- OPEN READ_MODE IS "data_mem.txt";
	--	VARIABLE lbuf : LINE; 
	--	VARIABLE data_i : STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
	--BEGIN
	--	FILE_OPEN (stddata, "data_mem.txt", READ_MODE);
	--	
	--	FOR i IN 0 TO END_ADDR LOOP 						
	--		IF(NOT ENDFILE(stddata)) THEN
	--			READLINE (stddata, lbuf);				
	--			
	--			READ (lbuf, data_i); 					
	--			data(i) <= STD_LOGIC_VECTOR(data_i);	
	--		END IF;
	--	END LOOP; 										
	--	FILE_CLOSE (stddata);
	--	
	--	WAIT;
	--END PROCESS;
	
END ARCHITECTURE behavioral;