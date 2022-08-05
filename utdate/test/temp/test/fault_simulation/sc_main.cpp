#include "systemc.h"
#include "testbench.h"

int sc_main(int argc, char* argv[]){
    testbench* fault_simulation = new testbench("testbench");
    
    // sc_trace_file *vcdfile;
    // vcdfile = sc_create_vcd_trace_file("vcdfile");
    // vcdfile->set_time_unit(1, SC_NS);

    // sc_trace(vcdfile, fault_simulation->clk, "clk");
    // sc_trace(vcdfile, fault_simulation->Si, "Si");
    // sc_trace(vcdfile, fault_simulation->NbarT, "NbarT");

 
    sc_start(50000, SC_NS);
    return 0;
}
