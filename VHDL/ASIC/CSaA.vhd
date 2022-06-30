-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CSaA IS
	GENERIC (
		n : INTEGER := 32;
		m : INTEGER := 4
	);
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		cin : IN STD_LOGIC;
		sum : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		cout : OUT STD_LOGIC 
	);
END CSaA;	 

ARCHITECTURE behavioral OF CSaA IS
	SIGNAL c : STD_LOGIC_VECTOR(n/m-1 DOWNTO 0);
	
	COMPONENT CSaA_block IS
		GENERIC (
			n : INTEGER := 4
		);
		PORT ( 
			x, y  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			cin : IN STD_LOGIC;
			sum : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0);
			cout : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN
	checkm_4 : IF m = 4 GENERATE
		first_0_4 : CSaA_block GENERIC MAP (4)
			PORT MAP(x(m-1 DOWNTO 0), y(m-1 DOWNTO 0), cin, sum(m-1 DOWNTO 0), c(0));
		
		rest_4 : FOR I IN 1 TO n/m-1 GENERATE
			rest_I_4 : CSaA_block GENERIC MAP (4)
				PORT MAP(x(m*(I+1)-1 DOWNTO m*I), y(m*(I+1)-1 DOWNTO m*I), c(I-1), sum(m*(I+1)-1 DOWNTO m*I), c(I));
		END GENERATE;
	END GENERATE;
	
	checkm_8 : IF m = 8 GENERATE
		first_0_8 : CSaA_block GENERIC MAP (8)
			PORT MAP(x(m-1 DOWNTO 0), y(m-1 DOWNTO 0), cin, sum(m-1 DOWNTO 0), c(0));
		
		rest_8 : FOR I IN 1 TO n/m-1 GENERATE
			rest_I_8 : CSaA_block GENERIC MAP (8)
				PORT MAP(x(m*(I+1)-1 DOWNTO m*I), y(m*(I+1)-1 DOWNTO m*I), c(I-1), sum(m*(I+1)-1 DOWNTO m*I), c(I));
		END GENERATE;
	END GENERATE;
	
	checkm_16 : IF m = 16 GENERATE
		first_0_16 : CSaA_block GENERIC MAP (16)
			PORT MAP(x(m-1 DOWNTO 0), y(m-1 DOWNTO 0), cin, sum(m-1 DOWNTO 0), c(0));
		
		rest_16 : FOR I IN 1 TO n/m-1 GENERATE
			rest_I_16 : CSaA_block GENERIC MAP (16)
				PORT MAP(x(m*(I+1)-1 DOWNTO m*I), y(m*(I+1)-1 DOWNTO m*I), c(I-1), sum(m*(I+1)-1 DOWNTO m*I), c(I));
		END GENERATE;
	END GENERATE;
	
	checkm_32 : IF m = 32 GENERATE
		whole : CSaA_block GENERIC MAP (32)
			PORT MAP(x, y, cin, sum, c(0));
	END GENERATE;
	
	cout <= c(n/m-1);
END behavioral;	 
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CSaA_block IS
	GENERIC ( 
			n : INTEGER := 32
		);
	PORT (
		x, y  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		cin : IN STD_LOGIC;
		sum : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		cout : OUT STD_LOGIC 
	);
END ENTITY CSaA_block;

ARCHITECTURE FUNC OF CSaA_block IS
	COMPONENT FA IS 
		PORT ( 
			x, y, cin : IN STD_LOGIC;
			sum, cout : OUT STD_LOGIC 
		);
	END COMPONENT;	

	SIGNAL so       : std_logic_vector (n-1 DOWNTO 1);
	SIGNAL co1, co2 : std_logic_vector (n-1 DOWNTO 0);
	SIGNAL c : std_logic;
BEGIN
	co2(0) <= '0';
	
	bit0_1 : FA 
			PORT MAP (x(0), y(0), cin, sum(0), co1(0));
			
	L1 : FOR I IN 1 TO n-1 GENERATE
		bitI_1 : FA 
				PORT MAP (x(I), y(I), '0', so(I), co1(I));
	END GENERATE L1;
	----------------------------------------------------------------------
	L2 : FOR I IN 0 TO n-2 GENERATE
		bitI_2 : FA 
				PORT MAP (so(I+1), co1(I), co2(I), sum(I+1), co2(I+1));
	END GENERATE L2;
	----------------------------------------------------------------------
	last : FA 
			PORT MAP ('0', co1(n-1), co2(n-1), cout, c);

END ARCHITECTURE FUNC;
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CSaA_test IS 
END CSaA_test;	  

ARCHITECTURE behavioral_TB OF CSaA_test IS
	COMPONENT CSaA IS 
		GENERIC ( 
			n : INTEGER := 32;
			m : INTEGER := 4
		);
		PORT ( 
			x, y  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			cin : IN STD_LOGIC;
			sum : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0);
			cout : OUT STD_LOGIC 
		);
	END COMPONENT;

	SIGNAL x, y, sum : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL cin, cout : STD_LOGIC;
BEGIN	
	CUT_16 : CSaA GENERIC MAP(32, 16)
		PORT MAP(x, y, cin, sum, cout);
	
	PROCESS
	BEGIN
		x <= "00000000000000000000000000110100"; -- 52
		y <= "00000000000000000000000000100110"; -- 38
		cin <= '0';				  -- 90
		
		WAIT FOR 9 NS;
		x <= "11111111111111110000000100011000"; -- -
		y <= "11111111111111110000001000010000"; -- -
		cin <= '1';				  -- -
		
		WAIT FOR 8 NS;
		x <= "11111111111111110100000100011000"; -- -
		y <= "00000000000000000011001000010000"; -- 
		cin <= '1';				  -- -
		
		WAIT FOR 3 NS;
		x <= "00000000111111110100000100011000"; -- -
		y <= "00000000000000000011001000010000"; -- 
		cin <= '0';				  -- -
		WAIT;
	END PROCESS;
END behavioral_TB;