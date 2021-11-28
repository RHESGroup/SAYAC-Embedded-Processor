--******************************************************************************
--  Filename:		CLA17.vhd
--  Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--  History:
--  Date:		21 May 2021
--  Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	17-bit Carry Look Ahead Adder                                 
--******************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY GAP IS
	GENERIC (
		m : INTEGER := 4
	);
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
		P, G : OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0)
	);
END GAP;	 

ARCHITECTURE behavioral OF GAP IS
BEGIN
	P <= x XOR y;
	G <= x AND y;
END behavioral;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLG IS
	PORT ( 
		p, g : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		cin : IN STD_LOGIC;
		c   : OUT STD_LOGIC_VECTOR(16 DOWNTO 0) );
END CLG;	 

ARCHITECTURE behavioral OF CLG IS
BEGIN		
	c(0) <= g(0) OR (p(0) AND cin);
	c(1) <= g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2) <= g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0))
		OR (p(2) AND p(1)AND p(0) AND cin);	
	c(3) <= g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1))
		OR (p(3) AND p(2) AND p(1) AND g(0))
		OR (p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(4) <= g(4) OR (p(4) AND g(3)) OR (p(4) AND p(3) AND g(2))
		OR (p(4) AND p(3) AND p(2) AND g(1))
		OR (p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(4) AND p(3) AND p(2) AND p(1) AND P(0) AND cin);
	c(5) <= g(5) OR (p(5) AND g(4)) OR (p(5) AND p(4) AND g(3))
		OR (p(5) AND p(4) AND p(3) AND g(2))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(6) <= g(6) OR (p(6) AND g(5)) OR (p(6) AND p(5) AND g(4))
		OR (p(6) AND p(5) AND p(4) AND g(3))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(7) <= g(7) OR (p(7) AND g(6)) OR (p(7) AND p(6) AND g(5))
		OR (p(7) AND p(6) AND p(5) AND g(4))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(8) <= g(8) OR (p(8) AND g(7)) OR (p(8) AND p(7) AND g(6))
		OR (p(8) AND p(7) AND p(6) AND g(5))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(9) <= g(9) OR (p(9) AND g(8)) OR (p(9) AND p(8) AND g(7))
		OR (p(9) AND p(8) AND p(7) AND g(6))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(10) <= g(10) OR (p(10) AND g(9)) OR (p(10) AND p(9) AND g(8))
		OR (p(10) AND p(9) AND p(8) AND g(7))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(11) <= g(11) OR (p(11) AND g(10)) OR (p(11) AND p(10) AND g(9))
		OR (p(11) AND p(10) AND p(9) AND g(8))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(12) <= g(12) OR (p(12) AND g(11)) OR (p(12) AND p(11) AND g(10))
		OR (p(12) AND p(11) AND p(10) AND g(9))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(13) <= g(13) OR (p(13) AND g(12)) OR (p(13) AND p(12) AND g(11))
		OR (p(13) AND p(12) AND p(11) AND g(10))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(14) <= g(14) OR (p(14) AND g(13)) OR (p(14) AND p(13) AND g(12))
		OR (p(14) AND p(13) AND p(12) AND g(11))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND g(10))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(15) <= g(15) OR (p(15) AND g(14)) OR (p(15) AND p(14) AND g(13))
		OR (p(15) AND p(14) AND p(13) AND g(12))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND g(11))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND g(10))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(16) <= g(16) OR (p(16) AND g(15)) OR (p(16) AND p(15) AND g(14))
		OR (p(16) AND p(15) AND p(14) AND g(13))
		OR (p(16) AND p(15) AND p(14) AND g(13))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND g(12))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND g(11))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND g(10))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(16) AND p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
END behavioral;
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLA17 IS
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		cin : IN STD_LOGIC;
		sum : OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END CLA17;	 

ARCHITECTURE behavioral OF CLA17 IS
	SIGNAL c, P, G : STD_LOGIC_VECTOR(16 DOWNTO 0);
BEGIN
	MY_GAP : ENTITY work.GAP GENERIC MAP (17)
		PORT MAP( x, y, P, G);
	
	MY_CLG : ENTITY work.CLG PORT MAP
		(P, G, cin, c);	

	sum(0) <= p(0) XOR cin;
	sum(16 DOWNTO 1) <= p(16 DOWNTO 1) XOR c(15 DOWNTO 0);
END behavioral;	 
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CLA17_test IS 
END CLA17_test;	  

ARCHITECTURE behavioral_TB OF CLA17_test IS
	COMPONENT CLA17 IS 
		PORT ( 
			x, y  : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
			cin : IN STD_LOGIC;
			sum : OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL x, y, sum : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL cin : STD_LOGIC;
BEGIN	
	CUT : CLA17 PORT MAP
		(x, y, cin, sum);
	
	PROCESS
	BEGIN
		cin <= '0';
		x <= "00000000000001010"; 		-- A = 10
		y <= "11111111111111011";		-- B = -5
		WAIT FOR 5 NS;
		x <= "11111111101111111"; 		-- A = -129
		y <= "00000001000000010";		-- B = 514
		WAIT FOR 5 NS;
		cin <= '1';
		WAIT FOR 5 NS;
		x <= "00000101001010000"; 		-- A = 2640
		y <= "00000000010000000";		-- B = 128
		WAIT FOR 5 NS;	
		x <= "11111111111110111"; 		-- A = -9
		y <= "00000000000010001";		-- B = 17
		WAIT FOR 5 NS;	
		x <= "11111111111100010"; 		-- A = -30
		y <= "11111111111110110";		-- B = -10
		WAIT FOR 5 NS;
		WAIT;
	END PROCESS;
END behavioral_TB;
