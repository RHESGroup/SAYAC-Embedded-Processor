LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY MUX3 IS
	GENERIC(	len		: 	INTEGER := 8);
	PORT (		a0		: 	IN STD_LOGIC_VECTOR(len-1 downto 0);
				a1		: 	IN STD_LOGIC_VECTOR(len-1 downto 0);
				a2		: 	IN STD_LOGIC_VECTOR(len-1 downto 0);
				sel		:  	IN STD_LOGIC_VECTOR(1 downto 0);
				q		: 	OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF MUX3 IS
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
				q <= (others => 'Z'); 
		END CASE;
		
	END PROCESS;
END behavioral;

