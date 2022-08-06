#include <iostream>
#include <systemc.h>
//#include "InstructionTest.h"
#include "systemTest.h"
#include <stdio.h>
#include <unistd.h>

void SoftwareUserInterface(systemTest * TOP);

int sc_main(int argc, char *argv[])
{
	
	sc_report_handler::set_actions (SC_ID_VECTOR_CONTAINS_LOGIC_VALUE_,
                                SC_DO_NOTHING);
	sc_report_handler::set_actions (SC_WARNING, SC_DO_NOTHING);


	systemTest * TOP = new systemTest ("systemTest_TB");
	sc_trace_file* VCDFile;
	VCDFile = sc_create_vcd_trace_file("system_Main");
	sc_trace(VCDFile, TOP -> clk, "clk");
	
	SoftwareUserInterface(TOP);
	
	return 0;
}


void SoftwareUserInterface(systemTest * TOP){
	
	int exit = 0;
	int DebugON = 0;
	int Loading = 0;
	int StartingLocation_ = 0;
	int PuttingData = 0;
	
	std::string cmnd, temp_cmnd;
	
	std::string arg;
	std::string file;
	std::string comm;
	
	
	cout<<"Welcome to SAYAC system software user interface\n"<<endl;
	
	while(!exit){
		cout<<"SUI>> please enter your command ";
		getline(cin,cmnd);
		
		size_t Debug = cmnd.find("-dbg");
		size_t LoadMEM = cmnd.find("-ldm");
		size_t StartingLocation = cmnd.find("-stl");
		size_t GenerateDataFile = cmnd.find("-gdf");
		size_t WriteMEM = cmnd.find("-wdm");
		size_t Run = cmnd.find("-run");
		size_t Exit = cmnd.find("-ext");
		size_t arguman = cmnd.find(" -");
		size_t txt, asm_; 
		size_t space;
	
		
		temp_cmnd = cmnd;
		
		////////            Help
		if(cmnd == "-hlp"){
			cout<<"\nSUI>> hlp>> ";
			cout<<"Valid commands:\n       -dbg       -ldm       -stl\n       -gdf       -wdm       -run\n       -ext\n";
			cout<<"*****************************************\n";
		}
		
		////////            Debug
		else if (Debug != std::string::npos){
			if(cmnd == "-dbg -hlp"){
				cout<<"SUI>> dbg>> hlp>> for debugging purpose:\n       -dgb -on : entering the debugging mode\n       -dgb -off : exiting the debugging mode\n";
			}	
			else{
				while (temp_cmnd.compare ("-dbg") == 0){
				
					temp_cmnd = cmnd;
					cout <<"SUI>> dbg>> Incomplete argument! Please choose your command's argument between on or off:  ";
					getline(cin,arg);
					temp_cmnd.append(" -");
					temp_cmnd.append(arg);
				//	cout<<endl;
				
				}	
			
				cmnd = temp_cmnd;
			
				size_t D_ON = cmnd.find("-dbg -on");
				size_t D_OFF = cmnd.find("-dbg -off");
			
				if(D_ON != std::string::npos){
					DebugON = 1;
					cout<<"SUI>> dbg>> on>> You entered the Debugging mode\n";
				}
				else if(D_OFF != std::string::npos){
					if(DebugON == 1){
						DebugON = 0;
						cout<<"SUI>> dbg>> off>> You exited the Debugging mode\n";
					}
					else 
						cout<<"SUI>> dbg>> you are not in the debugging mode\n";
				}
				else
					cout<<"SUI>> Wrong command! \n";	
			
				cout<<"*****************************************\n";
				TOP->systemModule->sayacInstructionModuleEmb->DebugON = DebugON;
				TOP->systemModule->memoryModule->DebugON = DebugON;
			}
			
		}
		
		
		
		////////            Loading Data into Memory
		else if (LoadMEM != std::string::npos){
			if(cmnd == "-ldm -hlp"){
				cout<< "SUI>> ldm>> hlp>>\n       -ldm -asm: First the assembler would generate the binary file and save it in a file named binfile.txt and then load it into the memory\n       -ldm -bin: For loading a binary file into the memory\n";
			}
			
			else{
			PuttingData = 0;
			while(temp_cmnd.compare("-ldm") == 0){
				cout <<"SUI>> ldm>> Incomplete argument! Please enter the type of file you want to load into the memory between assembly or binary\n";
				getline(cin,arg);
				temp_cmnd.append(" -");
				temp_cmnd.append(arg);
			}
			cmnd = temp_cmnd;
			arg = cmnd.substr(6,9);
			if(arg == "bin"){
				cout <<"SUI>> ldm>> bin>> Please enter the name of the binary file you want to load into the memory      ";
				getline(cin,arg);
				temp_cmnd.append(" -");
				temp_cmnd.append(arg);
				txt = cmnd.find(".txt");
				if(txt != std::string::npos){
					temp_cmnd = cmnd.substr (12,cmnd.length());
					file = temp_cmnd;
					Loading = 1;	
					cout<<"SUI>> ldm>> bin>> Loading bin file into MEM\n";
				}
				else{
						temp_cmnd.append(".txt");
						file = temp_cmnd;
						Loading = 1;
						cout<<"SUI>> ldm>> bin>> Loading bin file into MEM\n";
				}
			}
			else if(arg == "asm"){
				cout <<"SUI>> ldm>> asm>> Please enter the name of the assembly file you want to load into the memory (the binary result is saved at binfile.txt)      ";
				getline(cin,arg);
				temp_cmnd.append(" -");
				temp_cmnd.append(arg);
				asm_ = arg.find(".asm");
				
				
				if(asm_ != std::string::npos){
					temp_cmnd = arg;
					file = temp_cmnd;
					int file_size = file.length();
					char file_char[file_size + 1];
					strcpy(file_char, file.c_str());
					char *args[] = {"./SAYACasm",file_char,NULL}; 
					if(fork() == 0){
					execvp("./SAYACasm",args); 
					}
					else{
					file = "binfile.txt";
					Loading = 1;
					cout<<"SUI>> ldm>> asm>> Loading asm file into MEM\n";
					}
				}
				else{
					arg.append(".asm");
					file = arg;
					int file_size = file.length();
					char file_char[file_size + 1];
					strcpy(file_char, file.c_str());
					char *args[] = {"./SAYACasm",file_char,NULL}; 
					if(fork() == 0){
					execvp("./SAYACasm",args); 
					}
					else{
					file = "binfile.txt";
					Loading = 1;
					cout<<"SUI>> ldm>> asm>> Loading asm file into MEM\n";
					}
				}
			}
			else{
				cout<<"SUI>> wrong command\n";
			}
			cout<<"*****************************************\n";
			
			TOP->systemModule->memoryModule->PuttingData = PuttingData;
			TOP->systemModule->memoryModule->Loading = Loading;
			TOP->systemModule->memoryModule->file = file;
			}
		}
		
		////////            Putting Data into Memory manually by generating data file
		else if (WriteMEM != std::string::npos){
			if(cmnd == "-wdm -hlp"){
				cout<<"SUI>> wdm>> hlp>>  You can put address and its data manually by fallowing syntax:   (address data)\n                   By putting dot(.) at the end of your data you can finalize your file, at the end an address and a data file would be generated for you and would be loaded into the memory\n";
			}
			else {
			cout<<"SUI>> wdm>> In order put binary data in the memory fallow the fallowing syntax: address data\n";
			
			std::string addr_data,Addr,Data;
			
			size_t endFile = addr_data.find("-");
			space = addr_data.find(" ");
			
			ofstream PutAddr,PutData;
			PutAddr.open("addr.txt");
			PutData.open("data.txt");
			
			while (endFile == std::string::npos){
				
				cout<< "SUI>> wdm>> ";		
				getline(cin,addr_data);
				space = addr_data.find(" ");
				endFile = addr_data.find(".");
				
				if(space!=std::string::npos){
					Addr = addr_data.substr(0,space);
					Data = addr_data.substr(space+1,addr_data.length());
					
					PutAddr << Addr <<endl;
					PutData << Data <<endl;
				}
				
			}
			
			PuttingData = 1;
			Loading = 0;
			PutAddr.close();
			PutData.close();
			
			
			TOP->systemModule->memoryModule->Loading = Loading;
			TOP->systemModule->memoryModule->PuttingData = PuttingData;
			}
			
		}
		
		////////            Generating file
		else if (GenerateDataFile != std::string::npos){
			if(cmnd == "-gdf -hlp"){
				cout<<"SUI>> gdf>> hlp>>  You can generate a file of data with this command with fallowing syntax:   (address data)\n                   By putting dot(.) at the end of your data you can finalize your file, at the end an address and a data file would be generated for you\n";
			}
			else{
			std::string FileName;
			cout<<"SUI>> gdf>> Enter the name of file you want to generate  ";
			getline(cin,FileName);
			ofstream GFile;
			GFile.open(FileName);
			cout<<"SUI>> gdf>> In order to generate a data file fallow the fallowing syntax: address data\n";
			
			std::string addr_data,Addr,Data;
			size_t endFile = addr_data.find("-");
			space = addr_data.find(" ");
			//size_t endFile;
			char *DataArray[10000];
			while (endFile == std::string::npos){
				
				cout<< "SUI>> gdf>> ";		
				getline(cin,addr_data);
				space = addr_data.find(" ");
				endFile = addr_data.find(".");
				
				if(space!=std::string::npos){
					Addr = addr_data.substr(0,space);
					Data = addr_data.substr(space+1,addr_data.length());
					
				}
				int AddressData = stoi(Addr);
				char arr[Data.length()];
				strcpy(arr, Data.c_str());
				DataArray[AddressData] = arr;
				
				//cout<< DataArray[AddressData]<<"sfhfskjfbjfbkdfbzkf\n";
				for(int i =0;i< 10000;i++){
					
					if(i == AddressData)
						GFile<< DataArray[i]<<endl;
				
				}
				
			}
			
			//PuttingData = 1;
			Loading = 0;
		//	PutAddr.close();
		//	PutData.close();
			
			
			TOP->systemModule->memoryModule->Loading = Loading;
			TOP->systemModule->memoryModule->PuttingData = PuttingData;
			}
		}
		
		
		////////            Starting Location
		else if (StartingLocation != std::string::npos){
			if(cmnd == "-stl -hlp"){
				cout<<"SUI>> stl>> hlp>> The starting location for the memory in order to read the instructions from there can be set to any number here by fallowing syntax:  (-stl -(number))\n";
			}
			else{
			while(temp_cmnd.compare("-stl") == 0){
				cout <<"SUI>> stl>> Please enter the starting location of your Program into the memory     ";
				getline(cin,arg);
				temp_cmnd.append(" -");
				temp_cmnd.append(arg);
			}
			cmnd = temp_cmnd;
			
			temp_cmnd = cmnd.substr (6,cmnd.length());
			StartingLocation_ = std::stoi(temp_cmnd);
			cout<<"SUI>> stl>> program starting from location "<< StartingLocation_<<endl;
			cout<<"*****************************************\n";
			TOP->systemModule->memoryModule->StartingLocation = StartingLocation_;
			}
			
		}
		
		
		
		////////            Run	
		else if(cmnd == "-run"){
			
			cout<<"SUI>> run>> Running...\n";	
			sc_start(7000,SC_NS);
			cout<<"*****************************************\n";
		}
		else if(cmnd == "-run -hlp")
			cout<<"SUI>> run>> hlp>> Start running the system and reading instructions\n";
		
		////////            Exit
		else if (Exit!= std::string::npos){	
			if(cmnd == "-ext -hlp")
				cout<<"SUI>> ext>> hlp>> Exits the environment\n";	
			else	
			exit = 1;
		}
		
		else if(!cmnd.empty())
			cout<<"wrong command !\n";
		
	}

}
