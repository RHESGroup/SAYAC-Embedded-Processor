LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg_UART IS
	GENERIC(	len		: 				INTEGER := 8);
	PORT (		x		: 				IN STD_LOGIC_VECTOR(len-1 downto 0);
				CLK		: 				IN STD_LOGIC;
				rst		: 				IN STD_LOGIC;  
				load	: 				IN STD_LOGIC; 
				Zero	: 				IN STD_LOGIC;
				high_amP:				IN STD_LOGIC;
				q		: 				OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF Reg_UART IS

BEGIN
	PROCESS(CLK, rst)
	BEGIN
		
		IF( rst = '1' AND rst'EVENT) THEN
			q <= (OTHERS => '0');
		ELSIF (CLK = '1' AND CLK'EVENT) THEN	
			IF (load = '1') THEN
				q <= x;	
			ELSIF(Zero = '1') THEN
				q <= (OTHERS => '0');
			ELSIF (high_amP = '1' ) THEN
				q <= (OTHERS => 'Z');
			END IF;	
		END IF;
		
	END PROCESS;
END behavioral;

