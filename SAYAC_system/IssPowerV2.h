#include <iostream>
#include <systemc.h>
#include "power.h"

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
class sayacInstruction : public sc_module
{
public:
	int DebugON;
	
	sc_in <sc_logic> clk;
	sc_in <sc_logic> memReady;
	
	sc_in <sc_lv<N>> dataBus;
	sc_out <sc_lv<N>> dataBusOut;

	sc_out <sc_logic> readMem, writeMem;
	sc_out <sc_logic> readIO, writeIO;
	sc_out <sc_lv<N>> addrBus;

	powerM* powModule;

	int adrSpace;

	sc_lv <N> *regFile;

	SC_HAS_PROCESS(sayacInstruction);

	sayacInstruction(sc_module_name)
	{
		powModule = new powerM("pow"); //power meter Instrument

		adrSpace = int(pow(2,regFileAdrBit));
		regFile = new sc_lv<N>[adrSpace];

		SC_THREAD(abstractSimulation);
		sensitive << clk.pos();
	}

	sc_lv<N> PCregister, ADRregister, IRregister, flagRegister;
	sc_lv<N> powerAccumulator;

	sc_logic wrRegFile, rdRegFile;
	sc_lv <regFileAdrBit> regFileRdADR1, regFileRdADR2, regFileWrADR;
	sc_lv <N> regFileWrData, regFileRdData1, regFileRdData2;


	enum opCodes 
	{
		ORSV0, ORSV1, 
		OIns2,  
		OIANR, OIANI,  
		OIMSI, OIMHI,
		OISLR, OISAR,   
		OIADR, OISUR, 
		OIADI, OISUI, 
		OIMUL, OIDIV,
		OIns15
	};

	enum instructions2 
	{
		LDR, STR,  
		JMR, JMI
	};	
	enum instructions15
	{					
		COMP,//CMR, CMI, 
		BRANCH,//BRC, BRR,
		SHI, 
		NOT//NTR, NTD
	};

	enum I15_cmp
	{
		CMR, CMI
	};

	enum I15_brc
	{
		BRC, BRR
	};

	enum I15_not
	{
		NTR, NTD
	};

	void abstractSimulation();
	void writeRegFile(sc_lv <regFileAdrBit> WrADR, sc_lv <N> WrData);
	void readRegFile
	(
		sc_lv <regFileAdrBit> address1, sc_lv <regFileAdrBit> address2
	);
	sc_lv<N> nBitSignExtension(sc_lv<N> inputSignal, int nBit,  bool sign);
	sc_lv<N> shiftFunction(sc_lv<5> shiftNumber, sc_lv<N> input, bool logical);
};

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
void sayacInstruction <N, regFileAdrBit, opcodeBit, cyclesMDU> :: writeRegFile
	(sc_lv <regFileAdrBit> WrADR, sc_lv <N> WrData)
	{
		sc_uint <regFileAdrBit> wrAd;
		if (wrRegFile == '1')
		{		
			wrAd = WrADR;
			regFile[wrAd] = WrData;
				
			if(DebugON){
				cout << "[adr]   " << wrAd << endl;
				cout << "RegFile Write Data Is:  " << regFile[wrAd] << "\n";
				// << "Time :   " << sc_time_stamp()<< endl;	
			}	
		}
	}

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
void sayacInstruction <N, regFileAdrBit, opcodeBit, cyclesMDU> :: readRegFile
	(sc_lv <regFileAdrBit> address1, sc_lv <regFileAdrBit> address2)
{
	sc_uint<regFileAdrBit> ad1, ad2;
	ad1 = address1;
	ad2 = address2;
	regFileRdData1 = regFile[ad1];
	regFileRdData2 = regFile[ad2];
	//cout << "regFile p1:  " << regFileRdData1 << "\n";
	//cout << "regFile p2:  " << regFileRdData2 << "\n";
}

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
sc_lv<N> sayacInstruction <N, regFileAdrBit, opcodeBit, cyclesMDU> :: nBitSignExtension
	(sc_lv<N> inputSignal, int leftRange, bool sign)
{
	int left;
	left = leftRange;
	sc_lv <N> temp, signEximmOut;

	if (sign == true){
		for(int i = 0; i <= (N-leftRange); i++)
		{
			temp[i] = inputSignal[leftRange];
		}
		signEximmOut = (temp.range(N-leftRange, 0), inputSignal.range(leftRange,0));
	}
	else{
		for(int i = 0; i <= (N-leftRange); i++)
		{
			temp[i] = SC_LOGIC_0;
		}
		signEximmOut = (temp, inputSignal.range(leftRange,0));
	} 
	//cout << "signEximm is:  "<< signEximmOut << "\n";
	return signEximmOut;
}

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
sc_lv<N> sayacInstruction <N, regFileAdrBit, opcodeBit, cyclesMDU> :: shiftFunction
	(sc_lv<5> shiftNumber, sc_lv<N> input, bool logical)
{
	sc_lv<N> result;
	switch (logical)
	{
		case true:
		{
		//	cout << "LOGICAL" << "\n";
		//	cout << "ShiftNumber   " << shiftNumber[4] << "\n";
			if (shiftNumber[4] == 1 )
			{
				result = input.to_uint() << shiftNumber.range(3,0).to_uint();
				/*cout << "LEFT SHIFT" << "\n";
				cout << "input is  " << input.to_uint() << "\n";
				cout << "Num is  " << shiftNumber.range(3,0).to_uint() << "\n";
				cout << "Result is" << result << "\n";*/
			}
			else if(shiftNumber[4] == 0)
			{
				result = input.to_uint() >> shiftNumber.range(3,0).to_uint();
				//cout << "right SHIFT" << "\n";

			}
			break;
		}
		case false:
		{
			//cout << "False" << "\n";
			if (shiftNumber[4] == 1 )
			{
				result = input.to_uint() << shiftNumber.range(3,0).to_uint();
			}
			else if(shiftNumber[4] == 0)
			{
				//cout << "Positive" << "\n";
				for (int i = N-1; i >= N-(shiftNumber.range(3,0).to_uint()); i-- )
				{
					result[i] = input[N-1];
					//cout << "result[i]    " << result[i] << "\n"; 
				}
				result.range(N-(shiftNumber.range(3,0).to_uint())-1,0) = 
					input.range(N-1,shiftNumber.range(3,0).to_uint());
			}
		}
		default:
			break;
	}
	//cout << "Result is   " << result << "\n";
	return result;
}

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
void sayacInstruction <N, regFileAdrBit, opcodeBit, cyclesMDU> :: abstractSimulation()
{	
	sc_lv <2*N> multRes;
	sc_lv <N> complement;
	sc_lv <N> tempWrite;
	sc_lv <2> IR2;
	sc_lv <2> IR15;
	sc_lv <4> opcode;
	sc_lv <4> rdOrrs1;
	sc_lv <4> rs1ADR;
	sc_lv <4> rs2ADR;
	sc_lv <N> tempPC;
	sc_lv <N> signEximm;
	sc_lv <8> imm;
	sc_lv <N> Quo, Rem;
	sc_lv<3> RFI;
	sc_logic IR9;
	PCregister = 0x0000;

	while (true)
	{
		writeMem = SC_LOGIC_0;
		//cout << "MEM Ready before  is: " << memReady << "\n";
		while (memReady != '1')
		{
			readMem = SC_LOGIC_1;
			addrBus = PCregister;
			//cout << "addrBus   " << addrBus << "\n";
			wait();
		}
		//cout << "MEM Ready before IR is:" << memReady << "\n";
		IRregister = dataBus -> read();
		//cout << "Ir IS:    " << IRregister << "\n";

		opcode = IRregister.range(15,12);
		IR2 = IRregister.range(11,10);
		IR15 = IRregister.range(11,10);
		imm = IRregister.range(11,4);
		RFI = IRregister.range(6,4);
		rdOrrs1 = IRregister.range(3,0);
		rs1ADR = IRregister.range(7,4);
		rs2ADR = IRregister.range(11,8);
		IR9 = IRregister[9];
		readMem = SC_LOGIC_0;
		addrBus.write('Z');

		switch (opcode.to_uint())
		{
			case ORSV0:
			{
				PCregister = PCregister.to_uint() + 1;
				wait();
				break;
			}
			case ORSV1:
			{
				PCregister = PCregister.to_uint() + 1;
				wait();
				break;
			}
			case OIns2:
			{
				switch (IR2.to_uint())
				{
					case LDR:
					{
						if(DebugON){
							cout << "**************Ldr Instruction************** " << "\n";
						}
						wrRegFile = SC_LOGIC_0;
						readRegFile( rs1ADR, rs1ADR);
						ADRregister = regFileRdData1;
						wait();
						if (IRregister[9] == '0')
							while(memReady != '1')
							{
								readMem = SC_LOGIC_1;
								addrBus = ADRregister;
								wait();
							}
						else if(IRregister[9] == '1')
						{
							readIO = SC_LOGIC_1;
							addrBus = ADRregister;
							wait();
						}
						wrRegFile = SC_LOGIC_1;
						writeRegFile(rdOrrs1, dataBus);
						readMem = SC_LOGIC_0;
						readIO = SC_LOGIC_0;
						PCregister = PCregister.to_uint() + 1;
						if(DebugON){
							(*powModule).display(0x2, PCregister, writeIO);
						}
						wait();
						break;
					}
					case STR:
					{
						if(DebugON){
							cout << "**************STR Instruction************** " << "\n";
						}
						readRegFile( rdOrrs1, rs1ADR);
						ADRregister = regFileRdData1;
						wait();
					//	addrBus = ADRregister;
						if (IRregister[9] == '0')
						{
							while(memReady != '1')
							{
								//cout << "MemReady != 1" << "\n";
								writeMem = SC_LOGIC_1;
								addrBus = ADRregister;
								dataBusOut = regFileRdData2;
								wait();
							}
							//cout << "memReady STR is" << memReady << "\n";
						}
						else if(IRregister[9] == '1')
						{
							writeIO = SC_LOGIC_1;
							addrBus = ADRregister;
							dataBusOut = regFileRdData2;
							wait();
						}
						writeMem = SC_LOGIC_0;
						PCregister = PCregister.to_uint() + 1;
						if(DebugON){
							(*powModule).display(0x03, PCregister, writeIO);
						}
						writeIO = SC_LOGIC_0;
						wait();
						break;
					}
					case JMR:
					{
						if(DebugON){
							cout << "**************JMR Instruction************** " << "\n";
						}
						wrRegFile = SC_LOGIC_0;
						readRegFile( rs1ADR, rs1ADR);
						tempPC = PCregister.to_uint() + regFileRdData1.to_uint();
						wrRegFile = SC_LOGIC_1;
						if(IRregister[9] == '1')
						{
							tempWrite = PCregister.to_uint() + 1;
							writeRegFile(rdOrrs1, tempWrite);
						}
						PCregister = tempPC;
						if(DebugON){
							(*powModule).display(0x4, PCregister, writeIO);
						}
						wait();
						break;
					}
					case JMI:
					{
						if(DebugON){
							cout << "**************JMI Instruction************** " << "\n";
						}
						wrRegFile = SC_LOGIC_0;
						signEximm = nBitSignExtension(imm, 5,true);
						tempPC = PCregister.to_uint() + signEximm.to_int();
						tempWrite = PCregister.to_uint() + 1;
						wrRegFile = SC_LOGIC_1;
						writeRegFile(rdOrrs1, tempWrite);
						PCregister = tempPC;
						if(DebugON){
							(*powModule).display(0x5, PCregister, writeIO);
						}
						wait();
						break;
					}
					default:
						break;
				}
				break;
			}
			case OIANR:
			{
				if(DebugON){
					cout << "**************ANR Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = regFileRdData1 & regFileRdData2;
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(ANR, PCregister, writeIO);
				}
				wait();
				break;
			}
			case OIANI:  
			{
				if (flagRegister[15] != '1')
				{
					if(DebugON){
						cout << "**************ANI Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					readRegFile( rdOrrs1, rdOrrs1);
					signEximm = nBitSignExtension(imm, 7, false);
					tempWrite = regFileRdData1 & signEximm;
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1,tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(ANI, PCregister, writeIO);
					}
					wait();
				}
				else if(flagRegister[15] == '1')
				{
					if(DebugON){
						cout << "**************Shadow ANI Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rdOrrs1);
					signEximm = nBitSignExtension(imm, 3, false);
					tempWrite = regFileRdData1 & signEximm;
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1,tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(ANI, PCregister, writeIO);
					}
					wait();

				}
				break;
			}
			case OIMSI:
			{
				if(DebugON){
					cout << "**************MSI Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				signEximm = nBitSignExtension(imm, 7, true);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1,signEximm);
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(MSI, PCregister, writeIO);
				}
				wait();			
				break;
			}
			case OIMHI:
			{
				if(DebugON){
					cout << "**************MHI Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				readRegFile( rdOrrs1, rdOrrs1);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1,(imm,regFileRdData1.range(7,0)));
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(MHI, PCregister, writeIO);
				}
				wait();
				break;
			}
			case OISLR:
			{
				if(DebugON){
					cout << "**************SLR Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = shiftFunction(regFileRdData2.range(4,0),regFileRdData1, true);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(SLR, PCregister, writeIO);
				}
				wait();
				break;
			}
			case OISAR:
			{
				if(DebugON){
					cout << "**************SAR Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = shiftFunction(regFileRdData2.range(4,0),regFileRdData1, false);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(SAR, PCregister, writeIO);
				}
				wait();
				break;
			}
			case OIADR:
			{
				if(DebugON){
					cout << "**************ADR Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = regFileRdData1.to_uint() + regFileRdData2.to_uint();
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(ADR, PCregister, writeIO);
				}
				wait();
				break;
			}
			case OISUR: 
			{
				if(DebugON){
					cout << "**************SUR Instruction************** " << "\n";
				}
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = regFileRdData1.to_uint() - regFileRdData2.to_uint();
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				if(DebugON){
					(*powModule).display(SUR, PCregister, writeIO);
				}
				wait();
				break;
			}
			case OIADI:
			{
				if( flagRegister[15] != '1')
				{
					if(DebugON){
						cout << "**************ADI Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					//cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rdOrrs1, rdOrrs1);
					signEximm = nBitSignExtension(imm, 7, true);
					tempWrite = regFileRdData1.to_uint() + signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(ADI, PCregister, writeIO);
					}
					wait();
				}
				else if( flagRegister[15] == '1')
				{
					if(DebugON){
						cout << "**************Shadow ADI Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
				//	cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rs1ADR, rdOrrs1);
					signEximm = nBitSignExtension(imm, 3, true);
					tempWrite = regFileRdData1.to_uint() + signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(ADI, PCregister, writeIO);
					}
					wait();
				}
				break;
			}
			case OISUI: 
			{
				if( flagRegister[15] != '1')
				{
					if(DebugON){
						cout << "**************SUI Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					//cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rdOrrs1, rdOrrs1);
					signEximm = nBitSignExtension(imm, 7, true);
					tempWrite = regFileRdData1.to_uint() - signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(SUI, PCregister, writeIO);
					}
					wait();
				}
				else if( flagRegister[15] == '1')
				{
					if(DebugON){
						cout << "**************Shadow SUI Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					//cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rs1ADR, rdOrrs1);
					signEximm = nBitSignExtension(imm, 3, true);
					tempWrite = regFileRdData1.to_uint() - signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(SUI, PCregister, writeIO);
					}
					wait();
				}
				break;
			}
			case OIMUL: 
			{
				if( flagRegister[13] != '1')
				{
					if(DebugON){
						cout << "**************MUL Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					multRes = regFileRdData1.to_uint() * regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					tempWrite = multRes.range(N-1,0);
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					tempWrite = multRes.range(2*N-1,N);
					wrRegFile = SC_LOGIC_1;
					writeRegFile((rdOrrs1.to_uint() + 1), tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(MUL, PCregister, writeIO);
					}
					wait();
				}
				else if( flagRegister[13] == '1' )
				{
					if(DebugON){
						cout << "**************Shadow MUL Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					multRes = regFileRdData1.to_uint() * regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					tempWrite = multRes.range(N-1,0);
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(MUL, PCregister, writeIO);
					}
					wait();
				}
				break;
			}
			case OIDIV:
			{
				if( flagRegister[11] != '1')
				{
					if(DebugON){
						cout << "*************DIV Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					Quo = regFileRdData1.to_uint() / regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, Quo);
					Rem = regFileRdData1.to_uint() % regFileRdData2.to_uint();;
					wrRegFile = SC_LOGIC_1;
					writeRegFile((rdOrrs1.to_uint() + 1), Rem);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(DIV, PCregister, writeIO);
					}
					wait();
				}
				else if(flagRegister[11] == '1')
				{
					if(DebugON){
						cout << "*************Shadow DIV Instruction************** " << "\n";
					}
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					Quo = regFileRdData1.to_uint() / regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					//tempWrite = multRes.range(N-1,0);
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, Quo);
					PCregister = PCregister.to_uint() + 1;
					if(DebugON){
						(*powModule).display(DIV, PCregister, writeIO);
					}
					wait();
				}
				break;
			}
			case OIns15:
			{
				switch(IR15.to_uint())
				{
					case COMP:
					{
						switch(IR9.to_bool())
						{	
							case CMR:
							{
								if(DebugON){
									cout << "*************CMR Instruction************** " << "\n";
								}
								readRegFile(rs1ADR, rdOrrs1);
								if (regFileRdData1.to_uint() > regFileRdData2.to_uint())
									flagRegister[5] = SC_LOGIC_1;
								else 
									flagRegister[5] = SC_LOGIC_0;
								flagRegister[4] = (regFileRdData1 == regFileRdData2)? sc_logic_1 : sc_logic_0;
								//cout << "flags is:   " << flagRegister << "\n";
								PCregister = PCregister.to_uint() + 1;
								if(DebugON){
									(*powModule).display(0x18, PCregister, writeIO);
								}
								wait();
								break;
							}
							case CMI: 
							{
								if(DebugON){
									cout << "*************CMI Instruction************** " << "\n";
								}
								readRegFile( rdOrrs1, rdOrrs1);
								signEximm = nBitSignExtension(imm, 4, true);
								if (regFileRdData1.to_uint() > signEximm.to_uint())
									flagRegister[5] = SC_LOGIC_1;
								else 
									flagRegister[5] = SC_LOGIC_0;
								flagRegister[4] = (regFileRdData1 == signEximm)? sc_logic_1 : sc_logic_0;
								//cout << "flags is:   " << flagRegister << "\n";
								PCregister = PCregister.to_uint() + 1;
								if(DebugON){
									(*powModule).display(0x19, PCregister, writeIO);
								}
								wait();
								break;
							}
							default:
								break;
						}
						break;
					}
					case BRANCH:
					{
						//cout << "Bool is   " <<  IR9.to_bool() << "\n";
						switch(IR9.to_bool())
						{
							case BRC: 
							{	
								if(DebugON){
									cout << "*************BRC Instruction************** " << "\n";
								}
								readRegFile( rdOrrs1, rdOrrs1);
								switch (RFI.to_uint())
								{
									case 0:
									{
										if(DebugON){
											cout << "Case 0" << "\n";
										}
										if (flagRegister[4] == 1)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x20, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 1:
									{
										if(DebugON){
											cout << "Case 1" << "\n";
										}
										if (flagRegister[5] == 0)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x20, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 2:
									{
										if(DebugON){
											cout << "Case 2" << "\n";
										}
										if (flagRegister[5] == 1)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x20, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 3:
									{
										if(DebugON){
											cout << "Case 3" << "\n";
										}
										if (flagRegister[4] == 1 || flagRegister[5] == 1)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x20, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 4:
									{
										if(DebugON){
											cout << "Case 4" << "\n";
										}
										if (flagRegister[4] == 1 || flagRegister[5] == 0)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x20, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 5:
									{
										if(DebugON){
											cout << "Case 5" << "\n";
										}
										if (flagRegister[4] == 0)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x20, PCregister, writeIO);
										}
										wait();
										break;
									}
									default:
										break;
								}
								break;
							}
							case BRR:
							{ 
								if(DebugON){
									cout << "*************BRR Instruction************** " << "\n";
								}
								readRegFile( rdOrrs1, rdOrrs1);
								switch (RFI.to_uint())
								{
									case 0:
									{	
										if(DebugON){
											cout << "Case 0 "<< "\n";
										}
										if (flagRegister[4] == 1)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x21, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 1:
									{	
										if(DebugON){
											cout << "Case 1" << "\n";
										}
										if (flagRegister[5] == 0)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x21, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 2:
									{	
										if(DebugON){
											cout << "Case 2" << "\n";
										}
										if (flagRegister[5] == 1)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x21, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 3:
									{	
										if(DebugON){
										cout << "Case 3" << "\n";
										}
										if (flagRegister[4] == 1 || flagRegister[5] == 1)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x21, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 4:
									{	if(DebugON){
										cout << "Case 4" << "\n";
										}
										if (flagRegister[4] == 1 || flagRegister[5] == 0)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x21, PCregister, writeIO);
										}
										wait();
										break;
									}
									case 5:
									{	
										if(DebugON){
											cout << "Case 5" << "\n";
										}
										if (flagRegister[4] == 0)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										if(DebugON){
											(*powModule).display(0x21, PCregister, writeIO);
										}
										wait();
										break;
									}
									default:
										break;
								}
								break;
							}
							default:
								break;
						}
						break;
					}
					case SHI:
					{
						if(DebugON){
						cout << "*************SHLogical Instruction************** " << "\n";
						}
						wrRegFile = SC_LOGIC_0;
						readRegFile( rdOrrs1, rdOrrs1);
						if (IR9.to_bool()== false)
							tempWrite = shiftFunction(IRregister.range(8,4),regFileRdData1, true);
						else if(IR9.to_bool() == true)
							tempWrite = shiftFunction(IRregister.range(8,4),regFileRdData1, false);
						wrRegFile = SC_LOGIC_1;
						//cout << "Temp write   " << tempWrite << endl;
						writeRegFile(rdOrrs1, tempWrite);
						PCregister = PCregister.to_uint() + 1;
						if(DebugON){
							(*powModule).display(0x22, PCregister, writeIO);
						}
						wait();
						break;
					}
					case NOT:
					{
						switch (IR9.to_bool())
						{
							case NTR: 
							{
								if(DebugON){
									cout << "*************NTR Instruction************** " << "\n";
								}
								wrRegFile = SC_LOGIC_0;
								readRegFile(rs2ADR, rs2ADR);
								complement = ~(regFileRdData2);
								tempWrite = (IRregister[8] == '1')? (complement.to_uint() + 1): complement;
								wrRegFile = SC_LOGIC_1;
								writeRegFile(rdOrrs1, tempWrite);
								PCregister = PCregister.to_uint() + 1;
								if(DebugON){
									(*powModule).display(0x23, PCregister, writeIO);
								}
								wait();
								break;
							}
							case NTD:
							{
								if(DebugON){
									cout << "*************NTD Instruction************** " << "\n";
								}
								wrRegFile = SC_LOGIC_0;
								readRegFile(rdOrrs1, rdOrrs1);
								complement = ~(regFileRdData1);
								tempWrite = (IRregister[8] == '1')? complement.to_uint() + 1: complement;
								wrRegFile = SC_LOGIC_1;
								writeRegFile(rdOrrs1, tempWrite);
								PCregister = PCregister.to_uint() + 1;
								if(DebugON){
									(*powModule).display(0x24, PCregister, writeIO);
								}
								wait();
								break;
							}
							default:
								break;
						}
						break;
					}
					default:
						break;
				}
				break;
			}
			default:
				break;
		}

	}
}
