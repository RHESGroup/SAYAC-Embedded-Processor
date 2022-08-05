#include <iostream>
#include <string>
#include <istream>
#include <stdio.h>
#include <systemc.h>

template <int NBit>
SC_MODULE(keyboard)
{
	sc_in <sc_logic> clk;
	sc_in <sc_logic> readIO;
	sc_out <sc_lv<NBit>> dataOut;

	sc_lv <NBit> temp;

	SC_CTOR(keyboard)
	{
		SC_THREAD(model);
		sensitive << readIO;
	}

	void model();
};

template <int NBit>
void keyboard <NBit> :: model()
{	
	char num[2];
	while (true)
	{
		if(readIO == '1')
		{
			cout << "\n\n              ********************** Guessed Password **********************\n";
			cout << "\n              Enter two character of the password  " << "    Time is:   " << sc_time_stamp() << "\n";
			for(int i = 0 ; i < 2; i++)
				cin >> num[i];
			temp.range(7,0) = num[1];
			temp.range(15,8) = num[0];
			dataOut.write(temp);
		}
		wait();
	}
}