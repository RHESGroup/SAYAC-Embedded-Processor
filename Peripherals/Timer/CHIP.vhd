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
--	This implementation is drived from 8253 which is a programmable interval timer.
--  It includes 4 part : counter, downcounter which is used in counter implementation, 
--	controlword register, read_write   
--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY CHIP IS
	GENERIC(	
				LEN_CONTROLWORD	: 	INTEGER := 6;
				LEN_DATA			:	INTEGER := 8);
	PORT (		DATA	: 		INOUT STD_LOGIC_VECTOR(LEN_DATA-1 downto 0); 
				RD		: 		IN STD_LOGIC; 
				WR		: 		IN STD_LOGIC;
				CS		: 		IN STD_LOGIC; 
				A0		:		IN STD_LOGIC;
				A1		: 		IN STD_LOGIC;
				CLK0	:		IN STD_LOGIC;			
				CLK1	:		IN STD_LOGIC;
				CLK2	:		IN STD_LOGIC;
				rst		:		IN STD_LOGIC;
				GATE0	:		IN STD_LOGIC;
				GATE1	:		IN STD_LOGIC;
				GATE2	:		IN STD_LOGIC;
				OUT0	:		OUT STD_LOGIC;
				OUT1	:		OUT STD_LOGIC;
				OUT2	:		OUT STD_LOGIC
				);
END ENTITY;



ARCHITECTURE behavioral OF CHIP IS

SIGNAL ReadSignal 		: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL WriteSignal 		: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL CONTROLWORD0_I	: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL CONTROLWORD1_I	: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL CONTROLWORD2_I	: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL CONTROLWORD0_O	: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL CONTROLWORD1_O	: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL CONTROLWORD2_O	: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL STATUS_RD_I		: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL STATUS_RD_O		: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL RD_BACK			: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL CLK_SEL			: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL CLK				: STD_LOGIC;

BEGIN

CONTROLWORD0_O <= CONTROLWORD0_I;
CONTROLWORD1_O <= CONTROLWORD1_I;
CONTROLWORD2_O <= CONTROLWORD2_I;

STATUS_RD_O <= STATUS_RD_I;

CLK_SEL <= (A1&A0);

READ_WRITE_INST: ENTITY WORK.READ_WRITE
	PORT MAP(RD, WR, A0, A1, CS, ReadSignal, WriteSignal);

COUNTER_INST0: ENTITY WORK.Counter 
	GENERIC MAP( LEN_CONTROLWORD, LEN_DATA)
	PORT MAP(CLK0, rst, CONTROLWORD0_O, GATE0, WriteSignal(0), ReadSignal(0), STATUS_RD_O(0), RD_BACK(0), DATA, OUT0);
	
COUNTER_INST1: ENTITY WORK.Counter 
	GENERIC MAP( LEN_CONTROLWORD, LEN_DATA)
	PORT MAP(CLK1, rst, CONTROLWORD1_O, GATE1, WriteSignal(1), ReadSignal(1), STATUS_RD_O(1), RD_BACK(1), DATA, OUT1);
	
COUNTER_INST2: ENTITY WORK.Counter 
	GENERIC MAP( LEN_CONTROLWORD, LEN_DATA)
	PORT MAP(CLK2, rst, CONTROLWORD2_O, GATE2, WriteSignal(2), ReadSignal(2), STATUS_RD_O(2), RD_BACK(2), DATA, OUT2);
	
CONTROLREGISTER_INST: ENTITY WORK.CONTROLREGISTER 
	PORT MAP(DATA, WriteSignal(3), CLK, STATUS_RD_O, CONTROLWORD0_O, CONTROLWORD1_O, CONTROLWORD2_O, CONTROLWORD0_I, 
	CONTROLWORD1_I, CONTROLWORD2_I, STATUS_RD_I, RD_BACK);
	
CLK_SELECT: ENTITY WORK.MUX3_1BIT 
	PORT MAP(CLK0, CLK1, CLK2, CLK_SEL, CLK);	
	

END behavioral;

