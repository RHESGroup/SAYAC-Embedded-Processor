--******************************************************************************
--	Filename:		SAYAC_TRF.vhd
--	Project:		SAYAC	:	Simple ARCHITECTURE	Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			13 May 2022
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University	OF	Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement	IS not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	The Register File (TRF)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	IFF	IS
	PORT	(	clk			:	IN	STD_LOGIC;
				rst			:	IN	STD_LOGIC;
				enFlag		:	IN	STD_LOGIC;
				setFlags	:	IN	STD_LOGIC;
				selFlag 	:	IN	STD_LOGIC;
				inFlag  	:	IN	STD_LOGIC;
				outFlag 	:	OUT	STD_LOGIC	);
END	ENTITY	IFF;

ARCHITECTURE	behavior	OF	IFF	IS
	SIGNAL	outFlag_FF	:	STD_LOGIC;
	SIGNAL	inFlag_FF	:	STD_LOGIC;
BEGIN
	inFlag_FF	<=	outFlag_FF	WHEN	(selFlag OR setFlags) = '0'	ELSE inFlag;
	
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			outFlag_FF	<=	'0';
		ELSIF	clk = '1' AND clk'EVENT	THEN
			IF	enFlag = '1'	THEN
				outFlag_FF	<=	inFlag_FF;
			END	IF;
		END	IF;
	END	PROCESS;
	
	outFlag	<=	outFlag_FF;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	TRF	IS
	PORT	(	clk				:	IN	STD_LOGIC;
				rst				:	IN	STD_LOGIC;
				writeTRF		:	IN	STD_LOGIC;
				setFlags		:	IN	STD_LOGIC;
				enFlag			:	IN	STD_LOGIC;
				readstatusTRF	:	IN	STD_LOGIC;
				writestatusTRF	:	IN	STD_LOGIC;
				rs1				:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				rs2				:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				rd				:	IN	STD_LOGIC_VECTOR(3	DOWNTO	0);
				selFlag			:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				inFlag			:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				R15_LSB			:	OUT	STD_LOGIC_VECTOR(7	DOWNTO	0);
				write_data		:	IN	STD_LOGIC_VECTOR(15	DOWNTO	0);
				p1				:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0);
				p2				:	OUT	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	TRF;

ARCHITECTURE	behavior	OF	TRF	IS
	TYPE	reg_file_mem	IS ARRAY (0	TO	15)	OF	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	memTRF 	  	:	reg_file_mem;
	SIGNAL	outFlag_reg	:	STD_LOGIC_VECTOR(7	DOWNTO	0);
	SIGNAL	selFlag_reg	:	STD_LOGIC_VECTOR(7	DOWNTO	0);
	SIGNAL	R15			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN
	PROCESS	(	clk, rst	)
	BEGIN
		IF	rst = '1'	THEN
			memTRF(15)	<=	(OTHERS => '0');
			
			FOR	I	IN	0	TO	14	LOOP
				memTRF(I)	<=	STD_LOGIC_VECTOR(TO_UNSIGNED(I, 16));
			END	LOOP;
		ELSIF	clk = '0' AND clk'EVENT 	THEN
			IF	writeTRF = '1' AND rd /= "0000"	THEN
				memTRF(TO_INTEGER(UNSIGNED(rd)))	<=	write_data;
			END	IF;
			IF		writestatusTRF = '1'	THEN 
				memTRF(15)	<=	write_data;
			ELSIF	selFlag_reg /= "00000000"	THEN
				memTRF(15)	<=	R15;
			END	IF;
			-- FOR	I	IN	0	TO	7	LOOP
			-- --	IF	(outFlag_reg XOR R15(7	DOWNTO	0)) /= "00000000" AND selFlag(I) = '1'	THEN
				-- IF	(outFlag_reg(I) XOR R15(I)) = '1' AND selFlag(I) = '1'	THEN
					-- memTRF(15)(I)	<=	outFlag_reg(I);
				-- END	IF;
			-- END	LOOP;
		END	IF;
	END	PROCESS;
	
	PROCESS	(	clk, rst	)
	BEGIN
		IF	rst = '1'	THEN
			selFlag_reg	<=	(OTHERS => '0');
		ELSIF	clk = '1' AND clk'EVENT 	THEN
			IF	enFlag = '1'	THEN
				selFlag_reg	<=	selFlag;
			END	IF;
		END	IF;
	END	PROCESS;
	
	p1	<=	R15									WHEN	rs1 = "1111" OR readstatusTRF  = '1'	ELSE
			memTRF(TO_INTEGER(UNSIGNED(rs1)));
	p2	<=	memTRF(TO_INTEGER(UNSIGNED(rs2)))	WHEN	rs2 /= "1111"							ELSE 
			R15;
	
	-- Flags = R15(7	DOWNTO	0)
	FlagsFF:	FOR	I	IN	0	TO	7	GENERATE
				FF_bitI:	ENTITY	WORK.IFF
								PORT	MAP(	clk, 
												rst, 
												enFlag, 
												setFlags, 
												selFlag(I), 
												inFlag(I), 
												outFlag_reg(I)	);
	END	GENERATE;
	
--	PROCESS	(	memTRF(15), outFlag_reg, selFlag	)
	PROCESS	(	memTRF(15), outFlag_reg, selFlag_reg	)
	BEGIN
		FOR	I	IN	0	TO	7	LOOP
		--	IF	(outFlag_reg XOR R15(7	DOWNTO	0)) = "00000000" OR selFlag(I) = '0'	THEN
			IF	(outFlag_reg(I) XOR R15(I)) = '0' OR selFlag_reg(I) = '0'	THEN
		--	IF	selFlag_reg(I) = '0'	THEN
				R15(I)	<=	memTRF(15)(I);
			ELSE 
				R15(I)	<=	outFlag_reg(I);
			END	IF;
		END	LOOP;
		
		R15(15	DOWNTO	8)	<=	memTRF(15)(15	DOWNTO	8);
	END	PROCESS;
	
	R15_LSB	<=	R15(7	DOWNTO	0);
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
