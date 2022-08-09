LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg_1BIT IS
	PORT (		x		: 				IN STD_LOGIC; 
				clk		: 				IN STD_LOGIC; 
				rst		: 				IN STD_LOGIC;
				Zero	: 				IN STD_LOGIC;				
				load	: 				IN STD_LOGIC; 
				q		: 				OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE behavioral OF Reg_1BIT IS

BEGIN
	PROCESS(clk)
	BEGIN
		IF( clk = '1' and clk 'EVENT)THEN
			IF( rst = '1' ) THEN
				q <= '0';
			ELSIF(Zero = '1') THEN
				q <= '0';
			ELSIF (load = '1') THEN
				q <= x;
			END IF;
		END IF;
		
	END PROCESS;
END behavioral;

