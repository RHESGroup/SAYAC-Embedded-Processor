LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg1 IS
	GENERIC(	len		: 				INTEGER := 6);
	PORT (		x		: 				IN STD_LOGIC_VECTOR(len-1 downto 0); 
				clk		: 				IN STD_LOGIC; 
				rst		: 				IN STD_LOGIC;
				load	: 				IN STD_LOGIC; 
				Zero	:				IN STD_LOGIC;
				q		: 				OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF Reg1 IS

BEGIN
	PROCESS(clk)
	BEGIN
		IF( clk = '1' and clk 'EVENT)THEN
			IF( rst = '1' ) THEN
				q <= (OTHERS => '0');
			ELSIF(Zero = '1') THEN
				q <= (OTHERS => '0');
			ELSIF (load = '1') THEN
				q <= x;
			END IF;
		END IF;
		
	END PROCESS;
END behavioral;

