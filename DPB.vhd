--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			20 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
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
		outIMM  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY IMM;

ARCHITECTURE behaviour OF IMM IS
BEGIN
	outIMM <= (15 DOWNTO 5 => in1(4)) & in1(4 DOWNTO 0) WHEN SE5bits = '1' ELSE
			  (15 DOWNTO 6 => in1(5)) & in1(5 DOWNTO 0) WHEN SE6bits = '1' ELSE
			  (15 DOWNTO 8 => '0') & in1 WHEN USE8bits = '1' ELSE
			  (15 DOWNTO 8 => in1(7)) & in1 WHEN SE8bits = '1' ELSE
			  in1 & in2 WHEN p1lowbits = '1' ELSE
			  (OTHERS => 'Z');
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
BEGIN
	outLLU <= (in1 AND in2) WHEN logicAND = '1' ELSE
			  (NOT in1) WHEN onesComp = '1' ELSE
			  STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(SIGNED(NOT in1)) + 1, 16))
			  WHEN twosComp = '1' ELSE 
			  (OTHERS => 'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY ASU IS
	PORT (
		in1, in2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		arithADD, arithSUB : IN STD_LOGIC;
		outASU  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY ASU;

ARCHITECTURE behaviour OF ASU IS
BEGIN
	outASU <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(in1)) + 
			  TO_INTEGER(UNSIGNED(in2)), 16)) WHEN arithADD = '1' ELSE
			  STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(SIGNED(in1)) - 
			  TO_INTEGER(SIGNED(in2)), 16)) WHEN arithSUB = '1' ELSE
			  (OTHERS => 'Z');
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
	IMPURE FUNCTION numberofshiftbits (value2 : STD_LOGIC_VECTOR(4 DOWNTO 0))
	RETURN INTEGER IS
		VARIABLE nums : INTEGER;
	BEGIN	
		IF value2(4) = '0' THEN 
			nums := TO_INTEGER(UNSIGNED(value2));
		ELSE
			nums := TO_INTEGER(SIGNED(NOT value2)) + 1;
		END IF;
		
		RETURN nums;
	END FUNCTION; 
	
	SIGNAL numofSH : INTEGER; 
	SIGNAL cases : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN	
	numofSH <= numberofshiftbits(in2);
	cases <= (in2(4) & logicSH & arithSH);
	
	PROCESS (in2, logicSH, arithSH, numofSH, cases, in1)
	BEGIN		
		CASE cases IS
			WHEN "001" =>						-- arithmetic right shift
				outSHU((15 - numofSH) DOWNTO 0) <= in1(15 DOWNTO numofSH);
				outSHU(15 DOWNTO (15 - numofSH - 1)) <= (OTHERS => in1(15));
			WHEN "010" =>						-- logical right shift
				outSHU((15 - numofSH) DOWNTO 0) <= in1(15 DOWNTO numofSH);
				outSHU(15 DOWNTO (15 - numofSH - 1)) <= (OTHERS => '0');
			WHEN "101" =>						-- arithmetic left shift
				outSHU(15 DOWNTO numofSH) <= in1((15 - numofSH) DOWNTO 0);
				outSHU((numofSH - 1) DOWNTO 0) <= (OTHERS => in1(0));
			WHEN "110" =>						-- logic left shift
				outSHU(15 DOWNTO numofSH) <= in1((15 - numofSH) DOWNTO 0);
				outSHU((numofSH - 1) DOWNTO 0) <= (OTHERS => '0');
			WHEN OTHERS =>
				outSHU <= (OTHERS => 'Z');
		END CASE;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MDU IS
	PORT (
		clk, rst, startMDU, arithMUL, arithDIV, ldMDU1, ldMDU2 : IN STD_LOGIC;
		in1, in2          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		outMDU1, outMDU2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)		
	);
END ENTITY MDU;

ARCHITECTURE behaviour OF MDU IS
	SIGNAL outMDU_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	outMDU_reg <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(SIGNED(in1)) *
				  TO_INTEGER(SIGNED(in2)), 32)) WHEN startMDU = '1' AND arithMUL = '1' ELSE
				  STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(SIGNED(in1)) /
				  TO_INTEGER(SIGNED(in2)), 32)) WHEN startMDU = '1' AND arithDIV = '1' ELSE
			      (OTHERS => 'Z');
	
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
		lt, eq, gt : OUT STD_LOGIC	
	);
END ENTITY CMP;

ARCHITECTURE behaviour OF CMP IS
BEGIN
	lt <= '1' WHEN TO_INTEGER(SIGNED(in2)) < TO_INTEGER(SIGNED(in1)) ELSE '0';
	eq <= '1' WHEN TO_INTEGER(SIGNED(in2)) = TO_INTEGER(SIGNED(in1)) ELSE '0';
	gt <= '1' WHEN TO_INTEGER(SIGNED(in2)) > TO_INTEGER(SIGNED(in1)) ELSE '0';	
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
		outADD  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY ADD;

ARCHITECTURE behaviour OF ADD IS
BEGIN
	outADD <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(in1)) +
			  TO_INTEGER(UNSIGNED(in2)), 16));
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MUX IS
	GENERIC (
		n : INTEGER := 16;	-- number of bits in the input
		m : INTEGER := 2	-- number of inputs
	);
	PORT (
		inMUX   : IN STD_LOGIC_VECTOR(m*n-1 DOWNTO 0);
		sel     : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
		outMUX : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY MUX;

ARCHITECTURE behaviour OF MUX IS
BEGIN
	PROCESS (inMUX, sel)
	BEGIN
		FOR I IN 0 TO m-1 LOOP
			IF sel(I) = '1' THEN
				outMUX <= inMUX((I+1)*n-1 DOWNTO I*n);
			END IF;
		END LOOP;
	END PROCESS;
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
		in1, in2 : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		sel1, sel2 : IN STD_LOGIC;
		outMUX  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY MUX2ofnbits;

ARCHITECTURE behaviour OF MUX2ofnbits IS
BEGIN
	outMUX <= in1 WHEN sel1 = '1' ELSE
			  in2 WHEN sel2 = '1' ELSE 
			  (OTHERS => 'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MUX8of16bits IS
	PORT (
--		in1, in2, in3, in4, in5, in6, in7, in8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		in1, in2, in3, in4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		in5, in6, in7, in8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		sel1, sel2, sel3, sel4, sel5, sel6, sel7, sel8 : IN STD_LOGIC;
		outMUX            : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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
			  (OTHERS => 'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MUX3of16bits IS
	PORT (
		in1, in2, in3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		sel1, sel2, sel3 : IN STD_LOGIC;
		outMUX       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY MUX3of16bits;

ARCHITECTURE behaviour OF MUX3of16bits IS
BEGIN
	outMUX <= in1 WHEN sel1 = '1' ELSE
			  in2 WHEN sel2 = '1' ELSE 
			  in3 WHEN sel3 = '1' ELSE 
			  (OTHERS => 'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY REG IS
	PORT (
		clk, rst, ld : IN STD_LOGIC;
		inREG   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		outREG : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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
	arithSUB <= '0', '1' AFTER 3 NS, '0' AFTER 5 NS;
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
	SIGNAL rst, startMDU, arithMUL, arithDIV, ldMDU1, ldMDU2 : STD_LOGIC;
	SIGNAL in1, in2         : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMDU1, outMDU2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 380 NS ELSE '0';
	rst <= '1', '0' AFTER 1 NS;
	startMDU <= '0', '1' AFTER 1 NS, '0' AFTER 13 NS, '1' AFTER 14 NS;
	arithMUL <= '1', '0' AFTER 6 NS, '1' AFTER 17 NS;
	arithDIV <= '0', '1' AFTER 8 NS, '0' AFTER 16 NS;
	ldMDU1 <= '1', '0' AFTER 27 NS;
	ldMDU2 <= '0', '1' AFTER 14 NS;
	in1 <= X"0000", X"0019" AFTER 2 NS, X"0A01" AFTER 15 NS, X"F204" AFTER 19 NS;
	in2 <= X"0000", X"0042" AFTER 3 NS, X"FFFE" AFTER 18 NS;
	
	MultDivUnit : ENTITY WORK.MDU PORT MAP 
					(clk, rst, startMDU, arithMUL, arithDIV, ldMDU1, 
					ldMDU2, in1, in2, outMDU1, outMDU2);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_CMP IS
END ENTITY test_CMP;
ARCHITECTURE test OF test_CMP IS
	SIGNAL in1, in2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL lt, eq, gt : STD_LOGIC;
BEGIN
	in1 <= X"0000", X"0019" AFTER 2 NS, X"FFF1" AFTER 5 NS, X"FEFE" AFTER 8 NS;
	in2 <= X"0000", X"0042" AFTER 3 NS, X"FFE2" AFTER 6 NS;
	
	ComparatorUnit : ENTITY WORK.CMP PORT MAP 
						(in1, in2, lt, eq, gt);
END ARCHITECTURE test;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_MUX IS
END ENTITY test_MUX;
ARCHITECTURE test OF test_MUX IS
	SIGNAL inMUX  : STD_LOGIC_VECTOR(4*16-1 DOWNTO 0);
	SIGNAL sel    : STD_LOGIC_VECTOR(4-1 DOWNTO 0);
	SIGNAL outMUX : STD_LOGIC_VECTOR(16-1 DOWNTO 0);
BEGIN
	sel <= "0001", "0010" AFTER 2 NS, "0100" AFTER 5 NS, "1000" AFTER 6 NS;
	inMUX <= X"2046100193423542", X"15B6F9A403217A52" AFTER 4 NS;
	
	Multiplexer : ENTITY WORK.MUX GENERIC MAP ( 16, 4 )	
					PORT MAP (inMUX, sel, outMUX);
END ARCHITECTURE test;