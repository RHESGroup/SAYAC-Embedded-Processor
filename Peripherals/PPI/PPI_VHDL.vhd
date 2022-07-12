--*****************************************************************************/
--	Filename:		PPI_VHDL.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			-
--	Authors:	 	Sepideh
--	Last Author: 	Sepideh
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	8255 is general purpose programmaple I/O device. it has 24 I/O pins which may 
--  individually programmed in 2 groups (GROUPA:PA, PCU GROUPB: PB, PCL) and used 
--	in three modes.
--  BSR MODE: used to set/reset PCL/PCU by using PD.
--  MODE0: it is simple I/O mode and there is no handshaking for transferring data 
--  MODE1: it is strobed I/O mode and it has handshaking and intrupt signals.
--  this mode is for PA and PB only and uses PCU/L as handshaking
--  MODE2: it is BI-DIRECTIONAL mode that uses for PA and utilizes PCU/L as handshaking. 
--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;

ENTITY PPI2 IS
	GENERIC(	len		: INTEGER := 8;
				len_bit	: INTEGER := 1);
	PORT (		clk		: 		IN STD_LOGIC;
				rst		: 		IN STD_LOGIC;
				nRD		: 		IN STD_LOGIC; --active low read signal
				nWR		: 		IN STD_LOGIC; --active low write signal
				nCS		:		IN STD_LOGIC; --active low chip select
				A		: 		IN std_logic_vector (1 downto 0); --port address
				PD		:		INOUT std_logic_vector (len-1 downto 0); --PORT D
				PA		: 		INOUT std_logic_vector (len-1 downto 0); --PORT A
				PB		: 		INOUT std_logic_vector (len-1 downto 0); --PORT B
				PCL		: 		INOUT std_logic_vector (len/2-1 downto 0); --PORTC LSB
				PCU		: 		INOUT std_logic_vector (len/2-1 downto 0) --PORTC MSB
				); 
END ENTITY;

ARCHITECTURE behavioral OF PPI2 IS

SIGNAL D_REG			:	STD_LOGIC_VECTOR (len-1 downto 0); --for saving PD value in CONTROL MODE
SIGNAL Data_IO			:	STD_LOGIC_VECTOR (len-1 downto 0); --saving data value 
SIGNAL PORTA			:	STD_LOGIC_VECTOR (len-1 downto 0); --saving data to put on PA
SIGNAL PORTB			:	STD_LOGIC_VECTOR (len-1 downto 0); --saving data to put on PB
SIGNAL PCL_REG			:	STD_LOGIC_VECTOR (len-1 downto 0); --saving data to put on LOW BITS PC
SIGNAL PCU_REG			:	STD_LOGIC_VECTOR (len-1 downto 0); --saving data to put on LOW BITS PC
SIGNAL Mode_Flag		:	STD_LOGIC; --PD(7)
SIGNAL B_CL_IO_MODE		:	STD_LOGIC;	--GROUPB MODE	
SIGNAL A_CU_IO_MODE		:	STD_LOGIC_VECTOR (1 downto 0); --GROUPA MODE
SIGNAL DREG_load		:	STD_LOGIC; --for saving DREG
SIGNAL DREG_Zero		:	STD_LOGIC;
SIGNAL ModeFlag_load	:	STD_LOGIC; --for saving D(7)
SIGNAL ModeFlag_Zero	:	STD_LOGIC;
SIGNAL DataIO_Zero		: 	STD_LOGIC;
SIGNAL DataIO_load		:	STD_LOGIC;
SIGNAL PDInPORTA_load	:	STD_LOGIC;
SIGNAL PDInPORTA_Zero	:	STD_LOGIC;
SIGNAL sel				:	STD_LOGIC_VECTOR (1 DOWNTO 0); --multiplexer selection for chosing PA, PB, PCU 
SIGNAL MUX_OUT			:	STD_LOGIC_VECTOR (len-1 DOWNTO 0); --multiplexer output -> Data_IO
SIGNAL PCU_8BIT			:	STD_LOGIC_VECTOR (len-1 DOWNTO 0);
SIGNAL PCL_8BIT			:	STD_LOGIC_VECTOR (len-1 DOWNTO 0);
SIGNAL PCUreg_load		:	STD_LOGIC;
SIGNAL PCUreg_Zero		:	STD_LOGIC;
SIGNAL INTRA_MODE1_IN 	:	STD_LOGIC; --intrupt signal for mode1 PORTA input
SIGNAL INTRB_MODE1_IN 	:	STD_LOGIC; --intrupt signal for mode1 PORTB input
SIGNAL IBF_A			:	STD_LOGIC; --input bufferA full
SIGNAL OBF_A			:	STD_LOGIC; --output bufferA full
SIGNAL INTRA_MODE1_OUT 	:	STD_LOGIC; --intrupt signal for mode1 PORTA output
SIGNAL INTRB_MODE1_OUT 	:	STD_LOGIC; --intrupt signal for mode1 PORTB output
SIGNAL IBF_B			:	STD_LOGIC; --input bufferB full
SIGNAL OBF_B			:	STD_LOGIC; --output bufferB full
SIGNAL INTRA_MODE2 		:	STD_LOGIC; --intrupt signal for mode2 (only for PORTA)
SIGNAL PORTB_load		:	STD_LOGIC; --saving data in PORTB
SIGNAL PORTB_Zero		:	STD_LOGIC;
SIGNAL PCLREG_load		:	STD_LOGIC; --saving data in PCLREG
SIGNAL PCLREG_Zero		:	STD_LOGIC;
SIGNAL HIGH_AMP_PORTA	:	STD_LOGIC;
SIGNAL HIGH_AMP_PORTB	:	STD_LOGIC;
SIGNAL HIGH_AMP_PCUREG	:	STD_LOGIC;
SIGNAL HIGH_AMP_PCLREG	:	STD_LOGIC;
SIGNAL HIGH_AMP_MODEFLAG:	STD_LOGIC;
SIGNAL HIGH_AMP_DataIO	:	STD_LOGIC;
SIGNAL HIGH_AMP_DREG	:	STD_LOGIC;
SIGNAL LET				:   STD_LOGIC := '0'; --permission for resetting IBF_A
SIGNAL FLAG_TEST		:   STD_LOGIC := '0'; --just for test(:

BEGIN

--Output Latch opertaion to the inout PORTS:
PA_PROCESS: PROCESS (Mode_Flag, D_REG, PORTA, A_CU_IO_MODE, PCU)
BEGIN

	IF (Mode_Flag = '1') THEN
		IF (D_REG(4) = '1') THEN --PORTA AS INPUT 
			PA <=  (others => 'Z'); 
		ELSE --PORTA AS OUTPUT
			IF (A_CU_IO_MODE = "10") THEN -- STROBED BI-DIRECTIONAL I/O
				IF(PCU(2) = '0') THEN --ACK_A (Acknowledge input) informs the 8255 that data from PA has been accepted
					PA <= PORTA;
				ELSE PA <=  (others => 'Z');	
				END IF;
			ELSE	
				PA <= PORTA;
			END IF;
		END IF;	
	ELSE
		PA <=  (others => 'Z'); 
	END IF;--PORTA AS INPUT 
END PROCESS PA_PROCESS;

PB_PROCESS: PROCESS (Mode_Flag, D_REG, PORTB)
BEGIN
	IF (Mode_Flag = '1') THEN
		IF (D_REG(1) = '1') THEN ----PORTB AS INPUT 
			PB <=  (others => 'Z'); 
		ELSE
			PB <= PORTB;
		END IF;	
	ELSE
		PB <= (others => 'Z'); 
	END IF;
END PROCESS PB_PROCESS;

PCL_PROCESS: PROCESS (Mode_Flag, D_REG, PCL_reg, A_CU_IO_MODE, INTRA_MODE1_OUT, INTRA_MODE2, 
INTRA_MODE1_IN,B_CL_IO_MODE, IBF_B, INTRB_MODE1_IN, OBF_B, INTRB_MODE1_OUT, rst, PD )
BEGIN
	IF (rst = '1' AND rst'EVENT) THEN
		PCL <= (others => 'Z');
	
	ELSIF (Mode_Flag = '1') THEN --MODE1
		IF (A_CU_IO_MODE = "01") AND  D_REG(4) = '1' THEN -- PORTA IN I/O STROBED  MODE AS INPUT
			PCL(3) <= INTRA_MODE1_IN;
			PCL(2 DOWNTO 0) <= (others => 'Z');
			
		ELSIF (A_CU_IO_MODE = "01") AND  D_REG(4) = '0' THEN -- PORTA IN I/O STROBED  MODE AS OUTPUT
			PCL(3) <= INTRA_MODE1_OUT;
			PCL(2 DOWNTO 0) <= (others => 'Z');
			
		ELSIF (B_CL_IO_MODE = '1') AND (D_REG(1) = '1') THEN -- PORTB IN I/O STROBED  MODE AS INPUT
			PCL(1) <= IBF_B; 
			PCL(0) <= INTRB_MODE1_IN;
			PCL(3 DOWNTO 2) <= (others => 'Z');
		
		ELSIF (B_CL_IO_MODE = '1') AND (D_REG(1) = '0') THEN -- PORTB IN I/O STROBED  MODE AS OUTPUT
			PCL(1) <= OBF_B;
			PCL(0) <= INTRB_MODE1_OUT;
			PCL(3 DOWNTO 2) <= (others => 'Z');
		
		ELSIF A_CU_IO_MODE = "10" THEN
			PCL(3) <= INTRA_MODE2;
			PCL(2 DOWNTO 0) <= (others => 'Z');
		
		ELSE
			IF (D_REG(0) = '1') THEN ----PORTCL AS INPUT 
				PCL <= (others => 'Z'); 
			ELSE
				PCL <= PCL_reg(3 DOWNTO 0);
			END IF;	
		END IF;
	END IF;
	IF (PD(7) = '0') THEN--BSR MODE
		CASE PD(3 DOWNTO 1) IS
			--Set/Reset Lower bits of PORTC(3 DOWNTO 0):
			WHEN "000" =>
				PCL(0) <= PD(0);
				PCL(3 DOWNTO 1) <= (OTHERS => 'Z');
			WHEN "001" => 
				PCL(1) <= PD(0);
				PCL(3 DOWNTO 2) <= (OTHERS => 'Z');
				PCL(0) <= 'Z';
			WHEN "010" => 
				PCL(2) <= PD(0);
				PCL(1 DOWNTO 0) <= (OTHERS => 'Z');
				PCL(3) <= 'Z';
			WHEN "011" => 
				PCL(3) <= PD(0);
				PCL(2 DOWNTO 0) <= (OTHERS => 'Z');
			WHEN OTHERS =>
				PCL <= (OTHERS => 'Z');
		END CASE;
	END IF;
END PROCESS PCL_PROCESS;

PCU_PROCESS: PROCESS (Mode_Flag, D_REG, PCU_reg, A_CU_IO_MODE, IBF_A, OBF_A, PD, rst, PCU, PCL)
BEGIN
	IF (rst = '1' AND rst'EVENT) THEN
		PCU <= (others => 'Z');
		
	ELSIF (Mode_Flag = '1') THEN --MODE1
		IF (A_CU_IO_MODE = "01") AND  (D_REG(4) = '1') THEN -- PORTA IN I/O STROBED  MODE AS INPUT
			PCU(1) <= IBF_A;
			PCU(3 DOWNTO 2) <= (OTHERS => 'Z');
			PCU(0) <= 'Z';
		
		ELSIF (A_CU_IO_MODE = "01") AND  (D_REG(4) = '0') THEN -- PORTA IN I/O STROBED  MODE AS OUTPUT
			PCU(3) <= OBF_A;
			PCU(2 DOWNTO 0) <= (OTHERS => 'Z');
			
		ELSIF (A_CU_IO_MODE = "10") AND (D_REG(4) = '1') THEN -- PORTA IN SOTROBED BI-DIRECTIONAL I/O MODE AS INPUT
			PCU(1) <= IBF_A;
			PCU(3 DOWNTO 2) <= (OTHERS => 'Z');
			PCU(0) <= 'Z';
		ELSIF (A_CU_IO_MODE = "10") AND (D_REG(4) = '0') THEN -- PORTA IN SOTROBED BI-DIRECTIONAL I/O MODE AS OUTPUT
			PCU(3) <= OBF_A;
			PCU(2 DOWNTO 0) <= (OTHERS => 'Z');
			
		ELSE
			IF (B_CL_IO_MODE = '1') THEN--BSR MODE
				PCU <=  (others => 'Z');
			ELSE 
				IF (D_REG(3) = '1') THEN ----PORTCU AS INPUT
					PCU <=  (others => 'Z'); 
				ELSE
					PCU <= PCU_reg(7 DOWNTO 4);
				END IF;
			END IF;
		END IF; -- A_CU_IO_MODE = "01" 	
	ELSIF (PD(7) = '0') THEN --BSR MODE
		CASE PD(3 DOWNTO 1) IS
		--Set/Reset Upper bits of PORTC(7 DOWNTO 4):
			WHEN "100" =>
				PCU(0) <= PD(0);
				PCU(3 DOWNTO 1) <= (OTHERS => 'Z');
			WHEN "101" =>  
				PCU(1) <= PD(0);
				PCU(3 DOWNTO 2) <= (OTHERS => 'Z');
				PCU(0) <= 'Z';
			WHEN "110" =>  
				PCU(2) <= PD(0);
				PCU(1 DOWNTO 0) <= (OTHERS => 'Z');
				PCU(3) <= 'Z';
			WHEN "111" =>  
				PCU(3) <= PD(0);
				PCU(2 DOWNTO 0) <= (OTHERS => 'Z');
			WHEN OTHERS =>
				PCU <= (others => 'Z');
			END CASE;
	END IF; -- Mode_Flag = '1'
END PROCESS PCU_PROCESS;

PD_PROCESS: PROCESS (nRD, nCS, Data_IO, A)
BEGIN
	IF ( (nRD = '0') AND (nCS = '0') AND NOT(A = "11")) THEN
		PD <= Data_IO;	
	ELSE
		PD <= (others => 'Z');
	END IF;
END PROCESS PD_PROCESS;
----------------------------------------------------------------------------
INTRA_MODE1_IN  <= (PCU(0) AND IBF_A) WHEN (nRD = '1') ELSE '0'; --STB-A & IBF_A(PCU(1))
INTRB_MODE1_IN  <= (PCL(2) AND IBF_B) WHEN (nRD = '1') ELSE '0'; --STB-B(PCL(2)) & IBF_B(PCL(1))	
PCU_8BIT <= "ZZZZ" & PCU;
PCL_8BIT <= "ZZZZ" & PCL;

INTRAMODE1OUT: PROCESS( nWR, PCU(2), OBF_A, A_CU_IO_MODE, D_REG(4))--ACK_B & OBF_B  (for producing intrupt signal as input for MODE1)
BEGIN 
	IF ((A_CU_IO_MODE = "01") AND  (D_REG(4) = '0')) THEN
		IF (nWR = '1' AND nWR'EVENT) THEN
			INTRA_MODE1_OUT <= '0';
		ELSIF (PCU(2) = '1' AND PCU(2)'EVENT) THEN
			INTRA_MODE1_OUT <= '1';
		END IF;
	ELSE
		INTRA_MODE1_OUT <= 'Z';
	END IF;
END PROCESS INTRAMODE1OUT;

INTRBMODE1OUT: PROCESS( nWR, PCL(2), OBF_B, B_CL_IO_MODE, D_REG(1)) --(for producing intrupt signal as output for MODE1)
BEGIN 
	IF ((B_CL_IO_MODE = '1') AND  (D_REG(1) = '0')) THEN
		IF (nWR = '1' AND nWR'EVENT ) THEN
			INTRB_MODE1_OUT <= '0';
		ELSIF (PCL(2) = '1' AND PCL(2)'EVENT) THEN
			INTRB_MODE1_OUT <= '1';
		END IF;
	ELSE
		INTRB_MODE1_OUT <= 'Z';
	END IF;
END PROCESS INTRBMODE1OUT;

INTRAMODE2: PROCESS(PCU, A_CU_IO_MODE) --(for producing intrupt signal for MODE2)
BEGIN
	IF (A_CU_IO_MODE = "10") THEN
		IF ((nWR = '0' AND nWR'EVENT) AND nRD = '1') THEN
			INTRA_MODE2 <= '0';
		ELSIF ((PCU(0) = '1' AND PCU(0)'EVENT) AND nRD = '1') THEN
		INTRA_MODE2 <= '1';
		END IF;
	ELSE INTRA_MODE2 <= 'Z';	
	
	END IF;

END PROCESS INTRAMODE2;

MODE_SELECTED: PROCESS (A, nRD, nWR, nCS, PD, PCL, PCU, Mode_Flag, D_REG, rst) 
BEGIN
DREG_load <= '0';
ModeFlag_load <= '0';

--Check the Control Word Register from the CPU:
	IF (nCS = '0') THEN
		IF (rst = '1' AND rst'EVENT) THEN
			A_CU_IO_MODE <= "ZZ"; 
			B_CL_IO_MODE <= 'Z';
		END IF;
		IF (A = "11") THEN --CONTROL MODE
			IF (nRD = '0' AND nRD'EVENT) THEN
				DREG_load <= '1';
				ModeFlag_load <= '1';
			END IF;--nWR = '1' AND nWR'EVENT
				
			IF Mode_Flag = '1' THEN
			
				--GROUPA CONFIGURATION MODE
				IF D_REG(6 DOWNTO 5)= "00" THEN 
					A_CU_IO_MODE <= "00"; -- SIMPLE I/O
				ELSIF D_REG(6 DOWNTO 5)= "01" THEN
					A_CU_IO_MODE <= "01"; -- STROBED I/O
				ELSE
					A_CU_IO_MODE <= "10"; -- STROBED BI-DIRECTIONAL I/O
				END IF;
				
				-- GROUPB CONFIGURATION MODE
				IF D_REG(2) = '1' THEN 
					B_CL_IO_MODE <= '1'; -- STROBED I/O
				ELSE
					B_CL_IO_MODE <= '0'; -- SIMPLE I/O MODE
				END IF;
					
			ELSIF (PD(7) = '0') THEN
				A_CU_IO_MODE <= "ZZ"; 
				B_CL_IO_MODE <= 'Z';
			ELSE
				A_CU_IO_MODE <= "ZZ"; 
				B_CL_IO_MODE <= 'Z';
			END IF; -- Mode_Flag
		
		END IF;	-- (A==2'b11)		
	END IF; -- nCS = '0'		
END PROCESS MODE_SELECTED;
	

MODE_EXECUTION: PROCESS (A, nRD, nWR, nCS, PD, PCL, PCU, Mode_Flag, D_REG, A_CU_IO_MODE, rst) 
BEGIN
HIGH_AMP_PORTA <= '0';
HIGH_AMP_PORTB <= '0';
DataIO_load <= '0';
PDInPORTA_load <= '0';
HIGH_AMP_PCUREG <= '0';
HIGH_AMP_PORTB <= '0';

	IF (rst = '1' AND rst'EVENT) THEN
		
		HIGH_AMP_PORTA <= '1';
		HIGH_AMP_PORTB <= '1';
		IBF_A <= 'Z';
		OBF_A <= 'Z';
	
	ELSIF ((nCS = '0') AND ( Mode_Flag = '1')) THEN
			-- Read/Write Group A operations: 
			IF A_CU_IO_MODE = "00" THEN -- PORTA OR CU IN SIMPLE I/O MODE
				CASE A IS
					--PORTA read or Write:
					WHEN "00" =>
						IF  (nRD = '0' AND nRD'EVENT) AND (D_REG(4)='1') THEN --PA AS INPUT IN SIMPLE I/O MODE
							sel <= "00"; -- PA SAVED IN Data_IO
							DataIO_load <= '1';
							
						ELSIF  (nWR = '0' AND nWR'EVENT) AND (D_REG(4)='0') THEN --PA AS OUTPUT IN SIMPLE I/O MODE  
							PDInPORTA_load <= '1'; --PD saved in PORTA_REG
						END IF; --(!nRD) && (D_REG(4)=1) 
						
					--Port C upper read and Write:
					WHEN "10" =>
						IF (nRD = '0' AND nRD'EVENT) AND (D_REG(3) = '1') THEN --PCU AS INPUT IN SIMPLE I/O MODE
							sel <= "10";
							DataIO_load <= '1'; --Data_IO <= PCU;
								
						ELSIF (nWR = '1' AND nWR'EVENT) AND (D_REG(3) = '0') THEN --PCU AS OUTPUT IN SIMPLE I/O MODE
							PCUreg_load <= '1'; --PCU_reg <= PD;	
						END IF; --(!nRD) && (D_REG(3)='1') && (!nCS)
						
					WHEN OTHERS => 
						sel <= "ZZ"; --Data_IO <= (OTHERS => 'Z');	
						PCUreg_Zero <= '1';		
				END CASE;
				
			ELSIF A_CU_IO_MODE = "01" THEN -- PORTA IN I/O STROBED  MODE 
				IF (D_REG(4) = '1') THEN --(D_REG(4) = '1')PORTA IS INPUT
					IF (PCU(0) = '0' AND PCU(0)'EVENT) THEN -- STB_A =0
						sel <= "00"; -- PA SAVED IN Data_IO
						DataIO_load <= '1';
						IBF_A <= '1';--PCU(1) = '1'	
					ELSIF (nRD = '1' AND nRD'EVENT AND NOT(A = "11")) THEN -- FOR RESETING IBF_A
						IBF_A <= '0';--PCU(1) = '0'

					END IF; --PCU(0) = '0' AND PCU(0)'EVENT
					
				ELSE --(D_REG(4) = '0')PORTA IS OUTPUT	
					IF (nWR = '1' AND nWR'EVENT) THEN
						OBF_A <= '0'; --PCU(3) = '0'
						PDInPORTA_load <= '1'; -- PORTA = PD
					ELSIF (PCU(2) = '0' AND PCU(2)'EVENT AND (nRD = '1')) THEN -- ACK_A
						OBF_A <= '1'; --PCU(3) = '1'
						HIGH_AMP_PORTA <= '1';
						--HIGH_AMP_PCUREG <= '1';
					
					END IF;--PCU(2) = '0' and PCU(2)'EVENT
				END IF;--D_REG(4) = '1'
			
			ELSIF A_CU_IO_MODE = "10" THEN -- PORTA IN SOTROBED BI-DIRECTIONAL I/O MODE 
				IF (D_REG(4) = '1') THEN --PORTA IS INPUT
					IF ((PCU(0) = '0' AND PCU(0)'EVENT) AND (nRD = '1')) THEN --STB_A
						sel <= "00"; -- PA SAVED IN Data_IO
						DataIO_load <= '1';
						IBF_A <= '1'; --PCU(1)
						LET <= '1';
					ELSIF (nRD = '1' AND nRD'EVENT AND (LET = '1'))	THEN
						LET <= '0';
						IBF_A <= '0'; --PCU(1)
					END IF;
				
				ELSE --PORTA IN SOTROBED BI-DIRECTIONAL I/O MODE AS OUTPUT
					IF (nWR = '1' AND nWR'EVENT AND nRD = '1') THEN
						OBF_A <= '0'; -- PCU(3)
						PDInPORTA_load <= '1';
					END IF; --nWR = '1' and nWR'EVENT
					IF (PCU(2) = '0' AND PCU(2)'EVENT AND nRD = '1') THEN --ACK_A
						OBF_A <= '1'; -- PCU(3)
					END IF; --CU(2) = '0' and PCU(2)'EVENT	
				END IF;	--PORTA IN SOTROBED BI-DIRECTIONAL I/O MODE AS INPUT
			END IF; --A_CU_IO_MODE = "00"
		
		--Read/Write Group B operations:
			IF B_CL_IO_MODE = '0' THEN -- PORTB OR CL IN SIMPLE I/O MODE
				CASE A IS
					--PORTB Read Or Write:
					WHEN "01" =>
						IF  (nRD = '0' AND nRD'EVENT) AND (D_REG(1)= '1') THEN -- PORTB IN SIMPLE I/O MODE AS INPUT
							sel <= "01"; -- PB SAVED IN Data_IO
							DataIO_load <= '1';
						ELSIF (nWR = '1' AND nWR'EVENT) AND (D_REG(1)= '0') THEN  -- PORTB IN SIMPLE I/O MODE AS OUTPUT 
							PORTB_load <= '1'; --PORTB = PD						
						END IF; --(!nRD) && (D_REG(1)= '1') && (!nCS)
					
					--PORTCL Read Or Write:	
					WHEN "10" =>
						IF (nRD = '0' AND nRD'EVENT) AND (D_REG(0)= '1') THEN -- PORTCL IN SIMPLE I/O MODE AS INPUT
							sel <= "11"; -- PCL SAVED IN Data_IO
							DataIO_load <= '1'; 

						ELSIF (nWR = '1' AND nWR'EVENT) AND (D_REG(0)= '0') THEN -- PORTCL IN SIMPLE I/O MODE AS OUTPUT
							PCLREG_load <= '1'; --PCL_reg = PD(3 DOWNTO 0)
						END IF; --(!nRD) && (D_REG(0)= '1') && (!nCS)
						
					WHEN OTHERS => 
						--FLAG_TEST <= '1';
						--HIGH_AMP_DataIO <= '1';						
				END CASE;
				
			ELSE -- PORTB IN I/O STROBED MODE
				IF (D_REG(1) = '1') THEN --(D_REG(1) = '1')PORTB IS INPUT
					IF (PCL(2) = '0' AND PCL(2)'EVENT AND nRD = '1') THEN -- STB_B =0 (PC(2))
						sel <= "01"; -- PB SAVED IN Data_IO
						DataIO_load <= '1';
						IBF_B <= '1'; --PCL(1)	
					ELSIF ((nRD = '1' AND nRD'EVENT) AND NOT(A="11")) THEN -- FOR RESETING IBF_A
						IBF_B <= '0'; --PCL(1)
						
					END IF; --nRD = '1' and nRD'EVENT
					
				ELSE --(D_REG(1) = '0')PORTB IS OUTPUT	
					IF (nWR = '1' AND nWR'EVENT) THEN
						OBF_B <= '0'; --PCL(1) <= '0'
						PORTB_load <= '1'; --PORTB <= PD
					ELSIF (PCL(2) = '0' AND PCL(2)'EVENT AND (nRD = '1')) THEN -- ACK_B
						OBF_B <= '1'; --PCL(1) <= '1'
						HIGH_AMP_PORTB <= '0';
					
					END IF;--PCU(2) = '0' and PCU(2)'EVENT	
				END IF;--D_REG(1) = '1'
 			
			END IF; --B_CL_IO_MODE == 0
	END IF; -- RST
END PROCESS MODE_EXECUTION;


DataIO_MUX:ENTITY WORK.MUX4 
	GENERIC MAP(len)
	PORT MAP(PA, PB, PCU_8BIT, PCL_8BIT, sel, MUX_OUT);	

D_REG_KEEPER: ENTITY WORK.Reg_DREG 
	GENERIC MAP(len)
	PORT MAP(PD, rst, DREG_load, DREG_Zero, HIGH_AMP_DREG, D_REG); 	
	
DataIO_KEEPER: ENTITY WORK.Reg 
	GENERIC MAP(len)
	PORT MAP(MUX_OUT, rst, DataIO_load, DataIO_Zero, HIGH_AMP_DataIO, Data_IO);
	
PORTA_REG: ENTITY WORK.Reg 
	GENERIC MAP(len)
	PORT MAP(PD, rst, PDInPORTA_load, PDInPORTA_Zero, HIGH_AMP_PORTA, PORTA);

PCUreg: ENTITY WORK.Reg 
	GENERIC MAP(len)
	PORT MAP(PD, rst, PCUreg_load, PCUreg_Zero, HIGH_AMP_PCUREG, PCU_reg);		

PDInPORTB_KEEPER: ENTITY WORK.Reg 
	GENERIC MAP(len)
	PORT MAP(PD, rst, PORTB_load, PORTB_Zero, HIGH_AMP_PORTB, PORTB);

PDInPCLREG: ENTITY WORK.Reg
	GENERIC MAP(len)
	PORT MAP(PD, rst, PCLREG_load, PCLREG_Zero, HIGH_AMP_PCLREG, PCL_REG);	
	
Mode_FlagREG: ENTITY WORK.Reg1 
	PORT MAP(D_REG(7), rst, ModeFlag_load, ModeFlag_Zero, HIGH_AMP_MODEFLAG, Mode_Flag);
  
END behavioral;
