from utdate.src.conv.json2systemc import json2systemc

# see if it's multi-bit port
# TODO: check if module name is also used for any other property
#   if so change module name, since it raise an error in systemc

WHITE_SPACE = "    "

class json2sc_testbench(json2systemc):
    def __init__(self, json_file, testbench, instance) -> None:
        json2systemc.__init__(self, json_file)
        self.testbench_name = testbench
        self.instance_name = instance

    # @def: add standard library library  
    def includes(self):
        include_lib = '#include <iostream>' + "\n"
        include_lib += '#include <fstream>' + "\n"
        include_lib += '#include <string>' + "\n"
        include_lib += '#include "systemc.h"' + "\n"
        include_lib += '#include "systemC_faultable_netlist.h"' + "\n"
        if(self.is_sequential):
            include_lib += '#include "fault_injector_seq.h"'
        else:
            include_lib += '#include "fault_injector_comb.h"'
        
        return include_lib

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def signal_declartion(self):

        signal_declaration = ""

        for port_name, port_prop in self.top_module["ports"].items():
            signal_declaration += WHITE_SPACE 

            # check whether the circuit is sequential
            if(self.is_sequential):
                # check whether port is single bit
                if len(port_prop["bits"]) == 1:
                    signal_declaration += f'sc_signal<sc_logic> {port_name};\n'
                else:
                    signal_declaration += f'sc_signal<sc_logic> {port_name}[{str(len(port_prop["bits"]))}];\n'
            else:
                if port_prop["direction"] == "input":
                    if len(port_prop["bits"]) == 1:
                        signal_declaration += f'sc_signal<sc_logic> {port_name};\n'
                    else:
                        signal_declaration += f'sc_signal<sc_logic> {port_name}[{str(len(port_prop["bits"]))}];\n'
                    
                elif port_prop["direction"] == "output":
                    if len(port_prop["bits"]) == 1:
                        signal_declaration += f'sc_signal<sc_logic> {port_name}_gld;\n'
                        signal_declaration += WHITE_SPACE + f'sc_signal<sc_logic> {port_name}_flt;\n'
                    else:
                        signal_declaration += f'sc_signal<sc_logic> {port_name}_gld[{str(len(port_prop["bits"]))}];\n'
                        signal_declaration += WHITE_SPACE + f'sc_signal<sc_logic> {port_name}_flt[{str(len(port_prop["bits"]))}];\n'

        # append test pins { NbarT, Si, global_reset, So }
        if(self.is_sequential):
            signal_declaration += WHITE_SPACE 
            signal_declaration += f'sc_signal<sc_logic> NbarT, Si, global_reset, So;\n'
    
        
        
        return signal_declaration
  

    # @def: instance all the required modules, define pointers outside constructor and port binding inside
    def cells_declaration(self):

        instance_pointer = ""
        cell_instantiation = ""

        instatnce_name = self.instance_name
        golden_instatnce_name = self.module_name + "_golden"
        faulty_instatnce_name = self.instance_name
        
        if(self.is_sequential):
            # pointer to faulty module under test
            instance_pointer = WHITE_SPACE + self.module_name + "* " + instatnce_name + ";\n"
            # pointer to fault injector module
            instance_pointer += WHITE_SPACE + f'fault_injector<{self.number_of_DFF()}, {self.size_Of_Ports()[0]}, {self.size_Of_Ports()[1]}>* flt_injector;\n'
        else:
            # pointer to faulty module under test
            instance_pointer = WHITE_SPACE + self.module_name + "* " + faulty_instatnce_name + ";\n"
            # pointer to golden module under test
            instance_pointer += WHITE_SPACE + self.module_name + "* " + golden_instatnce_name + ";\n"
            # pointer to fault injector module
            instance_pointer += WHITE_SPACE + "fault_injector* flt_injector;\n"
        # pointer to faultRegistry
        instance_pointer += WHITE_SPACE + "faultRegistry* accessRegistry;\n"
 
        cell_instantiation = WHITE_SPACE + WHITE_SPACE + 'accessRegistry = new faultRegistry();\n'
        
        # normally there are three (two for sequential) module that must be declared [fault injector, (golden)model (, faulty model)]
        for p in range(3):
            if (p == 0):
                if(self.is_sequential):
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'flt_injector = new fault_injector<{self.number_of_DFF()}, {self.size_Of_Ports()[0]}, {self.size_Of_Ports()[1]}>("fault_injector", accessRegistry);\n'
                else:
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'flt_injector = new fault_injector("fault_injector", accessRegistry);\n'
            elif(p == 1):
                if(self.is_sequential):
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'{instatnce_name} = new {self.module_name}("{instatnce_name}", accessRegistry);\n'
                else:
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'{golden_instatnce_name} = new {self.module_name}("{golden_instatnce_name}", accessRegistry);\n'
            elif(p == 2):
                if(self.is_sequential):
                    pass
                else:
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'{faulty_instatnce_name} = new {self.module_name}("{faulty_instatnce_name}", accessRegistry);\n'
            if(self.is_sequential):
                if(p == 0):
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'// output_port[0:2] is always assigned to scan pins\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'flt_injector->output_ports(global_reset);\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'flt_injector->output_ports(NbarT);\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'flt_injector->output_ports(Si);\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'// input_ports[0:2] is always assigned to scan pins\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'flt_injector->input_ports({self.clk_name});\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'flt_injector->input_ports({self.rst_name});\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'flt_injector->input_ports(So);\n'
                    cell_instantiation += '\n'
                if(p == 1):
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'{instatnce_name}->global_reset(global_reset);\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'{instatnce_name}->NbarT(NbarT);\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'{instatnce_name}->Si(Si);\n'
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'{instatnce_name}->So(So);\n'

            # port mapping 
            # loop through each connection, get corresponding net-name            
            for port_name, port_prop in self.top_module["ports"].items():
                # for sequential circuits and for faut-injector module, don't bind clock and reset since there were binded before
                if(not ((port_name == self.clk_name or port_name == self.rst_name) and (self.is_sequential) and (p == 0))):
                    if port_prop["direction"] == "input":
                        # is port single-bit
                        if len(port_prop["bits"]) == 1:
                            cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                            if (p == 0):
                                cell_instantiation += f'flt_injector->output_ports({port_name});\n'
                            elif(p == 1):
                                if(self.is_sequential):
                                    cell_instantiation += f'{instatnce_name}->{port_name}({port_name});\n'
                                else:
                                    cell_instantiation += f'{golden_instatnce_name}->{port_name}({port_name});\n'
                            elif(p == 2):
                                if(self.is_sequential):
                                    pass
                                else:
                                    cell_instantiation += f'{faulty_instatnce_name}->{port_name}({port_name});\n'
                        else: # if port is multi-bit, slice the port loop through each bit
                            for i in range(len(port_prop["bits"])):
                                cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                                if (p == 0):
                                    cell_instantiation += f'flt_injector->output_ports({port_name}[{i}]);\n'
                                elif(p == 1):
                                    if(self.is_sequential):
                                        cell_instantiation += f'{instatnce_name}->{port_name}[{i}]({port_name}[{i}]);\n'
                                    else:
                                        cell_instantiation += f'{golden_instatnce_name}->{port_name}[{i}]({port_name}[{i}]);\n'
                                elif(p == 2):
                                    if(self.is_sequential):
                                        pass
                                    else:
                                        cell_instantiation += f'{faulty_instatnce_name}->{port_name}[{i}]({port_name}[{i}]);\n'
                        
                    if port_prop["direction"] == "output":
                        # is port single-bit
                        if len(port_prop["bits"]) == 1:
                            cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                            if (p == 0):
                                if(self.is_sequential):
                                    cell_instantiation += f'flt_injector->input_ports({port_name});\n'
                                else:
                                    cell_instantiation += f'flt_injector->input_ports({port_name}_gld);\n'
                                    cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                                    cell_instantiation += f'flt_injector->input_ports({port_name}_flt);\n'
                            elif(p == 1):
                                if(self.is_sequential):
                                    cell_instantiation += f'{instatnce_name}->{port_name}({port_name});\n'
                                else:
                                    cell_instantiation += f'{golden_instatnce_name}->{port_name}({port_name}_gld);\n'
                            elif(p == 2):
                                if(self.is_sequential):
                                    pass
                                else:
                                    cell_instantiation += f'{faulty_instatnce_name}->{port_name}({port_name}_flt);\n'
                        else: # if port is multi-bit, slice the port loop through each bit
                            for i in range(len(port_prop["bits"])):
                                cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                                if (p == 0):
                                    if(self.is_sequential):
                                        cell_instantiation += f'flt_injector->input_ports({port_name}[{i}]);\n'
                                    else:
                                        cell_instantiation += f'flt_injector->input_ports({port_name}_gld[{i}]);\n'
                                        cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                                        cell_instantiation += f'flt_injector->input_ports({port_name}_flt[{i}]);\n'
                                elif(p == 1):
                                    if(self.is_sequential):
                                        cell_instantiation += f'{instatnce_name}->{port_name}[{i}]({port_name}[{i}]);\n'
                                    else:
                                        cell_instantiation += f'{golden_instatnce_name}->{port_name}[{i}]({port_name}_gld[{i}]);\n'
                                elif(p == 2):
                                    if(self.is_sequential):
                                        pass
                                    else:
                                        cell_instantiation += f'{faulty_instatnce_name}->{port_name}[{i}]({port_name}_flt[{i}]);\n'

        return instance_pointer, cell_instantiation

    def clock_process(self):
        SC_THREAD_definition = ""
        clocking_proc = ""

        SC_THREAD_definition += WHITE_SPACE + WHITE_SPACE + f'SC_THREAD(clocking);\n'
        clocking_proc += WHITE_SPACE + f'void clocking(void)'+ '{\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE + f'rst.write(SC_LOGIC_0);\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE + f'while(true)' + '{\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'clk.write(SC_LOGIC_0);\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'wait(10, SC_NS);\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'clk.write(SC_LOGIC_1);\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE + f'wait(10, SC_NS);\n'
        clocking_proc += WHITE_SPACE + WHITE_SPACE +'}\n'
        clocking_proc += WHITE_SPACE + '}\n'

        return SC_THREAD_definition, clocking_proc


    # @def: declare module signature 
    def constructor_declaration(self):
        constructor_declaration = ""
        constructor_declaration += WHITE_SPACE + f'SC_HAS_PROCESS(testbench);\n'
        constructor_declaration += WHITE_SPACE + f'testbench(sc_module_name _name)' + "{\n"
        
        # add cell instantiation and binding
        constructor_declaration += self.cells_declaration()[1] + "\n"
        if(self.is_sequential):
            constructor_declaration += self.clock_process()[0] + "\n"

        constructor_declaration += WHITE_SPACE + "}\n"

        return constructor_declaration

    # @def: declare module signature 
    def module_declaration(self):
        entity_declaration = ""
        entity_declaration += f'SC_MODULE( testbench ) ' + '{\n'
        
        entity_declaration += "\n"
        entity_declaration += self.signal_declartion()
        entity_declaration += "\n"
        entity_declaration += self.cells_declaration()[0]
        entity_declaration += "\n"
        entity_declaration += self.constructor_declaration()
        if(self.is_sequential):
            entity_declaration += "\n"
            entity_declaration += self.clock_process()[1]

        entity_declaration += "};"
        return entity_declaration


