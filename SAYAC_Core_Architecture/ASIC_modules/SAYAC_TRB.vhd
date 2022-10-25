--******************************************************************************
--	Filename:		SAYAC_TRB.vhd
--	Project:		SAYAC	:	Simple ARCHITECTURE	Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			13 May 2022
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University	OF	Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement	IS not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	The Register Bank (TRB)	OF	the SAYAC core                                 
--******************************************************************************
	
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	TRB	IS
	PORT	(	clk					:	IN	STD_LOGIC;
				rst					:	IN	STD_LOGIC;
				writeTRB			:	IN	STD_LOGIC;
				readMemAccPolicy	:	IN	STD_LOGIC;
				readTopStackAddr	:	IN	STD_LOGIC;
				readIHBAddr			:	IN	STD_LOGIC;
				readExcBaseAddr		:	IN	STD_LOGIC;
				readExcOffAddr		:	IN	STD_LOGIC;
				rw_addr				:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				write_data			:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				read_data			:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	TRB;

ARCHITECTURE	behavior	OF	TRB	IS
	TYPE	reg_file_mem	IS	ARRAY	(0	TO	15)	OF	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	memTRB 	  	:	reg_file_mem;
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			memTRB(0)	<=	(OTHERS=>'1');
			memTRB(1)	<=	(OTHERS=>'1');
			
			FOR	I	IN	2	TO	15	LOOP
				memTRB(I)	<=	STD_LOGIC_VECTOR(TO_UNSIGNED(I, 16)	);
			END	LOOP;
		ELSIF	clk = '0' AND clk'EVENT 	THEN
			IF	writeTRB = '1'	THEN
				memTRB(TO_INTEGER(UNSIGNED(rw_addr)))	<=	write_data;
			END	IF;
		END	IF;
	END	PROCESS;
	
	read_data	<=	memTRB(1)	WHEN	readMemAccPolicy = '1'	ELSE
					memTRB(3)	WHEN	readTopStackAddr = '1'	ELSE
					memTRB(5)	WHEN	readIHBAddr = '1'		ELSE
					memTRB(6)	WHEN	readExcBaseAddr = '1'	ELSE
					memTRB(7)	WHEN	readExcOffAddr = '1'	ELSE
					memTRB(TO_INTEGER(UNSIGNED(rw_addr)));
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
