--*****************************************************************************/
--	Filename:		controller_wb.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		1.000
--	History:		-
--	Date:			20 July 2022
--	Authors:	 	Alireza, Sepideh
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
--	set associative cache controller
--	Write-Back (Write-Allocate Policy): 
--		if Miss ->
--			read block from mem (hope of Hit in future)
--			write to cache and dirty_wr (from CPU)
--		if Hit -> 
--			write to cache and dirty_wr (from CPU)
--		----------------------------------------------------
--		if read block from mem to cache (READ_MISS, WRITE_MISS) ->
--			if valid & dirty ->
--				write block to mem (from cache)
--	moore controller: (output signals only depend on current state)
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY controller_wb IS
	PORT (
		-- system
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- datapath interface
		Hit					: IN  STD_LOGIC;	-- CM output, [from datapath]
		valid				: IN  STD_LOGIC;	-- CM output, [from datapath]
		dirty_wr			: OUT STD_LOGIC;	-- CM input,  [to datapath]
		dirty				: IN  STD_LOGIC;	-- CM output, [from datapath]
		sel_all        	    : OUT STD_LOGIC;	-- CM inputs, [to datapath]
		rd                	: OUT STD_LOGIC;	-- CM inputs, [to datapath]
		wr                	: OUT STD_LOGIC;	-- CM inputs, [to datapath]
		d_on_cpu			: OUT STD_LOGIC;	-- tri-state select, data or address on buss or not [to datapath]
		d_on_mem			: OUT STD_LOGIC;	-- tri-state select, data or address on buss or not [to datapath]
		adr_on_mem			: OUT STD_LOGIC;	-- tri-state select, data or address on buss or not [to datapath]
		drt_adr_on_mem		: OUT STD_LOGIC;	-- tri-state select, dirty address on memory address buss [to datapath]
		update             	: OUT STD_LOGIC;	-- to datapath (For replacement block when Miss accurs)
		en_replacement		: OUT STD_LOGIC;	-- to replacement policy module
		-- CPU interface
		c_rd			   	: IN  STD_LOGIC;	-- cache read and write, [cpu interface]
		c_wr			   	: IN  STD_LOGIC;	-- cache read and write, [cpu interface]
		c_ready		    	: OUT STD_LOGIC;	-- cache ready, [cpu interface]
		-- memory interface
		m_ready				: IN  STD_LOGIC;	-- memory ready, [mem interface]
		m_rd				: OUT STD_LOGIC;	-- memory read and write, [mem interface]
		m_wr				: OUT STD_LOGIC		-- memory read and write, [mem interface]
	);		
END ENTITY controller_wb;

ARCHITECTURE behavioral OF controller_wb IS
	
	TYPE state IS (
		IDLE, -- 0
		READ_HIT, -- 1
		READ_MISS_DIRTY_WRITETOMEM, -- 2
		READ_MISS_WAIT, -- 3
		READ_MISS_DONE, -- 4
		READ_MISS, -- 5
		WRITE_HIT, -- 6
		WRITE_MISS_DIRTY_WRITETOMEM, -- 7
		WRITE_MISS_ALLOCATE_WAIT, -- 8
		WRITE_MISS_ALLOCATE_DONE, -- 9
		WRITE_MISS -- 10
	);
	
	SIGNAL p_state, n_state : state;
	
BEGIN
			
	en_replacement <= c_rd OR c_wr;

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
	PROCESS(p_state, c_rd, c_wr, m_ready, Hit, valid, dirty) BEGIN
		n_state <= IDLE;
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				IF c_rd = '1' AND Hit = '1' THEN 
					n_state <= READ_HIT;
				ELSIF c_rd = '1' AND Hit = '0' AND (valid = '1' AND dirty = '1') THEN
					n_state <= READ_MISS_DIRTY_WRITETOMEM; 
				ELSIF c_rd = '1' AND Hit = '0' AND NOT(valid = '1' AND dirty = '1') THEN
					n_state <= READ_MISS_WAIT; 
				ELSIF c_wr = '1' AND Hit = '1' THEN
					n_state <= WRITE_HIT; 
				ELSIF c_wr = '1' AND Hit = '0' AND (valid = '1' AND dirty = '1') THEN
					n_state <= WRITE_MISS_DIRTY_WRITETOMEM;
				ELSIF c_wr = '1' AND Hit = '0' AND NOT(valid = '1' AND dirty = '1') THEN
					n_state <= WRITE_MISS_ALLOCATE_WAIT; 
				ELSE
					n_state <= IDLE; 
				END IF; 
				
			WHEN READ_HIT => -- 1
				n_state <= IDLE;
				
			WHEN READ_MISS_DIRTY_WRITETOMEM => -- 2
				IF m_ready = '1' THEN
					n_state <= READ_MISS_WAIT; 
				ELSE
					n_state <= READ_MISS_DIRTY_WRITETOMEM; 
				END IF;
			
			WHEN READ_MISS_WAIT => -- 3
				IF m_ready = '1' THEN
					n_state <= READ_MISS_DONE; 
				ELSE
					n_state <= READ_MISS_WAIT; 
				END IF;
				
			WHEN READ_MISS_DONE => -- 4
				n_state <= READ_MISS;
				
			WHEN READ_MISS => -- 5
				n_state <= IDLE;
				
			WHEN WRITE_HIT => -- 6
				n_state <= IDLE;
				
			WHEN WRITE_MISS_DIRTY_WRITETOMEM => -- 7
				IF m_ready = '1' THEN
					n_state <= WRITE_MISS_ALLOCATE_WAIT; 
				ELSE
					n_state <= WRITE_MISS_DIRTY_WRITETOMEM;
				END IF;
				
			WHEN WRITE_MISS_ALLOCATE_WAIT => -- 8
				IF m_ready = '1' THEN
					n_state <= WRITE_MISS_ALLOCATE_DONE; 
				ELSE
					n_state <= WRITE_MISS_ALLOCATE_WAIT;
				END IF;
			
			WHEN WRITE_MISS_ALLOCATE_DONE => -- 9
				n_state <= WRITE_MISS; 
			
			WHEN WRITE_MISS => -- 10
				n_state <= IDLE; 
				
			WHEN OTHERS => 
				n_state <= IDLE; 
		END CASE; 
	END PROCESS;
	
	-- Combinational Part, outputs
	PROCESS(p_state) BEGIN
		c_ready <= '0';
		sel_all <= '0';
		rd <= '0';
		wr <= '0';
		dirty_wr <= '0';
		m_rd <= '0';
		m_wr <= '0';
		d_on_cpu <= '0';
		d_on_mem <= '0';
		adr_on_mem <= '0';
		drt_adr_on_mem <= '0';
		update <= '0';
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				rd <= '1'; 
				
			WHEN READ_HIT => -- 1
				rd <= '1'; 
				d_on_cpu <= '1'; 
				c_ready <= '1'; 
				update <= '1'; 
				
			WHEN READ_MISS_DIRTY_WRITETOMEM => -- 2
				m_wr <= '1'; 
				drt_adr_on_mem <= '1'; 
				d_on_mem <= '1'; 
				rd <= '1'; 
				sel_all <= '1';
			
			WHEN READ_MISS_WAIT => -- 3
				m_rd <= '1'; 
				adr_on_mem <= '1'; 
				
			WHEN READ_MISS_DONE => -- 4
				sel_all <= '1'; 
				wr <= '1'; 
				update <= '1';
				
			WHEN READ_MISS => -- 5
				rd <= '1'; 
				d_on_cpu <= '1'; 
				c_ready <= '1';
				
			WHEN WRITE_HIT => -- 6
				wr <= '1'; 
				rd <= '1'; 
				dirty_wr <= '1'; 
				c_ready <= '1'; 
				update <= '1';
				
			WHEN WRITE_MISS_DIRTY_WRITETOMEM => -- 7
				m_wr <= '1'; 
				drt_adr_on_mem <= '1'; 
				d_on_mem <= '1'; 
				rd <= '1'; 
				sel_all <= '1';
				
			WHEN WRITE_MISS_ALLOCATE_WAIT => -- 8
				m_rd <= '1'; 
				adr_on_mem <= '1'; 
			
			WHEN WRITE_MISS_ALLOCATE_DONE => -- 9
				sel_all <= '1'; 
				wr <= '1'; 
				update <= '1';
			
			WHEN WRITE_MISS => -- 10
				wr <= '1'; 
				rd <= '1'; 
				dirty_wr <= '1'; 
				c_ready <= '1'; 
				
			WHEN OTHERS => 
				c_ready <= '0';
				sel_all <= '0';
				rd <= '0';
				wr <= '0';
				dirty_wr <= '0';
				m_rd <= '0';
				m_wr <= '0';
				d_on_cpu <= '0';
				d_on_mem <= '0';
				adr_on_mem <= '0';
				drt_adr_on_mem <= '0';
				update <= '0';
		END CASE; 
	END PROCESS;
	
END ARCHITECTURE behavioral;