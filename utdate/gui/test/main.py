from pathlib import Path
from tkinter import Tk, Frame, Canvas, Entry, Text, Button, PhotoImage
from utdate.src.script import faultCollapsing, bench, test_set_gen


OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)

def test(directories, config):
    Test(directories, config)


class Test(Frame):
    def __init__(self, parent, directories, config, controller=None, *args, **kwargs):
        Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        [working_directory, synthesis_dir, lib_dir, log_dir, test_dir, fltSim_dir] = directories
        self.testbench_name = ""
        self.instance_name = ""

        # self.geometry("800x600")
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
            0,
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

        canvas.create_rectangle(
            125.0,
            146.0,
            (125 + 300.0),
            (146 + 200.0),
            fill="#EBEBEB",
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

        # Buttons: fault collapsing --------------------
        self.faultcllps_img = PhotoImage(
            file=relative_to_assets("faultcllps.png"))
        self.faultcllps_success_img = PhotoImage(
            file=relative_to_assets("faultcllps_success.png"))
        self.faultcllps_fail_img = PhotoImage(
            file=relative_to_assets("faultcllps_fail.png"))
        self.faultCollpse_btn = Button(
            self,
            image=self.faultcllps_img,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.fault_collapsing(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir),
            relief="flat"
        )
        self.faultCollpse_btn.place(
            x=125.0,
            y=386.0,
            width=208.0,
            height=35.0
        )

        # Buttons: test generation --------------------
        self.test_disabled_img = PhotoImage(
            file=relative_to_assets("test_disabled.png"))
        self.test_img = PhotoImage(
            file=relative_to_assets("test.png"))
        self.test_success_img = PhotoImage(
            file=relative_to_assets("test_success.png"))
        self.test_fail_img = PhotoImage(
            file=relative_to_assets("test_fail.png"))
        self.testset_btn = Button(
            self,
            image=self.test_disabled_img,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.test_set_generation(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir),
            relief="flat"
        )
        self.testset_btn.place(
            x=125.0,
            y=536.0,
            width=208.0,
            height=35.0
        )
        self.testset_btn.config(state="disabled")


        # Buttons: bench generation --------------------
        self.bench_img = PhotoImage(
            file=relative_to_assets("bench.png"))
        self.bench_success_img = PhotoImage(
            file=relative_to_assets("bench_success.png"))
        self.bench_fail_img = PhotoImage(
            file=relative_to_assets("bench_fail.png"))
        self.bench_btn = Button(
            self,
            image=self.bench_img,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.bench_generation(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir),
            relief="flat"
        )
        self.bench_btn.place(
            x=125.0,
            y=461.0,
            width=208.0,
            height=35.0
        )

        # Buttons: Open log file --------------------
        self.openlog_disabled_img = PhotoImage(
            file=relative_to_assets("openlog_disabled.png"))
        self.openlog_img = PhotoImage(
            file=relative_to_assets("openlog.png"))
        
        self.openlog_flt_btn = Button(
            self,
            image=self.openlog_disabled_img,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.openlog_faultcollapse(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir),
            relief="flat"
        )
        self.openlog_flt_btn.place(
            x=343.0,
            y=386.0,
            width=82.0,
            height=35.0
        )
        
        self.openlog_bench_btn = Button(
            self,
            image=self.openlog_disabled_img,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.openlog_bench(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir),
            relief="flat"
        )
        self.openlog_bench_btn.place(
            x=343.0,
            y=461.0,
            width=82.0,
            height=35.0
        )

        self.openlog_testset_btn = Button(
            self,
            image=self.openlog_disabled_img,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: self.openlog_testset(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir),
            relief="flat"
        )
        self.openlog_testset_btn.place(
            x=343.0,
            y=536.0,
            width=82.0,
            height=35.0
        )

        # Entry for testbench name --------------------
        self.testbench_name_entry = Entry(
            self,
            bd=0,
            bg="#D9D9D9",
            highlightthickness=0,
            border=1,
            font=('Helvetica 14'),
            foreground="black"
            )
        self.testbench_name_entry.place(
                x=145.0,
                y=191.0,
                width=260.0,
                height=40.0
            )
        # Add text in Entry box for placeholder
        self.testbench_name_entry.insert(0, 'Testbench')
        # Use bind method for deleting placeholder on click and rewrite it on leaving (if it's empty)
        self.testbench_name_entry.bind("<Button-1>", self.click_testbench_ent)
        self.testbench_name_entry.bind("<Leave>", self.leave_testbench_ent)

        canvas.create_text(
            145.0,
            161.0,
            anchor="nw",
            text="Enter testbench Name:",
            fill="#222020",
            font=('Helvetica 15')
        )

        # Entry for Instance name --------------------
        self.instance_name_entry = Entry(
            self,
            bd=0,
            bg="#D9D9D9",
            highlightthickness=0,
            border=1,
            font=('Helvetica 14'),
            foreground="black"
            )
        self.instance_name_entry.place(
                x=145.0,
                y=288.0,
                width=260.0,
                height=40.0
            )
        # Add text in Entry box for placeholder
        self.instance_name_entry.insert(0, 'Instance')
        # Use bind method for deleting placeholder on click and rewrite it on leaving (if it's empty)
        self.instance_name_entry.bind("<Button-1>", self.click_instance_ent)
        self.instance_name_entry.bind("<Leave>", self.leave_instance_ent)

        canvas.create_text(
            145.0,
            258.0,
            anchor="nw",
            text="Enter Instance Name:",
            fill="#222020",
            font=('Helvetica 15')
        )
        # -------------------- Entry for instance name

        canvas.create_text(
            35.0,
            15.0,
            anchor="nw",
            text="Test",
            fill="#FFFFFF",
            font=("Inter", 32 * -1)
        )
        # window.resizable(False, False)
        # window.mainloop()

    def fault_collapsing(self, config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):
        self.testbench_name = self.testbench_name_entry.get()
        self.instance_name = self.instance_name_entry.get()

        faultCollapsing(self.testbench_name,  self.instance_name, config, working_directory, 
            synthesis_dir, lib_dir, log_dir, test_dir)

        self.faultCollpse_btn.config(image=self.faultcllps_success_img)
        self.openlog_flt_btn.config(image=self.openlog_img)
        

    def bench_generation(self, config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):
        
        bench(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir)
        
        self.bench_btn.config(image=self.bench_success_img)
        self.testset_btn.config(image=self.test_img)
        self.testset_btn.config(state="normal")
        self.openlog_bench_btn.config(image=self.openlog_img)

    def test_set_generation(self, config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir):

        test_set_gen(config, working_directory, synthesis_dir, lib_dir, log_dir, test_dir)
        self.testset_btn.config(image=self.test_success_img)
        self.openlog_testset_btn.config(image=self.openlog_img)


    def openlog_faultcollapse(self, working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config):
        print("not a functional, yet !!!")
        # TODO: create new window (TopLevel) and show report on it new text box
  
        # # read log file
        # with open(os.path.join(log_dir, "atalanta.log"), "r") as log_file:
        #     log_txt = log_file.read()
        
    def openlog_bench(self, working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config):
        print("not a functional, yet !!!")
    
    def openlog_testset(self, working_directory, synthesis_dir, lib_dir, log_dir, fltSim_dir, config):
        print("not a functional, yet !!!")
        

    
    # call function when we click on entry box
    def click_testbench_ent(*args):
        if (args[0].testbench_name_entry.get() == "Testbench"):
            args[0].testbench_name_entry.delete(0, 'end')
    
    # call function when we leave entry box
    def leave_testbench_ent(*args):
        if (args[0].testbench_name_entry.get() == ""):
            args[0].testbench_name_entry.delete(0, 'end')
            args[0].testbench_name_entry.insert(0, 'Testbench')
        args[0].focus()

    # call function when we click on entry box
    def click_instance_ent(*args):
        if (args[0].instance_name_entry.get() == "Instance"):
            args[0].instance_name_entry.delete(0, 'end')
    
    # call function when we leave entry box
    def leave_instance_ent(*args):
        if (args[0].instance_name_entry.get() == ""):
            args[0].instance_name_entry.delete(0, 'end')
            args[0].instance_name_entry.insert(0, 'Instance')      
        args[0].focus()

    # getter method
    def get_testbench_name(self):
        return self.testbench_name
    def get_instance_name(self):
        return self.instance_name



