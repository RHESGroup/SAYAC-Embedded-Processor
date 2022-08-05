#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

#include "systemc.h"
#include "utilities.h"


using namespace std;

#ifndef __FIM_H__
#define __FIM_H__

enum Faults { SA0, SA1, BitFlip, NoFault };


SC_MODULE(SC_MODULE_FAULTABLE) {
public:
	string testbenchId;
	string designId;
	string hardwareObjectId;
	sc_signal <bool> faultInjected;
	SC_MODULE_FAULTABLE() {}
};


const vector<string> getModuleName(SC_MODULE_FAULTABLE* regModule);

class faultProperty{
private:
	string testbenchId;
	string designId;
	string moduleId;
	int faultId;
	string objId;
	Faults faultType;
	bool enable;
public:
	faultProperty(){};
	faultProperty(string testbenchId, string designId, string moduleId, 
		string objId, int faultId, Faults faultType) 
			:moduleId{ moduleId }, objId{ objId }, faultId{ faultId }, faultType{ faultType }, enable(0) {}
	
	void setFaultProperty(string testbenchId, string designId, string moduleId, string objId, int faultId, Faults faultType){
		this->testbenchId = testbenchId; 
		this->designId = designId; 
		this->moduleId = moduleId; 
		this->objId = objId; 
		this->faultId = faultId; 
		this->faultType = faultType; 
		this->enable = 0;
	}
	string getTestbenchId(){ return testbenchId; }
	string getDesignId(){ return designId; }
	string getModuleId(){ return moduleId; }
	string getObjId(){return objId;}
	int getFaultId(){return faultId;}
	Faults getFaultType(){return faultType;}
	bool getEnable(){return enable;}
	void enableFault(){enable=1;}
	void disableFault(){enable=0;}
};


class faultRegistry {
private:
	vector <SC_MODULE_FAULTABLE*> moduleVector;
	vector <string> moduleIdVector;
	vector <faultProperty*> faultVector;
public:
	void registerModule(SC_MODULE_FAULTABLE* regModule);
	void registerFault(faultProperty* regFault);
	vector<vector<string>> readFaultList(ifstream& faultList);
	
	void saboteurOn(string testbenchId, string designId, string moduleId, string objId, Faults faultType); //search, find, enable
	void saboteurOff(string testbenchId, string designId, string moduleId, string objId, Faults faultType); //search, find, disable
	void injectFaultList(const vector<vector<string>>& faultList, int faultNumber);
	void removeFaultList(const vector<vector<string>>& faultList, int faultNumber);
	
	bool is_module_faulty(string testbenchId, string designId, string moduleId);
	bool is_object_faulty(string testbenchId, string designId, string moduleId, string objId);
	int getFaultId(string testbenchId, string designId, string moduleId, string objId, Faults faultType); //search, find, getFaultType
	Faults getObjectFaultType(string testbenchId, string designId, string moduleId, string objId); //search, find, if enabled getFaultType
	
	void infFaults();
	void disp_faultList(vector<vector<string>>& faultList);
	void infStuckAt();

	ofstream log_file;

};



#endif