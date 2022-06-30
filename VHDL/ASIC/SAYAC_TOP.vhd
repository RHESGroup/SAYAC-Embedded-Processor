--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
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
--	SAYAC_TOP level circuit (SAYAC_TOP) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY SAYAC_TOP IS
	PORT (
		clk, rst : IN STD_LOGIC;
		-- Interrupt signal receiving from Programmable Interrupt Controller (PIC)
		interrupt : IN STD_LOGIC
		--
	);
END ENTITY SAYAC_TOP;

ARCHITECTURE behavior OF SAYAC_TOP IS
	SIGNAL opcode : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		   selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF : STD_LOGIC;
    SIGNAL selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF : STD_LOGIC;
	SIGNAL selrd0_TRF, selrd1_TRF, writeTRF : STD_LOGIC;
	SIGNAL selp1_PCP, selimm_PCP : STD_LOGIC;
    SIGNAL selp1_PC, selPCadd_PC, selPC1_PC : STD_LOGIC;
    SIGNAL selPC_addrBus, selADR_addrBus, driveDataBus : STD_LOGIC;
    SIGNAL SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits : STD_LOGIC;
    SIGNAL selp2_ASU, selimm_ASU, arithADD, arithSUB : STD_LOGIC;
    SIGNAL logicAND, onesComp, twosComp : STD_LOGIC;
    SIGNAL selp2_SHU, selshim_SHU, logicSH, arithSH : STD_LOGIC;
    SIGNAL ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU : STD_LOGIC;
    SIGNAL ldIR, ldADR, ldPC : STD_LOGIC;
    SIGNAL readMEM, writeMEM, readIO, writeIO : STD_LOGIC;
	SIGNAL readyMEM, readyMDU : STD_LOGIC;
	--
	SIGNAL readstatusTRF, writestatusTRF, writeTRB, USE12bits : STD_LOGIC;
	SIGNAL selPC_PCP, selTRB_PCP, sel1_ADR, selPCP_ADR : STD_LOGIC;
	SIGNAL seldataBus_PC, selp1_dataBus, selPC_dataBus, selPC1_dataBus : STD_LOGIC;
	SIGNAL readIHBAddr, readTopStackAddr, selrs1_imm, selcnt_imm : STD_LOGIC;
	SIGNAL rst_cnt, inc_cnt, IntEnable, IntServicing, selTRB_ADR : STD_LOGIC;
	SIGNAL dividebyzero, exception, selESA_PC, InvalidInst : STD_LOGIC;
	--
	SIGNAL readMM, writeMM, selPCP_addrBus, ldExcBaseAddr : STD_LOGIC;
	SIGNAL readExcBaseAddr, readExcOffAddr, ExcEnable, ExcServicing : STD_LOGIC;
	--
	SIGNAL FIB      : STD_LOGIC_VECTOR(4 DOWNTO 0);  --Flags Intrepretation Bits
	SIGNAL setFlags : STD_LOGIC;
	SIGNAL enFlag   : STD_LOGIC;
	SIGNAL R15_LSB  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL selFlag  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dataBus  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL addrBus  : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	DataPath : ENTITY WORK.DPU PORT MAP 
					(clk => clk, rst => rst,
					seldataBus_TRF => seldataBus_TRF, selPC1_TRF => selPC1_TRF,  
					selLLU_TRF => selLLU_TRF, selSHU_TRF => selSHU_TRF, 
					selASU_TRF => selASU_TRF, selMDU1_TRF => selMDU1_TRF,  
					selMDU2_TRF => selMDU2_TRF, selIMM_TRF => selIMM_TRF, 
					selrs1_TRF => selrs1_TRF, selrd_1_TRF => selrd_1_TRF,  
					selrs2_TRF => selrs2_TRF, selrd_2_TRF => selrd_2_TRF, 
					selrd0_TRF => selrd0_TRF, selrd1_TRF => selrd1_TRF,  writeTRF => writeTRF,
					selp1_PCP => selp1_PCP, selimm_PCP => selimm_PCP, selp1_PC => selp1_PC, 
					selPCadd_PC => selPCadd_PC, selPC1_PC => selPC1_PC,  
					selPC_addrBus => selPC_addrBus, selADR_addrBus => selADR_addrBus,  
					driveDataBus => driveDataBus, SE5bits => SE5bits, SE6bits => SE6bits, 
					USE8bits => USE8bits, SE8bits => SE8bits, p1lowbits => p1lowbits,  
					selp2_ASU => selp2_ASU, selimm_ASU => selimm_ASU, arithADD => arithADD, 
					arithSUB => arithSUB, logicAND => logicAND, onesComp => onesComp,  
					twosComp => twosComp, selp2_SHU => selp2_SHU, selshim_SHU => selshim_SHU,  
					logicSH => logicSH, arithSH => arithSH, ldMDU1 => ldMDU1, ldMDU2 => ldMDU2, 
					arithMUL => arithMUL, arithDIV => arithDIV, startMDU => startMDU,  
					ldIR => ldIR, ldADR => ldADR, ldPC => ldPC,  
					--
					readstatusTRF => readstatusTRF, writestatusTRF => writestatusTRF, 
					writeTRB => writeTRB, USE12bits => USE12bits, selPC_PCP => selPC_PCP,
					selTRB_PCP => selTRB_PCP, sel1_ADR => sel1_ADR, selPCP_ADR => selPCP_ADR, 
					seldataBus_PC => seldataBus_PC, selp1_dataBus => selp1_dataBus, 
					selPC_dataBus => selPC_dataBus, selPC1_dataBus => selPC1_dataBus,
					readIHBAddr => readIHBAddr, 
					readTopStackAddr => readTopStackAddr, selrs1_imm => selrs1_imm, 
					selcnt_imm => selcnt_imm, rst_cnt => rst_cnt, inc_cnt => inc_cnt, 
					IntEnable => IntEnable, IntServicing => IntServicing, selTRB_ADR => selTRB_ADR,
					selPCP_addrBus => selPCP_addrBus, selESA_PC => selESA_PC,
					ldExcBaseAddr => ldExcBaseAddr, readExcBaseAddr => readExcBaseAddr, 
					readExcOffAddr => readExcOffAddr, ExcEnable => ExcEnable, 
					ExcServicing => ExcServicing,
					--
  					InvalidInst => InvalidInst, exception => exception, readyMDU => readyMDU, 
					opcode => opcode, FIB => FIB, 
					setFlags => setFlags, enFlag => enFlag, selFlag => selFlag,  
					R15_LSB => R15_LSB, dataBus => dataBus, addrBus => addrBus);
	Controller : ENTITY WORK.CCU PORT MAP 
					(clk => clk, rst => rst, 
					exception => exception, interrupt => interrupt, 
					readyMEM => readyMEM, readyMDU => readyMDU, 
					opcode => opcode, FIB => FIB, seldataBus_TRF => seldataBus_TRF,  
					selPC1_TRF => selPC1_TRF, selLLU_TRF => selLLU_TRF,  
					selSHU_TRF => selSHU_TRF, selASU_TRF => selASU_TRF,  
					selMDU1_TRF => selMDU1_TRF, selMDU2_TRF => selMDU2_TRF,  
					selIMM_TRF => selIMM_TRF, selrs1_TRF => selrs1_TRF,  
					selrd_1_TRF => selrd_1_TRF, selrs2_TRF => selrs2_TRF,  
					selrd_2_TRF => selrd_2_TRF, selrd0_TRF => selrd0_TRF,  
					selrd1_TRF => selrd1_TRF, writeTRF => writeTRF, selp1_PCP => selp1_PCP, 
					selimm_PCP => selimm_PCP, selp1_PC => selp1_PC,  
					selPCadd_PC => selPCadd_PC, selPC1_PC => selPC1_PC,  
					selPC_addrBus => selPC_addrBus, selADR_addrBus => selADR_addrBus,  
					driveDataBus => driveDataBus, SE5bits => SE5bits, SE6bits => SE6bits, 
					USE8bits => USE8bits, SE8bits => SE8bits, p1lowbits => p1lowbits, 
					selp2_ASU => selp2_ASU, selimm_ASU => selimm_ASU, arithADD => arithADD, 
					arithSUB => arithSUB, logicAND => logicAND, onesComp => onesComp,  
					twosComp => twosComp, selp2_SHU => selp2_SHU, selshim_SHU => selshim_SHU,  
					logicSH => logicSH, arithSH => arithSH, ldMDU1 => ldMDU1, ldMDU2 => ldMDU2,  
					arithMUL => arithMUL, arithDIV => arithDIV, startMDU => startMDU, 
					ldIR => ldIR, ldADR => ldADR, ldPC => ldPC, readMEM => readMEM,  
					writeMEM => writeMEM, readIO => readIO, writeIO => writeIO, 
					--
					readstatusTRF => readstatusTRF, writestatusTRF => writestatusTRF, 
					writeTRB => writeTRB, USE12bits => USE12bits, selPC_PCP => selPC_PCP,
					selTRB_PCP => selTRB_PCP, sel1_ADR => sel1_ADR, selPCP_ADR => selPCP_ADR, 
					seldataBus_PC => seldataBus_PC, selp1_dataBus => selp1_dataBus, 
					selPC_dataBus => selPC_dataBus, selPC1_dataBus => selPC1_dataBus, 
					readIHBAddr => readIHBAddr, 
					readTopStackAddr => readTopStackAddr, selrs1_imm => selrs1_imm, 
					selcnt_imm => selcnt_imm, rst_cnt => rst_cnt, inc_cnt => inc_cnt, 
					IntEnable => IntEnable, IntServicing => IntServicing, selTRB_ADR => selTRB_ADR,
					selPCP_addrBus => selPCP_addrBus, selESA_PC => selESA_PC,
					ldExcBaseAddr => ldExcBaseAddr, readExcBaseAddr => readExcBaseAddr, 
					readExcOffAddr => readExcOffAddr, ExcEnable => ExcEnable, 
					ExcServicing => ExcServicing,
					--
  					setFlags => setFlags, enFlag => enFlag, InvalidInst => InvalidInst,
					R15_LSB => R15_LSB, selFlag => selFlag);

	-- Address Decoder
	readMM  <= readMEM OR readIO;
	writeMM <= writeMEM OR writeIO;
	
	MEMORY : ENTITY WORK.MEM GENERIC MAP ( 600 ) 
				PORT MAP (clk => clk, rst => rst, readMEM => readMM, writeMEM => writeMM,  
						 addr => addrBus, rwData => dataBus, readyMEM => readyMEM);
--				 		 addrBus => addrBus, p1 => p1, dataBus => dataBus, readyMEM => readyMEM));
				
	InstructionROM : ENTITY WORK.inst_ROM GENERIC MAP (	600 )
						PORT MAP (clk => clk, rst => rst, readInst => selPC_addrBus,  
								 addrInst => addrBus, Inst => dataBus);
END ARCHITECTURE behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_SAYAC_TOP IS
END ENTITY test_SAYAC_TOP;

ARCHITECTURE test OF test_SAYAC_TOP IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, interrupt : STD_LOGIC;
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 22000 NS ELSE '0';
	rst <= '1', '0' AFTER 2 NS;
	interrupt <= '0', '1' AFTER 430 NS;
--	interrupt <= '0';

	SAYAC_TOP_Circuit : ENTITY WORK.SAYAC_TOP PORT MAP 
					(clk, rst, interrupt);
END ARCHITECTURE test;