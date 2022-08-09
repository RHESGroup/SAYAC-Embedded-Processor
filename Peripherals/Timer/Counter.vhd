--*****************************************************************************/
--	Filename:		CHIP.vhd
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
--	This chip works in 5 modes: intrrupt on terminal count, programmable one-shot,
--  rate generator, square wave rate generator, software triggered strobe,  
--	hardware triggeredstrobe. the selection of these modes and binary/bcd 
--  representation,get or put LSB/MSB value in the counter  are done by 
--  control word register. Also, it has read and write modes. in the read mode 
--  we can have counter value "on the fly" or stop the counter and read the value.
--  In the write mode we can put control word or initial value in the counter. 
--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY Counter IS
	GENERIC( LEN_CONTROLWORD	: 	INTEGER := 6;
			 LEN_DATA			:	INTEGER := 8);
	PORT (
			 CLK_INPUT	: 	IN STD_LOGIC;
			 rst		: 	IN STD_LOGIC;
			 CONTROLWORD: 	IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			 GATE		: 	IN STD_LOGIC;
			 WR_SIGNAL	:	IN STD_LOGIC;
			 RD_SIGNAL	:	IN STD_LOGIC;
			 STATUS_RD	:	IN STD_LOGIC; --for reading the status of the counter
			 RD_BACK	:	IN STD_LOGIC; --for reading the value of the counter
			 DATABUS	: 	INOUT STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0);
			 OUTPUT		:	OUT STD_LOGIC);			
END ENTITY;

ARCHITECTURE behavioral OF Counter IS

TYPE STATE_TYPE IS (MODE0, MODE1, MODE2, MODE3, MODE4, MODE5, MODE0_0, MODE0_1, MODE1_0, MODE1_1, MODE2_0, MODE2_1, MODE3_0, MODE3_1, MODE3_2,MODE3_3, 
MODE3_4, MODE4_0, MODE4_1, MODE5_0, MODE5_1, START);
SIGNAL P_STATE, N_STATE : STATE_TYPE := START;

SIGNAL MODE						:	STD_LOGIC_VECTOR (2 DOWNTO 0); --mode of the counter
SIGNAL sel_MUXDATAOUTPUT		:	STD_LOGIC_VECTOR (1 DOWNTO 0); --selection between Status of the counter, LSB/MSB bits of the counter
SIGNAL TEST						:	STD_LOGIC_VECTOR (5 DOWNTO 0); 
SIGNAL StatusByteReg			:	STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0); --keeping the statuse of the counter = control word
SIGNAL DataOutput				:	STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0); -- for putting value on databus
SIGNAL NUM_L					:	STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0); --LSB bits of the counter
SIGNAL NUM_M					:	STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0); --MSB bits of the counter
SIGNAL CR_L						:	STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0); --LSB bits that we want to load it in to counter
SIGNAL CR_M						:	STD_LOGIC_VECTOR (LEN_DATA-1 DOWNTO 0); --MSB bits that we want to load it in to counter
SIGNAL CEoutput					:	STD_LOGIC_VECTOR (15 DOWNTO 0); --value of the counter
SIGNAL CR						:	STD_LOGIC_VECTOR (15 DOWNTO 0); --(CR_M & CR_L)
SIGNAL WR_PSTATE				:	STD_LOGIC_VECTOR (1 DOWNTO 0) := "11"; --present state for write state machine
SIGNAL WR_NSTATE				:	STD_LOGIC_VECTOR (1 DOWNTO 0) := "11"; --next state for writing state machine
SIGNAL RD_PSTATE				:	STD_LOGIC_VECTOR (1 DOWNTO 0) := "11"; --present state for reading state machine
SIGNAL RD_NSTATE				:	STD_LOGIC_VECTOR (1 DOWNTO 0) := "11"; --next state for reading state machine
SIGNAL StatusByteReadCheck 		:	STD_LOGIC := '0'; --Check that you have read the status. 1 = waiting to be read. 0 = Empty
SIGNAL SET_StatusByteReadCheck	:	STD_LOGIC;
SIGNAL RESET_COUNTLATCHCHECK	:	STD_LOGIC;
SIGNAL SET_COUNTLATCHCHECK		:	STD_LOGIC;
SIGNAL RESET_StatusByteReadCheck:	STD_LOGIC;
SIGNAL CLK						:	STD_LOGIC; 
SIGNAL ld_CONTROLWORD			:	STD_LOGIC; --loading controlword
SIGNAL Zero_CONTROLWORD 		:	STD_LOGIC;
SIGNAL SET_LATCHCOUNTCHECK		:	STD_LOGIC;
SIGNAL RESET_LATCHCOUNTCHECK	:	STD_LOGIC;
SIGNAL COUNTLATCHCHECK			:	STD_LOGIC; --latching the value of the counter in reading state
SIGNAL ld_CRM					:	STD_LOGIC;
SIGNAL Zero_CRM					:	STD_LOGIC;
SIGNAL ld_CRL					:	STD_LOGIC;
SIGNAL Zero_CRL					:	STD_LOGIC;
SIGNAL SET_CRLOADED				:	STD_LOGIC;
SIGNAL RESET_CRLOADED			:	STD_LOGIC;
SIGNAL CRLOADED					:	STD_LOGIC; --to show there is value for loading in the counter
SIGNAL SET_LoadFlag				:	STD_LOGIC;
SIGNAL RESET_LoadFlag			:	STD_LOGIC;
SIGNAL LoadFlag					:	STD_LOGIC;
SIGNAL SET_PAUSECLK				:	STD_LOGIC;
SIGNAL RESET_PAUSECLK			:	STD_LOGIC;
SIGNAL CRNullCONTROL			:	STD_LOGIC; --it become zero when new value loaded in the counter
SIGNAL SET_CRNullControl		:	STD_LOGIC;
SIGNAL RESET_CRNullControl		:	STD_LOGIC;
SIGNAL StatusByteReg6_INPUT		:	STD_LOGIC; -- -> StatusByteReg(6)
SIGNAL StatusByteReg6_sel		:	STD_LOGIC;
SIGNAL DOWN_COUNT_BINARY		:	STD_LOGIC; --to decrease one unit in binary
SIGNAL DOWN_COUNT_BINARY2		:	STD_LOGIC; --to decrease two unit in binary
SIGNAL DOWN_COUNT_BINARY3		:	STD_LOGIC; --to decrease three unit in binary
SIGNAL DOWN_COUNT_BCD			:	STD_LOGIC; --to decrease one unit in bcd
SIGNAL DOWN_COUNT_BCD2			:	STD_LOGIC; --to decrease two unit in bcd
SIGNAL DOWN_COUNT_BCD3			:	STD_LOGIC; --to decrease three unit in bcd
SIGNAL ld_DOWNCOUNT				:	STD_LOGIC; --command for decreasing the counter
SIGNAL Zero_CEFLAG				:	STD_LOGIC;
SIGNAL ld_CEFLAG				:	STD_LOGIC;
SIGNAL OUT_CEFLAG 				:	STD_LOGIC;
SIGNAL ODD 						:	STD_LOGIC; --odd number
SIGNAL EVEN 					:	STD_LOGIC; --even number
SIGNAL WAIT_TOSHOW				:	STD_LOGIC; --to show LSB/MSB bits in the output
SIGNAL SET_NEWCONTROLWORD		:	STD_LOGIC;
SIGNAL RESET_NEWCONTROLWORD		:	STD_LOGIC;
SIGNAL NEWCONTROLWORD			:	STD_LOGIC; --new control word for setting
SIGNAL OUTPUT_WIRE 				:	STD_LOGIC := '0'; --output
SIGNAL FLAG						:	STD_LOGIC := '0';
SIGNAL PAUSE_CLK				:	STD_LOGIC := '0';--Used in simple reading 2 bytes format to pause clk. 0=continue. 1=pause clk

BEGIN
--------------------------------------------CONTROLLER----------------------------------------------------

RD_BACKandCOUNTLATCHCHECK:PROCESS (ControlWord, RD_BACK) --latch setting for read state
BEGIN
	SET_COUNTLATCHCHECK <= '0';

	IF (ControlWord(5 DOWNTO 4) = "00") THEN -- LATCH COMMAND
		SET_COUNTLATCHCHECK <= '1';
	ELSIF (RD_BACK = '1' AND RD_BACK'EVENT)THEN -- READ BACK COMMAND
		SET_COUNTLATCHCHECK <= '1';
	END IF;
END PROCESS RD_BACKandCOUNTLATCHCHECK;
---------------------------------------------

LatchingStatus_From_ReadBackCommand: PROCESS (STATUS_RD) --latch setting for read state
BEGIN
	SET_StatusByteReadCheck <= '0';
	IF (STATUS_RD = '1' AND STATUS_RD'EVENT) THEN
		SET_StatusByteReadCheck <= '1';
	END IF;
END PROCESS LatchingStatus_From_ReadBackCommand;
----------------------------------------------
-------------------Writing to CR--------------
seq_WRITING_CONT: PROCESS (CLK_INPUT, rst) 
BEGIN
	IF rst = '1' THEN
		WR_PSTATE <= "11";
	ELSIF CLK_INPUT = '1' AND CLK_INPUT'EVENT THEN
		WR_PSTATE <=  WR_NSTATE;
	END IF;
END PROCESS seq_WRITING_CONT;

WRITING_OPERATION: PROCESS (WR_SIGNAL , StatusByteReg, WR_PSTATE, DATABUS)
BEGIN
	Zero_CRM <= '0';
	Zero_CRL <= '0';
	ld_CRL   <= '0';
	ld_CRM   <= '0';
	SET_CRLOADED <= '0';
	SET_LoadFlag <= '0';

		CASE (WR_PSTATE) IS
			WHEN "11" =>
				IF (StatusByteReg(5 DOWNTO 4) = "01" ) THEN --LSB only
					IF (WR_SIGNAL = '1') THEN
						ld_CRL <= '1';
						WR_NSTATE <= "11";
						SET_CRLOADED <= '1';
						SET_LoadFlag <= '1';
						Zero_CRM <= '1'; 
					END IF;	
				ELSIF (StatusByteReg(5 DOWNTO 4) = "10") THEN --MSB only
					IF (WR_SIGNAL = '1') THEN
						ld_CRM <= '1';
						WR_NSTATE <= "11";
						SET_CRLOADED <= '1';
						SET_LoadFlag <= '1';
						Zero_CRL <= '1';
					END IF;	
				ELSIF (StatusByteReg(5 DOWNTO 4) = "11") THEN --first LSB then MSB
					IF (WR_SIGNAL = '1') THEN
						WR_NSTATE <= "10";
						--ld_CRL <= '1';
					END IF;	
				END IF; --StatusByteReg(5 DOWNTO 4) = "01" 
	
			WHEN "10" => --load MSB after LSB
				--ld_CRM <= '1';
				ld_CRL <= '1';
				WR_NSTATE <= "01";
				--SET_CRLOADED <= '1';
				--SET_LoadFlag <= '1';
			WHEN "01" =>
				ld_CRM <= '1';
				WR_NSTATE <= "11";
				SET_CRLOADED <= '1';
				SET_LoadFlag <= '1';
			WHEN OTHERS =>
				Zero_CRM <= '0';
				Zero_CRL <= '0';
				ld_CRL   <= '0';
				ld_CRM   <= '0';
				SET_CRLOADED <= '0';
				SET_LoadFlag <= '0';
				
		END CASE;	

END PROCESS WRITING_OPERATION;	
	
	
-----------------------------------------------------
-------------------Reading From NUM L/M--------------
seq_READING_CONT: PROCESS (CLK_INPUT, rst) 
BEGIN
	IF rst = '1' THEN
		RD_PSTATE <= "11";
	ELSIF CLK_INPUT = '1' AND CLK_INPUT'EVENT THEN
		RD_PSTATE <= RD_NSTATE;
	END IF;
END PROCESS seq_READING_CONT;

READING_FROM_NUMLM: PROCESS (RD_SIGNAL, StatusByteReadCheck, RD_PSTATE, WAIT_TOSHOW)
BEGIN

RESET_StatusByteReadCheck <= '0';
RESET_COUNTLATCHCHECK <= '0';
RESET_PAUSECLK <= '0';
SET_PAUSECLK <= '0';	
	IF (RD_SIGNAL = '1' OR WAIT_TOSHOW = '1') THEN
			IF (StatusByteReadCheck = '1') THEN
				sel_MUXDATAOUTPUT <= "00"; --StatusByteReg SELECT
			ELSE 
				CASE (RD_PSTATE) IS
					WHEN "11" =>
						IF (StatusByteReg(5 DOWNTO 4) = "01") THEN --LSB only
							sel_MUXDATAOUTPUT <= "01"; --NUM_L SELECT
							RD_NSTATE <= "11";
							RESET_COUNTLATCHCHECK <= '1';
						
						ELSIF (StatusByteReg(5 DOWNTO 4) = "10") THEN --MSB only
							sel_MUXDATAOUTPUT <= "10"; --NUM_M SELECT
							RD_NSTATE <= "11";
							RESET_COUNTLATCHCHECK <= '1';
						ELSIF (StatusByteReg(5 DOWNTO 4) = "11") THEN --first LSB then MSB
							sel_MUXDATAOUTPUT <= "01"; --NUM_L SELECT
							RD_NSTATE <= "10";--
							IF (CountLatchCheck = '0') THEN
								SET_PAUSECLK <= '1';
							END IF;--CountLatchCheck = '0'
						END IF; --StatusByteReg(5 DOWNTO 4) = "01"
					WHEN "10" =>	
						sel_MUXDATAOUTPUT <= "10"; --NUM_M SELECT
						RD_NSTATE <= "01";
						WAIT_TOSHOW <= '1';
						
					WHEN "01" =>
						RESET_COUNTLATCHCHECK <= '1';
						RESET_PAUSECLK <= '1';
						WAIT_TOSHOW <= '0';
						RD_NSTATE <= "11";	
					WHEN OTHERS =>
						RESET_StatusByteReadCheck <= '0';
						RESET_COUNTLATCHCHECK <= '0';
						RESET_PAUSECLK <= '0';
						SET_PAUSECLK <= '0';
					
				END CASE;	
			END IF;--StatusByteReadCheck = '1'
	ELSE
		RESET_StatusByteReadCheck <= '1';
	END IF;--RD_SIGNAL = '1' AND RD_SIGNAL'EVENT
END PROCESS READING_FROM_NUMLM;
---------------------------------------------------------------------------

NULLCOUNTER_PUTTING_VALCEtoCR: PROCESS (CRLOADED, CRNullCONTROL)
BEGIN
SET_CRNullControl <= '0';
RESET_CRLOADED    <= '0';

	IF (CRLOADED = '1' )THEN --Assigning NullCounterFlag to 1 after putting value in CR
		SET_CRNullControl <= '1';
		StatusByteReg6_sel <= '0'; --StatusByteReg(6) = '1'
		RESET_CRLOADED <= '1';
	
	END IF;
	
	IF (CRNullControl = '0')THEN --To 0 After putting value from CR to CE
		StatusByteReg6_sel <= '1'; --StatusByteReg(6) = '0'
	
	END IF;

END PROCESS NULLCOUNTER_PUTTING_VALCEtoCR;

-------------------------------------------------------------------------------
-----------------------------STATE MACHINE-------------------------------------

seq_controller: PROCESS(CLK, rst)
BEGIN
	IF (rst = '1' AND rst'EVENT) THEN
		 P_STATE <= START;
	ELSIF (CLK = '1' AND CLK'EVENT) THEN
			P_STATE <= N_STATE;
	END IF;	
END PROCESS seq_controller;

COMB_controller: PROCESS (MODE, P_STATE, GATE, CRNullControl, CEoutput, StatusByteReg, LoadFlag, WR_SIGNAL, WR_PSTATE, OUT_CEFLAG)
BEGIN
RESET_CRNullControl <= '0';
RESET_LoadFlag <= '0';
ld_DOWNCOUNT   <= '0';
DOWN_COUNT_BCD <= '0';
DOWN_COUNT_BCD2 <= '0';
DOWN_COUNT_BCD3 <= '0';
DOWN_COUNT_BINARY <= '0';
DOWN_COUNT_BINARY2 <= '0';
DOWN_COUNT_BINARY3 <= '0';
ld_CEFLAG <= '0';
Zero_CEFLAG <= '0';
RESET_NEWCONTROLWORD <= '0';

	CASE (P_STATE) IS
		WHEN START => 
			CASE (MODE) IS
				WHEN "000" =>
					
					IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
						OUTPUT <= '0';
						OUTPUT_WIRE <= '0';
						N_STATE <= MODE0;
					ELSE 
						N_STATE <= START;
					END IF;	
					
				WHEN "001" =>
					--OUTPUT <= '1';
					--OUTPUT_WIRE <= '1';
					IF (GATE = '1' ) THEN --COUNTER INITIALIZATION
							IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
								RESET_CRNullControl <= '1';
								RESET_LoadFlag <= '1';
								ld_DOWNCOUNT <= '1';
								OUTPUT <= '1';
								OUTPUT_WIRE <= '1';
								N_STATE <= MODE1_0;
							END IF;
					ELSE 
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
							N_STATE <= MODE1;
						ELSE 
							N_STATE <= START;
						END IF;
					END IF;
				WHEN "010" =>
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					IF (GATE = '1') THEN
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
								RESET_CRNullControl <= '1';
								RESET_LoadFlag <= '1';
								ld_DOWNCOUNT <= '1';
								OUTPUT <= '1';
								OUTPUT_WIRE <= '1';
								N_STATE <= MODE2_0;
							END IF;
					ELSE
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
							N_STATE <= MODE2;
						ELSE 
							N_STATE <= START;
						END IF;
							
					END IF;
						
				WHEN "011" =>						
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
						IF (CR(0) = '1') THEN
							ODD <= '1';
							EVEN <= '0';
						ELSE 
							EVEN <= '1';
							ODD <= '0';
						END IF;
					IF (GATE = '1') THEN
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
								RESET_CRNullControl <= '1';
								RESET_LoadFlag <= '1';
								ld_DOWNCOUNT <= '1';
								OUTPUT <= '1';
								OUTPUT_WIRE <= '1';
								N_STATE <= MODE3_0;
							END IF;
					ELSE
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
							N_STATE <= MODE3;
						ELSE 
							N_STATE <= START;
						END IF;
							
					END IF;
					
				WHEN "100" =>
					IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
							OUTPUT <= '1';
							OUTPUT_WIRE <= '1';
							N_STATE <= MODE4;
						ELSE 
							N_STATE <= START;
						END IF;
				WHEN "101" =>
					IF (GATE = '1' ) THEN --COUNTER INITIALIZATION
							IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
								RESET_CRNullControl <= '1';
								RESET_LoadFlag <= '1';
								ld_DOWNCOUNT <= '1';
								OUTPUT <= '1';
								OUTPUT_WIRE <= '1';
								N_STATE <= MODE5_0;
							END IF;
					ELSE 
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
							N_STATE <= MODE5;
						ELSE 
							N_STATE <= START;
						END IF;
					END IF;
				WHEN OTHERS =>
					OUTPUT <= '1';
					
			END CASE;
------------------------------------------------------------
----------------------MODE0---------------------------------			
		WHEN MODE0 => 
			ld_DOWNCOUNT <= '1';
			RESET_CRNullControl <= '1';
			RESET_LoadFlag <= '1';
			--OUTPUT <= '0';
			--OUTPUT_WIRE <= '0';
			N_STATE <= MODE0_0;
			
		WHEN MODE0_0 =>
			OUTPUT <= '0';
			OUTPUT_WIRE <= '0';
			IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
				IF(NEWCONTROLWORD = '1') THEN
					N_STATE <= START;
					RESET_NEWCONTROLWORD <= '1';
				ELSE 
					N_STATE <= MODE0;
					
				END IF;
			ELSE	
				IF (GATE = '1') THEN
					IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
						IF (CEoutput > "0") THEN
							DOWN_COUNT_BINARY <= '1';
							N_STATE <= MODE0_0;
						ELSE
							OUTPUT <= '1';
							OUTPUT_WIRE <= '1';
							IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE0;	
								END IF;	
							ELSE
								N_STATE <= MODE0;
							END IF;	
						END IF; --CEoutput > "0"
					ELSIF (StatusByteReg(0) = '1') THEN --BCD Count MODE
						IF (NOT(CEoutput = "1001100110011001")) THEN
							DOWN_COUNT_BCD <= '1';
							N_STATE <= MODE0_0;
						ELSE
							OUTPUT <= '1';
							OUTPUT_WIRE <= '1';
							IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE0;	
								END IF;	
							ELSE
								N_STATE <= MODE0;
							END IF;	
							
						END IF; --CEoutput /= "1001100110011001"
					
					END IF; --StatusByteReg(0) = '0'
				ELSE
					N_STATE <= MODE0_0;
				END IF; --GATE = '1'
			END IF;	--WR_SIGNAL = '1' AND StatusByteReg(5 DOWNTO 4) = "01"
------------------------------------------------------------
----------------------MODE1---------------------------------			
		WHEN MODE1 =>
			IF (GATE = '1' ) THEN --COUNTER INITIALIZATION

				IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
					RESET_CRNullControl <= '1';
					RESET_LoadFlag <= '1';
					ld_DOWNCOUNT <= '1';
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE1_0;
				ELSE
					N_STATE <= MODE1_0;
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					ld_DOWNCOUNT <= '1';
				END IF;
			ELSE 
				N_STATE <= MODE1;
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';				
			END IF;	
		WHEN MODE1_0 =>
			
			IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
				IF (CEoutput > "0") THEN
					DOWN_COUNT_BINARY <= '1';
					OUTPUT <= '0';
					OUTPUT_WIRE <= '0';
					N_STATE <= MODE1_0;
				ELSE
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE0;	
								END IF;	
							ELSE
								IF (GATE = '1') THEN
									ld_DOWNCOUNT <= '1';
									N_STATE <= MODE1_0;
								ELSE N_STATE <= MODE1;
							END IF;
						
					END IF;	
				END IF; --CEoutput > "0"
			ELSIF (StatusByteReg(0) = '1') THEN --BCD Count MODE
				IF (NOT(CEoutput = "1001100110011001")) THEN
					DOWN_COUNT_BCD <= '1';
					OUTPUT <= '0';
					OUTPUT_WIRE <= '0';
					N_STATE <= MODE1_0;
				ELSE
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE0;	
								END IF;	
							ELSE
								IF (GATE = '1') THEN
									ld_DOWNCOUNT <= '1';
									N_STATE <= MODE1_0;
								ELSE N_STATE <= MODE1;
							END IF;
						
					END IF;
							
				END IF; --CEoutput /= "1001100110011001"
			END IF; --StatusByteReg(0) = '0'
--------------------------------------------------------------
------------------------MODE2---------------------------------
		WHEN MODE2 =>
			IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
				IF (  GATE = '1' ) THEN
					RESET_CRNullControl <= '1';
					RESET_LoadFlag <= '1';
					ld_DOWNCOUNT <= '1';
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE2_0;
				ELSE 
					N_STATE <= MODE2;
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';					
				END IF;	
			ELSE
				IF (GATE = '1') THEN
					ld_DOWNCOUNT <= '1';
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE2_0;
				ELSE 
					N_STATE <= MODE2;
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
				END IF;	
			END IF;
		WHEN MODE2_0 =>
			IF (GATE = '0' ) THEN
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
			END IF;
			IF (GATE = '1') THEN 
				IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
					IF (CEoutput > "0") THEN
						OUTPUT <= '1';
						OUTPUT_WIRE <= '1';
						DOWN_COUNT_BINARY <= '1';
						N_STATE <= MODE2_0;
	
					ELSE
						OUTPUT <= '0';
						OUTPUT_WIRE <= '0';
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
						    
							IF(NEWCONTROLWORD = '1') THEN
								N_STATE <= START;
								RESET_NEWCONTROLWORD <= '1';
							ELSE
								IF (GATE = '1') THEN
									ld_DOWNCOUNT <= '1';
									N_STATE <= MODE2_0;
								ELSE
									N_STATE <= MODE2;
								END IF;
									
							END IF;	
						ELSE
							IF (GATE = '1') THEN
								ld_DOWNCOUNT <= '1';
								N_STATE <= MODE2_0;
							ELSE N_STATE <= MODE2;
							END IF;
						END IF;
								
					END IF; --CEoutput > "0"
				ELSIF (StatusByteReg(0) = '1') THEN --BCD Count MODE
					IF (NOT(CEoutput = "1001100110011001")) THEN
						OUTPUT <= '1';
						OUTPUT_WIRE <= '1';
						DOWN_COUNT_BCD <= '1';
						N_STATE <= MODE2_0;
						
					ELSE
						OUTPUT <= '0';
						OUTPUT_WIRE <= '0';
						OUTPUT <= '0';
						OUTPUT_WIRE <= '0';
						IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
						    
							IF(NEWCONTROLWORD = '1') THEN
								N_STATE <= START;
								RESET_NEWCONTROLWORD <= '1';
							ELSE
								IF (GATE = '1') THEN
									ld_DOWNCOUNT <= '1';
									N_STATE <= MODE2_0;
								ELSE
									N_STATE <= MODE2;
								END IF;
									
							END IF;	
						ELSE
							IF (GATE = '1') THEN
								ld_DOWNCOUNT <= '1';
								N_STATE <= MODE2_0;
							ELSE N_STATE <= MODE2;
							END IF;
						END IF;	
					END IF; --CEoutput /= "1001100110011001"
				END IF; --StatusByteReg(0) = '0'
			ELSE 
				N_STATE <= MODE2_0;
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
			END IF;--GATE = '1'
--------------------------------------------------------------
------------------------MODE3---------------------------------			
		WHEN MODE3 =>
			IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
				IF (GATE = '1') THEN
					RESET_CRNullControl <= '1';
					RESET_LoadFlag <= '1';
					ld_DOWNCOUNT <= '1';
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE3_0;
				ELSE
					N_STATE <= MODE3;
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
				END IF;	
			ELSE 
				IF (GATE = '1' ) THEN --COUNTER INITIALIZATION
					ld_DOWNCOUNT <= '1';
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE3_0;
				ELSE
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE3;
				END IF;--GATE = '1' AND GATE'EVENT
				
			END IF;
		WHEN MODE3_0 =>	--FIRST HALF PERIOD
			OUTPUT <= '1';
			OUTPUT_WIRE <= '1';
			
			IF (GATE = '1') THEN --COUNTING ENABLE
				IF (ODD = '1') THEN
					IF (CEoutput > "01") THEN
						OUTPUT <= '1';
						OUTPUT_WIRE <= '1';
						IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
							DOWN_COUNT_BINARY <= '1';
						ELSE DOWN_COUNT_BCD <= '1';
						END IF; --StatusByteReg(0) = '0'
						N_STATE <= MODE3_1;
					END IF;

				ELSIF(EVEN = '1') THEN
					IF (CEoutput > "10") THEN
						
						IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
							DOWN_COUNT_BINARY2 <= '1';
						ELSE DOWN_COUNT_BCD2 <= '1';	
						END IF; --StatusByteReg(0) = '0'
						N_STATE <= MODE3_0;
					ELSE
						ld_DOWNCOUNT <= '1';
						N_STATE <= MODE3_4;
					
					END IF;	
				END IF; -- ODD = '1'
			ELSE N_STATE <= MODE3_0;	
			
			END IF; --GATE = '1'	
			
		WHEN MODE3_1 => --FOR ODD NUMBER ONLY(FIRST HALF PERIOD)
			IF (GATE = '0' ) THEN
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
			END IF;
			IF (GATE = '1') THEN --COUNTING ENABLE
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
				IF (CEoutput > "10") THEN
					N_STATE <= MODE3_1;
					IF(StatusByteReg(0) = '0') THEN	
						DOWN_COUNT_BINARY2 <= '1';
					ELSE DOWN_COUNT_BCD2 <= '1';	
					END IF; --StatusByteReg(0) = '0'
				ELSE
					ld_DOWNCOUNT <= '1';
					N_STATE <= MODE3_2;
				END IF;
			ELSE 
				N_STATE <= MODE3_1;

			END IF;--GATE = '1'
		WHEN MODE3_2 => --FOR ODD NUMBER ONLY(SECOND HALF PERIOD)
			IF (GATE = '0' ) THEN
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
			END IF;
			IF (GATE = '1') THEN --COUNTING ENABLE
				OUTPUT <= '0';
				OUTPUT_WIRE <= '0';
				IF (CEoutput > "11") THEN
					N_STATE <= MODE3_3;
					IF(StatusByteReg(0) = '0') THEN	
						DOWN_COUNT_BINARY3 <= '1';
					ELSE DOWN_COUNT_BCD3 <= '1';	
					END IF; --StatusByteReg(0) = '0'
				END IF;
			ELSE 
				N_STATE <= MODE3_2;	
			END IF;
		WHEN MODE3_3 => --FOR ODD NUMBER ONLY(SECOND HALF PERIOD)
			IF (GATE = '0' ) THEN
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
			END IF;
			IF (GATE = '1') THEN --COUNTING ENABLE
				OUTPUT <= '0';
				OUTPUT_WIRE <= '0';
				IF (CEoutput > "10") THEN
					IF(StatusByteReg(0) = '0') THEN	
						DOWN_COUNT_BINARY2 <= '1';
					ELSE DOWN_COUNT_BCD2 <= '1';	
					END IF; --StatusByteReg(0) = '0'
				ELSE
					IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
						    
						IF(NEWCONTROLWORD = '1') THEN
							N_STATE <= START;
							RESET_NEWCONTROLWORD <= '1';
						ELSE
							IF (GATE = '1') THEN
								ld_DOWNCOUNT <= '1';
								N_STATE <= MODE3_0;
							ELSE
								N_STATE <= MODE3;
							END IF;		
						END IF;	
					ELSE
						IF (GATE = '1') THEN
							ld_DOWNCOUNT <= '1';
							N_STATE <= MODE3_0;
						ELSE N_STATE <= MODE3;
						END IF;
					END IF;	
				END IF;
			ELSE N_STATE <= MODE3_3;
			END IF;
		WHEN MODE3_4 =>	-- ONLY FOR EVEN NUMBER(SECOND PERIOD)
			IF (GATE = '0' ) THEN
				OUTPUT <= '1';
				OUTPUT_WIRE <= '1';
			END IF;
			
			IF (GATE = '1') THEN --COUNTING ENABLE
				OUTPUT <= '0';
				OUTPUT_WIRE <= '0';
				IF (CEoutput > "10") THEN
					IF(StatusByteReg(0) = '0') THEN	
						DOWN_COUNT_BINARY2 <= '1';
					ELSE DOWN_COUNT_BCD2 <= '1';	
					END IF; --StatusByteReg(0) = '0'
				ELSE
					IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
						    
						IF(NEWCONTROLWORD = '1') THEN
							N_STATE <= START;
							RESET_NEWCONTROLWORD <= '1';
						ELSE
							IF (GATE = '1') THEN
								ld_DOWNCOUNT <= '1';
								N_STATE <= MODE3_0;
							ELSE
								N_STATE <= MODE3;
							END IF;		
						END IF;	
					ELSE
						IF (GATE = '1') THEN
							ld_DOWNCOUNT <= '1';
							N_STATE <= MODE3_0;
						ELSE N_STATE <= MODE3;
						END IF;
					END IF;	
				END IF;
				
			ELSE 	

			END IF;			
--------------------------------------------------------------
------------------------MODE4---------------------------------			
			
		WHEN MODE4 =>
			ld_DOWNCOUNT <= '1';
			RESET_CRNullControl <= '1';
			RESET_LoadFlag <= '1';
			OUTPUT <= '1';
			OUTPUT_WIRE <= '1';
			N_STATE <= MODE4_0;
			
		WHEN MODE4_0 =>
			OUTPUT <= '1';
			OUTPUT_WIRE <= '1';
			IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
				IF(NEWCONTROLWORD = '1') THEN
					N_STATE <= START;
					RESET_NEWCONTROLWORD <= '1';
				ELSE 
					N_STATE <= MODE4;
					
				END IF;
			ELSE	
				IF (GATE = '1') THEN
					IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
						IF (CEoutput > "0") THEN
							DOWN_COUNT_BINARY <= '1';
							N_STATE <= MODE4_0;
						ELSE
							OUTPUT <= '1';
							OUTPUT_WIRE <= '1';
							IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE4;	
								END IF;	
							ELSE
								N_STATE <= MODE4_1;
							END IF;	
						END IF; --CEoutput > "0"
					ELSIF (StatusByteReg(0) = '1') THEN --BCD Count MODE
						IF (NOT(CEoutput = "1001100110011001")) THEN
							DOWN_COUNT_BCD <= '1';
							N_STATE <= MODE0_0;
						ELSE
							OUTPUT <= '1';
							OUTPUT_WIRE <= '1';
							IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE4;	
								END IF;	
							ELSE
								N_STATE <= MODE4_1;
							END IF;	
							
						END IF; --CEoutput /= "1001100110011001"
					
					END IF; --StatusByteReg(0) = '0'
				ELSE
					N_STATE <= MODE4_0;
				END IF; --GATE = '1'
			END IF;	
		WHEN MODE4_1 =>	
				OUTPUT <= '0';
				OUTPUT_WIRE <= '0';
				IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
					IF(NEWCONTROLWORD = '1') THEN
						N_STATE <= START;
						RESET_NEWCONTROLWORD <= '1';
					ELSE 
						N_STATE <= MODE4;	
					END IF;	
				ELSE
					N_STATE <= MODE4;
				END IF;			
--------------------------------------------------------------
------------------------MODE5---------------------------------		
			
		WHEN MODE5 =>
				IF((CRNullControl = '1') AND LoadFlag = '1') THEN --Wants to put a value from CR to CE
					IF (GATE = '1' ) THEN --COUNTER INITIALIZATION
						RESET_CRNullControl <= '1';
						RESET_LoadFlag <= '1';
						ld_DOWNCOUNT <= '1';
						OUTPUT <= '1';
						OUTPUT_WIRE <= '1';
						N_STATE <= MODE5_0;
					ELSE N_STATE <= MODE5;	
					END IF;	
				ELSE
					N_STATE <= MODE5_0;
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					ld_DOWNCOUNT <= '1';
				END IF;
				
		WHEN MODE5_0 =>
			IF(StatusByteReg(0) = '0') THEN	--Binary Count MODE
				IF (CEoutput > "0") THEN
					DOWN_COUNT_BINARY <= '1';
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					N_STATE <= MODE5_0;
				ELSE
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
								IF(NEWCONTROLWORD = '1') THEN
									N_STATE <= START;
									RESET_NEWCONTROLWORD <= '1';
								ELSE 
									N_STATE <= MODE5;	
								END IF;	
					ELSE
						N_STATE <= MODE5_1;	
						
					END IF;	
				END IF; --CEoutput > "0"
			ELSIF (StatusByteReg(0) = '1') THEN --BCD Count MODE
				IF (NOT(CEoutput = "1001100110011001")) THEN
					DOWN_COUNT_BCD <= '1';
					OUTPUT <= '0';
					OUTPUT_WIRE <= '0';
					N_STATE <= MODE5_0;
				ELSE
					OUTPUT <= '1';
					OUTPUT_WIRE <= '1';
					IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
						IF(NEWCONTROLWORD = '1') THEN
							N_STATE <= START;
							RESET_NEWCONTROLWORD <= '1';
						ELSE 
							N_STATE <= MODE5;	
						END IF;	
					ELSE 
						N_STATE <= MODE5_1;
								
					END IF;
							
				END IF; --CEoutput /= "1001100110011001"
			END IF; --StatusByteReg(0) = '0'
		WHEN MODE5_1 =>	
			OUTPUT <= '0';
			OUTPUT_WIRE <= '0';
			IF ((CRNullControl = '1') AND LoadFlag = '1' ) THEN
				IF(NEWCONTROLWORD = '1') THEN
					N_STATE <= START;
					RESET_NEWCONTROLWORD <= '1';
				ELSE 
					N_STATE <= MODE5;	
				END IF;	
			ELSE 
				N_STATE <= MODE5;
						
			END IF;
			
		WHEN OTHERS =>
			RESET_CRNullControl <= '0';
			RESET_LoadFlag <= '0';
			ld_DOWNCOUNT   <= '0';
			DOWN_COUNT_BCD <= '0';
			DOWN_COUNT_BINARY <= '0';
			ld_CEFLAG <= '0';
			Zero_CEFLAG <= '0';	
	END CASE;
	
END PROCESS COMB_controller;
---------------------------------------------------------------------
------------------------------------DATAPATH-------------------------
MODE    <= CONTROLWORD (3 DOWNTO 1);
DATABUS_OUTPUT: PROCESS(CLK_INPUT)
BEGIN
	IF(CLK_INPUT = '1' AND CLK_INPUT'EVENT) THEN
		IF(RD_SIGNAL = '1' OR WAIT_TOSHOW = '1') THEN
			DATABUS <= DataOutput;
		ELSE DATABUS <=	(OTHERS => 'Z');
		END IF;
	END IF;

END PROCESS DATABUS_OUTPUT;
--DATABUS <= DataOutput WHEN (RD_SIGNAL = '1') ELSE (OTHERS => 'Z');
CLK     <= CLK_INPUT WHEN (PAUSE_CLK = '0' OR PAUSE_CLK = 'U') ELSE '1';
NUM_L   <= CEoutput(7 DOWNTO 0) WHEN (COUNTLATCHCHECK = '0' OR COUNTLATCHCHECK = 'U') ELSE NUM_L;
NUM_M   <= CEoutput(15 DOWNTO 8)WHEN (COUNTLATCHCHECK = '0' OR COUNTLATCHCHECK = 'U') ELSE NUM_M;
StatusByteReg(7) <= OUTPUT_WIRE;
StatusByteReg(6) <= StatusByteReg6_INPUT; 
CR <= (CR_M & CR_L);
StatusByte_Reg: PROCESS (CLK_INPUT)
BEGIN
	IF (CLK_INPUT = '1' AND CLK_INPUT'EVENT) THEN
		SET_NEWCONTROLWORD <= '0';
		IF (NOT(CONTROLWORD(5 DOWNTO 4)= "00") OR (NOT(CONTROLWORD(7 DOWNTO 6) = "11"))) THEN
			StatusByteReg(5 DOWNTO 0) <= CONTROLWORD(5 DOWNTO 0);
			SET_NEWCONTROLWORD <= '1';
		END IF;
	END IF;	
END PROCESS StatusByte_Reg;	
	
CRM_Reg:ENTITY WORK.Reg1 
	GENERIC MAP(LEN_DATA)						
	PORT MAP(DATABUS, CLK_INPUT, rst, ld_CRM, Zero_CRM, CR_M);	

CRL_Reg:ENTITY WORK.Reg1 
	GENERIC MAP(LEN_DATA)						
	PORT MAP(DATABUS, CLK_INPUT, rst, ld_CRL, Zero_CRL, CR_L);

OUTPUTFLAG_Reg:ENTITY WORK.Reg_1BIT	
	PORT MAP ('1', CLK_INPUT, rst, Zero_CEFLAG, ld_CEFLAG, OUT_CEFLAG);
NEW_CONTROLWORD:ENTITY WORK.SR_REG 
	PORT MAP (SET_NEWCONTROLWORD, RESET_NEWCONTROLWORD, NEWCONTROLWORD);	

SR_LATCHCOUNT:ENTITY WORK.SR_REG 
	PORT MAP (SET_COUNTLATCHCHECK, RESET_COUNTLATCHCHECK, COUNTLATCHCHECK);

SR_CRLOADED:ENTITY WORK.SR_REG 
	PORT MAP (SET_CRLOADED, RESET_CRLOADED, CRLOADED);

SR_LoadFlag:ENTITY WORK.SR_REG 
	PORT MAP (SET_LoadFlag, RESET_LoadFlag, LoadFlag);

SR_StatusByteReadCheck:ENTITY WORK.SR_REG 
	PORT MAP (SET_StatusByteReadCheck, RESET_StatusByteReadCheck, StatusByteReadCheck);

SR_PAUSECLK:ENTITY WORK.SR_REG 
	PORT MAP (SET_PAUSECLK, RESET_PAUSECLK, PAUSE_CLK);	
	
SR_CRNullControl:ENTITY WORK.SR_REG 
	PORT MAP (SET_CRNullControl, RESET_CRNullControl, CRNullControl);

MUX_DATAOUTPUT:ENTITY WORK.MUX3 
	GENERIC MAP(LEN_DATA)
	PORT MAP(StatusByteReg, NUM_L, NUM_M, sel_MUXDATAOUTPUT, DataOutput);

MUX_StatusByteReg6:ENTITY WORK.MUX2 
	PORT MAP('1', '0', StatusByteReg6_sel,StatusByteReg6_INPUT);


MODULE_DOWNCOUNTER:ENTITY WORK.DOWN_COUNTER
	GENERIC MAP(2*LEN_DATA)
	PORT MAP(CLK, rst, CR, DOWN_COUNT_BINARY,DOWN_COUNT_BINARY2,DOWN_COUNT_BINARY3, DOWN_COUNT_BCD,DOWN_COUNT_BCD2,DOWN_COUNT_BCD3 
	, ld_DOWNCOUNT, MODE, CEoutput);	
END behavioral;
