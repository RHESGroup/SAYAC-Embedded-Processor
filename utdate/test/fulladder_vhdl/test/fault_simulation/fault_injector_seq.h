#include "systemc.h"
#include <iostream>
#include <fstream>
#include <string>
#include "FIM.h"


using namespace sc_core;

template<int NumDFF, int SizePI, int SizePO>
SC_MODULE(fault_injector){

    sc_port<sc_signal_in_if<sc_logic>, 0, SC_ONE_OR_MORE_BOUND> input_ports;
    sc_port<sc_signal_inout_if<sc_logic>, 0, SC_ONE_OR_MORE_BOUND> output_ports;

    sc_lv<SizePO> PO;
    sc_lv<SizePI> PI;
    sc_lv<NumDFF> pre_expected_st, cur_expected_st, load_st, saved_st;
    sc_lv<SizePO> expected_PO, sampledPO;

    faultRegistry* accessRegistry;

	SC_HAS_PROCESS(fault_injector);
	fault_injector(sc_module_name _name, faultRegistry* accessRegistryIn){
        accessRegistry = accessRegistryIn;
        accessRegistry->log_file.open("flt.log");
        
        SC_THREAD(faultInjection);
    }

    void faultInjection(void){
        // Variable Definition ----------------------
        bool detected = false;
        bool flag = false;
        int numOfDetecteds = 0;
        int numOfFaults = 0;
        float coverage;
        ifstream faultFile;
        ifstream testFile;
        ofstream reportFile;

        vector<vector<string>> flist;
        vector<string> testVectors;
        
        sc_lv<SizePO + SizePI + (2 * NumDFF) > testData;

        //--- File Handling ----------------------
        faultFile.open("fault_list.flt");
        flist = accessRegistry->readFaultList(faultFile);
        faultFile.close();

        testFile.open("test_list_seq.txt");      
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
            cur_expected_st = 0;
            //--- report ----------------------
            reportFile << "TB---->faultNum = " << numOfFaults << " is injected @ " << sc_core::sc_time_stamp();
            
            detected = false;
            flag = false;
            
            // global_reset <= '1'; 
            output_ports[0]->write(SC_LOGIC_1);
			// WAIT UNTIL clk = '1';
            wait(input_ports[0]->posedge_event());
            // global_reset <= '0'; 
            output_ports[0]->write(SC_LOGIC_0);
            
            for(int j=0; ((j < testVectors.size()) && (!detected)); j++){
                
                pre_expected_st = cur_expected_st;
                
                // read one line of test list
                testData = str2logic<SizePO + SizePI + (2 * NumDFF)>(testVectors[j]);
                testData = testData.reverse();

                accessRegistry->log_file << "\n" << "---+++---+++---+++---+++" << std::endl;
                accessRegistry->log_file << "Apply Test Vector: " << testData << std::endl << std::endl;
                
                // sudo-primary input (dff state): should be shifted in
                load_st = (testData.range(NumDFF - 1, 0));
                accessRegistry->log_file << "\n" << "load_st(PPI) = " << load_st << std::endl;

				// PI <= testLine(numDFF+1 TO numDFF+sizePI);
                for (unsigned int k = 3; k < output_ports.size(); k++){
                    output_ports[k]->write(testData[NumDFF + (k - 3)]);
                }
                accessRegistry->log_file << "\n" << "PI = " << testData.range(NumDFF + (output_ports.size() - 4), NumDFF) << std::endl;

                // actual primary output
                // expected_PO = testLine(NumDFF+SizePI+1 TO NumDFF+SizePI+SizePO);
                expected_PO = testData.range((NumDFF+SizePI+SizePO) - 1, (NumDFF+SizePI));
                accessRegistry->log_file << "\n" << "expected_PO(PO) = " << expected_PO << std::endl;

                // sudo-primary input (dff state): should be shifted out
                cur_expected_st = testData.range((2*NumDFF+SizePI+SizePO) - 1, (NumDFF+SizePI+SizePO));
                accessRegistry->log_file << "\n" << "cur_expected_st(PPO) = " << cur_expected_st << std::endl;
                
				// NbarT <= '1';
                output_ports[1]->write(SC_LOGIC_1);
                for(int i = 0; i < NumDFF; i++){
					// Si	<=  load_st (index);
                    output_ports[2]->write(load_st[NumDFF - (i + 1)]);
                    accessRegistry->log_file << "\n" << "Si = " << load_st[NumDFF - (i + 1)] << std::endl;
                    wait(input_ports[0]->posedge_event());
                    saved_st[NumDFF - (i + 1)] = input_ports[2]->read();
                }

				// NbarT <= '0';
                output_ports[1]->write(SC_LOGIC_0);
				// WAIT UNTIL clk = '1';
                wait(input_ports[0]->posedge_event());

				// sampledPO := PO;
                for(int i = 3; i < input_ports.size(); i++){
                    // sampledPO[SizePO - (i - 3) - 1] = input_ports[i]->read();
                    sampledPO[(i - 3)] = input_ports[i]->read();
                }
                wait(SC_ZERO_TIME);
                
                sc_lv<NumDFF + SizePO> pre_expected_st_and_expected_PO, saved_st_and_sampledPO;
                pre_expected_st_and_expected_PO = (pre_expected_st, expected_PO);
                saved_st_and_sampledPO = (saved_st, sampledPO);
                accessRegistry->log_file << "\n" << "pre_expected_st_and_expected_PO = (pre_expected_st, expected_PO)" << std::endl;
                accessRegistry->log_file << pre_expected_st_and_expected_PO << " = " << pre_expected_st << " , " << expected_PO << std::endl;
                accessRegistry->log_file << "\n" << "saved_st_and_sampledPO = (saved_st, sampledPO)" << std::endl;
                accessRegistry->log_file << saved_st_and_sampledPO << " = " << saved_st << " , " << sampledPO << std::endl;

                if(!flag){
                    flag = true;
                    if(expected_PO != sampledPO){
                        detected = true;
                        reportFile << ", detected by testVector = " << testData.reverse() << " @ " << sc_core::sc_time_stamp() << std::endl;

                    }
                } else if ((pre_expected_st_and_expected_PO) != (saved_st_and_sampledPO)) {
                    detected = true;
                    reportFile << ", detected by testVector = " << testData.reverse() << " @ " << sc_core::sc_time_stamp() << std::endl;

                }
                
            }//--- endfor: testvectors
            if(!detected){
                // NbarT <= '1';
                output_ports[1]->write(SC_LOGIC_1);
                for(int i = 0; i < NumDFF; i++){
					// Si	<=  load_st (index);
                    output_ports[2]->write(load_st[NumDFF - (i + 1)]);
                    wait(input_ports[0]->posedge_event());
                    saved_st[NumDFF - (i + 1)] = input_ports[2]->read();
                }
                if(saved_st != cur_expected_st){
                    detected = true;
                    reportFile << ", detected by testVector = " << testData.reverse() << " @ " << sc_core::sc_time_stamp() << std::endl;
                }
            }
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