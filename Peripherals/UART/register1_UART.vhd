LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg1_UART IS
	PORT (		x		: 				IN STD_LOGIC;
				CLK		: 				IN STD_LOGIC;
				rst		: 				IN STD_LOGIC;  
				load	: 				IN STD_LOGIC; 
				Zero	: 				IN STD_LOGIC;
				high_amP:				IN STD_LOGIC;
				q		: 				OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE behavioral OF Reg1_UART IS

BEGIN
	PROCESS(CLK, rst)
	BEGIN
		
		IF( rst = '1' AND rst'EVENT) THEN
			q <= '0';
		ELSIF (CLK = '1' AND CLK'EVENT) THEN	
			IF (load = '1') THEN
				q <= x;	
			ELSIF(Zero = '1') THEN
				q <= '0';
			ELSIF (high_amP = '1' ) THEN
				q <= 'Z';
			END IF;	
		END IF;
		
	END PROCESS;
END behavioral;

