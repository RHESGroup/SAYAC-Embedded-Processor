--******************************************************************************
--	Filename:		SAYAC_DPU.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
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
--	DataPath Unit (DPU) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY DPU IS
	PORT (
		clk, rst       : IN STD_LOGIC;
		seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
        selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF,
		selrd1_TRF, writeTRF, selp1_PCP, selimm_PCP, 
        selp1_PC, selPCadd_PC, selPC1_PC, selPC_addrBus, selADR_addrBus,
        driveDataBus, SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits,
        selp2_ASU, selimm_ASU, arithADD, arithSUB,
        logicAND, onesComp, twosComp,
        selp2_SHU, selshim_SHU, logicSH, arithSH,
        ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU,
        ldIR, ldADR, ldPC,
        readstatusTRF, writestatusTRF, writeTRB, USE12bits, selPC_PCP, selTRB_PCP,
		sel1_ADR, selPCP_ADR, seldataBus_PC, selp1_dataBus, 
		selPC_dataBus, selPC1_dataBus, readIHBAddr, readTopStackAddr, selrs1_imm, 
        selcnt_imm, rst_cnt, inc_cnt, IntEnable, IntServicing, selTRB_ADR,
		selPCP_addrBus, selESA_PC, ldExcBaseAddr, readExcBaseAddr, readExcOffAddr, 
		ExcEnable, ExcServicing, 
		InvalidInst    : IN    STD_LOGIC;
		Exception      : OUT   STD_LOGIC;
		readyMDU       : OUT   STD_LOGIC;
		opcode         : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIB	           : OUT   STD_LOGIC_VECTOR(4 DOWNTO 0);
		setFlags       : IN    STD_LOGIC;
		enFlag         : IN    STD_LOGIC;
		selFlag        : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
		R15_LSB        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
		dataBus        : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		addrBus        : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY DPU;

ARCHITECTURE behavior OF DPU IS
	SIGNAL inDataTRF, p1, p2  			  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMDU1, outMDU2, outASU       : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outLLU, outSHU, outPC1, outIMM : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Instruction, outMuxASU   	  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outPCP, outPC, outADR 	      : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMux1PCP, outMuxPC           : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMuxSHU 				      : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL outMuxrs1, outMuxrs2, outMuxrd : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inFlag						  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL write_data, read_data          : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMUXdataBus                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL gt, eq, DividedByZero   		  : STD_LOGIC;
	SIGNAL read_addr         			  : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inADR, outMux2PCP, ESA  		  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outrd1, outCNT      			  : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL ExcSrcNum           			  : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	ALIAS rs1		           			  : STD_LOGIC_VECTOR(3 DOWNTO 0) IS Instruction(7 DOWNTO 4);
	ALIAS rs2		           			  : STD_LOGIC_VECTOR(3 DOWNTO 0) IS Instruction(11 DOWNTO 8);
	ALIAS rd		           			  : STD_LOGIC_VECTOR(3 DOWNTO 0) IS Instruction(3 DOWNTO 0);
	ALIAS ExcOffAddr           			  : STD_LOGIC_VECTOR(4 DOWNTO 0) IS read_data(4 DOWNTO 0);
BEGIN
	muxdataBus : ENTITY WORK.MUX3of16bits GENERIC MAP ( 16 )
					PORT MAP (p1, outPC, outPC1, selp1_dataBus, selPC_dataBus, selPC1_dataBus, outMuxdataBus);

	dataBus <= (OTHERS => 'Z') WHEN driveDataBus = '0' ELSE outMuxdataBus;
	
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
						(clk, rst, writeTRF, setFlags, enFlag, readstatusTRF, writestatusTRF,
						outMuxrs1, outMuxrs2, outMuxrd, selFlag, inFlag, R15_LSB, 
						inDataTRF, p1, p2);
	
	ExceptionAddrGen: ENTITY WORK.EAG PORT MAP
						(clk, rst, ldExcBaseAddr, ExcSrcNum, read_data, ExcOffAddr, ESA);
	
	ExceptionSourceRegister: ENTITY WORK.ESR PORT MAP
			(clk, rst, DividedByZero, InvalidInst, ExcSrcNum, Exception);
	
    TheRegisterBank : ENTITY WORK.TRB PORT  MAP
						(clk, rst, writeTRB, 
						 readExcBaseAddr, readExcOffAddr, readIHBAddr, readTopStackAddr,
						 rd, dataBus, read_data);

    Counter : ENTITY WORK.CNT PORT MAP
                    (clk, rst, rst_cnt, inc_cnt, outCNT);
	
	opcode    <= Instruction(15 DOWNTO 8);
	FIB       <= Instruction(8 DOWNTO 4);
--	inFlag    <= (i & x & gt & eq & i_en & x_en & i_mask & x_mask); 
	inFlag    <= (IntServicing & ExcServicing & gt & eq & ExcEnable & '0' & '0' & IntEnable);
	
	IR : ENTITY WORK.REG PORT MAP 
			(clk, rst, ldIR, dataBus, Instruction);
	
	ImmediateUnit : ENTITY WORK.IMM PORT MAP 
						(Instruction(11 DOWNTO 4), p1(7 DOWNTO 0), outCNT, SE5bits, SE6bits,
						USE8bits, SE8bits, p1lowbits, selrs1_imm,  selcnt_imm, USE12bits, outIMM);
	
	mux1PCP : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 16 )
				PORT MAP (p1, outIMM, selp1_PCP, selimm_PCP, outMux1PCP);
	
	mux2PCP : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 16 )
				PORT MAP (read_data, outPC, selTRB_PCP, selPC_PCP, outMux2PCP);

	PCP : ENTITY WORK.ADD GENERIC MAP ( 16 )
				PORT MAP (outMux1PCP, outMux2PCP, outPCP);
	
	muxPC : ENTITY WORK.MUX5of16bits PORT MAP 
				(p1, outPCP, ESA, dataBus, outPC1, selp1_PC, selPCAdd_PC, 
				 selESA_PC, seldataBus_PC, selPC1_PC, outMuxPC);
	
	PC : ENTITY WORK.REG PORT MAP 
			(clk, rst, ldPC, outMuxPC, outPC);
	
	PC1 : ENTITY WORK.INC GENERIC MAP ( 16 )
			PORT MAP (outPC, outPC1);
	
	muxADR : ENTITY WORK.MUX3of16bits GENERIC MAP ( 16 )
				PORT MAP (outMux1PCP, outPCP, read_data, sel1_ADR, selPCP_ADR, selTRB_ADR, inADR);

	ADR : ENTITY WORK.REG PORT MAP 
			(clk, rst, ldADR, inADR, outADR);
	
	muxaddrBus : ENTITY WORK.MUX3of16bits PORT MAP
					(outADR, outPC, outPCP, selADR_addrBus, selPC_addrBus, selPCP_addrBus, addrBus);
	
	MultDivUnit : ENTITY WORK.MDU PORT MAP 
--					(clk, rst, startMDU, arithMUL, arithDIV, signMDU, ldMDU1, ldMDU2, 
					(clk, rst, startMDU, arithMUL, arithDIV, '0', ldMDU1, ldMDU2, 
					p1, p2,	outMDU1, outMDU2, DividedByZero, readyMDU);
	
	muxASU : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 16 )
				PORT MAP (p2, outIMM, selp2_ASU, selimm_ASU, outMuxASU);
	
	ComparatorUnit : ENTITY WORK.CMP PORT MAP 
--						(p1, outMuxASU, signCMP, eq, gt);
						(p1, outMuxASU, '0', eq, gt);
	
	AddSubUnit : ENTITY WORK.ASU PORT MAP 
					(p1, outMuxASU, arithADD, arithSUB, outASU);
	
	LogicLogicUnit : ENTITY WORK.LLU PORT MAP 
						(p1, outMuxASU, logicAND, onesComp, twosComp, outLLU);
	
	
	muxSHU : ENTITY WORK.MUX2ofnbits GENERIC MAP ( 5 )
				PORT MAP (p2(4 DOWNTO 0), Instruction(8 DOWNTO 4), selp2_SHU, 
						 selshim_SHU, outMuxSHU);
	
	ShiftUnit : ENTITY WORK.SHU PORT MAP 
					(p1, outMuxSHU, logicSH, arithSH, outSHU);
END ARCHITECTURE behavior;