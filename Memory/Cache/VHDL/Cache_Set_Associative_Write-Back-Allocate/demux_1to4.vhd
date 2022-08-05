--*****************************************************************************/
--	Filename:		demux_1to4.vhd
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
--	a simple demultiplexer 1 to 4 ( 2-bit select)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY demux_1to4 IS
	PORT (
		datain         	    : IN  STD_LOGIC;
		sel		 		   	: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		dataout				: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);		
END ENTITY demux_1to4;

ARCHITECTURE behavioral OF demux_1to4 IS	
BEGIN
	PROCESS (datain, sel)		
	BEGIN 	
		CASE sel IS 
			WHEN "00" =>
				dataout(0) <= datain;
			
			WHEN "01" =>
				dataout(1) <= datain;
			
			WHEN "10" =>
				dataout(2) <= datain;
			
			WHEN "11" =>
				dataout(3) <= datain;
			
			WHEN OTHERS =>
				dataout <= "0000";
		END CASE;
	END PROCESS;
	
END ARCHITECTURE behavioral;
