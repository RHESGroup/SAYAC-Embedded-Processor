from ..conv.json2hdl import json2hdl


class fault_collapsing(json2hdl):
    def __init__(self, json_file, testbench, instance_name) -> None:
        json2hdl.__init__(self, json_file)

        self.fault_list = ""
        self.testbench = testbench
        self.inst_name = instance_name


    def table(self, cell_type):
        all_the_same = True
        stuck_at_one = True
        faultable = True
        if (cell_type == "and_n") or (cell_type == "nand_n"):
            pass
        elif (cell_type == "or_n") or (cell_type == "nor_n"):
            stuck_at_one = False
        elif (cell_type == "xor_n") or (cell_type == "xnor_n") or (cell_type == "fanout_n") or (cell_type == "pout"):
            all_the_same = False
        else:
            faultable = False
        
        return [faultable, all_the_same, stuck_at_one]
    
    # @def: find actual net name using net integer value
    #   input: net integer value
    #   output: net name
    def cells_declaration(self):
        cells_declaration = ""
        i = 0
        
        for cell_name, cell_prop in self.top_module["cells"].items():
            cells_declaration += self.get_each_cell(cell_prop, i)
            i += 1
        return cells_declaration

    def get_each_cell(self, cell, index):
        # retrieve cell type, parameters and connection as a dictionary
        cell_type = cell["type"]
        cell_parameter = cell["parameters"]
        cell_connections = cell["connections"]

        instance_name = cell_type + "_" + str(index)
        line = self.testbench + "/" + self.inst_name + "/" + instance_name + "/"
        # respectively: faultable, stuck_at_one, all_the_same
        f, a, s = self.table(cell_type)
        
        fault_detection = ""

        # separate "dff" and other components
        if (cell_type == "dff") or (cell_type == "DFF_NP1") or (cell_type == "DFF_NP0"):
            # loop through each port
            # if it's input, write correspondence name and fault
            for con_name, con_value in cell_connections.items():
                # if it is an input port
                if (con_name.find("D") > -1):
                    line_cell = line + con_name
                    fault_detection += line_cell + " 1" + "\n"
                    fault_detection += line_cell + " 0" + "\n"

        # is it a faultable gate
        if (f):
            # do all the input ports have a same stuck at value
            if(a):
                # is it stuck at one
                if(s):
                    # loop through each port
                    # if it's input, write correspondence name and fault
                    for con_name, con_value in cell_connections.items():
                        # if it is an input port
                        if (con_name.find("in") > -1):
                            if len(con_value) > 1:
                                for bit in con_value:
                                    line_cell = line + con_name + "(" + str(con_value.index(bit)) + ")"
                                    fault_detection += line_cell + " 1" + "\n"
                            else:
                                line_cell = line + con_name
                                fault_detection += line_cell + " 1" + "\n"

                else: # it's stuck at zero
                    for con_name, con_value in cell_connections.items():
                        # if it is an input port
                        if (con_name.find("in") > -1):
                            if len(con_value) > 1:
                                for bit in con_value:
                                    line_cell = line + con_name + "(" + str(con_value.index(bit)) + ")"
                                    fault_detection += line_cell + " 0" + "\n"
                            else:
                                line_cell = line + con_name
                                fault_detection += line_cell + " 0" + "\n"
                # endif: stuck_at
            else: # each input port has both stuck at one/zero 
                for con_name, con_value in cell_connections.items():
                    # if it is an input port
                    if (con_name.find("in") > -1):
                        if len(con_value) > 1:
                            for bit in con_value:
                                line_cell = line + con_name + "(" + str(con_value.index(bit)) + ")"
                                fault_detection += line_cell + " 1" + "\n"
                                fault_detection += line_cell + " 0" + "\n"
                        else:
                            line_cell = line + con_name
                            fault_detection += line_cell + " 1" + "\n"
                            fault_detection += line_cell + " 0" + "\n"
            #endif: same input
        #endif: it's not a faultable gate
        return fault_detection


    def generate_fault_list(self):
        
        self.fault_list = self.cells_declaration()
        return self.fault_list

