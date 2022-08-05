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



class json2verilog(json2hdl):
    def __init__(self, json_file) -> None:
        # add parent constructor
        json2hdl.__init__(self, json_file)
        
        self.verilog = ""
        
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
            return "1'b" + net_number

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def module_declaration(self):
        module_declaration = ""
        module_declaration += "module " + self.module_name + "(" 
        for port in self.ports_list:
            module_declaration += port + ", "
        module_declaration = module_declaration[:-2] + ");\n"

        return module_declaration

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def port_declaration(self):
        # self.ports_list = list(self.top_module["ports"])

        port_declaration = ""

        for port_name, port_prop in self.top_module["ports"].items():
            if port_prop["direction"] == "input":
                if len(port_prop["bits"]) == 1:
                    port_declaration += f'input {port_name};\n'
                else:
                    port_declaration += f'input [{str(len(port_prop["bits"]) - 1)}:0] {port_name};'
                    # port_declaration += port_name + " : IN STD_LOGIC_VECTOR (" + str(len(port_prop["bits"]) - 1) + " DOWNTO 0);\n"

            elif port_prop["direction"] == "output":
                if len(port_prop["bits"]) == 1:
                    port_declaration += f'output {port_name};\n'
                else:
                    port_declaration += f'output [{str(len(port_prop["bits"]) - 1)}:0] {port_name};'
        
        return port_declaration


    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def wire_declartion(self):

        wire_declartion = ""

        for net in self.net_dict:
            if not (net in self.ports_list):
                wire_declartion += "wire " + net + ";\n"
        
        return wire_declartion

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def get_each_cell(self, cell, index):
        # retrieve cell type, parameters and connection as a dictionary
        cell_type = cell["type"]
        cell_parameter = cell["parameters"]
        cell_connections = cell["connections"]

        # start string
        cell_declaration = cell_type + " #(\n"
        
        # loop through each parameter and add them
        #   despite actual verilog output, we use 32'b (instead of 32'd), assuming that all variables are less then 32 bit
        for param_name, param_value in cell_parameter.items():
            cell_declaration += "  ." + param_name + "(32'b" + param_value + "),\n"
        
        # remove last "," and add newline
        cell_declaration = cell_declaration[:-2] + "\n"
        
        # add cell name 
        cell_declaration += ") " + cell_type + "_" + str(index) + "_" + " (\n"

        # loop through each connection, get corresponding net-name
        for con_name, con_value in cell_connections.items():
            cell_declaration += "  ." + con_name + "({ " 
            for connection in con_value:
                # find corresponding net name using net number
                cell_declaration += self.find_net(connection) + ", "
            
            # remove last ", " and " }),"
            cell_declaration = cell_declaration[:-2] + " }),\n"
            
        # remove last ",\n" and add newline
        cell_declaration = cell_declaration[:-2] + "\n"
        cell_declaration += ");"
            
        return cell_declaration

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def generate_verilog(self):

        self.verilog += self.module_declaration()
        self.verilog += "\n"
        self.verilog += self.wire_declartion()
        self.verilog += self.port_declaration()
        self.verilog += "\n"
        self.verilog += self.cells_declaration()
        self.verilog += "\n"
        self.verilog += "endmodule"

        return self.verilog
    