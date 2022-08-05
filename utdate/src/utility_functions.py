import os
import json
import shutil

# @def: 
#   unique_list; find and remove reapeted items of a list
#   @input: a list that might contain reapeted item
#   @output: a list with unique items
def unique_list(input_list):
  
    # initialize a null list
    unique_list = []
      
    # traverse for all elements
    for x in input_list:
        # check if exists in unique_list or not
        if x not in unique_list:
            unique_list.append(x)
    
    return unique_list

# @def: 
#   extract_name ; take the name and prune extra control tokens
#     @input   ; name
def extract_name(name):
    tokens = [',', '(', ')', '{', '}', ';', ':', '+', '-', '=']

    while name[-1] in tokens:
        name = name[:-1]
    return name

# @def: 
#   split_page ; find successive sequence in a string and split it into two part right after last element occures
#     @input   ;  page 
#                 input sequence
def split_page(page, sequence):
    pointer = 0
    for i in range(len(sequence)):
        pointer = page.find(sequence[i], pointer)
        
    return page[:pointer + len(sequence[-1])], page[pointer + len(sequence[-1]):]


# @def: 
#   mkdir ; make directory inside current working directory if not existed
#     @input   ;  name of directory (usually end in profix _dir)
#     @output : newly created directory
def mkdir(name, cwd, fresh=True):
    name_dir = os.path.join(cwd, name)
    if not(os.path.isdir(name_dir)):
        os.mkdir(name_dir)
    elif (fresh):
        shutil.rmtree(name_dir)
        os.mkdir(name_dir)
    return name_dir

#-------------------------------------------------------


# @def: 
#   lut2gate ; find and replace gate names
#     @input   ; string of a page
def lut2gate(temp_page):

    page2line = temp_page.splitlines()

    for indx, line in enumerate(page2line):
    
        if (line.strip().find("DFFRSE") > -1):
            page2line[indx] = line.replace('DFFRSE', 'DFF')

        if (line.strip().find(",") > -1):
            if (line.strip().find("LUT 0x1") > -1):
                page2line[indx] = line.replace('LUT 0x1', 'NOR')
            if (line.strip().find("LUT 0x8") > -1):
                page2line[indx] = line.replace('LUT 0x8', 'AND')
            if (line.strip().find("LUT 0x7") > -1):
                page2line[indx] = line.replace('LUT 0x7', 'NAND')
        else:
            if (line.strip().find("LUT 0x1") > -1):
                page2line[indx] = line.replace('LUT 0x1', 'NOT')
            if (line.strip().find("LUT 0x2") > -1):
                page2line[indx] = line.replace('LUT 0x2', 'BUF')   
            if (line.strip().find("LUT 0xe") > -1):
                page2line[indx] = line.replace('LUT 0xe', 'DFF')   
       
    return "\n".join(page2line)

def restore_name(temp_page):

    page2line = temp_page.splitlines()

    for indx, line in enumerate(page2line):
        # remove "new_"
        # find line which contains "new_"
        if (line.strip().find("new_") > -1):
            # split line considering white spaces
            words = line.split()
            # for each word in line
            for indx_2, word in enumerate(words):
                # if it contains "new_"
                if (word.strip().find("new_") > -1):
                
                    if len(word) > 1:
                        # trim functional tokens at the end
                        name = extract_name(word)
                        # remove last "new_"
                        new_word = name.replace('new_', '')
                        # remove last "_"
                        new_word = new_word[:-1]
                        new_word = word.replace(name, new_word)
                        words[indx_2] = new_word
                        # aggregate spilted line to make new line
            
            new_line = " ".join(words)
            # replace modified line
            page2line[indx] = new_line


    return "\n".join(page2line)


# @def: 
#   lut2gate ; find and remove . port from DFF
#     @input   ; string of a page
def remove_DFFport(temp_page):

    page2line = temp_page.splitlines()

    for indx, line in enumerate(page2line):
        # find DFF_PP
        if (line.strip().find("DFF_PP") > -1) and (line.strip().find("(") > -1):
            for indx_2, line_2 in enumerate(page2line[indx:]):
                # find ");" that happens after 
                if line_2.strip().find(");") > -1:
                    for indx_3, line_3 in enumerate(page2line[indx: indx + indx_2]):
                        if line_3.strip().find(".C") > -1:
                            page2line[indx + indx_3] = ""
                    break

    # create new page
    return "\n".join(page2line)


# @def: 
#   find_clk_rst_netNumber ; search json file and find signal (numbers) connected to pins "C" and "R" of every DFF 
#       this would be "clock" & "rest" respectively
#     @input   ; dictionary of cells
def find_clk_rst_netNumber(cells):
    clk_num = list()
    rst_num = list()
    
    # find net numbers connected to clock and reset pins of DFFs
    for cell in cells.values():
        if cell["type"].find("DFF") > -1:
            clk_num.append(cell["connections"]["C"][0])
            rst_num.append(cell["connections"]["R"][0])
    
    for cell in cells.values():
        if cell["type"].find("dff") > -1:
            clk_num.append(cell["connections"]["C"][0])
            rst_num.append(cell["connections"]["CLR"][0])
    
    # remove repeated numbers
    clk_num = unique_list(clk_num)
    rst_num = unique_list(rst_num)
    old_clk_num = clk_num.copy()
    
    # Recursive search for connected nets to nets we found so far
    #   append new nets then loop again until there is no new net to add
    #   in each loop, search for cells output for one of existing nets in list
    do_while = True
    while ((len(old_clk_num) != len(clk_num)) or do_while):
        do_while = False
        old_clk_num = clk_num.copy()

        for cell in cells.values():
            for connection_name, connection_value in cell["connections"].items():
                # search for clk
                if (connection_name.find("Y") > -1): # if output port named "Y"
                    if (connection_value[0] in clk_num):
                        if (cell["type"] == "BUF"):
                            clk_num.append(cell["connections"]["A"][0])
                        else:
                            clk_num.append(cell["connections"]["A"][0])
                            clk_num.append(cell["connections"]["B"][0])
                if (connection_name.find("O") > -1): # if output port named "O"
                    if (connection_value[0] in clk_num):
                        clk_num.append(cell["connections"]["I"][0])
                if (connection_name.find("out1") > -1): # if output port named "out1"
                    if (connection_value[0] in clk_num):
                        clk_num.append(cell["connections"]["in1"][0])
                
                # rest finder
                if (connection_name.find("Y") > -1):
                    if (connection_value[0] in rst_num):
                        if (cell["type"] == "BUF"):
                            rst_num.append(cell["connections"]["A"][0])
                        else:
                            rst_num.append(cell["connections"]["A"][0])
                            rst_num.append(cell["connections"]["B"][0])
                if (connection_name.find("O") > -1):
                    if (connection_value[0] in rst_num):
                        rst_num.append(cell["connections"]["I"][0])
                if (connection_name.find("out1") > -1):
                    if (connection_value[0] in rst_num):
                        rst_num.append(cell["connections"]["in1"][0])
        
        clk_num = unique_list(clk_num)
        rst_num = unique_list(rst_num)
    
    return clk_num, rst_num

# @def: 
#   find_clk_rst_name ; search module ports for clock and reset port_name (given clock and reset signal number)
#     @input; 
#       ports: dictionary of module ports
#       clk_num: list of clock (and connected nets)
#       rst_num: list of reset (and connected nets)
def find_clk_rst_name(ports, clk_num, rst_num):
    
    clk = ""
    rst = ""
    for port_name, port_value in ports.items():
        if port_value["bits"][0] in clk_num:
            clk = port_name.strip() 
        if port_value["bits"][0] in rst_num:
            rst = port_name.strip() 

    return clk, rst


# @def: 
#   find_clk_rst_name: read json/bench file for clock and reset name, remove clock and reset (along with all signals
#       connected to them) from bench file
#     @input; 
#       json_file: path to json file
#       bench_file: path to input bench file
def rm_float_net(json_file, bench_file):
    with open(json_file, "r") as j:
        js = json.load(j)

        module_name = list(js["modules"])[0]
        top_module = js["modules"][module_name]
        cells = top_module["cells"]
        ports = top_module["ports"]

    # check whether the design is sequential/combinational (check for existance of dff)
    is_seq = False
    for cell in cells.values():
        if ((cell["type"].find("DFF") > -1) or (cell["type"].find("dff") > -1)):
            is_seq = True

    with open(bench_file, "r") as b:
        bench = b.read()
    
    # if it's sequential remove clock and reset from bench file
    if(is_seq):
        clk_list, rst_list = find_clk_rst_netNumber(cells)
        clk, rst = find_clk_rst_name(ports, clk_list, rst_list)

        page2line = bench.splitlines()
        rst_nets = list()
        for indx, line in enumerate(page2line):
            if (line.strip().find(clk) > -1):
                page2line[indx] = "# " + page2line[indx]
            if (line.strip().find(rst) > -1):
                if (line.strip().find("=") > -1):
                    rst_name_name = line[:line.strip().find("=")].strip()
                    rst_nets.append(rst_name_name)
                    page2line[indx] = "# " + page2line[indx]
                else:
                    page2line[indx] = "# " + page2line[indx]
                # page2line[indx] = li " +npage2line[indx]
        
        for indx, line in enumerate(page2line):
            for rst_net in rst_nets:
                if (line.strip().find(rst_net) > -1):
                    page2line[indx] = "# " + page2line[indx]

        return "\n".join(page2line)
    else: # if combinational return bench as is
        return bench
