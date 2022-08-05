from utdate.src.conv.json2hdl import json2hdl 

# assumptions: 
#   1. It's a flattend netlist which contains only one module as a top module
#   2. Numeric parameter and attribute values up are equ/less than 32 bits and are written as decimal
#       values.
#   
#   TODO: 
#       -  assumption 1. should change to a more general case where each module is converted through some
#                   sort of loop
#       - port declaration must support for multi-bit ports  
#       - add support for extra library as an input 



WHITE_SPACE = "    "

class json2vhdl(json2hdl): 
    def __init__(self, json_file) -> None:
        # add parent constructor
        json2hdl.__init__(self, json_file)
        
        self.vhdl = ""
    
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
                            return key + "(" + str(values.index(value)) + ")"
        else:
            return "'" + net_number + "'"

    # @def: add standard library library  
    def import_library(self):
        library_declaration = "LIBRARY IEEE;\nUSE IEEE.std_logic_1164.ALL;"
        return library_declaration

    # @def: declare ports
    def port_declaration(self):
        port_declaration = ""

        for port_name, port_prop in self.top_module["ports"].items():
            port_declaration += WHITE_SPACE + WHITE_SPACE

            if port_prop["direction"] == "input":
                if len(port_prop["bits"]) == 1:
                    port_declaration += port_name + " : IN STD_LOGIC" + ";\n"
                else:
                    port_declaration += port_name + " : IN STD_LOGIC_VECTOR (" + str(len(port_prop["bits"]) - 1) + " DOWNTO 0);\n"

            elif port_prop["direction"] == "output":
                if len(port_prop["bits"]) == 1:
                    port_declaration += port_name + " : OUT STD_LOGIC" + ";\n"
                else:
                    port_declaration += port_name + " : OUT STD_LOGIC_VECTOR (" + str(len(port_prop["bits"]) - 1) + " DOWNTO 0);\n"
        
        return port_declaration


    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def signal_declartion(self):

        signal_declartion = ""

        for net in self.net_dict:
            if not (net in self.ports_list):
                signal_declartion += WHITE_SPACE 
                signal_declartion += "SIGNAL " + net + " : STD_LOGIC" + ";\n"
        
        return signal_declartion

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    #   TODO: add support for external libaray
    def get_each_cell(self, cell, index):
        # retrieve cell type, parameters and connection as a dictionary
        cell_type = cell["type"]
        cell_parameter = cell["parameters"]
        cell_connections = cell["connections"]

        instance_name = cell_type + "_" + str(index)
        library = "WORK"

        
        # start string
        cell_declaration = ""
        cell_declaration += instance_name + ": ENTITY " + library + "." + cell_type + "\n"
        
        cell_declaration += WHITE_SPACE + "PORT MAP (\n"
        
        # loop through each connection, get corresponding net-name
        # port mapping 
        for con_name, con_value in cell_connections.items():
            # if net is single-bit  
            if (len(con_value) == 1):
                cell_declaration += WHITE_SPACE + WHITE_SPACE
                cell_declaration += con_name + " => " + self.find_net(con_value[0]) + ",\n"
            else: # if net is multi-bit, slice the port loop through each bit
                i = 0
                for connection in con_value:
                    cell_declaration += WHITE_SPACE + WHITE_SPACE
                    cell_declaration += con_name + "(" + str(i) + ")" + " => " + self.find_net(connection) + ",\n"
                    i += 1
        
        # remove last ",\n" and add newline
        cell_declaration = cell_declaration[:-2] + "\n"
        cell_declaration += WHITE_SPACE
        cell_declaration += ");"
            
        return cell_declaration


        
    # @def: declare module signature 
    def entity_declaration(self):
        entity_declaration = ""
        entity_declaration += "ENTITY " + self.module_name + " IS\n" 
        entity_declaration += WHITE_SPACE + "PORT (\n"
        
        entity_declaration += self.port_declaration()

        # remove last "; " and " }),"
        entity_declaration = entity_declaration[:-2] + ");\n"

        entity_declaration += "END ENTITY " + self.module_name + ";"

        return entity_declaration

    # @def: declare module signature 
    def arch_declaration(self):
        architecture_declaration = ""

        architecture_declaration += "ARCHITECTURE" + " arch OF " + self.module_name + " IS" + "\n"

        architecture_declaration += self.signal_declartion() + "\n"
        
        architecture_declaration += "BEGIN" + "\n"

        architecture_declaration += self.cells_declaration() + "\n"
        
        architecture_declaration += "END ARCHITECTURE arch;"

        return architecture_declaration


    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def generate_vhdl(self):

        self.vhdl += self.import_library() + "\n"
        self.vhdl += "\n"
        self.vhdl += self.entity_declaration() + "\n"
        self.vhdl += "\n"
        self.vhdl += self.arch_declaration()
        self.vhdl += "\n"

        return self.vhdl
