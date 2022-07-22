--*****************************************************************************/
--	Filename:		mem.vhd
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
--	A simple single port SRAM memory
--	one cycle to write & combinational read
--	sel signal : activate the memory (chip select)
--	rd & wr : only one of them can be issued
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY mem IS
	GENERIC (
		ADR_WIDTH			: INTEGER := 8;
		DATA_WIDTH			: INTEGER := 16
	);
	PORT (
		clk           	    : IN  STD_LOGIC;
		sel           	    : IN  STD_LOGIC;
		rd                	: IN  STD_LOGIC;
		wr                	: IN  STD_LOGIC;
		address			   	: IN  STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		datain 		    	: IN  STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0); 
		dataout 		   	: OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0)
	);		
END ENTITY mem;

ARCHITECTURE behavioral OF mem IS

	TYPE mem IS ARRAY (NATURAL RANGE <>) of std_logic_vector(datain'length -1 DOWNTO 0); 
	CONSTANT MEM_SIZE : INTEGER := 2**address'LENGTH;
	SIGNAL data : mem (0 TO MEM_SIZE-1);
	
	FUNCTION conv_integer (invec : std_logic_vector) RETURN INTEGER IS 
		VARIABLE tmp : INTEGER := 0;
	BEGIN
		FOR i IN invec'LENGTH - 1 DOWNTO 0 LOOP 
			IF invec (i) = '1' THEN
				tmp := tmp + 2**i;
			ELSIF invec (i) = '0' THEN
				tmp := tmp;
			ELSE 
				tmp := 0; 		-- may be error
			END IF; 
		END LOOP; 	
		RETURN tmp; 
	END FUNCTION conv_integer;
	
BEGIN
	-- Initialization only for simulation:		
	--FOR i IN data'RANGE LOOP 
	--	data(i)<= (OTHERS=>'0'); 
	--END LOOP;
	
	PROCESS (clk)		
	BEGIN 	
		IF clk = '1' AND clk'EVENT THEN
			IF sel = '1' AND wr = '1' THEN				
				data(conv_integer(address))<= datain;
			END IF; 
		END IF;
	END PROCESS;
	
	dataout <= data(conv_integer(address)) WHEN sel = '1' AND rd = '1' ELSE (OTHERS => 'Z');
	
END ARCHITECTURE behavioral;
