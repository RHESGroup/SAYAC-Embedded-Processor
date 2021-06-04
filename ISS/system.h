#include <iostream>
#include "ISSPlusPower.h"
#include "Memory.h"
#include <systemc.h>

template <int adrBit, int dataBit>
SC_MODULE (embsystem)
{
	sc_in <sc_logic> clk;

	sc_signal <sc_logic> memReady, readMem, writeMem;
	sc_signal <sc_logic> CS;

	sc_signal <sc_logic> readIO, writeIO;
	sc_signal <sc_lv <16>> addrBus;
	sc_signal <sc_lv <16>> dataBus, dataBusOut;

	sayacInstruction<16, 4, 16, 3> *sayacInstructionModuleEmb;
	memory <16,16> *memoryModule;

	SC_CTOR(embsystem)
	{
		sayacInstructionModuleEmb = new sayacInstruction<16, 4, 16, 3>("sayacInstructionSetModuleEmb");
		(*sayacInstructionModuleEmb)
		(
			clk, memReady, dataBus, dataBusOut, readMem, writeMem, readIO, writeIO, addrBus
		);
		
		memoryModule = new memory <16, 16>("memoryModule");
		(*memoryModule)(clk, readMem, writeMem, CS, addrBus, dataBusOut, memReady, dataBus);

		SC_METHOD (Modeling);
			sensitive << clk;
	}
	void Modeling();

};

template <int adrBit, int dataBit>
void embsystem<adrBit, dataBit>::Modeling()
{
	CS = SC_LOGIC_1;
}