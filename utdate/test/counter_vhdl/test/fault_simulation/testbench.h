#include <iostream>
#include <fstream>
#include <string>
#include "systemc.h"
#include "systemC_faultable_netlist.h"
#include "fault_injector_seq.h"

using namespace sc_core;

SC_MODULE( testbench ) {

    sc_signal<sc_logic> clk;
    sc_signal<sc_logic> rst;
    sc_signal<sc_logic> en;
    sc_signal<sc_logic> co;
    sc_signal<sc_logic> counter[4];
    sc_signal<sc_logic> NbarT, Si, global_reset, So;

    counter_4bit* fut;
    fault_injector<4, 1, 5>* flt_injector;
    faultRegistry* accessRegistry;

    SC_HAS_PROCESS(testbench);
    testbench(sc_module_name _name){
        accessRegistry = new faultRegistry();
        flt_injector = new fault_injector<4, 1, 5>("fault_injector", accessRegistry);
            // output_port[0:2] is always assigned to scan pins
            flt_injector->output_ports(global_reset);
            flt_injector->output_ports(NbarT);
            flt_injector->output_ports(Si);
            // input_ports[0:2] is always assigned to scan pins
            flt_injector->input_ports(clk);
            flt_injector->input_ports(rst);
            flt_injector->input_ports(So);

            flt_injector->output_ports(en);
            flt_injector->input_ports(co);
            flt_injector->input_ports(counter[0]);
            flt_injector->input_ports(counter[1]);
            flt_injector->input_ports(counter[2]);
            flt_injector->input_ports(counter[3]);
        fut = new counter_4bit("fut", accessRegistry);
            fut->global_reset(global_reset);
            fut->NbarT(NbarT);
            fut->Si(Si);
            fut->So(So);
            fut->clk(clk);
            fut->rst(rst);
            fut->en(en);
            fut->co(co);
            fut->counter[0](counter[0]);
            fut->counter[1](counter[1]);
            fut->counter[2](counter[2]);
            fut->counter[3](counter[3]);
                                                                                                
        SC_THREAD(clocking);

    }

    void clocking(void){
        rst.write(SC_LOGIC_0);
        while(true){
            clk.write(SC_LOGIC_0);
            wait(10, SC_NS);
            clk.write(SC_LOGIC_1);
            wait(10, SC_NS);
        }
    }
};
