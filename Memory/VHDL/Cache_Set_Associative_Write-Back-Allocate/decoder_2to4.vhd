--*****************************************************************************/
--	Filename:		decoder_2to4.vhd
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
--	a simple decoder 2 to 4
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY decoder_2to4 IS
	PORT (
		datain         	    : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		dataout 		   	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);		
END ENTITY decoder_2to4;

ARCHITECTURE behavioral OF decoder_2to4 IS	
BEGIN
	PROCESS (datain)		
	BEGIN 	
		CASE datain IS 
			WHEN "00" =>
				dataout <= "0001";
			
			WHEN "01" =>
				dataout <= "0010";
			
			WHEN "10" =>
				dataout <= "0100";
			
			WHEN "11" =>
				dataout <= "1000";
			
			WHEN OTHERS =>
				dataout <= "0000";
		END CASE;
	END PROCESS;
	
END ARCHITECTURE behavioral;
