--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Radix8_MUL IS 
	PORT ( clk, rst, start : IN STD_LOGIC ;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		done : OUT STD_LOGIC;
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
END Radix8_MUL;	 

ARCHITECTURE behavioral_Radix8_MUL OF Radix8_MUL IS 
	COMPONENT Controller8 IS 
		PORT ( clk, rst, start : IN STD_LOGIC;
			op : IN STD_LOGIC_VECTOR (3 DOWNTO 0);	
			ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS : OUT STD_LOGIC;
			sel_MUX : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			busy : OUT STD_LOGIC ); 
	END COMPONENT;

	COMPONENT Datapath8 IS 
		PORT ( clk, rst : IN STD_LOGIC;
			A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
			ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS : IN STD_LOGIC;
			sel_MUX : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			op : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );			
	END COMPONENT;
	
	SIGNAL ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, busy_reg : STD_LOGIC;
	SIGNAL sel_MUX : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL op : STD_LOGIC_VECTOR (3 DOWNTO 0); 
	SIGNAL mult_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0'); 
BEGIN
	DP : Datapath8
		PORT MAP (clk, rst, A, B, ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_MUX, op, mult_out);
	
	CU : Controller8
		PORT MAP (clk, rst, start, op, ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_MUX, busy_reg);
		
	result <= mult_out WHEN busy_reg = '0';
	done <= NOT busy_reg;
END behavioral_Radix8_MUL;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Controller8 IS 
	PORT ( clk, rst, start : IN STD_LOGIC;
		op : IN STD_LOGIC_VECTOR (3 DOWNTO 0);	
		ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS : OUT STD_LOGIC;
		sel_MUX : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		busy : OUT STD_LOGIC );
END Controller8;

ARCHITECTURE behavioral_CU OF Controller8 IS 	
	TYPE state IS (IDLE, COUNT, ADD);
	SIGNAL p_state, n_state : state;
	SIGNAL zero_cntr, en_cntr, co : STD_LOGIC;
	SIGNAL cntr, cntinc : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN	
	PROCESS (p_state, start, co, op)
	BEGIN
		n_state <= IDLE;
		busy <= '1';	ld_A <= '0'; sh_A <= '0'; ld_B <= '0'; ld_P <= '0'; zero_P <= '0'; 
		sel_AS <= '0'; sel_MUX <= "000";	en_cntr <= '0'; zero_cntr <= '0';

		CASE ( p_state ) IS
			WHEN IDLE =>
				zero_cntr <= '1';	
				zero_P <= '1';	
				ld_A <= '1';
				ld_B <= '1';
				
				IF start <= '1' THEN
					n_state <= COUNT;
				ELSE
					n_state <= IDLE;
				END IF;
			WHEN COUNT =>
				IF op = "0000" OR op = "1111" THEN		-- Nothing
					sel_MUX <= "000";	
				END IF;
				IF op = "0001" OR op = "0010" THEN		-- P+B
					sel_MUX <= "001";
					sel_AS <= '0';
				END IF;
				IF op = "0011" OR op = "0100" THEN		-- P+2B
					sel_MUX <= "010";	
					sel_AS <= '0';
				END IF;
				IF op = "0101" OR op = "0110" THEN		-- P+3B
					sel_MUX <= "011";	
					sel_AS <= '0';
				END IF;
				IF op = "0111" THEN						-- P+4B
					sel_MUX <= "100";	
					sel_AS <= '0';
				END IF;
				IF op = "1000" THEN						-- P-4B
					sel_MUX <= "100";	
					sel_AS <= '1';
				END IF;
				IF op = "1001" OR op = "1010" THEN		-- P-3B
					sel_MUX <= "011";	
					sel_AS <= '1';
				END IF;
				IF op = "1011" OR op = "1100" THEN		-- P-2B
					sel_MUX <= "010";	
					sel_AS <= '1';
				END IF;
				IF op = "1101" OR op = "1110" THEN		-- P-B
					sel_MUX <= "001";	
					sel_AS <= '1';
				END IF;
				
				en_cntr <= '1';
				ld_P <= '1';
				sh_A <= '1';
				
				IF co = '1' THEN
					n_state <= ADD;
				ELSE
					n_state <= COUNT;
				END IF;			
			WHEN ADD =>
				sel_MUX <= "101";
				busy <= '0';

				n_state <= IDLE;			
		END CASE;
	END PROCESS;
			
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			p_state <= IDLE;
		ELSIF clk = '1' AND clk'EVENT THEN
			p_state <= n_state;
		END IF;
	END PROCESS;
	
--Counter: counting the number of iterations
	INCrementer : ENTITY WORK.INC GENERIC MAP (3) PORT MAP (cntr, cntinc);
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
				cntr <= "000";
		ELSIF clk = '1' AND clk'EVENT THEN
			IF zero_cntr = '1' THEN
				cntr <= "011";
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

ENTITY Datapath8 IS 
	PORT ( clk, rst : IN STD_LOGIC;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS : IN STD_LOGIC;
		sel_MUX : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		op : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );			
END Datapath8;

ARCHITECTURE behavioral_DP OF Datapath8 IS 	
	SIGNAL A_reg : STD_LOGIC_VECTOR (17 DOWNTO 0) := (OTHERS => '0');
	SIGNAL B_reg, P_reg, AS_out, in2_AS : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL B2, B3, B4 : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL in2_AS_sel : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL A_reg_32 : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
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
				A_reg <= AS_out(2 DOWNTO 0) & A_reg(17 DOWNTO 3);	
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
				P_reg <= AS_out(15) & AS_out(15) & AS_out(15) & AS_out(16 DOWNTO 3);	
			END IF;
		END IF;
	END PROCESS;	
	B2 <= B_reg(15 DOWNTO 0) & '0';
	B4 <= B_reg(14 DOWNTO 0) & "00";
	ADD_B3 : ENTITY WORK.CLA17
		PORT MAP(B_reg, B2, '0', B3);
		
--MUX for in1_mul	
	PROCESS (sel_MUX, B_reg, B2, B3, B4)
	BEGIN
		IF sel_MUX = "000" THEN
			in2_AS <= (OTHERS => '0');
		ELSIF sel_MUX = "001" THEN
			in2_AS <= B_reg;
		ELSIF sel_MUX = "010" THEN
			in2_AS <= B2;
		ELSIF sel_MUX = "011" THEN
			in2_AS <= B3;
		ELSIF sel_MUX = "100" THEN
			in2_AS <= B4;
--		ELSIF sel_MUX = "101" THEN
--			in2_AS <= (OTHERS => '0');
		--	in2_AS <= in2_AS;	
		END IF;
	END PROCESS;
	
--AddSub	
	in2_AS_sel <= in2_AS WHEN sel_AS = '0' ELSE (NOT in2_AS);
	ADD1 : ENTITY WORK.CLA17
		PORT MAP(P_reg, in2_AS_sel, sel_AS, AS_out);
	
	op <= A_reg(3 DOWNTO 0);
	result <= AS_out(15 DOWNTO 0) & A_reg_32(16 DOWNTO 1);		
END behavioral_DP;		 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Radix8_MUL_TB IS 
END Radix8_MUL_TB;

ARCHITECTURE behavioral_TB OF Radix8_MUL_TB IS
	COMPONENT Radix8_MUL IS 
		PORT ( clk, rst, start : IN STD_LOGIC;
			A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
			done : OUT STD_LOGIC;
			result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;

	SIGNAL clk : STD_LOGIC := '1';
	SIGNAL rst, done, start : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL result_Radix8_MUL : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN
	MUT : Radix8_MUL
		PORT MAP (clk, rst, start, A, B, done, result_Radix8_MUL);
	
	clk <= NOT clk AFTER 2.5 NS WHEN NOW <= 250 NS ELSE '0';
	
	PROCESS
	BEGIN
		rst <= '1', '0' AFTER 6 NS;
		start <= '0';
		
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