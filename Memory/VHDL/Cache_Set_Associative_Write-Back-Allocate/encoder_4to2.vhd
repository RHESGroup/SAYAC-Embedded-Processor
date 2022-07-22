--*****************************************************************************/
--	Filename:		encoder_4to2.vhd
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
--	a simple encoder 4 to 2
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY encoder_4to2 IS
	PORT (
		datain         	    : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		dataout 		   	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);		
END ENTITY encoder_4to2;

ARCHITECTURE behavioral OF encoder_4to2 IS	
BEGIN
	PROCESS (datain)		
	BEGIN 	
		CASE datain IS 
			WHEN "0001" =>
				dataout <= "00";
			
			WHEN "0010" =>
				dataout <= "01";
			
			WHEN "0100" =>
				dataout <= "10";
			
			WHEN "1000" =>
				dataout <= "11";
			
			WHEN OTHERS =>
				dataout <= "00";
		END CASE;
	END PROCESS;
	
END ARCHITECTURE behavioral;
