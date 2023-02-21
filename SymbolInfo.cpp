#ifndef SYMBOLINFO_HPP
#define SYMBOLINFO_HPP

#include <iostream>
#include <vector>
#include <string>

using namespace std;

class SymbolInfo;

class FHandle {
    public:
    bool isDeclared;
    bool isDefined;
    vector<string> paramList;
    vector<SymbolInfo*> parameters;
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

    int functionParamListSize(){
        return paramList.size();
    }
};

class SymbolInfo
{
public:
    string name;
    string type;
    string dtype;
    string asmName;
    SymbolInfo *nextSymbol;
    vector<SymbolInfo*> childList;
    FHandle *fh;
    int start;
    int end;
    bool isPointer;
    bool isFunction;
    bool global;
    int arrSize;
    int offset;

    SymbolInfo(string name="", string type="", int line = -1, bool isPointer = false)
    {
        this->name = name;
        this->type = type;
        asmName = name;
        nextSymbol = NULL;
        start = line;
        end = line;
        this->isPointer = isPointer;
        isFunction = false;
        global = false;
        arrSize = 0;
        fh = new FHandle();
        offset = 0;
    }

    SymbolInfo(SymbolInfo* s){
        this->name = s->name;
        this->type = s->type;
        asmName = s->name;
        nextSymbol = NULL;
        start = s->start;
        end = s->end;
        this->isPointer = s->isPointer;
        isFunction = s->isFunction;
        global = s->global;
        arrSize = s->arrSize;
        fh = NULL;
        offset = s->offset;
    }

    int getLine(){
        return this->start;
    }

    void setIsFunction(bool function){
        isFunction = function;
    }

    bool getIsFunction(){
        return isFunction;
    }

    void setIsPointer(bool isPointer){
        this->isPointer = isPointer;
    }

    bool getIsPointer(){
        return this->isPointer;
    }

    void changeLine(){
        start = childList[0]->start;
        end = childList[childList.size() - 1]->end;
    }

    void addChild(SymbolInfo* child){
        childList.push_back(child);
    }

    void setName(string name)
    {
        this->name = name;
    }

    int paramListSize(){
        return fh->functionParamListSize();
    }

    string getName()
    {
        return this->name;
    }

    void setType(string type)
    {
        this->type = type;
    }

    string getType()
    {
        return this->type;
    }

    void setNextSymbol(SymbolInfo *nextSymbol)
    {
        this->nextSymbol = nextSymbol;
    }

    SymbolInfo *getNextSymbol()
    {
        return this->nextSymbol;
    }
};



// int main() {
//     std::cout<<"Hello World\n";
//     SymbolInfo s;
// }

#endif