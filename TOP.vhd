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
--	TOP level circuit (TOP) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY TOP IS
	PORT (
		clk, rst : IN STD_LOGIC
	);
END ENTITY TOP;

ARCHITECTURE behaviour OF TOP IS
	SIGNAL opcode : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		   selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF : STD_LOGIC;
    SIGNAL selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF : STD_LOGIC;
	SIGNAL selrd0_TRF, selrd1_TRF, writeTRF : STD_LOGIC;
	SIGNAL selp1_PCP, selimm_PCP : STD_LOGIC;
    SIGNAL selp1_PC, selPCadd_PC, selPC1_PC : STD_LOGIC;
    SIGNAL selPC_MEM, selADR_MEM, driveDataBus : STD_LOGIC;
    SIGNAL SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits : STD_LOGIC;
    SIGNAL selp2_ASU, selimm_ASU, arithADD, arithSUB : STD_LOGIC;
    SIGNAL logicAND, onesComp, twosComp : STD_LOGIC;
    SIGNAL selp2_SHU, selshim_SHU, logicSH, arithSH : STD_LOGIC;
    SIGNAL ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU : STD_LOGIC;
    SIGNAL ldIR, ldADR, ldPC : STD_LOGIC;
    SIGNAL readMEM, writeMEM, readIO, writeIO : STD_LOGIC;
	SIGNAL readyMEM, readyMDU : STD_LOGIC;
BEGIN
	DataPath : ENTITY WORK.TDP PORT MAP 
					(clk, rst,
					seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
					selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
					selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, 
					selrd0_TRF, selrd1_TRF,	writeTRF, selp1_PCP, 
					selimm_PCP, selp1_PC, selPCadd_PC, selPC1_PC, selPC_MEM, 
					selADR_MEM, driveDataBus, SE5bits, SE6bits, USE8bits, 
					SE8bits, p1lowbits, selp2_ASU, selimm_ASU, arithADD, 
					arithSUB, logicAND, onesComp, twosComp, selp2_SHU, 
					selshim_SHU, logicSH, arithSH, ldMDU1, ldMDU2,	arithMUL, 
					arithDIV, startMDU, ldIR, ldADR, ldPC, readMEM, writeMEM, 
					readIO, writeIO, readyMEM, readyMDU, opcode);
	Controller : ENTITY WORK.CTRL PORT MAP 
					(clk, rst, readyMEM, readyMDU, opcode,
					seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
					selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
					selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, 
					selrd0_TRF, selrd1_TRF, writeTRF, selp1_PCP, 
					selimm_PCP, selp1_PC, selPCadd_PC, selPC1_PC,	
					selPC_MEM, selADR_MEM, driveDataBus, SE5bits, SE6bits, 
					USE8bits, SE8bits, p1lowbits, selp2_ASU, selimm_ASU, 
					arithADD, arithSUB, logicAND, onesComp, twosComp, 
					selp2_SHU, selshim_SHU, logicSH, arithSH, ldMDU1, 
					ldMDU2,	arithMUL, arithDIV, startMDU, ldIR, ldADR,
					ldPC, readMEM, writeMEM, readIO, writeIO);
END ARCHITECTURE behaviour;