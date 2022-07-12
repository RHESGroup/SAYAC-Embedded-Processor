LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY MUX2 IS
	GENERIC(	len: 	INTEGER := 8);
	PORT (		a0: 	IN STD_LOGIC_VECTOR(len-1 downto 0);
				a1: 	IN STD_LOGIC_VECTOR(len-1 downto 0);
				sel:  	IN STD_LOGIC;
				q: 		OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF MUX2 IS
BEGIN

	q <= a0 WHEN (sel = '0') ELSE a1;		
END behavioral;

