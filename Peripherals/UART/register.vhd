LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg IS
	GENERIC(	len		: 				INTEGER := 8);
	PORT (		x		: 				IN STD_LOGIC_VECTOR(len-1 downto 0);  
				rst		: 				IN STD_LOGIC;  
				load	: 				IN STD_LOGIC; 
				Zero	: 				IN STD_LOGIC;
				high_amP:				IN STD_LOGIC;
				q		: 				OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF Reg IS

BEGIN
	PROCESS(rst, load, Zero, high_amP, x)
	BEGIN
	
			
		IF( rst = '1' AND rst'EVENT) THEN
			q <= (OTHERS => '0');
		ELSIF ((load = '1' AND load'EVENT) OR (load = '0' AND load'EVENT)) THEN
			q <= x;	
		ELSIF(Zero = '1' AND Zero'EVENT) THEN
			q <= (OTHERS => '0');
		
		ELSIF (high_amP = '1' AND high_amP'EVENT) THEN
			q <= (OTHERS => 'Z');
		END IF;
		
	END PROCESS;
END behavioral;

