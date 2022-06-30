--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FA IS 
	PORT ( 
		x, y, cin : IN STD_LOGIC;
		sum, cout : OUT STD_LOGIC
	);
END FA;	  

ARCHITECTURE behavioral_FA OF FA IS
BEGIN
	sum <= x XOR y XOR cin;
	cout <= (x AND y) OR (x AND cin) OR (cin AND y);
END behavioral_FA;
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RCA IS 
	GENERIC ( 
		n : INTEGER := 32
	);
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        sum : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0)
	);
END RCA;	  

ARCHITECTURE behavioral_RCA OF RCA IS
	COMPONENT FA IS 
		PORT ( 
			x, y, cin : IN STD_LOGIC;
			sum, cout : OUT STD_LOGIC 
		);
	END COMPONENT;	
	
	SIGNAL carry	: STD_LOGIC_VECTOR(n-1 DOWNTO 1);
	SIGNAL cout		: STD_LOGIC;
BEGIN
	bit0 : FA
			PORT MAP(x(0), y(0), '0', sum(0), carry(1));
	
	add : FOR I IN 1 TO n-2 GENERATE
			bitI : FA
				PORT MAP(x(I), y(I), carry(I), sum(I), carry(I+1));
	END GENERATE;
	
	bitn : FA
			PORT MAP(x(n-1), y(n-1), carry(n-1), sum(n-1), cout);
END behavioral_RCA;
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RCA_test IS 
END RCA_test;	  

ARCHITECTURE behavioral_TB OF RCA_test IS
	COMPONENT RCA IS 
		GENERIC ( 
			n : INTEGER := 32
		);
		PORT ( 
			x, y  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			sum : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL x, y, sum : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN	
	CUT_n : RCA GENERIC MAP(32)
		PORT MAP(x, y, sum);
	
	PROCESS
	BEGIN
		x <= "00000000000000000000000000110100"; -- 52
		y <= "00000000000000000000000000100110"; -- 38
		
		WAIT FOR 9 NS;
		x <= "11111111111111110000000100011000"; -- -
		y <= "11111111111111110000001000010000"; -- -
		
		WAIT FOR 8 NS;
		x <= "11111111111111110100000100011000"; -- -
		y <= "00000000000000000011001000010000"; -- 
		
		WAIT FOR 3 NS;
		x <= "00000000111111110100000100011000"; -- -
		y <= "00000000000000000011001000010000"; -- 
		WAIT;
	END PROCESS;
END behavioral_TB;