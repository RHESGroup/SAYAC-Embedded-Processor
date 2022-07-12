--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY	Controller_Radix16_MUL	IS 
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				start	:	IN	STD_LOGIC;
				op		:	IN	STD_LOGIC_VECTOR(4	DOWNTO	0);	
				ld_A	:	OUT	STD_LOGIC;
				sh_A	:	OUT	STD_LOGIC;
				ld_B	:	OUT	STD_LOGIC;
				ld_P	:	OUT	STD_LOGIC;
				zero_P	:	OUT	STD_LOGIC;
				sel_AS	:	OUT	STD_LOGIC;
				sel_MUX	:	OUT	STD_LOGIC_VECTOR(3	DOWNTO	0);
				busy	:	OUT	STD_LOGIC 	);
END	Controller_Radix16_MUL;

ARCHITECTURE	behavioral_CU	OF	Controller_Radix16_MUL	IS 	
	TYPE	state	IS (IDLE, COUNT, ADD);
	SIGNAL	p_state		:	state;
	SIGNAL	n_state		:	state;
	SIGNAL	zero_cntr	:	STD_LOGIC;
	SIGNAL	en_cntr		:	STD_LOGIC;
	SIGNAL	co			:	STD_LOGIC;
	SIGNAL	cntr		:	STD_LOGIC_VECTOR(1	DOWNTO	0);
	SIGNAL	cntinc		:	STD_LOGIC_VECTOR(1	DOWNTO	0);
BEGIN	
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			p_state	<=	IDLE;
		ELSIF	clk = '1' AND clk'EVENT	THEN
			p_state	<=	n_state;
		END	IF;
	END	PROCESS;
	
	PROCESS	(	p_state, start, co	)
	BEGIN	
		n_state	<=	IDLE;
		
		CASE	(	p_state	)	IS
			WHEN IDLE =>
				IF	start	<=	'0'	THEN
					n_state	<=	IDLE;
				ELSE
					n_state	<=	COUNT;
				END	IF;
			WHEN COUNT =>
				IF	co = '1'	THEN
					n_state	<=	ADD;
				ELSE
					n_state	<=	COUNT;
				END	IF;			
			WHEN ADD =>
				n_state	<=	IDLE;
		END	CASE;
	END	PROCESS;
	
	PROCESS	(	p_state, op	)
	BEGIN
		busy		<=	'1';	
		ld_A		<=	'0'; 
		sh_A		<=	'0'; 
		ld_B		<=	'0'; 
		ld_P		<=	'0'; 
		zero_P		<=	'0'; 
		sel_AS		<=	'0'; 
		sel_MUX		<=	"0000";	
		en_cntr		<=	'0'; 
		zero_cntr	<=	'0';
		
		CASE	(	p_state	)	IS
			WHEN IDLE =>
				zero_cntr	<=	'1';	
				zero_P		<=	'1';	
				ld_A		<=	'1';
				ld_B		<=	'1';
			WHEN COUNT =>
				IF	op = "00000" OR op = "11111"	THEN		-- Nothing
					sel_MUX	<=	"0000";	
				END	IF;
				
				IF	op = "00001" OR op = "00010"	THEN		-- P+B
					sel_MUX	<=	"0001";
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "00011" OR op = "00100"	THEN		-- P+2B
					sel_MUX	<=	"0010";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "00101" OR op = "00110"	THEN		-- P+3B
					sel_MUX	<=	"0011";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "00111" OR op = "01000"	THEN		-- P+4B
					sel_MUX	<=	"0100";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "01001" OR op = "01010"	THEN		-- P+5B
					sel_MUX	<=	"0101";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "01011" OR op = "01100"	THEN		-- P+6B
					sel_MUX	<=	"0110";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "01101" OR op = "01110"	THEN		-- P+7B
					sel_MUX	<=	"0111";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "01111"	THEN						-- P+8B
					sel_MUX	<=	"1000";	
					sel_AS	<=	'0';
				END	IF;
				
				IF	op = "10000"	THEN						-- P-8B
					sel_MUX	<=	"1000";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "10001" OR op = "10010"	THEN		-- P-7B
					sel_MUX	<=	"0111";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "10011" OR op = "10100"	THEN		-- P-6B
					sel_MUX	<=	"0110";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "10101" OR op = "10110"	THEN		-- P-5B
					sel_MUX	<=	"0101";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "10111" OR op = "11000" 	THEN		-- P-4B
					sel_MUX	<=	"0100";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "11001" OR op = "11010"	THEN		-- P-3B
					sel_MUX	<=	"0011";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "11011" OR op = "11100"	THEN		-- P-2B
					sel_MUX	<=	"0010";	
					sel_AS	<=	'1';
				END	IF;
				
				IF	op = "11101" OR op = "11110"	THEN		-- P-B
					sel_MUX	<=	"0001";	
					sel_AS	<=	'1';
				END	IF;
				
				en_cntr	<=	'1';
				ld_P	<=	'1';
				sh_A	<=	'1';
			WHEN ADD =>
				sel_MUX	<=	"1001";
				busy	<=	'0';
		END	CASE;
	END	PROCESS;
	
--Counter: counting the number	OF	iterations
	INCrementer:	ENTITY	WORK.INC	GENERIC	MAP	(	2	)
						PORT	MAP	 (	cntr, 
										cntinc	);
										
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
				cntr	<=	"00";
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	zero_cntr = '1'	THEN
				cntr	<=	"00";
			ELSIF	en_cntr = '1'	THEN
				cntr	<=	cntinc;
			END	IF;
		END	IF;
	END	PROCESS;
	
	co	<=	'1'	WHEN	cntr = "11"	ELSE '0';
END	behavioral_CU;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY	Datapath_Radix16_MUL	IS 
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				A		:	IN	STD_LOGIC_VECTOR(16	DOWNTO	0);
				B		:	IN	STD_LOGIC_VECTOR(16	DOWNTO	0);
				ld_A	:	IN	STD_LOGIC;
				sh_A	:	IN	STD_LOGIC;
				ld_B	:	IN	STD_LOGIC;
				ld_P	:	IN	STD_LOGIC;
				zero_P	:	IN	STD_LOGIC;
				sel_AS	:	IN	STD_LOGIC;
				sel_MUX	:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				op		:	OUT	STD_LOGIC_VECTOR(4	DOWNTO	0);
				result	:	OUT	STD_LOGIC_VECTOR(31	DOWNTO	0) 	);			
END	Datapath_Radix16_MUL;

ARCHITECTURE	behavioral_DP	OF	Datapath_Radix16_MUL	IS 	
	SIGNAL	A_reg		:	STD_LOGIC_VECTOR(17	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B_reg		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	P_reg		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	AS_out		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	in2_AS		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B2			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B3			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B4			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B5			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B6			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B7			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	B8			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	in2_AS_sel	:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	A_reg_32	:	STD_LOGIC_VECTOR(31	DOWNTO	0)	:=	(OTHERS => '0');
	SIGNAL	cin, cin1	:	STD_LOGIC;
BEGIN	
--A register:
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			A_reg	<=	(OTHERS=>'0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	ld_A = '1'	THEN
				A_reg	<=	A & '0';
			ELSIF	sh_A = '1'	THEN
				A_reg	<=	AS_out(3	DOWNTO	0) & A_reg(17	DOWNTO	4);	
			END	IF;
		END	IF;
	END	PROCESS;
	
	A_reg_32	<=	("000000000000000" & A_reg(17	DOWNTO	1));
	
--B register: 
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
				B_reg	<=	(OTHERS=>'0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	ld_B = '1'	THEN
				B_reg	<=	B;
			END	IF;
		END	IF;
	END	PROCESS;

--P register:
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
				P_reg	<=	(OTHERS=>'0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF		zero_P = '1'	THEN
				P_reg	<=	(OTHERS=>'0');
			ELSIF	ld_P = '1'	THEN
				P_reg	<=	AS_out(16) & AS_out(16) & AS_out(16) & AS_out(16) & AS_out(16	DOWNTO	4	);	
			END	IF;
		END	IF;
	END	PROCESS;
	
	B2	<=	B_reg(15	DOWNTO	0) & '0';
	B4	<=	B_reg(14	DOWNTO	0) & "00";
	B8	<=	B_reg(13	DOWNTO	0) & "000";
	
	ADD_B3:	ENTITY	WORK.CLA17
				PORT	MAP	(	B_reg, 
								B2, 
								'0', 
								B3	);
	
	ADD_B5:	ENTITY	WORK.CLA17
				PORT	MAP	(	B_reg, 
								B4, 
								'0', 
								B5	);
	ADD_B6:	ENTITY	WORK.CLA17
				PORT	MAP	(	B2, 
								B4, 
								'0', 
								B6	);

	ADD_B7:	ENTITY	WORK.CLA17
				PORT	MAP	(	B3, 
								B4, 
								'0', 
								B7	);


--MUX FOR	in1_mul	
	PROCESS	(	sel_MUX, B_reg, B2, B3, B4, B5, B6, B7, B8	)
	BEGIN
		IF		sel_MUX = "0000"	THEN
			in2_AS	<=	(OTHERS => '0');
		ELSIF	sel_MUX = "0001"	THEN
			in2_AS	<=	B_reg;
		ELSIF	sel_MUX = "0010"	THEN
			in2_AS	<=	B2;
		ELSIF	sel_MUX = "0011"	THEN
			in2_AS	<=	B3;
		ELSIF	sel_MUX = "0100"	THEN
			in2_AS	<=	B4;
		ELSIF	sel_MUX = "0101"	THEN
			in2_AS	<=	B5;
		ELSIF	sel_MUX = "0110"	THEN
			in2_AS	<=	B6;
		ELSIF	sel_MUX = "0111"	THEN
			in2_AS	<=	B7;
		ELSIF	sel_MUX = "1000"	THEN
			in2_AS	<=	B8;
		ELSIF	sel_MUX = "1001"	THEN
			in2_AS	<=	(OTHERS => '0');
		END	IF;
	END	PROCESS;
	
--AddSub	
	in2_AS_sel	<=	in2_AS	WHEN	sel_AS = '0'	ELSE (NOT in2_AS);
	
	ADD1:	ENTITY	WORK.CLA17
				PORT	MAP	(	P_reg, 
								in2_AS_sel, 
								sel_AS, 
								AS_out	);
	
	op		<=	A_reg(4	DOWNTO	0);
	result	<=	AS_out(15	DOWNTO	0) & A_reg_32(16	DOWNTO	1);	
END	behavioral_DP;		 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	Radix16_MUL	IS 
	PORT	(	clk		:	IN	STD_LOGIC ;
				rst		:	IN	STD_LOGIC ;
				start	:	IN	STD_LOGIC ;
				A		:	IN	STD_LOGIC_VECTOR(16	DOWNTO	0);
				B		:	IN	STD_LOGIC_VECTOR(16	DOWNTO	0);
				done	:	OUT	STD_LOGIC;
				result	:	OUT	STD_LOGIC_VECTOR(31	DOWNTO	0) 	);
END	Radix16_MUL;	 

ARCHITECTURE	behavioral_Radix16_MUL	OF	Radix16_MUL	IS 
	SIGNAL	ld_A		:	STD_LOGIC;
	SIGNAL	sh_A		:	STD_LOGIC;
	SIGNAL	ld_B		:	STD_LOGIC;
	SIGNAL	ld_P		:	STD_LOGIC;
	SIGNAL	zero_P		:	STD_LOGIC;
	SIGNAL	sel_AS		:	STD_LOGIC;
	SIGNAL	busy_reg	:	STD_LOGIC;
	SIGNAL	sel_MUX		:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	op			:	STD_LOGIC_VECTOR(4	DOWNTO	0); 
	SIGNAL	mult_out	:	STD_LOGIC_VECTOR(31	DOWNTO	0)	:=	(OTHERS => '0'	); 
BEGIN
	DP:	ENTITY	WORK.Datapath_Radix16_MUL
			PORT	MAP(	clk, 
							rst, 
							A, 
							B, 
							ld_A, 
							sh_A, 
							ld_B, 
							ld_P, 
							zero_P, 
							sel_AS, 
							sel_MUX, 
							op, 
							mult_out	);
	
	CU:	ENTITY	WORK.Controller_Radix16_MUL
			PORT	MAP(	clk, 
							rst, 
							start, 
							op, 
							ld_A, 
							sh_A, 
							ld_B, 
							ld_P, 
							zero_P, 
							sel_AS, 
							sel_MUX, 
							busy_reg	);
		
	result	<=	mult_out	WHEN	busy_reg = '0';
	done	<=	NOT busy_reg;
END	behavioral_Radix16_MUL;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY	Radix16_MUL_TB	IS 
END	Radix16_MUL_TB;

ARCHITECTURE	behavioral_TB	OF	Radix16_MUL_TB	IS
	SIGNAL	clk					:	STD_LOGIC	:=	'1';
	SIGNAL	rst					:	STD_LOGIC;
	SIGNAL	done				:	STD_LOGIC;
	SIGNAL	start				:	STD_LOGIC;
	SIGNAL	A					:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	B					:	STD_LOGIC_VECTOR(16	DOWNTO	0);
	SIGNAL	result_Radix16_MUL	:	STD_LOGIC_VECTOR(31	DOWNTO	0);
BEGIN
	MUT:	ENTITY	WORK.Radix16_MUL 
				PORT	MAP(	clk, 
								rst, 
								start, 
								A, 
								B, 
								done, 
								result_Radix16_MUL	);
	
	clk	<=	NOT clk AFTER 2.5 NS	WHEN	NOW	<=	300 NS	ELSE '0';
	rst	<=	'1', '0' AFTER 6 NS;
	
	PROCESS
	BEGIN
		start	<=	'0';
		WAIT	FOR	5 NS;
		A		<=	"00000000000000000"; 		-- A = 0
		B		<=	"00000000000000000";		-- B = 0
		start	<=	'1';
		WAIT UNTIL RISING_EDGE(done);
		
		A		<=	"00000000101100000"; 		-- A = 352
		B		<=	"00000000100000001";		-- B = 257
		WAIT UNTIL RISING_EDGE(done);
		
		A		<=	"00000000000001010"; 		-- A = 10
		B		<=	"11111111111111011";		-- B = -5
		WAIT UNTIL RISING_EDGE(done);
	
		A		<=	"00000101001010000"; 		-- A = 2640
		B		<=	"00000000010000000";		-- B = 128
		WAIT UNTIL RISING_EDGE(done);
		
		A		<=	"11111111111110111"; 		-- A = -9
		B		<=	"00000000000010001";		-- B = 17
		WAIT UNTIL RISING_EDGE(done);
		
		A		<=	"11111111111110011"; 		-- A = -13
		B		<=	"11111111111110110";		-- B = -10
		WAIT UNTIL RISING_EDGE(done);
		start	<=	'0';
		
		WAIT	FOR	15 NS;
		WAIT;
	END	PROCESS;
END	behavioral_TB; 