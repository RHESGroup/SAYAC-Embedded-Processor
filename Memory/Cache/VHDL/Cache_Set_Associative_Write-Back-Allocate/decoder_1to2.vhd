--*****************************************************************************/
--	Filename:		decoder_1to2.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			20 July 2022
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
--	a simple decoder 1 to 2
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY decoder_1to2 IS
	PORT (
		datain         	    : IN  STD_LOGIC;
		dataout0 		   	: OUT STD_LOGIC;
		dataout1 		   	: OUT STD_LOGIC
	);		
END ENTITY decoder_1to2;

ARCHITECTURE behavioral OF decoder_1to2 IS	
BEGIN
	PROCESS (datain)		
	BEGIN 	
		CASE datain IS 
			WHEN '0' =>
				dataout0 <= '1';
				dataout1 <= '0';
			
			WHEN '1' =>
				dataout0 <= '0';
				dataout1 <= '1';
			
			WHEN OTHERS =>
				dataout0 <= '0';
				dataout1 <= '0';
		END CASE;
	END PROCESS;
	
END ARCHITECTURE behavioral;
