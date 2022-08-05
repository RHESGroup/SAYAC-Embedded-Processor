LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY fulladder IS
    PORT (
        i0 : IN STD_LOGIC;
        i1 : IN STD_LOGIC;
        ci : IN STD_LOGIC;
        s : OUT STD_LOGIC;
        co : OUT STD_LOGIC);
END ENTITY fulladder;

ARCHITECTURE arch OF fulladder IS
    SIGNAL S0 : STD_LOGIC;
    SIGNAL S1 : STD_LOGIC;
    SIGNAL S2 : STD_LOGIC;
    SIGNAL S3 : STD_LOGIC;
    SIGNAL S4 : STD_LOGIC;
    SIGNAL S5 : STD_LOGIC;
    SIGNAL S6 : STD_LOGIC;
    SIGNAL S7 : STD_LOGIC;
    SIGNAL S8 : STD_LOGIC;
    SIGNAL S9 : STD_LOGIC;
    SIGNAL S10 : STD_LOGIC;
    SIGNAL S11 : STD_LOGIC;
    SIGNAL S12 : STD_LOGIC;
    SIGNAL S13 : STD_LOGIC;
    SIGNAL S14 : STD_LOGIC;
    SIGNAL S15 : STD_LOGIC;
    SIGNAL S16 : STD_LOGIC;

BEGIN
nor_n_0: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S12,
        in1(1) => S15,
        out1 => S11
    );
nand_n_1: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S10,
        in1(1) => S8,
        out1 => S0
    );
nand_n_2: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S12,
        in1(1) => S15,
        out1 => S1
    );
notg_3: ENTITY WORK.notg
    PORT MAP (
        in1 => S1,
        out1 => S2
    );
nor_n_4: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S2,
        in1(1) => S11,
        out1 => S3
    );
nand_n_5: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S1,
        in1(1) => S0,
        out1 => S4
    );
nand_n_6: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S4,
        in1(1) => S14,
        out1 => S5
    );
nand_n_7: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S3,
        in1(1) => S9,
        out1 => S6
    );
nand_n_8: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S6,
        in1(1) => S5,
        out1 => S16
    );
nand_n_9: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S0,
        in1(1) => S14,
        out1 => S7
    );
nand_n_10: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S7,
        in1(1) => S1,
        out1 => S13
    );
notg_11: ENTITY WORK.notg
    PORT MAP (
        in1 => S15,
        out1 => S8
    );
notg_12: ENTITY WORK.notg
    PORT MAP (
        in1 => S14,
        out1 => S9
    );
notg_13: ENTITY WORK.notg
    PORT MAP (
        in1 => S12,
        out1 => S10
    );
pin_14: ENTITY WORK.pin
    PORT MAP (
        in1 => ci,
        out1 => S12
    );
pout_15: ENTITY WORK.pout
    PORT MAP (
        in1 => S13,
        out1 => co
    );
pin_16: ENTITY WORK.pin
    PORT MAP (
        in1 => i0,
        out1 => S14
    );
pin_17: ENTITY WORK.pin
    PORT MAP (
        in1 => i1,
        out1 => S15
    );
pout_18: ENTITY WORK.pout
    PORT MAP (
        in1 => S16,
        out1 => s
    );

END ARCHITECTURE arch;
