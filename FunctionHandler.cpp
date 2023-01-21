#include <iostream>
#include <vector>
#include <string>
using namespace std;

class FHandle {
    public:
    bool isDeclared;
    bool isDefined;
    vector<string> paramList;
    FHandle(){
        isDeclared = false;
        isDefined = false;
    }

    bool sameParamList(vector<string> pmList){
        if(pmList.size() != paramList.size())
        return false;

        for(int  i = 0; i < pmList.size(); i++){
            if(paramList[i] != pmList[i])
            return false;
        }
        return true;
    }
};
