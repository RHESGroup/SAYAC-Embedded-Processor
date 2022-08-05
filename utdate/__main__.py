import tkinter as tk
from utdate.gui.main_window.main import mainWindow
from utdate.src import script


prop = script.preparation()


if __name__ == "__main__":
    # Main window constructor
    root = tk.Tk()  # Make temporary window for app to start
    root.withdraw()  # WithDraw the window
    # loginWindow()
    mainWindow(prop["directories"], prop["config"])
    root.mainloop()
