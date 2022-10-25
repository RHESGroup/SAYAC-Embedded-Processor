--******************************************************************************
--	Filename:		SAYAC_CCU.vhd
--	Project:		SAYAC	:	Simple ARCHITECTURE	Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			9 July 2022
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University	OF	Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement	IS not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Control Control Unit (CCU)	OF	the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;	
	
ENTITY	CCU	IS
	PORT	(	clk					:	IN	STD_LOGIC;
				rst					:	IN	STD_LOGIC;
				readyMEM			:	IN	STD_LOGIC;
				readyMDU			:	IN	STD_LOGIC;
				exception			:	IN	STD_LOGIC;
				-- Interrupt SIGNAL	receiving from Programmable Interrupt Controller (PIC)
				interrupt			:	IN	STD_LOGIC;
				--	
				opcode   			:	IN	STD_LOGIC_VECTOR(7	DOWNTO	0);
				FIB      			:	IN	STD_LOGIC_VECTOR(4	DOWNTO	0);  --Flags Intrepretation Bits
				seldataBus_TRF		:	OUT	STD_LOGIC;
				selPC1_TRF			:	OUT	STD_LOGIC;
				selLLU_TRF			:	OUT	STD_LOGIC;
				selSHU_TRF			:	OUT	STD_LOGIC;
				selASU_TRF			:	OUT	STD_LOGIC;
				selMDU1_TRF			:	OUT	STD_LOGIC;
				selMDU2_TRF			:	OUT	STD_LOGIC;
				selIMM_TRF			:	OUT	STD_LOGIC;
				selrs1_TRF			:	OUT	STD_LOGIC;
				selrd_1_TRF			:	OUT	STD_LOGIC;
				selrs2_TRF			:	OUT	STD_LOGIC;
				selrd_2_TRF			:	OUT	STD_LOGIC;
				selrd0_TRF			:	OUT	STD_LOGIC;
				selrd1_TRF			:	OUT	STD_LOGIC;
				writeTRF			:	OUT	STD_LOGIC;
				selp1_PCP			:	OUT	STD_LOGIC;
				selimm_PCP			:	OUT	STD_LOGIC;
				selp1_PC			:	OUT	STD_LOGIC;
				selPCadd_PC			:	OUT	STD_LOGIC;
				selPC1_PC			:	OUT	STD_LOGIC;
				selPC_addrBus		:	OUT	STD_LOGIC;
				selADR_addrBus		:	OUT	STD_LOGIC;
				driveDataBus		:	OUT	STD_LOGIC;
				SE5bits				:	OUT	STD_LOGIC;
				SE6bits				:	OUT	STD_LOGIC;
				USE8bits			:	OUT	STD_LOGIC;
				SE8bits				:	OUT	STD_LOGIC;
				p1lowbits			:	OUT	STD_LOGIC;
				selp2_ASU			:	OUT	STD_LOGIC;
				selimm_ASU			:	OUT	STD_LOGIC;
				arithADD			:	OUT	STD_LOGIC;
				arithSUB			:	OUT	STD_LOGIC;
				logicAND			:	OUT	STD_LOGIC;
				onesComp			:	OUT	STD_LOGIC;
				twosComp			:	OUT	STD_LOGIC;
				selp2_SHU			:	OUT	STD_LOGIC;
				selshim_SHU			:	OUT	STD_LOGIC;
				logicSH				:	OUT	STD_LOGIC;
				arithSH				:	OUT	STD_LOGIC;
				ldMDU1				:	OUT	STD_LOGIC;
				ldMDU2				:	OUT	STD_LOGIC;
				arithMUL			:	OUT	STD_LOGIC;
				arithDIV			:	OUT	STD_LOGIC;
				startMDU			:	OUT	STD_LOGIC;
				ldIR				:	OUT	STD_LOGIC;
				ldADR				:	OUT	STD_LOGIC;
				ldPC				:	OUT	STD_LOGIC;
				readMEM				:	OUT	STD_LOGIC;
				writeMEM			:	OUT	STD_LOGIC;
				readIO				:	OUT	STD_LOGIC;
				writeIO				:	OUT	STD_LOGIC;
				readInstMEM			:	OUT	STD_LOGIC;
				-- New additinal control signals FOR handling interrupt
				readstatusTRF		:	OUT	STD_LOGIC;
				writestatusTRF		:	OUT	STD_LOGIC;
				writeTRB			:	OUT	STD_LOGIC;
				USE12bits			:	OUT	STD_LOGIC;
				selPC_PCP			:	OUT	STD_LOGIC;
				selTRB_PCP			:	OUT	STD_LOGIC;
				sel1_ADR			:	OUT	STD_LOGIC;
				selPCP_ADR			:	OUT	STD_LOGIC;
				seldataBus_PC		:	OUT	STD_LOGIC;
				selp1_dataBus		:	OUT	STD_LOGIC;
				selPC_dataBus		:	OUT	STD_LOGIC;
				selPC1_dataBus		:	OUT	STD_LOGIC;
				readIHBAddr			:	OUT	STD_LOGIC;
				readTopStackAddr	:	OUT	STD_LOGIC;
				selrs1_imm			:	OUT	STD_LOGIC;
				selcnt_imm			:	OUT	STD_LOGIC;
				rst_cnt				:	OUT	STD_LOGIC;
				inc_cnt				:	OUT	STD_LOGIC;
				IntEnable			:	OUT	STD_LOGIC;
				IntServicing		:	OUT	STD_LOGIC;
				selTRB_ADR			:	OUT	STD_LOGIC;
				selPCP_addrBus		:	OUT	STD_LOGIC;
				selESA_PC			:	OUT	STD_LOGIC;
				ldExcBaseAddr		:	OUT	STD_LOGIC;
				readExcBaseAddr		:	OUT	STD_LOGIC;
				readExcOffAddr		:	OUT	STD_LOGIC;
				ExcEnable			:	OUT	STD_LOGIC;
				ExcServicing		:	OUT	STD_LOGIC;
				--
				readMemAccPolicy	:	OUT	STD_LOGIC;
			--	ldPRV				:	OUT	STD_LOGIC;
			--	setMmode			:	OUT	STD_LOGIC;
			--	setUmode			:	OUT	STD_LOGIC;
			--	outPRV				:	IN	STD_LOGIC_VECTOR(1	DOWNTO	0);
				current_PRV			:	OUT	STD_LOGIC_VECTOR(1	DOWNTO	0);
				EnvCallFault		:	OUT	STD_LOGIC;
				LdAccFault			:	IN	STD_LOGIC;
				StAccFault			:	IN	STD_LOGIC;
				DividedByZero		:	IN	STD_LOGIC;
				--
				setFlags   			:	OUT	STD_LOGIC;
				enFlag     			:	OUT	STD_LOGIC;
				InvalidInst			:	OUT	STD_LOGIC;
				R15_LSB    			:	IN 	STD_LOGIC_VECTOR(7	DOWNTO	0);
				selFlag    			:	OUT	STD_LOGIC_VECTOR(7	DOWNTO	0)	);
END	ENTITY	CCU;

ARCHITECTURE	behavior	OF	CCU	IS
	CONSTANT	RSV1  	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0000";
	CONSTANT	RSV2  	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0001";
	CONSTANT	INST2 	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0010";
	-- New additinal instructions FOR	handling interrupt
	CONSTANT	LOAD  	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"00";
	CONSTANT	LDR   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"00";
	CONSTANT	LIR   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"01";
	CONSTANT	LDB   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"10";
	CONSTANT	LIB   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"11";
	CONSTANT	STORE 	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"01";
	CONSTANT	STR   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"00";
	CONSTANT	SIR   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"01";
	CONSTANT	STB   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"10";
	CONSTANT	SIB   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"11";
	CONSTANT	JUMPR 	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"10";
	CONSTANT	JMR   	:	STD_LOGIC                   	:=	'0';
	CONSTANT	JMB   	:	STD_LOGIC                   	:=	'1';
	--
	CONSTANT	JMI   	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	:=	"11";
	CONSTANT	ANR   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0011";
	CONSTANT	ANI   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0100";
	CONSTANT	MSI   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0101";
	CONSTANT	MHI   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0110";
	CONSTANT	SLR   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"0111";
	CONSTANT	SAR   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1000";
	CONSTANT	ADR   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1001";
	CONSTANT	SUR   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1010";
	CONSTANT	ADI   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1011";
	CONSTANT	SUI   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1100";
	CONSTANT	MUL   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1101";
	CONSTANT	DIV   	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1110";
	CONSTANT	INST15	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	:=	"1111";
	CONSTANT	INST151	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	:=	"000";
	CONSTANT	SYSINST	:	STD_LOGIC						:=	'0';
	CONSTANT	MEC		:	STD_LOGIC_VECTOR(7	DOWNTO	0)	:=	"00000000";
	CONSTANT	CMR   	:	STD_LOGIC						:=	'1';
	CONSTANT	CMI   	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	:=	"001";
	CONSTANT	BRC   	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	:=	"010";
	CONSTANT	BRR   	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	:=	"011";
	CONSTANT	SHI   	:	STD_LOGIC_VECTOR(5	DOWNTO	0)	:=	"111110";
	CONSTANT	NTR   	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	:=	"110";
	CONSTANT	NTD   	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	:=	"111";
	
	TYPE	state	IS	(	fetch, 
							interrupt_processing_state1, interrupt_processing_state2, 
							interrupt_processing_state3, 
							exception_processing_state1, exception_processing_state2,
							exec1, exec2, exec3, exec4	);

	SIGNAL	pstate			:	state	:=	fetch;
	SIGNAL	nstate			:	state	:=	fetch;
	
	ALIAS opcode7downto4	:	STD_LOGIC_VECTOR(3	DOWNTO	0)	IS opcode(7	DOWNTO	4);
	ALIAS opcode3downto2	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	IS opcode(3	DOWNTO	2);
	ALIAS opcode3downto1	:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS opcode(3	DOWNTO	1);
	ALIAS opcode1downto0	:	STD_LOGIC_VECTOR(1	DOWNTO	0)	IS opcode(1	DOWNTO	0);
	ALIAS opcode0       	:	STD_LOGIC                   	IS opcode(0);
	ALIAS RFI				:	STD_LOGIC_VECTOR(2	DOWNTO	0)	IS FIB(2	DOWNTO	0);
BEGIN	
	--	ISsuing control signals
	PROCESS	(	pstate, readyMEM, readyMDU, opcode, FIB, R15_LSB	)
	BEGIN
		selFlag				<=	(OTHERS => '0');
		current_PRV			<=	"00";
		seldataBus_TRF		<=	'0';	
		selPC1_TRF			<=	'0';		
		selLLU_TRF			<=	'0'; 
		selSHU_TRF			<=	'0';	    
		selASU_TRF			<=	'0';		
		selMDU1_TRF			<=	'0'; 
		selMDU2_TRF			<=	'0';	    
		selIMM_TRF			<=	'0';		
		selrs1_TRF			<=	'0';	    
		selrd_1_TRF			<=	'0';		
		selrd0_TRF			<=	'0';		
		selrd1_TRF			<=	'0';	    
		writeTRF			<=	'0';		
		selp1_PCP			<=	'0';		
		selimm_PCP			<=	'0';	
		selp1_PC			<=	'0';		
		selPCadd_PC			<=	'0';		
		selPC1_PC			<=	'0';       
		selPC_addrBus		<=	'0';	
		selADR_addrBus		<=	'0';	
		SE5bits				<=	'0';			
		SE6bits				<=	'0';			
		USE8bits			<=	'0';		
		SE8bits				<=	'0';			
		p1lowbits			<=	'0';		
		selp2_ASU			<=	'0';		
		selimm_ASU			<=	'0';		
		arithADD			<=	'0';		
		arithSUB			<=	'0';        
		logicAND			<=	'0';		
		onesComp			<=	'0';		
		twosComp			<=	'0';        
		selp2_SHU			<=	'0';		
		selshim_SHU			<=	'0';		
		logicSH				<=	'0';			
		arithSH				<=	'0';
		ldMDU1				<=	'0';			
		ldMDU2				<=	'0';			
		arithMUL			<=	'0';
		arithDIV			<=	'0';		
		startMDU			<=	'0';        
		ldIR				<=	'0';
		ldADR				<=	'0';			
		ldPC				<=	'0';	        
		readMEM				<=	'0';
		writeMEM			<=	'0';		
		readIO				<=	'0';			
		writeIO				<=	'0';		
		selrd_2_TRF			<=	'0';		
		selrs2_TRF			<=	'0';		
		driveDataBus		<=	'0';
		setFlags			<=	'0';		
		enFlag				<=	'0';			
		readstatusTRF		<=	'0';	
		writeTRB			<=	'0';		
		USE12bits			<=	'0';
		selPC_PCP			<=	'0';		
		selTRB_PCP			<=	'0';		
		sel1_ADR			<=	'0';
		selPCP_ADR			<=	'0';		
		seldataBus_PC		<=	'0';	
		selp1_dataBus		<=	'0';
		selPC_dataBus		<=	'0';	
		selPC1_dataBus		<=	'0';	
		readIHBAddr			<=	'0';		
		readTopStackAddr	<=	'0';
		selrs1_imm			<=	'0';      
		selcnt_imm			<=	'0';      
		rst_cnt				<=	'0';
		inc_cnt				<=	'0';        
		selTRB_ADR			<=	'0';    	
		writestatusTRF		<=	'0';
		IntEnable			<=	'0';		
		IntServicing		<=	'0';	
		selPCP_addrBus		<=	'0';
		selESA_PC			<=	'0';		
		ldExcBaseAddr		<=	'0';	
		readExcBaseAddr		<=	'0';	
		readExcOffAddr		<=	'0';	
		ExcEnable			<=	'0';		
		ExcServicing		<=	'0';
		InvalidInst			<=	'0';		
		readInstMEM			<=	'0';
		readMemAccPolicy	<=	'0';
	--	ldPRV				<=	'0';
	--	setMmode			<=	'0';
	--	setUmode			<=	'0';
		EnvCallFault		<=	'0';
		
		CASE	(	pstate	)	IS
			WHEN	fetch	=>
				selPC_addrBus 		<=	'1';		
				ldIR				<=	'1';			
				rst_cnt				<=	'0';
				readInstMEM			<=	'1';
				readMemAccPolicy	<=	'1';
			WHEN	interrupt_processing_state1	=>
				readIHBAddr			<=	'1';			
				selTRB_PCP			<=	'1';		
				selcnt_imm			<=	'1';     
				USE12bits			<=	'1';			
				selimm_PCP			<=	'1';		
				selPCP_addrBus		<=	'1';		
				readstatusTRF		<=	'1';   	
				selp1_dataBus		<=	'1';	
				writeIO				<=	'1'; 
				IntEnable			<=	'0'; 			
				IntServicing		<=	'1';    	
				enFlag				<=	'1';   			
				inc_cnt				<=	'1';			
				driveDataBus		<=	'1';
			--	writestatusTRF		<=	'1';
				
			--	IF	outPRV /= "00"	THEN
				IF	R15_LSB(1	DOWNTO	0) /= "00"	THEN
					selFlag			<=	"10000111";
					current_PRV		<=	"00";
				--	setMmode		<=	'1';
				ELSE
					selFlag			<=	"10000100";
				END IF;
			WHEN	interrupt_processing_state2	=>
				readIHBAddr			<=	'1';         
				selTRB_PCP			<=	'1';    	
				selcnt_imm			<=	'1';     
				USE12bits			<=	'1';			
				selimm_PCP			<=	'1';   	
				selPCP_addrBus		<=	'1';    	
				selPC1_dataBus		<=	'1';  	
				writeIO				<=	'1';  		
				inc_cnt				<=	'1';
				driveDataBus		<=	'1';
			WHEN	interrupt_processing_state3	=>
				readIHBAddr			<=	'1';			
				selTRB_PCP			<=	'1';		
				selcnt_imm			<=	'1';     
				USE12bits			<=	'1';			
				selimm_PCP			<=	'1';		
				selPCP_addrBus		<=	'1';		
				readIO				<=	'1';				
				seldataBus_PC		<=	'1';	
				ldPC				<=	'1';
				rst_cnt				<=	'1';
			WHEN	exception_processing_state1	=>
				selFlag				<=	"01001000";  
				readExcBaseAddr		<=	'1';		
				ldExcBaseAddr		<=	'1';	
				selTRB_PCP			<=	'1';
				selcnt_imm			<=	'1';     		
				USE12bits			<=	'1';		
				selimm_PCP			<=	'1';		
				selPCP_addrBus		<=	'1';		
				selPC_dataBus		<=	'1';  	
				writeIO				<=	'1';
				inc_cnt				<=	'1';				
				ExcEnable			<=	'0'; 		
				ExcServicing		<=	'1';  	
				enFlag				<=	'1';   		
				driveDataBus		<=	'1';
			WHEN	exception_processing_state2	=>
				readExcOffAddr		<=	'1';		
				selESA_PC			<=	'1';		
				ldPC				<=	'1';				
				rst_cnt				<=	'1';
			WHEN	exec1	=>
				CASE (opcode7downto4)	IS
					WHEN	RSV1	=> 
						ldPC		<=	'1';		
						selPC1_PC	<=	'1';  			
					WHEN	RSV2	=> 
						ldPC		<=	'1';		
						selPC1_PC	<=	'1'; 	
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	LOAD	=>
								selrs1_TRF	<=	'1';		
								selp1_PCP	<=	'1';	
								ldADR		<=	'1';
								
								
								CASE	(	opcode1downto0	)	IS 
									WHEN	LDR | LIR | LDB	=>
										sel1_ADR	<=	'1';
									WHEN	LIB	=>
										readIHBAddr	<=	'1'; 	
										selTRB_PCP	<=	'1';	
										selPCP_ADR	<=	'1';
									WHEN	OTHERS	=>
										sel1_ADR	<=	'0';		
										readIHBAddr	<=	'0';	
										selTRB_PCP	<=	'0';		
										selPCP_ADR	<=	'0';
								END	CASE;
							WHEN	STORE	=>
								selrd_1_TRF	<=	'1';		
								selp1_PCP	<=	'1';	
								ldADR		<=	'1';								
								
								CASE	(	opcode1downto0	)	IS 
									WHEN	STR | SIR	=>
										sel1_ADR	<=	'1';
									WHEN	STB	=>
										selTRB_PCP			<=	'1';		
										selPCP_ADR			<=	'1';	
										readTopStackAddr	<=	'1';
									WHEN	SIB	=>
										readIHBAddr			<=	'1';		
										selTRB_PCP			<=	'1';	
										selPCP_ADR			<=	'1';
									WHEN	OTHERS	=>
										sel1_ADR			<=	'0';		
										selTRB_PCP			<=	'0';	
										selPCP_ADR			<=	'0';	
										readIHBAddr			<=	'0';		
										readTopStackAddr	<=	'0';
								END	CASE;
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMR	=>
										selrs1_TRF	<=	'1';		
										selp1_PCP	<=	'1';	
										selPC_PCP	<=	'1';
										selPCadd_PC	<=	'1';		
										ldPC		<=	'1';					
										IF	opcode(1) = '1'	THEN
											selrd0_TRF	<=	'1';		
											selPC1_TRF	<=	'1';		
											writeTRF	<=	'1';
										END	IF;
									WHEN	JMB	=>
										selrs1_imm		<=	'1';		
										USE12bits		<=	'1';	
										selimm_PCP		<=	'1';	
										selTRB_PCP		<=	'1';		
										selPCP_ADR		<=	'1';	
										ldADR			<=	'1';
										readstatusTRF	<=	'1';
									--	ldPRV			<=	'1';
									WHEN	OTHERS	=>
										selrs1_TRF		<=	'0';		
										selp1_PCP		<=	'0';	
										selPC_PCP		<=	'0';
										selPCadd_PC		<=	'0';		
										ldPC			<=	'0';		
										selrd0_TRF		<=	'0';
										selPC1_TRF		<=	'0';		
										writeTRF		<=	'0';	
										selrs1_imm		<=	'0';		
										USE12bits		<=	'0';		
										selimm_PCP		<=	'0';	
										selTRB_PCP		<=	'0';		
										selPCP_ADR		<=	'0';		
										ldADR			<=	'0';
									--	ldPRV			<=	'0';
								END	CASE;
							WHEN	JMI	=>
								SE6bits				<=	'1';			
								selimm_PCP			<=	'1';	
								selPC_PCP			<=	'1';	
								selPCadd_PC			<=	'1';		
								ldPC				<=	'1';		
								selrd0_TRF			<=	'1';	
								selPC1_TRF			<=	'1';		
								writeTRF			<=	'1';				
							WHEN	OTHERS	=>
								selrs1_TRF			<=	'0';		
								ldADR				<=	'0';		
								selp1_PCP			<=	'0';
								ldPC				<=	'0';			
								selPCadd_PC			<=	'0';	
								selrd0_TRF			<=	'0';	
								selPC1_TRF			<=	'0';		
								SE6bits				<=	'0';		
								selimm_PCP			<=	'0';	
								writeTRF			<=	'0';		
								selrd_1_TRF			<=	'0';	
								sel1_ADR			<=	'0';		
								writeTRB			<=	'0';	
								readIHBAddr			<=	'0';
								selTRB_PCP			<=	'0';		
								selPCP_ADR			<=	'0';	
								selp1_dataBus		<=	'0';
								selPC_PCP			<=	'0';		
								USE12bits			<=	'0';	
								readTopStackAddr	<=	'0';
								seldataBus_PC		<=	'0';	
								readMEM				<=	'0';
						END	CASE;
					WHEN	ANR	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						selp2_ASU	<=	'1';	
						logicAND	<=	'1';		
						selrd0_TRF	<=	'1';		
						selLLU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';	
					WHEN	ANI	=>
						selrd_1_TRF	<=	'1';		
						USE8bits	<=	'1';		
						selimm_ASU	<=	'1';	
						logicAND	<=	'1';		
						selrd0_TRF	<=	'1';		
						selLLU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';
					WHEN	MSI	=>
						SE8bits		<=	'1';			
						selrd0_TRF	<=	'1';		
						selIMM_TRF	<=	'1';
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';
					WHEN	MHI	=>
						selrd_1_TRF	<=	'1';		
						p1lowbits	<=	'1';		
						selrd0_TRF	<=	'1';
						selIMM_TRF	<=	'1';		
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';
						ldPC	<=	'1';			
					WHEN	SLR	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						selp2_SHU	<=	'1';
						logicSH		<=	'1';			
						selrd0_TRF	<=	'1';		
						selSHU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';	
					WHEN	SAR	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						selp2_SHU	<=	'1';
						arithSH		<=	'1';			
						selrd0_TRF	<=	'1';		
						selSHU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';	
					WHEN	ADR	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						selp2_ASU	<=	'1';
						arithADD	<=	'1';		
						selrd0_TRF	<=	'1';		
						selASU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';	
					WHEN	SUR	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						selp2_ASU	<=	'1';
						arithSUB	<=	'1';		
						selrd0_TRF	<=	'1';		
						selASU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';
					WHEN	ADI	=>
						selrd_1_TRF	<=	'1';		
						SE8bits		<=	'1';			
						selimm_ASU	<=	'1';
						arithADD	<=	'1';		
						selrd0_TRF	<=	'1';		
						selASU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';
					WHEN	SUI	=>
						selrd_1_TRF	<=	'1';		
						SE8bits		<=	'1';			
						selimm_ASU	<=	'1';
						arithSUB	<=	'1';		
						selrd0_TRF	<=	'1';		
						selASU_TRF	<=	'1';	
						writeTRF	<=	'1';		
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';
					WHEN	MUL	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						arithMUL	<=	'1';
						startMDU	<=	'1';
						
						IF	readyMDU = '1'	THEN 
							ldMDU1	<=	'1';
						END	IF;
					WHEN	DIV	=>
						selrs1_TRF	<=	'1';		
						selrs2_TRF	<=	'1';		
						arithDIV	<=	'1';
						startMDU	<=	'1';
						
						IF	readyMDU = '1'	THEN 
							ldMDU1	<=	'1';
						END	IF;
					WHEN	INST15	=>
						CASE	(	opcode3downto1	)	IS
							WHEN	INST151	=>
								CASE	(	opcode0	)	IS
									WHEN	SYSINST	=>
										selFlag			<=	"00000011";
										current_PRV		<=	"01";
										enFlag			<=	'1';
									--	setUmode		<=	'1';
										EnvCallFault	<=	'1';
									WHEN	CMR		=>
										selrs1_TRF		<=	'1';		
										selrd_2_TRF		<=	'1';		
										selp2_ASU		<=	'1';		
										selPC1_PC		<=	'1';		
										ldPC			<=	'1';			
										enFlag			<=	'1';
										selFlag			<=	"00110000";
									WHEN	OTHERS	=>
									--	setUmode		<=	'0';
										EnvCallFault	<=	'0';
										selrs1_TRF		<=	'0';		
										selrd_2_TRF		<=	'0';		
										selp2_ASU		<=	'0';		
										selPC1_PC		<=	'0';		
										ldPC			<=	'0';			
										enFlag			<=	'0';
										selFlag			<=	(OTHERS=>'0');
								END CASE;
							WHEN	CMI		=>
								selrd_1_TRF	<=	'1';		
								SE5bits		<=	'1';			
								selimm_ASU	<=	'1';	
								selPC1_PC	<=	'1';		
								ldPC		<=	'1';			
								enFlag		<=	'1';
								selFlag		<=	"00110000";
							WHEN	BRC		=>
								CASE	(	RFI	)	IS
									WHEN	"000"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(4) = '1'	THEN						--eq
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';
										ELSE
											selPC1_PC	<=	'1';		
										END	IF;
									WHEN	"001"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '0' AND R15_LSB(4) = '0'	THEN	--lt
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	"010"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '1'	THEN						--gt
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	"011"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '1' OR R15_LSB(4) = '1'	THEN	--gt/eq
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	"100"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '0' OR R15_LSB(4) = '1'	THEN	--lt/eq
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';
										ELSE
											selPC1_PC	<=	'1';		
										END	IF;
									WHEN	"101"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(4) = '0'	THEN						--neq
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	OTHERS	=>
										selrd_1_TRF	<=	'0';		
										selp1_PC	<=	'0';	
										ldPC		<=	'0';
										selPC1_PC	<=	'0';
								END	CASE;
							WHEN	BRR	=>
								CASE	(	RFI	)	IS
									WHEN	"000"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(4) = '1'	THEN						--eq
											selrd_1_TRF	<=	'1';		
											selp1_PCP	<=	'1';		
											selPC_PCP	<=	'1';
											selPCadd_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	"001"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '0' AND R15_LSB(4) = '0'	THEN	--lt
											selrd_1_TRF	<=	'1';		
											selp1_PCP	<=	'1';		
											selPC_PCP	<=	'1';
											selPCadd_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';											
										END	IF;
									WHEN	"010"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '1'	THEN						--gt
											selrd_1_TRF	<=	'1';		
											selp1_PCP	<=	'1';		
											selPC_PCP	<=	'1';
											selPCadd_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';		
										END	IF;
									WHEN	"011"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '1' OR R15_LSB(4) = '1'	THEN	--gt/eq
											selrd_1_TRF	<=	'1';		
											selp1_PCP	<=	'1';		
											selPC_PCP	<=	'1';
											selPCadd_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	"100"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(5) = '0' OR R15_LSB(4) = '1'	THEN	--lt/eq
											selrd_1_TRF	<=	'1';		
											selp1_PCP	<=	'1';		
											selPC_PCP	<=	'1';
											selPCadd_PC	<=	'1';	
										ELSE
											selPC1_PC	<=	'1';
										END	IF;
									WHEN	"101"	=>
										ldPC		<=	'1';
										
										IF	R15_LSB(4) = '0'	THEN						--neq
											selrd_1_TRF	<=	'1';		
											selp1_PC	<=	'1';		
											selPC_PCP	<=	'1';
											selPCadd_PC	<=	'1';
										ELSE
											selPC1_PC	<=	'1';	
										END	IF;
									WHEN	OTHERS	=>
										selrd_1_TRF	<=	'0';		
										selp1_PCP	<=	'0';		
										selPCadd_PC	<=	'0';	
										ldPC		<=	'0';			
										selPC_PCP	<=	'0';
								END	CASE;
							WHEN	NTR	=>
								selrs1_TRF	<=	'1';		
								selrd0_TRF	<=	'1';		
								selLLU_TRF	<=	'1';	
								writeTRF	<=	'1';		
								selPC1_PC	<=	'1';		
								ldPC		<=	'1';
								
								IF	opcode(0) = '0'	THEN
									onesComp	<=	'1';
								ELSE
									twosComp	<=	'1';
								END	IF;
							WHEN	NTD	=>
								selrd_1_TRF	<=	'1';		
								selrd0_TRF	<=	'1'; 		
								selLLU_TRF	<=	'1';	
								writeTRF	<=	'1';		
								selPC1_PC	<=	'1';		
								ldPC		<=	'1';
								
								IF	opcode(0) = '0'	THEN
									onesComp	<=	'1';
								ELSE
									twosComp	<=	'1';
								END	IF;
							WHEN	OTHERS	=>
								selrs1_TRF	<=	'0';		
								selp2_ASU	<=	'0';		
								SE5bits		<=	'0';	
								selimm_ASU	<=	'0';		
								selrd_1_TRF	<=	'0';		
								selp1_PC	<=	'0';	
								writeTRF	<=	'0';		
								selPCadd_PC	<=	'0';		
								selLLU_TRF	<=	'0';	
								selrd0_TRF	<=	'0';		
								onesComp	<=	'0';		
								twosComp	<=	'0';	
								ldPC		<=	'0';			
								selrs2_TRF	<=	'0';		
								enFlag		<=	'0';
								selFlag		<=	(OTHERS	=> '0');
						END	CASE;
					WHEN	OTHERS	=>
						InvalidInst		<=	'1';
						selp1_PCP		<=	'0';
						selimm_PCP		<=	'0';	
						selp1_PC		<=	'0';
						selPCadd_PC		<=	'0';		
						selPC1_PC		<=	'0';	
						seldataBus_TRF	<=	'0';	
						selPC1_TRF		<=	'0';		
						selLLU_TRF		<=	'0';	
						selSHU_TRF		<=	'0';
						selASU_TRF		<=	'0';		
						selMDU1_TRF		<=	'0';	
						selMDU2_TRF		<=	'0';	
						selIMM_TRF		<=	'0';		
						selp2_SHU		<=	'0';	
						selshim_SHU		<=	'0';	
						selp2_ASU		<=	'0';		
						selimm_ASU		<=	'0';	
						selrs1_TRF		<=	'0';	
						selrd_1_TRF		<=	'0';		
						selrd0_TRF		<=	'0';	
						selrd1_TRF		<=	'0';	
						selPC_addrBus	<=	'0';	
						SE5bits			<=	'0';		
						selADR_addrBus	<=	'0';
						SE6bits			<=	'0';			
						USE8bits		<=	'0';	
						SE8bits			<=	'0';	
						readMEM			<=	'0';			
						writeMEM		<=	'0';	
						readIO			<=	'0';	
						writeIO			<=	'0';			
						logicAND		<=	'0'; 	
						ldIR			<=	'0';	
						writeTRF		<=	'0';		
						ldADR			<=	'0';		
						ldPC			<=	'0';	
						ldMDU1			<=	'0';			
						ldMDU2			<=	'0';		
						onesComp		<=	'0';	
						twosComp		<=	'0';		
						arithADD		<=	'0';	
						arithSUB		<=	'0';	
						arithMUL		<=	'0';		
						arithDIV		<=	'0'; 	
						logicSH			<=	'0';	
						arithSH			<=	'0';			
						startMDU		<=	'0';	
						selrd_2_TRF		<=	'0';	
						selrs2_TRF		<=	'0';
				END	CASE;
				-- SHI
				IF	opcode(7	DOWNTO	2) = SHI	THEN
					selrd_1_TRF	<=	'1';		
					selshim_SHU	<=	'1';		
					selrd0_TRF	<=	'1';
					selSHU_TRF	<=	'1';		
					writeTRF	<=	'1';		
					selPC1_PC	<=	'1';	
					ldPC		<=	'1';
					
					IF	opcode(1) = '0'	THEN
						logicSH	<=	'1';
					ELSE
						arithSH	<=	'1';
					END	IF;
				END	IF;
			WHEN	exec2	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	LOAD	=>
								selADR_addrBus		<=	'1';		
								selPC1_PC			<=	'1';
								readMemAccPolicy	<=	'1';
								
								CASE	(	opcode1downto0	)	IS 
									WHEN	LDR	=>
										seldataBus_TRF	<=	'1';	
										selrd0_TRF		<=	'1';		
										readMEM			<=	'1';
										
										IF	readyMEM = '1'	THEN
											ldPC		<=	'1';	
											writeTRF	<=	'1';
										END	IF;
									WHEN	LIR | LIB	=>
										seldataBus_TRF	<=	'1';	
										selrd0_TRF		<=	'1';		
										readIO			<=	'1';			
										ldPC			<=	'1';			
										writeTRF		<=	'1';
									WHEN	LDB	=>
										readMEM			<=	'1';
										
										IF	readyMEM = '1'	THEN
											ldPC		<=	'1';	
											writeTRB	<=	'1';
										END	IF;
									WHEN	OTHERS	=>
										selADR_addrBus		<=	'0';	
										seldataBus_TRF		<=	'0';	
										selPC1_PC			<=	'0';	
										selrd0_TRF			<=	'0';		
										readMEM				<=	'0';			
										ldPC				<=	'0';	
										writeTRF			<=	'0';		
										readIO				<=	'0';			
										writeTRB			<=	'0';
										readMemAccPolicy	<=	'0';
								END	CASE;
							WHEN	STORE	=>
								selADR_addrBus		<=	'1';		
								selp1_dataBus		<=	'1';		
								selrs1_TRF			<=	'1';
								driveDataBus		<=	'1';			
								selPC1_PC			<=	'1';
								readMemAccPolicy	<=	'1';
								
								CASE	(	opcode1downto0	)	IS 
									WHEN	STR	=>
										writeMEM	<=	'1';	
										
										IF	readyMEM = '1'	THEN
											ldPC	<=	'1';
										END	IF;
									WHEN	SIR | SIB	=>
										writeIO		<=	'1';			
										ldPC		<=	'1';
									WHEN	STB	=>
										writeMEM	<=	'1';		
										ldPC		<=	'1';
									WHEN	OTHERS	=>
										selADR_addrBus		<=	'0';	
										selrs1_TRF			<=	'0';		
										selp1_dataBus		<=	'0';
										driveDataBus		<=	'0';	
										writeIO				<=	'0';			
										selPC1_PC			<=	'0';
										ldPC				<=	'0';			
										writeMEM			<=	'0';
										readMemAccPolicy	<=	'0';
								END	CASE;
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMB	=>
										selADR_addrBus	<=	'1';	
										readIO			<=	'1';			
										seldataBus_PC	<=	'1';
										ldPC			<=	'1';
									WHEN	OTHERS	=> 
										selADR_addrBus	<=	'0';	
										readIO			<=	'0';			
										seldataBus_PC	<=	'0';
										ldPC			<=	'0';
								END	CASE;
							WHEN	OTHERS	=> 
								selADR_addrBus	<=	'0';	
								selrd0_TRF		<=	'0';	
								readIO			<=	'0';	
								writeTRF		<=	'0';		
								readMEM			<=	'0';		
								writeIO			<=	'0';	
								writeMEM		<=	'0';			
								writeTRB		<=	'0';	
								selp1_dataBus	<=	'0';
								seldataBus_PC	<=	'0';	
						END	CASE;
					WHEN	MUL | DIV	=> 
						selrd0_TRF	<=	'1';		
						selMDU1_TRF	<=	'1';		
						writeTRF	<=	'1';
						ldMDU2	<=	'1';
					WHEN	OTHERS	=>
						selADR_addrBus	<=	'0';		
						selrd0_TRF		<=	'0';		
						readIO			<=	'0';	
						writeTRF		<=	'0';		
						readMEM			<=	'0';			
						writeIO			<=	'0';	
						writeMEM		<=	'0';			
						arithMUL		<=	'0';		
						selMDU1_TRF		<=	'0';	
						ldMDU1			<=	'0';			
						arithDIV		<=	'0';		
						driveDataBus	<=	'0';
				END	CASE;
			WHEN	exec3	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMB	=>
										readIHBAddr	<=	'1';     
										selTRB_ADR	<=	'1';   
										ldADR		<=	'1'; 
									WHEN	OTHERS	=>
										readIHBAddr	<=	'0';     
										selTRB_ADR	<=	'0';   
										ldADR		<=	'0'; 
								END	CASE;
							WHEN	OTHERS	=>
								readIHBAddr	<=	'0';     
								selTRB_ADR	<=	'0';   
								ldADR		<=	'0'; 
						END	CASE;
					WHEN	MUL | DIV	=> 
						selrd1_TRF	<=	'1';		
						selMDU2_TRF	<=	'1';		
						writeTRF	<=	'1';
						selPC1_PC	<=	'1';		
						ldPC		<=	'1';
					WHEN	OTHERS	=> 
						writeTRF	<=	'0';		
						selMDU2_TRF	<=	'0';		
						selrd1_TRF	<=	'0';	
						selPC1_PC	<=	'0';		
						ldPC		<=	'0';    		
						readIHBAddr	<=	'0';     
						selTRB_ADR	<=	'0';   	
						ldADR		<=	'0';
				END	CASE;
			WHEN	exec4	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMB	=>
										selADR_addrBus	<=	'1';		
										readIO			<=	'1';      
										seldataBus_TRF	<=	'1';
										writestatusTRF	<=	'1';   	
										selrd0_TRF		<=	'1';
									WHEN	OTHERS	=>
										selADR_addrBus	<=	'0';		
										readIO			<=	'0';      
										seldataBus_TRF	<=	'0';
										writestatusTRF	<=	'0';   	
										selrd0_TRF		<=	'0';
								END	CASE;
							WHEN	OTHERS	=> 
								selADR_addrBus	<=	'0';		
								readIO			<=	'0';      
								seldataBus_TRF	<=	'0';
								writestatusTRF	<=	'0';   	
								selrd0_TRF		<=	'0';
						END	CASE;
					WHEN	OTHERS	=> 
						selADR_addrBus	<=	'0';		
						readIO			<=	'0';		
						seldataBus_TRF	<=	'0';
						writestatusTRF	<=	'0';
				END	CASE;
		END	CASE;
	END	PROCESS;
	
	--	ISsuing next state
	PROCESS	(	pstate, readyMEM, readyMDU, opcode, interrupt, exception, LdAccFault, StAccFault, DividedByZero, R15_LSB	)
	BEGIN
		CASE	(	pstate)	IS
			WHEN	fetch	=>
				IF		interrupt = '1' AND R15_LSB(2) = '1'	THEN
					nstate	<=	interrupt_processing_state1;
				ELSIF	exception = '1' AND R15_LSB(3) = '1'	THEN
					nstate	<=	exception_processing_state1;
				ELSE
					nstate	<=	exec1;
				END	IF;
			WHEN	interrupt_processing_state1	=>
				nstate	<=	interrupt_processing_state2;
			WHEN	interrupt_processing_state2	=>
				nstate	<=	interrupt_processing_state3;
			WHEN	interrupt_processing_state3	=>
				nstate	<=	fetch;
			WHEN	exception_processing_state1	=>
				nstate	<=	exception_processing_state2;
			WHEN	exception_processing_state2	=>
				nstate	<=	fetch;
			WHEN	exec1	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	RSV1	=> 
						nstate	<=	fetch;
					WHEN	RSV2	=> 
						nstate	<=	fetch;
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	LOAD	=>
								IF	LdAccFault = '1' AND R15_LSB(3) = '1'	THEN
									nstate	<=	fetch;
								ELSE
									nstate	<=	exec2;
								END	IF;
							WHEN	STORE	=>
								IF	StAccFault = '1' AND R15_LSB(3) = '1'	THEN
									nstate	<=	fetch;
								ELSE
									nstate	<=	exec2;
								END	IF;
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMR	=>
										nstate	<=	fetch;
									WHEN	JMB	=>
										nstate	<=	exec2;
									WHEN	OTHERS	=>
										nstate	<=	fetch;
								END	CASE;
							WHEN	JMI	=>
								nstate	<=	fetch;				
							WHEN	OTHERS	=>
								nstate	<=	fetch;
						END	CASE;
					WHEN	ANR | ANI | MSI | MHI | SLR | SAR | ADR | SUR | ADI | SUI	=> 
						nstate	<=	fetch;
					WHEN	MUL		=> 
						IF	readyMDU = '1'	THEN 
							nstate	<=	exec2;
						ELSE
							nstate	<=	exec1;
						END	IF;
					WHEN	DIV		=> 
						IF	DividedByZero = '1' AND R15_LSB(3) = '1'	THEN
							nstate	<=	fetch;
						ELSE
							IF	readyMDU = '1'	THEN 
								nstate	<=	exec2;
							ELSE
								nstate	<=	exec1;
							END	IF;
						END	IF;
					WHEN	INST15	=>
						CASE	(	opcode3downto1	)	IS
							WHEN	INST151 | CMI | BRC | BRR | NTR | NTD	=> 
								nstate	<=	fetch;
							WHEN	OTHERS	=>
								nstate	<=	fetch;
						END	CASE;
					WHEN	OTHERS	=>
						nstate	<=	fetch;
				END	CASE;
				-- SHI
				IF	opcode(7	DOWNTO	2) = SHI	THEN
					nstate	<=	fetch;
				END	IF;
			WHEN	exec2	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	LOAD	=>
								CASE	(	opcode1downto0	)	IS 
									WHEN	LDR | LDB	=>
										IF	readyMEM = '1'	THEN
											nstate	<=	fetch;
										ELSE
											nstate	<=	exec2;
										END	IF;
									WHEN	LIR | LIB	=>
										nstate	<=	fetch;
									WHEN	OTHERS	=>
										nstate	<=	fetch;
								END	CASE;
							WHEN	STORE	=>
								CASE	(	opcode1downto0	)	IS 
									WHEN	STR | STB	=>
										IF	readyMEM = '1'	THEN
											nstate	<=	fetch;
										ELSE
											nstate	<=	exec2;
										END	IF;
									WHEN	SIR | SIB	=>
										nstate	<=	fetch;
									WHEN	OTHERS	=>
										nstate	<=	fetch;
								END	CASE;
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMB	=>
										IF	opcode(1) = '1'	THEN
											nstate	<=	exec3;
										ELSE
											nstate	<=	fetch;
										END	IF;
									WHEN	OTHERS	=> 
										nstate	<=	fetch;
								END	CASE;
							WHEN	OTHERS	=> 
								nstate	<=	fetch;
						END	CASE;
					WHEN	MUL | DIV	=> 
						nstate	<=	exec3;	
					WHEN	OTHERS	=>
						nstate	<=	fetch;
				END	CASE;
			WHEN	exec3	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMB	=>
										nstate	<=	exec4;
									WHEN	OTHERS	=>
										nstate	<=	fetch; 
								END	CASE;
							WHEN	OTHERS	=>
								nstate	<=	fetch;
						END	CASE;
					WHEN	MUL | DIV	=> 
						nstate	<=	fetch;
					WHEN	OTHERS	=> 
						nstate	<=	fetch;
				END	CASE;
			WHEN	exec4	=>
				CASE	(	opcode7downto4	)	IS
					WHEN	INST2	=>
						CASE	(	opcode3downto2	)	IS
							WHEN	JUMPR	=> 
								CASE	(	opcode0	)	IS
									WHEN	JMB	=>
										nstate	<=	fetch;
									WHEN	OTHERS	=>
										nstate	<=	fetch;
								END	CASE;
							WHEN	OTHERS	=> 
								nstate	<=	fetch;
						END	CASE;
					WHEN	OTHERS	=> 
						nstate	<=	fetch;
				END	CASE;
		END	CASE;
	END	PROCESS;
	
	PROCESS	(	clk, rst	)
	BEGIN
		IF		rst = '1'	THEN
			pstate	<=	fetch;
		ELSIF	clk = '1' AND clk'EVENT	THEN
			pstate	<=	nstate;
		END	IF;
	END	PROCESS;
END	ARCHITECTURE	behavior;
------------------------------------------------------------------------------------------------
