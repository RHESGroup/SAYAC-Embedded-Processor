--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
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
--	SAYAC_TOP level circuit (SAYAC_TOP)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	SAYAC_TOP	IS
	PORT	(	clk			:	IN	STD_LOGIC;
				rst			:	IN	STD_LOGIC;
			-- Interrupt SIGNAL	receiving from Programmable Interrupt Controller (PIC)
				interrupt	:	IN	STD_LOGIC;	
				not_empty_check : OUT STD_LOGIC);
END	ENTITY	SAYAC_TOP;

ARCHITECTURE	behavior	OF	SAYAC_TOP	IS
	SIGNAL	opcode				:	STD_LOGIC_VECTOR(7	DOWNTO	0);
    SIGNAL	seldataBus_TRF		:	STD_LOGIC;
    SIGNAL	selPC1_TRF			:	STD_LOGIC;
    SIGNAL	selLLU_TRF			:	STD_LOGIC;
    SIGNAL	selSHU_TRF			:	STD_LOGIC;
    SIGNAL	selASU_TRF			:	STD_LOGIC;
    SIGNAL	selMDU1_TRF			:	STD_LOGIC;
    SIGNAL	selMDU2_TRF			:	STD_LOGIC;
    SIGNAL	selIMM_TRF			:	STD_LOGIC;
    SIGNAL	selrs1_TRF			:	STD_LOGIC;
    SIGNAL	selrd_1_TRF			:	STD_LOGIC;
    SIGNAL	selrs2_TRF			:	STD_LOGIC;
    SIGNAL	selrd_2_TRF			:	STD_LOGIC;
	SIGNAL	selrd0_TRF			:	STD_LOGIC;
	SIGNAL	selrd1_TRF			:	STD_LOGIC;
	SIGNAL	writeTRF			:	STD_LOGIC;
	SIGNAL	selp1_PCP			:	STD_LOGIC;
	SIGNAL	selimm_PCP			:	STD_LOGIC;
    SIGNAL	selp1_PC			:	STD_LOGIC;
    SIGNAL	selPCadd_PC			:	STD_LOGIC;
    SIGNAL	selPC1_PC			:	STD_LOGIC;
    SIGNAL	selPC_addrBus		:	STD_LOGIC;
    SIGNAL	selADR_addrBus		:	STD_LOGIC;
    SIGNAL	driveDataBus		:	STD_LOGIC;
    SIGNAL	SE5bits				:	STD_LOGIC;
    SIGNAL	SE6bits				:	STD_LOGIC;
    SIGNAL	USE8bits			:	STD_LOGIC;
    SIGNAL	SE8bits				:	STD_LOGIC;
    SIGNAL	p1lowbits			:	STD_LOGIC;
    SIGNAL	selp2_ASU			:	STD_LOGIC;
    SIGNAL	selimm_ASU			:	STD_LOGIC;
    SIGNAL	arithADD			:	STD_LOGIC;
    SIGNAL	arithSUB			:	STD_LOGIC;
    SIGNAL	logicAND			:	STD_LOGIC;
    SIGNAL	onesComp			:	STD_LOGIC;
    SIGNAL	twosComp			:	STD_LOGIC;
    SIGNAL	selp2_SHU			:	STD_LOGIC;
    SIGNAL	selshim_SHU			:	STD_LOGIC;
    SIGNAL	logicSH				:	STD_LOGIC;
    SIGNAL	arithSH				:	STD_LOGIC;
    SIGNAL	ldMDU1				:	STD_LOGIC;
    SIGNAL	ldMDU2				:	STD_LOGIC;
    SIGNAL	arithMUL			:	STD_LOGIC;
    SIGNAL	arithDIV			:	STD_LOGIC;
    SIGNAL	startMDU			:	STD_LOGIC;
    SIGNAL	ldIR				:	STD_LOGIC;
    SIGNAL	ldADR				:	STD_LOGIC;
    SIGNAL	ldPC				:	STD_LOGIC;
    SIGNAL	readMEM				:	STD_LOGIC;
    SIGNAL	writeMEM			:	STD_LOGIC;
    SIGNAL	readIO				:	STD_LOGIC;
    SIGNAL	writeIO				:	STD_LOGIC;
    SIGNAL	readInstMEM			:	STD_LOGIC;
	SIGNAL	readyMEM			:	STD_LOGIC;
	SIGNAL	readyMDU			:	STD_LOGIC;
	--	
	SIGNAL	readstatusTRF		:	STD_LOGIC;
	SIGNAL	writestatusTRF		:	STD_LOGIC;
	SIGNAL	writeTRB			:	STD_LOGIC;
	SIGNAL	USE12bits			:	STD_LOGIC;
	SIGNAL	selPC_PCP			:	STD_LOGIC;
	SIGNAL	selTRB_PCP			:	STD_LOGIC;
	SIGNAL	sel1_ADR			:	STD_LOGIC;
	SIGNAL	selPCP_ADR			:	STD_LOGIC;
	SIGNAL	seldataBus_PC		:	STD_LOGIC;
	SIGNAL	selp1_dataBus		:	STD_LOGIC;
	SIGNAL	selPC_dataBus		:	STD_LOGIC;
	SIGNAL	selPC1_dataBus		:	STD_LOGIC;
	SIGNAL	readIHBAddr			:	STD_LOGIC;
	SIGNAL	readTopStackAddr	:	STD_LOGIC;
	SIGNAL	selrs1_imm			:	STD_LOGIC;
	SIGNAL	selcnt_imm			:	STD_LOGIC;
	SIGNAL	rst_cnt				:	STD_LOGIC;
	SIGNAL	inc_cnt				:	STD_LOGIC;
	SIGNAL	IntEnable			:	STD_LOGIC;
	SIGNAL	IntServicing		:	STD_LOGIC;
	SIGNAL	selTRB_ADR			:	STD_LOGIC;
	SIGNAL	dividebyzero		:	STD_LOGIC;
	SIGNAL	exception			:	STD_LOGIC;
	SIGNAL	selESA_PC			:	STD_LOGIC;
	SIGNAL	InvalidInst			:	STD_LOGIC;
	--	
	SIGNAL	readMM				:	STD_LOGIC;
	SIGNAL	writeMM				:	STD_LOGIC;
	SIGNAL	selPCP_addrBus		:	STD_LOGIC;
	SIGNAL	ldExcBaseAddr		:	STD_LOGIC;
	SIGNAL	readExcBaseAddr		:	STD_LOGIC;
	SIGNAL	readExcOffAddr		:	STD_LOGIC;
	SIGNAL	ExcEnable			:	STD_LOGIC;
	SIGNAL	ExcServicing		:	STD_LOGIC;
	SIGNAL	EnvCallFault		:	STD_LOGIC;
	SIGNAL	readMemAccPolicy	:	STD_LOGIC;
--	SIGNAL	ldPRV				:	STD_LOGIC;
--	SIGNAL	setMmode			:	STD_LOGIC;
--	SIGNAL	setUmode			:	STD_LOGIC;
	SIGNAL	LdAccFault			:	STD_LOGIC;
	SIGNAL	StAccFault			:	STD_LOGIC;
	SIGNAL	DividedByZero		:	STD_LOGIC;
	--	
	SIGNAL	FIB     			:	STD_LOGIC_VECTOR(4	DOWNTO	0);  --Flags Intrepretation Bits
	SIGNAL	setFlags			:	STD_LOGIC;
	SIGNAL	enFlag  			:	STD_LOGIC;
	SIGNAL	R15_LSB 			:	STD_LOGIC_VECTOR(7	DOWNTO	0);
--	SIGNAL	outPRV				:	STD_LOGIC_VECTOR(1	DOWNTO	0);
	SIGNAL	current_PRV			:	STD_LOGIC_VECTOR(1	DOWNTO	0);
	SIGNAL	selFlag 			:	STD_LOGIC_VECTOR(7	DOWNTO	0);
	SIGNAL	dataBus 			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	addrBus 			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
BEGIN
	DataPath:	ENTITY	WORK.DPU
					PORT	MAP	(	clk 				=>	clk, 
									rst 				=>	rst,
									seldataBus_TRF		=>	seldataBus_TRF,
									selPC1_TRF			=>	selPC1_TRF,	
									selLLU_TRF			=>	selLLU_TRF,		
									selSHU_TRF			=>	selSHU_TRF,		
									selASU_TRF			=>	selASU_TRF,		
									selMDU1_TRF			=>	selMDU1_TRF,			
									selMDU2_TRF			=>	selMDU2_TRF,		
									selIMM_TRF			=>	selIMM_TRF,		
									selrs1_TRF			=>	selrs1_TRF,		
									selrd_1_TRF			=>	selrd_1_TRF,			
									selrs2_TRF			=>	selrs2_TRF,		
									selrd_2_TRF			=>	selrd_2_TRF,			
									selrd0_TRF			=>	selrd0_TRF,		
									selrd1_TRF			=>	selrd1_TRF,		
									writeTRF			=>	writeTRF,		
									selp1_PCP			=>	selp1_PCP,			
									selimm_PCP			=>	selimm_PCP,			
									selp1_PC			=>	selp1_PC,		
									selPCadd_PC			=>	selPCadd_PC,
									selPC1_PC			=>	selPC1_PC,		
									selPC_addrBus		=>	selPC_addrBus,	
									selADR_addrBus		=>	selADR_addrBus,		
									driveDataBus		=>	driveDataBus,	
									SE5bits				=>	SE5bits,		
									SE6bits				=>	SE6bits,			
									USE8bits			=>	USE8bits,			
									SE8bits				=>	SE8bits,			
									p1lowbits			=>	p1lowbits,
									selp2_ASU			=>	selp2_ASU,			
									selimm_ASU			=>	selimm_ASU,			
									arithADD			=>	arithADD,		
									arithSUB			=>	arithSUB,			
									logicAND			=>	logicAND,			
									onesComp			=>	onesComp,			
									twosComp			=>	twosComp,			
									selp2_SHU			=>	selp2_SHU,			
									selshim_SHU			=>	selshim_SHU,		
									logicSH				=>	logicSH,		
									arithSH				=>	arithSH,			
									ldMDU1				=>	ldMDU1,			
									ldMDU2				=>	ldMDU2,			
									arithMUL			=>	arithMUL,
									arithDIV			=>	arithDIV,			
									startMDU			=>	startMDU,			
									ldIR				=>	ldIR,			
									ldADR				=>	ldADR,				
									ldPC				=>	ldPC,			
									readstatusTRF		=>	readstatusTRF,
									writestatusTRF		=>	writestatusTRF,		
									writeTRB			=>	writeTRB,	
									USE12bits			=>	USE12bits,			
									selPC_PCP			=>	selPC_PCP,			
									selTRB_PCP			=>	selTRB_PCP,			
									sel1_ADR			=>	sel1_ADR,		
									selPCP_ADR			=>	selPCP_ADR,
									seldataBus_PC		=>	seldataBus_PC,
									selp1_dataBus		=>	selp1_dataBus,		
									selPC_dataBus		=>	selPC_dataBus,		
									selPC1_dataBus		=>	selPC1_dataBus,		
									readIHBAddr			=>	readIHBAddr,	
									readTopStackAddr	=>	readTopStackAddr,	
									selrs1_imm			=>	selrs1_imm,
									selcnt_imm			=>	selcnt_imm,		
									rst_cnt				=>	rst_cnt,		
									inc_cnt				=>	inc_cnt,			
									IntEnable			=>	IntEnable,
									IntServicing		=>	IntServicing,
									selTRB_ADR			=>	selTRB_ADR,		
									selPCP_addrBus		=>	selPCP_addrBus,
									selESA_PC			=>	selESA_PC,	
									ldExcBaseAddr		=>	ldExcBaseAddr,
									readExcBaseAddr		=>	readExcBaseAddr,
									readExcOffAddr		=>	readExcOffAddr,	
									ExcEnable			=>	ExcEnable,	
									ExcServicing		=>	ExcServicing,
									readMemAccPolicy	=>	readMemAccPolicy,
								--	ldPRV				=>	ldPRV,	
								--	setMmode			=>	setMmode,
								--	setUmode			=>	setUmode,			
									readMEM				=>	readMEM,			
									writeMEM			=>	writeMEM,			
									readIO				=>	readIO,			
									writeIO				=>	writeIO,				
									readInstMEM			=>	readInstMEM,
									InvalidInst			=>	InvalidInst,		
									EnvCallFault		=>	EnvCallFault,		
									Exception			=>	Exception,		
									readyMDU			=>	readyMDU,		
									opcode				=>	opcode,			
									FIB					=>	FIB,			
									setFlags			=>	setFlags,
									enFlag				=>	enFlag,			
									selFlag				=>	selFlag,				
									R15_LSB				=>	R15_LSB,			
									dataBus				=>	dataBus,			
									addrBus				=>	addrBus,
									LdAccFault			=>	LdAccFault,
									StAccFault			=>	StAccFault,
									DividedByZero		=>	DividedByZero,
								--	outPRV				=>	outPRV	);
									current_PRV			=>	current_PRV	);
									
	Controller:	ENTITY	WORK.CCU
					PORT	MAP	(	clk					=>	clk, 	
									rst					=>	rst, 
									readyMEM			=>	readyMEM,			
									readyMDU			=>	readyMDU,		
									exception		    =>	exception,		    
									interrupt		    =>	interrupt,    
									opcode   			=>	opcode,	
									FIB      			=>	FIB,	
									seldataBus_TRF		=>	seldataBus_TRF,		
									selPC1_TRF			=>	selPC1_TRF,		
									selLLU_TRF			=>	selLLU_TRF,		
									selSHU_TRF			=>	selSHU_TRF,		
									selASU_TRF			=>	selASU_TRF,		
									selMDU1_TRF			=>	selMDU1_TRF,		
									selMDU2_TRF			=>	selMDU2_TRF,			
									selIMM_TRF			=>	selIMM_TRF,		
									selrs1_TRF			=>	selrs1_TRF,		
									selrd_1_TRF			=>	selrd_1_TRF,			
									selrs2_TRF			=>	selrs2_TRF,		
									selrd_2_TRF			=>	selrd_2_TRF,			
									selrd0_TRF			=>	selrd0_TRF,		
									selrd1_TRF			=>	selrd1_TRF,		
									writeTRF			=>	writeTRF,		
									selp1_PCP			=>	selp1_PCP,		
									selimm_PCP			=>	selimm_PCP,	
									selp1_PC			=>	selp1_PC,		
									selPCadd_PC			=>	selPCadd_PC,	
									selPC1_PC			=>	selPC1_PC,	
									selPC_addrBus		=>	selPC_addrBus,	
									selADR_addrBus		=>	selADR_addrBus,
									driveDataBus		=>	driveDataBus,
									SE5bits				=>	SE5bits,			
									SE6bits				=>	SE6bits,			
									USE8bits			=>	USE8bits,			
									SE8bits				=>	SE8bits,		
									p1lowbits			=>	p1lowbits,			
									selp2_ASU			=>	selp2_ASU,		
									selimm_ASU			=>	selimm_ASU,	
									arithADD			=>	arithADD,			
									arithSUB			=>	arithSUB,			
									logicAND			=>	logicAND,			
									onesComp			=>	onesComp,			
									twosComp			=>	twosComp,		
									selp2_SHU			=>	selp2_SHU,		
									selshim_SHU			=>	selshim_SHU,	
									logicSH				=>	logicSH,			
									arithSH				=>	arithSH,				
									ldMDU1				=>	ldMDU1,			
									ldMDU2				=>	ldMDU2,			
									arithMUL			=>	arithMUL,			
									arithDIV			=>	arithDIV,			
									startMDU			=>	startMDU,		
									ldIR				=>	ldIR,			
									ldADR				=>	ldADR,				
									ldPC				=>	ldPC,			
									readMEM				=>	readMEM,			
									writeMEM			=>	writeMEM,		
									readIO				=>	readIO,			
									writeIO				=>	writeIO,		
									readInstMEM			=>	readInstMEM,	
									readstatusTRF		=>	readstatusTRF,	
									writestatusTRF		=>	writestatusTRF,	
									writeTRB			=>	writeTRB,		
									USE12bits			=>	USE12bits,			
									selPC_PCP			=>	selPC_PCP,		
									selTRB_PCP			=>	selTRB_PCP,	
									sel1_ADR			=>	sel1_ADR,		
									selPCP_ADR			=>	selPCP_ADR,	
									seldataBus_PC		=>	seldataBus_PC,		
									selp1_dataBus		=>	selp1_dataBus,		
									selPC_dataBus		=>	selPC_dataBus,	
									selPC1_dataBus		=>	selPC1_dataBus,	
									readIHBAddr			=>	readIHBAddr,	
									readTopStackAddr	=>	readTopStackAddr,	
									selrs1_imm			=>	selrs1_imm,		
									selcnt_imm			=>	selcnt_imm,	
									rst_cnt				=>	rst_cnt,			
									inc_cnt				=>	inc_cnt,		
									IntEnable			=>	IntEnable,		
									IntServicing		=>	IntServicing,	
									selTRB_ADR			=>	selTRB_ADR,	
									selPCP_addrBus		=>	selPCP_addrBus,	
									selESA_PC			=>	selESA_PC,	
									ldExcBaseAddr		=>	ldExcBaseAddr,	
									readExcBaseAddr		=>	readExcBaseAddr,		
									readExcOffAddr		=>	readExcOffAddr,
									ExcEnable			=>	ExcEnable,		
									ExcServicing		=>	ExcServicing,	
									readMemAccPolicy	=>	readMemAccPolicy,
								--	ldPRV				=>	ldPRV,			
								--	setMmode			=>	setMmode,		
								--	setUmode			=>	setUmode,	
								--	outPRV				=>	outPRV,		
									current_PRV			=>	current_PRV,		
									EnvCallFault		=>	EnvCallFault,	
									LdAccFault			=>	LdAccFault,		
									StAccFault			=>	StAccFault,	
									DividedByZero		=>	DividedByZero,		
									setFlags   			=>	setFlags, 			
									enFlag     			=>	enFlag,		
									InvalidInst			=>	InvalidInst,		
									R15_LSB    			=>	R15_LSB,	
									selFlag    			=>	selFlag	);

	-- Address Decoder
	readMM 	<=	readMEM OR readIO;
	writeMM	<=	writeMEM OR writeIO;
	
	MEMORY:	ENTITY	WORK.MEM	GENERIC	MAP	(	5130	) 
				PORT	MAP	(	clk			=>	clk, 
								rst			=>	rst, 
								readMEM		=>	readMM, 
								writeMEM	=>	writeMM,  
								addr		=>	addrBus, 
								rwData		=>	dataBus, 
								readyMEM	=>	readyMEM	);
				
	InstructionROM:	ENTITY	WORK.inst_ROM	GENERIC	MAP	(	5130	)  
						PORT	MAP	(	clk			=>	clk, 
										rst			=>	rst, 
										readInst	=>	readInstMEM,  
									--	readInst	=>	selPC_addrBus,
										addrInst	=>	addrBus, 
										Inst		=>	dataBus	);
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------

