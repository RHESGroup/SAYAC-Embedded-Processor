from pathlib import Path
from tkinter import (
    Toplevel,
    Frame,
    Canvas,
    Button,
    Entry,
    PhotoImage,
    messagebox,
    StringVar,
)

from utdate.gui.file.main import InputFile
from utdate.gui.synthesis.main import Synthesis
from utdate.gui.test.main import Test
from utdate.gui.faultSim.main import FaultSim

OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)


def mainWindow(directories, config):
    MainWindow(directories, config)


class MainWindow(Toplevel):

    def __init__(self, directories, config, *args, **kwargs):
        Toplevel.__init__(self, *args, **kwargs)

        [working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir] = directories

        self.title("DATE: Design and Test Environment")

        self.current_window = None
        self.current_window_label = StringVar()

        # Add a frame rectangle
        self.sidebar_indicator = Frame(self, background="#EE5959")


        self.geometry("800x600")
        self.configure(bg = "#FFFFFF")


        self.canvas = Canvas(
            self,
            bg = "#FFFFFF",
            height = 600,
            width = 800,
            bd = 0,
            highlightthickness = 0,
            relief = "ridge"
        )

        self.canvas.place(x = 0, y = 0)
        self.canvas.create_rectangle(
            0.0,
            7.105427357601002e-15,
            800.0,
            600.0,
            fill="#FFFFFF",
            outline="")

        self.canvas.create_rectangle(
            250.0,
            7.105427357601002e-15,
            800.0,
            8.000000000000007,
            fill="#EE5959",
            outline="")

        self.canvas.create_rectangle(
            0.0,
            7.105427357601002e-15,
            250.0,
            600.0,
            fill="#222020",
            outline="")

        file_btn_image_1 = PhotoImage(
            file=relative_to_assets("button_1.png"))
        self.file_btn = Button(
            self.canvas,
            image=file_btn_image_1,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.file_btn, "file"),
            relief="flat"
        )
        self.file_btn.place(
            x=0.0,
            y=134.0,
            width=250.0,
            height=60.0
        )

        synth_btn_image_2 = PhotoImage(
            file=relative_to_assets("button_2.png"))
        self.synth_btn = Button(
            self.canvas,
            image=synth_btn_image_2,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.synth_btn, "synth"),
            relief="flat"
        )
        self.synth_btn.place(
            x=0.0,
            y=194.0,
            width=250.0,
            height=60.0
        )

        test_btn_image_3 = PhotoImage(
            file=relative_to_assets("button_3.png"))
        self.test_btn = Button(
            self.canvas,
            image=test_btn_image_3,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.test_btn, "test"),
            relief="flat"
        )
        self.test_btn.place(
            x=0.0,
            y=254.0,
            width=250.0,
            height=60.0
        )

        faultSim_btn_image_4 = PhotoImage(
            file=relative_to_assets("button_4.png"))
        self.faultSim_btn = Button(
            self.canvas,
            image=faultSim_btn_image_4,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.faultSim_btn, "faultsim"),
            relief="flat"
        )
        self.faultSim_btn.place(
            x=0.0,
            y=314.0,
            width=250.0,
            height=60.0
        )

        about_btn_image_5 = PhotoImage(
            file=relative_to_assets("button_5.png"))
        self.about_btn = Button(
            self.canvas,
            image=about_btn_image_5,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.about_btn, "abt"),
            relief="flat"
        )
        self.about_btn.place(
            x=0.0,
            y=374.0,
            width=250.0,
            height=60.0
        )

        exit_btn_image_6 = PhotoImage(
            file=relative_to_assets("button_6.png"))
        self.exit_btn = Button(
            self.canvas,
            image=exit_btn_image_6,
            borderwidth=0,
            highlightthickness=0,
            command= self.exit,
            relief="flat"
        )
        self.exit_btn.place(
            x=4.0,
            y=1.999999999999993,
            width=12.0,
            height=12.0
        )

        resize_btn_image_7 = PhotoImage(
            file=relative_to_assets("button_7.png"))
        self.resize_btn = Button(
            self.canvas,
            image=resize_btn_image_7,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.about_btn, "abt"),
            relief="flat"
        )
        self.resize_btn.place(
            x=19.0,
            y=1.999999999999993,
            width=12.0,
            height=12.0
        )

        button_image_8 = PhotoImage(
            file=relative_to_assets("button_8.png"))
        self.button_8 = Button(
            self.canvas,
            image=button_image_8,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.handle_btn_press(self.about_btn, "abt"),
            relief="flat"
        )
        self.button_8.place(
            x=33.0,
            y=1.999999999999993,
            width=12.0,
            height=12.0
        )

        # Loop through windows and place them
        self.windows = {
            "file": InputFile(self, directories, config),
            "synth": Synthesis(self, directories, config),
            "test": Test(self, directories, config),
            "faultsim": FaultSim(self, directories, config)
        }
        self.sidebar_indicator_y ={
            "file": 134,
            "synth": 194,
            "test": 254,
            "faultsim": 314

        }

        # self.handle_btn_press(self.file_btn, "file")
        self.create_all_pages()
        # # self.sidebar_indicator.place(x=0, y=0)

        # self.current_window.place(x=0, y=0, width=800.0, height=600.0)

        # self.current_window.tkraise()
        self.resizable(False, False)
        self.mainloop()

    def place_sidebar_indicator(self):
        pass

    # def logout(self):
    #     confirm = messagebox.askyesno(
    #         "Confirm log-out", "Do you really want to log out?"
    #     )
    #     if confirm == True:
    #         user = None
    #         self.destroy()
    #         login.gui.loginWindow()

    def create_all_pages(self):
        
        for window in self.windows.values():
            window.place(x=250, y=0, width=550.0, height=600.0)
        
        self.windows["file"].tkraise()
        # Place the sidebar on respective button
        self.sidebar_indicator.place(x=0, y=self.sidebar_indicator_y["file"], height=60, width=10)
        self.sidebar_indicator.tkraise()



    def handle_btn_press(self, caller, name):
        # Place the sidebar on respective button
        self.sidebar_indicator.place(x=0, y=self.sidebar_indicator_y[name], height=60, width=10)

        if(name == "synth"):
            self.windows[name].display_files()

        # Set current Window
        self.current_window = self.windows.get(name)

        # raise the frame of the button pressed to top
        self.windows[name].tkraise()
        self.sidebar_indicator.tkraise()

        # # Handle label change
        # current_name = self.windows.get(name)._name.split("!")[-1].capitalize()
        # self.canvas.itemconfigure(self.heading, text=current_name)

    def handle_dashboard_refresh(self):
        # Recreate the dash window
        self.windows["file"] = InputFile(self)

    def exit(self):
        quit()