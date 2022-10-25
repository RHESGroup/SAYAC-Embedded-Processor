--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	GAP	IS
	GENERIC	(	m	:	INTEGER	:=	4	);
	PORT	(	x 	:	IN	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
				y 	:	IN	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
				P	:	OUT	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
				G	:	OUT	STD_LOGIC_VECTOR(m-1	DOWNTO	0)	);
END	GAP;	 

ARCHITECTURE	behavioral	OF	GAP	IS
BEGIN
	P	<=	x XOR y;
	G	<=	x AND y;
--	A	<=	x OR y;
END	behavioral;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CLG_4	IS
	PORT	(	p	:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				g	:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				cin	:	IN	STD_LOGIC;
				c  	:	OUT	STD_LOGIC_VECTOR(3	DOWNTO	0) 	);
END	CLG_4;	 

ARCHITECTURE	behavioral	OF	CLG_4	IS
BEGIN		
	c(0)	<=	g(0) OR (p(0) AND cin	);
	c(1)	<=	g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2)	<=	g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0)) OR 
				(p(2) AND p(1)AND p(0) AND cin);
	c(3)	<=	g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1)) OR
				(p(3) AND p(2)AND p(1) AND g(0)) OR
				(p(3) AND p(2)AND p(1) AND p(0) AND cin	);
END	behavioral;	
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CLG_8	IS
	PORT	(	p	:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				g	:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				cin	:	IN	STD_LOGIC;
				c  	:	OUT	STD_LOGIC_VECTOR(7	DOWNTO	0) 	);
END	CLG_8;	 

ARCHITECTURE	behavioral	OF	CLG_8	IS
BEGIN		
	c(0)	<=	g(0) OR (p(0) AND cin);
	c(1)	<=	g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2)	<=	g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0)) OR 
				(p(2) AND p(1)AND p(0) AND cin);	
	c(3)	<=	g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1)) OR
				(p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(4)	<=	g(4) OR (p(4) AND g(3)) OR (p(4) AND p(3) AND g(2)) OR
				(p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(4) AND p(3) AND p(2) AND p(1) AND P(0) AND cin);
	c(5)	<=	g(5) OR (p(5) AND g(4)) OR (p(5) AND p(4) AND g(3)) OR
				(p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(6)	<=	g(6) OR (p(6) AND g(5)) OR (p(6) AND p(5) AND g(4)) OR
				(p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(7)	<=	g(7) OR (p(7) AND g(6)) OR (p(7) AND p(6) AND g(3)) OR
				(p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
END	behavioral;	
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CLG_16	IS
	PORT	(	p	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				g	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				cin	:	IN	STD_LOGIC;
				c  	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0) 	);
END	CLG_16;	 

ARCHITECTURE	behavioral	OF	CLG_16	IS
BEGIN		
	c(0)	<=	g(0) OR (p(0) AND cin);
	c(1)	<=	g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2)	<=	g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0)) OR
				(p(2) AND p(1)AND p(0) AND cin);	
	c(3)	<=	g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1)) OR
				(p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(4)	<=	g(4) OR (p(4) AND g(3)) OR (p(4) AND p(3) AND g(2)) OR
				(p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(4) AND p(3) AND p(2) AND p(1) AND P(0) AND cin);
	c(5)	<=	g(5) OR (p(5) AND g(4)) OR (p(5) AND p(4) AND g(3)) OR
				(p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(6)	<=	g(6) OR (p(6) AND g(5)) OR (p(6) AND p(5) AND g(4)) OR
				(p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(7)	<=	g(7) OR (p(7) AND g(6)) OR (p(7) AND p(6) AND g(5)) OR
				(p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(8)	<=	g(8) OR (p(8) AND g(7)) OR (p(8) AND p(7) AND g(6)) OR
				(p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(9)	<=	g(9) OR (p(9) AND g(8)) OR (p(9) AND p(8) AND g(7)) OR
				(p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(10)	<=	g(10) OR (p(10) AND g(9)) OR (p(10) AND p(9) AND g(8)) OR
				(p(10) AND p(9) AND p(8) AND g(7)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(11)	<=	g(11) OR (p(11) AND g(10)) OR (p(11) AND p(10) AND g(9)) OR
				(p(11) AND p(10) AND p(9) AND g(8)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND g(7)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(12)	<=	g(12) OR (p(12) AND g(11)) OR (p(12) AND p(11) AND g(10)) OR
				(p(12) AND p(11) AND p(10) AND g(9)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND g(8)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(13)	<=	g(13) OR (p(13) AND g(12)) OR (p(13) AND p(12) AND g(11)) OR
				(p(13) AND p(12) AND p(11) AND g(10)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND g(9)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(14)	<=	g(14) OR (p(14) AND g(13)) OR (p(14) AND p(13) AND g(12)) OR
				(p(14) AND p(13) AND p(12) AND g(11)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND g(10)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(15)	<=	g(15) OR (p(15) AND g(14)) OR (p(15) AND p(14) AND g(13)) OR
				(p(15) AND p(14) AND p(13) AND g(12)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND g(11)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND g(10)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0)) OR
				(p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
END	behavioral;
---------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CLA16	IS
	PORT	(	 x	 	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				y 		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				cin		:	IN	STD_LOGIC;
				sum		:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	CLA16;		 

ARCHITECTURE	behavioral	OF	CLA16	IS
	SIGNAL	c	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	P	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	G	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN
	MY_GAP:	ENTITY	WORK.GAP	GENERIC	MAP	(	16	)
				PORT	MAP	(	x, 
								y, 
								P, 
								G	);
	
	MY_CLG_16:	ENTITY	WORK.CLG_16
					PORT	MAP	(	P, 
									G, 
									cin, 
									c	);

	sum(0)				<=	p(0) XOR cin;
	sum(15	DOWNTO	1)	<=	p(15	DOWNTO	1) XOR c(14	DOWNTO	0);
END	behavioral;	 
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CLA_block	IS
	GENERIC	(	m		:	INTEGER	:=	4	);
	PORT	(	x	 	:	IN	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
				y 		:	IN	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
				cin		:	IN	STD_LOGIC;
				sum		:	OUT	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
				cout	:	OUT	STD_LOGIC	);
END	CLA_block;	 

ARCHITECTURE	behavioral	OF	CLA_block	IS
	SIGNAL	c	:	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
	SIGNAL	P	:	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
	SIGNAL	G	:	STD_LOGIC_VECTOR(m-1	DOWNTO	0);
BEGIN
	MY_GAP:	ENTITY	WORK.GAP	GENERIC	MAP	(	m	)
		PORT	MAP	(	x, 
						y, 
						P, 
						G	);
	
	checkm_4:	IF	m = 4	GENERATE
		MY_CLG_4:	ENTITY	WORK.CLG_4
						PORT	MAP	(	P, 
										G, 
										cin, 
										C	);
	END	GENERATE;
	
	checkm_8:	IF	m = 8	GENERATE
		MY_CLG_8:	ENTITY	WORK.CLG_8
						PORT	MAP	(	P, 
										G, 
										cin, 
										C	);
	END	GENERATE;
	
	checkm_16:	IF	m = 16	GENERATE
		MY_CLG_16:	ENTITY	WORK.CLG_16
						PORT	MAP	(	P, 
										G, 
										cin, 
										C	);
	END	GENERATE;	

	cout				<=	C(m-1);
	sum(0)				<=	p(0) XOR cin;
	sum(m-1	DOWNTO	1)	<=	p(m-1	DOWNTO	1) XOR c(m-2	DOWNTO	0);
END	behavioral;	
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CLA	IS
	GENERIC	(	n		:	INTEGER	:=	32;
				m		:	INTEGER	:=	4	);
	PORT	(	x 		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				y 		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				cin		:	IN	STD_LOGIC;
				sum		:	OUT	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				cout	:	OUT	STD_LOGIC	);
END	CLA;	 

ARCHITECTURE	behavioral	OF	CLA	IS
	SIGNAL	c	:	STD_LOGIC_VECTOR(n/m-1	DOWNTO	0);
BEGIN
	checkm_4:	IF	m = 4	GENERATE
		first_0_4:	ENTITY	WORK.CLA_block	GENERIC	MAP	(	4	)
						PORT	MAP	(	x(m-1	DOWNTO	0), 
										y(m-1	DOWNTO	0), 
										cin, 
										sum(m-1	DOWNTO	0), 
										c(0)	);
		
		rest_4:	FOR	I	IN	1	TO	n/m-1	GENERATE
			rest_I_4:	ENTITY	WORK.CLA_block	GENERIC	MAP	(	4	)
							PORT	MAP	(	x(m*(I+1)-1	DOWNTO	m*I), 
											y(m*(I+1)-1	DOWNTO	m*I), 
											c(I-1), 
											sum(m*(I+1)-1	DOWNTO	m*I), 
											c(I)	);
		END	GENERATE;
	END	GENERATE;
	
	checkm_8:	IF	m = 8	GENERATE
		first_0_8:	ENTITY	WORK.CLA_block	GENERIC	MAP	(	8	)
						PORT	MAP	(	x(m-1	DOWNTO	0), 
										y(m-1	DOWNTO	0), 
										cin, 
										sum(m-1	DOWNTO	0), 
										c(0)	);
		
		rest_8:	FOR	I	IN	1	TO	n/m-1	GENERATE
			rest_I_8:	ENTITY	WORK.CLA_block	GENERIC	MAP	(	8	)
							PORT	MAP	(	x(m*(I+1)-1	DOWNTO	m*I), 
											y(m*(I+1)-1	DOWNTO	m*I), 
											c(I-1), 
											sum(m*(I+1)-1	DOWNTO	m*I), 
											c(I)	);
		END	GENERATE;
	END	GENERATE;
	
	checkm_16:	IF	m = 16	GENERATE
		first_0_16:	ENTITY	WORK.CLA_block	GENERIC	MAP	(	16	)
						PORT	MAP	(	x(m-1	DOWNTO	0), 
										y(m-1	DOWNTO	0), 
										cin, 
										sum(m-1	DOWNTO	0), 
										c(0)	);
		
		rest_16:	FOR	I	IN	1	TO	n/m-1	GENERATE
			rest_I_16:	ENTITY	WORK.CLA_block	GENERIC	MAP	(	16	)
							PORT	MAP	(	x(m*(I+1)-1	DOWNTO	m*I), 
											y(m*(I+1)-1	DOWNTO	m*I), 
											c(I-1), 
											sum(m*(I+1)-1	DOWNTO	m*I), 
											c(I)	);
		END	GENERATE;
	END	GENERATE;
	
	cout	<=	c(n/m-1	);
END	behavioral;	 
------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------
