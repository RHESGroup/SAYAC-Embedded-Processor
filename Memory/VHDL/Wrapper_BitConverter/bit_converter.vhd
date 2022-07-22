--*****************************************************************************/
--	Filename:		bit_converter.vhd
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
--	bit_converter: convert DATA_WIDTH & ADR_WIDTH between a pir of {master, slave}
--	it transfer data between maaster and slave with different width
--*****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bit_converter IS
	GENERIC (
		SLAVE_DATA_WIDTH	: INTEGER := 16;
		MASTER_DATA_WIDTH	: INTEGER := 64; -- assert: MASTER_DATA_WIDTH = K *  SLAVE_DATA_WIDTH, K is an integer
		SLAVE_ADR_WIDTH		: INTEGER := 16;
		MASTER_ADR_WIDTH	: INTEGER := 14;
		TRANS_COUNT			: INTEGER := 4;	 -- MASTER_DATA_WIDTH / SLAVE_DATA_WIDTH;
		COUNTER_WIDTH		: INTEGER := 2 	 -- SLAVE_ADR_WIDTH - MASTER_ADR_WIDTH;
	);
	PORT (
		-- system
		rst           	    : IN  STD_LOGIC;
		clk           	    : IN  STD_LOGIC;
		-- in or out refer to the device (master or slave)
		-- Master interface
		m_address			: IN  STD_LOGIC_VECTOR (MASTER_ADR_WIDTH - 1 DOWNTO 0);   -- master	-> converter
		m_dataout	    	: IN  STD_LOGIC_VECTOR (MASTER_DATA_WIDTH - 1 DOWNTO 0);  -- master  	-> converter
		m_datain	    	: OUT STD_LOGIC_VECTOR (MASTER_DATA_WIDTH - 1 DOWNTO 0);  -- converter-> master
		m_ready				: OUT STD_LOGIC;                                          -- converter-> master
		m_rd				: IN  STD_LOGIC;                                          -- master  	-> converter
		m_wr				: IN  STD_LOGIC;                                          -- master  	-> converter
		-- Slave interface                                                            
		s_address			: OUT STD_LOGIC_VECTOR (SLAVE_ADR_WIDTH - 1 DOWNTO 0);    -- converter-> slave
		s_datain	    	: OUT STD_LOGIC_VECTOR (SLAVE_DATA_WIDTH - 1 DOWNTO 0);   -- converter-> slave
		s_dataout	    	: IN  STD_LOGIC_VECTOR (SLAVE_DATA_WIDTH - 1 DOWNTO 0);   -- slave  	-> converter
		s_ready				: IN  STD_LOGIC;                                          -- slave  	-> converter
		s_wr				: OUT STD_LOGIC;                                          -- converter-> slave
		s_rd				: OUT STD_LOGIC                                         -- converter-> slave
	);		
END ENTITY bit_converter;

ARCHITECTURE behavioral OF bit_converter IS

	TYPE buf_mem IS ARRAY (0 TO TRANS_COUNT-1) of std_logic_vector(SLAVE_DATA_WIDTH -1 DOWNTO 0);
	TYPE state IS (
		IDLE,
		WRITE_0,
		WRITE_LOOP,
		WRITE_WAIT_SLAVE,
		WRITE_DONE,
		READ_LOOP,
		READ_WAIT_SLAVE,
		READ_DONE
	);
	
	SIGNAL buf_reg		: buf_mem;
	SIGNAL buf_datain	: buf_mem;
	SIGNAL ld_buf		: STD_LOGIC_VECTOR (0 TO TRANS_COUNT - 1);
	SIGNAL adr_reg		: STD_LOGIC_VECTOR (MASTER_ADR_WIDTH - 1 DOWNTO 0);
	
	SIGNAL p_state, n_state : state;
	
	SIGNAL count		: STD_LOGIC_VECTOR (COUNTER_WIDTH - 1 DOWNTO 0);
	SIGNAL inc			: STD_LOGIC;
	SIGNAL co			: STD_LOGIC;
	SIGNAL dcd			: STD_LOGIC_VECTOR (TRANS_COUNT - 1 DOWNTO 0);
	SIGNAL ld_all		: STD_LOGIC;
	SIGNAL ld_adr		: STD_LOGIC;
	SIGNAL d_on_master	: STD_LOGIC;
	
	FUNCTION and_reduce( V: STD_LOGIC_VECTOR ) RETURN STD_LOGIC is
      VARIABLE result: STD_LOGIC;
    BEGIN
      FOR i IN V'RANGE LOOP
        IF i = V'LEFT THEN
          result := V(i);
        ELSE
          result := result AND V(i);
        END IF;
        EXIT WHEN result = '0';
      END LOOP;
      RETURN result;
    END and_reduce;
	
BEGIN

	-- datapath-----------------------------------------------------
	
	m_datain <= buf_reg(3) & buf_reg(2) & buf_reg(1) & buf_reg(0) WHEN d_on_master = '1' ELSE (OTHERS=>'Z');
			
	BUF_FOR: for i in 0 to TRANS_COUNT-1 generate
		
		PROCESS (clk) BEGIN
			IF (clk = '1' AND clk'EVENT) THEN
				IF rst = '1' THEN
					buf_reg(i) <= (OTHERS=>'0');
				ELSIF ld_buf(i) = '1' THEN
					buf_reg(i) <= buf_datain(i);	-- m_dataout[((i+1)*SLAVE_DATA_WIDTH)-1:i*SLAVE_DATA_WIDTH];
				END IF;
			END IF;
		END PROCESS;
	
	buf_datain(i) <= m_dataout(((i+1)*SLAVE_DATA_WIDTH)-1 DOWNTO i*SLAVE_DATA_WIDTH) WHEN ld_all = '1' ELSE s_dataout;	-- write
	
	ld_buf(i) <= ld_all OR (dcd(i) AND s_ready AND m_rd);	-- s_ready && m_rd (instead of ld)
	
	end generate BUF_FOR;
	
	-- counter
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				count <= (OTHERS=>'0');
			ELSIF inc = '1' THEN
				count <= count + "01";
			END IF;
		END IF;
	END PROCESS;
	co <= and_reduce(count);
	
	-- decoder
	dcd <= 	"0001" WHEN count = "00" ELSE
			"0010" WHEN count = "01" ELSE
			"0100" WHEN count = "10" ELSE
			"1000";
			
	-- slave datain
	s_datain <= buf_reg(0) WHEN count = "00" ELSE
				buf_reg(1) WHEN count = "01" ELSE
				buf_reg(2) WHEN count = "10" ELSE
				buf_reg(3);
	
	-- adr_reg
	PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN
				adr_reg <= (OTHERS=>'0');
			ELSIF ld_adr = '1' THEN
				adr_reg <= m_address;
			END IF;
		END IF;
	END PROCESS;
	
	s_address <= adr_reg & count;
	
	-- controller--------------------------------------------------
	
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
	PROCESS(p_state, m_rd, m_wr, co, s_ready) BEGIN
		n_state <= IDLE;
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				IF m_wr = '1' THEN 
					n_state <= WRITE_0;
				ELSIF m_rd = '1' THEN
					n_state <= READ_WAIT_SLAVE; 
				ELSE
					n_state <= IDLE; 
				END IF; 
				
			WHEN WRITE_0 => -- 1
				n_state <= WRITE_WAIT_SLAVE; 
				
			WHEN WRITE_WAIT_SLAVE => -- 2
				IF s_ready = '1' THEN
					n_state <= WRITE_LOOP; 
				ELSE
					n_state <= WRITE_WAIT_SLAVE; 
				END IF;
			
			WHEN WRITE_LOOP => -- 3
				IF co = '1' THEN
					n_state <= WRITE_DONE; 
				ELSE
					n_state <= WRITE_WAIT_SLAVE; 
				END IF;
			
			WHEN WRITE_DONE => -- 4
				n_state <= IDLE; 
			
			WHEN READ_WAIT_SLAVE => -- 5
				IF s_ready = '1' THEN
					n_state <= READ_LOOP; 
				ELSE
					n_state <= READ_WAIT_SLAVE; 
				END IF;
			
			WHEN READ_LOOP => -- 6
				IF co = '1' THEN
					n_state <= READ_DONE; 
				ELSE
					n_state <= READ_WAIT_SLAVE; 
				END IF;
			
			WHEN READ_DONE => -- 7
				n_state <= IDLE; 
			
			WHEN OTHERS => 
				n_state <= IDLE; 
		END CASE; 
	END PROCESS;
	
	-- Combinational Part, outputs
	PROCESS(p_state) BEGIN
		inc <= '0';
		m_ready <= '0';
		ld_adr <= '0';
		ld_all <= '0';
		s_wr <= '0';
		s_rd <= '0';
		d_on_master <= '0';
		
		CASE p_state IS 
			WHEN IDLE => -- 0
				ld_adr <= '1';				
				
			WHEN WRITE_0 => -- 1
				ld_all <= '1'; 
				
			WHEN WRITE_LOOP => -- 2
				inc <= '1'; 
			
			WHEN WRITE_WAIT_SLAVE => -- 3
				s_wr <= '1'; 
				
			WHEN WRITE_DONE => -- 4
				m_ready <= '1'; 
			
			WHEN READ_LOOP => -- 5
				inc <= '1'; 
			
			WHEN READ_WAIT_SLAVE => -- 6
				s_rd <= '1'; 
				
			WHEN READ_DONE => -- 7
				m_ready <= '1';
				d_on_master <= '1';				
			
			WHEN OTHERS => 
				inc <= '0';
				m_ready <= '0';
				ld_adr <= '0';
				ld_all <= '0';
				s_wr <= '0';
				s_rd <= '0';
				d_on_master <= '0';
		END CASE; 
	END PROCESS;
	
END ARCHITECTURE behavioral;