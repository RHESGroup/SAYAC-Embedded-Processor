--******************************************************************************
--	Filename:		SAYAC_controller.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			26 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Controller (CTRL) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
	
ENTITY CTRL IS
	PORT (
		clk, rst, readyMEM, readyMDU : IN STD_LOGIC;
		opcode   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIB      : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  --FLags Intrepretation Bits
	    seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
        selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF, 
		selrd1_TRF, writeTRF, selp1_PCP, selimm_PCP, 
        selp1_PC, selPCadd_PC, selPC1_PC,
        selPC_MEM, selADR_MEM, driveDataBus,
        SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits,
        selp2_ASU, selimm_ASU, arithADD, arithSUB,
        logicAND, onesComp, twosComp,
        selp2_SHU, selshim_SHU, logicSH, arithSH,
        ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU,
        ldIR, ldADR, ldPC,
        readMEM, writeMEM, readIO, writeIO,
		setFlags, enFlag : OUT STD_LOGIC;
		outFlag  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		selFlag : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY CTRL;

ARCHITECTURE behaviour OF CTRL IS
	CONSTANT RSV1   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	CONSTANT RSV2   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
	CONSTANT INST2  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
	CONSTANT LDR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	CONSTANT STR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
	CONSTANT JMR    : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
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
	
	TYPE state IS (fetch, exec1, exec2, exec3);
	SIGNAL pstate, nstate : state := fetch;
	TYPE instruction IS 
		(I_RSV1, I_RSV2, I_LDR, I_LDR_MEM, I_LDR_IO, I_STR, I_STR_MEM,
		I_STR_IO, I_JMR_DS, I_JMR_S, I_JMI, I_ANR, I_ANI, I_MSI, I_MHI,
		I_SLR, I_SAR, I_ADR, I_SUR, I_ADI, I_SUI, I_MUL, I_MUL_HL, I_MUL_L,
		I_DIV, I_DIV_HL, I_DIV_L, I_CMR, I_CMI, I_BRC, I_BRR, I_SHI_L,
		I_SHI_A, I_NTR_1, I_NTR_2, I_NTD_1, I_NTD_2);
	SIGNAL INST : instruction;
BEGIN	
	-- Issuing control signals
	PROCESS (pstate, readyMEM, readyMDU, opcode, FIB)
		VARIABLE opcode7downto4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE opcode3downto2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
		VARIABLE opcode3downto1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
		VARIABLE RFI  : STD_LOGIC_VECTOR (2 DOWNTO 0);	--Relational Flag Interpretation
	BEGIN
		opcode7downto4 := opcode(7 DOWNTO 4);	
		opcode3downto2 := opcode(3 DOWNTO 2);	
		opcode3downto1 := opcode(3 DOWNTO 1);
		RFI := FIB(2 DOWNTO 0);
		
		seldataBus_TRF <= '0';	selPC1_TRF <= '0';		selLLU_TRF <= '0'; 
		selSHU_TRF <= '0';	    selASU_TRF <= '0';		selMDU1_TRF <= '0'; 
		selMDU2_TRF <= '0';	    selIMM_TRF <= '0';		selrs1_TRF <= '0';	    
		selrd_1_TRF <= '0';		selrd0_TRF <= '0';		selrd1_TRF <= '0';	    
		writeTRF <= '0';		selp1_PCP <= '0';		selimm_PCP <= '0';	
		selp1_PC <= '0';		selPCadd_PC <= '0';		selPC1_PC <= '0';       
		selPC_MEM <= '0';		selADR_MEM <= '0';	    SE5bits <= '0';			
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
		
		CASE (pstate) IS
			WHEN fetch =>
				selPC_MEM <= '1';	ldIR <= '1';
			WHEN exec1 =>
				CASE (opcode7downto4) IS
					WHEN RSV1 => 
						seldataBus_TRF <= '0';	selPC1_TRF <= '0';		selLLU_TRF <= '0'; 
						selSHU_TRF <= '0';	    selASU_TRF <= '0';		selMDU1_TRF <= '0'; 
						selMDU2_TRF <= '0';	    selIMM_TRF <= '0';		selrs1_TRF <= '0';	    
						selrd_1_TRF <= '0';		selrd0_TRF <= '0';		selrd1_TRF <= '0';	    
						writeTRF <= '0';		selp1_PCP <= '0';		selimm_PCP <= '0';	
						selp1_PC <= '0';		selPCadd_PC <= '0';		selPC1_PC <= '0';       
						selPC_MEM <= '0';		selADR_MEM <= '0';	    SE5bits <= '0';			
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
					WHEN RSV2 => 
						seldataBus_TRF <= '0';	selPC1_TRF <= '0';		selLLU_TRF <= '0'; 
						selSHU_TRF <= '0';	    selASU_TRF <= '0';		selMDU1_TRF <= '0'; 
						selMDU2_TRF <= '0';	    selIMM_TRF <= '0';		selrs1_TRF <= '0';	    
						selrd_1_TRF <= '0';		selrd0_TRF <= '0';		selrd1_TRF <= '0';	    
						writeTRF <= '0';		selp1_PCP <= '0';		selimm_PCP <= '0';	
						selp1_PC <= '0';		selPCadd_PC <= '0';		selPC1_PC <= '0';       
						selPC_MEM <= '0';		selADR_MEM <= '0';	    SE5bits <= '0';			
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
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LDR =>
								selrs1_TRF <= '1';		selrd0_TRF <= '1';	selp1_PCP <= '1';
								ldADR <= '1';
							WHEN STR =>
								selrd_1_TRF <= '1';		selp1_PCP <= '1';	ldADR <= '1';	
							WHEN JMR => 
								selrs1_TRF <= '1';		selp1_PCP <= '1';	selPCadd_PC <= '1';	
								ldPC <= '1';			
								IF opcode(1) = '1' THEN
									selrd0_TRF <= '1';		selPC1_TRF <= '1';		
									writeTRF <= '1';
								END IF;
							WHEN JMI =>
								SE6bits <= '1';			selimm_PCP <= '1';	selPCadd_PC <= '1';
								ldPC <= '1';			selrd0_TRF <= '1';	selPC1_TRF <= '1';	
								writeTRF <= '1';					
							WHEN OTHERS =>
								selrs1_TRF <= '0';		ldADR <= '0';		selp1_PCP <= '0';
								ldPC <= '0';			selPCadd_PC <= '0';	selrd0_TRF <= '0';	
								selPC1_TRF <= '0';		SE6bits <= '0';		selimm_PCP <= '0';	
								writeTRF <= '0';		selrd_1_TRF <= '1';		
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
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		ldMDU1 <= '1';
						arithMUL <= '1';
						IF readyMDU = '1' THEN 
							startMDU <= '1';	
						END IF;
					WHEN DIV =>
						selrs1_TRF <= '1';		selrs2_TRF <= '1';		ldMDU1 <= '1';
						arithDIV <= '1';
						IF readyMDU = '1' THEN 
							startMDU <= '1';	
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
										IF outFlag(4) = '1' THEN						--eq
											selrd_1_TRF <= '1';	selp1_PC <= '1';	ldPC <= '1';
										END IF;
									WHEN "001" =>
										IF outFlag(5) = '0' THEN						--lt
											selrd_1_TRF <= '1';	selp1_PC <= '1';	ldPC <= '1';
										END IF;
									WHEN "010" =>
										IF outFlag(5) = '1' THEN						--gt
											selrd_1_TRF <= '1';	selp1_PC <= '1';	ldPC <= '1';
										END IF;
									WHEN "011" =>
										IF outFlag(5) = '1' OR outFlag(4) = '1' THEN	--gt/eq
											selrd_1_TRF <= '1';	selp1_PC <= '1';	ldPC <= '1';
										END IF;
									WHEN "100" =>
										IF outFlag(5) = '0' OR outFlag(4) = '1' THEN	--lt/eq
											selrd_1_TRF <= '1';	selp1_PC <= '1';	ldPC <= '1';
										END IF;
									WHEN OTHERS =>
										selrd_1_TRF <= '0';		selp1_PC <= '0';	ldPC <= '0';
								END CASE;
							WHEN BRR =>
								selrd_1_TRF <= '1';		selp1_PCP <= '1';		selPCadd_PC <= '1';	
								ldPC <= '1';
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
							selp1_PCP <= '0';		selimm_PCP <= '0';	selp1_PC <= '0';
							selPCadd_PC <= '0';		selPC1_PC <= '0';	seldataBus_TRF <= '0';	
							selPC1_TRF <= '0';		selLLU_TRF <= '0';	selSHU_TRF <= '0';
							selASU_TRF <= '0';		selMDU1_TRF <= '0';	selMDU2_TRF <= '0';	
							selIMM_TRF <= '0';		selp2_SHU <= '0';	selshim_SHU <= '0';	
							selp2_ASU <= '0';		selimm_ASU <= '0';	selrs1_TRF <= '0';	
							selrd_1_TRF <= '0';		selrd0_TRF <= '0';	selrd1_TRF <= '0';	
							selPC_MEM <= '0';		selADR_MEM <= '0';	SE5bits <= '0';	
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
					selSHU_TRF <= '1';		writeTRF <= '1';	selPC1_PC <= '1';	
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
							WHEN LDR =>
								selADR_MEM <= '1';	seldataBus_TRF <= '1';	selPC1_PC <= '1';	
								ldPC <= '1';	
								IF opcode(1) = '0' THEN		--I/O
									readIO <= '1';	writeTRF <= '1';
								ELSE						--MEM
									readMEM <= '1';
									IF readyMEM = '1' THEN
										writeTRF <= '1';
									END IF;
								END IF;
							WHEN STR =>
								selADR_MEM <= '1';	selrs1_TRF <= '1';		driveDataBus <= '1';
								selPC1_PC <= '1';	ldPC <= '1';
								IF opcode(1) = '0' THEN
									writeIO <= '1';
								ELSE
									writeMEM <= '1';
								END IF;
							WHEN OTHERS => 
								selADR_MEM <= '0';	selrd0_TRF <= '0';	readIO <= '0';	
								writeTRF <= '0';	readMEM <= '0';		writeIO <= '0';	
								writeMEM<= '0';
						END CASE;
					WHEN MUL => 
						selrd0_TRF <= '1';		selMDU1_TRF <= '1';		writeTRF <= '1';
						ldMDU2 <= '1';
					WHEN DIV =>
						selrd0_TRF <= '1';		selMDU1_TRF <= '1';		writeTRF <= '1';
						ldMDU2 <= '1';
					WHEN OTHERS =>
						selADR_MEM <= '0';		selrd0_TRF <= '0';		readIO <= '0';	
						writeTRF <= '0';		readMEM <= '0';			writeIO <= '0';	
						writeMEM<= '0';			arithMUL <= '0';		selMDU1_TRF <= '0';	
						ldMDU1 <= '0';			arithDIV <= '0';		driveDataBus <= '0';
				END CASE;
			WHEN exec3 =>
				CASE (opcode7downto4) IS
					WHEN MUL => 
						selrd1_TRF <= '1';		selMDU2_TRF <= '1';		writeTRF <= '1';
						selPC1_PC <= '1';		ldPC <= '1';
					WHEN DIV =>
						selrd1_TRF <= '1';		selMDU2_TRF <= '1';		writeTRF <= '1';
						selPC1_PC <= '1';		ldPC <= '1';
					WHEN OTHERS => 
						writeTRF <= '0';		selMDU2_TRF <= '0';		selrd1_TRF <= '0';	
						selPC1_PC <= '0';		ldPC <= '0';
				END CASE;
		END CASE;
	END PROCESS;
	
	-- Issuing next state
	PROCESS (pstate, readyMEM, readyMDU, opcode)
		VARIABLE opcode7downto4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE opcode3downto2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
		VARIABLE opcode3downto1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		opcode7downto4 := opcode(7 DOWNTO 4);	
		opcode3downto2 := opcode(3 DOWNTO 2);	
		opcode3downto1 := opcode(3 DOWNTO 1);
		
		CASE (pstate) IS
			WHEN fetch =>
				IF rst = '1' THEN
					nstate <= fetch;
				ELSE
					nstate <= exec1;
				END IF;
			WHEN exec1 =>
				CASE (opcode7downto4) IS
					WHEN RSV1 => 
						INST <= I_RSV1;		nstate <= fetch;
					WHEN RSV2 => 
						INST <= I_RSV2;		nstate <= fetch;
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LDR => 
								INST <= I_LDR;	nstate <= exec2;
							WHEN STR => 
								INST <= I_STR;	nstate <= exec2;
							WHEN JMR => 
								nstate <= fetch;	
								IF opcode(1) = '1' THEN
									INST <= I_JMR_S;
								ELSE
									INST <= I_JMR_DS;
								END IF;
							WHEN JMI => 
								INST <= I_JMI;	nstate <= fetch;
							WHEN OTHERS =>
								nstate <= fetch;
						END CASE;
					WHEN ANR => 
						INST <= I_ANR;	nstate <= fetch;
					WHEN ANI => 
						INST <= I_ANI;	nstate <= fetch;
					WHEN MSI => 
						INST <= I_MSI;	nstate <= fetch;
					WHEN MHI => 
						INST <= I_MHI;	nstate <= fetch;
					WHEN SLR => 
						INST <= I_SLR;	nstate <= fetch;
					WHEN SAR => 
						INST <= I_SAR;	nstate <= fetch;
					WHEN ADR => 
						INST <= I_ADR;	nstate <= fetch;
					WHEN SUR => 
						INST <= I_SUR;	nstate <= fetch;
					WHEN ADI => 
						INST <= I_ADI;	nstate <= fetch;
					WHEN SUI => 
						INST <= I_SUI;	nstate <= fetch;
					WHEN MUL => 
						INST <= I_MUL;
						IF readyMDU = '1' THEN 
							nstate <= exec2;
						ELSE
							nstate <= exec1;
						END IF;
					WHEN DIV => 
						INST <= I_DIV;
						IF readyMDU = '1' THEN 
							nstate <= exec2;
						ELSE
							nstate <= exec1;
						END IF;
					WHEN INST15 =>
						CASE (opcode3downto1) IS
							WHEN CMR => 
								INST <= I_CMR;	nstate <= fetch;
							WHEN CMI => 
								INST <= I_CMI;	nstate <= fetch;
							WHEN BRC => 
								INST <= I_BRC;	nstate <= fetch;
							WHEN BRR => 
								INST <= I_BRR;	nstate <= fetch;
							WHEN NTR =>
								nstate <= fetch;
								IF opcode(0) = '0' THEN
									INST <= I_NTR_1;
								ELSE
									INST <= I_NTR_2;
								END IF;
							WHEN NTD =>
								nstate <= fetch;
								IF opcode(0) = '0' THEN
									INST <= I_NTD_1;
								ELSE
									INST <= I_NTD_2;
								END IF;
							WHEN OTHERS =>
								nstate <= fetch;
						END CASE;
					WHEN OTHERS =>
							nstate <= fetch;
				END CASE;
				-- SHI
				IF opcode(7 DOWNTO 2) = SHI THEN
					nstate <= fetch;	
					IF opcode(1) = '0' THEN
						INST <= I_SHI_L;
					ELSE
						INST <= I_SHI_A;
					END IF;
				END IF;
			WHEN exec2 =>
				CASE (opcode7downto4) IS
					WHEN INST2 =>
						CASE (opcode3downto2) IS
							WHEN LDR =>	
								IF opcode(1) = '0' THEN		--I/O
									INST <= I_LDR_IO;	nstate <= fetch;
									
								ELSE						--MEM
									INST <= I_LDR_MEM;
									IF readyMEM = '1' THEN
										nstate <= fetch;
									ELSE
										nstate <= exec2;
									END IF;
								END IF;
							WHEN STR =>
								IF opcode(1) = '0' THEN
									INST <= I_STR_IO;	nstate <= fetch; 	
								ELSE
									INST <= I_STR_MEM;
									IF readyMEM = '1' THEN
										nstate <= fetch;
									ELSE
										nstate <= exec2;
									END IF;
								END IF;
							WHEN OTHERS => 
								nstate <= fetch;
						END CASE;
					WHEN MUL => 
						INST <= I_MUL_HL;	nstate <= exec3;	
					WHEN DIV =>
						INST <= I_DIV_HL;	nstate <= exec3; 		
					WHEN OTHERS =>
						nstate <= fetch;
				END CASE;
			WHEN exec3 =>
				CASE (opcode7downto4) IS
					WHEN MUL => 
						nstate <= fetch;
					WHEN DIV =>
						nstate <= fetch;
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
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY test_CTRL IS
END ENTITY test_CTRL;
ARCHITECTURE test OF test_CTRL IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, readyMEM, readyMDU : STD_LOGIC;
	SIGNAL seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF : STD_LOGIC; 
	SIGNAL selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF : STD_LOGIC;
    SIGNAL selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF, 
		   selrd1_TRF, writeTRF : STD_LOGIC;
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
	SIGNAL opcode  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL FIB     : STD_LOGIC_VECTOR(4 DOWNTO 0);  --FLags Intrepretation Bits
	SIGNAL setFlags, enFlag : STD_LOGIC;
	SIGNAL outFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL selFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN	
	clk <= NOT clk AFTER 1 NS WHEN NOW <= 380 NS ELSE '0';
	rst <= '1', '0' AFTER 1 NS;
	readyMEM <= '0', '1' AFTER 4 NS, '0' AFTER 16 NS;
	readyMDU <= '0', '1' AFTER 50 NS;
	FIB <= "00000", "00011" AFTER 50 NS;
	outFlag <= X"00", X"F1" AFTER 50 NS;
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

	Controller : ENTITY WORK.CTRL PORT MAP 
					(clk, rst, readyMEM, readyMDU, opcode, FIB,
					seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
					selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF,
					selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF, selrd0_TRF, 
					selrd1_TRF, writeTRF, selp1_PCP, selimm_PCP, 
					selp1_PC, selPCadd_PC, selPC1_PC,
					selPC_MEM, selADR_MEM, driveDataBus,
					SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits,
					selp2_ASU, selimm_ASU, arithADD, arithSUB,
					logicAND, onesComp, twosComp,
					selp2_SHU, selshim_SHU, logicSH, arithSH,
					ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU,
					ldIR, ldADR, ldPC,
					readMEM, writeMEM, readIO, writeIO,
					setFlags, enFlag, outFlag, selFlag);
END ARCHITECTURE test;