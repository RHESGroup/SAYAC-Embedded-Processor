--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY	Controller4	IS 
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				start	:	IN	STD_LOGIC;
				op		:	IN	STD_LOGIC_VECTOR(2	DOWNTO	0);	
				ld_A	:	OUT	STD_LOGIC;
				sh_A	:	OUT	STD_LOGIC;
				ld_B	:	OUT	STD_LOGIC;
				ld_P	:	OUT	STD_LOGIC;
				zero_P	:	OUT	STD_LOGIC;
				sel_AS	:	OUT	STD_LOGIC;
				sel_MUX	:	OUT	STD_LOGIC_VECTOR(1	DOWNTO	0);
				busy	:	OUT	STD_LOGIC 	);
END	Controller4;

ARCHITECTURE	behavioral_CU	OF	Controller4	IS 	
	TYPE	state	IS (IDLE, COUNT, ADD	);
	SIGNAL	p_state		:	state;
	SIGNAL	n_state		:	state;
	SIGNAL	zero_cntr	:	STD_LOGIC;
	SIGNAL	en_cntr		:	STD_LOGIC;
	SIGNAL	co			:	STD_LOGIC;
	SIGNAL	cntr		:	STD_LOGIC_VECTOR(2	DOWNTO	0);
	SIGNAL	cntinc		:	STD_LOGIC_VECTOR(2	DOWNTO	0);
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
		sel_MUX		<=	"00";	
		en_cntr		<=	'0'; 
		zero_cntr	<=	'0';
		
		CASE	(	p_state	)	IS
			WHEN IDLE =>
				zero_cntr	<=	'1';	
				zero_P		<=	'1';	
				ld_A		<=	'1';
				ld_B		<=	'1';
			WHEN COUNT =>
				busy		<=	'1';
				en_cntr	<=	'1';
				ld_P	<=	'1';
				sh_A	<=	'1';
				
				IF	op = "000" OR op = "111"	THEN		-- Nothing
					sel_MUX	<=	"00";	
				END	IF;
				IF	op = "001" OR op = "010"	THEN		-- P+B
					sel_MUX	<=	"01";
					sel_AS	<=	'0';
				END	IF;
				IF	op = "011"	THEN						-- P+2B
					sel_MUX	<=	"10";	
					sel_AS	<=	'0';
				END	IF;
				IF	op = "100"	THEN						-- P-2B
					sel_MUX	<=	"10";	
					sel_AS	<=	'1';
				END	IF;
				IF	op = "101" OR op = "110"	THEN		-- P-B
					sel_MUX	<=	"01";	
					sel_AS	<=	'1';
				END	IF;
			WHEN ADD =>
				sel_MUX	<=	"11";
				busy	<=	'0';
		END	CASE;
	END	PROCESS;
	
--Counter: counting the number	OF	iterations
	INCrementer:	ENTITY	WORK.INC	GENERIC	MAP	(	3	)
						PORT	MAP	 (	cntr, 
										cntinc	);
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
				cntr	<=	"000";
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF		zero_cntr = '1'	THEN
				cntr	<=	"000";
			ELSIF	en_cntr = '1'	THEN
				cntr	<=	cntinc;
			END	IF;
		END	IF;
	END	PROCESS;
	
	co	<=	'1'	WHEN	cntr = "111"	ELSE '0';
END	behavioral_CU;
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY	Datapath4	IS 
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
				sel_MUX	:	IN	STD_LOGIC_VECTOR(1	DOWNTO	0);
				op		:	OUT	STD_LOGIC_VECTOR(2	DOWNTO	0);
				result	:	OUT	STD_LOGIC_VECTOR(31	DOWNTO	0) 	);			
END	Datapath4;

ARCHITECTURE	behavioral_DP	OF	Datapath4	IS 	
	SIGNAL	A_reg		:	STD_LOGIC_VECTOR(17	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	B_reg		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	P_reg		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	B2			:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	AS_out		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	in2_AS		:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	in2_AS_sel	:	STD_LOGIC_VECTOR(16	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	A_reg_32	:	STD_LOGIC_VECTOR(31	DOWNTO	0)	:=	(OTHERS => '0'	);
	SIGNAL	cin			:	STD_LOGIC;
	SIGNAL	cin1		:	STD_LOGIC;
BEGIN	
--A register:
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			A_reg	<=	(OTHERS=>'0');
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF		ld_A = '1'	THEN
				A_reg	<=	A & '0';
			ELSIF	sh_A = '1'	THEN
				A_reg	<=	AS_out(1	DOWNTO	0) & A_reg(17	DOWNTO	2);	
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
				P_reg	<=	AS_out(16) & AS_out(16) & AS_out(16	DOWNTO	2);	
			END	IF;
		END	IF;
	END	PROCESS;	
	B2	<=	B_reg(15	DOWNTO	0) & '0';
		
--MUX FOR	in1_mul	
	PROCESS	(	sel_MUX, B_reg, B2, in2_AS	)
	BEGIN
		IF		sel_MUX = "00"	THEN
			in2_AS	<=	(OTHERS=>'0');
		ELSIF	sel_MUX = "01"	THEN
			in2_AS	<=	B_reg;
		ELSIF	sel_MUX = "10"	THEN
			in2_AS	<=	B2;
		ELSIF	sel_MUX = "11"	THEN
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
	
	op		<=	A_reg(2	DOWNTO	0);
	result	<=	AS_out(15	DOWNTO	0) & A_reg_32(16	DOWNTO	1);	
END	behavioral_DP;		 
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	Radix4_MUL	IS
	PORT	(	clk		:	IN	STD_LOGIC;
				rst		:	IN	STD_LOGIC;
				start	:	IN	STD_LOGIC;
				A		:	IN	STD_LOGIC_VECTOR(16	DOWNTO	0);
				B		:	IN	STD_LOGIC_VECTOR(16	DOWNTO	0);
				done	:	OUT	STD_LOGIC;
				result	:	OUT	STD_LOGIC_VECTOR(31	DOWNTO	0) 	);
END	Radix4_MUL;	 

ARCHITECTURE	behavioral_Radix4_MUL	OF	Radix4_MUL	IS
	SIGNAL	ld_A		:	STD_LOGIC;
	SIGNAL	sh_A		:	STD_LOGIC;
	SIGNAL	ld_B		:	STD_LOGIC;
	SIGNAL	ld_P		:	STD_LOGIC;
	SIGNAL	zero_P		:	STD_LOGIC;
	SIGNAL	sel_AS		:	STD_LOGIC;
	SIGNAL	busy_reg	:	STD_LOGIC;
	SIGNAL	sel_MUX		:	STD_LOGIC_VECTOR(1	DOWNTO	0);
	SIGNAL	op			:	STD_LOGIC_VECTOR(2	DOWNTO	0); 
	SIGNAL	mult_out	:	STD_LOGIC_VECTOR(31	DOWNTO	0)	:=	(OTHERS => '0'	); 
BEGIN
	DP:	ENTITY	WORK.Datapath4
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
	
	CU:	ENTITY	WORK.Controller4
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
END	behavioral_Radix4_MUL;
---------------------------------------------------------------------------------------------------------------------------------
