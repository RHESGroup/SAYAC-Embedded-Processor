from pathlib import Path
import os

# from tkinter import *
# Explicit imports to satisfy Flake8
from tkinter import Tk, Frame, Canvas, Entry, Text, Button, PhotoImage, filedialog
from tkinter.tix import TEXT
from utdate.src.script import fault_simulation

OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)

def faultsim(directories, config):
    FaultSim(directories, config)


class FaultSim(Frame):
    def __init__(self, parent, directories, config, controller=None, *args, **kwargs):
        Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        [working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir] = directories
        
        self.test_file_dir = ""
        self.fault_file_dir = ""
        
        self.configure(bg = "#FFFFFF")


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
            1.4210854715202004e-14,
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

        # Images: upper ribbon -----------------------------
        canvas.image_image_1 = PhotoImage(
            file=relative_to_assets("image_1.png"))
        image_1 = canvas.create_image(
            68.0,
            35.0,
            image=canvas.image_image_1
        )

        # Images: Logo -----------------------------
        canvas.image_image_2 = PhotoImage(
            file=relative_to_assets("image_2.png"))
        image_2 = canvas.create_image(
            490.0,
            68.0,
            image=canvas.image_image_2
        )

        canvas.entry_image_1 = PhotoImage(
            file=relative_to_assets("entry_1.png"))
        entry_bg_1 = canvas.create_image(
            228.0,
            309.0,
            image=canvas.entry_image_1
        )
        # entry_1 = Text(
        #     bd=0,
        #     bg="#EAEAEA",
        #     highlightthickness=0
        # )
        # entry_1.place(
        #     x=28.0,
        #     y=99.0,
        #     width=400.0,
        #     height=418.0
        # )
        

        canvas.create_rectangle(
            35.0,
            350.0,
            420.0,
            510.0,
            fill="#D9D9D9",
            outline="")

        # Entry: -----------------------------
        canvas.entry_image_2 = PhotoImage(
            file=relative_to_assets("entry_2.png"))
        entry_bg_2 = canvas.create_image(
            140.0,
            159.5,
            image=canvas.entry_image_2
        )
        self.entry_2 = Text(
            self,
            bd=0,
            bg="#D9D9D9",
            font=("Courier", 16),
            highlightthickness=0,
            width=20,
            height=1
        )
        self.entry_2.place(
            x=37.0,
            y=(142.0 + 5)
        )
        self.entry_2.config(state="disabled")

        canvas.entry_image_3 = PhotoImage(
            file=relative_to_assets("entry_3.png"))
        entry_bg_3 = canvas.create_image(
            140.0,
            254.5,
            image=canvas.entry_image_3
        )
        self.entry_3 = Text(
            self,
            bd=0,
            bg="#D9D9D9",
            font=("Courier", 16),
            width=20,
            height=1,
            highlightthickness=0
        )
        self.entry_3.place(
            x=37.0,
            y=(237.0 + 5)
            # width=210.0,
            # height=33.0
        )
        self.entry_3.config(state="disabled")

        self.synth_log = Text(
            self,
            bd=0,
            font=("Courier", 14),
            bg="#D9D9D9",
            highlightthickness=0
        )
        self.synth_log.place(
            x=37.0,
            y=350.0,
            width=385.0,
            height=160.0
        )
        self.synth_log.config(state="disabled")

        # Text: -------------------------------
        canvas.create_text(
            35.0,
            8.0,
            anchor="nw",
            text="Fault ",
            fill="#FFFFFF",
            font=("Inter", 24 * -1)
        )

        canvas.create_text(
            10.0,
            37.0,
            anchor="nw",
            text="Simulation",
            fill="#FFFFFF",
            font=("Inter", 24 * -1)
        )

        canvas.create_text(
            35.0,
            309.0,
            anchor="nw",
            text="Simulation Report",
            fill="#000000",
            font=("Inter", 20 * -1)
        )

        canvas.create_text(
            35.0,
            202.0,
            anchor="nw",
            text="Use existing Fault list",
            fill="#000000",
            font=("Inter", 15 * -1)
        )

        canvas.create_text(
            35.0,
            107.0,
            anchor="nw",
            text="Use existing Test set",
            fill="#000000",
            font=("Inter", 15 * -1)
        )


        # Buttons: Fault Simulation, Open test file, Open fault file -----------------------------
        canvas.button_image_1 = PhotoImage(
            file=relative_to_assets("button_1.png"))
        faultsim_btn = Button(
            self,
            image=canvas.button_image_1,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.fault_sim(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir),
            relief="flat"
        )
        faultsim_btn.place(
            x=58.0,
            y=534.0,
            width=340.0,
            height=37.0
        )

        canvas.button_image_2 = PhotoImage(
            file=relative_to_assets("button_2.png"))
        open_test_btn = Button(
            self,
            image=canvas.button_image_2,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.open_test_file(working_directory),
            relief="flat"
        )
        open_test_btn.place(
            x=260.0,
            y=142.0,
            width=160.0,
            height=35.0
        )

        canvas.button_image_3 = PhotoImage(
            file=relative_to_assets("button_3.png"))
        open_fault_btn = Button(
            self,
            image=canvas.button_image_3,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.open_fault_file(working_directory),
            relief="flat"
        )
        open_fault_btn.place(
            x=260.0,
            y=237.0,
            width=160.0,
            height=35.0
        )



    def fault_sim(self, config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir):
        if(self.test_file_dir != ""):
            testbench = self.test_file_dir
        else:
            testbench = self.parent.windows["test"].get_testbench_name()
        
        if(self.fault_file_dir != ""):
            instance = self.fault_file_dir
        else:
            instance = self.parent.windows["test"].get_instance_name()

        fault_simulation(synthesis_dir, test_dir, fltSim_dir, config, testbench, instance)

        self.synth_log.config(state="normal")

        # read log file
        with open(os.path.join(fltSim_dir, "reportFile.txt"), "r") as log_file:
            log_txt = log_file.read()
        
        page2line = log_txt.splitlines()
        fault_report = page2line[-3] + '\n'
        fault_report += page2line[-2] + '\n'
        fault_report += page2line[-1]

        self.synth_log.insert('1.0', fault_report)
        self.synth_log.config(state="disabled")



    # callback function for open file dialog 
    def open_test_file(self, working_directory):
        self.entry_2.config(state="normal")
        
        self.test_file_dir = filedialog.askopenfilename(initialdir=working_directory, title="Select test file", filetypes=[("txt", ".txt"), ("test", ".test"), ("vector", ".vect"), ("pattern", ".pat")])
        file_name = self.test_file_dir[self.test_file_dir.rfind('/') + 1:]
        self.entry_2.delete('1.0', 'end')
        self.entry_2.insert('1.0', file_name)
        self.entry_2.config(state="disabled")

    # callback function for open file dialog 
    def open_fault_file(self, working_directory):
        self.entry_3.config(state="normal")
        
        self.fault_file_dir = filedialog.askopenfilename(initialdir=working_directory, title="Select fault file", filetypes=[("txt", ".txt"), ("fault", ".flt")])
        file_name = self.fault_file_dir[self.fault_file_dir.rfind('/') + 1:]
        
        self.entry_3.delete('1.0', 'end')
        self.entry_3.insert('1.0', file_name)
        
        self.entry_3.config(state="disabled")

