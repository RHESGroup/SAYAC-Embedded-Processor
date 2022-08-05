import os
import json
import subprocess
from subprocess import CalledProcessError
import shutil
from utdate.src.utility_functions import *
from utdate.src.utility_functions import split_page
from utdate.src.make_script import yosys_script_mk
from utdate.src.make_script import abc_script_mk
from utdate.src.conv.json2vhdl import json2vhdl
from utdate.src.conv.json2verilog import json2verilog
from utdate.src.conv.json2sc_testbench import json2sc_testbench
from utdate.src.conv.json2systemc import json2systemc
from utdate.src.conv.json2systemc_flt import json2systemc_flt
from utdate.src.flt.fault_collapsing import fault_collapsing
import utdate.lib as lib


def preparation():
   # create directory (synthesis, lib, log, bench)
   working_directory = os.getcwd()
   synthesis_dir = mkdir("synthesis", working_directory, False)
   lib_dir = lib.__path__[0]
   log_dir = mkdir("log", working_directory)
   test_dir = mkdir("test", working_directory)
   fltSim_dir = mkdir("fault_simulation", test_dir)

   # read config file
   with open(os.path.join(lib_dir, "config.json"), "r") as json_file:
      config = json.load(json_file)

   # copy abc.rc to test_dir
   abc_rc_src = os.path.join(lib_dir, "abc.rc")
   abc_rc_dst = os.path.join(test_dir, "abc.rc")
   try:
      shutil.copyfile(abc_rc_src, abc_rc_dst)

   # If source and destination are same
   except shutil.SameFileError:
      print("Source and destination represents the same file.")
   
   # If destination is a directory.
   except IsADirectoryError:
      print("Destination is a directory.")
   
   # If there is any permission issue
   except PermissionError:
      print("Permission denied.")
   
   # For other errors
   except:
      print("Error occurred while copying file.")

   # copy all files from lib/fault_simulation files to test_dir
   source_folder = os.path.join(lib_dir, "fault_simulation")
   destination_folder = fltSim_dir
   
   # fetch all files
   for file_name in os.listdir(source_folder):
      # construct full file path
      source = os.path.join(source_folder, file_name)
      destination = os.path.join(destination_folder, file_name)
      # copy only files
      if os.path.isfile(source):
         shutil.copy(source, destination)
      else:
         print("file/directory does not exist: ", source)

   return {"directories": [working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir], 
            "config": config}

# @def: synthesize using yosys
#  @args: 
#     config: dictionary of configuration obtained from json
#     vhdl: determine the design to be vhdl
#     use_existing_script: if set to false bypasses script making process
#        user must provide valid yosys script at valid location (under lib_dir)
def netlist(input_file_name, module_name, config, working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, vhdl=False, use_existing_script=False):
   yosys_script_dir = os.path.join(lib_dir, "yosys_script.ys")

   if not (use_existing_script):
      with open(yosys_script_dir,'w',encoding = 'utf-8') as f:
         f.write(yosys_script_mk(input_file=input_file_name, module_name=module_name, 
                                 config=config, working_directory=working_directory, 
                                 lib_dir=lib_dir, synthesis_dir=synthesis_dir, vhdl=vhdl))
   
   ###################### yosys ######################
   try:
      # run yosys script with input file name, throw exception if failed
      yosys_log = subprocess.run([config["yosys_bin"], yosys_script_dir], stdout=subprocess.PIPE, text=True, check=True)
      # an alternative would be to use input arg
      # yosys_log = subprocess.run([config["yosys_bin"], yosys_script_dir], stdout=subprocess.PIPE, text=True, input=f'script {yosys_script_dir}', check=True)
   except CalledProcessError:
      yosys_log = "CalledProcessError: \n" 
      yosys_log += "    yosys returned non-zero exit status 1"
      yosys_log_dir = os.path.join(log_dir, "yosys.log")
      with open(yosys_log_dir,'w', encoding = 'utf-8') as f:
         f.write(yosys_log)
   
   else:
      ###################### convert to vhdl, verilog, systemC ######################
      json_input = os.path.join(synthesis_dir, config["yosys_script_postmap_json_outputName"])
      
      j2vhd = json2vhdl(json_input)
      with open(os.path.join(synthesis_dir, config["vhdl_netlist_fileName"]), "w") as f:
         f.write(j2vhd.generate_vhdl())
      
      j2v = json2verilog(json_input)
      with open(os.path.join(synthesis_dir, config["verilog_netlist_fileName"]), "w") as f:
         f.write(j2v.generate_verilog())
      
      j2sc = json2systemc(json_input)
      with open(os.path.join(synthesis_dir, config["systemC_netlist_fileName"]), "w") as f:
         f.write(j2sc.generate_systemc())
      yosys_log_dir = os.path.join(log_dir, "yosys.log")
      with open(yosys_log_dir,'w', encoding = 'utf-8') as f:
         f.write(yosys_log.stdout)
   

# @def: generate bench file using abc
#  @args: 
#     config: dictionary of configuration obtained from json
#     reference to directories
def bench(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):
   # writing abc script
   abc_script_dir = os.path.join(lib_dir, "abc_script.scr")

   with open(abc_script_dir,'w',encoding = 'utf-8') as f:
      f.write(abc_script_mk(config=config, lib_dir=lib_dir, 
                              test_dir=test_dir, synthesis_dir=synthesis_dir))
   
   with open(os.path.join(synthesis_dir, config["yosys_script_premap_v_outputName"]), 'r', encoding = 'utf-8') as f:
      yosys_v_output = f.read()
      
   # remove .C port from asynch DFF_PP
   with open(os.path.join(test_dir, config["abc_v_inputName"]), 'w', encoding = 'utf-8') as f:
      f.write(remove_DFFport(yosys_v_output))
   

   # change dir to synthesis
   os.chdir(test_dir)
   ###################### yosys ######################
   # run abc script with input file name, through exception if failed
   abc_log = subprocess.run([config["abc_bin"]], stdout=subprocess.PIPE, text=True, input=f'source -x {abc_script_dir}', check=True)
   yosys_log_dir = os.path.join(log_dir, "abc.log")
   with open(yosys_log_dir,'w', encoding = 'utf-8') as f:
      f.write(abc_log.stdout)
   # change dir back to workdirectory
   os.chdir(working_directory)

   with open(os.path.join(test_dir, config["abc_bench_output"]), 'r', encoding = 'utf-8') as f:
      abc_pre_replace = f.read()
   
   abc_post_replace = restore_name(abc_pre_replace)
   abc_post_replace = lut2gate(abc_post_replace)

   with open(os.path.join(test_dir, config["abc_bench_output"]), 'w', encoding = 'utf-8') as f:
      f.write(abc_post_replace)

# @def: generate fault list and corresponding test vector
#  @args: 
#     testbench_name: name of simulated testbench, used to address hierarchy 
#     instance_name: name of design under test, used to address hierarchy 
#     config: dictionary of configuration obtained from json
#     use_existing_script: if set to false bypasses script making process
#     reference to directories
def fault(testbench_name,  instance_name, config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):
   json_input = os.path.join(synthesis_dir, config["yosys_script_postmap_json_outputName"])
   json_premap_input = os.path.join(synthesis_dir, config["yosys_script_premap_json_outputName"])
   bench_input = os.path.join(test_dir, config["abc_bench_output"])

   ###################### fault collapsing ######################
   fault_list = fault_collapsing(json_input, testbench_name,  instance_name)
   with open(os.path.join(test_dir, config["fault_list_fileName"]), 'w', encoding = 'utf-8') as f:
      f.write(fault_list.generate_fault_list())

   ###################### atalanta ######################
   with open(os.path.join(test_dir, config["abc_bench_rm_floated_net_output"]), 'w', encoding = 'utf-8') as b:
      b.write(rm_float_net(json_premap_input, bench_input))
   
   # change dir to test_dirctory
   os.chdir(test_dir)

   atalanta_script = f'{config["abc_bench_rm_floated_net_output"]}'

   # run atalanta script with input file name, through exception if failed
   atalanta_log = subprocess.run([config["atalanta_bin"], "-t", "test_list.txt", atalanta_script], stdout=subprocess.PIPE, text=True, check=True)
   atalanta_log_dir = os.path.join(log_dir, "atalanta.log")
   with open(atalanta_log_dir,'w', encoding = 'utf-8') as f:
      f.write(atalanta_log.stdout)

   # change back to working dir
   os.chdir(working_directory)
   

# @def: generate fault list and corresponding test vector
#  @args: 
#     testbench_name: name of simulated testbench, used to address hierarchy 
#     instance_name: name of design under test, used to address hierarchy 
#     config: dictionary of configuration obtained from json
#     use_existing_script: if set to false bypasses script making process
#     reference to directories
def fault_simulation(synthesis_dir, test_dir, fltSim_dir, config, testbench, instance):
   json_input = os.path.join(synthesis_dir, config["yosys_script_postmap_json_outputName"])
   # change dir to fault simulation directory
   os.chdir(fltSim_dir)

   # copy fault_list and test_list file into fault_simulation directory

   fault_list_source = os.path.join(test_dir, "fault_list.flt")
   fault_list_destination = os.path.join(fltSim_dir, "fault_list.flt")

   if os.path.isfile(fault_list_source):
      shutil.copy(fault_list_source, fault_list_destination)
   else:
      print("file/directory does not exist: ", fault_list_source)


   # remove extra information from atalanta output file and retain lists of vectors
   test_list_file = ""
   test_for_comb = ""
   test_for_seq = ""
   with open(os.path.join(test_dir, "test_list.txt"), "r") as f:
      test_list_file = f.read()
      # find the specifier
      page_one, page_two = split_page(test_list_file, "* Test patterns and fault free responses:")
      # turn string into list of lines
      page2line = page_two.splitlines()
      for line in page2line:
         if(line):
               # split line into list considering "white space"
               split_space = line.split(' ')
               # for combinational test list just retain input test patterns
               test_for_comb += split_space[-2] + "\n"
               # for sequential test list concatenate input test patterns and expected outputs (fault free responses)
               test_for_seq += split_space[-2] + split_space[-1] + "\n"
      
      # remove last line break "\n"
      test_for_comb = test_for_comb[:-1]
      test_for_seq = test_for_seq[:-1]


   with open(os.path.join(fltSim_dir, "test_list_comb.txt"), "w") as f:
      f.write(test_for_comb)
   with open(os.path.join(fltSim_dir, "test_list_seq.txt"), "w") as f:
      f.write(test_for_seq)


   j2sc_testbench = json2sc_testbench(json_input, testbench, instance)
   with open(os.path.join(fltSim_dir, config["systemC_testbench_fileName"]), "w") as f:
      f.write(j2sc_testbench.generate_systemc())

   j2sc_faultable_netlist = json2systemc_flt(json_input)
   with open(os.path.join(fltSim_dir, config["systemC_faultable_netlist_fileName"]), "w") as f:
      f.write(j2sc_faultable_netlist.generate_systemc())

   # call make file and save stdout
   # ** use stdout to debug later
   fault_log = subprocess.run(["make"], stdout=subprocess.PIPE, text=True, check=True)


# @def: generate fault list and corresponding test vector
#  @args: 
#     testbench_name: name of simulated testbench, used to address hierarchy 
#     instance_name: name of design under test, used to address hierarchy 
#     config: dictionary of configuration obtained from json
#     use_existing_script: if set to false bypasses script making process
#     reference to directories
def faultCollapsing(testbench_name,  instance_name, config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):
   json_input = os.path.join(synthesis_dir, config["yosys_script_postmap_json_outputName"])

   ###################### fault collapsing ######################
   fault_list = fault_collapsing(json_input, testbench_name,  instance_name)
   with open(os.path.join(test_dir, config["fault_list_fileName"]), 'w', encoding = 'utf-8') as f:
      f.write(fault_list.generate_fault_list())



# @def: generate fault list and corresponding test vector
#  @args: 
#     testbench_name: name of simulated testbench, used to address hierarchy 
#     instance_name: name of design under test, used to address hierarchy 
#     config: dictionary of configuration obtained from json
#     use_existing_script: if set to false bypasses script making process
#     reference to directories
def test_set_gen(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):
   json_premap_input = os.path.join(synthesis_dir, config["yosys_script_premap_json_outputName"])
   bench_input = os.path.join(test_dir, config["abc_bench_output"])

   ###################### atalanta ######################
   with open(os.path.join(test_dir, config["abc_bench_rm_floated_net_output"]), 'w', encoding = 'utf-8') as b:
      b.write(rm_float_net(json_premap_input, bench_input))
   
   # change dir to test_dirctory
   os.chdir(test_dir)

   atalanta_script = f'{config["abc_bench_rm_floated_net_output"]}'

   # run atalanta script with input file name, through exception if failed
   atalanta_log = subprocess.run([config["atalanta_bin"], "-t", "test_list.txt", atalanta_script], stdout=subprocess.PIPE, text=True, check=True)
   atalanta_log_dir = os.path.join(log_dir, "atalanta.log")
   with open(atalanta_log_dir,'w', encoding = 'utf-8') as f:
      f.write(atalanta_log.stdout)

   # change back to working dir
   os.chdir(working_directory)
   