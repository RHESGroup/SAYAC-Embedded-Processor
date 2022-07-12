--******************************************************************************
--	Filename:		SAYAC_DPU.vhd
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
--	DataPath Unit (DPU)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY	DPU	IS
	PORT	(	clk		      		:	IN		STD_LOGIC;
				rst      			:	IN		STD_LOGIC;
				seldataBus_TRF		:	IN		STD_LOGIC;
				selPC1_TRF			:	IN		STD_LOGIC;
				selLLU_TRF			:	IN		STD_LOGIC;
				selSHU_TRF			:	IN		STD_LOGIC;
				selASU_TRF			:	IN		STD_LOGIC;
				selMDU1_TRF			:	IN		STD_LOGIC;
				selMDU2_TRF			:	IN		STD_LOGIC;
				selIMM_TRF			:	IN		STD_LOGIC;
				selrs1_TRF			:	IN		STD_LOGIC;
				selrd_1_TRF			:	IN		STD_LOGIC;
				selrs2_TRF			:	IN		STD_LOGIC;
				selrd_2_TRF			:	IN		STD_LOGIC;
				selrd0_TRF			:	IN		STD_LOGIC;
				selrd1_TRF			:	IN		STD_LOGIC;
				writeTRF			:	IN		STD_LOGIC;
				selp1_PCP			:	IN		STD_LOGIC;
				selimm_PCP			:	IN		STD_LOGIC;
				selp1_PC			:	IN		STD_LOGIC;
				selPCadd_PC			:	IN		STD_LOGIC;
				selPC1_PC			:	IN		STD_LOGIC;
				selPC_addrBus		:	IN		STD_LOGIC;
				selADR_addrBus		:	IN		STD_LOGIC;
				driveDataBus		:	IN		STD_LOGIC;
				SE5bits				:	IN		STD_LOGIC;
				SE6bits				:	IN		STD_LOGIC;
				USE8bits			:	IN		STD_LOGIC;
				SE8bits				:	IN		STD_LOGIC;
				p1lowbits			:	IN		STD_LOGIC;
				selp2_ASU			:	IN		STD_LOGIC;
				selimm_ASU			:	IN		STD_LOGIC;
				arithADD			:	IN		STD_LOGIC;
				arithSUB			:	IN		STD_LOGIC;
				logicAND			:	IN		STD_LOGIC;
				onesComp			:	IN		STD_LOGIC;
				twosComp			:	IN		STD_LOGIC;
				selp2_SHU			:	IN		STD_LOGIC;
				selshim_SHU			:	IN		STD_LOGIC;
				logicSH				:	IN		STD_LOGIC;
				arithSH				:	IN		STD_LOGIC;
				ldMDU1				:	IN		STD_LOGIC;
				ldMDU2				:	IN		STD_LOGIC;
				arithMUL			:	IN		STD_LOGIC;
				arithDIV			:	IN		STD_LOGIC;
				startMDU			:	IN		STD_LOGIC;
				ldIR				:	IN		STD_LOGIC;
				ldADR				:	IN		STD_LOGIC;
				ldPC				:	IN		STD_LOGIC;
				readstatusTRF		:	IN		STD_LOGIC;
				writestatusTRF		:	IN		STD_LOGIC;
				writeTRB			:	IN		STD_LOGIC;
				USE12bits			:	IN		STD_LOGIC;
				selPC_PCP			:	IN		STD_LOGIC;
				selTRB_PCP			:	IN		STD_LOGIC;
				sel1_ADR			:	IN		STD_LOGIC;
				selPCP_ADR			:	IN		STD_LOGIC;
				seldataBus_PC		:	IN		STD_LOGIC;
				selp1_dataBus		:	IN		STD_LOGIC;
				selPC_dataBus		:	IN		STD_LOGIC;
				selPC1_dataBus		:	IN		STD_LOGIC;
				readIHBAddr			:	IN		STD_LOGIC;
				readTopStackAddr	:	IN		STD_LOGIC;
				selrs1_imm			:	IN		STD_LOGIC;
				selcnt_imm			:	IN		STD_LOGIC;
				rst_cnt				:	IN		STD_LOGIC;
				inc_cnt				:	IN		STD_LOGIC;
				IntEnable			:	IN		STD_LOGIC;
				IntServicing		:	IN		STD_LOGIC;
				selTRB_ADR			:	IN		STD_LOGIC;
				selPCP_addrBus		:	IN		STD_LOGIC;
				selESA_PC			:	IN		STD_LOGIC;
				ldExcBaseAddr		:	IN		STD_LOGIC;
				readExcBaseAddr		:	IN		STD_LOGIC;
				readExcOffAddr		:	IN		STD_LOGIC;
				ExcEnable			:	IN		STD_LOGIC;
				ExcServicing		:	IN		STD_LOGIC;
				--
				readMEM				:	IN		STD_LOGIC;
				writeMEM			:	IN		STD_LOGIC;
				readIO				:	IN		STD_LOGIC;
				writeIO				:	IN		STD_LOGIC;
				readInstMEM			:	IN		STD_LOGIC;
				readMemAccPolicy	:	IN		STD_LOGIC;
			--	ldPRV				:	IN		STD_LOGIC;
			--	setMmode			:	IN		STD_LOGIC;
			--	setUmode			:	IN		STD_LOGIC;
			--	outPRV				:	OUT		STD_LOGIC_VECTOR(1	DOWNTO	0);
				current_PRV			:	IN		STD_LOGIC_VECTOR(1	DOWNTO	0);
				InvalidInst			:	IN   	STD_LOGIC;
				EnvCallFault		:	IN   	STD_LOGIC;
				LdAccFault			:	OUT		STD_LOGIC;
				StAccFault			:	OUT		STD_LOGIC;
				DividedByZero		:	OUT		STD_LOGIC;
				--
				Exception			:	OUT  	STD_LOGIC;
				readyMDU			:	OUT  	STD_LOGIC;
				opcode				:	OUT  	STD_LOGIC_VECTOR(7	DOWNTO	0);
				FIB					:	OUT  	STD_LOGIC_VECTOR(4	DOWNTO	0);
				setFlags			:	IN   	STD_LOGIC;
				enFlag				:	IN   	STD_LOGIC;
				selFlag				:	IN   	STD_LOGIC_VECTOR(7	DOWNTO	0);
				R15_LSB				:	OUT  	STD_LOGIC_VECTOR(7	DOWNTO	0);
				dataBus				:	INOUT	STD_LOGIC_VECTOR(15	DOWNTO	0);
				addrBus				:	OUT  	STD_LOGIC_VECTOR(15	DOWNTO	0)	);
END	ENTITY	DPU;

ARCHITECTURE	behavior	OF	DPU	IS
	SIGNAL	inDataTRF		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	p1				:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	p2				:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMDU1			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMDU2			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outASU			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outLLU			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outSHU			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outPC1			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outIMM			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	Instruction		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMuxASU		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outPCP			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outPC			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outADR			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMux1PCP		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMuxPC		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMuxSHU		:	STD_LOGIC_VECTOR(4	DOWNTO	0);
	SIGNAL	outMuxrs1		:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	outMuxrs2		:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	outMuxrd		:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	inFlag			:	STD_LOGIC_VECTOR(7	DOWNTO	0);
	SIGNAL	outTRB			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMUXdataBus	:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	gt				:	STD_LOGIC;
	SIGNAL	eq				:	STD_LOGIC;
	SIGNAL	read_addr		:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	inADR			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outMux2PCP		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	ESA				:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outSRB			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outRSB			:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	outrd1			:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	outCNT			:	STD_LOGIC_VECTOR(3	DOWNTO	0);
	SIGNAL	ExcSrcNum		:	STD_LOGIC_VECTOR(2	DOWNTO	0);
--	SIGNAL	outPRV_reg		:	STD_LOGIC_VECTOR(1	DOWNTO	0);
--	SIGNAL	current_PRV		:	STD_LOGIC_VECTOR(1	DOWNTO	0);
	SIGNAL	addressBus		:	STD_LOGIC_VECTOR(15	DOWNTO	0);
	SIGNAL	InstAccFault	:	STD_LOGIC;
	SIGNAL	LdAccFault_reg	:	STD_LOGIC;
	SIGNAL	StAccFault_reg	:	STD_LOGIC;
	SIGNAL	DivByZero_reg	:	STD_LOGIC;

--	ALIAS	PreviousPRV		:	STD_LOGIC_VECTOR(1	DOWNTO	0)	IS	p1(1			DOWNTO	0);
	ALIAS	rs1				:	STD_LOGIC_VECTOR(3	DOWNTO	0)	IS	Instruction(7	DOWNTO	4);
	ALIAS	rs2				:	STD_LOGIC_VECTOR(3	DOWNTO	0)	IS	Instruction(11	DOWNTO	8);
	ALIAS	rd				:	STD_LOGIC_VECTOR(3	DOWNTO	0)	IS	Instruction(3	DOWNTO	0);
	ALIAS	ExcOffAddr		:	STD_LOGIC_VECTOR(4	DOWNTO	0)	IS	outTRB(4		DOWNTO	0);
BEGIN
	muxdataBus:	ENTITY	WORK.MUX3of16bits	GENERIC	MAP	(	16	)
					PORT	MAP	(	p1, 
									outPC, 
									outPC1, 
									selp1_dataBus,
									selPC_dataBus, 
									selPC1_dataBus, 
									outMuxdataBus	);

	dataBus			<=	(OTHERS => 'Z')	WHEN	driveDataBus = '0'	ELSE outMuxdataBus;
	addrBus			<=	addressBus;
--	outPRV			<=	outPRV_reg;
	LdAccFault		<=	LdAccFault_reg;
	StAccFault		<=	StAccFault_reg;
	DividedByZero	<=	DivByZero_reg;
	
	rd1:	ENTITY	WORK.INC	GENERIC	MAP	(	4	)
				PORT	MAP	(	rd, 
								outrd1	);
		
	muxrd:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	4	)
				PORT	MAP	(	rd, 
								outrd1, 
								selrd0_TRF, 
								selrd1_TRF, 
								outMuxrd	);
		
	muxrs1:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	4	)
				PORT	MAP	(	rs1, 
								rd, 
								selrs1_TRF, 
								selrd_1_TRF, 
								outMuxrs1	);
				  
	muxrs2:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	4	)
				PORT	MAP	(	rs2, 
								rd, 
								selrs2_TRF, 
								selrd_2_TRF, 
								outMuxrs2	);
		
	muxinDataTRF:	ENTITY	WORK.MUX8of16bits
						PORT	MAP	(	outIMM, 
										outMDU1, 
										outMDU2, 
										outASU, 
										outLLU, 
										outSHU, 
										dataBus, 
										outPC1, 
										selIMM_TRF, 
										selMDU1_TRF, 
										selMDU2_TRF, 
										selASU_TRF,	
										selLLU_TRF, 
										selSHU_TRF, 
										seldataBus_TRF, 
										selPC1_TRF,	
										inDataTRF	);
						
	TheRegisterFile:	ENTITY	WORK.TRF
							PORT	MAP	(	clk, 
											rst, 
											writeTRF, 
											setFlags, 
											enFlag, 
											readstatusTRF, 
											writestatusTRF,
											outMuxrs1, 
											outMuxrs2, 
											outMuxrd, 
											selFlag, 
											inFlag, 
											R15_LSB, 
											inDataTRF, 
											p1, 
											p2	);
	
	ExceptionAddrGen:	ENTITY	WORK.EAG
							PORT	MAP	(	clk, 
											rst, 
											ldExcBaseAddr, 
											ExcSrcNum, 
											outTRB, 
											ExcOffAddr, 
											ESA	);
	
	ExceptionSourceRegister:	ENTITY	WORK.ESR 
									PORT	MAP	(	clk, 
													rst,		
													ExcServicing,
													InstAccFault,	
													InvalidInst,	
													LdAccFault_reg,	
													StAccFault_reg,	
													EnvCallFault,
													DivByZero_reg,	
													ExcSrcNum,
													Exception	);
	
    TheRegisterBank:	ENTITY	WORK.TRB
							PORT	MAP	(	clk, 
											rst, 
											writeTRB, 
											readMemAccPolicy, 
											readTopStackAddr, 
											readIHBAddr, 
											readExcBaseAddr, 
											readExcOffAddr, 
											rd, 
											dataBus, 
											outTRB	);
	
	SummaryRegisterBank:	ENTITY	WORK.SRB
								PORT	MAP	(	clk, 
												rst,
												writeTRB,
												rd,
												dataBus,
												outSRB	);
	
	RegionSizeBank:	ENTITY	WORK.RSB
							PORT	MAP	(	clk, 
											rst,
											writeTRB,
											rd,
											dataBus,
											outRSB	);

	-- PriviledgeModeRegister: ENTITY	WORK.PRV
								-- PORT	MAP	(	clk, 
												-- rst,
												-- ldPRV,
												-- setMmode,
												-- setUmode,
												-- PreviousPRV,
												-- outPRV_reg	);

    Counter:	ENTITY	WORK.CNT
					PORT	MAP	(	clk, 
									rst, 
									rst_cnt, 
									inc_cnt, 
									outCNT	);
	
	opcode   	<=	Instruction(15	DOWNTO	8);
	FIB      	<=	Instruction(8	DOWNTO	4);
--	inFlag   	<=	(i & x & gt & eq & i_en & x_en & i_mask & x_mask	); 
--	inFlag   	<=	(IntServicing & ExcServicing & gt & eq & ExcEnable & IntEnable & outPRV_reg);
	inFlag   	<=	(IntServicing & ExcServicing & gt & eq & ExcEnable & IntEnable & current_PRV);
	
	IR:	ENTITY	WORK.REG
			PORT	MAP	 (	clk, 
							rst, 
							ldIR, 
							dataBus, 
							Instruction	);
	
	ImmediateUnit:	ENTITY	WORK.IMM
						PORT	MAP	(	Instruction(11	DOWNTO	4), 
										p1(7	DOWNTO	0), 
										outCNT, 
										SE5bits, 
										SE6bits,
										USE8bits, 
										SE8bits, 
										p1lowbits, 
										selrs1_imm,  
										selcnt_imm, 
										USE12bits, 
										outIMM	);
	
	mux1PCP:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	16	)
					PORT	MAP	(	p1, 
									outIMM, 
									selp1_PCP, 
									selimm_PCP, 
									outMux1PCP	);
	
	mux2PCP:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	16	)
				PORT	MAP	(	outTRB, 
								outPC, 
								selTRB_PCP, 
								selPC_PCP, 
								outMux2PCP	);

	PCP:	ENTITY	WORK.ADD	GENERIC	MAP	(	16	)
				PORT	MAP	(	outMux1PCP, 
								outMux2PCP, 
								outPCP	);
	
	muxPC:	ENTITY	WORK.MUX5of16bits
				PORT	MAP	(	p1, 
								outPCP, 
								ESA, 
								dataBus, 
								outPC1, 
								selp1_PC, 
								selPCAdd_PC, 
								selESA_PC, 
								seldataBus_PC, 
								selPC1_PC, 
								outMuxPC	);
	
	PC:	ENTITY	WORK.REG
			PORT	MAP	(	clk, 
							rst, 
							ldPC, 
							outMuxPC, 
							outPC	);
	
	PC1:	ENTITY	WORK.INC	GENERIC	MAP	(	16	)
				PORT	MAP	(	outPC, 
								outPC1	);
	
	muxADR:	ENTITY	WORK.MUX3of16bits	GENERIC	MAP	(	16	)
				PORT	MAP	(	outMux1PCP, 
								outPCP, 
								outTRB, 
								sel1_ADR, 
								selPCP_ADR, 
								selTRB_ADR, 
								inADR	);

	ADR:	ENTITY	WORK.REG
				PORT	MAP	(	clk, 
								rst, 
								ldADR, 
								inADR, 
								outADR	);
	
	muxaddrBus:	ENTITY	WORK.MUX3of16bits
					PORT	MAP	(	outADR, 
									outPC, 
									outPCP, 
									selADR_addrBus, 
									selPC_addrBus, 
									selPCP_addrBus, 
									addressBus	);
	
	MultDivUnit:	ENTITY	WORK.MDU
						PORT	MAP	(	clk, 
										rst, 
										startMDU, 
										arithMUL, 
										arithDIV, 
										'0', 
									-- signMDU,
										ldMDU1, 
										ldMDU2,	 
										p1, 
										p2,	
										outMDU1, 
										outMDU2, 
										DivByZero_reg, 
										readyMDU	);
	
	muxASU:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	16	)
				PORT	MAP	(	p2, 
								outIMM, 
								selp2_ASU, 
								selimm_ASU, 
								outMuxASU	);
	
	ComparatorUnit:	ENTITY	WORK.CMP
						PORT	MAP	(	p1, 
										outMuxASU, 
										'0', 
									--	signCMP,
										eq, 
										gt	);
	
	AddSubUnit:	ENTITY	WORK.ASU
					PORT	MAP	(	p1, 
									outMuxASU, 
									arithADD, 
									arithSUB, 
									outASU	);
	
	LogicLogicUnit:	ENTITY	WORK.LLU
						PORT	MAP	(	p1, 
										outMuxASU, 
										logicAND,
										onesComp, 
										twosComp, 
										outLLU	);
	
	
	muxSHU:	ENTITY	WORK.MUX2ofnbits	GENERIC	MAP	(	5	)
				PORT	MAP	(	p2(4	DOWNTO	0), 
								Instruction(8	DOWNTO	4), 
								selp2_SHU, 
								selshim_SHU, 
								outMuxSHU	);
	
	ShiftUnit:	ENTITY	WORK.SHU
					PORT	MAP	(	p1, 
									outMuxSHU, 
									logicSH, 
									arithSH, 
									outSHU	);
					
	AddressRegionCheck:	ENTITY	WORK.ARC
							PORT	MAP	(	addressBus,
											outSRB, 
											outRSB,
											readMEM,
											writeMEM,
											readIO,
											writeIO,	
											ldIR,
											InstAccFault,	
											StAccFault_reg,	
											LdAccFault_reg	);
END	ARCHITECTURE	behavior;