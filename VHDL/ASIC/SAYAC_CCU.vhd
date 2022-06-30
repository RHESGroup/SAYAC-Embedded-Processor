--******************************************************************************
--	Filename:		SAYAC_CCU.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
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
--	Control Control Unit (CCU) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;	
	
ENTITY CCU IS
	PORT (
		clk, rst, readyMEM, readyMDU : IN STD_LOGIC;
		exception : IN STD_LOGIC;
		-- Interrupt signal receiving from Programmable Interrupt Controller (PIC)
		interrupt : IN STD_LOGIC;
		--
		opcode    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIB       : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  --Flags Intrepretation Bits
	    seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
        selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF, 
		selrd1_TRF, writeTRF, selp1_PCP, selimm_PCP, 
        selp1_PC, selPCadd_PC, selPC1_PC,
        selPC_addrBus, selADR_addrBus, driveDataBus,
        SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits,
        selp2_ASU, selimm_ASU, arithADD, arithSUB,
        logicAND, onesComp, twosComp,
        selp2_SHU, selshim_SHU, logicSH, arithSH,
        ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU,
        ldIR, ldADR, ldPC,
        readMEM, writeMEM, readIO, writeIO,
		-- New additinal control signals for handling interrupt
		readstatusTRF, writestatusTRF, writeTRB, USE12bits, selPC_PCP, 
        selTRB_PCP, sel1_ADR, selPCP_ADR, seldataBus_PC, selp1_dataBus, 
		selPC_dataBus, selPC1_dataBus, readIHBAddr, readTopStackAddr, 
		selrs1_imm, selcnt_imm, rst_cnt, inc_cnt, IntEnable, IntServicing, 
		selTRB_ADR, selPCP_addrBus, selESA_PC, ldExcBaseAddr,
		readExcBaseAddr, readExcOffAddr, ExcEnable, ExcServicing, 
		--
		setFlags    : OUT STD_LOGIC;
		enFlag      : OUT STD_LOGIC;
		InvalidInst : OUT STD_LOGIC;
		R15_LSB     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		selFlag     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY CCU;

ARCHITECTURE behavior OF CCU IS
	CONSTANT RSV1   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	CONSTANT RSV2   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
	CONSTANT INST2  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
	-- New additinal instructions for handling interrupt
	CONSTANT LOAD   : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	CONSTANT LDR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	CONSTANT LIR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
	CONSTANT LDB    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
	CONSTANT LIB    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
	CONSTANT STORE  : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
	CONSTANT STR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	CONSTANT SIR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
	CONSTANT STB    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
	CONSTANT SIB    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
	CONSTANT JUMPR  : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
	CONSTANT JMR    : STD_LOGIC                    := '0';
	CONSTANT JMB    : STD_LOGIC                    := '1';
	--
	CONSTANT JMI    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
	CONSTANT ANR    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
	CONSTANT ANI    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
	CONSTANT MSI    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
	CONSTANT MHI    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
	CONSTANT SLR    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
	CONSTANT SAR    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
	CONSTANT ADR    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
	CONSTANT SUR    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
	CONSTANT ADI    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
	CONSTANT SUI    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
	CONSTANT MUL    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
	CONSTANT DIV    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
	CONSTANT INST15 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	CONSTANT CMR    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
	CONSTANT CMI    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
	CONSTANT BRC    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
	CONSTANT BRR    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
	CONSTANT SHI    : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111110";
	CONSTANT NTR    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
	CONSTANT NTD    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";
	
	TYPE state IS (fetch, 
				   interrupt_processing_state1, interrupt_processing_state2, 
				   interrupt_processing_state3, 
				   exception_processing_state1, exception_processing_state2,
				   exec1, exec2, exec3, exec4);
	SIGNAL pstate, nstate : state := fetch;
	
	ALIAS opcode7downto4 : STD_LOGIC_VECTOR(3 DOWNTO 0) IS opcode(7 DOWNTO 4);
	ALIAS opcode3downto2 : STD_LOGIC_VECTOR(1 DOWNTO 0) IS opcode(3 DOWNTO 2);
	ALIAS opcode3downto1 : STD_LOGIC_VECTOR(2 DOWNTO 0) IS opcode(3 DOWNTO 1);
	ALIAS opcode1downto0 : STD_LOGIC_VECTOR(1 DOWNTO 0) IS opcode(1 DOWNTO 0);
	ALIAS opcode0        : STD_LOGIC                    IS opcode(0);
	
	ALIAS RFI : STD_LOGIC_VECTOR(2 DOWNTO 0) IS FIB(2 DOWNTO 0);
BEGIN	
	-- Issuing control signals
	PROCESS (pstate, readyMEM, readyMDU, opcode, FIB, R15_LSB)
	BEGIN
		seldataBus_TRF <= '0';	selPC1_TRF <= '0';		selLLU_TRF <= '0'; 
		selSHU_TRF <= '0';	    selASU_TRF <= '0';		selMDU1_TRF <= '0'; 
		selMDU2_TRF <= '0';	    selIMM_TRF <= '0';		selrs1_TRF <= '0';	    
		selrd_1_TRF <= '0';		selrd0_TRF <= '0';		selrd1_TRF <= '0';	    
		writeTRF <= '0';		selp1_PCP <= '0';		selimm_PCP <= '0';	
		selp1_PC <= '0';		selPCadd_PC <= '0';		selPC1_PC <= '0';       
		selPC_addrBus <= '0';	selADR_addrBus <= '0';	SE5bits <= '0';			
		SE6bits <= '0';			USE8bits <= '0';		SE8bits <= '0';			
		p1lowbits <= '0';		selp2_ASU <= '0';		selimm_ASU <= '0';		
		arithADD <= '0';		arithSUB <= '0';        logicAND <= '0';		
		onesComp <= '0';		twosComp <= '0';        selp2_SHU <= '0';		
		selshim_SHU <= '0';		logicSH <= '0';			arithSH <= '0';
		ldMDU1 <= '0';			ldMDU2 <= '0';			arithMUL <= '0';
		arithDIV <= '0';		startMDU <= '0';        ldIR <= '0';
		ldADR <= '0';			ldPC <= '0';	        readMEM <= '0';
		writeMEM <= '0';		readIO <= '0';			writeIO <= '0';		
		selrd_2_TRF <= '0';		selrs2_TRF <= '0';		driveDataBus <= '0';
		setFlags <= '0';		enFlag <= '0';
		selFlag <= (OTHERS => '0');			
		readstatusTRF <= '0';	writeTRB <= '0';		USE12bits <= '0';
		selPC_PCP <= '0';		selTRB_PCP <= '0';		sel1_ADR <= '0';
		selPCP_ADR <= '0';		seldataBus_PC <= '0';	selp1_dataBus <= '0';
		selPC_dataBus <= '0';	selPC1_dataBus <= '0';	readIHBAddr <= '0';		
		readTopStackAddr <= '0';
		selrs1_imm <= '0';      selcnt_imm <= '0';      rst_cnt <= '0';
		inc_cnt <= '0';         selTRB_ADR <= '0';    	writestatusTRF <= '0';
		IntEnable <= '0';		IntServicing <= '0';	selPCP_addrBus <= '0';
		selESA_PC <= '0';		ldExcBaseAddr <= '0';	readExcBaseAddr <= '0';	
		readExcOffAddr <= '0';	ExcEnable <= '0';		ExcServicing <= '0';
		InvalidInst <= '0';
		
		CASE (pstate) IS
			WHEN fetch =>
				selPC_addrBus <= '1';		ldIR <= '1';			rst_cnt <= '0';
			WHEN interrupt_processing_state1 =>
				readIHBAddr <= '1';			selTRB_PCP <= '1';		selcnt_imm <= '1';     
				USE12bits <= '1';			selimm_PCP <= '1';		selPCP_addrBus <= '1';		
				readstatusTRF <= '1';   	selp1_dataBus <= '1';	writeIO <= '1'; 
				IntEnable <= '0'; 			IntServicing <= '1';	selFlag <= "10000001";    	
				enFlag <= '1';   			inc_cnt <= '1';			driveDataBus <= '1';
			WHEN interrupt_processing_state2 =>
				readIHBAddr <= '1';         selTRB_PCP <= '1';    	selcnt_imm <= '1';     
				USE12bits <= '1';			selimm_PCP <= '1';   	selPCP_addrBus <= '1';    	
				selPC1_dataBus <= '1';  	writeIO <= '1';  		inc_cnt <= '1';
				driveDataBus <= '1';
			WHEN interrupt_processing_state3 =>
				readIHBAddr <= '1';			selTRB_PCP <= '1';		selcnt_imm <= '1';     
				USE12bits <= '1';			selimm_PCP <= '1';		selPCP_addrBus <= '1';		
				readIO <= '1';				seldataBus_PC <= '1';	ldPC <= '1';
				rst_cnt <= '1';
			WHEN exception_processing_state1 =>
				readExcBaseAddr <= '1';		ldExcBaseAddr <= '1';	selTRB_PCP <= '1';
				selcnt_imm <= '1';     		USE12bits <= '1';		selimm_PCP <= '1';		
				selPCP_addrBus <= '1';		selPC_dataBus <= '1';  	writeIO <= '1';
				inc_cnt <= '1';				ExcEnable <= '0'; 		ExcServicing <= '1';
				selFlag <= "01001000";    	enFlag <= '1';   		driveDataBus <= '1';
			WHEN exception_processing_state2 =>
				readExcOffAddr <= '1';		selESA_PC <= '1';		ldPC <= '1';				
				rst_cnt <= '1';
			WHEN exec1 =>
				CASE (opcode7downto4) IS
					WHEN RSV1 => 
						ldPC <= '1';		selPC1_PC <= '1';  			
					WHEN RSV2 => 
						ldPC <= '1';		selPC1_PC <= '1'; 	
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LOAD =>
								selrs1_TRF <= '1';		selp1_PCP <= '1';	ldADR <= '1';
								CASE (opcode1downto0) IS 
									WHEN LDR | LIR | LDB =>
										sel1_ADR <= '1';
									WHEN LIB =>
										readIHBAddr <= '1'; 		selTRB_PCP <= '1';	selPCP_ADR <= '1';
									WHEN OTHERS =>
										sel1_ADR <= '0';		readIHBAddr <= '0';	selTRB_PCP <= '0';		
										selPCP_ADR <= '0';
								END CASE;
							WHEN STORE =>
								selrd_1_TRF <= '1';		selp1_PCP <= '1';	ldADR <= '1';	
								CASE (opcode1downto0) IS 
									WHEN STR | SIR =>
										sel1_ADR <= '1';
									WHEN STB =>
										selTRB_PCP <= '1';		selPCP_ADR <= '1';	readTopStackAddr <= '1';
									WHEN SIB =>
										readIHBAddr <= '1';		selTRB_PCP <= '1';	selPCP_ADR <= '1';
									WHEN OTHERS =>
										sel1_ADR <= '0';		selTRB_PCP <= '0';	selPCP_ADR <= '0';	
										readIHBAddr <= '0';		readTopStackAddr <= '0';
								END CASE;
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMR =>
										selrs1_TRF <= '1';		selp1_PCP <= '1';	selPC_PCP <= '1';
										selPCadd_PC <= '1';		ldPC <= '1';					
										IF opcode(1) = '1' THEN
											selrd0_TRF <= '1';		selPC1_TRF <= '1';		
											writeTRF <= '1';
										END IF;
									WHEN JMB =>
										selrs1_imm <= '1';		USE12bits <= '1';	selimm_PCP <= '1';	
										selTRB_PCP <= '1';		selPCP_ADR <= '1';	ldADR <= '1';
									WHEN OTHERS =>
										selrs1_TRF <= '0';		selp1_PCP <= '0';	selPC_PCP <= '0';
										selPCadd_PC <= '0';		ldPC <= '0';		selrd0_TRF <= '0';
										selPC1_TRF <= '0';		writeTRF <= '0';	selrs1_imm <= '0';		
										USE12bits <= '0';		selimm_PCP <= '0';	selTRB_PCP <= '0';		
										selPCP_ADR <= '0';		ldADR <= '0';
								END CASE;
							WHEN JMI =>
								SE6bits <= '1';			selimm_PCP <= '1';	selPC_PCP <= '1';	
								selPCadd_PC <= '1';		ldPC <= '1';		selrd0_TRF <= '1';	
								selPC1_TRF <= '1';		writeTRF <= '1';				
							WHEN OTHERS =>
								selrs1_TRF <= '0';		ldADR <= '0';		selp1_PCP <= '0';
								ldPC <= '0';			selPCadd_PC <= '0';	selrd0_TRF <= '0';	
								selPC1_TRF <= '0';		SE6bits <= '0';		selimm_PCP <= '0';	
								writeTRF <= '0';		selrd_1_TRF <= '0';	
								sel1_ADR <= '0';		writeTRB <= '0';	readIHBAddr <= '0';
								selTRB_PCP <= '0';		selPCP_ADR <= '0';	selp1_dataBus <= '0';
								selPC_PCP <= '0';		USE12bits <= '0';	readTopStackAddr <= '0';
								seldataBus_PC <= '0';	
						END CASE;
					WHEN ANR =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		selp2_ASU <= '1';	
						logicAND <= '1';		selrd0_TRF <= '1';		selLLU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';	
					WHEN ANI =>
						selrd_1_TRF <= '1';		USE8bits <= '1';		selimm_ASU <= '1';	
						logicAND <= '1';		selrd0_TRF <= '1';		selLLU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
					WHEN MSI =>
						SE8bits <= '1';			selrd0_TRF <= '1';		selIMM_TRF <= '1';
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
					WHEN MHI =>
						selrd_1_TRF <= '1';		p1lowbits <= '1';		selrd0_TRF <= '1';
						selIMM_TRF <= '1';		writeTRF <= '1';		selPC1_PC <= '1';
						ldPC <= '1';			
					WHEN SLR =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		selp2_SHU <= '1';
						logicSH <= '1';			selrd0_TRF <= '1';		selSHU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';	
					WHEN SAR =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		selp2_SHU <= '1';
						arithSH <= '1';			selrd0_TRF <= '1';		selSHU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';	
					WHEN ADR =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		selp2_ASU <= '1';
						arithADD <= '1';		selrd0_TRF <= '1';		selASU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';	
					WHEN SUR =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		selp2_ASU <= '1';
						arithSUB <= '1';		selrd0_TRF <= '1';		selASU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
					WHEN ADI =>
						selrd_1_TRF <= '1';		SE8bits <= '1';			selimm_ASU <= '1';
						arithADD <= '1';		selrd0_TRF <= '1';		selASU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
					WHEN SUI =>
						selrd_1_TRF <= '1';		SE8bits <= '1';			selimm_ASU <= '1';
						arithSUB <= '1';		selrd0_TRF <= '1';		selASU_TRF <= '1';	
						writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
					WHEN MUL =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		arithMUL <= '1';
						startMDU <= '1';
						IF readyMDU = '1' THEN 
							ldMDU1 <= '1';
						END IF;
					WHEN DIV =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		arithDIV <= '1';
						startMDU <= '1';	
						IF readyMDU = '1' THEN 
							ldMDU1 <= '1';
						END IF;
					WHEN INST15 =>
						CASE (opcode3downto1) IS
							WHEN CMR =>
								selrs1_TRF <= '1';		selrd_2_TRF <= '1';		selp2_ASU <= '1';		
								selPC1_PC <= '1';		ldPC <= '1';			enFlag <= '1';
								selFlag <= "00110000";
							WHEN CMI =>
								selrd_1_TRF <= '1';		SE5bits <= '1';			selimm_ASU <= '1';	
								selPC1_PC <= '1';		ldPC <= '1';			enFlag <= '1';
								selFlag <= "00110000";
							WHEN BRC =>
								CASE (RFI) IS
									WHEN "000" =>
										ldPC <= '1';
										IF R15_LSB(4) = '1' THEN						--eq
											selrd_1_TRF <= '1';		selp1_PC <= '1';
										ELSE
											selPC1_PC <= '1';		
										END IF;
									WHEN "001" =>
										ldPC <= '1';
										IF R15_LSB(5) = '0' AND R15_LSB(4) = '0' THEN	--lt
											selrd_1_TRF <= '1';		selp1_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN "010" =>
										ldPC <= '1';
										IF R15_LSB(5) = '1' THEN						--gt
											selrd_1_TRF <= '1';		selp1_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN "011" =>
										ldPC <= '1';
										IF R15_LSB(5) = '1' OR R15_LSB(4) = '1' THEN	--gt/eq
											selrd_1_TRF <= '1';		selp1_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN "100" =>
										ldPC <= '1';
										IF R15_LSB(5) = '0' OR R15_LSB(4) = '1' THEN	--lt/eq
											selrd_1_TRF <= '1';		selp1_PC <= '1';
										ELSE
											selPC1_PC <= '1';		
										END IF;
									WHEN "101" =>
										ldPC <= '1';
										IF R15_LSB(4) = '0' THEN						--neq
											selrd_1_TRF <= '1';		selp1_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN OTHERS =>
										selrd_1_TRF <= '0';		selp1_PC <= '0';	ldPC <= '0';
										selPC1_PC <= '0';
								END CASE;
							WHEN BRR =>
								CASE (RFI) IS
									WHEN "000" =>
										ldPC <= '1';
										IF R15_LSB(4) = '1' THEN						--eq
											selrd_1_TRF <= '1';		selp1_PCP <= '1';		selPC_PCP <= '1';
											selPCadd_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN "001" =>
										ldPC <= '1';
										IF R15_LSB(5) = '0' AND R15_LSB(4) = '0' THEN	--lt
											selrd_1_TRF <= '1';		selp1_PCP <= '1';		selPC_PCP <= '1';
											selPCadd_PC <= '1';	
										ELSE
											selPC1_PC <= '1';											
										END IF;
									WHEN "010" =>
										ldPC <= '1';
										IF R15_LSB(5) = '1' THEN						--gt
											selrd_1_TRF <= '1';		selp1_PCP <= '1';		selPC_PCP <= '1';
											selPCadd_PC <= '1';	
										ELSE
											selPC1_PC <= '1';		
										END IF;
									WHEN "011" =>
										ldPC <= '1';
										IF R15_LSB(5) = '1' OR R15_LSB(4) = '1' THEN	--gt/eq
											selrd_1_TRF <= '1';		selp1_PCP <= '1';		selPC_PCP <= '1';
											selPCadd_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN "100" =>
										ldPC <= '1';
										IF R15_LSB(5) = '0' OR R15_LSB(4) = '1' THEN	--lt/eq
											selrd_1_TRF <= '1';		selp1_PCP <= '1';		selPC_PCP <= '1';
											selPCadd_PC <= '1';	
										ELSE
											selPC1_PC <= '1';
										END IF;
									WHEN "101" =>
										ldPC <= '1';
										IF R15_LSB(4) = '0' THEN						--neq
											selrd_1_TRF <= '1';		selp1_PC <= '1';		selPC_PCP <= '1';
											selPCadd_PC <= '1';
										ELSE
											selPC1_PC <= '1';	
										END IF;
									WHEN OTHERS =>
										selrd_1_TRF <= '0';		selp1_PCP <= '0';		selPCadd_PC <= '0';	
										ldPC <= '0';			selPC_PCP <= '0';
								END CASE;
							WHEN NTR =>
								selrs1_TRF <= '1';		selrd0_TRF <= '1';		selLLU_TRF <= '1';	
								writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
								IF opcode(0) = '0' THEN
									onesComp <= '1';
								ELSE
									twosComp <= '1';
								END IF;
							WHEN NTD =>
								selrd_1_TRF <= '1';		selrd0_TRF <= '1'; 		selLLU_TRF <= '1';	
								writeTRF <= '1';		selPC1_PC <= '1';		ldPC <= '1';
								IF opcode(0) = '0' THEN
									onesComp <= '1';
								ELSE
									twosComp <= '1';
								END IF;
							WHEN OTHERS =>
								selrs1_TRF <= '0';		selp2_ASU <= '0';		SE5bits <= '0';	
								selimm_ASU <= '0';		selrd_1_TRF <= '0';		selp1_PC <= '0';	
								writeTRF <= '0';		selPCadd_PC <= '0';		selLLU_TRF <= '0';	
								selrd0_TRF <= '0';		onesComp <= '0';		twosComp <= '0';	
								ldPC <= '0';			selrs2_TRF <= '0';		enFlag <= '0';
								selFlag <= (OTHERS => '0');
						END CASE;
					WHEN OTHERS =>
						InvalidInst <= '1';
						selp1_PCP <= '0';		selimm_PCP <= '0';	selp1_PC <= '0';
						selPCadd_PC <= '0';		selPC1_PC <= '0';	seldataBus_TRF <= '0';	
						selPC1_TRF <= '0';		selLLU_TRF <= '0';	selSHU_TRF <= '0';
						selASU_TRF <= '0';		selMDU1_TRF <= '0';	selMDU2_TRF <= '0';	
						selIMM_TRF <= '0';		selp2_SHU <= '0';	selshim_SHU <= '0';	
						selp2_ASU <= '0';		selimm_ASU <= '0';	selrs1_TRF <= '0';	
						selrd_1_TRF <= '0';		selrd0_TRF <= '0';	selrd1_TRF <= '0';	
						selPC_addrBus <= '0';	SE5bits <= '0';		selADR_addrBus <= '0';
						SE6bits <= '0';			USE8bits <= '0';	SE8bits <= '0';	
						readMEM <= '0';			writeMEM <= '0';	readIO <= '0';	
						writeIO <= '0';			logicAND <= '0'; 	ldIR <= '0';	
						writeTRF <= '0';		ldADR <= '0';		ldPC <= '0';	
						ldMDU1 <= '0';			ldMDU2 <= '0';		onesComp <= '0';	
						twosComp <= '0';		arithADD <= '0';	arithSUB <= '0';	
						arithMUL <= '0';		arithDIV <= '0'; 	logicSH <= '0';	
						arithSH <= '0';			startMDU <= '0';	selrd_2_TRF <= '0';	
						selrs2_TRF <= '0';
				END CASE;
				-- SHI
				IF opcode(7 DOWNTO 2) = SHI THEN
					selrd_1_TRF <= '1';		selshim_SHU <= '1';		selrd0_TRF <= '1';
					selSHU_TRF <= '1';		writeTRF <= '1';		selPC1_PC <= '1';	
					ldPC <= '1';
					IF opcode(1) = '0' THEN
						logicSH <= '1';
					ELSE
						arithSH <= '1';
					END IF;
				END IF;
			WHEN exec2 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LOAD =>
								selADR_addrBus <= '1';		selPC1_PC <= '1';
								CASE (opcode1downto0) IS 
									WHEN LDR =>
										seldataBus_TRF <= '1';	selrd0_TRF <= '1';		readMEM <= '1';
										IF readyMEM = '1' THEN
											ldPC <= '1';	writeTRF <= '1';
										END IF;
									WHEN LIR | LIB =>
										seldataBus_TRF <= '1';	selrd0_TRF <= '1';		readIO <= '1';			
										ldPC <= '1';			writeTRF <= '1';
									WHEN LDB =>
										readMEM <= '1';
										IF readyMEM = '1' THEN
											ldPC <= '1';	writeTRB <= '1';
										END IF;
									WHEN OTHERS =>
										selADR_addrBus <= '0';	seldataBus_TRF <= '0';	selPC1_PC <= '0';	
										selrd0_TRF <= '0';		readMEM <= '0';			ldPC <= '0';	
										writeTRF <= '0';		readIO <= '0';			writeTRB <= '0';
								END CASE;
							WHEN STORE =>
								selADR_addrBus <= '1';		selp1_dataBus <= '1';		selrs1_TRF <= '1';
								driveDataBus <= '1';		selPC1_PC <= '1';
								CASE (opcode1downto0) IS 
									WHEN STR =>
										writeMEM <= '1';	
										IF readyMEM = '1' THEN
											ldPC <= '1';
										END IF;
									WHEN SIR | SIB =>
										writeIO <= '1';			ldPC <= '1';
									WHEN STB =>
										writeMEM <= '1';		ldPC <= '1';
									WHEN OTHERS =>
										selADR_addrBus <= '0';	selrs1_TRF <= '0';		selp1_dataBus <= '0';
										driveDataBus <= '0';	writeIO <= '0';			selPC1_PC <= '0';
										ldPC <= '0';			writeMEM <= '0';
								END CASE;
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMB =>
										selADR_addrBus <= '1';	readIO <= '1';			seldataBus_PC <= '1';
										ldPC <= '1';
									WHEN OTHERS => 
										selADR_addrBus <= '0';	readIO <= '0';			seldataBus_PC <= '0';
										ldPC <= '0';
								END CASE;
							WHEN OTHERS => 
								selADR_addrBus <= '0';	selrd0_TRF <= '0';	readIO <= '0';	
								writeTRF <= '0';		readMEM <= '0';		writeIO <= '0';	
								writeMEM<= '0';			writeTRB <= '0';	selp1_dataBus <= '0';
								seldataBus_PC <= '0';	
						END CASE;
					WHEN MUL | DIV => 
						selrd0_TRF <= '1';		selMDU1_TRF <= '1';		writeTRF <= '1';
						ldMDU2 <= '1';
					WHEN OTHERS =>
						selADR_addrBus <= '0';		selrd0_TRF <= '0';		readIO <= '0';	
						writeTRF <= '0';		readMEM <= '0';			writeIO <= '0';	
						writeMEM<= '0';			arithMUL <= '0';		selMDU1_TRF <= '0';	
						ldMDU1 <= '0';			arithDIV <= '0';		driveDataBus <= '0';
				END CASE;
			WHEN exec3 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMB =>
										readIHBAddr <= '1';     selTRB_ADR <= '1';   ldADR <= '1'; 
									WHEN OTHERS =>
										readIHBAddr <= '0';     selTRB_ADR <= '0';   ldADR <= '0'; 
								END CASE;
							WHEN OTHERS =>
								readIHBAddr <= '0';     selTRB_ADR <= '0';   ldADR <= '0'; 
						END CASE;
					WHEN MUL | DIV => 
						selrd1_TRF <= '1';		selMDU2_TRF <= '1';		writeTRF <= '1';
						selPC1_PC <= '1';		ldPC <= '1';
					WHEN OTHERS => 
						writeTRF <= '0';		selMDU2_TRF <= '0';		selrd1_TRF <= '0';	
						selPC1_PC <= '0';		ldPC <= '0';    		readIHBAddr <= '0';     
						selTRB_ADR <= '0';   	ldADR <= '0';
				END CASE;
			WHEN exec4 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMB =>
										selADR_addrBus <= '1';		readIO <= '1';      seldataBus_TRF <= '1';
										writestatusTRF <= '1';   	selrd0_TRF <= '1';
									WHEN OTHERS =>
										selADR_addrBus <= '0';		readIO <= '0';      seldataBus_TRF <= '0';
										writestatusTRF <= '0';   	selrd0_TRF <= '0';
								END CASE;
							WHEN OTHERS => 
								selADR_addrBus <= '0';		readIO <= '0';      seldataBus_TRF <= '0';
								writestatusTRF <= '0';   	selrd0_TRF <= '0';
						END CASE;
					WHEN OTHERS => 
						selADR_addrBus <= '0';		readIO <= '0';		seldataBus_TRF <= '0';
						writestatusTRF <= '0';
				END CASE;
		END CASE;
	END PROCESS;
	
	-- Issuing next state
	PROCESS (pstate, readyMEM, readyMDU, opcode)
	BEGIN
		CASE (pstate) IS
			WHEN fetch =>
				IF interrupt = '1' AND R15_LSB(0) = '1' THEN
					nstate <= interrupt_processing_state1;
				ELSIF exception = '1' AND R15_LSB(4) = '1' THEN
					nstate <= exception_processing_state1;
				ELSE
					nstate <= exec1;
				END IF;
			WHEN interrupt_processing_state1 =>
				nstate <= interrupt_processing_state2;
			WHEN interrupt_processing_state2 =>
				nstate <= interrupt_processing_state3;
			WHEN interrupt_processing_state3 =>
				nstate <= fetch;
			WHEN exception_processing_state1 =>
				nstate <= exception_processing_state2;
			WHEN exception_processing_state2 =>
				nstate <= fetch;
			WHEN exec1 =>
				CASE (opcode7downto4) IS
					WHEN RSV1 => 
						nstate <= fetch;
					WHEN RSV2 => 
						nstate <= fetch;
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LOAD | STORE =>
								nstate <= exec2;
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMR =>
										nstate <= fetch;
									WHEN JMB =>
										nstate <= exec2;
									WHEN OTHERS =>
										nstate <= fetch;
								END CASE;
							WHEN JMI =>
								nstate <= fetch;				
							WHEN OTHERS =>
								nstate <= fetch;
						END CASE;
					WHEN ANR | ANI | MSI | MHI | SLR | SAR | ADR | SUR | ADI | SUI => 
						nstate <= fetch;
					WHEN MUL | DIV => 
						IF readyMDU = '1' THEN 
							nstate <= exec2;
						ELSE
							nstate <= exec1;
						END IF;
					WHEN INST15 =>
						CASE (opcode3downto1) IS
							WHEN CMR | CMI | BRC | BRR | NTR | NTD => 
								nstate <= fetch;
							WHEN OTHERS =>
								nstate <= fetch;
						END CASE;
					WHEN OTHERS =>
						nstate <= fetch;
				END CASE;
				-- SHI
				IF opcode(7 DOWNTO 2) = SHI THEN
					nstate <= fetch;
				END IF;
			WHEN exec2 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LOAD =>
								CASE (opcode1downto0) IS 
									WHEN LDR | LDB =>
										IF readyMEM = '1' THEN
											nstate <= fetch;
										ELSE
											nstate <= exec2;
										END IF;
									WHEN LIR | LIB =>
										nstate <= fetch;
									WHEN OTHERS =>
										nstate <= fetch;
								END CASE;
							WHEN STORE =>
								CASE (opcode1downto0) IS 
									WHEN STR | STB =>
										IF readyMEM = '1' THEN
											nstate <= fetch;
										ELSE
											nstate <= exec2;
										END IF;
									WHEN SIR | SIB =>
										nstate <= fetch;
									WHEN OTHERS =>
										nstate <= fetch;
								END CASE;
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMB =>
										IF opcode(1) = '1' THEN
											nstate <= exec3;
										ELSE
											nstate <= fetch;
										END IF;
									WHEN OTHERS => 
										nstate <= fetch;
								END CASE;
							WHEN OTHERS => 
								nstate <= fetch;
						END CASE;
					WHEN MUL | DIV => 
						nstate <= exec3;	
					WHEN OTHERS =>
						nstate <= fetch;
				END CASE;
			WHEN exec3 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMB =>
										nstate <= exec4;
									WHEN OTHERS =>
										nstate <= fetch; 
								END CASE;
							WHEN OTHERS =>
								nstate <= fetch;
						END CASE;
					WHEN MUL | DIV => 
						nstate <= fetch;
					WHEN OTHERS => 
						nstate <= fetch;
				END CASE;
			WHEN exec4 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN JUMPR => 
								CASE (opcode0) is
									WHEN JMB =>
										nstate <= fetch;
									WHEN OTHERS =>
										nstate <= fetch;
								END CASE;
							WHEN OTHERS => 
								nstate <= fetch;
						END CASE;
					WHEN OTHERS => 
						nstate <= fetch;
				END CASE;
		END CASE;
	END PROCESS;
	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			pstate <= fetch;
		ELSIF clk = '1' AND clk'EVENT THEN
			pstate <= nstate;
		END IF;
	END PROCESS;
END ARCHITECTURE behavior;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_CCU IS
END ENTITY test_CCU;
ARCHITECTURE test OF test_CCU IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, readyMEM, readyMDU : STD_LOGIC;
	SIGNAL exception : STD_LOGIC;
	SIGNAL interrupt : STD_LOGIC;
	SIGNAL seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF : STD_LOGIC; 
	SIGNAL selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF : STD_LOGIC;
    SIGNAL selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF, 
		   selrd1_TRF, writeTRF : STD_LOGIC;
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
	SIGNAL readstatusTRF, writestatusTRF, writeTRB, USE12bits, selPC_PCP, 
           selTRB_PCP, sel1_ADR, selPCP_ADR, seldataBus_PC, selp1_dataBus, 
		   selPC_dataBus, selPC1_dataBus, readIHBAddr, readTopStackAddr, 
		   selrs1_imm, selcnt_imm, rst_cnt, inc_cnt, IntEnable, IntServicing, 
		   selTRB_ADR, selPCP_addrBus, selESA_PC, ldExcBaseAddr,
		   readExcBaseAddr, readExcOffAddr, ExcEnable, ExcServicing : STD_LOGIC;
	SIGNAL opcode  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL FIB     : STD_LOGIC_VECTOR(4 DOWNTO 0);  --FLags Intrepretation Bits
	SIGNAL setFlags, enFlag, InvalidInst : STD_LOGIC;
	SIGNAL R15_LSB : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL selFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN	
	clk <= NOT clk AFTER 1 NS WHEN NOW <= 380 NS ELSE '0';
	rst <= '1', '0' AFTER 1 NS;
	readyMEM <= '0', '1' AFTER 4 NS, '0' AFTER 16 NS;
	readyMDU <= '0', '1' AFTER 50 NS;
	FIB <= "00000", "00011" AFTER 50 NS;
	R15_LSB <= X"00", X"F1" AFTER 50 NS;
	-- opcode <= X"00", X"01" AFTER 1 NS, X"20" AFTER 2 NS, X"22" AFTER 6 NS, 
			  -- X"26" AFTER 14 NS, X"2A" AFTER 22 NS, X"30" AFTER 26 NS, 
			  -- X"50" AFTER 30 NS, X"70" AFTER 34 NS, X"90" AFTER 38 NS, 
			  -- X"B0" AFTER 42 NS, X"D0" AFTER 46 NS, X"E0" AFTER 54 NS, 
			  -- X"F2" AFTER 60 NS, X"F6" AFTER 64 NS, X"FA" AFTER 68 NS,
			  -- X"FD" AFTER 72 NS, X"FF" AFTER 76 NS;
	opcode <= X"00", X"01" AFTER 1 NS, X"24" AFTER 4 NS, X"28" AFTER 12 NS,
			  X"2C" AFTER 18 NS, X"40" AFTER 22 NS, X"60" AFTER 26 NS, 
			  X"80" AFTER 30 NS, X"A0" AFTER 34 NS, X"C0" AFTER 38 NS, 
			  X"F0" AFTER 42 NS, X"F4" AFTER 46 NS, X"F8" AFTER 50 NS, 
			  X"FC" AFTER 54 NS, X"FE" AFTER 58 NS;

	Controller : ENTITY WORK.CCU PORT MAP 
					(clk, rst, readyMEM, readyMDU, 
					exception, interrupt, opcode, FIB,
					seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
					selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
					selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF, 
					selrd1_TRF, writeTRF, selp1_PCP, selimm_PCP, 
					selp1_PC, selPCadd_PC, selPC1_PC,
					selPC_addrBus, selADR_addrBus, driveDataBus,
					SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits,
					selp2_ASU, selimm_ASU, arithADD, arithSUB,
					logicAND, onesComp, twosComp,
					selp2_SHU, selshim_SHU, logicSH, arithSH,
					ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU,
					ldIR, ldADR, ldPC,
					readMEM, writeMEM, readIO, writeIO,
					readstatusTRF, writestatusTRF, writeTRB, USE12bits, selPC_PCP, 
					selTRB_PCP, sel1_ADR, selPCP_ADR, seldataBus_PC, selp1_dataBus, 
					selPC_dataBus, selPC1_dataBus, readIHBAddr, readTopStackAddr, 
					selrs1_imm, selcnt_imm, rst_cnt, inc_cnt, IntEnable, IntServicing, 
					selTRB_ADR, selPCP_addrBus, selESA_PC, ldExcBaseAddr, 
					readExcBaseAddr, readExcOffAddr, ExcEnable, ExcServicing, 
					setFlags, enFlag, InvalidInst, R15_LSB, selFlag);
END ARCHITECTURE test;