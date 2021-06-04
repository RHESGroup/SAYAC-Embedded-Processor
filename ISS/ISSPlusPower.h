#include <iostream>
#include <systemc.h>

#define LDR_POW 25
#define STR_POW 23
#define JMR_POW 38
#define JMI_POW 37
#define ANR_POW 10
#define ANI_POW 9
#define MSI_POW 6
#define MHI_POW 6
#define SLR_POW 8
#define SAR_POW 8
#define ADR_POW 20
#define SUR_POW 20
#define ADI_POW 18
#define SUI_POW 18
#define MUL_POW 60
#define DIV_POW 60
#define CMR_POW 10
#define CMI_POW 9
#define BRC_POW 7
#define BRR_POW 24
#define SHI_POW 7
//#define SHA_POW 7
#define NTR_POW 5
#define NTD_POW 4

template <int N, int regFileAdrBit, int opcodeBit, int cyclesMDU>
SC_MODULE(sayacInstruction)
{
	sc_in <sc_logic> clk;
	sc_in <sc_logic> memReady;
	
	sc_in <sc_lv<N>> dataBus;
	sc_out <sc_lv<N>> dataBusOut;

	sc_out <sc_logic> readMem, writeMem;
	sc_out <sc_logic> readIO, writeIO;
	sc_out <sc_lv<N>> addrBus;

	int adrSpace;

	sc_lv <N> *regFile;
	
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

/*	enum I15_sh
	{
		SHL, SHA
	};
	*/
	enum I15_not
	{
		NTR, NTD
	};

	SC_CTOR(sayacInstruction)
	{
		adrSpace = int(pow(2,regFileAdrBit));
		regFile = new sc_lv<N>[adrSpace];

		SC_THREAD(abstractSimulation);
		sensitive << clk.pos();
	}

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
			cout << "[adr]   " << wrAd << endl;
			cout << "RegFile Write Data Is:  " << regFile[wrAd] << "Time :   " << sc_time_stamp()<< endl;		
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
	cout << "regFile p1:  " << regFileRdData1 << endl;
	cout << "regFile p2:  " << regFileRdData2 << endl;
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
	cout << "signEximm is:  "<< signEximmOut << endl;
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
			cout << "LOGICAL" << endl;
			cout << "ShiftNumber   " << shiftNumber[4] << endl;
			if (shiftNumber[4] == 1 )
			{
				result = input.to_uint() << shiftNumber.range(3,0).to_uint();
				cout << "LEFT SHIFT" << endl;
				cout << "input is  " << input.to_uint() << endl;
				cout << "Num is  " << shiftNumber.range(3,0).to_uint() << endl;
				cout << "Result is" << result << endl;
			}
			else if(shiftNumber[4] == 0)
			{
				result = input.to_uint() >> shiftNumber.range(3,0).to_uint();
				cout << "right SHIFT" << endl;

			}
			break;
		}
		case false:
		{
			cout << "False" << endl;
			if (shiftNumber[4] == 1 )
			{
				result = input.to_uint() << shiftNumber.range(3,0).to_uint();
			}
			else if(shiftNumber[4] == 0)
			{
				cout << "Positive" << endl;
				for (int i = N-1; i >= N-(shiftNumber.range(3,0).to_uint()); i-- )
				{
					result[i] = input[N-1];
					cout << "result[i]    " << result[i] << endl; 
				}
				result.range(N-(shiftNumber.range(3,0).to_uint())-1,0) = 
					input.range(N-1,shiftNumber.range(3,0).to_uint());
			}
		}
		default:
			break;
	}
	cout << "Result is   " << result << endl;
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
	//sc_lv<8> flags;
	sc_lv<3> RFI;
	sc_logic IR9;
	PCregister = 0x0000;

	while (true)
	{
		writeMem = SC_LOGIC_0;
		cout << "MEM Ready before  is: " << memReady << endl;
		while (memReady != '1')
		{
			readMem = SC_LOGIC_1;
			addrBus = PCregister;
			cout << "addrBus   " << addrBus << endl;
			wait();
		}
		cout << "MEM Ready before IR is:" << memReady << endl;
		IRregister = dataBus -> read();
		cout << "Ir IS:    " << IRregister << endl;

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
	//	cout << "opcode.to_uint()    " << opcode.to_uint() << endl;
		//cout << "ir9    "  << IR9  << "    ir9 char    " << IR9.to_char() << endl;
		addrBus.write('Z');// = "ZZZZZZZZZZZZZZZZ";

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
						cout << "**************Ldr Instruction************** " << endl;
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
						powerAccumulator = powerAccumulator.to_uint() + LDR_POW; 
						wait();
						break;
					}
					case STR:
					{
						cout << "**************STR Instruction************** " << endl;
						readRegFile( rdOrrs1, rs1ADR);
						ADRregister = regFileRdData1;
						wait();
					//	addrBus = ADRregister;
						if (IRregister[9] == '0')
						{
							while(memReady != '1')
							{
								cout << "MemReady != 1" << endl;
								writeMem = SC_LOGIC_1;
								addrBus = ADRregister;
								dataBusOut = regFileRdData2;
								wait();
							}
							cout << "memReady STR is" << memReady << endl;
						}
						else if(IRregister[9] == '1')
						{
							writeIO = SC_LOGIC_1;
							addrBus = ADRregister;
							dataBusOut = regFileRdData2;
							wait();
						}
						writeMem = SC_LOGIC_0;
						writeIO = SC_LOGIC_0;
						PCregister = PCregister.to_uint() + 1;
						powerAccumulator = powerAccumulator.to_uint() + STR_POW; 
						cout << "PC   " << PCregister << endl;
						wait();
						break;
					}
					case JMR:
					{
						cout << "**************JMR Instruction************** " << endl;
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
						powerAccumulator = powerAccumulator.to_uint() + JMR_POW; 
						wait();
						break;
					}
					case JMI:
					{
						cout << "**************JMI Instruction************** " << endl;
						wrRegFile = SC_LOGIC_0;
						signEximm = nBitSignExtension(imm, 5,true);
						tempPC = PCregister.to_uint() + signEximm.to_int();
						tempWrite = PCregister.to_uint() + 1;
						wrRegFile = SC_LOGIC_1;
						writeRegFile(rdOrrs1, tempWrite);
						PCregister = tempPC;
						powerAccumulator = powerAccumulator.to_uint() + JMI_POW; 
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
				cout << "**************ANR Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = regFileRdData1 & regFileRdData2;
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + ANR_POW; 
				wait();
				break;
			}
			case OIANI:  
			{
				if (flagRegister[15] != '1')
				{
					cout << "**************ANI Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					readRegFile( rdOrrs1, rdOrrs1);
					signEximm = nBitSignExtension(imm, 7, false);
					tempWrite = regFileRdData1 & signEximm;
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1,tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + ANI_POW; 
					wait();
				}
				else if(flagRegister[15] == '1')
				{
					cout << "**************Shadow ANI Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rdOrrs1);
					signEximm = nBitSignExtension(imm, 3, false);
					tempWrite = regFileRdData1 & signEximm;
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1,tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + ANI_POW; 
					wait();

				}
				break;
			}
			case OIMSI:
			{
				cout << "**************MSI Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				signEximm = nBitSignExtension(imm, 7, true);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1,signEximm);
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + MSI_POW; 
				wait();
				break;
			}
			case OIMHI:
			{
				cout << "**************MHI Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				readRegFile( rdOrrs1, rdOrrs1);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1,(imm,regFileRdData1.range(7,0)));
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + MHI_POW; 
				wait();
				break;
			}
			case OISLR:
			{
				cout << "**************SLR Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = shiftFunction(regFileRdData2.range(4,0),regFileRdData1, true);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + SLR_POW; 
				wait();
				break;
			}
			case OISAR:
			{
				cout << "**************SAR Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = shiftFunction(regFileRdData2.range(4,0),regFileRdData1, false);
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + SAR_POW; 
				wait();
				break;
			}
			case OIADR:
			{
				cout << "**************ADR Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = regFileRdData1.to_uint() + regFileRdData2.to_uint();
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + ADR_POW; 
				wait();
				break;
			}
			case OISUR: 
			{
				cout << "**************SUR Instruction************** " << endl;
				wrRegFile = SC_LOGIC_0;
				readRegFile( rs1ADR, rs2ADR);
				tempWrite = regFileRdData1.to_uint() - regFileRdData2.to_uint();
				wrRegFile = SC_LOGIC_1;
				writeRegFile(rdOrrs1, tempWrite);
				PCregister = PCregister.to_uint() + 1;
				powerAccumulator = powerAccumulator.to_uint() + SUR_POW; 
				wait();
				break;
			}
			case OIADI:
			{
				if( flagRegister[15] != '1')
				{
					cout << "**************ADI Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					//cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rdOrrs1, rdOrrs1);
					signEximm = nBitSignExtension(imm, 7, true);
					tempWrite = regFileRdData1.to_uint() + signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + ADI_POW; 
					wait();
					//cout << "PCregister Is:  " << PCregister << "   Time :   " << sc_time_stamp()<< endl;
				}
				else if( flagRegister[15] == '1')
				{
					cout << "**************Shadow ADI Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
				//	cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rs1ADR, rdOrrs1);
					signEximm = nBitSignExtension(imm, 3, true);
					tempWrite = regFileRdData1.to_uint() + signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + ADI_POW; 
					wait();
					//cout << "PCregister Is:  " << PCregister << "   Time :   " << sc_time_stamp()<< endl;
				}
				break;
			}
			case OISUI: 
			{
				if( flagRegister[15] != '1')
				{
					cout << "**************SUI Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					//cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rdOrrs1, rdOrrs1);
					signEximm = nBitSignExtension(imm, 7, true);
					tempWrite = regFileRdData1.to_uint() - signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + SUI_POW; 
					wait();
					//cout << "PCregister Is:  " << PCregister << "   Time :   " << sc_time_stamp()<< endl;
				}
				else if( flagRegister[15] == '1')
				{
					cout << "**************Shadow SUI Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					//cout << "Time :   " << sc_time_stamp()<<endl;
					readRegFile( rs1ADR, rdOrrs1);
					signEximm = nBitSignExtension(imm, 3, true);
					tempWrite = regFileRdData1.to_uint() - signEximm.to_int();
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + SUI_POW; 
					wait();
					//cout << "PCregister Is:  " << PCregister << "   Time :   " << sc_time_stamp()<< endl;
				}
				break;
			}
			case OIMUL: 
			{
				if( flagRegister[13] != '1')
				{
					cout << "**************MUL Instruction************** " << endl;
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
					powerAccumulator = powerAccumulator.to_uint() + MUL_POW; 
					wait();
				}
				else if( flagRegister[13] == '1' )
				{
					cout << "**************Shadow MUL Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					multRes = regFileRdData1.to_uint() * regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					tempWrite = multRes.range(N-1,0);
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, tempWrite);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + MUL_POW; 
					wait();
				}
				break;
			}
			case OIDIV:
			{
				if( flagRegister[11] != '1')
				{
					cout << "*************DIV Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					Quo = regFileRdData1.to_uint() / regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					///tempWrite = multRes.range(N-1,0);
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, Quo);
					Rem = regFileRdData1.to_uint() % regFileRdData2.to_uint();;
					//tempWrite = multRes.range(2*N-1,N);
					wrRegFile = SC_LOGIC_1;
					writeRegFile((rdOrrs1.to_uint() + 1), Rem);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + DIV_POW; 
					wait();
				}
				else if(flagRegister[11] == '1')
				{
					cout << "*************Shadow DIV Instruction************** " << endl;
					wrRegFile = SC_LOGIC_0;
					readRegFile( rs1ADR, rs2ADR);
					Quo = regFileRdData1.to_uint() / regFileRdData2.to_uint();
					for(int i = 0; i < cyclesMDU; i++)
						wait();
					//tempWrite = multRes.range(N-1,0);
					wrRegFile = SC_LOGIC_1;
					writeRegFile(rdOrrs1, Quo);
					PCregister = PCregister.to_uint() + 1;
					powerAccumulator = powerAccumulator.to_uint() + DIV_POW; 
					wait();
				}
				break;
			}
			case OIns15:
			{
				//cout << "IR15   " << IR15.to_uint() << endl;
				switch(IR15.to_uint())
				{
					case COMP:
					{
						switch(IR9.to_bool())
						{	
							case CMR:
							{
								cout << "*************CMR Instruction************** " << endl;
								readRegFile(rs1ADR, rdOrrs1);
								if (regFileRdData1.to_uint() > regFileRdData2.to_uint())
									flagRegister[5] = SC_LOGIC_1;
								else 
									flagRegister[5] = SC_LOGIC_0;
								flagRegister[4] = (regFileRdData1 == regFileRdData2)? sc_logic_1 : sc_logic_0;
								cout << "flags is:   " << flagRegister << endl;
								PCregister = PCregister.to_uint() + 1;
								powerAccumulator = powerAccumulator.to_uint() + CMR_POW; 
								wait();
								break;
							}
							case CMI: 
							{
								cout << "*************CMI Instruction************** " << endl;
								readRegFile( rdOrrs1, rdOrrs1);
								signEximm = nBitSignExtension(imm, 4, true);
								if (regFileRdData1.to_uint() > signEximm.to_uint())
									flagRegister[5] = SC_LOGIC_1;
								else 
									flagRegister[5] = SC_LOGIC_0;
								flagRegister[4] = (regFileRdData1 == signEximm)? sc_logic_1 : sc_logic_0;
								cout << "flags is:   " << flagRegister << endl;
								PCregister = PCregister.to_uint() + 1;
								powerAccumulator = powerAccumulator.to_uint() + CMI_POW; 
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
						//cout << "Bool is   " <<  IR9.to_bool() << endl;
						switch(IR9.to_bool())
						{
							case BRC: 
							{
								cout << "*************BRC Instruction************** " << endl;
								readRegFile( rdOrrs1, rdOrrs1);
								switch (RFI.to_uint())
								{
									case 0:
									{
										cout << "Case 0" << endl;
										if (flagRegister[4] == 1)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 1:
									{
										cout << "Case 1" << endl;
										if (flagRegister[5] == 0)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 2:
									{
										cout << "Case 2" << endl;
										if (flagRegister[5] == 1)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 3:
									{
										cout << "Case 3" << endl;
										if (flagRegister[4] == 1 || flagRegister[5] == 1)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 4:
									{
										cout << "Case 4" << endl;
										if (flagRegister[4] == 1 || flagRegister[5] == 0)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 5:
									{
										cout << "Case 5" << endl;
										if (flagRegister[4] == 0)
											PCregister = regFileRdData1;
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									default:
										break;
								}
								powerAccumulator = powerAccumulator.to_uint() + BRC_POW; 
								break;
							}
							case BRR:
							{ 
								cout << "*************BRR Instruction************** " << endl;
								readRegFile( rdOrrs1, rdOrrs1);
								switch (RFI.to_uint())
								{
									case 0:
									{
										cout << "Case 0 "<< endl;
										if (flagRegister[4] == 1)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 1:
									{
										cout << "Case 1" << endl;
										if (flagRegister[5] == 0)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 2:
									{
										cout << "Case 2" << endl;
										if (flagRegister[5] == 1)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 3:
									{
										cout << "Case 3" << endl;
										if (flagRegister[4] == 1 || flagRegister[5] == 1)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 4:
									{
										cout << "Case 4" << endl;
										if (flagRegister[4] == 1 || flagRegister[5] == 0)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
										wait();
										break;
									}
									case 5:
									{
										cout << "Case 5" << endl;
										if (flagRegister[4] == 0)
											PCregister = PCregister.to_uint() + regFileRdData1.to_uint();
										else
											PCregister = PCregister.to_uint() + 1;
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
						powerAccumulator = powerAccumulator.to_uint() + BRR_POW; 
						break;
					}
					case SHI:
					{
						//if (IR9.to_bool()== false)
						//{
							cout << "*************SHLogical Instruction************** " << endl;
							wrRegFile = SC_LOGIC_0;
							readRegFile( rdOrrs1, rdOrrs1);
							if (IR9.to_bool()== false)
								tempWrite = shiftFunction(IRregister.range(8,4),regFileRdData1, true);
							else if(IR9.to_bool() == true)
								tempWrite = shiftFunction(IRregister.range(8,4),regFileRdData1, false);
							wrRegFile = SC_LOGIC_1;
							cout << "Temp write   " << tempWrite << endl;
							writeRegFile(rdOrrs1, tempWrite);
							PCregister = PCregister.to_uint() + 1;
							wait();
						//}
					/*	else if(IR9.to_bool() == true)
						{
							cout << "*************SHA Instruction************** " << endl;
							wrRegFile = SC_LOGIC_0;
							readRegFile( rdOrrs1, rdOrrs1);
							tempWrite = shiftFunction(IRregister.range(8,4),regFileRdData1, false);
							wrRegFile = SC_LOGIC_1;
							writeRegFile(rdOrrs1, tempWrite);
							PCregister = PCregister.to_uint() + 1;
							wait();
						}*/
						powerAccumulator = powerAccumulator.to_uint() + SHI_POW; 
						break;
					}
					case NOT:
					{
						switch (IR9.to_bool())
						{
							case NTR: 
							{
								cout << "*************NTR Instruction************** " << endl;
								wrRegFile = SC_LOGIC_0;
								readRegFile(rs2ADR, rs2ADR);
								complement = ~(regFileRdData2);
								tempWrite = (IRregister[8] == '1')? (complement.to_uint() + 1): complement;
								wrRegFile = SC_LOGIC_1;
								writeRegFile(rdOrrs1, tempWrite);
								PCregister = PCregister.to_uint() + 1;
								powerAccumulator = powerAccumulator.to_uint() + NTR_POW; 
								wait();
								break;
							}
							case NTD:
							{
								cout << "*************NTD Instruction************** " << endl;
								wrRegFile = SC_LOGIC_0;
								readRegFile(rdOrrs1, rdOrrs1);
								complement = ~(regFileRdData1);
								tempWrite = (IRregister[8] == '1')? complement.to_uint() + 1: complement;
								wrRegFile = SC_LOGIC_1;
								writeRegFile(rdOrrs1, tempWrite);
								PCregister = PCregister.to_uint() + 1;
								powerAccumulator = powerAccumulator.to_uint() + NTD_POW; 
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