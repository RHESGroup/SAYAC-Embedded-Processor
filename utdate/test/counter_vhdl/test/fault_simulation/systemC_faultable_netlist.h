#include <systemc.h>
#include "component_flt_lib.h"

using namespace sc_core;

SC_MODULE( counter_4bit ) {

    sc_in<sc_logic> clk;
    sc_in<sc_logic> rst;
    sc_in<sc_logic> en;
    sc_out<sc_logic> co;
    sc_out<sc_logic> counter[4];
    sc_in<sc_logic> global_reset;
    sc_in<sc_logic> NbarT;
    sc_in<sc_logic> Si;
    sc_out<sc_logic> So;

    sc_signal<sc_logic> sc_logic_1_signal;
    sc_signal<sc_logic> sc_logic_0_signal;

    sc_signal<sc_logic> S0;
    sc_signal<sc_logic> S1;
    sc_signal<sc_logic> S2;
    sc_signal<sc_logic> S3;
    sc_signal<sc_logic> S4;
    sc_signal<sc_logic> S5;
    sc_signal<sc_logic> S6;
    sc_signal<sc_logic> S7;
    sc_signal<sc_logic> S8;
    sc_signal<sc_logic> S9;
    sc_signal<sc_logic> S10;
    sc_signal<sc_logic> S11;
    sc_signal<sc_logic> S12;
    sc_signal<sc_logic> S13;
    sc_signal<sc_logic> S14;
    sc_signal<sc_logic> S15;
    sc_signal<sc_logic> S16;
    sc_signal<sc_logic> S17;
    sc_signal<sc_logic> S18;
    sc_signal<sc_logic> S19;
    sc_signal<sc_logic> S20;
    sc_signal<sc_logic> S21;
    sc_signal<sc_logic> S22;
    sc_signal<sc_logic> S23;
    sc_signal<sc_logic> S24;
    sc_signal<sc_logic> S25;
    sc_signal<sc_logic> new_counter_reg_0;
    sc_signal<sc_logic> new_counter_reg_1;
    sc_signal<sc_logic> new_counter_reg_2;
    sc_signal<sc_logic> new_counter_reg_3;
    sc_signal<sc_logic> global_reset_sig;
    sc_signal<sc_logic> NbarT_sig;
    sc_signal<sc_logic> Si_sig;
    sc_signal<sc_logic> So_sig;

    notg_flt* notg_0;
    notg_flt* notg_1;
    notg_flt* notg_2;
    nand_n_flt* nand_n_3;
    nand_n_flt* nand_n_4;
    nor_n_flt* nor_n_5;
    nor_n_flt* nor_n_6;
    nor_n_flt* nor_n_7;
    nor_n_flt* nor_n_8;
    nor_n_flt* nor_n_9;
    nor_n_flt* nor_n_10;
    nor_n_flt* nor_n_11;
    nand_n_flt* nand_n_12;
    notg_flt* notg_13;
    nor_n_flt* nor_n_14;
    nor_n_flt* nor_n_15;
    nor_n_flt* nor_n_16;
    nor_n_flt* nor_n_17;
    nor_n_flt* nor_n_18;
    dff_flt* dff_19;
    dff_flt* dff_20;
    dff_flt* dff_21;
    dff_flt* dff_22;
    pin_flt* pin_23;
    pout_flt* pout_24;
    pout_flt* pout_25;
    pout_flt* pout_26;
    pout_flt* pout_27;
    pout_flt* pout_28;
    pin_flt* pin_29;
    pin_flt* pin_30;
    pout_flt* pout_31;
    pin_flt* pin_32;
    pin_flt* pin_33;
    pin_flt* pin_34;

SC_HAS_PROCESS(counter_4bit);
    counter_4bit(sc_module_name _name, faultRegistry* accessRegistry){
    notg_0 = new notg_flt("notg_0", accessRegistry);
        notg_0->in1(new_counter_reg_0);
        notg_0->out1(S4);

    notg_1 = new notg_flt("notg_1", accessRegistry);
        notg_1->in1(new_counter_reg_3);
        notg_1->out1(S5);

    notg_2 = new notg_flt("notg_2", accessRegistry);
        notg_2->in1(S20);
        notg_2->out1(S6);

    nand_n_3 = new nand_n_flt("nand_n_3", accessRegistry);
        nand_n_3->in1[0](new_counter_reg_1);
        nand_n_3->in1[1](new_counter_reg_0);
        nand_n_3->out1(S7);

    nand_n_4 = new nand_n_flt("nand_n_4", accessRegistry);
        nand_n_4->in1[0](new_counter_reg_2);
        nand_n_4->in1[1](new_counter_reg_3);
        nand_n_4->out1(S8);

    nor_n_5 = new nor_n_flt("nor_n_5", accessRegistry);
        nor_n_5->in1[0](S8);
        nor_n_5->in1[1](S7);
        nor_n_5->out1(S19);

    nor_n_6 = new nor_n_flt("nor_n_6", accessRegistry);
        nor_n_6->in1[0](S6);
        nor_n_6->in1[1](S4);
        nor_n_6->out1(S9);

    nor_n_7 = new nor_n_flt("nor_n_7", accessRegistry);
        nor_n_7->in1[0](S20);
        nor_n_7->in1[1](new_counter_reg_0);
        nor_n_7->out1(S10);

    nor_n_8 = new nor_n_flt("nor_n_8", accessRegistry);
        nor_n_8->in1[0](S10);
        nor_n_8->in1[1](S9);
        nor_n_8->out1(S0);

    nor_n_9 = new nor_n_flt("nor_n_9", accessRegistry);
        nor_n_9->in1[0](S7);
        nor_n_9->in1[1](S6);
        nor_n_9->out1(S11);

    nor_n_10 = new nor_n_flt("nor_n_10", accessRegistry);
        nor_n_10->in1[0](S9);
        nor_n_10->in1[1](new_counter_reg_1);
        nor_n_10->out1(S12);

    nor_n_11 = new nor_n_flt("nor_n_11", accessRegistry);
        nor_n_11->in1[0](S12);
        nor_n_11->in1[1](S11);
        nor_n_11->out1(S1);

    nand_n_12 = new nand_n_flt("nand_n_12", accessRegistry);
        nand_n_12->in1[0](S11);
        nand_n_12->in1[1](new_counter_reg_2);
        nand_n_12->out1(S13);

    notg_13 = new notg_flt("notg_13", accessRegistry);
        notg_13->in1(S13);
        notg_13->out1(S14);

    nor_n_14 = new nor_n_flt("nor_n_14", accessRegistry);
        nor_n_14->in1[0](S11);
        nor_n_14->in1[1](new_counter_reg_2);
        nor_n_14->out1(S15);

    nor_n_15 = new nor_n_flt("nor_n_15", accessRegistry);
        nor_n_15->in1[0](S15);
        nor_n_15->in1[1](S14);
        nor_n_15->out1(S2);

    nor_n_16 = new nor_n_flt("nor_n_16", accessRegistry);
        nor_n_16->in1[0](S14);
        nor_n_16->in1[1](new_counter_reg_3);
        nor_n_16->out1(S16);

    nor_n_17 = new nor_n_flt("nor_n_17", accessRegistry);
        nor_n_17->in1[0](S13);
        nor_n_17->in1[1](S5);
        nor_n_17->out1(S17);

    nor_n_18 = new nor_n_flt("nor_n_18", accessRegistry);
        nor_n_18->in1[0](S17);
        nor_n_18->in1[1](S16);
        nor_n_18->out1(S3);

    dff_19 = new dff_flt("dff_19", accessRegistry);
        dff_19->C(S18);
        dff_19->CE(sc_logic_1_signal);
        dff_19->CLR(S21);
        dff_19->D(S0);
        dff_19->NbarT(NbarT_sig);
        dff_19->PRE(sc_logic_0_signal);
        dff_19->Q(new_counter_reg_0);
        dff_19->Si(Si_sig);
        dff_19->global_reset(global_reset_sig);

    dff_20 = new dff_flt("dff_20", accessRegistry);
        dff_20->C(S18);
        dff_20->CE(sc_logic_1_signal);
        dff_20->CLR(S21);
        dff_20->D(S1);
        dff_20->NbarT(NbarT_sig);
        dff_20->PRE(sc_logic_0_signal);
        dff_20->Q(new_counter_reg_1);
        dff_20->Si(new_counter_reg_0);
        dff_20->global_reset(global_reset_sig);

    dff_21 = new dff_flt("dff_21", accessRegistry);
        dff_21->C(S18);
        dff_21->CE(sc_logic_1_signal);
        dff_21->CLR(S21);
        dff_21->D(S2);
        dff_21->NbarT(NbarT_sig);
        dff_21->PRE(sc_logic_0_signal);
        dff_21->Q(new_counter_reg_2);
        dff_21->Si(new_counter_reg_1);
        dff_21->global_reset(global_reset_sig);

    dff_22 = new dff_flt("dff_22", accessRegistry);
        dff_22->C(S18);
        dff_22->CE(sc_logic_1_signal);
        dff_22->CLR(S21);
        dff_22->D(S3);
        dff_22->NbarT(NbarT_sig);
        dff_22->PRE(sc_logic_0_signal);
        dff_22->Q(new_counter_reg_3);
        dff_22->Si(new_counter_reg_2);
        dff_22->global_reset(global_reset_sig);

    pin_23 = new pin_flt("pin_23", accessRegistry);
        pin_23->in1(clk);
        pin_23->out1(S18);

    pout_24 = new pout_flt("pout_24", accessRegistry);
        pout_24->in1(S19);
        pout_24->out1(co);

    pout_25 = new pout_flt("pout_25", accessRegistry);
        pout_25->in1(new_counter_reg_0);
        pout_25->out1(counter[0]);

    pout_26 = new pout_flt("pout_26", accessRegistry);
        pout_26->in1(new_counter_reg_1);
        pout_26->out1(counter[1]);

    pout_27 = new pout_flt("pout_27", accessRegistry);
        pout_27->in1(new_counter_reg_2);
        pout_27->out1(counter[2]);

    pout_28 = new pout_flt("pout_28", accessRegistry);
        pout_28->in1(new_counter_reg_3);
        pout_28->out1(counter[3]);

    pin_29 = new pin_flt("pin_29", accessRegistry);
        pin_29->in1(en);
        pin_29->out1(S20);

    pin_30 = new pin_flt("pin_30", accessRegistry);
        pin_30->in1(rst);
        pin_30->out1(S21);

    pout_31 = new pout_flt("pout_31", accessRegistry);
        pout_31->in1(So_sig);
        pout_31->out1(So);
    pin_32 = new pin_flt("pin_32", accessRegistry);
        pin_32->in1(global_reset);
        pin_32->out1(global_reset_sig);
    pin_33 = new pin_flt("pin_33", accessRegistry);
        pin_33->in1(NbarT);
        pin_33->out1(NbarT_sig);
    pin_34 = new pin_flt("pin_34", accessRegistry);
        pin_34->in1(Si);
        pin_34->out1(Si_sig);

    SC_METHOD(sc_logic_signal_assignment);

    SC_METHOD(So_assignment);
        sensitive << new_counter_reg_3;

    }

    void sc_logic_signal_assignment(void){ 
        sc_logic_1_signal.write(SC_LOGIC_1);
        sc_logic_0_signal.write(SC_LOGIC_0);
    }

    void So_assignment(void){
        So_sig.write(new_counter_reg_3.read());
    }
};
