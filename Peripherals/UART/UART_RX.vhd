--*****************************************************************************/
--	Filename:		UART_RX.vhd
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
--	File content description:
--	UART RX is receiver part of this module. it recieves serial data from 
--  RX_DATA_Serial and send complete word by O_RX_Byte. it also recieves c
--  ontrol word from this input. by this control word we can set number of 
--  stop bit, enable parity, even/odd parity, baud rate, length of data.
--  when the RX_DATA_Serial becomes 0 the reception starts and recieves 
--  start bit then data, parity(if it is enable) and stop bit(s) 
--*****************************************************************************/
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
USE IEEE.std_logic_arith.all;
USE IEEE.numeric_std.all;
ENTITY UART_RX IS
	GENERIC ( len				: INTEGER := 8;
			  COUNTER_RANGE 	: INTEGER := 87;
			  DATA_SERIAL_len	: INTEGER := 8;
			  Cnt_len			: INTEGER := 4);
	PORT (	  Clk				: IN  STD_LOGIC;
	          rst				: IN  STD_LOGIC;
			  nCS				: IN  STD_LOGIC; --active low chip select                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
			  CD				: IN  STD_LOGIC; --databus consist of control word or data 
			  nRD				: IN  STD_LOGIC; --active low read signal
			  nWR     			: IN  STD_LOGIC; --active loww write signal
			  RX_DATA_Serial	: IN  STD_LOGIC; --serial transfer port
			  O_RX_Byte			: INOUT STD_LOGIC_VECTOR(7 downto 0); --databus
			  TXRDY  			: OUT STD_LOGIC; --(transmitter ready) it shows to cpu that 8251 is ready to recieves data
			  RXRDY  			: OUT STD_LOGIC; --(Receiver Ready) it is raised high to to signal the cpu that 8251 has a complete character to fetch
			  BREAK  			: OUT STD_LOGIC --GOES HIGH WHEN HAVE 2 STOP BIT
			  );
END UART_RX;

ARCHITECTURE behavioral of UART_RX is
 
TYPE STATE_TYPE is (IDLE, RX_Start_Bit, RX_Data_Bits, RX_Stop_Bit, Cleanup, SETTING, PARITY_RECEIVE, RX_Stop_Bit1, RX_Stop_Bit2);
SIGNAL p_state, n_state : STATE_TYPE := IDLE;

SIGNAL INC_Clk_Count 		: STD_LOGIC;
SIGNAL RESET_Clk_Count  	: STD_LOGIC; 
SIGNAL INC_INDEX 			: STD_LOGIC;
SIGNAL RESET_INDEX  		: STD_LOGIC;
SIGNAL SAVE_DATA  			: STD_LOGIC;
SIGNAL PARITY_SAVE  		: STD_LOGIC;
SIGNAL PARITY 				: STD_LOGIC;
SIGNAL DONE					: STD_LOGIC := '0';
SIGNAL Clk_Count 			: INTEGER range 0 to COUNTER_RANGE-1 := 0; --for counting pulse width
SIGNAL Bit_Index 			: INTEGER range 0 to DATA_SERIAL_len-1 := 0;  -- 8 Bits Total
SIGNAL RX_Byte   			: STD_LOGIC_VECTOR(DATA_SERIAL_len-1 downto 0) := (others => '0'); --recieved data register
SIGNAL ZERO   				: STD_LOGIC_VECTOR(Cnt_len-1 downto 0) := (others => '0');
SIGNAL DATA_SETTING_RX		: STD_LOGIC_VECTOR (len-1 DOWNTO 0); --recieved control word for setting
SIGNAL ld_SETTINGBUFFER_RX	: STD_LOGIC;
SIGNAL Zero_SETTINGBUFFER_RX: STD_LOGIC;
SIGNAL PARITI_ENABLE		: STD_LOGIC;
SIGNAL high_amP				: STD_LOGIC;
SIGNAL Zero_PARITYREG		: STD_LOGIC;
SIGNAL FLAG					: STD_LOGIC;
SIGNAL PARITI_EVENODD		: STD_LOGIC; -- EVEN = 1 / ODD = 0
SIGNAL CLKS_PER_BIT			: INTEGER range 0 to 64 := 0;
SIGNAL DATASERIAL_LEN		: INTEGER range 0 to 64 := 0;
SIGNAL STOPBIT_NUM			: INTEGER range 0 to 2 := 0;
			
BEGIN
  
UART_RX : PROCESS (p_state, RX_DATA_Serial, Clk_Count, nRD, nWR, CD, DATA_SETTING_RX )
BEGIN

		INC_Clk_Count<= '0';
		RESET_Clk_Count <= '0';
		SAVE_DATA <= '0';
		INC_INDEX <= '0';
		RESET_INDEX <= '0';
		ld_SETTINGBUFFER_RX <= '0';
		PARITY_SAVE <= '0';
		
	IF ( nCS = '0') THEN		
		CASE p_state is
			WHEN IDLE =>
				BREAK <= '0';
				DONE <= '0';
				TXRDY <= '1';
				IF (nRD = '0') THEN
					RXRDY <= '0';
				END IF;
				
				IF (nWR = '0' AND CD = '1') THEN
					ld_SETTINGBUFFER_RX <= '1';
					n_state <= SETTING;
				ELSIF RX_DATA_Serial = '0' THEN       -- Start bit detected
					n_state <= RX_Start_Bit;
				ELSE
					n_state <= IDLE;
				END IF;
				
			WHEN SETTING =>
				CASE (DATA_SETTING_RX(1 DOWNTO 0)) IS
					WHEN "01" =>
						CLKS_PER_BIT <= 1;
					WHEN "10" =>
						CLKS_PER_BIT <= 16;
					WHEN "11" =>
						CLKS_PER_BIT <= 64;
					WHEN OTHERS =>
						CLKS_PER_BIT <= 0;
				END CASE;
				CASE (DATA_SETTING_RX(3 DOWNTO 2)) IS
					WHEN "00" =>
						DATASERIAL_LEN <= 5;
					WHEN "01" =>
						DATASERIAL_LEN <= 6;
					WHEN "10" =>
						DATASERIAL_LEN <= 7;
					WHEN "11" =>
						DATASERIAL_LEN <= 8;
					WHEN OTHERS =>
						FLAG <= '1';
				END CASE;
				PARITI_ENABLE  <= DATA_SETTING_RX(4); 
				PARITI_EVENODD <= DATA_SETTING_RX(5);
				CASE (DATA_SETTING_RX(7 DOWNTO 6)) IS
					WHEN "01" =>
						STOPBIT_NUM <= 1;
					WHEN "11" =>
						STOPBIT_NUM <= 2;
					WHEN OTHERS =>
						STOPBIT_NUM <= 1;
				END CASE;
				n_state <= IDLE;

        -- Check middle of start bit to make sure it's still low
			WHEN RX_Start_Bit =>
				TXRDY <= '0';
				INC_Clk_Count <= '1';
				
				IF Clk_Count = (CLKS_PER_BIT-1)/2 THEN
					IF RX_DATA_Serial = '0' THEN
						RESET_Clk_Count <= '1';  -- reset counter since we found the middle
						n_state <= RX_Data_Bits;
					ELSE
						n_state <= IDLE;
					END IF;
				END IF;
				
			-- Wait CLKS_PER_BIT-1 clock cycles to sample serial data
			WHEN RX_Data_Bits =>
				IF Clk_Count < CLKS_PER_BIT-1 THEN
					INC_Clk_Count <= '1';
				ELSE
					RESET_Clk_Count <= '1';
					SAVE_DATA <= '1';
				
				-- Check if we have sent out all bits
					IF Bit_Index < DATASERIAL_LEN THEN
						INC_INDEX <= '1';
						n_state   <= RX_Data_Bits;
					ELSE
						DONE <= '1';
						RESET_INDEX <= '1';
						IF (PARITI_ENABLE = '1') THEN
							n_state   <= PARITY_RECEIVE;
						ELSE n_state   <= RX_Stop_Bit;
						
						END IF;	
					END IF;
				END IF;
				
			WHEN PARITY_RECEIVE =>
				IF Clk_Count < CLKS_PER_BIT-1 THEN
					INC_Clk_Count <= '1';
				ELSE
					RESET_Clk_Count <= '1';
					PARITY_SAVE <= '1';
					n_state   <= RX_Stop_Bit1;
				END IF;
			-- Receive Stop bit.  Stop bit = 1
			WHEN RX_Stop_Bit1 => --first stop bit
			-- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
				IF Clk_Count < CLKS_PER_BIT-1 THEN
					INC_Clk_Count <= '1';
					n_state   <= RX_Stop_Bit;
					
				ELSE
					RESET_Clk_Count <= '1';
					n_state   		<= RX_Stop_Bit2;
				END IF;
				
			WHEN RX_Stop_Bit2 => --if have two stop bit (second stop bit)
				IF Clk_Count < CLKS_PER_BIT-1 THEN
					INC_Clk_Count <= '1';
					n_state   <= RX_Stop_Bit2;	
				ELSE
					IF (RX_DATA_Serial = '0') THEN
						BREAK <= '1';
					ELSE BREAK <= '0';	
					END IF;
					RXRDY <= '1';
					RESET_Clk_Count <= '1';
					n_state   		<= Cleanup;
				END IF;
				
			-- Stay here 1 clock
			WHEN Cleanup =>
			IF (nRD = '0') THEN
				RXRDY <= '0';
			END IF;
			n_state 	<= IDLE;
		
			WHEN OTHERS =>
			n_state <= IDLE;
			
      END CASE;
	END IF; --CS = '0'  
END PROCESS UART_RX;

sequential_RX_controller: PROCESS (clk, rst) 
						BEGIN
							IF rst = '1' THEN
								p_state <= IDLE;
							ELSIF clk = '1' AND clk'EVENT THEN
								p_state <=  n_state;
							END IF;
END PROCESS sequential_RX_controller;


SAVEDATA:PROCESS(clk) --save serial data that recieved 
	BEGIN
		IF ( clk = '1' and clk'EVENT ) THEN
			IF SAVE_DATA = '1' THEN
				RX_Byte( CONV_INTEGER(Bit_Index)) <= RX_DATA_Serial;
			END IF; 
			IF ( DONE = '1') THEN
				IF (NOT(DATASERIAL_LEN = 8)) THEN
					RX_Byte(len-1 DOWNTO DATASERIAL_LEN) <= (OTHERS => '0');
				
				END IF;
			END IF;
		END IF;		
END PROCESS SAVEDATA;


SERIAL_DATA_COUNTER: ENTITY WORK.Counter --counter to Determine the sampling time
					GENERIC MAP(COUNTER_RANGE)
					PORT MAP(clk, rst, RESET_Clk_Count, INC_Clk_Count, Clk_Count);
					
INDEX_GENERATOR: ENTITY WORK.Counter --counter to count recieved data
					GENERIC MAP(DATA_SERIAL_len)
					PORT MAP(clk, rst, RESET_INDEX, INC_INDEX, Bit_Index);
 
 o_RX_Byte <= RX_Byte WHEN ( nRD = '0'  AND nCS = '0') ELSE (OTHERS => 'Z'); 
 
SETTINGBUFFER_RX:ENTITY WORK.Reg_UART -- registering setting bits
	GENERIC MAP(len)
	PORT MAP(O_RX_Byte, clk, rst, ld_SETTINGBUFFER_RX, Zero_SETTINGBUFFER_RX, high_amP, DATA_SETTING_RX);
	
PARITY_RX:ENTITY WORK.Reg1_UART --registering receives parity
	PORT MAP(RX_DATA_Serial, clk, rst, PARITY_SAVE, Zero_PARITYREG, high_amP, PARITY);				
   
end behavioral;  
