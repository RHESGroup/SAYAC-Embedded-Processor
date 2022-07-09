LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Reg_DREG IS
	GENERIC(	len		: 				INTEGER := 8);
	PORT (		x		: 				IN STD_LOGIC_VECTOR(len-1 downto 0);  
				rst		: 				IN STD_LOGIC;  
				load	: 				IN STD_LOGIC; 
				Zero	: 				IN STD_LOGIC;
				high_amP:				IN STD_LOGIC;
				q		: 				OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF Reg_DREG IS

BEGIN
	PROCESS(rst, load, Zero, high_amP)
	BEGIN
		IF( rst = '1' ) THEN
			q <= "10011011";
		ELSIF(Zero = '1' ) THEN
			q <= (OTHERS => '0');
		ELSIF (load = '1' ) THEN
			q <= x;
		ELSIF (high_amP = '1') THEN
			q <= (OTHERS => 'Z');
		END IF;
		
	END PROCESS;
END behavioral;

