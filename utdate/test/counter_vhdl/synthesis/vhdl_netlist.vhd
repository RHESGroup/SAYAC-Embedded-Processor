LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY counter_4bit IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        en : IN STD_LOGIC;
        co : OUT STD_LOGIC;
        counter : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END ENTITY counter_4bit;

ARCHITECTURE arch OF counter_4bit IS
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
    SIGNAL S17 : STD_LOGIC;
    SIGNAL S18 : STD_LOGIC;
    SIGNAL S19 : STD_LOGIC;
    SIGNAL S20 : STD_LOGIC;
    SIGNAL S21 : STD_LOGIC;
    SIGNAL S22 : STD_LOGIC;
    SIGNAL S23 : STD_LOGIC;
    SIGNAL S24 : STD_LOGIC;
    SIGNAL S25 : STD_LOGIC;
    SIGNAL new_counter_reg_0 : STD_LOGIC;
    SIGNAL new_counter_reg_1 : STD_LOGIC;
    SIGNAL new_counter_reg_2 : STD_LOGIC;
    SIGNAL new_counter_reg_3 : STD_LOGIC;

BEGIN
notg_0: ENTITY WORK.notg
    PORT MAP (
        in1 => new_counter_reg_0,
        out1 => S4
    );
notg_1: ENTITY WORK.notg
    PORT MAP (
        in1 => new_counter_reg_3,
        out1 => S5
    );
notg_2: ENTITY WORK.notg
    PORT MAP (
        in1 => S20,
        out1 => S6
    );
nand_n_3: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => new_counter_reg_1,
        in1(1) => new_counter_reg_0,
        out1 => S7
    );
nand_n_4: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => new_counter_reg_2,
        in1(1) => new_counter_reg_3,
        out1 => S8
    );
nor_n_5: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S8,
        in1(1) => S7,
        out1 => S19
    );
nor_n_6: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S6,
        in1(1) => S4,
        out1 => S9
    );
nor_n_7: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S20,
        in1(1) => new_counter_reg_0,
        out1 => S10
    );
nor_n_8: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S10,
        in1(1) => S9,
        out1 => S0
    );
nor_n_9: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S7,
        in1(1) => S6,
        out1 => S11
    );
nor_n_10: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S9,
        in1(1) => new_counter_reg_1,
        out1 => S12
    );
nor_n_11: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S12,
        in1(1) => S11,
        out1 => S1
    );
nand_n_12: ENTITY WORK.nand_n
    PORT MAP (
        in1(0) => S11,
        in1(1) => new_counter_reg_2,
        out1 => S13
    );
notg_13: ENTITY WORK.notg
    PORT MAP (
        in1 => S13,
        out1 => S14
    );
nor_n_14: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S11,
        in1(1) => new_counter_reg_2,
        out1 => S15
    );
nor_n_15: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S15,
        in1(1) => S14,
        out1 => S2
    );
nor_n_16: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S14,
        in1(1) => new_counter_reg_3,
        out1 => S16
    );
nor_n_17: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S13,
        in1(1) => S5,
        out1 => S17
    );
nor_n_18: ENTITY WORK.nor_n
    PORT MAP (
        in1(0) => S17,
        in1(1) => S16,
        out1 => S3
    );
dff_19: ENTITY WORK.dff
    PORT MAP (
        C => S18,
        CE => '1',
        CLR => S21,
        D => S0,
        NbarT => '0',
        PRE => '0',
        Q => new_counter_reg_0,
        Si => S22,
        global_reset => '0'
    );
dff_20: ENTITY WORK.dff
    PORT MAP (
        C => S18,
        CE => '1',
        CLR => S21,
        D => S1,
        NbarT => '0',
        PRE => '0',
        Q => new_counter_reg_1,
        Si => S23,
        global_reset => '0'
    );
dff_21: ENTITY WORK.dff
    PORT MAP (
        C => S18,
        CE => '1',
        CLR => S21,
        D => S2,
        NbarT => '0',
        PRE => '0',
        Q => new_counter_reg_2,
        Si => S24,
        global_reset => '0'
    );
dff_22: ENTITY WORK.dff
    PORT MAP (
        C => S18,
        CE => '1',
        CLR => S21,
        D => S3,
        NbarT => '0',
        PRE => '0',
        Q => new_counter_reg_3,
        Si => S25,
        global_reset => '0'
    );
pin_23: ENTITY WORK.pin
    PORT MAP (
        in1 => clk,
        out1 => S18
    );
pout_24: ENTITY WORK.pout
    PORT MAP (
        in1 => S19,
        out1 => co
    );
pout_25: ENTITY WORK.pout
    PORT MAP (
        in1 => new_counter_reg_0,
        out1 => counter(0)
    );
pout_26: ENTITY WORK.pout
    PORT MAP (
        in1 => new_counter_reg_1,
        out1 => counter(1)
    );
pout_27: ENTITY WORK.pout
    PORT MAP (
        in1 => new_counter_reg_2,
        out1 => counter(2)
    );
pout_28: ENTITY WORK.pout
    PORT MAP (
        in1 => new_counter_reg_3,
        out1 => counter(3)
    );
pin_29: ENTITY WORK.pin
    PORT MAP (
        in1 => en,
        out1 => S20
    );
pin_30: ENTITY WORK.pin
    PORT MAP (
        in1 => rst,
        out1 => S21
    );

END ARCHITECTURE arch;
