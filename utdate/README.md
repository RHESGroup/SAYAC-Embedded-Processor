# UTDATE: Design And Test Environment

**utdate** is a tool provided by Navabi Lab Group (University of Tehran) to facilitate design and test flow of digital circuits.

In fact, *utdate* is a toolchain to generate some of files required for testing a design. It takes takes a high-level description of the circuit under test (CUT) in an HDL format, i.e., Verilog or VHDL, and in addition to synthesizing, it automatically generates the files needed for testing and executes simulations. Some stages might dependent on others, meaning that one phase might use outputs of the other. Hence, it is recommended to run all steps in specified order one after the other. However, it is possible to individually execute each stage. After running the toolchain, two main categories of files will be generated, synthesis and test-related files. The synthesis directory contains pre- and post-mapped synthesis outputs. The former is netlists of the default library of Yosys and the latter is netlists mapped to our custom library. The test directory gathers all files needed for test purposes including the “.bench” format of the CUT, fault list, and test set.

## How to install

*utdate* is a python package hosted at *Pypi* (the Python Package Index) and can be installed like any other using `pip install <package>` command. The package is self-contained and takes care of prerequisites. But before starting to use it you must make sure you have the right version of python installed.

This package relys on tcl/tk to run its GUI. *tkinter* is the standard Python interface to the Tcl/Tk. According to official [python documentation page](https://docs.python.org/3/library/tkinter.html)
> Running python -m tkinter from the command line should open a window demonstrating a simple Tk interface, letting you know that tkinter is properly installed on your system

It simply means that *Tkinter* (and, since Python 3.1, ttk, the interface to the newer themed widgets) is included in the Python standard library and it relies on Tcl/Tk being installed on your system. But depending on how you install Python, this may not happen automatically.

There is a detailed tutorial on how to get Python and Tkinter onto your machine on [tk documentation page](https://tkdocs.com/tutorial/install.html) but here's a brief overview:

### 1. For Linux Distribution (Using Package Manager)

Usually Linux distributions comes with a recent version of Python 3.x installed (if don't go a head and install it using Package Manager). That is most likely to contained with *tkinter* package as well. To find out, simply open python and `import tkinter`. If no error occures you're good to go. but  
> Sometimes Linux distributions separate out their Tkinter support into a separate package. If so, you'll need to find and install this package, which will also ensure that appropriate versions of the Tcl/Tk libraries are installed on your system.
> For example, running Ubuntu 20.04LTS, Python 3.8.2 is already installed. However, to use Tkinter, you need to install a separate package, named python3-tk:
```
%sudo apt-get install python3-tk
```

### 2. For MacOs
#### Easy Way
> the easiest way to get Tk and Tkinter installed on your system is using Python's binary installer, available at [python.org](https://www.python.org/).

### Install package using PIP

As was already mentioned, **utdate** can be easily installed using `pip`:

-  (Although not neccessary) let's Start by making sure you have the latest version of "pip" installed:
    Unix/MacOs:
    ```
    python3 -m pip install --upgrade pip
    ```
    Windows:
    ```
    py -m pip install --upgrade pip
    ```
 
-  Next, download the package from PyPi:
    ```
    pip install -i https://test.pypi.org/simple/ 
    ```

## How to Run

To run **utdate**, open a terminal at your working dirctory and call:
```
python3 -m utdate
```

This executes **utdate**'s `main` module and opens up the gui. 

Remember that opening the program would automatically creates new directories and places some file. 