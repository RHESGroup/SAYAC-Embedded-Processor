--*****************************************************************************/
--	Filename:		mux_4to1.vhd
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
--	a simple multiplexer 4 to 1 ( 2-bit select)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY mux_4to1 IS
	PORT (
		datain         	    : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		sel		 		   	: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		dataout				: OUT STD_LOGIC
	);		
END ENTITY mux_4to1;

ARCHITECTURE behavioral OF mux_4to1 IS	
BEGIN
	PROCESS (datain, sel)		
	BEGIN 	
		CASE sel IS 
			WHEN "00" =>
				dataout <= datain(0);
			
			WHEN "01" =>
				dataout <= datain(1);
			
			WHEN "10" =>
				dataout <= datain(2);
			
			WHEN "11" =>
				dataout <= datain(3);
			
			WHEN OTHERS =>
				dataout <= '0';
		END CASE;
	END PROCESS;
	
END ARCHITECTURE behavioral;
