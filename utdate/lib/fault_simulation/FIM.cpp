#include "FIM.h"

using namespace std;


const vector<string> getModuleName(SC_MODULE_FAULTABLE* regModule){
	string full_name;
	vector<string> name;

	full_name = regModule->name();

	// convert string to stringstream to use stream properties (here getline)
	stringstream sstream(full_name);
	string tempString;
	while(getline(sstream, tempString, '.')){
		name.push_back(tempString);
	}

	// this->log_file << "+++ Module name: ----" << std::endl;
	// for(vector<string>::iterator it = name.begin(); it != name.end(); it++){
	// 	this->log_file << (*it) << std::endl;
	// }
	// this->log_file << "+++ getmodule name ends: ----" << std::endl;
	
	return name;
}


void faultRegistry::registerModule(SC_MODULE_FAULTABLE* regModule) {
	moduleVector.push_back(regModule);
	string hierarchical_name = regModule->testbenchId + "." + regModule->designId + "." + regModule->hardwareObjectId;
	this->log_file << "++ Registered Module: " << hierarchical_name << std::endl;
	moduleIdVector.push_back(hierarchical_name);
}

void faultRegistry::registerFault(faultProperty* regFault) {
	faultVector.push_back(regFault);
}


vector<vector<string>> faultRegistry::readFaultList(ifstream& faultList){

    vector<vector<string>> complete_flist;
    
    while(faultList){
        string line;

        getline(faultList, line);

        // create vector of string to save each token
        vector<string> fault_prop;
        // convert strin to stringstream to use stream properties (here getline)
        stringstream sstream(line);
        string tempString;

        while(getline(sstream, tempString, '/')){
            fault_prop.push_back(tempString);
        }
        
        // on the last round, right before EOF break the loop (otherwise raises seg. fault)
        if(!faultList){
            break;
        }
        // convert "one" char to string
        string str2c(1, fault_prop.back().back());
        fault_prop.push_back(str2c);
        
        // remove two last char (fault value + white space)
        fault_prop[fault_prop.size() - 2].pop_back();
        fault_prop[fault_prop.size() - 2].pop_back();

        complete_flist.push_back(fault_prop);
    }
	return complete_flist;
}


void faultRegistry::saboteurOn(string testbenchId, string designId, string moduleId, string objId, Faults faultType){
	for(int i=0; i<faultVector.size(); i++){
		if((faultVector[i]->getTestbenchId() == testbenchId) && (faultVector[i]->getDesignId() == designId) && 
			(faultVector[i]->getModuleId() == moduleId) && (faultVector[i]->getObjId() == objId) && 
			(faultVector[i]->getFaultType() == faultType)){
			
			faultVector[i]->enableFault();	//Activate fault

			// this->log_file << "faultVector of " << std::endl;
			// this->log_file << faultVector[i]->getTestbenchId() <<  " = " << testbenchId << std::endl;
			// this->log_file << faultVector[i]->getDesignId() <<  " = " << designId << std::endl;
			// this->log_file << faultVector[i]->getModuleId() <<  " = " << moduleId << std::endl;
			// this->log_file << faultVector[i]->getObjId() <<  " = " << objId << std::endl;
			// this->log_file << faultVector[i]->getFaultType() <<  " = " << faultType << std::endl;
			// this->log_file << "enabled ----------------------- " << std::endl;


		}
	}
	
	string hierarchical_name = testbenchId + "." + designId + "." + moduleId;	
	
	for (int j=0; j<moduleIdVector.size(); j++){
		if(moduleIdVector[j] == hierarchical_name){

			this->log_file << "## enable faultInjected signal on module:: ";
			moduleVector[j]->faultInjected.write(true); // Inject fault
			// this->log_file << hierarchical_name << std::endl;
			this->log_file << moduleIdVector[j] << std::endl;
			// this->log_file << moduleVector[j]->hardwareObjectId << std::endl;
		}

	}
}

void faultRegistry::saboteurOff(string testbenchId, string designId, string moduleId, string objId, Faults faultType){
	for(int i=0; i<faultVector.size(); i++){
		if((faultVector[i]->getTestbenchId() == testbenchId) && (faultVector[i]->getDesignId() == designId) && 
			(faultVector[i]->getModuleId() == moduleId) && (faultVector[i]->getObjId() == objId) && 
			(faultVector[i]->getFaultType() == faultType)){
			
			faultVector[i]->disableFault();
		}
	}

	string hierarchical_name = testbenchId + "." + designId + "." + moduleId;	
	for (int j=0; j<moduleIdVector.size(); j++){
		if(moduleIdVector[j] == hierarchical_name)
			moduleVector[j]->faultInjected.write(false); // deactivate fault
	}	
}

void faultRegistry::injectFaultList(const vector<vector<string>>& faultList, int faultNumber){
	
	// { testbench, dut, module, obj, fault_type }
	string fault_properties[5];

	const string fault_p_title[] = {
		"testbench | ",
		"dut       | ",
		"module    | ",
		"obj       | ",
		"faultType | "
	};

	if(faultNumber <= faultList.size()){
		this->log_file << "Fault to be Injected: " << std::endl;
		this->log_file << "----------|-------------- " << std::endl;
		if(faultNumber == 0){ // if (fualtNumber == 0) inject all faults
			// traverse each line (fault)
			for(int i=0; i < faultList.size(); i++){
				// traverse fault properties
				for(int j=0; j < faultList[i].size(); j++){
					fault_properties[j] = faultList[i][j];
					this->log_file << fault_p_title[j] << fault_properties[j] << std::endl;
				}

				if(fault_properties[4] == "0")
					this->saboteurOn(fault_properties[0], fault_properties[1], fault_properties[2], fault_properties[3],SA0);
				if(fault_properties[4] == "1")
					this->saboteurOn(fault_properties[0], fault_properties[1], fault_properties[2], fault_properties[3],SA1);
			}
		} else { // if ( 0 < faultNumber < faultList.size() ) inject one specific fault
			// traverse fault properties
			for(int j=0; j < faultList[faultNumber - 1].size(); j++){
				fault_properties[j] = faultList[faultNumber - 1][j];
				this->log_file << fault_p_title[j] << fault_properties[j] << std::endl;
			}

			if(fault_properties[4] == "0")
				this->saboteurOn(fault_properties[0], fault_properties[1], fault_properties[2], fault_properties[3],SA0);
			if(fault_properties[4] == "1")
				this->saboteurOn(fault_properties[0], fault_properties[1], fault_properties[2], fault_properties[3],SA1);
		}
	} else { // if fault number is greater than fault list range
		this->log_file << "OUT OF RANGE ERROR: number exceeds range of fault list" << std::endl;
	}
}

void faultRegistry::removeFaultList(const vector<vector<string>>& faultList, int faultNumber){
	
	// { testbench, dut, module, obj, fault_type }
	string fault_properties[5];

	const string fault_p_title[] = {
		"testbench | ",
		"dut       | ",
		"module    | ",
		"obj       | ",
		"faultType | "
	};

	if(faultNumber <= faultList.size()){
		this->log_file << "Fault to be removed: " << std::endl;
		this->log_file << "----------|-------------- " << std::endl;
		if(faultNumber == 0){ // if (fualtNumber == 0) inject all faults
			// traverse each line (fault)
			for(int i=0; i < faultList.size(); i++){
				// traverse fault properties
				for(int j=0; j < faultList[i].size(); j++){
					fault_properties[j] = faultList[i][j];
					this->log_file << fault_p_title[j] << fault_properties[j] << std::endl;
				}

				if(fault_properties[4] == "0")
					this->saboteurOff(fault_properties[0], fault_properties[1], fault_properties[2],fault_properties[3],SA0);
				if(fault_properties[4] == "1")
					this->saboteurOff(fault_properties[0], fault_properties[1], fault_properties[2],fault_properties[3],SA1);
			}
		} else { // if ( 0 < faultNumber < faultList.size() ) inject one specific fault
			// traverse fault properties
			for(int j=0; j < faultList[faultNumber - 1].size(); j++){
				fault_properties[j] = faultList[faultNumber - 1][j];
				this->log_file << fault_p_title[j] << fault_properties[j] << std::endl;
			}

			if(fault_properties[4] == "0")
				this->saboteurOff(fault_properties[0], fault_properties[1], fault_properties[2],fault_properties[3],SA0);
			if(fault_properties[4] == "1")
				this->saboteurOff(fault_properties[0], fault_properties[1], fault_properties[2],fault_properties[3],SA1);
		}
	} else { // if fault number is greater than fault list range
		this->log_file << "OUT OF RANGE ERROR: number exceeds range of fault list" << std::endl;
	}
}


bool faultRegistry::is_module_faulty(string testbenchId, string designId, string moduleId){
	bool fault_enable = false;

	for(int i=0; i<faultVector.size(); i++){
			if((faultVector[i]->getTestbenchId() == testbenchId) && (faultVector[i]->getDesignId() == designId) && 
				(faultVector[i]->getModuleId() == moduleId)){

					fault_enable = fault_enable || faultVector[i]->getEnable();
				}
	}	
	return fault_enable;
}

bool faultRegistry::is_object_faulty(string testbenchId, string designId, string moduleId, string objId){
	bool fault_enable = false;

	for(int i=0; i<faultVector.size(); i++){
			if((faultVector[i]->getTestbenchId() == testbenchId) && (faultVector[i]->getDesignId() == designId) && 
				(faultVector[i]->getModuleId() == moduleId) && (faultVector[i]->getObjId() == objId)){

					fault_enable = fault_enable || faultVector[i]->getEnable();
				}
	}	
	return fault_enable;
}
int faultRegistry::getFaultId(string testbenchId, string designId, string moduleId, string objId, Faults faultType){
	for(int i=0; i<faultVector.size(); i++){
		if((faultVector[i]->getTestbenchId() == testbenchId) && (faultVector[i]->getDesignId() == designId) && 
			(faultVector[i]->getModuleId() == moduleId) && (faultVector[i]->getObjId() == objId) && 
			(faultVector[i]->getFaultType() == faultType)){
				return faultVector[i]->getFaultId();

			}
	}
	return NoFault;
}

Faults faultRegistry::getObjectFaultType(string testbenchId, string designId, string moduleId, string objId){
	for(int i=0; i<faultVector.size(); i++){
		if((faultVector[i]->getTestbenchId() == testbenchId) && (faultVector[i]->getDesignId() == designId) && 
			(faultVector[i]->getModuleId() == moduleId) && (faultVector[i]->getObjId() == objId) && (faultVector[i]->getEnable() == true)){
				return faultVector[i]->getFaultType();
			}
	}
	return NoFault;
}


void faultRegistry::infFaults(){
	this->log_file << std::endl;
	this->log_file << "Registered fault objects" << std::endl;
	this->log_file << "Total number of faultable objects: " << faultVector.size() << std::endl;
	this->log_file << "+++----+++----+++----+++----+++" << std::endl;
	for(int i=0; i<faultVector.size(); i++){
		this->log_file << "Faulty object: #" << i << std::endl; 
		this->log_file << "-------------------------------" << std::endl;
		this->log_file << "getTestbenchId | " << faultVector[i]->getTestbenchId()  << std::endl
		<< 		 	 "getDesignId    | " << faultVector[i]->getDesignId()  << std::endl
		<< 		 	 "moduleId       | " << faultVector[i]->getModuleId()  << std::endl
		<< 		 	 "objId          | " << faultVector[i]->getObjId()  << std::endl
		<< 		 	 "faultId        | " << faultVector[i]->getFaultId() << std::endl
		<< 		 	 "type           | " << faultVector[i]->getFaultType()  << std::endl
		<< 		 	 "enable         | " << faultVector[i]->getEnable() << std::endl;
		this->log_file << std::endl;
	}
	this->log_file << "-----------------------------" << std::endl;
}

void faultRegistry::infStuckAt(){
	for (int i = 0; i < faultVector.size(); i++){
		if (faultVector[i]->getFaultType() == SA0 || faultVector[i]->getFaultType() == SA1){
			cout << "moduleId:" << faultVector[i]->getModuleId()
				<< " objId:" << faultVector[i]->getObjId()
				<< " faultId:" << faultVector[i]->getFaultId()
				<< " type:" << faultVector[i]->getFaultType()
				<< " enable:" << faultVector[i]->getEnable()
				<< endl;
		}
	}
}

void faultRegistry::disp_faultList(vector<vector<string>>& faultList){
    for(int i = 0; i < faultList.size(); i++){

        this->log_file << "On line " << i << " of fault list there is fault with description below: " << std::endl;

		int j = 0;
		const string prop_name[] = {
			"@ testbench: ",
			"@ design under test: ",
			"@ module name: ",
			"@ port name: ",
            "@ stuck at value: "
			};
        for(vector<string>::iterator it = faultList[i].begin(); it != faultList[i].end(); it++){
            this->log_file << prop_name[j] << (*it) << std::endl;
			j++;
        }
    }
}