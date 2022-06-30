--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLA IS
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
END CLA;	 

ARCHITECTURE behavioral OF CLA IS
	SIGNAL c : STD_LOGIC_VECTOR(n/m-1 DOWNTO 0);
	
	COMPONENT CLA_block IS
		GENERIC (
			m : INTEGER := 4
		);
		PORT ( 
			x, y  : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
			cin : IN STD_LOGIC;
			sum : OUT STD_LOGIC_VECTOR (m-1 DOWNTO 0);
			cout : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN
	checkm_4 : IF m = 4 GENERATE
		first_0_4 : CLA_block GENERIC MAP (4)
			PORT MAP(x(m-1 DOWNTO 0), y(m-1 DOWNTO 0), cin, sum(m-1 DOWNTO 0), c(0));
		
		rest_4 : FOR I IN 1 TO n/m-1 GENERATE
			rest_I_4 : CLA_block GENERIC MAP (4)
				PORT MAP(x(m*(I+1)-1 DOWNTO m*I), y(m*(I+1)-1 DOWNTO m*I), c(I-1), sum(m*(I+1)-1 DOWNTO m*I), c(I));
		END GENERATE;
	END GENERATE;
	
	checkm_8 : IF m = 8 GENERATE
		first_0_8 : CLA_block GENERIC MAP (8)
			PORT MAP(x(m-1 DOWNTO 0), y(m-1 DOWNTO 0), cin, sum(m-1 DOWNTO 0), c(0));
		
		rest_8 : FOR I IN 1 TO n/m-1 GENERATE
			rest_I_8 : CLA_block GENERIC MAP (8)
				PORT MAP(x(m*(I+1)-1 DOWNTO m*I), y(m*(I+1)-1 DOWNTO m*I), c(I-1), sum(m*(I+1)-1 DOWNTO m*I), c(I));
		END GENERATE;
	END GENERATE;
	
	checkm_16 : IF m = 16 GENERATE
		first_0_16 : CLA_block GENERIC MAP (16)
			PORT MAP(x(m-1 DOWNTO 0), y(m-1 DOWNTO 0), cin, sum(m-1 DOWNTO 0), c(0));
		
		rest_16 : FOR I IN 1 TO n/m-1 GENERATE
			rest_I_16 : CLA_block GENERIC MAP (16)
				PORT MAP(x(m*(I+1)-1 DOWNTO m*I), y(m*(I+1)-1 DOWNTO m*I), c(I-1), sum(m*(I+1)-1 DOWNTO m*I), c(I));
		END GENERATE;
	END GENERATE;
	
	cout <= c(n/m-1);
END behavioral;	 
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLA16 IS
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		cin : IN STD_LOGIC;
		sum : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END CLA16;		 

ARCHITECTURE behavioral OF CLA16 IS
	SIGNAL c, P, G : STD_LOGIC_VECTOR(15 DOWNTO 0);

	COMPONENT GAP IS
		GENERIC (
				m : INTEGER := 4
			);
		PORT ( 
			x, y : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
			P,G : OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0) 
		);
	END COMPONENT;

	COMPONENT CLG_16 IS
		PORT ( 
			P,G : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			cin : IN STD_LOGIC;
			C : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
		);
	END COMPONENT;
BEGIN
	MY_GAP : GAP GENERIC MAP (16)
		PORT MAP( x, y, P, G);
	
	MY_CLG_16 : CLG_16
		PORT MAP( P, G, cin, c);

	sum(0) <= p(0) XOR cin;
	sum(15 DOWNTO 1) <= p(15 DOWNTO 1) XOR c(14 DOWNTO 0);
END behavioral;	 
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLA_block IS
	GENERIC (
			m : INTEGER := 4
		);
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
		cin : IN STD_LOGIC;
		sum : OUT STD_LOGIC_VECTOR (m-1 DOWNTO 0);
		cout : OUT STD_LOGIC 
	);
END CLA_block;	 

ARCHITECTURE behavioral OF CLA_block IS
	SIGNAL c, P, G : STD_LOGIC_VECTOR(m-1 DOWNTO 0);

	COMPONENT GAP IS
		GENERIC (
				m : INTEGER := 4
			);
		PORT ( 
			x, y : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
			P,G : OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0) 
		);
	END COMPONENT;

	COMPONENT CLG_4 IS
		PORT ( 
			P,G : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			cin : IN STD_LOGIC;
			C : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) 
		);
	END COMPONENT;
	
	COMPONENT CLG_8 IS
		PORT ( 
			P,G : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			cin : IN STD_LOGIC;
			C : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
		);
	END COMPONENT;

	COMPONENT CLG_16 IS
		PORT ( 
			P,G : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			cin : IN STD_LOGIC;
			C : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
		);
	END COMPONENT;
BEGIN
	MY_GAP : GAP GENERIC MAP (m)
		PORT MAP( x, y, P, G);
	
	checkm_4 : IF m = 4 GENERATE
		MY_CLG_4 : CLG_4
			PORT MAP( P, G, cin, C);
	END GENERATE;
	
	checkm_8 : IF m = 8 GENERATE
		MY_CLG_8 : CLG_8
			PORT MAP( P, G, cin, C);
	END GENERATE;
	
	checkm_16 : IF m = 16 GENERATE
		MY_CLG_16 : CLG_16
			PORT MAP( P, G, cin, C);
	END GENERATE;	

	cout <= C(m-1);
	sum(0) <= p(0) XOR cin;
	sum(m-1 DOWNTO 1) <= p(m-1 DOWNTO 1) XOR c(m-2 DOWNTO 0);
END behavioral;	
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY GAP IS
	GENERIC (
			m : INTEGER := 4
		);
	PORT ( 
		x, y  : IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
--		P, G, A : OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0)
		P, G : OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0)
	);
END GAP;	 

ARCHITECTURE behavioral OF GAP IS
BEGIN
	P <= x XOR y;
	G <= x AND y;
--	A <= x OR y;
END behavioral;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLG_4 IS
	PORT ( 
		p, g : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		cin : IN STD_LOGIC;
		c   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );
END CLG_4;	 

ARCHITECTURE behavioral OF CLG_4 IS
BEGIN		
	c(0) <= g(0) OR (p(0) AND cin);
	c(1) <= g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2) <= g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0))
		OR (p(2) AND p(1)AND p(0) AND cin);
	c(3) <= g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1))
		OR (p(3) AND p(2)AND p(1) AND g(0))
		OR (p(3) AND p(2)AND p(1) AND p(0) AND cin);
END behavioral;	
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLG_8 IS
	PORT ( 
		p, g : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		cin : IN STD_LOGIC;
		c   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) );
END CLG_8;	 

ARCHITECTURE behavioral OF CLG_8 IS
BEGIN		
	c(0) <= g(0) OR (p(0) AND cin);
	c(1) <= g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2) <= g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0))
			OR (p(2) AND p(1)AND p(0) AND cin);	
	c(3) <= g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1))
			OR (p(3) AND p(2) AND p(1) AND g(0))
			OR (p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(4) <= g(4) OR (p(4) AND g(3)) OR (p(4) AND p(3) AND g(2))
			OR (p(4) AND p(3) AND p(2) AND g(1))
			OR (p(4) AND p(3) AND p(2) AND p(1) AND g(0))
			OR (p(4) AND p(3) AND p(2) AND p(1) AND P(0) AND cin);
	c(5) <= g(5) OR (p(5) AND g(4)) OR (p(5) AND p(4) AND g(3))
		OR (p(5) AND p(4) AND p(3) AND g(2))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(6) <= g(6) OR (p(6) AND g(5)) OR (p(6) AND p(5) AND g(4))
		OR (p(6) AND p(5) AND p(4) AND g(3))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(7) <= g(7) OR (p(7) AND g(6)) OR (p(7) AND p(6) AND g(3))
		OR (p(7) AND p(6) AND p(5) AND g(4))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
END behavioral;	
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CLG_16 IS
	PORT ( 
		p, g : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		cin : IN STD_LOGIC;
		c   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );
END CLG_16;	 

ARCHITECTURE behavioral OF CLG_16 IS
BEGIN		
	c(0) <= g(0) OR (p(0) AND cin);
	c(1) <= g(1) OR (p(1) AND g(0)) OR (p(1) AND p(0) AND cin);
	c(2) <= g(2) OR (p(2) AND g(1)) OR (p(2) AND p(1) AND g(0))
		OR (p(2) AND p(1)AND p(0) AND cin);	
	c(3) <= g(3) OR (p(3) AND g(2)) OR (p(3) AND p(2) AND g(1))
		OR (p(3) AND p(2) AND p(1) AND g(0))
		OR (p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(4) <= g(4) OR (p(4) AND g(3)) OR (p(4) AND p(3) AND g(2))
		OR (p(4) AND p(3) AND p(2) AND g(1))
		OR (p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(4) AND p(3) AND p(2) AND p(1) AND P(0) AND cin);
	c(5) <= g(5) OR (p(5) AND g(4)) OR (p(5) AND p(4) AND g(3))
		OR (p(5) AND p(4) AND p(3) AND g(2))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(6) <= g(6) OR (p(6) AND g(5)) OR (p(6) AND p(5) AND g(4))
		OR (p(6) AND p(5) AND p(4) AND g(3))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(7) <= g(7) OR (p(7) AND g(6)) OR (p(7) AND p(6) AND g(5))
		OR (p(7) AND p(6) AND p(5) AND g(4))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(8) <= g(8) OR (p(8) AND g(7)) OR (p(8) AND p(7) AND g(6))
		OR (p(8) AND p(7) AND p(6) AND g(5))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(9) <= g(9) OR (p(9) AND g(8)) OR (p(9) AND p(8) AND g(7))
		OR (p(9) AND p(8) AND p(7) AND g(6))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(10) <= g(10) OR (p(10) AND g(9)) OR (p(10) AND p(9) AND g(8))
		OR (p(10) AND p(9) AND p(8) AND g(7))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);		
	c(11) <= g(11) OR (p(11) AND g(10)) OR (p(11) AND p(10) AND g(9))
		OR (p(11) AND p(10) AND p(9) AND g(8))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(12) <= g(12) OR (p(12) AND g(11)) OR (p(12) AND p(11) AND g(10))
		OR (p(12) AND p(11) AND p(10) AND g(9))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(13) <= g(13) OR (p(13) AND g(12)) OR (p(13) AND p(12) AND g(11))
		OR (p(13) AND p(12) AND p(11) AND g(10))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(14) <= g(14) OR (p(14) AND g(13)) OR (p(14) AND p(13) AND g(12))
		OR (p(14) AND p(13) AND p(12) AND g(11))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND g(10))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
	c(15) <= g(15) OR (p(15) AND g(14)) OR (p(15) AND p(14) AND g(13))
		OR (p(15) AND p(14) AND p(13) AND g(12))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND g(11))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND g(10))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND g(9))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND g(8))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND g(7))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND g(6))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND g(5))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND g(4))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND g(3))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND g(2))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND g(1))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND g(0))
		OR (p(15) AND p(14) AND p(13) AND p(12) AND p(11) AND p(10) AND p(9) AND p(8) AND p(7) AND p(6) AND p(5) AND p(4) AND p(3) AND p(2) AND p(1) AND p(0) AND cin);
END behavioral;
---------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CLA_test IS 
END CLA_test;	  

ARCHITECTURE behavioral_TB OF CLA_test IS
	COMPONENT CLA IS 
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
	CUT_16 : CLA GENERIC MAP(32, 16)
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
			
		x <= X"FFFFFF7F";						-- A = -129
		y <= X"00000202";						-- B = 514
		WAIT FOR 9 NS;
		cin <= '0';
		
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
---------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY CLA_16_16_TB IS 
END CLA_16_16_TB;

ARCHITECTURE behavioral_TB OF CLA_16_16_TB IS
	COMPONENT CLA IS 
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

	SIGNAL x, y, sum : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL cin, cout : STD_LOGIC;
BEGIN	
	CUT_16 : CLA GENERIC MAP(16, 16)
		PORT MAP(x, y, cin, sum, cout);
	
	PROCESS
	BEGIN	
		cin <= '0';
		x <= "0000000000001010"; 		-- A = 10
		y <= "1111111111111011";		-- B = -5
		WAIT FOR 5 NS;
		x <= X"FF7F"; 					-- A = -129
		y <= X"0202";					-- B = 514
		WAIT FOR 5 NS;
		cin <= '1';
		WAIT FOR 5 NS;
		x <= X"0A50"; 					-- A = 2640
		y <= X"0080";					-- B = 128
		WAIT FOR 5 NS;	
		x <= "1111111111110111"; 		-- A = -9
		y <= "0000000000010001";		-- B = 17
		WAIT FOR 5 NS;	
		x <= X"FFF3"; 					-- A = -13
		y <= X"FFF6";					-- B = -10
		WAIT FOR 5 NS;
		WAIT;
	END PROCESS;
END behavioral_TB; 