#ifndef SYMBOLINFO_HPP
#define SYMBOLINFO_HPP

#include <iostream>
#include "FunctionHandler.cpp"
#include <vector>
#include <string>

using namespace std;

class SymbolInfo
{
public:
    string name;
    string type;
    string dtype;
    SymbolInfo *nextSymbol;
    vector<SymbolInfo*> childList;
    FHandle *fh;
    int start;
    int end;
    bool isPointer;
    bool isFunction;

    SymbolInfo(string name="", string type="", int line = -1, bool isPointer = false)
    {
        this->name = name;
        this->type = type;
        nextSymbol = NULL;
        start = line;
        end = line;
        this->isPointer = isPointer;
        isFunction = false;
        fh = new FHandle();
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