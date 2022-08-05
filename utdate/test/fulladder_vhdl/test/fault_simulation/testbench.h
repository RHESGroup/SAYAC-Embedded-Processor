#include <iostream>
#include <fstream>
#include <string>
#include "systemc.h"
#include "systemC_faultable_netlist.h"
#include "fault_injector_comb.h"

using namespace sc_core;

SC_MODULE( testbench ) {

    sc_signal<sc_logic> i0;
    sc_signal<sc_logic> i1;
    sc_signal<sc_logic> ci;
    sc_signal<sc_logic> s_gld;
    sc_signal<sc_logic> s_flt;
    sc_signal<sc_logic> co_gld;
    sc_signal<sc_logic> co_flt;

    fulladder* fut;
    fulladder* fulladder_golden;
    fault_injector* flt_injector;
    faultRegistry* accessRegistry;

    SC_HAS_PROCESS(testbench);
    testbench(sc_module_name _name){
        accessRegistry = new faultRegistry();
        flt_injector = new fault_injector("fault_injector", accessRegistry);
            flt_injector->output_ports(i0);
            flt_injector->output_ports(i1);
            flt_injector->output_ports(ci);
            flt_injector->input_ports(s_gld);
            flt_injector->input_ports(s_flt);
            flt_injector->input_ports(co_gld);
            flt_injector->input_ports(co_flt);
        fulladder_golden = new fulladder("fulladder_golden", accessRegistry);
            fulladder_golden->i0(i0);
            fulladder_golden->i1(i1);
            fulladder_golden->ci(ci);
            fulladder_golden->s(s_gld);
            fulladder_golden->co(co_gld);
        fut = new fulladder("fut", accessRegistry);
            fut->i0(i0);
            fut->i1(i1);
            fut->ci(ci);
            fut->s(s_flt);
            fut->co(co_flt);

    }
};
