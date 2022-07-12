--*****************************************************************************/
--	Filename:		UART_TX.vhd
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
--	UART TX is transmitter part of this module. it transmits serial data by 
--  TXD and recieves complete word from i_TX_Byte. it also recieves control word
--  from this input. by this control word we can set number of stop bit, enable parity, 
--  even/odd parity, baud rate, length of data. 1 value as stop bit puts on TDX. when 
--  we have bits for tranmit first put 0 value as start bit then puts data, parity
--  (if it is enable) and stop bit(s). 
--*****************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_TX IS
  GENERIC (
			COUNTER_RANGE: INTEGER := 87;    
			len			 : INTEGER := 8;
			Cnt_len		 : INTEGER := 4
		);
  PORT (
    Clk       			: IN  STD_LOGIC;
	rst       			: IN  STD_LOGIC;
	nCS       			: IN  STD_LOGIC; --active low chip select
	nCTS        		: IN  STD_LOGIC; --active low clear to send data serial
	CD       			: IN  STD_LOGIC; --databus consist of control word or data
    nWR     			: IN  STD_LOGIC; --active low write signal
    i_TX_Byte   		: IN  STD_LOGIC_VECTOR(len-1 downto 0); --databus for recieving data or control word from cpu
    TXD 				: OUT STD_LOGIC; --data serial transfer 
	TXE  				: OUT STD_LOGIC --transmitter empty(TX has no bits to send)
	
    );
end UART_TX;

ARCHITECTURE behavioral OF UART_TX IS
 
TYPE STATE_TYPE IS (IDLE, TX_Start_Bit, TX_Data_Bits, TX_Stop_Bit, Cleanup, SETTING, PARITY_SEND, TX_Stop_Bit1, TX_Stop_Bit2);
SIGNAL p_state, n_state : STATE_TYPE := IDLE;

SIGNAL RESET_Clk_Count 		: STD_LOGIC;
SIGNAL INC_Clk_Count 		: STD_LOGIC;
SIGNAL RESET_Bit_Index 		: STD_LOGIC;
SIGNAL INC_Bit_Index 		: STD_LOGIC;
SIGNAL flag 				: STD_LOGIC := '0';
SIGNAL r_Bit_Index   		: INTEGER range 0 to len := 0;  
SIGNAL r_TX_Data   			: STD_LOGIC_VECTOR(len-1 downto 0) := (others => '0'); --data for sending
SIGNAL DATA_SETTING			: STD_LOGIC_VECTOR(len-1 downto 0) := (others => '0'); --control word
SIGNAL Clk_Count 			: INTEGER range 0 to 64 := 0; --for counting pulse width
SIGNAL TX_Done   			: STD_LOGIC := '0';
SIGNAL ld_iTXByte			: STD_LOGIC; --loading recieved data in register
SIGNAL PARITY				: STD_LOGIC;
SIGNAL Zero_iTXByte			: STD_LOGIC;
SIGNAL high_amP				: STD_LOGIC;
SIGNAL ld_SETTINGBUFFER		: STD_LOGIC; --saving control word
SIGNAL Zero_SETTINGBUFFER	: STD_LOGIC;
SIGNAL PARITI_ENABLE		: STD_LOGIC;
SIGNAL PARITI_EVENODD		: STD_LOGIC; -- EVEN = 1 / ODD = 0
SIGNAL DATA_LEN_FORPARITY	: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL CLKS_PER_BIT			: INTEGER range 0 to 64 := 0;
SIGNAL DATASERIAL_LEN		: INTEGER range 0 to 64 := 0; --serial data with
SIGNAL STOPBIT_NUM			: INTEGER range 0 to 2 := 0; -- number of stop bits
   
BEGIN
   
UART_TX : PROCESS (p_state, Clk_Count, r_Bit_Index, nCTS, nWR, CD ) --WR =i_TX_DV 
BEGIN
        
		TX_Done   <= '0';
		RESET_Clk_Count <= '0';
		RESET_Bit_Index <= '0';	
		INC_Clk_Count <= '0';
		RESET_Clk_Count <= '0';
		INC_Bit_Index <= '0';
		ld_iTXByte <= '0';
		ld_SETTINGBUFFER <= '0';
	IF ( nCS = '0') THEN		
		CASE p_state IS
			
			WHEN IDLE =>
          
				TXD <= '1';			--output TX 
				TX_Done   <= '0';		  
				RESET_Clk_Count <= '1';
				RESET_Bit_Index <= '1';
 
				IF (nWR = '0' AND CD = '0') THEN --data ready for transfer from CPU 
					ld_iTXByte <= '1';   --saving (len-1)bits transfer from memory
					n_state <= TX_Start_Bit;
					TXE <= '0';
				ELSIF (nWR = '0' AND CD = '1') THEN
					ld_SETTINGBUFFER <= '1'; --saving control word
					n_state <= SETTING;
				END IF;
				
			WHEN SETTING =>
				CASE (DATA_SETTING(1 DOWNTO 0)) IS
					WHEN "01" =>
						CLKS_PER_BIT <= 1;
					WHEN "10" =>
						CLKS_PER_BIT <= 16;
					WHEN "11" =>
						CLKS_PER_BIT <= 64;
					WHEN OTHERS =>
						CLKS_PER_BIT <= 0;
				END CASE;
				CASE (DATA_SETTING(3 DOWNTO 2)) IS
					WHEN "00" =>
						DATASERIAL_LEN <= 5;
						DATA_LEN_FORPARITY <= "0101";
					WHEN "01" =>
						DATASERIAL_LEN <= 6;
						DATA_LEN_FORPARITY <= "0110";
					WHEN "10" =>
						DATASERIAL_LEN <= 7;
						DATA_LEN_FORPARITY <= "0111";
					WHEN "11" =>
						DATASERIAL_LEN <= 8;
						DATA_LEN_FORPARITY <= "1000";
					WHEN OTHERS =>
						flag <= '1';
				END CASE;
				PARITI_ENABLE  <= DATA_SETTING(4); 
				PARITI_EVENODD <= DATA_SETTING(5);
				CASE (DATA_SETTING(7 DOWNTO 6)) IS
					WHEN "01" =>
						STOPBIT_NUM <= 1;
					WHEN "11" =>
						STOPBIT_NUM <= 2;
					WHEN OTHERS =>
						STOPBIT_NUM <= 1;
				END CASE;
				n_state <= IDLE;
		
			-- Send out Start Bit. Start bit = 0
			WHEN TX_Start_Bit =>
				IF (nCTS = '0') THEN
					 TXD <= '0';		--set start bit 
					 -- Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
					IF ((Clk_Count < CLKS_PER_BIT-1) AND (nCTS = '0')) THEN
						INC_Clk_Count <= '1';
						n_state   <= TX_Start_Bit;
					ELSE 
						RESET_Clk_Count <= '1';
						n_state   <= TX_Data_Bits;
					END IF;
				ELSE TXD <= '1';	
				END IF;
                    
        -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish          
			WHEN TX_Data_Bits =>
				TXD <= r_TX_Data(r_Bit_Index);
           
				IF Clk_Count < CLKS_PER_BIT-1 THEN
					INC_Clk_Count <= '1';
					n_state   <= TX_Data_Bits;
				ELSE
					RESET_Clk_Count <= '1';
					IF r_Bit_Index < (DATASERIAL_LEN-1) THEN
						INC_Bit_Index <= '1';
						n_state   <= TX_Data_Bits;
					ELSE 
						RESET_Bit_Index <= '1';
						IF (PARITI_ENABLE = '1') THEN
							n_state   <= PARITY_SEND;
						ELSE n_state   <= TX_Stop_Bit;
						
						END IF;		
					END IF;
	
				END IF;
			WHEN PARITY_SEND =>
				TXD <= PARITY;
				IF Clk_Count < CLKS_PER_BIT-1 THEN
					INC_Clk_Count <= '1';
					n_state   <= PARITY_SEND;
				ELSE
					RESET_Clk_Count <= '1';
					n_state   <= TX_Stop_Bit1;
				END IF;	
        -- Send out Stop bit.  Stop bit = 1
			WHEN TX_Stop_Bit1 =>
				TXD <= '1';
 
        -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
				IF (Clk_Count < CLKS_PER_BIT-1)  THEN
					INC_Clk_Count <= '1';
					n_state   <= TX_Stop_Bit1;
				ELSE
					RESET_Clk_Count <= '1';
					IF (STOPBIT_NUM = 2 ) THEN
						n_state   <= TX_Stop_Bit2;
					ELSIF (STOPBIT_NUM = 1) THEN
						TX_Done   <= '1';
						n_state   <= Cleanup;	
					END IF;	
				END IF; 
			WHEN TX_Stop_Bit2 =>	
				TXD <= '1';
				IF (Clk_Count < CLKS_PER_BIT-1)  THEN
					INC_Clk_Count <= '1';
					n_state   <= TX_Stop_Bit2;
				ELSE
					RESET_Clk_Count <= '1';
					n_state   <= Cleanup;
				END IF;	
        -- Stay here 1 clock
        WHEN Cleanup =>
          TX_Done   <= '1';
		  TXE <= '1';
          n_state   <= IDLE;
       
        WHEN OTHERS =>
          n_state <= IDLE;
 
      END CASE;
	END IF; -- CS = '0'  
  END PROCESS UART_TX;
 
  
sequential_RX_controller: PROCESS (clk, rst) 
						BEGIN
							IF rst = '1' THEN
								p_state <= IDLE;
							ELSIF clk = '1' AND clk'EVENT THEN
								p_state <=  n_state;
							END IF;
END PROCESS sequential_RX_controller;

SERIAL_DATA_COUNTER: ENTITY WORK.Counter --counter to Determine pulse width
					GENERIC MAP(COUNTER_RANGE)
					PORT MAP(clk, rst, RESET_Clk_Count, INC_Clk_Count, Clk_Count);
					
INDEX_GENERATOR: ENTITY WORK.Counter --counter to count tranmitted data
					GENERIC MAP(len)
					PORT MAP(clk, rst, RESET_Bit_Index, INC_Bit_Index, r_Bit_Index);  
  
TRANSMITTERBUFFER:ENTITY WORK.Reg_UART -- registering data from cpu
	GENERIC MAP(len	)
	PORT MAP(i_TX_Byte, clk, rst, ld_iTXByte, Zero_iTXByte, high_amP, r_TX_Data);
	
SETTINGBUFFER_TX:ENTITY WORK.Reg_UART --registering control word 
	GENERIC MAP(len)
	PORT MAP(i_TX_Byte, clk, rst, ld_SETTINGBUFFER, Zero_SETTINGBUFFER, high_amP, DATA_SETTING);
		

PARITY_MODULE: ENTITY WORK.PARITY_GENERATOR --module for producing parity bit
	GENERIC MAP(len )
	PORT MAP( r_TX_Data, DATA_LEN_FORPARITY, PARITI_EVENODD, PARITY	);

end behavioral;