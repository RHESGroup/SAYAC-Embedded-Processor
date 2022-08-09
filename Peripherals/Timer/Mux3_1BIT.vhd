LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY MUX3_1BIT IS
	PORT (		a0		: 	IN STD_LOGIC;
				a1		: 	IN STD_LOGIC;
				a2		: 	IN STD_LOGIC;
				sel		:  	IN STD_LOGIC_VECTOR(1 downto 0);
				q		: 	OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE behavioral OF MUX3_1BIT IS
BEGIN

	PROCESS (a0, a1, a2, sel)
	BEGIN
		CASE (sel) IS
		
			WHEN "00" =>
				q <= a0;
			WHEN "01" =>
				q <= a1;
			WHEN "10" =>
				q <= a2;
			WHEN OTHERS => 
				q <= 'Z'; 
		END CASE;
		
	END PROCESS;
END behavioral;

