#include <string>
#include <iterator>
#include <vector>
#include <sstream>

#ifndef __UTILITIES_H__
#define __UTILITIES_H__

// @define: templated function to convert string to logic vector 
//      @input type: string
//      @output type: sc_dt::sc_lv<width>

template<int width>
sc_dt::sc_lv<width> str2logic(std::string str){
    std::string::iterator it;
    sc_dt::sc_lv<width> logic_vector;
    int i = 0;

    for (it = str.begin(); it != str.end(); it++){
        if ((*it) == '1')
            logic_vector[width - i - 1] = '1';
        else if ((*it) == '0')
            logic_vector[width - i - 1] = '0';

        i = i + 1;
    }

    return logic_vector;
}

#endif