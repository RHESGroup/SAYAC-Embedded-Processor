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
#define NTR_POW 5
#define NTD_POW 4

enum instructions
{
	RSV0, RSV1, 
	LDR, STR,
	JMR, JMI,
	ANR, ANI,  
	MSI, MHI,
	SLR, SAR,   
	ADR, SUR, 
	ADI, SUI, 
	MUL, DIV,
	CMR, CMI, 
	BRC, BRR,
	SHI, 
	NTR, NTD,
};

SC_MODULE(powerM)
{
public:

	sc_lv <16> powerAccumulator;
	
	SC_HAS_PROCESS(powerM);

	powerM::powerM(sc_module_name)
	{
		SC_METHOD(init);
	}
	powerM(){};

	void init();

	sc_lv<16>  powerCalculator(int inst);
	void display(int inst);



};

void powerM::init()
{
	powerAccumulator = 0x0;
	cout << "Init pow is done" << endl;
}

sc_lv<16> powerM::powerCalculator(int inst)
{
	switch (inst)
	{
		case RSV0:
		{
			powerAccumulator = powerAccumulator.to_uint();
			break;
		}
		case RSV1:
		{
			powerAccumulator = powerAccumulator.to_uint();
			break;
		}
		case LDR:
		{
			powerAccumulator = powerAccumulator.to_uint() + LDR_POW;
			break;
		}
		case STR:
		{
			powerAccumulator = powerAccumulator.to_uint() + STR_POW;
			break;
		}
		case JMR:
		{
			powerAccumulator = powerAccumulator.to_uint() + JMR_POW;
			break;
		}
		case JMI:
		{
			powerAccumulator = powerAccumulator.to_uint() + JMI_POW;
			break;
		}
		case ANR:
		{
			powerAccumulator = powerAccumulator.to_uint() + ANR_POW;
			break;
		}
		case ANI:  
		{
			powerAccumulator = powerAccumulator.to_uint() + ANI_POW;
			break;
		}
		case MSI:
		{
			powerAccumulator = powerAccumulator.to_uint() + MSI_POW;
			break;
		}
		case MHI:
		{
			powerAccumulator = powerAccumulator.to_uint() + MHI_POW;
			break;
		}
		case SLR: 
		{
			powerAccumulator = powerAccumulator.to_uint() + SLR_POW;
			break;
		}
		case SAR:
		{
			powerAccumulator = powerAccumulator.to_uint() + SAR_POW;
			break;
		}
		case ADR:
		{
			powerAccumulator = powerAccumulator.to_uint() + ADR_POW;
			break;
		}
		case SUR:
		{
			powerAccumulator = powerAccumulator.to_uint() + SUR_POW;
			break;
		}
		case ADI:
		{
			powerAccumulator = powerAccumulator.to_uint() + ADI_POW;
			break;
		}
		case SUI:
		{
			powerAccumulator = powerAccumulator.to_uint() + SUI_POW;
			break;
		}
		case MUL:
		{
			powerAccumulator = powerAccumulator.to_uint() + MUL_POW;
			break;
		}
		case DIV:
		{
			powerAccumulator = powerAccumulator.to_uint() + DIV_POW;
			break;
		}
		case CMR:
		{
			powerAccumulator = powerAccumulator.to_uint() + CMR_POW;
			break;
		}
		case CMI:
		{
			powerAccumulator = powerAccumulator.to_uint() + CMI_POW;
			break;
		}
		case BRC:
		{
			powerAccumulator = powerAccumulator.to_uint() + BRC_POW;
			break;
		}
		case BRR:
		{
			powerAccumulator = powerAccumulator.to_uint() + BRR_POW;
			break;
		}
		case SHI:
		{
			powerAccumulator = powerAccumulator.to_uint() + SHI_POW;
			break;
		}
		case NTR:
		{
			powerAccumulator = powerAccumulator.to_uint() + NTR_POW;
			break;
		}
		case NTD:
		{
			powerAccumulator = powerAccumulator.to_uint() + NTD_POW;
			break;
		}
		default:
			break;
	}
	return powerAccumulator;
}
void powerM::display(int inst)
{
	sc_lv <16> powerAcc;
	powerAcc = powerCalculator (inst);
	cout << "Power is:  " << powerAcc << endl;
}