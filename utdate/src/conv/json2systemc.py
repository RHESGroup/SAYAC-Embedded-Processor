from utdate.src.conv.json2hdl import json2hdl

# see if it's multi-bit port
# TODO: check if module name is also used for any other property
#   if so change module name, since it raise an error in systemc

WHITE_SPACE = "    "

class json2systemc(json2hdl):
    def __init__(self, json_file) -> None:
        json2hdl.__init__(self, json_file)

        self.systemc = ""


    # @def: 
    #   size_Of_Ports; helper function to find size of input/output ports
    def size_Of_Ports(self):
        port_dic = self.top_module["ports"]
        sizePI = 0
        sizePO = 0

        for port in port_dic.values():
            if port["direction"] == "input":
                # considering ports can be multi-bit, add length of bits
                sizePI = sizePI + len(port["bits"])
            if port["direction"] == "output":
                sizePO = sizePO + len(port["bits"])

        # exclude clock and reset
        sizePI = sizePI - 2
        
        return sizePI, sizePO
    
    # @def: 
    #   size_Of_Ports; helper function to find number of DFFs in design
    def number_of_DFF(self):
        cells_dic = self.top_module["cells"]
        numb_DFF = 0

        for cell in cells_dic.values():
            if ((cell["type"].find("DFF") > -1) or (cell["type"].find("dff") > -1)):
                numb_DFF = numb_DFF + 1

        return numb_DFF
   
    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def find_net(self, net_number):
        # is net_number string
        # some net are set to constant string 1/0 
        if not (isinstance(net_number, str)):
            for key, values in self.net_dict.items():
                if len(values) == 1:
                    if (values[0] == net_number):
                        return key
                else:
                    for value in values:
                        if (value == net_number):
                            return key + "[" + str(values.index(value)) + "]"
        else:
            return "sc_logic_" + net_number + "_signal"
 
    # @def: add standard library library  
    def includes(self):
        include_lib = '#include <systemc.h>' + "\n"
        include_lib += '#include "component_library.h"'
        return include_lib

    # @def: define sc_core namespace
    def namespace_decl(self):
        namespace_decl = "using namespace sc_core;"
        return namespace_decl

    # @def: define sc_logic_signals to be use for port binding
    #   @output: a list of three string
    #       sc_logic_signal_declr: that goes to signal_declartion()
    #       sc_logic_method_declr: that goes to constructor_declaration()
    #       sc_logic_function_declr: that goes to module_declaration()
    def sc_logic_signals(self):
        sc_logic_signal_declr = ""
        sc_logic_method_declr = ""
        sc_logic_function_declr = ""

        # singals that provide SC_LOGIC_(0/1) for port binding process
        sc_logic_signal_declr += WHITE_SPACE 
        sc_logic_signal_declr += "sc_signal<sc_logic> sc_logic_1_signal;\n"
        sc_logic_signal_declr += WHITE_SPACE 
        sc_logic_signal_declr += "sc_signal<sc_logic> sc_logic_0_signal;\n"

        sc_logic_method_declr += WHITE_SPACE + f'SC_METHOD(sc_logic_signal_assignment);\n'
        
        sc_logic_function_declr += WHITE_SPACE + "void sc_logic_signal_assignment(void){ \n"
        sc_logic_function_declr += WHITE_SPACE + WHITE_SPACE + "sc_logic_1_signal.write(SC_LOGIC_1);\n"
        sc_logic_function_declr += WHITE_SPACE + WHITE_SPACE + "sc_logic_0_signal.write(SC_LOGIC_0);\n"
        sc_logic_function_declr += WHITE_SPACE + "}\n"
        
        return sc_logic_signal_declr, sc_logic_method_declr, sc_logic_function_declr

    # @def: declare ports
    def port_declaration(self):

        port_declaration = ""

        for port_name, port_prop in self.top_module["ports"].items():
            port_declaration += WHITE_SPACE 

            if port_prop["direction"] == "input":
                if len(port_prop["bits"]) == 1:
                    port_declaration += f'sc_in<sc_logic> {port_name};\n'
                else:
                    port_declaration += f'sc_in<sc_logic> {port_name}[{str(len(port_prop["bits"]))}];\n'
                
            elif port_prop["direction"] == "output":
                if len(port_prop["bits"]) == 1:
                    port_declaration += f'sc_out<sc_logic> {port_name};\n'
                else:
                    port_declaration += f'sc_out<sc_logic> {port_name}[{str(len(port_prop["bits"]))}];\n'
                
        return port_declaration

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def signal_declartion(self):

        signal_declartion = ""

        signal_declartion += self.sc_logic_signals()[0] + "\n"

        for net in self.net_dict:
            if not (net in self.ports_list):
                signal_declartion += WHITE_SPACE 
                signal_declartion += "sc_signal<sc_logic> " + net + ";\n"

        return signal_declartion
  
    # @def: retrieve cell parameters for each cell and pass it to cells_declaration()
    #   input: 
    #       cell: dictionaly of cell {hide_name, type, parameters, attributes, connections}
    #       index: an index to name and address cells with (get appended at the end of cell name)
    #   output: two separate string to append at different location
    #       instance_pointer: create a pointer to gate type
    #       cell_instantiation: instantiation of cells inside constructor
    def get_each_cell(self, cell, index):
        # retrieve cell type, parameters and connection as a dictionary
        cell_type = cell["type"]
        cell_parameter = cell["parameters"]
        cell_connections = cell["connections"]

        instance_pointer = ""
        cell_instantiation = ""

        instatnce_name = cell_type + "_" + str(index)
        # start string
        instance_pointer = WHITE_SPACE + cell_type + "* " + instatnce_name + ";\n"
 
        cell_instantiation = WHITE_SPACE + instatnce_name + " = new " + cell_type + '("' + instatnce_name + '");\n'
        
        # port mapping 
        # loop through each connection, get corresponding net-name
        for con_name, con_value in cell_connections.items():
            # is port multi-bit
            if (len(con_value) == 1):
                cell_instantiation += WHITE_SPACE + WHITE_SPACE
                cell_instantiation += instatnce_name + "->" + con_name + "(" + self.find_net(con_value[0]) + ");\n"
            else: # if net is multi-bit, slice the port loop through each bit
                i = 0
                for connection in con_value:
                    cell_instantiation += WHITE_SPACE + WHITE_SPACE
                    cell_instantiation += instatnce_name + "->" + con_name + "[" + str(i) + "]" + "(" + self.find_net(connection) + ");\n"
                    i += 1
                    
        return instance_pointer, cell_instantiation


    # @def: instance all the required modules, define pointers outside constructor and port binding inside
    def cells_declaration(self):
        instance_pointer = ""
        cell_instantiation = ""
        i = 0
        
        for cell_name, cell_prop in self.top_module["cells"].items():
            instance_pointer += self.get_each_cell(cell_prop, i)[0]
            cell_instantiation += self.get_each_cell(cell_prop, i)[1] + "\n"
            i += 1

        return instance_pointer, cell_instantiation

    # @def: declare module signature 
    def constructor_declaration(self):
        constructor_declaration = ""
        constructor_declaration += f'SC_CTOR( {self.module_name} ) ' + '{\n'
        
        # add cell instantiation and binding
        constructor_declaration += self.cells_declaration()[1] + "\n"
        
        # add sc_module for sc_logic_signals
        constructor_declaration += self.sc_logic_signals()[1] + "\n"

        constructor_declaration += WHITE_SPACE + "}\n"

        return constructor_declaration

    # @def: declare module signature 
    def module_declaration(self):
        entity_declaration = ""
        entity_declaration += f'SC_MODULE( {self.module_name} ) ' + '{\n'
        
        entity_declaration += "\n"
        entity_declaration += self.port_declaration()
        entity_declaration += "\n"
        entity_declaration += self.signal_declartion()
        entity_declaration += "\n"
        entity_declaration += self.cells_declaration()[0]
        entity_declaration += "\n"
        entity_declaration += self.constructor_declaration()
        entity_declaration += "\n"
        entity_declaration += self.sc_logic_signals()[2]

        entity_declaration += "};"
        return entity_declaration

    # @def: concatinate pieces and output final systemc module
    def generate_systemc(self):

        self.systemc += self.includes() + "\n"
        self.systemc += "\n"
        self.systemc += self.namespace_decl() + "\n"
        self.systemc += "\n"
        self.systemc += self.module_declaration() + "\n"

        return self.systemc
