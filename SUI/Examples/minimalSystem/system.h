#include <iostream>
#include "IssPowerV2.h"
#include "Memory.h"
#include "keyboard.h"
//#include "display.h"
#include <systemc.h>

template <int adrBit, int dataBit>
SC_MODULE (embsystem)
{
public:
	sc_in <sc_logic> clk;

	sc_signal <sc_logic> memReady, readMem, writeMem;
	sc_signal <sc_logic> CS;

	sc_signal <sc_logic> readIO, writeIO;
	sc_signal <sc_lv <16>> addrBus, memAdr;
	sc_signal <sc_lv <16>> sayacDataIn, dataBusOut; 
	sc_signal <sc_lv <16>> keyboardDataOut, memoryDataOut, sayacAdrOut;

	sc_logic CSV;
	sc_lv<16> decoded;

	sayacInstruction<16, 4, 16, 3> *sayacInstructionModuleEmb;
	memory <16,16> *memoryModule;
	keyboard <16> *keyboardModule;

	SC_CTOR(embsystem)
	{
		sayacInstructionModuleEmb = new sayacInstruction<16, 4, 16, 3>("sayacInstructionSetModuleEmb");
		(*sayacInstructionModuleEmb)
		(
			clk, memReady, sayacDataIn, dataBusOut, readMem, writeMem, readIO, writeIO, sayacAdrOut
		);
		
		memoryModule = new memory <16, 16>("memoryModule");
		(*memoryModule)(clk, readMem, writeMem, CS, sayacAdrOut, dataBusOut, memReady, memoryDataOut);

		keyboardModule = new keyboard <16>("keyboardModule");
		(*keyboardModule)(clk, readIO, keyboardDataOut);

		SC_METHOD (init);
		SC_METHOD (Modeling);
			sensitive << clk;
	}
	void init();
	void Modeling();
};

template <int adrBit, int dataBit>
void embsystem<adrBit, dataBit>::init()
{
	CSV = SC_LOGIC_1;
}
template <int adrBit, int dataBit>
void embsystem<adrBit, dataBit>::Modeling()
{
	CS = CSV;

	decoded = sayacAdrOut.read();

	if (decoded[15] == '0')
	{
		CSV = SC_LOGIC_1;
		sayacDataIn = memoryDataOut;
	}
	else if (decoded[15] == '1')
	{
		sayacDataIn = keyboardDataOut;
	}
}
