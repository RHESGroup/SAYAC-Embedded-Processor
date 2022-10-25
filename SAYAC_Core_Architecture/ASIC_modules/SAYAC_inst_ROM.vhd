--******************************************************************************
--	Filename:		SAYAC_inst_ROM.vhd
--	Project:		SAYAC	:	Simple ARCHITECTURE	Yet Ample Circuitry
--  Version:		0.990
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
--	instruction ROM (inst_ROM)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
	
ENTITY	inst_ROM	IS
	GENERIC	(	numofinst	:	INTEGER	:=	36	);
	PORT	(	clk			:	IN	STD_LOGIC;
				rst			:	IN	STD_LOGIC;
				readInst	:	IN	STD_LOGIC;
				addrInst	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				Inst    	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	inst_ROM;

ARCHITECTURE	behavior	OF	inst_ROM	IS
	TYPE	inst_mem	IS ARRAY (0	TO	numofinst-1)	OF	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	instMEM	:	inst_mem;
	
	IMPURE	FUNCTION	InitRomFromFile 
	RETURN	inst_mem	IS
		-- FILE RomFile			:	TEXT	OPEN	read_mode	IS	"INT_inst.txt";
		-- FILE RomFile			:	TEXT	OPEN	read_mode	IS	"Matrix_Multiplication_inst.txt";
		FILE 	RomFile			:	TEXT	OPEN	read_mode	IS	"Level1_inst.txt";
		VARIABLE RomFileLine	:	LINE;
		VARIABLE GOOD			:	BOOLEAN;
		VARIABLE fstatus		:	FILE_OPEN_STATUS;
		VARIABLE ROM			:	inst_mem;
	BEGIN	
		REPORT	"Status from FILE: '" & FILE_OPEN_STATUS'IMAGE(fstatus) & "'";
		READLINE(RomFile, RomFileLine);
		FOR	I	IN	0	TO	numofinst-1	LOOP
			IF	NOT ENDFILE(RomFile)	THEN
				READLINE(RomFile, RomFileLine);
				READ(RomFileLine, ROM(I), GOOD);
				REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END	IF;
		END	LOOP;
		
		FILE_close(RomFile);
		RETURN ROM;
	END	FUNCTION;
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF	rst = '1'	THEN
			instMEM	<=	InitRomFromFile;
		--	Inst	<=	(OTHERS => '0'	);
		-- ELSIF	clk = '1' AND clk'EVENT	THEN
			-- IF	readInst = '1'	THEN
				-- Inst	<=	instMEM(TO_INTEGER(UNSIGNED(addrInst))	);
			--	ELSE
				-- Inst	<=	(OTHERS => 'Z'	);
			-- END	IF;
		END	IF;
	END	PROCESS;
	
	Inst	<=	instMEM(TO_INTEGER(UNSIGNED(addrInst)))	WHEN	readInst = '1'	ELSE
				(OTHERS => 'Z'	);
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
