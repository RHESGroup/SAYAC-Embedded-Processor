--******************************************************************************
--	Filename:		SAYAC_DPB.vhd
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
--	DataPath Blocks (DPB)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	IMM	IS
	PORT	(	in1			:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				in2			:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				in3			:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				SE5bits		:	IN	STD_LOGIC;
				SE6bits		:	IN	STD_LOGIC;
				USE8bits	:	IN	STD_LOGIC;
				SE8bits		:	IN	STD_LOGIC;
				p1lowbits	:	IN	STD_LOGIC;
				selrs1_imm	:	IN	STD_LOGIC;
				selcnt_imm	:	IN	STD_LOGIC;
				USE12bits	:	IN	STD_LOGIC;
				outIMM  	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	IMM;

ARCHITECTURE	behavior	OF	IMM	IS
BEGIN
	outIMM	<=	(15	DOWNTO	5 => in1(4)) & in1(4	DOWNTO	0)	WHEN	SE5bits = '1'							ELSE
				(15	DOWNTO	6 => in1(5)) & in1(5	DOWNTO	0)	WHEN	SE6bits = '1'							ELSE
				(15	DOWNTO	8 => '0') & in1						WHEN	USE8bits = '1'							ELSE
				(15	DOWNTO	8 => in1(7)) & in1					WHEN	SE8bits = '1'							ELSE
				in1 & in2										WHEN	p1lowbits = '1'							ELSE 
				(15	DOWNTO	4 => '0') & in1(3	DOWNTO	0)		WHEN	selrs1_imm = '1' AND USE12bits = '1'	ELSE
				(15	DOWNTO	4 => '0') & in3						WHEN	selcnt_imm = '1' AND USE12bits = '1'	ELSE
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	COMP	IS
	PORT	(	inCOMP		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				onebartwo	:	IN	STD_LOGIC;
				outCOMP		:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	COMP;

ARCHITECTURE	behavior	OF	COMP	IS
	SIGNAL	carry 	:	STD_LOGIC_VECTOR(16	DOWNTO	1);
BEGIN
	-- Half Adder
	outCOMP(0)	<=	(NOT inCOMP(0)) XOR onebartwo;
	carry(1)	<=	(NOT inCOMP(0)) AND onebartwo;
	
	rest:	FOR	I	IN	1	TO	15	GENERATE
			outCOMP(I)	<=	(NOT inCOMP(I)) XOR carry(I);
			carry(I+1)	<=	(NOT inCOMP(I)) AND carry(I);
	END	GENERATE;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	LLU	IS
	PORT	(	in1			:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2			:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				logicAND	:	IN	STD_LOGIC;
				onesComp	:	IN	STD_LOGIC;
				twosComp	:	IN	STD_LOGIC;
				outLLU 		:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	LLU;

ARCHITECTURE	behavior	OF	LLU	IS
	SIGNAL	onebartwo	:	STD_LOGIC;
	SIGNAL	outCOMP		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN
	onebartwo	<=	'0'	WHEN	onesComp = '1'	ELSE
					'1'	WHEN	twosComp = '1'	ELSE '0';
				 
	COMPlementer:	ENTITY	WORK.COMP
						PORT	MAP	(	in1, 
										onebartwo, 
										outCOMP	);
	
	outLLU	<=	(in1 AND in2)	WHEN	logicAND = '1'						ELSE
				outCOMP			WHEN	onesComp = '1' OR twosComp = '1'	ELSE
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	ASU	IS
	PORT	(	in1			:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2			:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				arithADD	:	IN	STD_LOGIC;
				arithSUB	:	IN	STD_LOGIC;
				outASU  	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)		
		);
END	ENTITY	ASU;

ARCHITECTURE	behavior	OF	ASU	IS
	SIGNAL	cin		:	STD_LOGIC;
	SIGNAL	input2	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN
	cin		<=	'0'			WHEN	arithADD = '1'	ELSE
				'1'			WHEN	arithSUB = '1'	ELSE 
				'0';
	input2	<=	in2			WHEN	arithADD = '1'	ELSE
				(NOT in2)	WHEN	arithSUB = '1'	ELSE 
				(OTHERS => '0');
	
	ADD1:	ENTITY	WORK.CLA	GENERIC	MAP	(	16, 16	) 
				PORT	MAP	(	in1, 
								input2, 
								cin, 
								outASU	);
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	SHU	IS
	PORT	(	in1    	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2    	:	IN	STD_LOGIC_VECTOR(4	DOWNTO	0);
				logicSH	:	IN	STD_LOGIC;
				arithSH	:	IN	STD_LOGIC;
				outSHU	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	SHU;

ARCHITECTURE	behavior	OF	SHU	IS	
	SIGNAL	cases			:	STD_LOGIC_VECTOR(2	DOWNTO	0);
	SIGNAL	outSHU_reg		:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	right_SHU_reg	:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	left_SHU_reg	:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	ser				:	STD_LOGIC;
	ALIAS	shift_num		:	STD_LOGIC_VECTOR(3	DOWNTO	0)	IS	in2(3	DOWNTO	0);
BEGIN	
	cases	<=	(in2(4) & logicSH & arithSH	);
	ser		<=	in1(15)	WHEN	arithSH = '1'	ELSE '0';	

	-- outSHU_reg(15 DOWNTO	in2)		<=	in1((15 - in2)	DOWNTO	0);
	-- outSHU_reg((in2 - 1)	DOWNTO	0)	<=	(OTHERS => '0');
	
	PROCESS	(	in1, shift_num, ser	)
	BEGIN
		CASE	shift_num	IS
			WHEN	"0000"	=>
				right_SHU_reg(15	DOWNTO	0)	<=	in1(15	DOWNTO	0);
				right_SHU_reg(16)				<=	ser;
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	0)	<=	in1(15	DOWNTO	0);
			WHEN	"0001"	=>
				right_SHU_reg(14	DOWNTO	0)	<=	in1(15	DOWNTO	1);
				right_SHU_reg(16	DOWNTO	15)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	1)	<=	in1(14	DOWNTO	0);
				left_SHU_reg(0)					<=	'0';
			WHEN	"0010"	=>
				right_SHU_reg(13	DOWNTO	0)	<=	in1(15	DOWNTO	2);
				right_SHU_reg(16	DOWNTO	14)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	2)	<=	in1(13	DOWNTO	0);
				left_SHU_reg(1 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"0011"	=>
				right_SHU_reg(12	DOWNTO	0)	<=	in1(15	DOWNTO	3);
				right_SHU_reg(16	DOWNTO	13)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	3)	<=	in1(12	DOWNTO	0);
				left_SHU_reg(2		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"0100"	=>
				right_SHU_reg(11	DOWNTO	0)	<=	in1(15	DOWNTO	4);
				right_SHU_reg(16	DOWNTO	12)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	4)	<=	in1(11	DOWNTO	0);
				left_SHU_reg(3 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"0101"	=>
				right_SHU_reg(10	DOWNTO	0)	<=	in1(15	DOWNTO	5);
				right_SHU_reg(16	DOWNTO	11)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	5)	<=	in1(10	DOWNTO	0);
				left_SHU_reg(4 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"0110"	=>
				right_SHU_reg(9		DOWNTO 0)	<=	in1(15	DOWNTO	6);
				right_SHU_reg(16	DOWNTO	10)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	6)	<=	in1(9	DOWNTO	0);
				left_SHU_reg(5 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"0111"	=>
				right_SHU_reg(8		DOWNTO 0)	<=	in1(15	DOWNTO	7);
				right_SHU_reg(16	DOWNTO	9)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	7)	<=	in1(8	DOWNTO	0);
				left_SHU_reg(6 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1000"	=>
				right_SHU_reg(7		DOWNTO 0)	<=	in1(15	DOWNTO	8);
				right_SHU_reg(16	DOWNTO	8)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	8)	<=	in1(7	DOWNTO	0);
				left_SHU_reg(7 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1001"	=>
				right_SHU_reg(6		DOWNTO 0)	<=	in1(15	DOWNTO	9);
				right_SHU_reg(16	DOWNTO	7)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	9)	<=	in1(6	DOWNTO	0);
				left_SHU_reg(8 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1010"	=>
				right_SHU_reg(5		DOWNTO 0)	<=	in1(15	DOWNTO	10);
				right_SHU_reg(16	DOWNTO	6)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	10)	<=	in1(5	DOWNTO	0);
				left_SHU_reg(9 		DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1011"	=>
				right_SHU_reg(4		DOWNTO 0)	<=	in1(15	DOWNTO	11);
				right_SHU_reg(16	DOWNTO	5)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	11)	<=	in1(4	DOWNTO	0);
				left_SHU_reg(10 	DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1100"	=>
				right_SHU_reg(3		DOWNTO 0)	<=	in1(15	DOWNTO	12);
				right_SHU_reg(16	DOWNTO	4)	<=	(OTHERS => ser);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	12)	<=	in1(3	DOWNTO	0);
				left_SHU_reg(11 	DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1101"	=>
				right_SHU_reg(2		DOWNTO 0)	<=	in1(15	DOWNTO	13	);
				right_SHU_reg(16	DOWNTO	3)	<=	(OTHERS => ser	);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	13)	<=	in1(2	DOWNTO	0);
				left_SHU_reg(12 	DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1110"	=>
				right_SHU_reg(1		DOWNTO 0)	<=	in1(15	DOWNTO	14	);
				right_SHU_reg(16	DOWNTO	2)	<=	(OTHERS => ser	);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15		DOWNTO	14)	<=	in1(1	DOWNTO	0);
				left_SHU_reg(13 	DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	"1111"	=>
				right_SHU_reg(0)				<=	in1(15	);
				right_SHU_reg(16	DOWNTO	1)	<=	(OTHERS => ser	);
				
				left_SHU_reg(16) 				<=	'0';
				left_SHU_reg(15)				<=	in1(0	);
				left_SHU_reg(14 	DOWNTO	0)	<=	(OTHERS => '0');
			WHEN	OTHERS	=>
			
		END	CASE;
	END	PROCESS;
	
--	PROCESS	(	in2, logicSH, arithSH, cases, in1	)
	PROCESS	(	right_SHU_reg, cases, left_SHU_reg	)
	BEGIN		
		CASE cases	IS
			WHEN "001" =>						-- arithmetic right shift
				outSHU_reg	<=	right_SHU_reg;
			WHEN "010" =>						-- logical right shift
				outSHU_reg	<=	right_SHU_reg;
			WHEN "101" =>						-- arithmetic left shift
				outSHU_reg	<=	left_SHU_reg;
			WHEN "110" =>						-- logic left shift
				outSHU_reg	<=	left_SHU_reg;
			WHEN OTHERS =>
				outSHU_reg	<=	(OTHERS => '0');
		END	CASE;
	END	PROCESS;
	
	outSHU	<=	outSHU_reg(15	DOWNTO	0);
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	MDU	IS
	PORT	(	clk				:	IN	STD_LOGIC;
				rst				:	IN	STD_LOGIC;
				startMDU		:	IN	STD_LOGIC;
				arithMUL		:	IN	STD_LOGIC;
				arithDIV		:	IN	STD_LOGIC;
				signMDU			:	IN	STD_LOGIC;
				ldMDU1			:	IN	STD_LOGIC;
				ldMDU2			:	IN	STD_LOGIC;
				in1         	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2         	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				outMDU1		 	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0);
				outMDU2			:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0);
				DividedByZero	:	OUT	STD_LOGIC;
				readyMDU        :	OUT	STD_LOGIC	);
END	ENTITY	MDU;

ARCHITECTURE	behavior	OF	MDU	IS
	SIGNAL	outMDU_reg	:	STD_LOGIC_VECTOR(31	DOWNTO	0);
	SIGNAL	outMULT		:	STD_LOGIC_VECTOR(31	DOWNTO	0);
	SIGNAL	outDIV		:	STD_LOGIC_VECTOR(31	DOWNTO	0);
	SIGNAL	opr1		:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	opr2		:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	inp1		:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	inp2		:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	twosCompin1	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	twosCompin2	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	Q			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	R			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	twosCompQ	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	twosCompR	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	doneMULT	:	STD_LOGIC;
	SIGNAL	doneDIV		:	STD_LOGIC;
	SIGNAL	startMULT	:	STD_LOGIC;
	SIGNAL	startDIV	:	STD_LOGIC;
BEGIN
	opr1	<=	(in1(15) & in1)	WHEN	signMDU = '1'	ELSE ('0' & in1	);
	opr2	<=	(in2(15) & in2)	WHEN	signMDU = '1'	ELSE ('0' & in2	);
	
	COMPin1:	ENTITY	WORK.COMP
					PORT	MAP	 (	in1, 
									'1', 
									twosCompin1	);
	COMPin2:	ENTITY	WORK.COMP
					PORT	MAP	 (	in2, 
									'1', 
									twosCompin2	);

	inp1		<=	(twosCompin1(15) & twosCompin1)	WHEN	(in1(15) AND signMDU) = '1'	ELSE ('0' & in1);
	inp2		<=	(twosCompin2(15) & twosCompin2)	WHEN	(in2(15) AND signMDU) = '1'	ELSE ('0' & in2);
	
	startMULT	<=	arithMUL AND startMDU;
	startDIV 	<=	arithDIV AND startMDU			WHEN	inp2 /= "00000000000000000"	ELSE '0';
	
--	MULT:	ENTITY	WORK.Booth_MUL
	MULT:	ENTITY	WORK.Radix4_MUL
	-- MULT:	ENTITY	WORK.Radix16_MUL
				PORT	MAP	 (	clk, 
								rst, 
								startMULT, 
								opr1, 
								opr2, 
								doneMULT, 
								outMULT	);
	
	DIVU:	ENTITY	WORK.Radix2_DIV 
				PORT	MAP	 (	clk, 
								rst, 
								startDIV, 
								inp1, 
								inp2, 
								doneDIV, 
								outDIV	);
	
	COMPQ:	ENTITY	WORK.COMP
				PORT	MAP	(	outDIV(15	DOWNTO	0), 
								'1', 
								twosCompQ	);

	COMPR:	ENTITY	WORK.COMP
				PORT	MAP	(	outDIV(31	DOWNTO	16), 
								'1', 
								twosCompR	);
	
	Q	<=	twosCompQ	WHEN	((in1(15) XOR in2(15)) AND signMDU) = '1'	ELSE outDIV(15	DOWNTO	0);
	R	<=	twosCompR	WHEN	(in1(15) AND signMDU) = '1'					ELSE outDIV(31	DOWNTO	16);
	
	-- outMDU_reg	<=	outMULT	WHEN	arithMUL = '1'	ELSE
				  -- (R & Q)	WHEN	arithDIV = '1';
	
	DividedByZero	<=	'1'	WHEN	arithDIV = '1' AND inp2 = "00000000000000000"	ELSE '0';
--	readyMDU    	<=	(arithMUL AND doneMULT) OR (arithDIV AND doneDIV	);
					
	PROCESS	(	doneMULT, arithMUL, arithDIV, doneDIV, inp2, outMULT, R, Q	)
	BEGIN
		IF		arithMUL = '1'	THEN
			readyMDU  	<=	doneMULT;
			outMDU_reg	<=	outMULT;
		ELSIF	arithDIV = '1'	THEN
			IF	inp2 = "00000000000000000"	THEN
				readyMDU  	<=	'1';
				outMDU_reg	<=	(OTHERS => '0');
			ELSE
				readyMDU  	<=	doneDIV;
				outMDU_reg	<=	(R & Q	);
			END	IF;
		ELSE
			readyMDU  	<=	'0';
			outMDU_reg	<=	(OTHERS => '0');
		END	IF;
	END	PROCESS;
	
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outMDU1	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	ldMDU1 = '1'	THEN
				outMDU1	<=	outMDU_reg(15	DOWNTO	0);
			END	IF;
		END	IF;
	END	PROCESS;
	
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outMDU2	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	ldMDU2 = '1'	THEN
				outMDU2	<=	outMDU_reg(31	DOWNTO	16);
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	CMP	IS
	PORT	(	in1		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				signCMP :	IN	STD_LOGIC;
				eq		:	OUT	STD_LOGIC;	
				gt  	:	OUT	STD_LOGIC	
		);
END	ENTITY	CMP;

ARCHITECTURE	behavior	OF	CMP	IS
	SIGNAL	ina	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	inb	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN
	-- eq	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(in2)) = TO_INTEGER(UNSIGNED(in1))	ELSE '0';
	-- gt	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(in2)) > TO_INTEGER(UNSIGNED(in1))	ELSE '0';	
	
	ina (15)			<=	in1(15) XOR signCMP;
	inb (15)			<=	in2(15) XOR signCMP;
	ina (14	DOWNTO	0)	<=	in1 (14	DOWNTO	0);
	inb (14	DOWNTO	0)	<=	in2 (14	DOWNTO	0);
	
	PROCESS	(	ina, inb	)
	BEGIN
		IF		TO_INTEGER(UNSIGNED(inb)) = TO_INTEGER(UNSIGNED(ina))	THEN
			eq	<=	'1';		gt	<=	'0';
		ELSIF	TO_INTEGER(UNSIGNED(inb)) > TO_INTEGER(UNSIGNED(ina))	THEN
			gt	<=	'1';		eq	<=	'0';
		ELSE
			gt	<=	'0';		eq	<=	'0';
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	ADD	IS
	GENERIC	(	 n		:	INTEGER	:=	16	);
	PORT	(	in1		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				in2		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				outADD	:	OUT	STD_LOGIC_VECTOR(n-1	DOWNTO	0)	);
END	ENTITY	ADD;

ARCHITECTURE	behavior	OF	ADD	IS
BEGIN
	ADD1:	ENTITY	WORK.CLA	GENERIC	MAP	(	n, n	)
				PORT	MAP	(	in1, 
								in2, 
								'0', 
								outADD	);
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	MUX2ofnbits	IS
	GENERIC	(	n		:	INTEGER	:=	16	);	-- number	OF	input bits
	PORT	(	in1		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				in2		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				sel1	:	IN	STD_LOGIC;
				sel2	:	IN	STD_LOGIC;
				outMUX	:	OUT	STD_LOGIC_VECTOR(n-1	DOWNTO	0)	);
END	ENTITY	MUX2ofnbits;

ARCHITECTURE	behavior	OF	MUX2ofnbits	IS
BEGIN
	outMUX	<=	in1	WHEN	sel1 = '1'	ELSE
				in2	WHEN	sel2 = '1'	ELSE 
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	MUX8of16bits	IS
	PORT	(	in1		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in3		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in4		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in5		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in6		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in7		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in8		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				sel1	:	IN	STD_LOGIC;
				sel2	:	IN	STD_LOGIC;
				sel3	:	IN	STD_LOGIC;
				sel4	:	IN	STD_LOGIC;
				sel5	:	IN	STD_LOGIC;
				sel6	:	IN	STD_LOGIC;
				sel7	:	IN	STD_LOGIC;
				sel8	:	IN	STD_LOGIC;
				outMUX	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	MUX8of16bits;

ARCHITECTURE	behavior	OF	MUX8of16bits	IS
BEGIN
	outMUX	<=	in1	WHEN	sel1 = '1'	ELSE
				in2	WHEN	sel2 = '1'	ELSE 
				in3	WHEN	sel3 = '1'	ELSE 
				in4	WHEN	sel4 = '1'	ELSE 
				in5	WHEN	sel5 = '1'	ELSE 
				in6	WHEN	sel6 = '1'	ELSE 
				in7	WHEN	sel7 = '1'	ELSE 
				in8	WHEN	sel8 = '1'	ELSE 
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	MUX4of16bits	IS
	PORT	(	in1	   	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2	   	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in3	   	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in4   	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				sel1	:	IN	STD_LOGIC;
				sel2	:	IN	STD_LOGIC;
				sel3	:	IN	STD_LOGIC;
				sel4	:	IN	STD_LOGIC;
				outMUX	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	MUX4of16bits;

ARCHITECTURE	behavior	OF	MUX4of16bits	IS
BEGIN
	outMUX	<=	in1	WHEN	sel1 = '1'	ELSE
				in2	WHEN	sel2 = '1'	ELSE 
				in3	WHEN	sel3 = '1'	ELSE 
				in4	WHEN	sel4 = '1'	ELSE
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	MUX5of16bits	IS
	PORT	(	in1	    :	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2	    :	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in3	    :	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in4     :	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in5     :	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				sel1	:	IN	STD_LOGIC;
				sel2	:	IN	STD_LOGIC;
				sel3	:	IN	STD_LOGIC;
				sel4	:	IN	STD_LOGIC;
				sel5	:	IN	STD_LOGIC;
				outMUX	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)
		);
END	ENTITY	MUX5of16bits;

ARCHITECTURE	behavior	OF	MUX5of16bits	IS
BEGIN
	outMUX	<=	in1	WHEN	sel1 = '1'	ELSE
				in2	WHEN	sel2 = '1'	ELSE 
				in3	WHEN	sel3 = '1'	ELSE 
				in4	WHEN	sel4 = '1'	ELSE
				in5	WHEN	sel5 = '1'	ELSE
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	MUX3of16bits	IS
	PORT	(	in1		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in2		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				in3		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				sel1	:	IN	STD_LOGIC;
				sel2	:	IN	STD_LOGIC;
				sel3	:	IN	STD_LOGIC;
				outMUX	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	MUX3of16bits;

ARCHITECTURE	behavior	OF	MUX3of16bits	IS
BEGIN
	outMUX	<=	in1	WHEN	sel1 = '1'	ELSE
				in2	WHEN	sel2 = '1'	ELSE 
				in3	WHEN	sel3 = '1'	ELSE 
				(OTHERS => '0');
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	REG	IS
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				ld		:	IN	STD_LOGIC;
				inREG	:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				outREG	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	REG;

ARCHITECTURE	behavior	OF	REG	IS
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outREG	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	ld = '1'	THEN
				outREG	<=	inREG;
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	REG1	IS
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				ld		:	IN	STD_LOGIC;
				inREG	:	IN	STD_LOGIC;
				outREG	:	OUT	STD_LOGIC	);
END	ENTITY	REG1;

ARCHITECTURE	behavior	OF	REG1	IS
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outREG	<=	'0';
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	ld = '1'	THEN
				outREG	<=	inREG;
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	CNT	IS
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				rst_cnt	:	IN	STD_LOGIC;
				inc_cnt	:	IN	STD_LOGIC;
				outCNT	:	OUT	STD_LOGIC_VECTOR(3	DOWNTO	0)	);
END	ENTITY	CNT;

ARCHITECTURE	behavior	OF	CNT	IS
   SIGNAL	outCNT_reg	:	STD_LOGIC_VECTOR(3	DOWNTO	0);
   SIGNAL	outCNT_INC	:	STD_LOGIC_VECTOR(3	DOWNTO	0);
BEGIN
	INCrementer:	ENTITY	WORK.INC	GENERIC	MAP	(	4	)
						PORT	MAP	(	outCNT_reg,
										outCNT_INC	);

  PROCESS	(	clk, rst	)
   BEGIN
       IF		rst = '1'	THEN
			outCNT_reg	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	rst_cnt = '1'	THEN
				outCNT_reg	<=	(OTHERS => '0');
        ELSIF	inc_cnt = '1'	THEN
            outCNT_reg	<=	outCNT_INC;
			END	IF;
		END	IF;
   END	PROCESS;

   outCNT	<=	outCNT_reg;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	EAG	IS
	PORT	(	clk    			:	IN 	STD_LOGIC;
				rst     		:	IN 	STD_LOGIC;
				ldExcBaseAddr	:	IN 	STD_LOGIC;
				ExcSrcNum    	:	IN 	STD_LOGIC_VECTOR(2	DOWNTO	0);
				ExcBaseAddr  	:	IN 	STD_LOGIC_VECTOR(15	DOWNTO	0);
				ExcOffAddr   	:	IN 	STD_LOGIC_VECTOR(4	DOWNTO	0);
				ESA		     	:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	EAG;

ARCHITECTURE	behavior	OF	EAG	IS
	SIGNAL	OffAddr		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	BaseAddr	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN			   
	PROCESS	(	ExcOffAddr, ExcSrcNum	)
	BEGIN
		CASE	(	ExcSrcNum	)	IS
			WHEN	"001"	=>	
				OffAddr	<=	(15	DOWNTO	5 => '0') & ExcOffAddr;
			WHEN	"010"	=>	
				OffAddr	<=	(15	DOWNTO	6 => '0') & ExcOffAddr & '0';
			WHEN	"011"	=>	
				OffAddr	<=	(15	DOWNTO	7 => '0') & ExcOffAddr & "00";
			WHEN	"100"	=>	
				OffAddr	<=	(15	DOWNTO	8 => '0') & ExcOffAddr & "000";
			WHEN	"101"	=>	
				OffAddr	<=	(15	DOWNTO	9 => '0') & ExcOffAddr & "0000";
			WHEN	"110"	=>	
				OffAddr	<=	(15	DOWNTO	10 => '0') & ExcOffAddr & "00000";
			WHEN	OTHERS	=>	
				OffAddr	<=	(OTHERS => '0');
		END	CASE;
	END	PROCESS;

	BaseReg	:	ENTITY	WORK.REG
					PORT	MAP	 (	clk, 
									rst, 
									ldExcBaseAddr, 
									ExcBaseAddr, 
									BaseAddr	);
	
	AddrGen:	ENTITY	WORK.ADD	GENERIC	MAP	(	16	)
					PORT	MAP	(	BaseAddr, 
									OffAddr, 
									ESA	);	
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	ESR	IS
	PORT	(	clk				:	IN	STD_LOGIC;
				rst				:	IN	STD_LOGIC;
				ExcServicing	:	IN	STD_LOGIC;
				InstAccFault	:	IN	STD_LOGIC;
				InvalidInst		:	IN	STD_LOGIC;
				LdAccFault		:	IN	STD_LOGIC;
				StAccFault		:	IN	STD_LOGIC;
				EnvCallFault	:	IN	STD_LOGIC;
				DividedByZero	:	IN	STD_LOGIC;
				ExcSrcNum		:	OUT	STD_LOGIC_VECTOR(2	DOWNTO	0);	
				Exception		:	OUT	STD_LOGIC	);
END	ENTITY	ESR;

ARCHITECTURE	behavior	OF	ESR	IS
   SIGNAL	ExcSrcNum_reg	:	STD_LOGIC_VECTOR(2	DOWNTO	0);
   SIGNAL	Exception_reg	:	STD_LOGIC;
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
       IF		rst = '1'	THEN
			ExcSrcNum_reg	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF		InstAccFault = '1'	THEN
				ExcSrcNum_reg	<=	"001";
			ELSIF	InvalidInst = '1'	THEN
				ExcSrcNum_reg	<=	"010";
			ELSIF	LdAccFault = '1'	THEN
				ExcSrcNum_reg	<=	"011";
			ELSIF	StAccFault = '1'	THEN
				ExcSrcNum_reg	<=	"100";
			ELSIF	EnvCallFault = '1'	THEN
				ExcSrcNum_reg	<=	"101";
			ELSIF	DividedByZero = '1'	THEN
				ExcSrcNum_reg	<=	"110";
			END	IF;
		END	IF;
	END	PROCESS;
	
--	Exception_reg	<=	ExcSrcNum_reg(0) OR ExcSrcNum_reg(1	);
--	Exception_reg	<=	'1'	WHEN	ExcSrcNum_reg /= "000"	ELSE	'0';
	Exception_reg	<=	InstAccFault OR InvalidInst OR LdAccFault OR StAccFault OR EnvCallFault	OR DividedByZero;
	ExcSrcNum		<=	ExcSrcNum_reg;
	
	-- BaseReg:	ENTITY	WORK.REG1
					-- PORT	MAP	 (	clk, 
									-- rst, 
									-- Exception_reg, 
									-- Exception_reg, 
									-- Exception	);
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			Exception	<=	'0';
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	Exception_reg = '1'	THEN
				Exception	<=	'1';
			ELSIF	ExcServicing = '1'	THEN
				Exception	<=	'0';
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	ARC	IS
	PORT	(	addrBus					: IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				regionSize				: IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				accessPolicy			: IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				readMEM					: IN	STD_LOGIC;
				writeMEM				: IN	STD_LOGIC;
				readIO					: IN	STD_LOGIC;
				writeIO					: IN	STD_LOGIC;
				ldIR					: IN	STD_LOGIC;
				InstructionAccessFault	: OUT	STD_LOGIC;		
				StoreAccessFault		: OUT	STD_LOGIC;	
				LoadAccessFault			: OUT	STD_LOGIC	);
END	ENTITY	ARC;

ARCHITECTURE	behavior	OF	ARC	IS
	SIGNAL	B						:	STD_LOGIC;
	SIGNAL	I						:	STD_LOGIC;
	SIGNAL	G						:	STD_LOGIC;
	SIGNAL	P						:	STD_LOGIC;
	SIGNAL	E						:	STD_LOGIC;
	SIGNAL	SAB						:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	SAI						:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	SAG						:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	SAP						:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	SAE						:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	EAE						:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	
	SIGNAL	InstructionRegionSize	:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	GeneralRegionSize		:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	PeripheralRegionSize	:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	SIGNAL	EventRegionSize			:	STD_LOGIC_VECTOR(5	DOWNTO	0);
	ALIAS	addrBusRegionSize		:	STD_LOGIC_VECTOR(5	DOWNTO	0)	IS	addrBus(15	DOWNTO	10);
	
	ALIAS	RWX_B					:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS	accessPolicy(14	DOWNTO	12);
	ALIAS	RWX_I					:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS	accessPolicy(11	DOWNTO	9);
	ALIAS	RWX_G					:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS	accessPolicy(8	DOWNTO	6);
	ALIAS	RWX_P					:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS	accessPolicy(5	DOWNTO	3);
	ALIAS	RWX_E					:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS	accessPolicy(2	DOWNTO	0);
BEGIN
	SAB						<=	"000000";
	SAI						<=	("0000"	& regionSize(15	DOWNTO	14));
	InstructionRegionSize	<=	('0'	& regionSize(13	DOWNTO	9));
	GeneralRegionSize		<=	('0'	& regionSize(8	DOWNTO	4));
	PeripheralRegionSize	<=	("0000"	& regionSize(3	DOWNTO	2));
	EventRegionSize			<=	("0000"	& regionSize(1	DOWNTO	0));
	
	addSG:	ENTITY	WORK.RCA	GENERIC	MAP	(	6	) 
				PORT	MAP	(	SAI, 
								InstructionRegionSize, 
								SAG	);
			
	addSP:	ENTITY	WORK.RCA	GENERIC	MAP	(	6	) 
				PORT	MAP	(	SAG, 
								GeneralRegionSize, 
								SAP	);
			
	addSE:	ENTITY	WORK.RCA	GENERIC	MAP	(	6	)
				PORT	MAP	(	SAP, 
								PeripheralRegionSize, 
								SAE	);
	
	addEE:	ENTITY	WORK.RCA	GENERIC	MAP	(	6	) 
				PORT	MAP	(	SAE, 
								EventRegionSize, 
								EAE	);
						
	B	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(addrBusRegionSize))	>=	TO_INTEGER(UNSIGNED(SAB)) AND 
						TO_INTEGER(UNSIGNED(addrBusRegionSize))	<	TO_INTEGER(UNSIGNED(SAI))		ELSE	
			'0';
	I	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(addrBusRegionSize))	>=	TO_INTEGER(UNSIGNED(SAI)) AND 
						TO_INTEGER(UNSIGNED(addrBusRegionSize))	<	TO_INTEGER(UNSIGNED(SAG))		ELSE	
			'0';
	G	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(addrBusRegionSize))	>=	TO_INTEGER(UNSIGNED(SAG)) AND  
						TO_INTEGER(UNSIGNED(addrBusRegionSize))	<	TO_INTEGER(UNSIGNED(SAP))		ELSE	
			'0';
	P	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(addrBusRegionSize))	>=	TO_INTEGER(UNSIGNED(SAP)) AND  
						TO_INTEGER(UNSIGNED(addrBusRegionSize))	<	TO_INTEGER(UNSIGNED(SAE))		ELSE	
			'0';
	E	<=	'1'	WHEN	TO_INTEGER(UNSIGNED(addrBusRegionSize))	>=	TO_INTEGER(UNSIGNED(SAE)) AND  
						TO_INTEGER(UNSIGNED(addrBusRegionSize))	<	TO_INTEGER(UNSIGNED(EAE))		ELSE	
			'0';
	
	InstructionAccessFault	<=	'1'	WHEN	(regionSize /= X"0000" AND accessPolicy /= X"0000") AND
											ldIR = '1' AND
											((B = '1' AND RWX_B(0) = '0') OR
											 (I = '1' AND RWX_I(0) = '0') OR
											 (G = '1' AND RWX_G(0) = '0') OR
											 (P = '1' AND RWX_P(0) = '0') OR
											 (E = '1' AND RWX_E(0) = '0') OR
											 (B = '0' AND I = '0' AND G = '0' AND P = '0' AND E = '0'))	ELSE	
								'0';
    StoreAccessFault		<=	'1'	WHEN	(regionSize /= X"0000" AND accessPolicy /= X"0000") AND 
											((writeMEM = '1' AND
											((B = '1' AND RWX_B(1) = '0') OR
											 (I = '1' AND RWX_I(1) = '0') OR
											 (G = '1' AND RWX_G(1) = '0') OR
											 (B = '0' AND I = '0' AND G = '0'))) OR
											(writeIO = '1' AND 
											((P = '1' AND RWX_P(1) = '0') OR
											 (E = '1' AND RWX_E(1) = '0') OR
											 (P = '0' AND E = '0'))))									ELSE	
								'0';
    LoadAccessFault			<=	'1'	WHEN	(regionSize /= X"0000" AND accessPolicy /= X"0000") AND
											((readMEM = '1'		AND 
											((G = '1' AND RWX_G(2) = '0') OR
											 (B = '1' AND RWX_B(2) = '0') OR
											 (I = '1' AND RWX_I(2) = '0') OR
											 (B = '0' AND I = '0' AND G = '0'))) OR
											(readIO = '1'		AND 
											((P = '1' AND RWX_P(2) = '0') OR
											 (E = '1' AND RWX_E(2) = '0') OR	
											 (P = '0' AND E = '0'))))									ELSE
								'0';	
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	PRV	IS
	PORT	(	clk			:	IN	STD_LOGIC;
				rst			:	IN	STD_LOGIC;
				ldPRV		:	IN	STD_LOGIC;
				setMmode	:	IN	STD_LOGIC;
				setUmode	:	IN	STD_LOGIC;
				inPRV		:	IN	STD_LOGIC_VECTOR(1	DOWNTO	0);
				outPRV		:	OUT	STD_LOGIC_VECTOR(1	DOWNTO	0)	);
END	ENTITY	PRV;

ARCHITECTURE	behavior	OF	PRV	IS
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outPRV	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF		ldPRV = '1'	THEN
				outPRV	<=	inPRV;
			ELSIF	setMmode = '1'	THEN
				outPRV	<=	"00";
			ELSIF	setUmode = '1'	THEN
				outPRV	<=	"01";
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	SRB	IS
	PORT	(	clk			:	IN	STD_LOGIC;
				rst			:	IN	STD_LOGIC;
				writeSRB	:	IN	STD_LOGIC;
				addrSRB		:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				inSRB		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				outSRB		:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	SRB;

ARCHITECTURE	behavior	OF	SRB	IS
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outSRB	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	writeSRB = '1' AND addrSRB = "0010"	THEN
				outSRB	<=	inSRB;
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	RSB	IS
	PORT	(	clk			:	IN	STD_LOGIC;
				rst			:	IN	STD_LOGIC;
				writeRSB	:	IN	STD_LOGIC;
				addrRSB		:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				inRSB		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				outRSB		:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	RSB;

ARCHITECTURE	behavior	OF	RSB	IS
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outRSB	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	writeRSB = '1' AND addrRSB = "0001"	THEN
				outRSB	<=	inRSB;
			END	IF;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
