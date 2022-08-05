import json
from ..utility_functions import find_clk_rst_netNumber, find_clk_rst_name
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


class json2hdl:
    def __init__(self, json_file) -> None:
        with open(json_file, "r") as f:
            self.js = json.load(f)
        
        self.module_name = list(self.js["modules"])[0]
        self.top_module = self.js["modules"][self.module_name]
        self.ports_list = list(self.top_module["ports"])
        self.net_dict = self.net_declartion()
        self.is_sequential = self.is_sequential_check()

        clk_list, rst_list = find_clk_rst_netNumber(self.top_module["cells"])
        self.clk_name, self.rst_name = find_clk_rst_name(self.top_module["ports"], clk_list, rst_list)


    # @def: 
    #   is_sequential_check ; check whether the circuit is combinational/sequential
    def is_sequential_check(self):
        cells_dic = self.top_module["cells"]
        is_seq = False

        for cell in cells_dic.values():
            if ((cell["type"].find("DFF") > -1) or (cell["type"].find("dff") > -1)):
                is_seq = True

        return is_seq

    # @def: find actual net name using net integer value
    #   input: -
    #   output: dictionary of nets (key) and list of their correspondence net_number (value)
    def net_declartion(self):
        i = 0
        net_dict = dict()
        for net_name, net_prop in self.top_module["netnames"].items():
            # check if name is auto generated, if so, assign new name "S##"
            if (net_prop["hide_name"]):
                # if it's a port choose a name
                # on assumption that all signals are single bit
                net_name = "S" + str(i)
                i += 1
            elif not (net_name in self.ports_list):
                net_name = "new_" + net_name
                net_name = net_name.replace("[", "_")
                net_name = net_name.replace("]", "")
                net_name = net_name.replace(".", "_")

            # if net is multi-bits, create a list of corresponding bits
            # if (len(net_prop["bits"])):
            lis = list()
            for bit in net_prop["bits"]:
                lis.append(bit)
            
            # append net name and corresponding number (net value)
            net_dict.update({net_name: lis})
        
        return net_dict

    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def cells_declaration(self):
        cells_declaration = ""
        i = 0
        
        for cell_name, cell_prop in self.top_module["cells"].items():
            cells_declaration += self.get_each_cell(cell_prop, i) + "\n"
            i += 1
        return cells_declaration
    
    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def find_net(self, net_number):
        # is net_number string
        # some net are set to constant string 1/0 
        if not (isinstance(net_number, str)):
            for key, values in self.net_dict.items():
                for value in values:
                    if (value == net_number):
                        return key
        else:
            return net_number 
