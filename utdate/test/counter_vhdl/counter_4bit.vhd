LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	

ENTITY counter_4bit IS 
	PORT (
		clk, rst, en : IN STD_LOGIC;
		co : OUT STD_LOGIC;
		counter : OUT STD_LOGIC_VECTOR(3 downto 0)
		);
	
END ENTITY counter_4bit;

ARCHITECTURE behavioural OF counter_4bit IS 
	SIGNAL counter_reg : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN 
	counting : PROCESS( clk, rst )
	begin
		IF (rst = '1') THEN
			counter_reg <= "0000";
		ELSIF (clk = '1' AND clk'EVENT) THEN
			IF (en = '1') THEN
				counter_reg <= STD_LOGIC_VECTOR(TO_UNSIGNED((TO_INTEGER(UNSIGNED(counter_reg)) + 1), 4));
			END IF;
		END IF ;		
	END process ; -- counting

	counter <= counter_reg;
	co <= '1' WHEN (counter_reg = "1111") ELSE '0';
END ARCHITECTURE;