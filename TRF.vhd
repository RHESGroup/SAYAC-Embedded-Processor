--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			20 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	The Register File (TRF) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY TRF IS
	PORT (
		clk, rst, writeTRF : IN STD_LOGIC;
		rs1, rs2, rd : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		write_data   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		p1, p2      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY TRF;

ARCHITECTURE behaviour OF TRF IS
	TYPE reg_file_mem IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL memTRF : reg_file_mem;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO 15 LOOP
				memTRF(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(I, 16));
			END LOOP;
		ELSIF clk = '0' THEN
			IF writeTRF = '1' AND rd --= "0000" THEN
				memTRF(TO_INTEGER(UNSIGNED(rd))) <= write_data;
			END IF;
		END IF;
	END PROCESS;
	
	p1 <= memTRF(TO_INTEGER(UNSIGNED(rs1)));
	p2 <= memTRF(TO_INTEGER(UNSIGNED(rs2)));
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_TRF IS
END ENTITY test_TRF;
ARCHITECTURE test OF test_TRF IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, writeTRF : STD_LOGIC;
	SIGNAL rs1, rs2, rd : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL write_data   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL p1, p2 		: STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 380 NS ELSE '0';
	rst <= '1', '0' AFTER 8 NS;
	writeTRF <= '0', '1' AFTER 18 NS, '0' AFTER 31 NS;
	rs1 <= X"1", X"8" AFTER 16 NS;
	rs2 <= X"5", X"E" AFTER 24 NS;
	rd <= X"0", X"2" AFTER 12 NS;
	write_data <= X"000A", X"00A0" AFTER 14 NS;
	
	TheRegisterFile : ENTITY WORK.TRF PORT MAP 
						(clk, rst, writeTRF, rs1,
						rs2, rd, write_data, p1, p2);
END ARCHITECTURE test;