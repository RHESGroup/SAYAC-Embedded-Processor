from utdate.src.conv.json2systemc import json2systemc

# see if it's multi-bit port
# TODO: check if module name is also used for any other property
#   if so change module name, since it raise an error in systemc

WHITE_SPACE = "    "

class json2sc_testbench(json2systemc):
    def __init__(self, json_file) -> None:
        json2systemc.__init__(self, json_file)

    # @def: add standard library library  
    def includes(self):
        include_lib = '#include <iostream>' + "\n"
        include_lib += '#include <fstream>' + "\n"
        include_lib += '#include <string>' + "\n"
        include_lib += '#include "systemc.h"' + "\n"
        include_lib += '#include "js2sc.h"' + "\n"
        include_lib += '#include "fault_injector.h"'
        
        return include_lib

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def signal_declartion(self):

        signal_declaration = ""

        for port_name, port_prop in self.top_module["ports"].items():
            signal_declaration += WHITE_SPACE 

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
                
        
        return signal_declaration
  

    # @def: instance all the required modules, define pointers outside constructor and port binding inside
    def cells_declaration(self):

        instance_pointer = ""
        cell_instantiation = ""

        faulty_instatnce_name = "flt_dut"
        golden_instatnce_name = "gld_dut"
        
        # pointer to faulty module under test
        instance_pointer = WHITE_SPACE + self.module_name + "* " + faulty_instatnce_name + ";\n"
        # pointer to golden module under test
        instance_pointer += WHITE_SPACE + self.module_name + "* " + golden_instatnce_name + ";\n"
        # pointer to fault injector module
        instance_pointer += WHITE_SPACE + "fault_injector* flt_injector;\n"
        # pointer to faultRegistry
        instance_pointer += WHITE_SPACE + "faultRegistry* accessRegistry;\n"
 
        cell_instantiation = WHITE_SPACE + WHITE_SPACE + 'accessRegistry = new faultRegistry();\n'
        

        for p in range(3):
            if (p == 0):
                cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'flt_injector = new fault_injector("fault_injector", accessRegistry);\n'
            elif(p == 1):
                cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'{golden_instatnce_name} = new {self.module_name}("{self.module_name}_gold", accessRegistry);\n'
            elif(p == 2):
                cell_instantiation += WHITE_SPACE + WHITE_SPACE + f'{faulty_instatnce_name} = new {self.module_name}("{self.module_name}_faulty", accessRegistry);\n'
            # port mapping 
            # loop through each connection, get corresponding net-name            
            for port_name, port_prop in self.top_module["ports"].items():
                if port_prop["direction"] == "input":
                    # is port single-bit
                    if len(port_prop["bits"]) == 1:
                        cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                        if (p == 0):
                            cell_instantiation += f'flt_injector->output_ports({port_name});\n'
                        elif(p == 1):
                            cell_instantiation += f'{golden_instatnce_name}->{port_name}({port_name});\n'
                        elif(p == 2):
                            cell_instantiation += f'{faulty_instatnce_name}->{port_name}({port_name});\n'
                    else: # if port is multi-bit, slice the port loop through each bit
                        # i = 0
                        for i in range(len(port_prop["bits"])):
                            cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                            if (p == 0):
                                cell_instantiation += f'flt_injector->output_ports({port_name}[{i}]);\n'
                            elif(p == 1):
                                cell_instantiation += f'{golden_instatnce_name}->{port_name}({port_name}[{i}]);\n'
                            elif(p == 2):
                                cell_instantiation += f'{faulty_instatnce_name}->{port_name}({port_name}[{i}]);\n'
                    
                if port_prop["direction"] == "output":
                    # is port single-bit
                    if len(port_prop["bits"]) == 1:
                        cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                        if (p == 0):
                            cell_instantiation += f'flt_injector->input_ports({port_name}_gld);\n'
                            cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                            cell_instantiation += f'flt_injector->input_ports({port_name}_flt);\n'
                        elif(p == 1):
                            cell_instantiation += f'{golden_instatnce_name}->{port_name}({port_name}_gld);\n'
                        elif(p == 2):
                            cell_instantiation += f'{faulty_instatnce_name}->{port_name}({port_name}_flt);\n'
                    else: # if port is multi-bit, slice the port loop through each bit
                        # i = 0
                        for i in range(len(port_prop["bits"])):
                            cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                            if (p == 0):
                                cell_instantiation += f'flt_injector->input_ports({port_name}_gld[{i}]);\n'
                                cell_instantiation += WHITE_SPACE + WHITE_SPACE + WHITE_SPACE
                                cell_instantiation += f'flt_injector->input_ports({port_name}_flt[{i}]);\n'
                            elif(p == 1):
                                cell_instantiation += f'{golden_instatnce_name}->{port_name}({port_name}_gld[{i}]);\n'
                            elif(p == 2):
                                cell_instantiation += f'{faulty_instatnce_name}->{port_name}({port_name}_flt[{i}]);\n'

        return instance_pointer, cell_instantiation


    # @def: declare module signature 
    def constructor_declaration(self):
        constructor_declaration = ""
        constructor_declaration += WHITE_SPACE + f'SC_HAS_PROCESS(testbench);\n'
        constructor_declaration += WHITE_SPACE + f'testbench(sc_module_name _name)' + "{\n"
        
        # add cell instantiation and binding
        constructor_declaration += self.cells_declaration()[1] + "\n"

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

        entity_declaration += "};"
        return entity_declaration


