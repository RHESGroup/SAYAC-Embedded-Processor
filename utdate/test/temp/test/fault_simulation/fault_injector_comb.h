#include "systemc.h"
#include <iostream>
#include <fstream>
#include <string>
#include "FIM.h"


using namespace sc_core;

SC_MODULE(fault_injector){

    sc_port<sc_signal_in_if<sc_logic>, 0, SC_ONE_OR_MORE_BOUND> input_ports;
    sc_port<sc_signal_inout_if<sc_logic>, 0, SC_ONE_OR_MORE_BOUND> output_ports;

    faultRegistry* accessRegistry;

    // SC_CTOR(fault_injector){
	SC_HAS_PROCESS(fault_injector);
	fault_injector(sc_module_name _name, faultRegistry* accessRegistryIn){
        accessRegistry = accessRegistryIn;
        accessRegistry->log_file.open("flt.log");
        
        SC_THREAD(faultInjection);
    }

    void faultInjection(void){
        // Variable Definition ----------------------
        bool detected = false;
        int numOfDetecteds = 0;
        int numOfFaults = 0;
        float coverage;
        
        ifstream faultFile;
        ifstream testFile;
        ofstream reportFile;

        vector<vector<string>> flist;
        vector<string> testVectors;
        
        sc_lv<3> testData;

        //--- File Handling ----------------------
        faultFile.open("fault_list.flt");
        flist = accessRegistry->readFaultList(faultFile);
        faultFile.close();

        testFile.open("test_list_comb.txt");      
        while(testFile){
            string line;

            getline(testFile, line);

            if(!testFile){
                break;
            }
            
            testVectors.push_back(line);
        }
        testFile.close();

        reportFile.open("reportFile.txt");
        
        accessRegistry->log_file << "* Initially Disable all faults " << std::endl;
        accessRegistry->removeFaultList(flist, 0);
        accessRegistry->infFaults();

        //--- Outer loop to inject fault ----------------------
        for(int i=1; i <= flist.size(); i++){
            accessRegistry->log_file << "--------- Inject Fault:--------------------- NUMBER:" << i << std::endl;
            accessRegistry->injectFaultList(flist, i);
            numOfFaults++;

            //--- report ----------------------
            reportFile << "TB---->faultNum = " << numOfFaults << " is injected @ " << sc_core::sc_time_stamp();
            detected = false;
            for(int j=0; ((j < testVectors.size()) && (!detected)); j++){
                testData = str2logic<3>(testVectors[j]);
                accessRegistry->log_file << "\n" << "---+++---+++---+++---+++" << std::endl;
                accessRegistry->log_file << "Apply Test Vector: " << testData << std::endl << std::endl;
                
                // Apply Test Vector to signals
                for (unsigned int k = 0; k < output_ports.size(); k++){
                    output_ports[k]->write(testData[k]);
                }
                // ci.write(testData[0]);
                // i1.write(testData[1]);
                // i0.write(testData[2]);

                wait(2, SC_NS);
                accessRegistry->log_file << "++ Simulation result " << std::endl;
                accessRegistry->log_file << " gold vs faulty " << std::endl;
                accessRegistry->log_file << " -------------- " << std::endl;
                accessRegistry->log_file << "        |       " << std::endl;
                for (unsigned int p = 0; p < input_ports.size(); p = p + 2){
                    accessRegistry->log_file << "    " << input_ports[p]->read() << "   |    " << input_ports[p + 1]->read() << std::endl;
                }
                accessRegistry->log_file << std::endl;

                //--- if outputs are not matched 
                for (unsigned int p = 0; p < input_ports.size(); p = p + 2){
                    
                    if(input_ports[p]->read() != input_ports[p + 1]->read()){
                        detected = true;
                        accessRegistry->log_file << "******* Fault has been detected ********" << std::endl;
                        accessRegistry->log_file << std::endl;
                        //--- write report ----------------------
                        reportFile << ", detected by testVector = " << testData << " @ " << sc_core::sc_time_stamp() << std::endl;
                        break;
                    } //--- endif: test detected the fault
                    
                }
                
            }//--- endfor: testvectors
            if(detected)
                numOfDetecteds++;
            
            accessRegistry->removeFaultList(flist, i); 
            wait(SC_ZERO_TIME);
            accessRegistry->log_file << "--------- Remove Fault:--------------------- NUMBER:" << i << std::endl << std::endl;

        }//--- endfor: faultlist


        //--- calculate coverage ----------------------
        coverage = (numOfDetecteds / numOfFaults);

        //--- write report ----------------------
        reportFile << "numOfDetecteds: " << numOfDetecteds << std::endl;
        reportFile << "numOfFaults: " << numOfFaults << std::endl;
        reportFile << "coverage: " << coverage << std::endl;

        //--- close report file ----------------------
        reportFile.close();

        accessRegistry->log_file << "+ End of faultInjection::---------------------------  " << std::endl;
        accessRegistry->log_file.close();
    }
};