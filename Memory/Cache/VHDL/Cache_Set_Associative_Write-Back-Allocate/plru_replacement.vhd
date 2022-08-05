--*****************************************************************************/
--	Filename:		plru_replacement.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			20 July 2022
--	Authors:	 	Sepideh, Alireza
--	First Author: 	Sepideh
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--	Replacement Policy module: FIFO_POLICY (First In First Out)
--  When Miss occurs controller sends update to this block for 
--  increasing history_mem according to recieved index.
--  The output of this block was to select one of the 4 available sets based on the 
--  FIFO policy( first input is the first output)  
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY plru_replacement IS
	GENERIC (
		INDEX_WIDTH			: INTEGER := 8;
		SET_WIDTH			: INTEGER := 2
	);
	PORT (
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		en                	: IN  STD_LOGIC;
		update             	: IN  STD_LOGIC;
		hit_update		   	: IN  STD_LOGIC;
		index_adr		   	: IN  STD_LOGIC_VECTOR (INDEX_WIDTH - 1 DOWNTO 0);
		hit_way	 		   	: IN  STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);  
		replace_way	    	: OUT STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0)
	);		
END ENTITY plru_replacement;


ARCHITECTURE behavioral OF plru_replacement IS
	
	CONSTANT MEM_SIZE : INTEGER := 2**INDEX_WIDTH;
	TYPE mem_type IS ARRAY (0 TO MEM_SIZE-1) of std_logic_vector(2 DOWNTO 0);
	
	SIGNAL history_mem	: mem_type;			-- register file for keeping and producing index for PLRU policy
	SIGNAL out_way		: STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);
	SIGNAL history		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL history_in	: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL selected_way	: STD_LOGIC_VECTOR (SET_WIDTH - 1 DOWNTO 0);
	SIGNAL left_sig		: STD_LOGIC;
	SIGNAL right_sig	: STD_LOGIC;
	
BEGIN
	
	DEC1 : ENTITY WORK.decoder_1to2
		PORT MAP(
			datain => selected_way(1),
			dataout0 => left_sig,
			dataout1 => right_sig );
	
	history_in(2) <= selected_way(1);
	history_in(1) <= selected_way(0) WHEN left_sig  = '1' ELSE history(1);	-- left
	history_in(0) <= selected_way(0) WHEN right_sig = '1' ELSE history(0);	-- right
	
	selected_way <= hit_way WHEN hit_update = '1' ELSE out_way;
	
	out_way(1) <= NOT history(2);
	out_way(0) <= NOT history(1) WHEN history(2) = '1' ELSE NOT history(0);	-- left or right
	
	PROCESS (clk)		
	BEGIN 	
		IF clk = '1' AND clk'EVENT THEN
			IF rst = '1' THEN	
				FOR i IN history_mem'RANGE LOOP 
					history_mem(i)<= (OTHERS=>'0'); 
				END LOOP;
			ELSIF update = '1' THEN				
				history_mem(to_integer(unsigned(index_adr)))<= history_in;
			END IF; 
		END IF;
	END PROCESS;
	
	history <= history_mem(to_integer(unsigned(index_adr)));
	replace_way <= out_way WHEN en = '1' ELSE (OTHERS=>'0'); 
	
END ARCHITECTURE behavioral;