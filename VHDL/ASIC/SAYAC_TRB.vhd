--******************************************************************************
--	Filename:		SAYAC_TRB.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			13 May 2022
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	The Register Bank (TRB) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY TRB IS
	PORT (
		clk, rst, writeTRB : IN STD_LOGIC;
		readExcBaseAddr    : IN STD_LOGIC;
		readExcOffAddr     : IN STD_LOGIC;
		readIHBAddr        : IN STD_LOGIC;
		readTopStackAddr   : IN STD_LOGIC;
		rw_addr  		   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		write_data		   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		read_data  		   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY TRB;

ARCHITECTURE behavior OF TRB IS
	TYPE reg_file_mem IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL memTRB 	   : reg_file_mem;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO 15 LOOP
				memTRB(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(I, 16));
			END LOOP;
		ELSIF clk = '0' AND clk'EVENT  THEN
			IF writeTRB = '1' THEN
				memTRB(TO_INTEGER(UNSIGNED(rw_addr))) <= write_data;
			END IF;
		END IF;
	END PROCESS;
	
	read_data <= memTRB(3) WHEN readTopStackAddr = '1' ELSE
				 memTRB(5) WHEN readIHBAddr = '1' ELSE
				 memTRB(6) WHEN readExcBaseAddr = '1' ELSE
				 memTRB(7) WHEN readExcOffAddr = '1' ELSE
				 memTRB(TO_INTEGER(UNSIGNED(rw_addr)));
END ARCHITECTURE behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_TRB IS
END ENTITY test_TRB;
ARCHITECTURE test OF test_TRB IS
	SIGNAL clk              : STD_LOGIC := '0';
	SIGNAL rst, writeTRB    : STD_LOGIC;
	SIGNAL readExcBaseAddr  : STD_LOGIC;
	SIGNAL readExcOffAddr   : STD_LOGIC;
	SIGNAL readIHBAddr      : STD_LOGIC;
	SIGNAL readTopStackAddr : STD_LOGIC;
	SIGNAL rw_addr          : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL write_data       : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL read_data	    : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN	
	clk              <= NOT clk AFTER 5 NS WHEN NOW <= 380 NS ELSE '0';
	rst 			 <= '1', '0' AFTER 2 NS;
	writeTRB 		 <= '0', '1' AFTER 18 NS, '0' AFTER 31 NS;
	readIHBAddr		 <= '0', '1' AFTER 22 NS, '0' AFTER 28 NS;
	readTopStackAddr <= '0', '1' AFTER 15 NS, '0' AFTER 19 NS;
	rw_addr          <= X"0", X"2" AFTER 12 NS;
	write_data       <= X"000A", X"00A0" AFTER 14 NS;
	
	TheRegisterFile : ENTITY WORK.TRB PORT MAP 
						(clk, rst, writeTRB, readExcBaseAddr, readExcOffAddr, 
						 readIHBAddr, readTopStackAddr,
						 rw_addr, write_data, read_data);
END ARCHITECTURE test;