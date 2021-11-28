--******************************************************************************
--  Filename:		SAYAC_DPB.vhd
--  Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--  History:
--  Date:		28 November 2021
--  Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	DataPath Blocks (DPB) of the SAYAC core                                 
--******************************************************************************
--******************************************************************************
--	Filename:		SAYAC_DPB.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			28 November 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	DataPath Blocks (DPB) of the SAYAC core                                 
--******************************************************************************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY IMM IS
	PORT (
		in1, in2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits : IN STD_LOGIC;
		outIMM   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY IMM;

ARCHITECTURE behaviour OF IMM IS
BEGIN
	outIMM <= (15 DOWNTO 5 => in1(4)) & in1(4 DOWNTO 0) WHEN SE5bits = '1' ELSE
		  (15 DOWNTO 6 => in1(5)) & in1(5 DOWNTO 0) WHEN SE6bits = '1' ELSE
		  (15 DOWNTO 8 => '0') & in1 WHEN USE8bits = '1' ELSE
		  (15 DOWNTO 8 => in1(7)) & in1 WHEN SE8bits = '1' ELSE
		  in1 & in2 WHEN p1lowbits = '1' ELSE 
		  (OTHERS => '0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY COMP IS
	PORT (
		inCOMP  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		onebartwo : IN STD_LOGIC;
		outCOMP : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY COMP;

ARCHITECTURE behaviour OF COMP IS
	SIGNAL carry  : STD_LOGIC_VECTOR(16 DOWNTO 1);
BEGIN
	-- Half Adder
	outCOMP(0) <= (NOT inCOMP(0)) XOR onebartwo;
	carry(1) <= (NOT inCOMP(0)) AND onebartwo;
	
	rest : FOR I IN 1 TO 15 GENERATE
			outCOMP(I) <= (NOT inCOMP(I)) XOR carry(I);
			carry(I+1) <= (NOT inCOMP(I)) AND carry(I);
	END GENERATE;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY LLU IS
	PORT (
		in1, in2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		logicAND, onesComp, twosComp : IN STD_LOGIC;
		outLLU  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY LLU;

ARCHITECTURE behaviour OF LLU IS
	SIGNAL onebartwo : STD_LOGIC;
	SIGNAL outCOMP : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	onebartwo <= '0' WHEN onesComp = '1' ELSE
		     '1' WHEN twosComp = '1' ELSE '0';
				 
	COMPlementer : ENTITY WORK.COMP PORT MAP 
				(in1, onebartwo, outCOMP);
	
	outLLU <= (in1 AND in2) WHEN logicAND = '1' ELSE
		  outCOMP WHEN onesComp = '1' OR twosComp = '1' ELSE
		  (OTHERS => '0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY ASU IS
	PORT (
		in1, in2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		arithADD, arithSUB : IN STD_LOGIC;
		outASU   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY ASU;

ARCHITECTURE behaviour OF ASU IS
	SIGNAL cin : STD_LOGIC;
	SIGNAL input2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	cin <= '0' WHEN arithADD = '1' ELSE
	       '1' WHEN arithSUB = '1' ELSE '0';
	input2 <= in2 WHEN arithADD = '1' ELSE
		  (NOT in2) WHEN arithSUB = '1' ELSE 
		  (OTHERS => '0');
	
	ADD1 : ENTITY WORK.CLA GENERIC MAP(16, 16) 
			PORT MAP (in1, input2, cin, outASU);
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY SHU IS
	PORT (
		in1     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		in2     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		logicSH, arithSH : IN STD_LOGIC;
		outSHU : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY SHU;

ARCHITECTURE behaviour OF SHU IS
	SIGNAL cases : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL outSHU_reg : STD_LOGIC_VECTOR(16 DOWNTO 0);
BEGIN	
	cases <= (in2(4) & logicSH & arithSH);
	
	PROCESS (in2, logicSH, arithSH, cases, in1)
	BEGIN		
		CASE cases IS
			WHEN "001" =>						-- arithmetic right shift
				outSHU_reg((15 - TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0)))) DOWNTO 0) <= 
						in1(15 DOWNTO TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0))));
				outSHU_reg(16 DOWNTO (16 - TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0))) - 1)) <= 
						(OTHERS => in1(15));
			WHEN "010" =>						-- logical right shift
				outSHU_reg((15 - TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0)))) DOWNTO 0) <= 
						in1(15 DOWNTO TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0))));
				outSHU_reg(16 DOWNTO (16 - TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0))) - 1)) <= 
						(OTHERS => '0');
			WHEN "101" =>						-- arithmetic left shift
				outSHU_reg(16) <= '0';
				outSHU_reg(15 DOWNTO TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0)))) <= 
						in1((15 - TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0)))) DOWNTO 0);
				outSHU_reg((TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0))) - 1) DOWNTO 0) <= 
						(OTHERS => '0');
			WHEN "110" =>						-- logic left shift
				outSHU_reg(16) <= '0';
				outSHU_reg(15 DOWNTO TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0)))) <= 
						in1((15 - TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0)))) DOWNTO 0);
				outSHU_reg((TO_INTEGER(UNSIGNED(in2(3 DOWNTO 0))) - 1) DOWNTO 0) <= 
						(OTHERS => '0');
			WHEN OTHERS =>
				outSHU_reg <=  (OTHERS => '0');
		END CASE;
	END PROCESS;
	
	outSHU <= outSHU_reg(15 DOWNTO 0);
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MDU IS
	PORT (
		clk, rst, startMDU, arithMUL, arithDIV, signMDU, ldMDU1, ldMDU2 : IN STD_LOGIC;
		in1, in2          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		outMDU1, outMDU2  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		readyMDU          : OUT STD_LOGIC
	);
END ENTITY MDU;

ARCHITECTURE behaviour OF MDU IS
	SIGNAL outMDU_reg, outMULT, outDIV : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL opr1, opr2 : STD_LOGIC_VECTOR(16 DOWNTO 0);
	SIGNAL inp1, inp2 : STD_LOGIC_VECTOR(16 DOWNTO 0);
	SIGNAL twosCompin1, twosCompin2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Q, R, twosCompQ, twosCompR : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL doneMULT, doneDIV : STD_LOGIC;
	SIGNAL startMULT, startDIV : STD_LOGIC;
BEGIN
	opr1 <= (in1(15) & in1) WHEN signMDU = '1' ELSE ('0' & in1);
	opr2 <= (in2(15) & in2) WHEN signMDU = '1' ELSE ('0' & in2);
	
	COMPin1 : ENTITY WORK.COMP PORT MAP 
			(in1, '1', twosCompin1);
	COMPin2 : ENTITY WORK.COMP PORT MAP 
			(in2, '1', twosCompin2);
	inp1 <= (twosCompin1(15) & twosCompin1) WHEN (in1(15) AND signMDU) = '1' ELSE ('0' & in1);
	inp2 <= (twosCompin2(15) & twosCompin2) WHEN (in2(15) AND signMDU) = '1' ELSE ('0' & in2);
	
	startMULT <= arithMUL AND startMDU;
	startDIV  <= arithDIV AND startMDU;
	
	MULT : ENTITY WORK.Radix4_MUL
--	MULT : ENTITY WORK.Radix16_MUL
		PORT MAP (clk, rst, startMULT, '0', opr1, opr2, doneMULT, outMULT);
	
	DIVU : ENTITY WORK.Radix2_DIV 
		PORT MAP (clk, rst, startDIV, inp1, inp2, doneDIV, outDIV);
	
	COMPQ : ENTITY WORK.COMP PORT MAP 
			(outDIV(15 DOWNTO 0), '1', twosCompQ);
	COMPR : ENTITY WORK.COMP PORT MAP 
			(outDIV(31 DOWNTO 16), '1', twosCompR);
	Q <= twosCompQ WHEN ((in1(15) XOR in2(15)) AND signMDU) = '1' ELSE outDIV(15 DOWNTO 0);
	R <= twosCompR WHEN (in1(15) AND signMDU) = '1' ELSE outDIV(31 DOWNTO 16);
	
	outMDU_reg <= outMULT WHEN arithMUL = '1' ELSE
		      (R & Q) WHEN arithDIV = '1';
	
	readyMDU <= (arithMUL AND doneMULT) OR (arithDIV AND doneDIV);
	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			outMDU1 <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ldMDU1 = '1' THEN
				outMDU1 <= outMDU_reg(15 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			outMDU2 <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ldMDU2 = '1' THEN
				outMDU2 <= outMDU_reg(31 DOWNTO 16);
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY CMP IS
	PORT (
		in1, in2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		signCMP  : IN STD_LOGIC;
		eq, gt   : OUT STD_LOGIC	
	);
END ENTITY CMP;

ARCHITECTURE behaviour OF CMP IS
	SIGNAL ina, inb : STD_LOGIC_VECTOR (15 DOWNTO 0);
BEGIN
	-- eq <= '1' WHEN TO_INTEGER(UNSIGNED(in2)) = TO_INTEGER(UNSIGNED(in1)) ELSE '0';
	-- gt <= '1' WHEN TO_INTEGER(UNSIGNED(in2)) > TO_INTEGER(UNSIGNED(in1)) ELSE '0';	
	
	ina (15) <= in1(15) XOR signCMP;
	inb (15) <= in2(15) XOR signCMP;
	ina (14 DOWNTO 0) <= in1 (14 DOWNTO 0);
	inb (14 DOWNTO 0) <= in2 (14 DOWNTO 0);
	
	PROCESS (ina, inb)
	BEGIN
		IF TO_INTEGER(UNSIGNED(inb)) = TO_INTEGER(UNSIGNED(ina)) THEN
			eq <= '1';		gt <= '0';
		ELSIF TO_INTEGER(UNSIGNED(inb)) > TO_INTEGER(UNSIGNED(ina)) THEN
			gt <= '1';		eq <= '0';
		ELSE
			gt <= '0';		eq <= '0';
		END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY ADD IS
	GENERIC ( 
		n : INTEGER := 16
	);
	PORT (
		in1, in2 : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		outADD   : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY ADD;

ARCHITECTURE behaviour OF ADD IS
BEGIN
	ADD1 : ENTITY WORK.CLA GENERIC MAP(16, 16)
			PORT MAP (in1, in2, '0', outADD);
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MUX2ofnbits IS
	GENERIC (
		n : INTEGER := 16	-- number of input bits
	);
	PORT (
		in1, in2   : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		sel1, sel2 : IN STD_LOGIC;
		outMUX     : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY MUX2ofnbits;

ARCHITECTURE behaviour OF MUX2ofnbits IS
BEGIN
	outMUX <= in1 WHEN sel1 = '1' ELSE
		  in2 WHEN sel2 = '1' ELSE 
		  (OTHERS => '0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MUX8of16bits IS
	PORT (
		in1, in2, in3, in4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		in5, in6, in7, in8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		sel1, sel2, sel3, sel4, sel5, sel6, sel7, sel8 : IN STD_LOGIC;
		outMUX             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY MUX8of16bits;

ARCHITECTURE behaviour OF MUX8of16bits IS
BEGIN
	outMUX <= in1 WHEN sel1 = '1' ELSE
		  in2 WHEN sel2 = '1' ELSE 
		  in3 WHEN sel3 = '1' ELSE 
		  in4 WHEN sel4 = '1' ELSE 
		  in5 WHEN sel5 = '1' ELSE 
		  in6 WHEN sel6 = '1' ELSE 
		  in7 WHEN sel7 = '1' ELSE 
		  in8 WHEN sel8 = '1' ELSE 
		  (OTHERS => '0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MUX3of16bits IS
	PORT (
		in1, in2, in3    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		sel1, sel2, sel3 : IN STD_LOGIC;
		outMUX           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY MUX3of16bits;

ARCHITECTURE behaviour OF MUX3of16bits IS
BEGIN
	outMUX <= in1 WHEN sel1 = '1' ELSE
		  in2 WHEN sel2 = '1' ELSE 
		  in3 WHEN sel3 = '1' ELSE 
		  (OTHERS => '0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY INC IS
	GENERIC (
		n : INTEGER := 16	-- number of input bits
	);
	PORT (
		inINC  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		outINC : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY INC;

ARCHITECTURE behaviour OF INC IS
	SIGNAL carry  : STD_LOGIC_VECTOR(n DOWNTO 1);
BEGIN
	-- Half Adder
	outINC(0) <= inINC(0) XOR '1';
	carry(1) <= inINC(0) AND '1';
	
	rest : FOR I IN 1 TO n-1 GENERATE
			outINC(I) <= inINC(I) XOR carry(I);
			carry(I+1) <= inINC(I) AND carry(I);
	END GENERATE;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY REG IS
	PORT (
		clk, rst, ld : IN STD_LOGIC;
		inREG        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		outREG       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY REG;

ARCHITECTURE behaviour OF REG IS
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			outREG <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ld = '1' THEN
				outREG <= inREG;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_IMM IS
END ENTITY test_IMM;
ARCHITECTURE test OF test_IMM IS
	SIGNAL in1, in2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits : STD_LOGIC;
	SIGNAL outIMM   : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	SE5bits <= '0', '1' AFTER 1 NS, '0' AFTER 2 NS;
	SE6bits <= '0', '1' AFTER 2 NS, '0' AFTER 3 NS;
	USE8bits <= '0', '1' AFTER 3 NS, '0' AFTER 4 NS;
	SE8bits <= '0', '1' AFTER 4 NS, '0' AFTER 5 NS;
	p1lowbits <= '0', '1' AFTER 5 NS, '0' AFTER 6 NS;
	in1 <= X"30", X"0A" AFTER 8 NS, X"E2" AFTER 12 NS;
	in2 <= X"F7", X"1C" AFTER 7 NS, X"6B" AFTER 10 NS;
	
	ImmediateUnit : ENTITY WORK.IMM PORT MAP 
				(in1, in2, SE5bits, SE6bits, USE8bits, 
				SE8bits, p1lowbits, outIMM);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_LLU IS
END ENTITY test_LLU;
ARCHITECTURE test OF test_LLU IS
	SIGNAL in1, in2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL logicAND, onesComp, twosComp : STD_LOGIC;
	SIGNAL outLLU   : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	logicAND <= '0', '1' AFTER 1 NS, '0' AFTER 2 NS;
	onesComp <= '0', '1' AFTER 3 NS, '0' AFTER 4 NS;
	twosComp <= '0', '1' AFTER 5 NS, '0' AFTER 6 NS;
	in1 <= X"2019", X"0A01" AFTER 2 NS, X"F204" AFTER 5 NS;
	in2 <= X"2042", X"0A35" AFTER 3 NS, X"F275" AFTER 4 NS;
	
	LogicLogicUnit : ENTITY WORK.LLU PORT MAP 
				(in1, in2, logicAND, onesComp, twosComp, outLLU);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_ASU IS
END ENTITY test_ASU;
ARCHITECTURE test OF test_ASU IS
	SIGNAL in1, in2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL arithADD, arithSUB : STD_LOGIC;
	SIGNAL outASU   : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	arithADD <= '1', '0' AFTER 2 NS;
	arithSUB <= '0', '1' AFTER 3 NS, '0' AFTER 6 NS;
	in1 <= X"2019", X"8A01" AFTER 1 NS, X"0A01" AFTER 2 NS, X"F204" AFTER 5 NS;
	in2 <= X"2042", X"0A35" AFTER 3 NS, X"F275" AFTER 4 NS;
	
	AddSubUnit : ENTITY WORK.ASU PORT MAP 
				(in1, in2, arithADD, arithSUB, outASU);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_SHU IS
END ENTITY test_SHU;
ARCHITECTURE test OF test_SHU IS
	SIGNAL in1    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL in2    : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL logicSH, arithSH : STD_LOGIC;
	SIGNAL outSHU : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	logicSH <= '1', '0' AFTER 1 NS, '1' AFTER 5 NS;
	arithSH <= '0', '1' AFTER 2 NS, '0' AFTER 4 NS;
	in1 <= X"2E18", X"8AB1" AFTER 4 NS, X"2AB1" AFTER 7 NS;
	in2 <= "00100", "10110" AFTER 3 NS, "10111" AFTER 6 NS;
	
	SHiftUnit : ENTITY WORK.SHU PORT MAP 
				(in1, in2, logicSH, arithSH, outSHU);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_MDU IS
END ENTITY test_MDU;
ARCHITECTURE test OF test_MDU IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, startMDU, arithMUL, arithDIV, ldMDU1, ldMDU2, signMDU, readyMDU : STD_LOGIC;
	SIGNAL in1, in2         : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMDU1, outMDU2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 140 NS ELSE '0';
	rst <= '1', '0' AFTER 1 NS;
	startMDU <= '0', '1' AFTER 1 NS, '0' AFTER 13 NS, '1' AFTER 14 NS;
	arithMUL <= '0', '1' AFTER 4 NS, '0' AFTER 88 NS;
	signMDU  <= '0', '1' AFTER 36 NS, '0' AFTER 110 NS;
	arithDIV <= '0', '1' AFTER 102 NS;
	ldMDU1 <= '1', '0' AFTER 27 NS, '1' AFTER 84 NS, '0' AFTER 88 NS, '1' AFTER 105 NS, '0' AFTER 108 NS;
	ldMDU2 <= '0', '1' AFTER 95 NS, '0' AFTER 97 NS, '1' AFTER 115 NS, '0' AFTER 117 NS, '1' AFTER 125 NS, '0' AFTER 128 NS;
	in1 <= "0000000000000001", "0000000000011001" AFTER 2 NS, "0000101000000001" AFTER 100 NS, "1111001000000100" AFTER 104 NS;
	in2 <= "0000000000000001", "0000000000000101" AFTER 3 NS, "1111111111111110" AFTER 106 NS;
	
	MultDivUnit : ENTITY WORK.MDU PORT MAP 
				(clk, rst, startMDU, arithMUL, arithDIV, signMDU, ldMDU1, 
				ldMDU2, in1, in2, outMDU1, outMDU2, readyMDU);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_CMP IS
END ENTITY test_CMP;
ARCHITECTURE test OF test_CMP IS
	SIGNAL in1, in2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL signCMP  : STD_LOGIC;
	SIGNAL eq, gt : STD_LOGIC;
BEGIN
	in1 <= X"0000", X"0019" AFTER 2 NS, X"FFF1" AFTER 5 NS, X"FEFE" AFTER 8 NS;
	in2 <= X"0000", X"0042" AFTER 3 NS, X"FFE2" AFTER 7 NS;
	signCMP <= '0', '1' AFTER 4 NS, '0' AFTER 6 NS, '1' AFTER 9 NS;
	
	ComparatorUnit : ENTITY WORK.CMP PORT MAP 
				(in1, in2, signCMP, eq, gt);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_INC IS
END ENTITY test_INC;
ARCHITECTURE test OF test_INC IS
	SIGNAL inINC  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outINC : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	inINC <= X"2E18", X"8AB1" AFTER 4 NS, X"2AB1" AFTER 7 NS;
	
	INCrementer : ENTITY WORK.INC PORT MAP 
				(inINC, outINC);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_COMP IS
END ENTITY test_COMP;
ARCHITECTURE test OF test_COMP IS
	SIGNAL inCOMP  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL onebartwo : STD_LOGIC;
	SIGNAL outCOMP : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	inCOMP <= X"2E18", X"8AB1" AFTER 4 NS, X"2AB1" AFTER 7 NS;
	onebartwo <= '0', '1' AFTER 3 NS, '0' AFTER 5 NS;
	
	COMPlementer : ENTITY WORK.COMP PORT MAP 
				(inCOMP, onebartwo, outCOMP);
END ARCHITECTURE test;
