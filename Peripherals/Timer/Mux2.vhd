LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY MUX2 IS
	PORT (		a0	: 	IN STD_LOGIC;
				a1	: 	IN STD_LOGIC;
				sel	:  	IN STD_LOGIC;
				q	: 	OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE behavioral OF MUX2 IS
BEGIN

	q <= a0 WHEN (sel = '0') ELSE a1;		
END behavioral;

