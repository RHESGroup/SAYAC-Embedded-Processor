--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Controller2 IS 
	PORT ( clk, rst, start : IN STD_LOGIC;
		op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);	
		ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry : OUT STD_LOGIC;
		busy : OUT STD_LOGIC );
END Controller2;

ARCHITECTURE behavioral_CU OF Controller2 IS 	
	TYPE state IS (IDLE, COUNT, ADD);
	SIGNAL p_state, n_state : state;
	SIGNAL zero_cntr, en_cntr, co : STD_LOGIC;
	SIGNAL cntr, cntinc : STD_LOGIC_VECTOR (4 DOWNTO 0);
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
		sel_AS <= '0'; sel_carry <= '0';
		en_cntr <= '0'; zero_cntr <= '0';
		
		CASE ( p_state ) IS
			WHEN IDLE =>
				zero_cntr <= '1';	
				zero_P <= '1';	
				ld_A <= '1';
				ld_B <= '1';
			WHEN COUNT =>
				busy <= '1';
				IF op = "01" THEN			-- P+B
					sel_AS <= '0';
				ELSIF op = "10" THEN		-- P-B	
					sel_AS <= '1';
				END IF;
				
				en_cntr <= '1';
				ld_P <= '1';
				sh_A <= '1';
			WHEN ADD =>
				sel_carry <= '1';
				busy <= '0';
		END CASE;
	END PROCESS;
	
--Counter: counting the number of iterations
	INCrementer : ENTITY WORK.INC GENERIC MAP (5) PORT MAP (cntr, cntinc);
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
				cntr <= "00000";
		ELSIF clk = '1' AND clk'EVENT THEN
			IF zero_cntr = '1' THEN
				cntr <= "01110";
			ELSIF en_cntr = '1' THEN
				cntr <= cntinc;
			END IF;
		END IF;
	END PROCESS;
	
	co <= '1' WHEN cntr = "11111" ELSE '0';
END behavioral_CU;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Datapath2 IS 
	PORT ( clk, rst, cout : IN STD_LOGIC;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry : IN STD_LOGIC;
		op : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );			
END Datapath2;

ARCHITECTURE behavioral_DP OF Datapath2 IS 	
	SIGNAL A_reg : STD_LOGIC_VECTOR (17 DOWNTO 0) := (OTHERS => '0');
	SIGNAL B_reg, P_reg : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL AS_out, in2_AS : STD_LOGIC_VECTOR (16 DOWNTO 0) := (OTHERS => '0');
	SIGNAL incin2 : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
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
		
	in2_AS <= B_reg;
	
--AddSub
	COMPAS : ENTITY WORK.COMP PORT MAP 
					(in2_AS(15 DOWNTO 0), '1', incin2);
	in2_AS_sel <= in2_AS WHEN sel_AS = '0' ELSE (incin2(15) & incin2);
	cin1 <= cin WHEN sel_AS = '0' ELSE '0';
	ADD1 : ENTITY WORK.CLA17
		PORT MAP(P_reg, in2_AS_sel, cin1, AS_out);
	
-- Tri_state for carry
	cin <= cout WHEN sel_carry = '1' ELSE '0';
	
	op <= A_reg(1 DOWNTO 0);
	result <= AS_out(15 DOWNTO 0) & A_reg_32(16 DOWNTO 1);	
END behavioral_DP;		 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Radix2_MUL IS
	PORT ( clk, rst, start, cout : IN STD_LOGIC ;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		done : OUT STD_LOGIC;
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
END Radix2_MUL;	 

ARCHITECTURE behavioral_Radix2_MUL OF Radix2_MUL IS
	SIGNAL ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry, busy_reg : STD_LOGIC;
	SIGNAL op : STD_LOGIC_VECTOR (1 DOWNTO 0); 
	SIGNAL mult_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0'); 
BEGIN
	DP : ENTITY WORK.Datapath2
		PORT MAP (clk, rst, cout, A, B, ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry, op, mult_out);
	
	CU : ENTITY WORK.Controller2
		PORT MAP (clk, rst, start, op, ld_A, sh_A, ld_B, ld_P, zero_P, sel_AS, sel_carry, busy_reg);
		
	result <= mult_out WHEN busy_reg = '0';
	done <= NOT busy_reg;
END behavioral_Radix2_MUL;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Radix2_MUL_TB IS 
END Radix2_MUL_TB;

ARCHITECTURE behavioral_TB OF Radix2_MUL_TB IS
	SIGNAL clk : STD_LOGIC := '1';
	SIGNAL rst, done, start, cout : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL result_Radix2_MUL : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN
	MUT : ENTITY WORK.Radix2_MUL
		PORT MAP (clk, rst, start, cout, A, B, done, result_Radix2_MUL);
	
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