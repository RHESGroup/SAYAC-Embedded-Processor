#include <systemc.h>
#include <iostream>     
#include <fstream> 
#include <string>

template <int adrBit, int dataBit>
SC_MODULE (memory)
{
	sc_in <sc_logic> clk;
	sc_in <sc_logic> memRead, memWrite;
	sc_in <sc_logic> CS;
	sc_in <sc_lv<adrBit>> address;
	sc_in <sc_lv<dataBit>> dataIn;

	sc_out <sc_logic> dataReady;
	sc_out <sc_lv<dataBit>> dataOut;

	int memRange;
	sc_lv<dataBit> *mem;

	SC_CTOR(memory)
	{
		memRange = int(pow(2,adrBit));
		mem = new sc_lv<dataBit>[memRange];

		SC_THREAD (init);
		SC_METHOD (readMem);
		sensitive << address << memRead;
		SC_METHOD (writeMem);
		sensitive << clk.pos();
		SC_THREAD (dump);
		SC_METHOD (setMemReady);
		sensitive << memRead << memWrite << CS << address;
	}
	void init();

	void readMem();
	void writeMem();
	void dump();
	void setMemReady();
};

template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: init()
{
	int i = 0;
	sc_lv <dataBit> data;
	ifstream initFile;
	initFile.open("PasswordSabaBinaryFalsePass.txt");
	while(!(initFile.eof()))
	{
		if( i < memRange)
		{
			initFile >> data;
			mem[i] = data;
			cout << "data is  " << mem[i] << endl; 
			i++;
			
		}
	}
	initFile.close();
}
template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: readMem()
{
	sc_lv<adrBit> tempAdr;
	tempAdr = address;
	//dataReady = SC_LOGIC_0;
	if (CS -> read() == '1')
	{
		if(memRead -> read() == '1')
		{
			if(tempAdr.to_uint() < memRange)
			{
				dataOut = mem[tempAdr.to_uint()];
		//		dataReady = SC_LOGIC_1;
				//cout << "READ MEM" << "\t" << "dataOut : " << dataOut << endl;
		
			}
		}
	}
}


template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: writeMem()
{
	sc_lv <adrBit> tempAd;
	//dataReady = SC_LOGIC_0;

	//if (clk == '1' && clk -> event())
	{
		if (CS -> read() == '1')
		{
			tempAd = address;
			if (tempAd.to_uint() < memRange)
			{
				if(memWrite -> read() == '1')
				{
					mem[tempAd.to_uint()] = dataIn -> read();
					//dataReady = SC_LOGIC_1;
				}
			}
		}
	}
}



template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: dump()
{
	ofstream out;
	wait (30, SC_NS);
	out.open("dump.txt");
	for (int i = 0; i < memRange; i++)
	{
		out << i << "\t" << mem[i] << endl;
	}
	out.close();
}

template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: setMemReady()
{
	sc_lv <adrBit> tempAd;
	dataReady = SC_LOGIC_0;
	cout << "Data Ready is " << dataReady << endl;
	if (CS -> read() == '1')
	{
		tempAd = address;
		if (tempAd.to_uint() < memRange)
			{
				if(memWrite -> read() == '1' || memRead -> read() == '1')
				{
					dataReady = SC_LOGIC_1;
				}
			}
		}
		cout << "DataF Ready is " << dataReady << endl;

}