#include "systemc.h"
#include "FIM.h"
//SystemC Library
//Navabi Lab Group
//School of ECE, University of Tehran

// TODO: parametrize gates

#ifndef __COMPONENT_FLT_LIB_H__
#define __COMPONENT_FLT_LIB_H__

/////////////////////////////////////////////////////////////////////////////////////
//    Buf
/////////////////////////////////////////////////////////////////////////////////////

class bufg_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1;
	sc_out <sc_logic> out1;
	
	faultProperty faults[2];

	SC_HAS_PROCESS(bufg_flt);
	bufg_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        
		vector<string> full_name = getModuleName(this);
        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",1,SA0); //objId:1 for in1
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",2,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);

		SC_METHOD(prc_Original_bufg);
		sensitive << in1 << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_bufg(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			out1 = in1;
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1 = "  << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA0)
				out1 = SC_LOGIC_0;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA1)
				out1 = SC_LOGIC_1;
			else
				out1 = SC_LOGIC_X;
		}
	}
};

/////////////////////////////////////////////////////////////////////////////////////
//    Not
/////////////////////////////////////////////////////////////////////////////////////

class notg_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1;
	sc_out <sc_logic> out1;
	
	faultProperty faults[2];

	SC_HAS_PROCESS(notg_flt);
	notg_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		// - why would i call registerModule and get a an ID from it
		// 		i'm the lowest level of hierarchy, 
		// 		someone higher in the rank should ask me about myself right after I created as an object
		// - why should I have the access to alllll fault Registry system 
		//		I should only have the access to what's necessary for me, 
		//			like; is the fault applied to my ports, if yes, what is it??
		// - why should I set fault for myself, i'm not to decide somebody else should make that decision
		// - all I care (and use) is getObjectFaultType
		accessRegistry = accessRegistryIn;
        
		vector<string> full_name = getModuleName(this);
        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",1,SA0); //objId:1 for in1
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",2,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);

		SC_METHOD(prc_Original_notg);
		sensitive << in1 << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_notg(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			if (in1->read() == SC_LOGIC_1){
				out1->write(SC_LOGIC_0);
			} else if (in1->read() == SC_LOGIC_0){
				out1->write(SC_LOGIC_1);
			}
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1 = "  << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA0)
				out1 = SC_LOGIC_1;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA1)
				out1 = SC_LOGIC_0;
			else
				out1 = SC_LOGIC_X;
		}
	}
};

/////////////////////////////////////////////////////////////////////////////////////
//    And
/////////////////////////////////////////////////////////////////////////////////////

class and_n_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1[2];
	sc_out <sc_logic> out1;
	
	faultProperty faults[4];

	SC_HAS_PROCESS(and_n_flt);
	and_n_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        
		vector<string> full_name = getModuleName(this);
        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
        
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",1,SA0); //objId:1 for in1[0]
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",2,SA1);
		faults[2].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",3,SA0); //objId:2 for in1[1]
		faults[3].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",4,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
		accessRegistry->registerFault(&faults[2]);
		accessRegistry->registerFault(&faults[3]);

		SC_METHOD(prc_Original_and_n);
		sensitive << in1[0] << in1[1] << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_and_n(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			out1 = in1[0] & in1[1];
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1[0] = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") << " --- fault on in1[1] = " 
				<< accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0 || accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = SC_LOGIC_0;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1 
					&& accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = SC_LOGIC_1;
				
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1)
				out1 = SC_LOGIC_1 & in1[1];
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = in1[0] & SC_LOGIC_1;
			
			else
				out1 = SC_LOGIC_X;
		}
	}
};


/////////////////////////////////////////////////////////////////////////////////////
//    Or
/////////////////////////////////////////////////////////////////////////////////////

class or_n_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1[2];
	sc_out <sc_logic> out1;
	
	faultProperty faults[4];

	SC_HAS_PROCESS(or_n_flt);
	or_n_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        vector<string> full_name = getModuleName(this);

        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
        
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",1,SA0); //objId:1 for in1[0]
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",2,SA1);
		faults[2].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",3,SA0); //objId:2 for in1[1]
		faults[3].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",4,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
		accessRegistry->registerFault(&faults[2]);
		accessRegistry->registerFault(&faults[3]);

		SC_METHOD(prc_Original_or_n);
		sensitive << in1[0] << in1[1] << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_or_n(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			out1 = in1[0] | in1[1];
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1[0] = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") << " --- fault on in1[1] = " 
				<< accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") <<  " --- Time: " << sc_time_stamp() << std::endl;
		
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1 || accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = SC_LOGIC_1;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0 
					&& accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = SC_LOGIC_0;
				
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0)
				out1 = SC_LOGIC_0 | in1[1];
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = in1[0] | SC_LOGIC_0;
			
			else
				out1 = SC_LOGIC_X;
		}
	}
};



/////////////////////////////////////////////////////////////////////////////////////
//    Nand
/////////////////////////////////////////////////////////////////////////////////////

class nand_n_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1[2];
	sc_out <sc_logic> out1;
	
	faultProperty faults[4];

	SC_HAS_PROCESS(nand_n_flt);
	nand_n_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        vector<string> full_name = getModuleName(this);

        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",1,SA0); //objId:1 for in1[0]
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",2,SA1);
		faults[2].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",3,SA0); //objId:2 for in1[1]
		faults[3].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",4,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
		accessRegistry->registerFault(&faults[2]);
		accessRegistry->registerFault(&faults[3]);

		SC_METHOD(prc_Original_nand_n);
		sensitive << in1[0] << in1[1] << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_nand_n(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			if ((in1[0]->read() == SC_LOGIC_1) && (in1[1]->read() == SC_LOGIC_1)){
				out1->write(SC_LOGIC_0);
			} else {
				out1->write(SC_LOGIC_1);
			}
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1[0] = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") << " --- fault on in1[1] = " 
				<< accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0 || accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = SC_LOGIC_1;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1 
					&& accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = SC_LOGIC_0;
				
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1){

				if (in1[1]->read() == SC_LOGIC_1)
					out1 = SC_LOGIC_0;
				else
					out1 = SC_LOGIC_1;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1){
				if (in1[0]->read() == SC_LOGIC_1)
					out1 = SC_LOGIC_0;
				else
					out1 = SC_LOGIC_1;
			}
			else
				out1 = SC_LOGIC_X;
		}
	}
};

/////////////////////////////////////////////////////////////////////////////////////
//    Nor
/////////////////////////////////////////////////////////////////////////////////////

class nor_n_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1[2];
	sc_out <sc_logic> out1;
	
	faultProperty faults[4];

	SC_HAS_PROCESS(nor_n_flt);
	nor_n_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        vector<string> full_name = getModuleName(this);

        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
        
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",1,SA0); //objId:1 for in1[0]
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",2,SA1);
		faults[2].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",3,SA0); //objId:2 for in1[1]
		faults[3].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",4,SA1);
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
		accessRegistry->registerFault(&faults[2]);
		accessRegistry->registerFault(&faults[3]);

		SC_METHOD(prc_Original_nor_n);
		sensitive << in1[0] << in1[1] << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_nor_n(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			if ((in1[0]->read() == SC_LOGIC_0) && (in1[1]->read() == SC_LOGIC_0)){
				out1->write(SC_LOGIC_1);
			} else {
				out1->write(SC_LOGIC_0);
			}
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1[0] = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") << " --- fault on in1[1] = " 
				<< accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1 || accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = SC_LOGIC_0;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0 
					&& accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = SC_LOGIC_1;
				
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0){

				if (in1[1]->read() == SC_LOGIC_0)
					out1 = SC_LOGIC_1;
				else
					out1 = SC_LOGIC_0;
			}
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0){

				if (in1[0]->read() == SC_LOGIC_0)
					out1 = SC_LOGIC_1;
				else
					out1 = SC_LOGIC_0;
			}
			else
				out1 = SC_LOGIC_X;
		}
	}
};


/////////////////////////////////////////////////////////////////////////////////////
//    Xor
/////////////////////////////////////////////////////////////////////////////////////

class xor_n_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1[2];
	sc_out <sc_logic> out1;
	
	faultProperty faults[4];

	SC_HAS_PROCESS(xor_n_flt);
	xor_n_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        vector<string> full_name = getModuleName(this);

        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
        
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",1,SA0); //objId:1 for in1[0]
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",2,SA1);
		faults[2].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",3,SA0); //objId:2 for in1[1]
		faults[3].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",4,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
		accessRegistry->registerFault(&faults[2]);
		accessRegistry->registerFault(&faults[3]);

		SC_METHOD(prc_Original_xor_n);
		sensitive << in1[0] << in1[1] << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in1 the functionality
	void prc_Original_xor_n(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			if (in1[0]->read() == in1[1]->read()){
				out1->write(SC_LOGIC_1);
			} else {
				out1->write(SC_LOGIC_0);
			}
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1[0] = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") << " --- fault on in1[1] = " 
				<< accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1 && accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = SC_LOGIC_0;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0 
					&& accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = SC_LOGIC_0;
				
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0){
				if (in1[1]->read() == SC_LOGIC_0)
					out1 = SC_LOGIC_0;
				else
					out1 = SC_LOGIC_1;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0){
				if (in1[0]->read() == SC_LOGIC_0)
					out1 = SC_LOGIC_0;
				else
					out1 = SC_LOGIC_1;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1){
				if (in1[1]->read() == SC_LOGIC_1)
					out1 = SC_LOGIC_0;
				else
					out1 = SC_LOGIC_1;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1){
				if (in1[0]->read() == SC_LOGIC_1)
					out1 = SC_LOGIC_0;
				else
					out1 = SC_LOGIC_1;
			}
			
			else
				out1 = SC_LOGIC_X;
		}
	}
};


/////////////////////////////////////////////////////////////////////////////////////
//    Xnor
/////////////////////////////////////////////////////////////////////////////////////

class xnor_n_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1[2];
	sc_out <sc_logic> out1;
	
	faultProperty faults[4];

	SC_HAS_PROCESS(xnor_n_flt);
	xnor_n_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        vector<string> full_name = getModuleName(this);

        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
        
		
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",1,SA0); //objId:1 for in1[0]
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(0)",2,SA1);
		faults[2].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",3,SA0); //objId:2 for in1[1]
		faults[3].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1(1)",4,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
		accessRegistry->registerFault(&faults[2]);
		accessRegistry->registerFault(&faults[3]);

		SC_METHOD(prc_Original_xnor_n);
		sensitive << in1[0] << in1[1] << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in1 the functionality
	void prc_Original_xnor_n(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			if (in1[0]->read() == in1[1]->read()){
				out1->write(SC_LOGIC_0);
			} else {
				out1->write(SC_LOGIC_1);
			}
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1[0] = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") << " --- fault on in1[1] = " 
				<< accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1 && accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1)
				out1 = SC_LOGIC_1;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0 
					&& accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0)
				out1 = SC_LOGIC_1;
				
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA0){
				if (in1[1]->read() == SC_LOGIC_0)
					out1 = SC_LOGIC_1;
				else
					out1 = SC_LOGIC_0;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA0){
				if (in1[0]->read() == SC_LOGIC_0)
					out1 = SC_LOGIC_1;
				else
					out1 = SC_LOGIC_0;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(0)") == SA1){
				if (in1[1]->read() == SC_LOGIC_1)
					out1 = SC_LOGIC_1;
				else
					out1 = SC_LOGIC_0;
			}
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1(1)") == SA1){
				if (in1[0]->read() == SC_LOGIC_1)
					out1 = SC_LOGIC_1;
				else
					out1 = SC_LOGIC_0;
			}
			
			else
				out1 = SC_LOGIC_X;
		}
	}
};


/////////////////////////////////////////////////////////////////////////////////////
//    Primary Input      
/////////////////////////////////////////////////////////////////////////////////////

class pin_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1;
	sc_out <sc_logic> out1;
	
	faultProperty faults[2];

	SC_HAS_PROCESS(pin_flt);
	pin_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;
        
		vector<string> full_name = getModuleName(this);
        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",1,SA0); //objId:1 for in1
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",2,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);

		SC_METHOD(prc_Original_pin);
		sensitive << in1 << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_pin(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			out1 = in1;
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1 = "  << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA0)
				out1 = SC_LOGIC_0;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA1)
				out1 = SC_LOGIC_1;
			else
				out1 = SC_LOGIC_X;
		}
	}
};


/////////////////////////////////////////////////////////////////////////////////////
//    Primary Output      
/////////////////////////////////////////////////////////////////////////////////////

class pout_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
	sc_in <sc_logic> in1;
	sc_out <sc_logic> out1;
	
	faultProperty faults[2];

	SC_HAS_PROCESS(pout_flt);
	pout_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;

        vector<string> full_name = getModuleName(this);
        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",1,SA0); //objId:1 for in1
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"in1",2,SA1);
		
		accessRegistry->registerModule(this);
		
		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);

		SC_METHOD(prc_Original_pout);
		sensitive << in1 << faultInjected;
			dont_initialize();
	}

	// Incorporate faults in the functionality
	void prc_Original_pout(){
		
			
		if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
			out1 = in1;
		}
		else{	
			accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " in1 = "  << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") <<  " --- Time: " << sc_time_stamp() << std::endl;
			
			if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA0)
				out1 = SC_LOGIC_0;
			
			else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"in1") == SA1)
				out1 = SC_LOGIC_1;
			else
				out1 = SC_LOGIC_X;
		}
	}
};


/////////////////////////////////////////////////////////////////////////////////////
//    D Flip Flop 
/////////////////////////////////////////////////////////////////////////////////////

class dff_flt : public SC_MODULE_FAULTABLE {
protected:

	faultRegistry* accessRegistry;
	
public:
    sc_in<sc_logic> D, C, CLR, PRE, CE, NbarT, Si, global_reset;
    sc_out<sc_logic> Q;

    sc_signal<sc_logic, SC_MANY_WRITERS> val;

	faultProperty faults[2];

	SC_HAS_PROCESS(dff_flt);
	dff_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
		// Register itself and gets its unique ID
		accessRegistry = accessRegistryIn;

        vector<string> full_name = getModuleName(this);
        testbenchId = full_name[0];
        designId = full_name[1];
        hardwareObjectId = full_name[2];
        
		// Define faults
		faults[0].setFaultProperty(testbenchId, designId, hardwareObjectId,"D",1,SA0); //objId:1 for D
		faults[1].setFaultProperty(testbenchId, designId, hardwareObjectId,"D",2,SA1);
		
		accessRegistry->registerModule(this);

		// Register faults
		accessRegistry->registerFault(&faults[0]); 
		accessRegistry->registerFault(&faults[1]);
        
		SC_THREAD(eval);
            sensitive << val;
        SC_METHOD(faultable_set);
            sensitive << C;
			dont_initialize();
        SC_METHOD(reset);
            sensitive << CLR << global_reset;
        SC_METHOD(preset);
            sensitive << PRE;
	}


    void eval(void){
        while(true){
                Q->write(val.read());
            wait();
        }
    }
    
	void faultable_set(void){
		
		
        if ((C->read() == SC_LOGIC_1) && ((PRE->read() == SC_LOGIC_0) && (CLR->read() == SC_LOGIC_0 && global_reset->read() == SC_LOGIC_0))){
            if (NbarT->read() == SC_LOGIC_1) 
				val.write(Si->read());
            else if (CE->read() == SC_LOGIC_1){
				if (!(accessRegistry->is_module_faulty(testbenchId, designId, hardwareObjectId))){
					val.write(D->read());
				}
				else{
					accessRegistry->log_file << "fault on " << testbenchId << "." << designId << "." << hardwareObjectId << " D = " << accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"D") << " --- Time: " << sc_time_stamp() << std::endl;

					if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"D") == SA0)
						val.write(SC_LOGIC_0);
					else if (accessRegistry->getObjectFaultType(testbenchId, designId, hardwareObjectId,"D") == SA1)
						val.write(SC_LOGIC_1);
				} 
			// END ELSE IF
        	}
		// END IF 
    	}
	// END FUNCTION: faultable_set
	}

    void reset(void){
        if (CLR->read() == SC_LOGIC_1 || global_reset->read() == SC_LOGIC_1) val.write(SC_LOGIC_0);
    }

    void preset(void){
        if ((PRE->read() == SC_LOGIC_1) && (CLR->read() == SC_LOGIC_0 && global_reset->read() == SC_LOGIC_0)) val.write(SC_LOGIC_1);
    }
};

/////////////////////////////////////////////////////////////////////////////////////
//    D Flip Flop: DFF_NP0_flt
/////////////////////////////////////////////////////////////////////////////////////
class DFF_NP0_flt : public SC_MODULE_FAULTABLE {
public:
    sc_in<sc_logic> D, C, R;
    sc_out<sc_logic> Q;

    sc_signal<sc_logic, SC_MANY_WRITERS> val;
    // sc_signal<sc_logic> val;

    // sc_time tphl; 
    // sc_time tplh;

    SC_HAS_PROCESS(DFF_NP0_flt);
	DFF_NP0_flt(sc_module_name _name, faultRegistry* accessRegistryIn){

        SC_THREAD(eval);
            sensitive << val;
        SC_METHOD(set);
            sensitive << C;
        SC_METHOD(reset);
            sensitive << R;
    }

    void eval(void){
        while(true){
                Q->write(val.read());
            wait();
        }
    }
    void set(void){
        if ((C->read() == SC_LOGIC_0) && (R->read() == SC_LOGIC_0)){
            val.write(D->read());
        }
    }

    void reset(void){
        if (R->read() == SC_LOGIC_1) val.write(SC_LOGIC_0);
    }

};

/////////////////////////////////////////////////////////////////////////////////////
//    D Flip Flop: DFF_NP1_flt
/////////////////////////////////////////////////////////////////////////////////////
class DFF_NP1_flt : public SC_MODULE_FAULTABLE {
public:
    sc_in<sc_logic> D, C, R;
    sc_out<sc_logic> Q;

    sc_signal<sc_logic, SC_MANY_WRITERS> val;
    // sc_signal<sc_logic> val;

    // sc_time tphl; 
    // sc_time tplh;

    SC_HAS_PROCESS(DFF_NP1_flt);
	DFF_NP1_flt(sc_module_name _name, faultRegistry* accessRegistryIn){
    // DFlipFlop(sc_module_name _name, sc_time tphl, sc_time tplh) 
    // : sc_module(_name), tphl(tphl), tplh(tplh) {

        SC_THREAD(eval);
            sensitive << val;
        SC_METHOD(set);
            sensitive << C;
        SC_METHOD(reset);
            sensitive << R;
    }

    void eval(void){
        while(true){
                Q->write(val.read());
            wait();
        }
    }
    void set(void){
        if ((C->read() == SC_LOGIC_0) && (R->read() == SC_LOGIC_0)){
            val.write(D->read());
        }
    }

    void reset(void){
        if (R->read() == SC_LOGIC_1) val.write(SC_LOGIC_1);
    }

};

#endif


