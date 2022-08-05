--*****************************************************************************/
--	Filename:		cpu_model_3_1.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		3.100
--	History:		-
--	Date:			21 July 2022
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
--	A cpu model (SAYAC)
--	dot product example
--*****************************************************************************/


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.STOP;

ENTITY cpu_model_3_1 IS
	GENERIC (
		DATA_WIDTH			: INTEGER := 16;
		ADR_WIDTH			: INTEGER := 16
		);
	PORT (
		rst           	    : IN  	STD_LOGIC;
		clk           	    : IN 	STD_LOGIC;
		address_bus		   	: OUT 	STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		data_bus	    	: INOUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);	  -- cpu read & write data
		ready				: IN  	STD_LOGIC;                                    -- memory ready
		rd                	: OUT	STD_LOGIC;                                    -- cpu read and write
		wr                	: OUT	STD_LOGIC
		);		
END ENTITY cpu_model_3_1;

ARCHITECTURE behavioral OF cpu_model_3_1 IS
	
	SIGNAL reg_0			: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL data				: STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL address			: STD_LOGIC_VECTOR (ADR_WIDTH  - 1 DOWNTO 0);
	SIGNAL rd_sig			: STD_LOGIC; 
	SIGNAL wr_sig			: STD_LOGIC; 
	
	-- WRITE_PROC(ADR, DAT, clk, address, data, ready, rd, wr)
	PROCEDURE WRITE_PROC
		(
		CONSTANT ADR		: IN	STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		CONSTANT DAT		: IN	STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
		SIGNAL clk			: IN 	STD_LOGIC;
		SIGNAL address		: OUT 	STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		SIGNAL data		    : OUT 	STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
		SIGNAL ready		: IN  	STD_LOGIC;
		SIGNAL rd           : OUT	STD_LOGIC;
		SIGNAL wr           : OUT	STD_LOGIC)
	IS	BEGIN
		WAIT UNTIL clk = '1' AND clk'EVENT;			-- @(posedge clk);
		rd <= '0'; 
		wr <= '1';
		address <= ADR;
		data <= DAT;
		WAIT UNTIL ready = '1' AND ready'EVENT;		-- @(posedge ready);
	END PROCEDURE WRITE_PROC;
	
	-- READ_PROC(ADR, DAT, clk, address, data_bus, ready, rd, wr)
	PROCEDURE READ_PROC
		(
		CONSTANT ADR		: IN	STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		SIGNAL DAT			: OUT	STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
		SIGNAL clk			: IN 	STD_LOGIC;
		SIGNAL address		: OUT 	STD_LOGIC_VECTOR (ADR_WIDTH - 1 DOWNTO 0);
		SIGNAL data_bus		    : IN 	STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
		SIGNAL ready		: IN  	STD_LOGIC;
		SIGNAL rd           : OUT	STD_LOGIC;
		SIGNAL wr           : OUT	STD_LOGIC)
	IS	BEGIN
		WAIT UNTIL clk = '1' AND clk'EVENT;			-- @(posedge clk);
		rd <= '1'; 
		wr <= '0';
		address <= ADR;
		WAIT UNTIL ready = '1' AND ready'EVENT;		-- @(posedge ready);
		WAIT FOR 1 ns;
		DAT <= data_bus;
	END PROCEDURE READ_PROC;
	
	-- NOP(clk, rd, wr)
	PROCEDURE NOP_PROC
		(
		SIGNAL clk			: IN 	STD_LOGIC;
		SIGNAL rd           : OUT	STD_LOGIC;
		SIGNAL wr           : OUT	STD_LOGIC)
	IS	BEGIN
		WAIT UNTIL clk = '1' AND clk'EVENT;			-- @(posedge clk);
		rd <= '0'; 
		wr <= '0';		
	END PROCEDURE NOP_PROC;
	
BEGIN
	
	data_bus	<= data		WHEN wr_sig = '1' ELSE (OTHERS=> 'Z');
	address_bus <= address	WHEN wr_sig = '1' OR rd_sig = '1' ELSE (OTHERS=> 'Z');
	
	rd <= rd_sig;
	wr <= wr_sig;
	
	PROCESS
    BEGIN
		rd_sig <= '0';
		wr_sig <= '0';
		
		WAIT UNTIL rst = '1' AND rst'EVENT;		-- @(posedge rst);
		WAIT UNTIL rst = '0' AND rst'EVENT;		-- @(negedge rst);
		
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(0, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(888, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(1, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(111, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(2, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(222, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(3, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(333, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(1024, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(1025, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(777, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(1025, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(1027, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(2047, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(2049, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(555, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(3072, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(4096, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(2048, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		WRITE_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(0, ADR_WIDTH)), STD_LOGIC_VECTOR(TO_UNSIGNED(444, DATA_WIDTH))
			, clk, address, data, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(5120, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(1024, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(7168, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		READ_PROC(STD_LOGIC_VECTOR(TO_UNSIGNED(9216, ADR_WIDTH)), reg_0
			, clk, address, data_bus, ready, rd_sig, wr_sig);
		--
		NOP_PROC(clk, rd_sig, wr_sig);
		NOP_PROC(clk, rd_sig, wr_sig);
		NOP_PROC(clk, rd_sig, wr_sig);
		NOP_PROC(clk, rd_sig, wr_sig);
		
		STOP;
		
    END PROCESS;

END ARCHITECTURE behavioral;