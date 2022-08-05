#include "systemc.h"
//Verilog Library for Test Applications
//CAD Research Group
//School of ECE, University of Tehran

// TODO: parametrize gates

#ifndef __GATES_H__
#define __GATES_H__

/////////////////////////////////////////////////////////////////////////////////////
//    Buf
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(bufg){

    sc_in< sc_logic> in1; 
    sc_out< sc_logic> out1;

    SC_CTOR(bufg){

        SC_METHOD(eval);
        sensitive << in1;

    }

    void eval(void){
        out1->write(in1->read());
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Not
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(notg){

    sc_in< sc_logic > in1; 
    sc_out< sc_logic > out1;

    SC_CTOR(notg){

        SC_METHOD(eval);
        sensitive << in1;

    }

    void eval(void){
        if (in1->read() == SC_LOGIC_1){
            out1->write(SC_LOGIC_0);
        } else if (in1->read() == SC_LOGIC_0){
            out1->write(SC_LOGIC_1);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    And
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(and_n){

    sc_in< sc_logic> in1[2]; 
    sc_out< sc_logic> out1;

    SC_CTOR(and_n){

        SC_METHOD(eval);
        sensitive << in1[0] << in1[1];

    }

    void eval(void){
        if ((in1[0]->read() == SC_LOGIC_0) || (in1[1]->read() == SC_LOGIC_0)){
            out1->write(SC_LOGIC_0);
        } else {
            out1->write(SC_LOGIC_1);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Or
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(or_n){

    sc_in< sc_logic> in1[2]; 
    sc_out< sc_logic> out1;

    SC_CTOR(or_n){

        SC_METHOD(eval);
        sensitive << in1[0] << in1[1];

    }

    void eval(void){
        if ((in1[0]->read() == SC_LOGIC_0) && (in1[1]->read() == SC_LOGIC_0)){
            out1->write(SC_LOGIC_0);
        } else {
            out1->write(SC_LOGIC_1);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Nand
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(nand_n){

    sc_in< sc_logic > in1[2]; 
    sc_out< sc_logic > out1;

    SC_CTOR(nand_n){

        SC_METHOD(eval);
        sensitive << in1[0] << in1[1];

    }

    void eval(void){
        if ((in1[0]->read() == SC_LOGIC_1) && (in1[1]->read() == SC_LOGIC_1)){
            out1->write(SC_LOGIC_0);
        } else {
            out1->write(SC_LOGIC_1);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Nor
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(nor_n){

    sc_in< sc_logic> in1[2]; 
    sc_out< sc_logic> out1;

    SC_CTOR(nor_n){

        SC_METHOD(eval);
        sensitive << in1[0] << in1[1];

    }

    void eval(void){
        if ((in1[0]->read() == SC_LOGIC_0) && (in1[1]->read() == SC_LOGIC_0)){
            out1->write(SC_LOGIC_1);
        } else {
            out1->write(SC_LOGIC_0);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Xor
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(xor_n){

    sc_in< sc_logic> in1[2]; 
    sc_out< sc_logic> out1;

    SC_CTOR(xor_n){

        SC_METHOD(eval);
        sensitive << in1[0] << in1[1];

    }

    void eval(void){
        if (in1[0]->read() == in1[1]->read()){
            out1->write(SC_LOGIC_1);
        } else {
            out1->write(SC_LOGIC_0);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Xnor
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(xnor_n){

    sc_in< sc_logic> in1[2]; 
    sc_out< sc_logic> out1;

    SC_CTOR(xnor_n){

        SC_METHOD(eval);
        sensitive << in1[0] << in1[1];

    }

    void eval(void){
        if (in1[0]->read() == in1[1]->read()){
            out1->write(SC_LOGIC_0);
        } else {
            out1->write(SC_LOGIC_1);
        }
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Primary Input      
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(pin){

    sc_in< sc_logic > in1; 
    sc_out< sc_logic > out1;

    SC_CTOR(pin){

        SC_METHOD(eval);
        sensitive << in1;

    }

    void eval(void){
        out1->write(in1->read());
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    Primary Output      
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(pout){

    sc_in< sc_logic > in1; 
    sc_out< sc_logic > out1;

    SC_CTOR(pout){

        SC_METHOD(eval);
        sensitive << in1;

    }

    void eval(void){
        out1->write(in1->read());
    };
};

/////////////////////////////////////////////////////////////////////////////////////
//    D Flip Flop 
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(dff){

    sc_in<sc_logic> D, C, CLR, PRE, CE, NbarT, Si, global_reset;
    sc_out<sc_logic> Q;

    sc_signal<sc_logic, SC_MANY_WRITERS> val;
    // sc_signal<sc_logic> val;

    // sc_time tphl; 
    // sc_time tplh;

    SC_HAS_PROCESS(dff);
    dff(sc_module_name _name) 
    : sc_module(_name) {
    // DFlipFlop(sc_module_name _name, sc_time tphl, sc_time tplh) 
    // : sc_module(_name), tphl(tphl), tplh(tplh) {

        SC_THREAD(eval);
            sensitive << val;
        SC_METHOD(set);
            sensitive << C;
        SC_METHOD(reset);
            sensitive << CLR << global_reset;
        SC_METHOD(preset);
            sensitive << PRE;
        
    }

    void eval(void){
        while(true){
                Q->write(val.read());
            wait();
        }
    }
    void set(void){
        if ((C->read() == SC_LOGIC_1) && ((PRE->read() == SC_LOGIC_0) && (CLR->read() == SC_LOGIC_0 && global_reset->read() == SC_LOGIC_0))){
            if (NbarT->read() == SC_LOGIC_1) val.write(Si->read());
            else if (CE->read() == SC_LOGIC_1) val.write(D->read());
        }
    }

    void reset(void){
        if (CLR->read() == SC_LOGIC_1 || global_reset->read() == SC_LOGIC_1) val.write(SC_LOGIC_0);
    }

    void preset(void){
        if ((PRE->read() == SC_LOGIC_1) && (CLR->read() == SC_LOGIC_0 && global_reset->read() == SC_LOGIC_0)) val.write(SC_LOGIC_1);
    }

};

/////////////////////////////////////////////////////////////////////////////////////
//    D Flip Flop: DFF_NP0
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(DFF_NP0){

    sc_in<sc_logic> D, C, R;
    sc_out<sc_logic> Q;

    sc_signal<sc_logic, SC_MANY_WRITERS> val;
    // sc_signal<sc_logic> val;

    // sc_time tphl; 
    // sc_time tplh;

    SC_HAS_PROCESS(DFF_NP0);
    DFF_NP0(sc_module_name _name) 
    : sc_module(_name) {

        SC_THREAD(eval);
            sensitive << val;
        SC_METHOD(set);
            sensitive << C;
        SC_METHOD(reset);
            sensitive << R;
    }

    void eval(void){
        while(true){
                Q->write(val.read());
            wait();
        }
    }
    void set(void){
        if ((C->read() == SC_LOGIC_0) && (R->read() == SC_LOGIC_0)){
            val.write(D->read());
        }
    }

    void reset(void){
        if (R->read() == SC_LOGIC_1) val.write(SC_LOGIC_0);
    }

};

/////////////////////////////////////////////////////////////////////////////////////
//    D Flip Flop: DFF_NP1
/////////////////////////////////////////////////////////////////////////////////////
SC_MODULE(DFF_NP1){

    sc_in<sc_logic> D, C, R;
    sc_out<sc_logic> Q;

    sc_signal<sc_logic, SC_MANY_WRITERS> val;
    // sc_signal<sc_logic> val;

    // sc_time tphl; 
    // sc_time tplh;

    SC_HAS_PROCESS(DFF_NP1);
    DFF_NP1(sc_module_name _name) 
    : sc_module(_name) {
    // DFlipFlop(sc_module_name _name, sc_time tphl, sc_time tplh) 
    // : sc_module(_name), tphl(tphl), tplh(tplh) {

        SC_THREAD(eval);
            sensitive << val;
        SC_METHOD(set);
            sensitive << C;
        SC_METHOD(reset);
            sensitive << R;
    }

    void eval(void){
        while(true){
                Q->write(val.read());
            wait();
        }
    }
    void set(void){
        if ((C->read() == SC_LOGIC_0) && (R->read() == SC_LOGIC_0)){
            val.write(D->read());
        }
    }

    void reset(void){
        if (R->read() == SC_LOGIC_1) val.write(SC_LOGIC_1);
    }

};

#endif


