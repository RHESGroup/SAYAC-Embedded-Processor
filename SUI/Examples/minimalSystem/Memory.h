#include <systemc.h>
#include <iostream>     
#include <fstream> 
#include <string>

template <int adrBit, int dataBit>
SC_MODULE (memory)
{	
	int DebugON;
	int Loading;
	int StartingLocation;
	int PuttingData;
	std::string file;

	sc_in <sc_logic> clk;
	sc_in <sc_logic> memRead, memWrite;
	sc_in <sc_logic> CS;
	sc_in <sc_lv<adrBit>> address;
	sc_in <sc_lv<dataBit>> dataIn;

	sc_out <sc_logic> memReady;
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
	ifstream initFileLoad;
	ifstream PutAddr;
	ifstream PutData;
	initFile.open("PasswordBinaryV2.txt");
	initFileLoad.open(file);
	PutAddr.open("addr.txt");
	PutData.open("data.txt");
	cout<<"starting location: "<<StartingLocation<< endl;
	if(Loading){
		
 		int count = 0;
     
			
		while(!(initFileLoad.eof()))
		{	i = 0;
			if( i < memRange)
			{
				if(count == StartingLocation){
				
					initFileLoad >> data;
					mem[i] = data;
				//	cout << "data is  " << mem[i] << endl; 
					i++;
				}
				else{
					initFileLoad >> data;
					count++;
				}
			}
		}
		initFileLoad.close();
		if(DebugON){
			cout<<"Loading to MEM *************************************************************\n";
		}
	}
	
	if(PuttingData){
	
		int addr;
		std::string addr_s,data_s;
		int data_i;
		while(getline(PutAddr,addr_s)){
			i = 0;
			if( i < memRange ){
			
				PutData >> data;
				addr = std::stoi(addr_s);
				mem[addr] = data;
			//	cout << "addr and data is: "<< addr<<"  "<<mem[addr]<<endl;
				
				i++;
			}
	
		}
		
		PutAddr.close();
		PutData.close();
		if(DebugON){
			cout<<"Putting Data to MEM *************************************************************\n";
		}
	
	}
	
	else if(!(Loading) && !(PuttingData)) {
		int count = 0;
		while(!(initFile.eof()))
		{
			if( i < memRange){
				
				initFile >> data;
				mem[i] = data;
				//cout << "data is  " << mem[i] << endl; 
				i++;
			}
		}
		initFile.close();
	}
}
template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: readMem()
{
	sc_lv<adrBit> tempAdr;
	tempAdr = address;
	if (CS -> read() == '1')
	{
		if(memRead -> read() == '1')
		{
			if(tempAdr.to_uint() < memRange)
			{
				dataOut = mem[tempAdr.to_uint()];
			}
		}
	}
}

template <int adrBit, int dataBit>
void memory <adrBit, dataBit> :: writeMem()
{
	sc_lv <adrBit> tempAd;
	
	if (CS -> read() == '1')
	{
		tempAd = address;
		if (tempAd.to_uint() < memRange)
		{
			if(memWrite -> read() == '1')
			{
				mem[tempAd.to_uint()] = dataIn -> read();
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
	memReady = SC_LOGIC_0;
	//cout << "memReady Ready is " << memReady << "\n";
	if (CS -> read() == '1')
	{
		tempAd = address;
		if (tempAd.to_uint() < memRange)
		{
			if(memWrite -> read() == '1' || memRead -> read() == '1')
			{
				memReady = SC_LOGIC_1;
			}
		}
	}
}
