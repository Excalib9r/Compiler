#ifndef SYMBOLTABLE_HPP
#define SYMBOLTABLE_HPP

#include "ScopeTable.cpp"

class SymbolTable
{
    ScopeTable *current;
    int ScopeTableNumber;
    int position1;
    int position2;
    int bucketSize;
    int countTable;

public:
    SymbolTable()
    {
        current = NULL;
        bucketSize = 17;
        countTable = 0;
        ScopeTableNumber = 0;
        position1 = 0;
        position2 = 0;
    }

    void setBucketSize(int bucketSize)
    {
        this->bucketSize = bucketSize;
    }

    void EnterScope()
    {
        countTable++;
        ScopeTable *newTable = new ScopeTable(bucketSize);
        newTable->setParentTable(current);
        ScopeTableNumber = countTable;
        newTable->setUniqueNumber(countTable);
        current = newTable;
    }

    int getPosition1()
    {
        return position1;
    }

    int getPosition2()
    {
        return position2;
    }

    int getScoptableNumber()
    {
        return ScopeTableNumber;
    }

    int getCurrentScoptableNumber(){
        return current->getUniqueNumber();
    }

    bool ExitScope()
    {
        bool scopeDeleted = false;
        if (current != NULL)
        {
            ScopeTableNumber = current->getUniqueNumber();
            scopeDeleted = true;
            ScopeTable *myTable = current->getParentTable();
            delete current;
            current = myTable;
        }
        return scopeDeleted;
    }

    bool Insert(SymbolInfo* symbol)
    {
        bool inserted = current->Insert(symbol);
        ScopeTableNumber = current->getUniqueNumber();
        position1 = current->getPosition1();
        position2 = current->getPosition2();
        return inserted;
    }

    bool SymbolTypeSame(SymbolInfo* symbol){
        bool typeSame = current->SymbolTypeSame(symbol);
        return typeSame;
    }

    bool typeSpecifierSame(SymbolInfo* symbol){
        bool typeSame = current->typeSpecifierSame(symbol);
        return typeSame;
    }

    bool Remove(string name)
    {
        bool deleted = current->Delete(name);
        ScopeTableNumber = current->getUniqueNumber();
        position1 = current->getPosition1();
        position2 = current->getPosition2();
        return deleted;
    }

    SymbolInfo* LookUp(string name)
    {
        ScopeTable *parent = current;
        SymbolInfo *symbol = parent->LookUp(name);
        ScopeTableNumber = parent->getUniqueNumber();
        position1 = parent->getPosition1();
        position2 = parent->getPosition2();
        while (symbol == NULL)
        {
            parent = parent->getParentTable();
            if (parent != NULL)
            {
                symbol = parent->LookUp(name);
                ScopeTableNumber = parent->getUniqueNumber();
                position1 = parent->getPosition1();
                position2 = parent->getPosition2();
            }
            if (parent == NULL)
            {
                break;
            }
        }
        return symbol;
    }

    void PrintCurrentScopeTable(FILE* logout)
    {
        current->Print(logout);
    }

    void PrintAllScopeTable(FILE* logout)
    {
        ScopeTable *parent = current;

        while (parent != NULL)
        {
            parent->Print(logout);
            parent = parent->getParentTable();
        }
    }

    ~SymbolTable()
    {
        delete current;
    }
};

#endif