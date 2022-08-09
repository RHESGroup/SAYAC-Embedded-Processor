LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY READ_WRITE IS
	PORT (		RD			: 				IN STD_LOGIC; 
				WR			: 				IN STD_LOGIC; 
				A0			: 				IN STD_LOGIC;  
				A1			: 				IN STD_LOGIC; 
				CS			: 				IN STD_LOGIC;
				ReadSignal	: 				OUT STD_LOGIC_VECTOR(3 downto 0);
				WriteSignal	: 				OUT STD_LOGIC_VECTOR(3 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF READ_WRITE IS

BEGIN
READSIGNAL_SETTING:PROCESS (A0, A1, CS, RD, WR)
BEGIN
	IF CS = '0' THEN

		IF (A1='0' AND A0='0' AND RD='0' AND WR='1') THEN
			ReadSignal <= "0001";
		ELSIF (A1='0' AND A0='1' AND RD='0' AND WR='1')	THEN
			ReadSignal <= "0010";
		ELSIF (A1='1' AND A0='0' AND RD='0' AND WR='1')	THEN
			ReadSignal <= "0100";
		ELSE ReadSignal <= (OTHERS => '0');
		END IF;
	END IF;
END PROCESS READSIGNAL_SETTING;

WRITESIGNAL_SETTING:PROCESS (A0, A1, CS, RD, WR)
BEGIN
	IF CS = '0' THEN

		IF (A1='0' AND A0='0' AND RD='1' AND WR='0') THEN
			WriteSignal <= "0001";
		ELSIF (A1='0' AND A0='1' AND RD='1' AND WR='0')	THEN
			WriteSignal <= "0010";
		ELSIF (A1='1' AND A0='0' AND RD='1' AND WR='0')	THEN
			WriteSignal <= "0100"; 
		ELSIF (A1='1' AND A0='1' AND RD='1' AND WR='0')	THEN
			WriteSignal <= "1000";
		ELSE WriteSignal <= (OTHERS => '0');
		END IF;
	END IF;
	
END PROCESS WRITESIGNAL_SETTING;

END behavioral;

