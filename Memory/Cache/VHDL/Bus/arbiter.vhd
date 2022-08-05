--*****************************************************************************/
--	Filename:		arbiter.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			20 July 2022
--	Authors:	 	Alireza
--	Last Author: 	Alireza
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--
--*****************************************************************************/
--	File content description:
--	A very simple bus "arbiter"
--	proiority-based: DEVICE_0, DEVICE_1, ...
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY arbiter IS
	PORT (
		-- system
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- device 0
		req_0				: IN  STD_LOGIC;
		gnt_0				: OUT STD_LOGIC;
		-- device 1
		req_1				: IN  STD_LOGIC;	
		gnt_1				: OUT STD_LOGIC
	);		
END ENTITY arbiter;

ARCHITECTURE behavioral OF arbiter IS
	
	TYPE state IS (
		IDLE, -- 0
		DEVICE_0, -- 1
		DEVICE_1  -- 2
	);
	
	SIGNAL p_state, n_state : state;
	
BEGIN
			
	-- Sequential Part
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				p_state <= IDLE;
			ELSE
				p_state <= n_state;
			END IF;
		END IF;
	END PROCESS;

	-- Combinational Part, next state
	PROCESS(p_state, req_0, req_1) BEGIN
		n_state <= IDLE;
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				IF req_0 = '1' THEN 
					n_state <= DEVICE_0;
				ELSIF req_1 = '1' THEN
					n_state <= DEVICE_1; 
				ELSE
					n_state <= IDLE; 
				END IF; 
				
			WHEN DEVICE_0 => -- 1
				IF req_0 = '1' THEN
					n_state <= DEVICE_0; 
				ELSE
					n_state <= IDLE; 
				END IF;
				
			WHEN DEVICE_1 => -- 2
				IF req_1 = '1' THEN
					n_state <= DEVICE_1; 
				ELSE
					n_state <= IDLE; 
				END IF;
			
			WHEN OTHERS => 
				n_state <= IDLE; 
		END CASE; 
	END PROCESS;
	
	-- Combinational Part, outputs
	PROCESS(p_state) BEGIN
		gnt_0 <= '0';
		gnt_1 <= '0';
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				gnt_0 <= '0';
				gnt_1 <= '0';				
				
			WHEN DEVICE_0 => -- 1
				gnt_0 <= '1'; 
				
			WHEN DEVICE_1 => -- 2
				gnt_1 <= '1'; 
				
			WHEN OTHERS => 
				gnt_0 <= '0';
				gnt_1 <= '0';
		END CASE; 
	END PROCESS;
	
END ARCHITECTURE behavioral;