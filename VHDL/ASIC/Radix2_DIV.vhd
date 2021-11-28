--******************************************************************************
--  Filename:		Radix2_DIV.vhd
--  Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--  History:
--  Date:		20 November 2021
--  Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Radix2 divider unit of the SAYAC core                                 
--******************************************************************************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
  
ENTITY SHR IS
	PORT (
		clk, rst, serIN, enSHR, initSHR, ldSHR : IN STD_LOGIC;
		inSHR : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		outSHR   : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
		serOUT : OUT STD_LOGIC
	);
END ENTITY SHR;

ARCHITECTURE behaviour OF SHR IS
	SIGNAL outSHR_reg : STD_LOGIC_VECTOR (16 DOWNTO 0);
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			outSHR_reg <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF initSHR = '1' THEN
				outSHR_reg <= (OTHERS => '0');
			ELSIF ldSHR = '1' THEN
				outSHR_reg <= inSHR;
			ELSIF enSHR = '1' THEN
				outSHR_reg <= (outSHR_reg(15 DOWNTO 0) & serIN);
			END IF;
		END IF;
	END PROCESS;
	
	outSHR <= outSHR_reg;
	serOUT <= outSHR_reg(16);
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
  
ENTITY Datapath_Radix2_DIV IS
	PORT (
		clk, rst : IN STD_LOGIC;
		load_R, shift_R, shift_Q, load_Q, load_M : IN STD_LOGIC;
		setQ0, setR, Q0, clr_R : IN STD_LOGIC;
		Divisor, Devident : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		outDIV : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		sign : OUT STD_LOGIC
	);
END ENTITY Datapath_Radix2_DIV;

ARCHITECTURE behaviour OF Datapath_Radix2_DIV IS
	SIGNAL mux1Out, Rprev, mux2Out, Qprev, M, subResult, notM : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL serOutQ, serOutR : STD_LOGIC;
BEGIN	
	shReg_R: ENTITY WORK.SHR PORT MAP
			(clk, rst, serOutQ, shift_R, clr_R, load_R, mux1Out, Rprev, serOutR);
	shReg_Q: ENTITY WORK.SHR PORT MAP
			(clk, rst, '0', shift_Q, '0', load_Q, mux2Out, Qprev, serOutQ);
	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			M <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF load_M = '1' THEN
				M <= Divisor;
			END IF;
		END IF;
	END PROCESS;
	
	notM <= NOT M;
	mux1Out <= Rprev WHEN setR = '0' ELSE subResult;
	mux2Out <= Devident WHEN setQ0 = '0' ELSE (Qprev(16 DOWNTO 1) & Q0);
	
	subtract : ENTITY WORK.CLA17
			PORT MAP (Rprev, notM, '1', subResult);
  
	sign <= subResult(16);
	outDIV <= (Rprev(15 DOWNTO 0) & Qprev(15 DOWNTO 0));
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Controller_Radix2_DIV IS
	PORT (
		clk, rst, start, sign: IN STD_LOGIC;
		load_R, shift_R, shift_Q, load_Q : OUT STD_LOGIC;
		load_M, setQ0, setR, Q0, clr_R, readyDIV : OUT STD_LOGIC
	);
END ENTITY Controller_Radix2_DIV;

ARCHITECTURE behaviour OF Controller_Radix2_DIV IS
	TYPE state IS (LOAD, SHIFT, SUB);
	SIGNAL ps, ns : state;
	SIGNAL co, incCnt, iniCnt : STD_LOGIC;
	SIGNAL cnt, cntinc : STD_LOGIC_VECTOR (4 DOWNTO 0);
BEGIN  
	INCrementer : ENTITY WORK.INC  GENERIC MAP (5) PORT MAP (cnt, cntinc);
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			cnt <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF iniCnt = '1' THEN
				cnt <= "01110";
			ELSIF incCnt = '1' THEN
				cnt <= cntinc;
			END IF;
		END IF;
	END PROCESS;
	
	co <= '1' WHEN cnt = "11111" ELSE '0';

	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			ps <= LOAD;
		ELSIF clk = '1' AND clk'EVENT THEN
			ps <= ns;
		END IF;
	END PROCESS;
  
	PROCESS (ps, start, co)
	BEGIN
		CASE (ps) IS
			WHEN LOAD => 
				IF start = '1' THEN
					ns <= SHIFT;
				ELSE
					ns <= LOAD;
				END IF;
			WHEN SHIFT => 
				ns <= SUB;
			WHEN SUB => 
				IF co = '1' THEN
					ns <= LOAD;
				ELSE
					ns <= SHIFT;
				END IF;
		END CASE;
	END PROCESS;
  
	PROCESS (ps, sign, co)
	BEGIN
		load_R <= '0';	shift_R <= '0';	shift_Q <= '0';	load_Q <= '0';
		load_M <= '0';	setQ0 <= '0';	setR <= '0';	Q0 <= '0';
		clr_R <= '0';	readyDIV <= '0';	incCnt <= '0';	iniCnt <= '0';
		
		CASE (ps) IS
			WHEN LOAD => 
				load_Q <= '1';	load_M <= '1';	iniCnt <= '1';	clr_R <= '1';
			WHEN SHIFT => 
				shift_R <= '1';	shift_Q <= '1';
				IF co = '1' THEN
					readyDIV <= '1';
				END IF;
			WHEN SUB => 
				setQ0 <= '1';	load_R <= '1';	load_Q <= '1';	incCnt <= '1';
				IF sign = '0' THEN
					setR <= '1';	Q0 <= '1';
				ELSE
					setR <= '0';	Q0 <= '0';
				END IF;
		END CASE;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Radix2_DIV IS 
	PORT ( clk, rst, start : IN STD_LOGIC;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		readyDIV : OUT STD_LOGIC;
		outDIV: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
END Radix2_DIV;	 

ARCHITECTURE behavioral_Radix2_DIV OF Radix2_DIV IS
	SIGNAL sign, load_R, shift_R, ready_reg : STD_LOGIC;
	SIGNAL shift_Q, load_Q, load_M, setQ0, setR, Q0, clr_R : STD_LOGIC;
	SIGNAL result : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN
	DP : ENTITY WORK.Datapath_Radix2_DIV PORT MAP
			(clk, rst, load_R, shift_R, shift_Q, load_Q, load_M, setQ0, setR, Q0, clr_R, B, A, result, sign);
	
	CU : ENTITY WORK.Controller_Radix2_DIV PORT MAP
			(clk, rst, start, sign, load_R, shift_R, shift_Q, load_Q, load_M, setQ0, setR, Q0, clr_R, ready_reg);
			
	outDIV <= result WHEN ready_reg = '1';
	readyDIV <= ready_reg;
END behavioral_Radix2_DIV; 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Radix2_DIV_TB IS 
END Radix2_DIV_TB;

ARCHITECTURE behavioral_TB OF Radix2_DIV_TB IS
	SIGNAL clk : STD_LOGIC := '1';
	SIGNAL rst, done, start : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL result_DIV : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN
	DIVU : ENTITY WORK.Radix2_DIV 
		PORT MAP (clk, rst, start, A, B, done, result_DIV);
	
	clk <= NOT clk AFTER 2.5 NS WHEN NOW <= 2000 NS ELSE '0';
	
	PROCESS
	BEGIN
		rst <= '1', '0' AFTER 3 NS;
		start <= '0';
		WAIT FOR 4 NS;
		
		A <= "00000000101100000"; 		-- A = 352
		B <= "00000000000000010";		-- B = 2
		start <= '1';
		WAIT FOR 4 NS;
		start <= '0';
		WAIT UNTIL rising_edge(done);
		
		A <= "00000000000001010"; 		-- A = 10
		B <= "11111111111111011";		-- B = -5
		start <= '1';
		WAIT FOR 12 NS;
		start <= '0';
		WAIT UNTIL rising_edge(done);
	
		A <= "00000101001010000"; 		-- A = 2640
		B <= "00000000010000100";		-- B = 132
		start <= '1';
		WAIT FOR 12 NS;
		start <= '0';
		WAIT UNTIL rising_edge(done);
		
		start <= '1';
		B <= "11111111111101010"; 		-- A = -22
		A <= "00000000010000011";		-- B = 131
		WAIT UNTIL rising_edge(done);
		
		A <= "11111111111100010"; 		-- A = -30
		B <= "11111111111110101";		-- B = -11
		WAIT UNTIL rising_edge(done);
		start <= '0';
		
		WAIT FOR 15 NS;
		WAIT;
	END PROCESS;
END behavioral_TB; 
