--*****************************************************************************/
--	Filename:		CHIP.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			-
--	Authors:	 	Sepideh
--	Last Author: 	Sepideh
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	In read mode, with some special codes we can make signal for reading the counter. 
--  For reading the status of the couter we use ControlWord (7 DOWNTO 6) = "11" and  
--	ControlWord(5 DOWNTO 4) = "11". For reading the value of the counter we use 
--  ControlWord(5 DOWNTO 4) = "00" and ControlWord(3 DOWNTO 1). 
   
--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY CONTROLREGISTER IS
	PORT (		DATA				: 	IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				WriteSignal			:  	IN STD_LOGIC;
				CLK					:  	IN STD_LOGIC;
				EnabStatusLatches_I	: 	IN STD_LOGIC_VECTOR  (2 DOWNTO 0);
				CONTROLWORD0_I		: 	IN STD_LOGIC_VECTOR  (7 DOWNTO 0);
				CONTROLWORD1_I		: 	IN STD_LOGIC_VECTOR  (7 DOWNTO 0);
				CONTROLWORD2_I		: 	IN STD_LOGIC_VECTOR  (7 DOWNTO 0);
				CONTROLWORD0_O		: 	OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				CONTROLWORD1_O		: 	OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				CONTROLWORD2_O		: 	OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				EnabStatusLatches_O	: 	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
				READ_BACK			: 	OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
				);
END ENTITY;

ARCHITECTURE behavioral OF CONTROLREGISTER IS
SIGNAL ControlWord			:STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL ControlWord2			:STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL TRIGGER 				: STD_LOGIC := '0';

BEGIN


CONTROLWORD0_O <= ControlWord2 WHEN (ControlWord2 (7 DOWNTO 6) = "00") ELSE CONTROLWORD0_I;
CONTROLWORD1_O <= ControlWord2 WHEN (ControlWord2 (7 DOWNTO 6) = "01") ELSE CONTROLWORD1_I;
CONTROLWORD2_O <= ControlWord2 WHEN (ControlWord2 (7 DOWNTO 6) = "10") ELSE CONTROLWORD2_I;
EnabStatusLatches_O <= ControlWord (3 DOWNTO 1) WHEN (ControlWord (7 DOWNTO 6) = "11" AND ControlWord(5 DOWNTO 4) = "11" AND WriteSignal = '1') ELSE "000";

TRIGGER_PROCESS: PROCESS (WriteSignal)
BEGIN
	IF(WriteSignal = '1') THEN
		TRIGGER <= '1';
	ELSE TRIGGER <= '0';	
	END IF;
END PROCESS TRIGGER_PROCESS; 

CONTROLWORD_SAVE: PROCESS (WriteSignal, TRIGGER)
BEGIN 
	IF (WriteSignal = '1') THEN
		ControlWord <= DATA;
		ControlWord2 <= DATA;
		IF (TRIGGER = '1') THEN
		IF (ControlWord(7 DOWNTO 6) = "11") THEN
			IF (ControlWord(1) = '1' AND ControlWord(5 DOWNTO 4) = "00") THEN
				READ_BACK(0) <= '1';
			END IF;	
			IF (ControlWord(2) = '1' AND ControlWord(5 DOWNTO 4) = "00") THEN
				READ_BACK(1) <= '1';
			END IF;	
			IF (ControlWord(3) = '1' AND ControlWord(5 DOWNTO 4) = "00") THEN
				READ_BACK(2) <= '1';
			END IF;	
		END IF;
		END IF;
	ELSIF (WriteSignal = '0') THEN
		READ_BACK <= "000";
		ControlWord <= (OTHERS => 'Z');
	END IF;
END PROCESS CONTROLWORD_SAVE;

		
END behavioral;

