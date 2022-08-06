# System User Interface
**SAYAC SUI** is a comman line interface that simulates a complete embedded system including SAYAC processor, a memory and peripherals. This enables high-level simulation, debug and analysis of platforms. The embedded system is a SystemC virtual platform that can include different components models. The processor model is an instruction set simulator (ISS) and the peripherals are SystemC bus functional models. The complete system is provided to the user as an executable file. the executable file will be sufficient to load and execute a simulation and it is not necessary to write your own SystemC testbench / harness. This makes the system easy to use for the users who are not familiar with SystemC modeling. The SUI will be extended in future so that you can create your own platforms, new models of processors, and other platform components using SystemC libraries and run them in the simulation environment using the SUI. 


## MinimalSystem Example
Mnimal system is an example of SAYAC system that contains a processor, a memory, and a keyboard as a peripheral. The example is an embedded system that contains a processor, a memory, and a keyboard as a peripheral. 

![sui](https://user-images.githubusercontent.com/82899079/183257253-7d58b119-67ec-479e-9fe0-11bf7e99b0a0.jpg)


## How to run 
The executable harness file is provided to the users in addition to the source files that are needed for a system simulation. To run the example system you need to first invoke the SUI environment:

### 1. Go to the directory including the example
```
CD $SourceDirectory/SUI/Examples/minimalSystem
```
### 2. Invoke the SUI environment
```
>./SAYACsystem
```
After running this command argument, the user enters the SUI simulation environment:
```
Welcome to SAYAC system user interface
SUI>> Please enter your command
```
