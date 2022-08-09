--*****************************************************************************/
--	Filename:		CHIP.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			-
--	Authors:	 	Sepideh
--	Last Author: 	Sepideh
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	This implementation used for decreasing the value of the counter in one, two or 
--  three units according to the commands.
    
--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY DOWN_COUNTER IS
	GENERIC(	len					: 	INTEGER := 16);
	PORT (		clk					:	IN STD_LOGIC;
				rst					:	IN STD_LOGIC;
				NUM_IN				: 	IN STD_LOGIC_VECTOR(len-1 downto 0); --input value 
				DOWN_COUNT_BINARY	: 	IN STD_LOGIC;
				DOWN_COUNT_BINARY2	: 	IN STD_LOGIC;
				DOWN_COUNT_BINARY3	: 	IN STD_LOGIC;
				DOWN_COUNT_BCD		: 	IN STD_LOGIC;
				DOWN_COUNT_BCD2		: 	IN STD_LOGIC;
				DOWN_COUNT_BCD3		: 	IN STD_LOGIC;
				LOAD_NUMIN			:	IN STD_LOGIC; --loading inpute value
				MODE				:	IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				NUM_OUT				: 	OUT STD_LOGIC_VECTOR(len-1 downto 0));
END ENTITY;

ARCHITECTURE behavioral OF DOWN_COUNTER IS
SIGNAL CEoutput		:	STD_LOGIC_VECTOR (len-1 downto 0) ; --value of the counter
SIGNAL ODD 			:	STD_LOGIC;
SIGNAL EVEN 		:	STD_LOGIC;
BEGIN

COUNTING: PROCESS (clk, rst)
	BEGIN
	
		IF (rst = '1' AND rst'EVENT) THEN
			NUM_OUT <= (OTHERS => 'Z');
			
		ELSIF (clk = '1' AND clk'EVENT) THEN
		------------------------------------------------------------
		----------------------LOADING-------------------------------
			IF (LOAD_NUMIN = '1') THEN --LOADING
			CEoutput <= NUM_IN;
			END IF;
			IF (CEoutput(0) = '1') THEN
					ODD <= '1';
			ELSE EVEN <= '1';
			END IF;
		------------------------------------------------------------	
			IF ((MODE = "000" OR MODE = "001" OR MODE = "010" OR MODE = "100" OR MODE = "101" OR MODE = "011") AND LOAD_NUMIN = '0') THEN
				IF (DOWN_COUNT_BINARY = '1') THEN
				
						CEoutput <= CEoutput - '1';
							
				ELSIF (DOWN_COUNT_BCD = '1') THEN --decrease one unite

					IF (CEoutput(3 DOWNTO 0) > "0") THEN
						CEoutput(3 DOWNTO 0) <= CEoutput (3 DOWNTO 0)-1;
					ELSIF (CEoutput(3 DOWNTO 0) = "0" AND CEoutput(7 DOWNTO 4) > "0") THEN	
						CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4)-1;
						CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "1001"; 
					
					ELSIF (CEoutput(3 DOWNTO 0) = "0" AND CEoutput(7 DOWNTO 4) = "0" AND CEoutput(11 DOWNTO 8)> "0") THEN
						CEoutput(11 DOWNTO 8) <= CEoutput(11 DOWNTO 8)-1;
						CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4) + "1001";
						CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "1001";
						
					ELSIF (CEoutput(3 DOWNTO 0) = "0" AND CEoutput(7 DOWNTO 4) = "0" AND CEoutput(11 DOWNTO 8) = "0" AND CEoutput(15 DOWNTO 12) > "0") THEN	
						CEoutput(15 DOWNTO 12) <= CEoutput(15 DOWNTO 12) -1;
						CEoutput(11 DOWNTO 8) <= CEoutput(11 DOWNTO 8)+ "1001";
						CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4) + "1001";
						CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "1001";				
					ELSE 
						CEoutput(3 DOWNTO 0) <= "1001";
						CEoutput(7 DOWNTO 4) <= "1001";
						CEoutput(11 DOWNTO 8) <= "1001";
						CEoutput(15 DOWNTO 12) <= "1001";
					
					END IF; --CEoutput(3 DOWNTO 0) > "0"
					
				ELSIF (DOWN_COUNT_BINARY2 = '1') THEN
						CEoutput <= CEoutput - "10";
				ELSIF (DOWN_COUNT_BCD2 = '1') THEN	--decrease two unite
					IF (CEoutput(3 DOWNTO 0) > "1") THEN
                       	CEoutput(3 DOWNTO 0) <= CEoutput (3 DOWNTO 0)-"10";
				    ELSIF (CEoutput(3 DOWNTO 0) < "10" AND CEoutput(7 DOWNTO 4) > "0") THEN	
				    	CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4)-"1";
				    	CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "1000";
				    ELSIF (CEoutput(3 DOWNTO 0) < "10" AND CEoutput(7 DOWNTO 4) = "0" AND CEoutput(11 DOWNTO 8)> "0") THEN
				    	CEoutput(11 DOWNTO 8) <= CEoutput(11 DOWNTO 8)-"1";
				    	CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4) + "1001";
				    	CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "1000";
				    ELSIF (CEoutput(3 DOWNTO 0) < "10" AND CEoutput(7 DOWNTO 4) = "0" AND CEoutput(11 DOWNTO 8)= "0"  AND CEoutput(15 DOWNTO 12) > "0") THEN
				    	CEoutput(15 DOWNTO 12) <= CEoutput(15 DOWNTO 12) -"1";
				    	CEoutput(11 DOWNTO 8) <= CEoutput(11 DOWNTO 8)+ "1001";
				    	CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4) + "1001";
				    	CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "1000";
				    ELSE 
				    	CEoutput(3 DOWNTO 0) <= "1001";
				    	CEoutput(7 DOWNTO 4) <= "1001";
				    	CEoutput(11 DOWNTO 8) <= "1001";
				    	CEoutput(15 DOWNTO 12) <= "1001";
				    
				    END IF; --CEoutput(3 DOWNTO 0) > "1"
					
				ELSIF (DOWN_COUNT_BINARY3 = '1') THEN
					CEoutput <= CEoutput - "11";
				
				ELSIF (DOWN_COUNT_BCD3 = '1') THEN --decrease three unite
					IF (CEoutput(3 DOWNTO 0) > "10") THEN
				    	CEoutput(3 DOWNTO 0) <= CEoutput (3 DOWNTO 0)- "11";
				    ELSIF (CEoutput(3 DOWNTO 0)< "11" AND CEoutput(7 DOWNTO 4) > "0") THEN	
				    	CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4)-1;
				    	CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "111";
				    ELSIF (CEoutput(3 DOWNTO 0) < "11" AND CEoutput(7 DOWNTO 4) = "0" AND CEoutput(11 DOWNTO 8)> "0") THEN
				    	CEoutput(11 DOWNTO 8) <= CEoutput(11 DOWNTO 8)-1;
				    	CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4) + "1001";
				    	CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "111";
				    ELSIF (CEoutput(3 DOWNTO 0) < "11" AND CEoutput(7 DOWNTO 4) = "0" AND CEoutput(11 DOWNTO 8)= "0"  AND CEoutput(15 DOWNTO 12) > "0") THEN
				    	CEoutput(15 DOWNTO 12) <= CEoutput(15 DOWNTO 12) -1;
				    	CEoutput(11 DOWNTO 8) <= CEoutput(11 DOWNTO 8)+ "1001";
				    	CEoutput(7 DOWNTO 4) <= CEoutput(7 DOWNTO 4) + "1001";
				    	CEoutput(3 DOWNTO 0) <= CEoutput(3 DOWNTO 0) + "111";
				    ELSE 
				    	CEoutput(3 DOWNTO 0) <= "1001";
				    	CEoutput(7 DOWNTO 4) <= "1001";
				    	CEoutput(11 DOWNTO 8) <= "1001";
				    	CEoutput(15 DOWNTO 12) <= "1001";
				    
				    END IF; --CEoutput(3 DOWNTO 0) > "10"
				
				END IF;	
						
				END IF;--DOWN_COUNT_BINARY = '1'
			END IF;--MODE = "000" OR MODE = "001" OR MODE = "010"
					
	END PROCESS COUNTING;
	
NUM_OUT <= CEoutput;		
	
END behavioral;

