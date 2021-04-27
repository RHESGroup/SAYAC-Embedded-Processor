--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			26 April 2021
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
		setFlags, enFlag : IN STD_LOGIC;
		rs1, rs2, rd    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		selFlag, inFlag : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		outFlag        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		write_data      : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		p1, p2         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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
		ELSIF clk = '0' AND clk'EVENT  THEN
			IF writeTRF = '1' AND rd /= "0000" THEN
				memTRF(TO_INTEGER(UNSIGNED(rd))) <= write_data;
			END IF;
		END IF;
	END PROCESS;
	
	p1 <= memTRF(TO_INTEGER(UNSIGNED(rs1)));
	p2 <= memTRF(TO_INTEGER(UNSIGNED(rs2)));
	
	-- Flags = r15(7 DOWNTO 0)
	FlagsFF : FOR I IN 0 TO 7 GENERATE
				FF_bitI : ENTITY WORK.IFF
					PORT MAP (clk, rst, enFlag, setFlags, 
							 selFlag(I), inFlag(I), outFLag(I));
	END GENERATE;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY IFF IS
	PORT (
		clk, rst, enFlag, setFlags : IN STD_LOGIC;
		selFlag  : IN STD_LOGIC;
		inFlag   : IN STD_LOGIC;
		outFLag  : OUT STD_LOGIC
	);
END ENTITY IFF;

ARCHITECTURE behaviour OF IFF IS
	SIGNAL outFlag_FF, inFlag_FF : STD_LOGIC;
BEGIN
	inFlag_FF <= outFlag_FF WHEN (selFlag OR setFlags) = '0' ELSE inFlag;
	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			outFlag_FF <= '0';
		ELSIF clk = '1' AND clk'EVENT THEN
			IF enFlag = '1' THEN
				outFlag_FF <= inFlag_FF;
			END IF;
		END IF;
	END PROCESS;
	
	outFLag <= outFlag_FF;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_TRF IS
END ENTITY test_TRF;
ARCHITECTURE test OF test_TRF IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, writeTRF : STD_LOGIC;
	SIGNAL setFlags, enFlag : STD_LOGIC;
	SIGNAL rs1, rs2, rd    : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL selFlag, inFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL outFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL write_data      : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL p1, p2 		   : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 380 NS ELSE '0';
	rst <= '1', '0' AFTER 2 NS;
	writeTRF <= '0', '1' AFTER 18 NS, '0' AFTER 31 NS;
	setFlags <= '0', '1' AFTER 3 NS, '0' AFTER 7 NS;
	enFlag <= '0', '1' AFTER 4 NS;
	rs1 <= X"1", X"8" AFTER 16 NS;
	rs2 <= X"5", X"E" AFTER 24 NS;
	rd <= X"0", X"2" AFTER 12 NS;
	selFlag <= X"00", X"08" AFTER 9 NS, X"16" AFTER 12 NS, X"04" AFTER 19 NS;
	inFlag <= X"00", X"02" AFTER 3 NS, X"FA" AFTER 13 NS, X"F5" AFTER 17 NS;
	write_data <= X"000A", X"00A0" AFTER 14 NS;
	
	TheRegisterFile : ENTITY WORK.TRF PORT MAP 
						(clk, rst, writeTRF, setFlags, enFlag, rs1, rs2, rd,
						selFlag, inFlag, outFlag, write_data, p1, p2);
END ARCHITECTURE test;