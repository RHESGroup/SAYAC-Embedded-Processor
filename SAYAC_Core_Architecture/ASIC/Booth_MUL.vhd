--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Controller_Booth IS 
	PORT ( clk, rst, start : IN STD_LOGIC;
		op : IN STD_LOGIC_VECTOR (1 DOWNTO 0);	
		shrP, ldQ, ldM, ldP, clrP, sel, subsel : OUT STD_LOGIC;
		done : OUT STD_LOGIC );
END Controller_Booth;

ARCHITECTURE behavioral_CU OF Controller_Booth IS 	
	TYPE state IS (IDLE, COUNT, SHIFT);
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
					n_state <= IDLE;
				ELSE
					n_state <= SHIFT;
				END IF;	
			WHEN SHIFT =>
				n_state <= COUNT;
		END CASE;
	END PROCESS;
	
	PROCESS (p_state, op, co, start)
	BEGIN
		done <= '0';	ldM <= '0';	ldQ <= '0';		ldP <= '0';		clrP <= '0';	en_cntr <= '0';	
		shrP <= '0';	sel <= '0';	subsel <= '0';	done <= '0';	zero_cntr <= '0';
		
		CASE ( p_state ) IS
			WHEN IDLE =>
				ldQ <= start;	clrP <= start; ldM <= '1'; zero_cntr <= '1';
			WHEN COUNT =>
				en_cntr <= '1'; ldP  <= '1'; 
				IF op = "10" THEN
					subsel <= '1';	sel <= '1'; 
				ELSIF op = "01" THEN
					sel <= '1'; 
				END IF;
				IF co = '1' THEN
					done <= '1';
				END IF;
			WHEN SHIFT =>
				shrP <= '1';	
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

ENTITY Datapath_Booth IS 
	PORT ( clk, rst : IN STD_LOGIC;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		op : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		shrP, ldQ, ldM, ldP, clrP, sel, subsel : IN STD_LOGIC;
		result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );			
END Datapath_Booth;

ARCHITECTURE behavioral_DP OF Datapath_Booth IS 	
	SIGNAL Mout, ASres, in2_AS_sel, AC : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL Q : STD_LOGIC_VECTOR (17 DOWNTO 0);
	SIGNAL P : STD_LOGIC_VECTOR (34 DOWNTO 0);
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			Mout <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF ldM = '1' THEN
				Mout <= A;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			P <= (OTHERS => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			IF clrP = '1' THEN
				P(34 DOWNTO 18) <= (OTHERS => '0');
				P(17 DOWNTO 0) <= (B & '0');
			ELSIF ldP = '1' THEN
				IF sel = '1' THEN
					P(34 DOWNTO 18) <= ASres;
				END IF;
			ELSIF shrP = '1' THEN
				P <= (P(34) & P(34 DOWNTO 1));
			END IF;
		END IF;
	END PROCESS;
	
    in2_AS_sel <= Mout WHEN subsel = '0' ELSE (NOT Mout);
	ADD1 : ENTITY WORK.CLA17
			PORT MAP(P(34 DOWNTO 18), in2_AS_sel, subsel, ASres);
	
	op <= P(1 DOWNTO 0);
	result <= P(32 DOWNTO 1);
	AC <= P(34 DOWNTO 18);
	Q  <= P(17 DOWNTO 0);
END behavioral_DP;		 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Booth_MUL IS
	PORT ( clk, rst, start : IN STD_LOGIC ;
		A, B : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		done : OUT STD_LOGIC;
		result: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
END Booth_MUL;	 

ARCHITECTURE behavioral_Booth_MUL OF Booth_MUL IS
	SIGNAL shrP, ldQ, ldM, ldP, clrP, sel, subsel, done_reg : STD_LOGIC;
	SIGNAL op : STD_LOGIC_VECTOR (1 DOWNTO 0); 
	SIGNAL mult_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0'); 
BEGIN
	DP : ENTITY WORK.Datapath_Booth
		PORT MAP (clk, rst, A, B, op, shrP, ldQ, ldM, ldP, clrP, sel, subsel, mult_out);
	
	CU : ENTITY WORK.Controller_Booth
		PORT MAP (clk, rst, start, op, shrP, ldQ, ldM, ldP, clrP, sel, subsel, done_reg);
		
	result <= mult_out WHEN done_reg = '1';
	done <= done_reg;
END behavioral_Booth_MUL;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Booth_MUL_TB IS 
END Booth_MUL_TB;

ARCHITECTURE behavioral_TB OF Booth_MUL_TB IS
	SIGNAL clk : STD_LOGIC := '1';
	SIGNAL rst, done, start : STD_LOGIC;
	SIGNAL A, B : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL result_Booth_MUL : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN
	MUT : ENTITY WORK.Booth_MUL
		PORT MAP (clk, rst, start, A, B, done, result_Booth_MUL);
	
	clk <= NOT clk AFTER 2.5 NS WHEN NOW <= 1000 NS ELSE '0';
	
	PROCESS
	BEGIN
		rst <= '1', '0' AFTER 3 NS;
		start <= '0';
		WAIT FOR 4 NS;
		
		A <= "00000000000001010"; 		-- A = 10
		B <= "11111111111111011";		-- B = -5
		start <= '1';
		WAIT FOR 4 NS;
		start <= '0';
		WAIT UNTIL rising_edge(done);
		
		A <= "00000000101100000"; 		-- A = 352
		B <= "00000000000000010";		-- B = 2
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