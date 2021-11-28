--******************************************************************************
--  Filename:		Radix4_MUL.vhd
--  Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--  History:
--  Date:		28 November 2021
--  Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Radix4 multiplier unit of the SAYAC core                                 
--******************************************************************************
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Radix4_MUL IS
	PORT ( clk, rst, start, cout : IN STD_LOGIC ;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		done : OUT STD_LOGIC;
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
END Radix4_MUL;	 

ARCHITECTURE behavioral_Radix4_MUL OF Radix4_MUL IS
	
	SIGNAL ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry, busy_reg : STD_LOGIC;
	SIGNAL sel_MUX : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL op : STD_LOGIC_VECTOR (2 DOWNTO 0); 
	SIGNAL mult_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0'); 
BEGIN
	DP : ENTITY WORK.Datapath4
		PORT MAP (clk, rst, cout, A, B, ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry, sel_MUX, op, mult_out);
	
	CU : ENTITY WORK.Controller4
		PORT MAP (clk, rst, start, op, ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry, sel_MUX, busy_reg);
		
	result <= mult_out WHEN busy_reg = '0';
	done <= NOT busy_reg;
END behavioral_Radix4_MUL;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Controller4 IS 
	PORT ( clk, rst, start : IN STD_LOGIC;
		op : IN STD_LOGIC_VECTOR (2 DOWNTO 0);	
		ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry : OUT STD_LOGIC;
		sel_MUX : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		busy : OUT STD_LOGIC );
END Controller4;

ARCHITECTURE behavioral_CU OF Controller4 IS 	
	TYPE state IS (IDLE, COUNT, ADD);
	SIGNAL p_state, n_state : state;
	SIGNAL zero_cntr, en_cntr, co : STD_LOGIC;
	SIGNAL cntr, cntinc : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			p_state <= IDLE;
		ELSIF clk = '1' AND clk'EVENT THEN
			p_state <= n_state;
		END IF;
	END PROCESS;
	
	PROCESS (p_state, start, co)
	BEGIN	
		n_state <= IDLE;
		CASE ( p_state ) IS
			WHEN IDLE =>
				IF start <= '0' THEN
					n_state <= IDLE;
				ELSE
					n_state <= COUNT;
				END IF;
			WHEN COUNT =>
				IF co = '1' THEN
					n_state <= ADD;
				ELSE
					n_state <= COUNT;
				END IF;			
			WHEN ADD =>
				n_state <= IDLE;
		END CASE;
	END PROCESS;
	
	PROCESS (p_state, op)
	BEGIN
		busy <= '1';
		ld_A <= '0'; sh_A <= '0'; ld_B <= '0'; ld_P <= '0'; zero_P <= '0'; 
		sel_AS <= '0'; sel_carry <= '0'; sel_MUX <= "00";
		en_cntr <= '0'; zero_cntr <= '0';
		
		CASE ( p_state ) IS
			WHEN IDLE =>
				zero_cntr <= '1';	
				zero_P <= '1';	
				ld_A <= '1';
				ld_B <= '1';
			WHEN COUNT =>
				busy <= '1';
				IF op = "000" OR op = "111" THEN		-- Nothing
					sel_MUX <= "00";	
				END IF;
				IF op = "001" OR op = "010" THEN		-- P+B
					sel_MUX <= "01";
					sel_AS <= '0';
				END IF;
				IF op = "011" THEN				-- P+2B
					sel_MUX <= "10";	
					sel_AS <= '0';
				END IF;
				IF op = "100" THEN				-- P-2B
					sel_MUX <= "10";	
					sel_AS <= '1';
				END IF;
				IF op = "101" OR op = "110" THEN		-- P-B
					sel_MUX <= "01";	
					sel_AS <= '1';
				END IF;
				
				en_cntr <= '1';
				ld_P <= '1';
				sh_A <= '1';
			WHEN ADD =>
				sel_MUX <= "11";
				sel_carry <= '1';
				busy <= '0';
		END CASE;
	END PROCESS;
	
--Counter: counting the number of iterations
	INCrementer : ENTITY WORK.INC GENERIC MAP (3) PORT MAP (cntr, cntinc);
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
				cntr <= "000";
		ELSIF clk = '1' AND clk'EVENT THEN
			IF zero_cntr = '1' THEN
				cntr <= "000";
			ELSIF en_cntr = '1' THEN
				cntr <= cntinc;
			END IF;
		END IF;
	END PROCESS;
	
	co <= '1' WHEN cntr = "111" ELSE '0';
END behavioral_CU;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Datapath4 IS 
	PORT ( clk, rst, cout : IN STD_LOGIC;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry : IN STD_LOGIC;
		sel_MUX : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		op : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );			
END Datapath4;

ARCHITECTURE behavioral_DP OF Datapath4 IS 	
	SIGNAL A_reg : STD_LOGIC_VECTOR (17 DOWNTO 0) := (OTHERS => '0');
	SIGNAL B_reg, P_reg, B2 : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL AS_out, in2_AS, in2_AS_bar, incin2 : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL in2_AS_sel : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL A_reg_32 : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL cin, cin1 : STD_LOGIC;
BEGIN	
--A register:
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			A_reg <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ld_A = '1' THEN
				A_reg <= A & '0';
			ELSIF sh_A = '1' THEN
				A_reg <= AS_out(1 DOWNTO 0) & A_reg(17 DOWNTO 2);	
			END IF;
		END IF;
	END PROCESS;
	A_reg_32 <= ("000000000000000" & A_reg(17 DOWNTO 1));
	
--B register: 
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
				B_reg <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ld_B = '1' THEN
				B_reg <= B;
			END IF;
		END IF;
	END PROCESS;

--P register:
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
				P_reg <= (OTHERS=>'0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF zero_P = '1' THEN
				P_reg <= (OTHERS=>'0');
			ELSIF ld_P = '1' THEN
				P_reg <= AS_out(16) & AS_out(16) & AS_out(16 DOWNTO 2);	
			END IF;
		END IF;
	END PROCESS;	
	B2 <= B_reg(15 DOWNTO 0) & '0';
		
--MUX for in1_mul	
	PROCESS (sel_MUX, B_reg, B2, in2_AS)
	BEGIN
		IF sel_MUX = "00" THEN
			in2_AS <= (OTHERS=>'0');
		ELSIF sel_MUX = "01" THEN
			in2_AS <= B_reg;
		ELSIF sel_MUX = "10" THEN
			in2_AS <= B2;
		ELSIF sel_MUX = "11" THEN
			in2_AS <= (OTHERS => '0');
		END IF;
	END PROCESS;
	
--AddSub
	in2_AS_bar <= NOT in2_AS;
	INCrementer : ENTITY WORK.INC GENERIC MAP (17) PORT MAP (in2_AS_bar, incin2);
	in2_AS_sel <= in2_AS WHEN sel_AS = '0' ELSE incin2;
	cin1 <= cin WHEN sel_AS = '0' ELSE '0';
	ADD1 : ENTITY WORK.CLA17
		PORT MAP(P_reg, in2_AS_sel, cin1, AS_out);
	
-- Tri_state for carry
	cin <= cout WHEN sel_carry = '1' ELSE '0';
	
	op <= A_reg(2 DOWNTO 0);
	result <= AS_out(15 DOWNTO 0) & A_reg_32(16 DOWNTO 1);	
END behavioral_DP;		 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Radix4_MUL_TB IS 
END Radix4_MUL_TB;

ARCHITECTURE behavioral_TB OF Radix4_MUL_TB IS
	SIGNAL clk : STD_LOGIC := '1';
	SIGNAL rst, done, start, cout : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL result_Radix4_MUL : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN
	MUT : ENTITY WORK.Radix4_MUL
		PORT MAP (clk, rst, start, cout, A, B, done, result_Radix4_MUL);
	
	clk <= NOT clk AFTER 2.5 NS WHEN NOW <= 300 NS ELSE '0';
	
	PROCESS
	BEGIN
		rst <= '1', '0' AFTER 6 NS;
		start <= '0';
		cout <= '0';
		
		A <= "00000000000000000"; 		-- A = 0
		B <= "00000000000000000";		-- B = 0
		start <= '1';
		WAIT UNTIL rising_edge(done);
		
		A <= "00000000101100000"; 		-- A = 352
		B <= "00000000100000001";		-- B = 257
		WAIT UNTIL rising_edge(done);
		
		A <= "00000000000001010"; 		-- A = 10
		B <= "11111111111111011";		-- B = -5
		WAIT UNTIL rising_edge(done);
	
		A <= "00000101001010000"; 		-- A = 2640
		B <= "00000000010000000";		-- B = 128
		WAIT UNTIL rising_edge(done);
		
		A <= "11111111111110111"; 		-- A = -9
		B <= "00000000000010001";		-- B = 17
		WAIT UNTIL rising_edge(done);
		
		A <= "11111111111110011"; 		-- A = -13
		B <= "11111111111110110";		-- B = -10
		WAIT UNTIL rising_edge(done);
		start <= '0';
		
		WAIT FOR 15 NS;
		WAIT;
	END PROCESS;
END behavioral_TB; 
