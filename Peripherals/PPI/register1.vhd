LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg1 IS
	PORT (		x		: 				IN STD_LOGIC;  
				rst		: 				IN STD_LOGIC;  
				load	: 				IN STD_LOGIC; 
				Zero	: 				IN STD_LOGIC;
				high_amP:				IN STD_LOGIC;
				q		: 				OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE behavioral OF Reg1 IS

BEGIN
	PROCESS(rst, load, Zero, high_amP)
	BEGIN
		
		IF( rst = '1' AND rst'EVENT) THEN
			q <= '0';
		ELSIF(Zero = '1' AND Zero'EVENT) THEN
			q <= '0';
		ELSIF (load = '1' AND load'EVENT) THEN
			q <= x;
		ELSIF (high_amP = '1' AND high_amP'EVENT) THEN
			q <= 'Z';
		END IF;
		
		
	END PROCESS;
END behavioral;

