#ifndef ICG
#define ICG
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include "SymbolInfo.cpp"
#include "1905080_SymbolTable.cpp"
using namespace std;

extern vector<SymbolInfo*> global;
extern vector<SymbolInfo*> globalFunctions;

int levelNumber = 0;
int globalVariable = 0;
int returnLevel = 0;
int localOffset = 0;
extern SymbolTable table;

FILE* codeFile = fopen("code.asm", "w");

void start(SymbolInfo* s);
void var_declaration(SymbolInfo* s);
void declaration_list(SymbolInfo* s);
void compound_statement(SymbolInfo* s);
void statements(SymbolInfo* s);
void statement(SymbolInfo* s);
void expression_statement(SymbolInfo* s);
void expression(SymbolInfo* s);
void logic_expression(SymbolInfo* s);
void variable(SymbolInfo* s);
void rel_expression(SymbolInfo* s);
void simple_expression(SymbolInfo* s);
void term(SymbolInfo* s);
void unary_expression(SymbolInfo* s);
void factor(SymbolInfo* s);
void argument_list(SymbolInfo* s);
void arguments(SymbolInfo* s);

void start(SymbolInfo* s){
    fprintf(codeFile, ".MODEL SMALL\n");
    fprintf(codeFile, ".STACK 1000H\n");
    fprintf(codeFile, ".DATA\n");
    fprintf(codeFile, "\tnumber DB \"00000$\"\n");
    for(int i = 0; i < global.size(); i++){
        SymbolInfo* var = table.LookUp(global[i]->name);
        var->asmName = var->name + "_" + to_string(globalVariable);
        cout << var->asmName << "\n" ;
        globalVariable++;
        if(var->getIsPointer()){
            fprintf(codeFile, "\t%s DW %d DUP (0000H)\n", var->asmName.c_str(), var->arrSize);
        }
        else{
            fprintf(codeFile, "\t%s DW 0\n", var->asmName.c_str());
        }
    }
    fprintf(codeFile, ".CODE\n");

    for(int i = 0; i < globalFunctions.size(); i++){
        SymbolInfo* var = table.LookUp(globalFunctions[i]->childList[1]->name);
        if(var->name != "main"){
            var->asmName = var->name + "_" + to_string(globalVariable);
            globalVariable++;
        }
        fprintf(codeFile, "%s PROC\n", var->asmName.c_str());
        fprintf(codeFile, "\tPUSH BP\n");
        fprintf(codeFile, "\tMOV BP, SP\n");
        if(var->name == "main"){
            fprintf(codeFile, "\tMOV AX, @DATA\n");
            fprintf(codeFile,"\tMOV DS, AX\n");
        }
        compound_statement(globalFunctions[i]->childList[globalFunctions[i]->childList.size()-1]);
        fprintf(codeFile, "RETURN%d:\n",returnLevel);
        returnLevel++;
        fprintf(codeFile, "\tPOP BP\n");
        if(var->name == "main"){
            fprintf(codeFile, "\tMOV AH, 4CH\n");
            fprintf(codeFile, "\tINT 21H\n");
        }
        else{
        fprintf(codeFile, "\tRET\n");
        }
        fprintf(codeFile, "%s ENDP\n",var->name.c_str());
    }
    // for println function
    
    ifstream println("println.asm");
    string input;
    while(getline(println, input)) fprintf(codeFile, "%s\n", input.c_str());
    println.close();

    fprintf(codeFile, "END MAIN\n");
}

void argument_list(SymbolInfo* s){
    arguments(s->childList[0]);
}

void arguments(SymbolInfo* s){
    if(s->childList.size() == 1){
        logic_expression(s->childList[0]);
    }
}

void var_declaration(SymbolInfo* s){
    declaration_list(s->childList[1]);
}

void declaration_list(SymbolInfo* s){
    if(s->childList.size() == 1){
        localOffset -= 2;
        s->childList[0]->offset = localOffset;
        table.Insert(s->childList[0]);
        fprintf(codeFile, "\tSUB SP, 2\n");
    }
    else if(s->childList.size() == 3){
        declaration_list(s->childList[0]);
        localOffset -= 2;
        s->childList[2]->offset = localOffset;
        table.Insert(s->childList[2]);
        fprintf(codeFile, "\tSUB SP, 2\n");
    }
    else if(s->childList.size() == 4){
        int size = s->childList[0]->arrSize * 2;
        s->childList[0]->offset = localOffset - 2;
        localOffset -= size;
        table.Insert(s->childList[0]);
        fprintf(codeFile, "\tSUB SP, %d\n", size);
    }
    else{
        declaration_list(s->childList[0]);
        int size = s->childList[2]->arrSize * 2;
        s->childList[0]->offset = localOffset - 2;
        localOffset -= size;
        table.Insert(s->childList[2]);
        fprintf(codeFile, "\tSUB SP, %d\n", size);
    }
}

void compound_statement(SymbolInfo* s) {
    if(s->childList.size() == 3) {
        localOffset = 0;
        table.EnterScope();
        statements(s->childList[1]);
        table.traverseCurrentTable(codeFile);
        table.ExitScope();
    }
}

void statements(SymbolInfo* s) {
    if(s->childList.size() == 2) {
        statements(s->childList[0]);
        statement(s->childList[1]);
    }
    else statement(s->childList[0]);
}

void statement(SymbolInfo* s) {
    if(s->childList.size() == 1){
        if(s->childList[0]->name == "expression_statement") expression_statement(s->childList[0]);
        if(s->childList[0]->name == "var_declaration") var_declaration(s->childList[0]);
        if(s->childList[0]->name == "compound_statement") compound_statement(s->childList[0]);
    }

    if(s->childList[0]->name == "println" || s->childList[0]->type == "PRINTLN") {
        SymbolInfo* var = table.LookUp(s->childList[2]->name);
        if(var->global)
            fprintf(codeFile, "\tMOV AX, %s\n", var->asmName.c_str());
        else 
            fprintf(codeFile, "\tMOV AX, BP[%d]\n", var->offset);
        fprintf(codeFile, "\tCALL PRINTLN\n");
    }
}

void expression_statement(SymbolInfo* s){
    if(s->childList.size() == 2){
        expression(s->childList[0]);
        fprintf(codeFile, "\tPOP AX\n");
    }
}

void expression(SymbolInfo* s){
    if(s->childList.size() == 1){
        logic_expression(s->childList[0]);
    }
    else{
        logic_expression(s->childList[2]);
        fprintf(codeFile, "\tPOP AX\n");
        if(s->childList[0]->childList.size() == 1){
        SymbolInfo* child = table.LookUp(s->childList[0]->childList[0]->getName());
        if(child->global){
            fprintf(codeFile, "\tMOV %s, AX\n", child->asmName.c_str());
        }
        else{
            fprintf(codeFile, "\tMOV BP[%d], AX\n", child->offset);
        }
        }
        fprintf(codeFile, "\tPUSH AX\n");
    }
}


void logic_expression(SymbolInfo* s){
    if(s->childList.size() == 1){
        rel_expression(s->childList[0]);
    }
    else{
        rel_expression(s->childList[0]);
        rel_expression(s->childList[2]);
        fprintf(codeFile, "\tPOP DX\n");
        fprintf(codeFile, "\tPOP CX\n");

        if(s->childList[1]->name == "&&"){
        fprintf(codeFile, "\tCMP CX, 0\n");
        fprintf(codeFile, "\tJG FOR_LOGICOP%d\n", levelNumber);
        }

        if(s->childList[1]->name == "||"){

        fprintf(codeFile, "\tJG FOR_LOGICOP%d\n", levelNumber);
        }

        fprintf(codeFile, "\tMOV CX, 0\n");
        fprintf(codeFile, "\tJMP END%d\n", levelNumber);
        fprintf(codeFile, "FOR_LOGICOP%d:\n", levelNumber);
        fprintf(codeFile, "\tMOV CX, 1\n");
        fprintf(codeFile, "\tEND%d:\n", levelNumber);
        fprintf(codeFile, "\tPUSH CX\n");
        levelNumber++;
    }
}

void rel_expression(SymbolInfo* s){
    if(s->childList.size() == 1){
        simple_expression(s->childList[0]);
    }
    else{
        simple_expression(s->childList[0]);
        simple_expression(s->childList[2]);
        fprintf(codeFile, "\tPOP DX\n");
        fprintf(codeFile, "\tPOP CX\n");
        fprintf(codeFile, "\tCMP CX, DX\n");
        
        string for_relop = "FOR_RELOP" + levelNumber;
        string end = "END" + levelNumber;
        levelNumber++;

        if(s->childList[1]->name == ">")
        fprintf(codeFile, "\tJG %s\n", for_relop.c_str());

        if(s->childList[1]->name == ">=")
        fprintf(codeFile, "\tJGE %s\n", for_relop.c_str());

        if(s->childList[1]->name == "<")
        fprintf(codeFile, "\tJL %s\n", for_relop.c_str());

        if(s->childList[1]->name == "<=")
        fprintf(codeFile, "\tJLE %s\n", for_relop.c_str());

        if(s->childList[1]->name == "==")
        fprintf(codeFile, "\tJE %s\n", for_relop.c_str());

        if(s->childList[1]->name == "!=")
        fprintf(codeFile, "\tJNE %s\n", for_relop.c_str());

        fprintf(codeFile, "\tMOV CX, 0\n");
        fprintf(codeFile, "\tJMP %s\n", end.c_str());
        fprintf(codeFile, "%s:\n", for_relop.c_str());
        fprintf(codeFile, "\tMOV CX, 1\n");
        fprintf(codeFile, "%s:\n", end.c_str());
        fprintf(codeFile, "\tPUSH CX\n");
    }
}

void simple_expression(SymbolInfo* s) {
    if(s->childList.size() == 1) {
        term(s->childList[0]);
    }
    else {
        simple_expression(s->childList[0]);
        term(s->childList[2]);
        fprintf(codeFile, "\tPOP CX\n");
        fprintf(codeFile, "\tPOP DX\n");
        if(s->childList[1]->name == "+")
            fprintf(codeFile, "\tADD DX, CX\n");
        else
            fprintf(codeFile, "\tSUB DX, CX\n");
        fprintf(codeFile, "\tPUSH DX\n");
    }
}

void factor(SymbolInfo* s){
    if(s->childList.size() == 3) {
        expression(s->childList[1]);
    }
    else if(s->childList.size() == 1){
        if(s->childList[0]->getName() == "variable"){
            SymbolInfo* child = table.LookUp(s->childList[0]->childList[0]->name);
            if(child->global){
                fprintf(codeFile, "\tMOV AX, %s\n", child->asmName.c_str());
                fprintf(codeFile, "\tPUSH AX\n");
            }
            else{
                fprintf(codeFile, "\tMOV AX, BP[%d]\n", child->offset);
                fprintf(codeFile, "\tPUSH AX\n");
            }
        }
        else{
            fprintf(codeFile, "\tMOV AX, %s\n", s->childList[0]->name.c_str());
            fprintf(codeFile, "\tPUSH AX\n");
        }
    }
    // else if(s->childList.size() == 4){
    //     // if(s->childList[0]->getName() == "PRINTLN"){
    //     //     argument_list(s->childList[2]);
    //     //     fprintf(codeFile, "\tCALL PRINTLN\n");
    //     // }
    // }
    else {
        SymbolInfo* child = table.LookUp(s->childList[0]->childList[0]->name);
        if(child->global){
            if(s->childList[1]->getType() == "DECOP"){
            fprintf(codeFile, "\tPUSH %s\n", child->asmName.c_str());
            fprintf(codeFile, "\tSUB %s, 1\n", child->asmName.c_str());
        }
        else{
            fprintf(codeFile, "\tPUSH %s\n", child->asmName.c_str());
            fprintf(codeFile, "\tADD %s, 1\n" , child->asmName.c_str());
        }
        }
        else{
        if(s->childList[1]->getType() == "DECOP"){
            fprintf(codeFile, "\tPUSH BP[%d]\n", child->offset);
            fprintf(codeFile, "\tSUB BP[%d], 1\n", child->offset);
        }
        else{
            fprintf(codeFile, "\tPUSH BP[%d]\n", child->offset);
            fprintf(codeFile, "\tADD BP[%d], 1\n", child->offset);
        }
        }
    }
} 

void term(SymbolInfo* s){
    if(s->childList.size() == 1){
        unary_expression(s->childList[0]);
    }
    else{
        term(s->childList[0]);
        unary_expression(s->childList[2]);
        fprintf(codeFile, "\tPOP BX\n");
        fprintf(codeFile, "\tPOP AX\n");
        if(s->childList[1]->name == "*"){
            fprintf(codeFile, "\tIMUL BX\n");
            fprintf(codeFile, "\tPUSH AX\n");
        }
        else if(s->childList[1]->name == "/"){
            fprintf(codeFile, "\tCWD\n");
            fprintf(codeFile, "\tIDIV BX\n");
            fprintf(codeFile, "\tPUSH AX\n");
        }  
        else{
            fprintf(codeFile, "\tCWD\n");
            fprintf(codeFile, "\tIDIV BX\n");
            fprintf(codeFile, "\tPUSH DX\n");
        }
    }
}

void unary_expression(SymbolInfo* s){
    if(s->childList.size() == 1){
        factor(s->childList[0]);
    }
    else{
        if(s->childList[0]->name == "!"){
            unary_expression(s->childList[1]);
            fprintf(codeFile, "\tPOP CX\n");
            fprintf(codeFile, "\tCMP CX, 0\n");
            fprintf(codeFile, "\tJE FOR_NOT%d\n", levelNumber);
            fprintf(codeFile, "\tMOV CX, 0\n");
            fprintf(codeFile, "\tJMP END%d\n", levelNumber);
            fprintf(codeFile, "FOR_NOT%d:\n", levelNumber);
            fprintf(codeFile, "\tMOV CX, 1\n");
            fprintf(codeFile, "END%d:\n", levelNumber);
            fprintf(codeFile, "\tPUSH CX\n");
            levelNumber++;
        }
        else{
            if(s->childList[0]->name == "+"){
                unary_expression(s->childList[1]);
            }
            else{
                unary_expression(s->childList[1]);
                fprintf(codeFile, "\tPOP CX\n");
                fprintf(codeFile, "\tNEG CX\n");
                fprintf(codeFile, "\tPUSH CX\n");
            }
        }
    }
}

#endif