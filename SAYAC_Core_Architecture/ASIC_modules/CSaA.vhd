--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CSaA_block	IS
	GENERIC	(	n		:	INTEGER	:=	32	);
	PORT	(	x 		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				y 		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				cin		:	IN	STD_LOGIC;
				sum		:	OUT	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				cout	:	OUT	STD_LOGIC	);
END	ENTITY	CSaA_block;

ARCHITECTURE	FUNC	OF	CSaA_block	IS
	SIGNAL	so  :	STD_LOGIC_VECTOR(n-1	DOWNTO	1	);
	SIGNAL	co1	:	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
	SIGNAL	co2	:	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
	SIGNAL	c	:	STD_LOGIC;
BEGIN
	co2(0)	<=	'0';
	
	bit0_1:	ENTITY	WORK.FA 
				PORT	MAP	(	x(0), 
								y(0), 
								cin, 
								sum(0), 
								co1(0)	);
			
	L1:	FOR	I	IN	1	TO	n-1	GENERATE
		bitI_1:	ENTITY	WORK.FA 
					PORT	MAP(	x(I), 
									y(I), 
									'0', 
									so(I), 
									co1(I)	);
	END	GENERATE L1;
	----------------------------------------------------------------------
	L2:	FOR	I	IN	0	TO	n-2	GENERATE
		bitI_2	:	ENTITY	WORK.FA 
						PORT	MAP(	so(I+1), 
										co1(I), 
										co2(I), 
										sum(I+1), 
										co2(I+1)	);
	END	GENERATE L2;
	----------------------------------------------------------------------
	last:	ENTITY	WORK.FA 
				PORT	MAP(	'0', 
								co1(n-1), 
								co2(n-1), 
								cout, 
								c	);

END	ARCHITECTURE	FUNC;
--------------------------------------------------------------------------------------------------- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY	CSaA	IS
	GENERIC	(	n		:	INTEGER	:=	32;
				m		:	INTEGER	:=	4		);
	PORT	(	x 		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				y 		:	IN	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				cin		:	IN	STD_LOGIC;
				sum		:	OUT	STD_LOGIC_VECTOR(n-1	DOWNTO	0);
				cout	:	OUT	STD_LOGIC 
		);
END	CSaA;	 

ARCHITECTURE	behavioral	OF	CSaA	IS
	SIGNAL	c	:	STD_LOGIC_VECTOR(n/m-1	DOWNTO	0);
BEGIN
	checkm_4:	IF	m = 4	GENERATE
		first_0_4:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	4	)
						PORT	MAP	(	x(m-1	DOWNTO	0), 
										y(m-1	DOWNTO	0), 
										cin, 
										sum(m-1	DOWNTO	0), 
										c(0)	);
		
		rest_4:	FOR	I	IN	1	TO	n/m-1	GENERATE
			rest_I_4:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	4	)
							PORT	MAP	(	x(m*(I+1)-1	DOWNTO	m*I), 
											y(m*(I+1)-1	DOWNTO	m*I), 
											c(I-1), 
											sum(m*(I+1)-1	DOWNTO	m*I), 
											c(I)	);
		END	GENERATE;
	END	GENERATE;
	
	checkm_8:	IF	m = 8	GENERATE
		first_0_8:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	8	)
						PORT	MAP	(	x(m-1	DOWNTO	0), 
										y(m-1	DOWNTO	0), 
										cin, 
										sum(m-1	DOWNTO	0), 
										c(0)	);
		
		rest_8:	FOR	I	IN	1	TO	n/m-1	GENERATE
			rest_I_8:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	8	)
							PORT	MAP	(	x(m*(I+1)-1	DOWNTO	m*I), 
											y(m*(I+1)-1	DOWNTO	m*I), 
											c(I-1), 
											sum(m*(I+1)-1	DOWNTO	m*I), 
											c(I)	);
		END	GENERATE;
	END	GENERATE;
	
	checkm_16:	IF	m = 16	GENERATE
		first_0_16:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	16	)
						PORT	MAP	(	x(m-1	DOWNTO	0),
										y(m-1	DOWNTO	0), 
										cin, 
										sum(m-1	DOWNTO	0), 
										c(0)	);
		
		rest_16:	FOR	I	IN	1	TO	n/m-1	GENERATE
			rest_I_16:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	16	)
							PORT	MAP	(	x(m*(I+1)-1	DOWNTO	m*I), 
											y(m*(I+1)-1	DOWNTO	m*I), 
											c(I-1), 
											sum(m*(I+1)-1	DOWNTO	m*I), 
											c(I)	);
		END	GENERATE;
	END	GENERATE;
	
	checkm_32:	IF	m = 32	GENERATE
		whole:	ENTITY WORK.CSaA_block	GENERIC	MAP	(	32	)
					PORT	MAP	(	x, 
									y, 
									cin, 
									sum, 
									c(0)	);
	END	GENERATE;
	
	cout	<=	c(n/m-1	);
END	behavioral;	 
------------------------------------------------------------------------------------------------
