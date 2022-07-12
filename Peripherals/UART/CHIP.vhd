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
--	File content description:
--	This module consist of two part: UART_TX for transmitting serial data and 
--  UART_RX for receiving serial data. 
--*****************************************************************************/
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY CHIP IS
	GENERIC( COUNTER_RANGE	:	INTEGER	:=	87;
			 len			:	INTEGER	:=	8;
			 Cnt_len		:	INTEGER	:=	4;
			 DATA_SERIAL_len:	INTEGER	:=	8);
	PORT (
	CLK         		: IN STD_LOGIC;    			
	rst         		: IN STD_LOGIC;
	nWR         		: IN STD_LOGIC;
	nRD         		: IN STD_LOGIC;
	CD         			: IN STD_LOGIC;
	nCS         		: IN STD_LOGIC;
	nCTS         		: IN STD_LOGIC; 
	DATA   				: INOUT STD_LOGIC_VECTOR(len-1 downto 0); 
	TXE     			: OUT STD_LOGIC; 
	TXRDY     			: OUT STD_LOGIC; 
	RXRDY     			: OUT STD_LOGIC; 
	BREAK     			: OUT STD_LOGIC  
	);		 
END CHIP;
 
ARCHITECTURE behavieral of CHIP is
   
SIGNAL w_TX_DONE   		: STD_LOGIC;
SIGNAL w_RX_DV     		: STD_LOGIC;
SIGNAL o_TX_Active		: STD_LOGIC;
SIGNAL RX_DATA_Serial 	: STD_LOGIC;
SIGNAL DATA_CHECK 		: STD_LOGIC;
SIGNAL w_RX_BYTE   		: std_logic_vector(7 downto 0);
SIGNAL SETTING_RX		: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL r_RX_SERIAL 		: STD_LOGIC := '1';
       
BEGIN
 
  -- Instantiate UART transmitter
  UART_TX_INST : ENTITY WORK.UART_TX
    GENERIC MAP ( COUNTER_RANGE, len, Cnt_len)
    PORT MAP ( Clk, rst, nCS, nCTS, CD, nWR, DATA, RX_DATA_Serial, TXE);
 			
  -- PARITI_EVENODD	 Instantiate UART Receiver
  UART_RX_INST : ENTITY WORK.UART_RX
    GENERIC MAP ( len, COUNTER_RANGE, DATA_SERIAL_len, Cnt_len)
    PORT MAP ( Clk, rst, nCS, CD, nRD, nWR, RX_DATA_Serial, DATA, TXRDY, RXRDY, BREAK); 				
	
	  
end behavieral;
		
