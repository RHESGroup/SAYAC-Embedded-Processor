from pathlib import Path
import os

# from tkinter import *
from tkinter import Tk, Frame, Canvas, Entry, Text, Button, PhotoImage, Checkbutton, BooleanVar
from tkinter import END as tk_END
from tkinter import INSERT as tk_BEGIN

from utdate.src.script import netlist

OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)

def synthesis(directories, config):
    Synthesis(directories, config)


class Synthesis(Frame):
    def __init__(self, parent, directories, config, controller=None, *args, **kwargs):
        Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        [working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir] = directories

        # self.geometry("800x600")
        self.configure(bg = "#FFFFFF")

        self.tk_is_vhdl = BooleanVar(self, False)

        # Main Canvas
        canvas = Canvas(
            self,
            bg = "#FFFFFF",
            height = 600,
            width = 550,
            bd = 0,
            highlightthickness = 0,
            relief = "ridge"
        )
        canvas.place(x = 0, y = 0)

        canvas.create_rectangle(
            0.0,
            0.0,
            550.0,
            600.0,
            fill="#FFFFFF",
            outline="")

        canvas.create_rectangle(
            0.0,
            0.0,
            550.0,
            8.0,
            fill="#EE5959",
            outline="")

        # Images: upper ribbon, Logo -----------------------------
        canvas.image_image_1 = PhotoImage(
            file=relative_to_assets("image_1.png"))
        image_1 = canvas.create_image(
            68.0,
            35.0,
            image=canvas.image_image_1
        )

        canvas.image_image_2 = PhotoImage(
            file=relative_to_assets("image_2.png"))
        image_2 = canvas.create_image(
            490.0,
            68.0,
            image=canvas.image_image_2
        )

        # Buttons: Synthesis, open_log -----------------------------
        canvas.button_image_1 = PhotoImage(
            file=relative_to_assets("button_1.png"))
        synthesis_btn = Button(
            self,
            image=canvas.button_image_1,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.synthesize(working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config),
            relief="flat"
        )
        synthesis_btn.place(
            x=28.0,
            y=540.0,
            width=240.0,
            height=37.0
        )

        self.button_2_success = PhotoImage(
            file=relative_to_assets("button_2_success.png"))
        self.button_2_fail = PhotoImage(
            file=relative_to_assets("button_2_fail.png"))
        canvas.button_image_2_disabled = PhotoImage(
            file=relative_to_assets("button_2_disabled.png"))
        self.open_log_btn = Button(
            self,
            image=canvas.button_image_2_disabled,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.open_synth_log(working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config),
            relief="flat"
        )
        self.open_log_btn.place(
            x=290.0,
            y=540.0,
            width=240.0,
            height=37.0
        )
        self.open_log_btn.config(state="disabled")

        # Text & Shapes:  rectangle#1; synthe_report -------------------------------
        canvas.create_text(
            12.0,
            20.0,
            anchor="nw",
            text="Synthesis",
            fill="#FFFFFF",
            font=("Inter", 24 * -1)
        )

        canvas.create_text(
            290.0,
            185.0,
            anchor="nw",
            text="Enter Top Module Name:",
            fill="#222020",
            font=('Helvetica 15')
        )

        canvas.create_text(
            28.0,
            185.0,
            anchor="nw",
            text="Input files:\n",
            fill="#222020",
            font=('Helvetica 15')
        )

        canvas.create_rectangle(
            290.0,
            270.0,
            (290 + 240.0),
            (270 + 255.0),
            fill="#D9D9D9",
            outline="")

        # Entry: Top module name, synthesis_log-------------------------------
        self.module_name_entry = Entry(
            self,
            bd=0,
            bg="#D9D9D9",
            highlightthickness=0,
            border=1,
            font=('Helvetica 14')
            )
        self.module_name_entry.place(
                x=290.0,
                y=215.0,
                width=240.0,
                height=40.0
            )
        # Add text in Entry box for placeholder
        self.module_name_entry.insert(0, 'Top Module Name')
        # Use bind method for deleting placeholder on click and rewrite it on leaving (if it's empty)
        # self.module_name_entry.bind("<Button-1>", self.click)
        self.module_name_entry.bind("<Leave>", self.leave)


        self.synth_log = Text(
            self,
            bd=0,
            bg="#D9D9D9",
            font=("Courier", 10),
            highlightthickness=0,
            width=39,
            height=25
        )
        self.synth_log.place(
                x=290.0,
                y=270.0
            )
        self.synth_log.config(state="disabled")


    # display input files
    def display_files(self):
        canvas_for_files = Canvas(
            self,
            bg = "#EBEBEB",
            width = 240,
            height = 310,
            bd = 0,
            highlightthickness = 0,
            relief = "ridge"
        )

        canvas_for_files.place(x = 28, y = 215)
        
        # get file name from File().get_files() dictionary and
        file_names = list()
        for file_name in self.parent.windows["file"].get_files():
            file_names.append(file_name)

        for i, file in enumerate(file_names):
            canvas_for_files.create_text(
                15.0,
                15.0 + (34 * i),
                anchor="nw",
                text=file,
                fill="#222020",
                font=('Helvetica 15')
            )
        
        if(len(file_names) != 0):
            top_module_name = file_names[0][:file_names[0].rfind('.')]
            self.module_name_entry.delete(0, tk_END)
            self.module_name_entry.insert(tk_BEGIN, top_module_name)


    def synthesize(self, working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config):
        
        input_file_directory = list()
        file_names = list()
        for file_name, file_dir in self.parent.windows["file"].get_files().items():
            input_file_directory.append(file_dir)
            file_names.append(file_name)

        if(len(input_file_directory) != 0):
            extension = file_names[0][file_names[0].rfind('.') + 1:]
            if((self.module_name_entry.get() == "") or (self.module_name_entry.get() == "Top Module Name")):
                top_module_name = file_names[0][:file_names[0].rfind('.')]
            else:
                top_module_name = self.module_name_entry.get()

            if extension.find("vhd") > -1:
                self.tk_is_vhdl.set(True)
            else:
                self.tk_is_vhdl.set(False)
            #  TODO: create warning dialog window if all extensions are not the same 
            # for extension in extensions:
            #     ext = extension
            
            netlist(input_file_directory, top_module_name, config, working_directory, 
                synthesis_dir, lib_dir, log_dir, fltSim_dir,
                vhdl=self.tk_is_vhdl.get(), use_existing_script=False)
            
            self.synth_log.config(state="normal")
            # read log file
            with open(os.path.join(log_dir, "yosys.log"), "r") as log_file:
                log_txt = log_file.read()
            
            self.open_log_btn.config(state="normal")
            self.synth_log.config(state="normal")
            self.synth_log.delete(tk_BEGIN, tk_END)
            
            if(log_txt.find("CalledProcessError") > -1):
                self.open_log_btn.config(image=self.button_2_fail)
            else:
                # separate and log a few last lines
                indx = log_txt.rfind("Printing statistics")
                log_txt = log_txt[indx:]
                self.open_log_btn.config(image=self.button_2_success)

            self.synth_log.insert(tk_BEGIN, log_txt)
            self.synth_log.config(state="disabled")




    def open_synth_log(self, working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config):
        print("not a functional, yet !!!")
        # TODO: create new window (TopLevel) and show report on it
  
        # # read log file
        # with open(os.path.join(log_dir, "yosys.log"), "r") as log_file:
        #     log_txt = log_file.read()
    
    # call function when we click on entry box
    def click(*args):
        if (args[0].module_name_entry.get() == "Top Module Name"):
            args[0].module_name_entry.delete(0, 'end')
    
    # call function when we leave entry box
    def leave(*args):
        if (args[0].module_name_entry.get() == ""):
            args[0].module_name_entry.delete(0, 'end')
            args[0].module_name_entry.insert(0, 'Top Module Name')
        
        args[0].focus()

    def set_vhdl(self):
        pass

    # TODO: open yosys log file and check if it was successful
    #       if so, report "print-statistics"
    #       if not, show error