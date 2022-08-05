LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
	
ENTITY nor_n IS
	PORT (
		in1 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1   : OUT STD_LOGIC);
END ENTITY nor_n;

ARCHITECTURE behaviour OF nor_n IS
BEGIN
	out1 <= in1(0) NOR in1(1);
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nand_n IS
	PORT (
		in1 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1   : OUT STD_LOGIC);
END ENTITY nand_n;

ARCHITECTURE behaviour OF nand_n IS
BEGIN
	out1 <= in1(0) NAND in1(1);
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY notg IS
	PORT (
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
END ENTITY notg;

ARCHITECTURE behaviour OF notg IS
BEGIN
	out1 <= NOT in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pin IS
	PORT (
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
END ENTITY pin;

ARCHITECTURE behaviour OF pin IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pout IS
	PORT (
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
END ENTITY pout;

ARCHITECTURE behaviour OF pout IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY dff IS
	PORT (
		D, C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
END ENTITY dff;

ARCHITECTURE behaviour OF dff IS
	SIGNAL tmp : STD_LOGIC;
BEGIN
	PROCESS (C, PRE, CLR, global_reset)
	BEGIN
		IF (CLR = '1' OR global_reset = '1') THEN
			tmp <= '0';
		ELSIF (PRE = '1' AND PRE'EVENT) THEN
			tmp <= '1';
		ELSIF (C = '1' AND C'EVENT) THEN
			IF NbarT = '1' THEN
				tmp <= Si;
			ELSIF CE = '1' THEN
				tmp <= D;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (tmp)
	BEGIN
		IF (tmp = '1' AND tmp'EVENT) THEN
			Q <= tmp;
		ELSIF (tmp = '0' AND tmp'EVENT) THEN
			Q <= tmp;
		END IF;
	END PROCESS;
	
END ARCHITECTURE behaviour;