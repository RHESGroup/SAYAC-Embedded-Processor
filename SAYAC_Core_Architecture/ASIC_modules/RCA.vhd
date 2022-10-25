--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	FA	IS 
	PORT	(	x		:	IN	STD_LOGIC;
				y		:	IN	STD_LOGIC;
				cin		:	IN	STD_LOGIC;
				sum		:	OUT	STD_LOGIC;
				cout	:	OUT	STD_LOGIC	);
END	FA;	  

ARCHITECTURE	behavioral_FA	OF	FA	IS
BEGIN
	sum		<=	x XOR y XOR cin;
	cout	<=	(x AND y) OR (x AND cin) OR (cin AND y);
END	behavioral_FA;
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	RCA	IS 
	GENERIC	(	n	:	INTEGER	:=	32	);
	PORT	(	x	:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				y 	:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				sum	:	OUT	STD_LOGIC_VECTOR(n-1	DOWNTO	0)	);
END	RCA;	  

ARCHITECTURE	behavioral_RCA	OF	RCA	IS
	SIGNAL	carry	:	STD_LOGIC_VECTOR(n-1	DOWNTO	1);
	SIGNAL	cout	:	STD_LOGIC;
BEGIN
	bit0:	ENTITY	WORK.FA
				PORT	MAP	(	x(0), 
								y(0), 
								'0', 
								sum(0), 
								carry(1));
	
	add:	FOR	I	IN	1	TO	n-2 GENERATE
			bitI:	ENTITY	WORK.FA
						PORT	MAP	(	x(I), 
										y(I), 
										carry(I), 
										sum(I), 
										carry(I+1));
	END	GENERATE;
	
	bitn:	ENTITY	WORK.FA
				PORT	MAP	(	x(n-1), 
								y(n-1), 
								carry(n-1), 
								sum(n-1), 
								cout);
END	behavioral_RCA;
---------------------------------------------------------------------------------------------------
