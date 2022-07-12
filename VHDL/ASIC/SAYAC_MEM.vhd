--******************************************************************************
--	Filename:		SAYAC_MEM.vhd
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
--	Memory (MEM)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	IEEE.NUMERIC_STD.ALL;
	
ENTITY	MEM	IS
	GENERIC (	memSize	:	INTEGER	:=	36	);
	PORT (	clk			:	IN		STD_LOGIC;
			rst			:	IN		STD_LOGIC;
			readMEM		:	IN		STD_LOGIC;
			writeMEM	:	IN		STD_LOGIC;
			addr		:	IN		STD_LOGIC_VECTOR(15	DOWNTO	0);
	--		addr		:	IN		STD_LOGIC_VECTOR(15	DOWNTO	0);
	--		writeData	:	IN		STD_LOGIC_VECTOR(15	DOWNTO	0);
	--		readData	:	OUT		STD_LOGIC_VECTOR(15	DOWNTO	0);
			rwData		:	INOUT	STD_LOGIC_VECTOR(15	DOWNTO	0);
			readyMEM	:	OUT		STD_LOGIC	);
END	ENTITY	MEM;

ARCHITECTURE	behavior	OF	MEM	IS
	TYPE	data_mem	IS	ARRAY	(0	TO	memSize-1) OF	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	memory	:	data_mem;
BEGIN
	PROCESS	(	clk, rst )
	BEGIN
		IF	rst = '1'	THEN
			FOR	I	IN	0	TO	memSize-1	LOOP
				memory(I)	<=	STD_LOGIC_VECTOR(TO_UNSIGNED(I, 16));
			END	LOOP;
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	writeMem = '1'	THEN
--				memory(TO_INTEGER(UNSIGNED(addr)))	<=	writeData;
				memory(TO_INTEGER(UNSIGNED(addr)))	<=	rwData;
				readyMEM							<=	'1';
			END	IF;
			
			IF	readMEM = '1'	THEN
				readyMEM	<=	'1';
			END	IF;
		END	IF;
	END	PROCESS;

--    readData	<=	memory(TO_INTEGER(UNSIGNED(addr)))	WHEN	readMEM = '1'	ELSE
    rwData	<=	memory(TO_INTEGER(UNSIGNED(addr)))	WHEN	readMEM = '1'	ELSE
			    (OTHERS => 'Z'); 
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;

ENTITY	test_MEM	IS
END	ENTITY	test_MEM;

ARCHITECTURE	test	OF	test_MEM	IS
	SIGNAL	clk			:	STD_LOGIC	:=	'0';
	SIGNAL	rst			:	STD_LOGIC;
	SIGNAL	readMEM		:	STD_LOGIC;
	SIGNAL	writeMEM	:	STD_LOGIC;
	SIGNAL	addr		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
--	SIGNAL	readData	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
--	SIGNAL	writeData	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	rwData		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	readyMEM	:	STD_LOGIC;
BEGIN	
	clk			<=	NOT clk AFTER 5 NS	WHEN	NOW	<=	380 NS	ELSE '0';
	rst			<=	'1', '0' AFTER 8 NS;
	readMEM		<=	'0', '1' AFTER 20 NS, '0' AFTER 27 NS;
	writeMEM	<=	'0', '1' AFTER 12 NS, '0' AFTER 18 NS;
	addr		<=	X"0200", X"0309" AFTER 13 NS;
--	writeData	<=	X"000A", X"00A0" AFTER 14 NS;
	rwData		<=	X"000A", X"00A0" AFTER 14 NS;
	
	MEMORY:	ENTITY	WORK.MEM
				PORT	MAP	(	clk, 
								rst, 
								readMEM, 
								writeMEM, 
								addr, 
								rwData, 
								readyMEM);
--								writeData, readData, readyMEM);
END	ARCHITECTURE	test;