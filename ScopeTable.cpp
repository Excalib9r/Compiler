#ifndef SCOPETABLE_HPP
#define SCOPETABLE_HPP

#include "SymbolInfo.cpp"
#include <cstring>
#include <string>
using namespace std;

class ScopeTable
{
    int uniqueNumber;
    int bucketSize;
    int position1;
    int position2;
    ScopeTable *parentTable;
    SymbolInfo **arr;

public:
    int sdbm(string name, int bucketSize)
    {
        int hashValue = 0;
        int length = name.length();

        for (unsigned int i = 0; i < length; i++)
        {
            hashValue = ((name[i]) + (hashValue << 6) + (hashValue << 16) - hashValue) % bucketSize;
        }

        return hashValue;
    }

    int hashFunction(int bucktetSize, string name)
    {
        int index = sdbm(name, bucktetSize);
        // cout << "The index for " << name << " is " << index << endl;
        return index;
    }
    ScopeTable(int size)
    {
        this->bucketSize = size;
        this->parentTable = NULL;
        position1 = 0;
        position2 = 0;
        arr = new SymbolInfo *[size];
        for (int i = 0; i < size; i++)
        {
            arr[i] = NULL;
        }
    }

    void setParentTable(ScopeTable *parentTable)
    {
        this->parentTable = parentTable;
    }

    ScopeTable *getParentTable()
    {
        return this->parentTable;
    }

    void setUniqueNumber(int uniqueNumber)
    {
        this->uniqueNumber = uniqueNumber;
    }

    int getUniqueNumber()
    {
        return this->uniqueNumber;
    }

    int getPosition1()
    {
        return position1;
    }

    int getPosition2()
    {
        return position2;
    }

    bool checkString(string s1, string s2)
    {
        int length = s1.length();
        bool same = true;
        for (int i = 0; i < length; i++)
        {
            if (s1[i] != s2[i])
            {
                same = false;
                break;
            }
        }
        return same;
    }

    SymbolInfo *LookUp(string name)
    {
        int index = hashFunction(bucketSize, name);
        position1 = index + 1;
        SymbolInfo *root = arr[index];
        bool found = false;
        position2 = 0;
        while (root != NULL)
        {
            position2++;
            string rootString = root->getName();
            if (rootString.length() == name.length())
            {
                found = checkString(name, rootString);
                if (found == true)
                {
                    return root;
                }
            }
            root = root->getNextSymbol();
        }
        return NULL;
    }

    bool Insert(SymbolInfo* symbol)
    {
        bool inserted = false;

        SymbolInfo *value = LookUp(symbol->getName());

        if (value == NULL)
        {
            position2 = 1;
            // cout << "Inside insert function" << endl;
            inserted = true;
            int index = hashFunction(bucketSize, symbol->getName());
            position1 = index + 1;

            if (arr[index] == NULL)
            {
                arr[index] = symbol;
            }
            else
            {
                position2++;
                SymbolInfo *root = arr[index];
                while (root->getNextSymbol() != NULL)
                {
                    position2++;
                    root = root->getNextSymbol();
                }

                root->setNextSymbol(symbol);
            }
        }

        return inserted;
    }

    bool Delete(string name)
    {
        SymbolInfo *symbol = LookUp(name);
        if (symbol == NULL)
        {
            return false;
        }

        else
        {
            int index = hashFunction(bucketSize, name);
            if (arr[index] == symbol)
            {
                arr[index] = symbol->getNextSymbol();
            }
            else
            {
                SymbolInfo *root = arr[index];

                while (root->getNextSymbol() != symbol)
                {
                    root = root->getNextSymbol();
                }
                root->setNextSymbol(symbol->getNextSymbol());
            }
            symbol->setNextSymbol(NULL);
            return true;
        }
    }

    void Print(FILE *logout)
    {
        fprintf(logout, "        ScopeTable# %d\n", uniqueNumber);
        for (int i = 0; i < bucketSize; i++)
        {
            SymbolInfo *root = arr[i];
            if (root != NULL)
            {
                fprintf(logout, "        %d--> ", i + 1);
                while (root != NULL)
                {
                    string s1 = root->getName();
                    string s2 = root->getType();
                    int n1 = s1.length();
                    int n2 = s2.length();
                    char c1[n1+1];
                    char c2[n2+1];
                    strcpy(c1, s1.c_str());
                    strcpy(c2, s2.c_str());
                    
                    if(root->getIsFunction())
                    fprintf(logout, "<%s ,FUNCTION ,%s> ", c1, c2);
                    else
                    fprintf(logout, "<%s ,%s> ", c1, c2);
                    root = root->getNextSymbol();
                }
                fprintf(logout, "\n");
            }
        }
    }

    void destroyScopeTable()
    {
        for (int i = 0; i < bucketSize; i++)
        {
            delete arr[i];
        }
        delete[] arr;
    }

    ~ScopeTable()
    {
        for (int i = 0; i < bucketSize; i++)
        {
            while(arr[i] != NULL){
                SymbolInfo* symbol =  arr[i]->getNextSymbol();
                delete arr[i];
                arr[i] = symbol;
            }
        }
        delete[] arr;
    }
};

#endif