--******************************************************************************
--	Filename:		SAYAC_DPU.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			18 June 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	DataPath Unit (DPU) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY DPU IS
	PORT (
		clk, rst : IN STD_LOGIC;
		seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
        selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF,
		selrd1_TRF, writeTRF, selp1_PCP, selimm_PCP, 
        selp1_PC, selPCadd_PC, selPC1_PC, selPC_MEM, selADR_MEM,
        driveDataBus, SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits,
        selp2_ASU, selimm_ASU, arithADD, arithSUB,
        logicAND, onesComp, twosComp,
        selp2_SHU, selshim_SHU, logicSH, arithSH,
        ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU,
        ldIR, ldADR, ldPC : IN STD_LOGIC;
		readyMDU : OUT STD_LOGIC;
		opcode  : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIB	    : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
		setFlags, enFlag : IN STD_LOGIC;
		selFlag : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		outFlag : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		dataBus : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		addrBus : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY DPU;

ARCHITECTURE behaviour OF DPU IS
	SIGNAL inDataTRF, p1, p2  			  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMDU1, outMDU2, outASU       : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outLLU, outSHU, outPC1, outIMM : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Instruction   				  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outPCP, outPC, outADR 	      : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMuxPCP, outMuxPC, outMuxASU : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMuxSHU 				      : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL outrd1, rs1, rs2, rd           : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL outMuxrs1, outMuxrs2, outMuxrd : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inFlag						  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL gt, eq : STD_LOGIC;
BEGIN
	rs1 <= Instruction(7 DOWNTO 4);
	rs2 <= Instruction(11 DOWNTO 8);
	rd  <= Instruction(3 DOWNTO 0);

	dataBus <= (OTHERS => 'Z') WHEN driveDataBus = '0' ELSE p1;
	
	-- rd1 : ENTITY WORK.ADD GENERIC MAP ( 4 )
			-- PORT MAP (rd, "0001", outrd1);
	rd1 : ENTITY WORK.INC GENERIC MAP ( 4 )
			PORT MAP (rd, outrd1);
		
	muxrd : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 4 )
				PORT MAP (rd, outrd1, selrd0_TRF, selrd1_TRF, outMuxrd);
		
	muxrs1 : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 4 )
				PORT MAP (rs1, rd, selrs1_TRF, selrd_1_TRF, outMuxrs1);
				  
	muxrs2 : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 4 )
				PORT MAP (rs2, rd, selrs2_TRF, selrd_2_TRF, outMuxrs2);
		
	muxinDataTRF : ENTITY WORK.MUX8of16bits PORT MAP 
						(outIMM, outMDU1, outMDU2, outASU, outLLU, outSHU, 
						dataBus, outPC1, selIMM_TRF, selMDU1_TRF, selMDU2_TRF, 
						selASU_TRF,	selLLU_TRF, selSHU_TRF, seldataBus_TRF, 
						selPC1_TRF,	inDataTRF);
						
	TheRegisterFile : ENTITY WORK.TRF PORT MAP 
						(clk, rst, writeTRF, setFlags, enFlag, outMuxrs1, 
						outMuxrs2, outMuxrd, selFlag, inFlag, outFlag, 
						inDataTRF, p1, p2);
	
	opcode <= Instruction(15 DOWNTO 8);
	FIB    <= Instruction(8 DOWNTO 4);
--	inFlag <= (i & x & gt & eq & i_en & x_en & i_mask & x_mask);
	inFlag <= ('0' & '0' & gt & eq & '0' & '0' & '0' & '0');
	
	IR : ENTITY WORK.REG PORT MAP 
			(clk, rst, ldIR, dataBus, Instruction);
	
	ImmediateUnit : ENTITY WORK.IMM PORT MAP 
						(Instruction(11 DOWNTO 4), p1(7 DOWNTO 0), SE5bits, SE6bits,
						USE8bits, SE8bits, p1lowbits, outIMM);
	
	muxPCP : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 16 )
				PORT MAP (p1, outIMM, selp1_PCP, selimm_PCP, outMuxPCP);
	
	PCP : ENTITY WORK.ADD GENERIC MAP ( 16 )
				PORT MAP (outMuxPCP, outPC, outPCP);
	
	muxPC : ENTITY WORK.MUX3of16bits PORT MAP 
				(p1, outPCP, outPC1, selp1_PC, selPCAdd_PC, 
				selPC1_PC, outMuxPC);
	
	PC : ENTITY WORK.REG PORT MAP 
			(clk, rst, ldPC, outMuxPC, outPC);
	
--	PC1 : ENTITY WORK.ADD GENERIC MAP ( 16 )
--			PORT MAP (outPC, X"0001", outPC1);
	PC1 : ENTITY WORK.INC GENERIC MAP ( 16 )
			PORT MAP (outPC, outPC1);
	
	ADR : ENTITY WORK.REG PORT MAP 
			(clk, rst, ldADR, outMuxPCP, outADR);
	
	muxMEM : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 16 )
				PORT MAP (outADR, outPC, selADR_MEM, selPC_MEM, addrBus);
	
	
	MultDivUnit : ENTITY WORK.MDU PORT MAP 
					(clk, rst, startMDU, arithMUL, arithDIV, ldMDU1, ldMDU2, p1, p2,
					outMDU1, outMDU2, readyMDU);
	
	muxASU : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 16 )
				PORT MAP (p2, outIMM, selp2_ASU, selimm_ASU, outMuxASU);
	
	ComparatorUnit : ENTITY WORK.CMP PORT MAP 
						(p1, outMuxASU, eq, gt);
	
	AddSubUnit : ENTITY WORK.ASU PORT MAP 
					(p1, outMuxASU, arithADD, arithSUB, outASU);
	
	LogicLogicUnit : ENTITY WORK.LLU PORT MAP 
						(p1, outMuxASU, logicAND, onesComp, twosComp, outLLU);
	
	
	muxSHU : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 5 )
		PORT MAP (p2(4 DOWNTO 0), Instruction(8 DOWNTO 4), selp2_SHU, 
				 selshim_SHU, outMuxSHU);
	
	ShiftUnit : ENTITY WORK.SHU PORT MAP 
					(p1, outMuxSHU, logicSH, arithSH, outSHU);
END ARCHITECTURE behaviour;