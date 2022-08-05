from pathlib import Path
import os

# from tkinter import *
# Explicit imports to satisfy Flake8
from tkinter import Tk, Frame, Canvas, Entry, Text, Button, PhotoImage, filedialog, Checkbutton


OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)

def inputFile(directories, config):
    InputFile(directories, config)


class InputFile(Frame):
    def __init__(self, parent, directories, config, controller=None, *args, **kwargs):
        Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        [working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir] = directories

        self.file_directory = dict()        
        self.file_entry_box = dict()        
        self.delete_file_btn = dict()        
        self.initial_delete_file_btn_x = 414.0
        self.initial_delete_file_btn_y = 179.0
        self.initial_file_entry_box_x = 105.0
        self.initial_file_entry_box_y = 172.0

        # self.geometry("800x600")
        self.configure(bg = "#FFFFFF")


        self.canvas = Canvas(
            self,
            bg = "#FFFFFF",
            height = 600,
            width = 550,
            bd = 0,
            highlightthickness = 0,
            relief = "ridge"
        )

        self.canvas.place(x = 0, y = 0)
        self.canvas.create_rectangle(
            0.0,
            0.0,
            550.0,
            600.0,
            fill="#FFFFFF",
            outline="")

        self.canvas.create_rectangle(
            0.0,
            7.105427357601002e-15,
            550.0,
            8.000000000000007,
            fill="#EE5959",
            outline="")

        # Images: upper ribbon, Logo -----------------------------
        self.canvas.image_image_1 = PhotoImage(
            file=relative_to_assets("image_1.png"))
        image_1 = self.canvas.create_image(
            68.0,
            35.00000000000001,
            image=self.canvas.image_image_1
        )

        self.canvas.image_image_2 = PhotoImage(
            file=relative_to_assets("image_2.png"))
        image_2 = self.canvas.create_image(
            490.0,
            68.0,
            image=self.canvas.image_image_2
        )

        # self.canvas.entry_image_1 = PhotoImage(
        #     file=relative_to_assets("entry_1.png"))

        self.canvas.button_image_1 = PhotoImage(
            file=relative_to_assets("button_1.png"))

        # Shape: centered gray rectangle ------------------
        self.canvas.create_rectangle(
            105.0,
            172.0,
            (105.0 + 340),
            (172.0 + 340),
            fill="#EBEBEB",
            outline="")


        # Text: -------------------------------
        self.canvas.create_text(
            105.0,
            118.0,
            anchor="nw",
            text="Input Files: (In Order of compilation)",
            fill="#000000",
            font=("Inter", 20 * -1)
        )

        self.canvas.create_text(
            44.0,
            15.999999999999993,
            anchor="nw",
            text="File",
            fill="#FFFFFF",
            font=("Inter", 32 * -1)
        )

        # Buttons: Open file -----------------------------
        self.canvas.button_image_2 = PhotoImage(
            file=relative_to_assets("button_2.png"))
        openfile_btn = Button(
            self,
            image=self.canvas.button_image_2,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.openFile(working_directory),
            relief="flat"
        )
        openfile_btn.place(
            x=105.0,
            y=533.0,
            width=340.0,
            height=37.0
        )


    # callback function for open file dialog 
    def openFile(self, working_directory):
        file_dir = filedialog.askopenfilename(initialdir=working_directory, title="Select design", filetypes=[("verilog", ".v"), ("vhdl", ".vhd")])
        file_name = file_dir[file_dir.rfind('/') + 1:]

        if(file_name != ""):

            # add file to file_directory list
            self.file_directory.update({file_name: file_dir})

            if not (file_name in self.file_entry_box):            
                # add new row to file list text box
                self.file_entry_box.update({file_name: Entry(
                self,
                bd=0,
                bg="#D9D9D9",
                highlightthickness=0,
                border=1
                )})

                # add new delete button for file
                self.delete_file_btn.update({file_name: Button(
                    self,
                    image=self.canvas.button_image_1,
                    borderwidth=0,
                    highlightthickness=0,
                    command=lambda: self.delete_file(file_name),
                    relief="flat"
                )})

            # display all items
            for i, x in enumerate(self.delete_file_btn):
                self.delete_file_btn[x].place(
                    x=self.initial_delete_file_btn_x,
                    y=self.initial_delete_file_btn_y + (32 * (i)),
                    width=20.0,
                    height=20.0
                )
                
            for i, x in enumerate(self.file_entry_box):
                self.file_entry_box[x].place(
                    x=self.initial_file_entry_box_x,
                    y=self.initial_file_entry_box_y + (32 * (i)),
                    width=340.0,
                    height=32.0
                )

                self.file_entry_box[x].insert(0, x)
                self.file_entry_box[x].config(state="disabled")

    def delete_file(self, id):

        # remove {file from file directory, correspondent text box and delete button}
        self.file_directory.pop(id)
        self.file_entry_box[id].destroy()
        self.file_entry_box.pop(id)
        self.delete_file_btn[id].destroy()
        self.delete_file_btn.pop(id)

        # replace (display) remaining items
        for i, x in enumerate(self.delete_file_btn):
            self.delete_file_btn[x].place(
                x=self.initial_delete_file_btn_x,
                y=self.initial_delete_file_btn_y + (32 * (i)),
                width=20.0,
                height=20.0
            )
            
        for i, x in enumerate(self.file_entry_box):
            self.file_entry_box[x].place(
                x=self.initial_file_entry_box_x,
                y=self.initial_file_entry_box_y + (32 * (i)),
                width=340.0,
                height=32.0
            )

            self.file_entry_box[x].insert(0, x)
            self.file_entry_box[x].config(state="disabled")

    def get_files(self):
        return self.file_directory