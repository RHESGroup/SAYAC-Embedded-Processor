LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Counter IS
	GENERIC( len	: 	INTEGER := 8);
	PORT (	 
			 clk	: 	IN STD_LOGIC;
			 rst	: 	IN STD_LOGIC;
			 load	: 	IN STD_LOGIC;
			 inc	: 	IN STD_LOGIC;
			 q		: 	OUT INTEGER range 0 to len);
END ENTITY;

ARCHITECTURE behavioral OF Counter IS

SIGNAL temp 		: INTEGER range 0 to len := 0;

BEGIN

	PROCESS(clk)
	BEGIN
		IF( clk = '1' and clk 'EVENT)THEN
			IF( rst = '1' ) THEN
				temp <= 0;
			ELSIF (load = '1') THEN
				temp <= 0;
			ELSIF (inc = '1') THEN
				temp <= temp + 1;		
			END IF;
		END IF;
		
	END PROCESS;
	q 	<= temp;
	
END behavioral;
