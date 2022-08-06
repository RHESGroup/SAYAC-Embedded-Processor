# System User Interface
**SAYAC SUI** is a comman line interface that simulates a complete embedded system including SAYAC processor, a memory and peripherals. This enables high-level simulation, debug and analysis of platforms. The embedded system is a SystemC virtual platform that can include different components models. The processor model is an instruction set simulator (ISS) and the peripherals are SystemC bus functional models. The complete system is provided to the user as an executable file. the executable file will be sufficient to load and execute a simulation and it is not necessary to write your own SystemC testbench / harness. This makes the system easy to use for the users who are not familiar with SystemC modeling. The SUI will be extended in future so that you can create your own platforms, new models of processors, and other platform components using SystemC libraries and run them in the simulation environment using the SUI. 


## MinimalSystem Example
Mnimal system is an example of SAYAC system that contains a processor, a memory, and a keyboard as a peripheral. The example is an embedded system that contains a processor, a memory, and a keyboard as a peripheral. 

![sui](https://user-images.githubusercontent.com/82899079/183257253-7d58b119-67ec-479e-9fe0-11bf7e99b0a0.jpg)

## Example Program
The application program that is being run on this SAYAC system, is a hardware security program.
In some specific APPs, in order to access the provided services, a user has to first grant access, providing a correct predefined password. 
 * Passwords must be 8 characters long;
 * APP performs the password correctness checking exploiting a custom co-processor, named SHADOW;
 * SHADOW is implemented resorting to the SAYAC processor;
 * APP and SHADOW interact via a shared memory called Mem, and specifically:
 * To request a new password check, APP has to:

    * store the 16 lower bits of the password into Mem(0x0F00),
    * store the 16 higher bits of the password into Mem(0x0F01),
    * store the value x000F into Mem(0x0F02);
    * at the completion of its check, SHADOW stores into Mem(0x0F10):
     * the value x0000 if the check failed,
     * the value x000F if the check passed;

In addition, the designers of SHADOW erroneously used a debug-oriented version of the processor SAYAC. In such a version, 2 general purpose registers (namely, R3 and R4) are used to store, at the completion of each Von-Neumann cycle, the number of clock cycles elapsed from the beginning of the current password checking, and the estimated power consumption from the beginning of the current password checking, respectively.

## How to run 
The executable harness file is provided to the users in addition to the source files that are needed for a system simulation. To run the example system you need to first invoke the SUI environment:

### 1. Go to the directory including the example:
```
CD $SourceDirectory/SUI/Examples/minimalSystem
```
### 2. Invoke the SUI environment:
```
>./SAYACsystem
```
After running this command argument, the user enters the SUI simulation environment:
```
Welcome to SAYAC system user interface
SUI>> Please enter your command
```
### 3. You can enable debugging mode:
```
SUI>> Please enter your command -dbg -hlp
SUI>> dbg>> hlp>> for debugging purpose:

	-dbg -on : entering the debugging mode
	-dbg -off: exiting the debugging mode

```
### 4. Run the simulation:
```
SUI>> Please enter your command -dbg -hlp
SUI>> dbg>> on>> You entered the Debugging mode
*********************************************
SUI>> Please enter your command -run
SUI>> run>> Running…

```

