--******************************************************************************
--	Filename:		SAYAC_instruction_ROM.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			27 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	instruction ROM (inst_ROM) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
	
ENTITY inst_ROM IS
	GENERIC (
		numofinst : INTEGER := 36
	);
	PORT (
		clk, rst, readInst : IN STD_LOGIC;
		addrInst : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		Inst    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   
	);
END ENTITY inst_ROM;

ARCHITECTURE behaviour OF inst_ROM IS
	TYPE inst_mem IS ARRAY (0 TO numofinst-1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL instMEM : inst_mem;
	
	IMPURE FUNCTION InitRomFromFile 
	RETURN inst_mem IS
		FILE RomFile : TEXT OPEN read_mode IS "inst.txt";
		VARIABLE RomFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE ROM : inst_mem;
	BEGIN	
		REPORT "Status from FILE: '" & FILE_OPEN_STATUS'IMAGE(fstatus) & "'";
		READLINE(RomFile, RomFileLine);
		FOR I IN 0 TO numofinst-1 LOOP
			IF NOT ENDFILE(RomFile) THEN
				READLINE(RomFile, RomFileLine);
				READ(RomFileLine, ROM(I), GOOD);
				REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		
		FILE_close(RomFile);
		RETURN ROM;
	END FUNCTION;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			instMEM <= InitRomFromFile;
		--	Inst <= (OTHERS => '0');
		-- ELSIF clk = '1' AND clk'EVENT THEN
			-- IF readInst = '1' THEN
				-- Inst <= instMEM(TO_INTEGER(UNSIGNED(addrInst)));
			-- ELSE
				-- Inst <= (OTHERS => 'Z');
			-- END IF;
		END IF;
	END PROCESS;
	
	Inst <= instMEM(TO_INTEGER(UNSIGNED(addrInst))) WHEN readInst = '1' ELSE
			(OTHERS => 'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_inst_ROM IS
END ENTITY test_inst_ROM;
ARCHITECTURE test OF test_inst_ROM IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, readInst : STD_LOGIC;
	SIGNAL addrInst : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Inst     : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 380 NS ELSE '0';
	rst <= '1', '0' AFTER 2 NS;
	readInst <= '1', '0' AFTER 25 NS;
	addrInst <= X"0000", X"0001" AFTER 25 NS, X"0002" AFTER 30 NS;
	
	InstructionROM : ENTITY WORK.inst_ROM GENERIC MAP (	3 ) 
						PORT MAP (clk, rst, readInst, addrInst, Inst);
END ARCHITECTURE test;