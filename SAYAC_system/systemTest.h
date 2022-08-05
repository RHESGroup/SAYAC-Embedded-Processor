#include <iostream>
#include "system.h"

SC_MODULE(systemTest)
{
	sc_signal <sc_logic> clk;
	//sc_signal <sc_lv<16>> input;

	embsystem<16, 16> *systemModule;

	SC_CTOR(systemTest)
	{
		systemModule = new embsystem<16, 16>("systemModule");
		(*systemModule)(clk);

		SC_THREAD (clocking);
		sensitive << clk;
	}

	void clocking();
};
void systemTest::clocking()
{
	while (true)
	{
		wait(2.5,SC_NS);
		clk = SC_LOGIC_0;
		wait(2.5,SC_NS);
		clk = SC_LOGIC_1;
	}
}
