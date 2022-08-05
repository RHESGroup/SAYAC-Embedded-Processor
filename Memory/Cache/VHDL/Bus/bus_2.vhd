--*****************************************************************************/
--	Filename:		bus_2.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		2.000
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
--	A very simple bus
--	- shared bus
--	bus_2 vs bus_v1: BUS_ADR_WIDTH = CPU_ADR_WIDTH - log2(BUS_DATA_WIDTH/CPU_DATA_WIDTH) := 14 (instead of 16)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY bus_2 IS
	GENERIC (
		BUS_DATA_WIDTH		: INTEGER := 64;	-- bus data
		BUS_ADR_WIDTH		: INTEGER := 14		-- bus address
	);
	PORT (
		-- system ----------------------------------------------------------
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- Master interface-------------------------------------------------
		-- -- datapath
		m_bus_address		: IN  STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);	-- address from cpu
		m_bus_datain	    : OUT STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0);   -- cache data_in from cpu
		m_bus_dataout	    : IN  STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0);   -- CPU dataout (to cpu)  
		-- -- controller
		m_bus_rd			: IN  STD_LOGIC;
		m_bus_wr			: IN  STD_LOGIC;
		m_bus_ready			: OUT STD_LOGIC;
		m_bus_req			: IN  STD_LOGIC;
		m_bus_gnt			: OUT STD_LOGIC;
		-- Slave Bus interface----------------------------------------------
		-- -- datapath
		s_bus_address		: OUT STD_LOGIC_VECTOR (BUS_ADR_WIDTH - 1 DOWNTO 0);-- address to memory (bus)
		s_bus_datain	    : OUT STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0);	-- memory block_in (64-bit), Mem provides a block (not a data)
		s_bus_dataout 		: IN  STD_LOGIC_VECTOR (BUS_DATA_WIDTH - 1 DOWNTO 0);	-- memory block_out(64-bit), Mem provides a block (not a data)
		-- -- controller
		s_bus_rd			: OUT STD_LOGIC;
		s_bus_wr			: OUT STD_LOGIC;
		s_bus_ready			: IN  STD_LOGIC
	);		
END ENTITY bus_2;

ARCHITECTURE behavioral OF bus_2 IS
	SIGNAL m_bus_req_unused	: STD_LOGIC;
	SIGNAL m_bus_gnt_unused	: STD_LOGIC;
	
BEGIN
	
	s_bus_address	<= m_bus_address;
	s_bus_datain	<= m_bus_dataout;
	m_bus_datain	<= s_bus_dataout;
	s_bus_rd		<= m_bus_rd;
	s_bus_wr		<= m_bus_wr;
	m_bus_ready		<= s_bus_ready;

	-- arbiter
	ARB : ENTITY WORK.arbiter
		PORT MAP(
			rst => rst,
			clk => clk, 
			req_0 => m_bus_req,
			gnt_0 => m_bus_gnt, 
			req_1 => m_bus_req_unused,
			gnt_1 => m_bus_gnt_unused );
			
	
END ARCHITECTURE behavioral;