#include "1905080_SymbolTable.cpp"

using namespace std;
int main(){
    SymbolTable st;
    st.EnterScope();
    SymbolInfo* symbol1 = new SymbolInfo("abc", "INT");
    st.EnterScope();
    SymbolInfo* symbol3 = new SymbolInfo("hel", "FLOAT");
    st.Insert(symbol1);
    SymbolInfo* symbol2 = st.LookUp("bara");
    if(symbol2 != NULL){
        cout << "Hello WOrld" << endl;
    }
    else{
        cout << " bar" << endl;
    }
    return 0;
}