%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <string>
#include <vector>
#include "1905080_SymbolTable.cpp"
#include "SymbolInfo.cpp"
#include "ICG.cpp"

using namespace std;

int yyparse(void);
int yylex(void);

FILE* testing = fopen("testing", "w");

FILE* parseFile;
FILE* tokenout;
FILE* logout;
FILE* tablelog;
FILE* error;

vector<SymbolInfo*> idList;
vector<SymbolInfo*> paramList;
vector<string> paramType;
vector<SymbolInfo*> argType;
vector<SymbolInfo*> global;
vector<SymbolInfo*> globalFunctions;

SymbolTable table;
bool funcarglist = false;
bool flagzero = false;
bool divbyzero = false;
bool funcVoidError = false;
SymbolInfo* forFuncVoidError;
bool indexNotFloat = false;
int recursiveIndexCount = 0;
int reducedToFloat = 0;
bool arrayIndexConstFloat = false;
bool insideFunction = false;

extern int line_count;
extern int error_count;
extern FILE *yyin;

void checkFoargTypeError(SymbolInfo* sym){
	insideFunction = false;
	SymbolInfo* symbol = table.LookUp(sym->getName());
	if(symbol != NULL){
		if(symbol->getIsFunction()){
			if(symbol->fh->isDefined){
				if(argType.size() > symbol->fh->paramList.size()){
					fprintf(error, "Line# %d: Too many arguments to function '%s'\n", line_count, sym->getName().c_str());
					error_count++;
				}
				else if(argType.size() < symbol->fh->paramList.size()){
					fprintf(error, "Line# %d: Too few arguments to function '%s'\n", line_count, sym->getName().c_str());
					error_count++;
				}
				else{
					for(int i = 0; i < argType.size(); i++){
						if(argType[i]->getIsPointer()){
							fprintf(error, "Line# %d: Type mismatch for argument %d of '%s'\n", line_count, i+1, sym->getName().c_str());
							error_count++;
						}
						else{
							if(argType[i]->getType() != symbol->fh->paramList[i]){
								fprintf(error, "Line# %d: Type mismatch for argument %d of '%s'\n", line_count, i+1, sym->getName().c_str());
								error_count++;
							}
						}
					}
				}
			}
			else{
				fprintf(error, "Line# %d: Warning Undefined function '%s'\n", line_count, sym->getName().c_str());
				error_count++;
			}
		}
	}
	argType.clear();
}

void callingFunctionError(SymbolInfo* sym){
	SymbolInfo* symbol = table.LookUp(sym->getName());
	if(symbol == NULL){
		fprintf(error, "Line# %d: Undeclared function '%s'\n", line_count, sym->getName().c_str());
		error_count++;
	}
	else{
		if(symbol->getType() == "VOID") {
			fprintf(error, "Line# %d: Void cannot be used in expression\n", line_count);
			error_count++;
		}
	}
	funcVoidError = false;
	delete forFuncVoidError;
}

void helperFunction(SymbolInfo* sym){
	SymbolInfo* symbol = table.LookUp(sym->getName());
	if(symbol == NULL){
		fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, sym->getName().c_str());
		error_count++;
	}
	else{
		if(symbol->getIsPointer()){
			fprintf(error, "Line# %d: Array subscript is not an integer\n", line_count);
			error_count++;
		}
		else{
			if(symbol->getType() != "INT")
			fprintf(error, "Line# %d: Array subscript is not an integer\n", line_count);
			error_count++;
		}
	}
}

// void anotherHelperFunction(SymbolInfo* sym){
// 	SymbolInfo* symbol = table.LookUp(sym->getName());
// 	if(symbol == NULL){
// 		fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, sym->getName().c_str());
// 	}
// 	else{
// 		if(symbol->getIsPointer())
// 		fprintf(error, "Line# %d: '%s' is an array type variable\n", line_count, sym->getName().c_str());
// 	}
// }

void yyerror(char *s)
{
	fprintf(error, "Line# %d: %s\n", line_count, s);
	error_count++;
}

void setIndexNotFloat(SymbolInfo* sym){
	indexNotFloat = true;
	recursiveIndexCount++;

	if(recursiveIndexCount == 1){
		SymbolInfo* symbol = table.LookUp(sym->getName());
		if(symbol == NULL){
			fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, sym->getName().c_str());
			error_count++;
		}
		else{
			if(!symbol->getIsPointer()){
				fprintf(error, "Line# %d: '%s' is not an array\n", line_count, symbol->getName().c_str());
				error_count++;
			}
		}
	}
	if(recursiveIndexCount > 1){
		SymbolInfo* symbol = table.LookUp(sym->getName());
		if(symbol == NULL){
			fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, sym->getName().c_str());
			error_count++;
		}
		else{
			if(symbol->getType() != "INT"){
				fprintf(error, "Line# %d: Array subscript is not an integer\n", line_count);
				error_count++;
			}
			else{
				if(!symbol->getIsPointer()){
					fprintf(error, "Line# %d: '%s' is not an array\n", line_count, symbol->getName().c_str());
					error_count++;
				}
			}
		}
	}
}

void idAlreadyExist(string s){
	fprintf(error, "Line# %d: %s\n", line_count, s.c_str());
	error_count++;
}

void insertIntoTable(string type){
	if(idList.empty()){
		return;
	}
	if(type[0] == 'V'){
		for(int i = 0; i < idList.size(); i++){
			fprintf(error, "Line# %d: Variable or field '%s' declared void\n", line_count, idList[i]->getName().c_str());
			error_count++;
		}
	}
	else{
		for(int i = 0; i < idList.size(); i++){
			SymbolInfo* newSymbol = new SymbolInfo(idList[i]->getName(), type , idList[i]->getLine(), idList[i]->getIsPointer());
			newSymbol->arrSize = idList[i]->arrSize;
			newSymbol->global = idList[i]->global;
			newSymbol->offset = idList[i]->offset;
			bool inserted = table.Insert(newSymbol);
			if(!inserted){
				if(table.getCurrentScoptableNumber() == 1){
					SymbolInfo* func = table.LookUp(newSymbol->getName());
					if(!func->getIsFunction()){
						bool typeSpecSame = table.typeSpecifierSame(newSymbol);
						if(typeSpecSame){
							fprintf(error, "Line# %d: Redefinition of parameter '%s'\n", line_count, idList[i]->getName().c_str());
							error_count++;
						}
						else{
							fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count, idList[i]->getName().c_str());
							error_count++;
						}
					}
					else{
						fprintf(error, "Line# %d: '%s' redeclared as different kind of symbol\n", line_count, newSymbol->getName().c_str());
						error_count++;
					}
				}
				else{
					bool typeSpecSame = table.typeSpecifierSame(newSymbol);
					if(typeSpecSame){
						fprintf(error, "Line# %d: Redefinition of parameter '%s'\n", line_count, idList[i]->getName().c_str());
						error_count++;
					}
					else{
						fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count, idList[i]->getName().c_str());
						error_count++;
					}
				}
			}
		}
	}
	idList.clear();
}

void insertParamList(){
	for(int i = 0; i < paramList.size(); i++){
		bool inserted = table.Insert(paramList[i]);
			if(!inserted){
				bool typeSpecSame = table.typeSpecifierSame(paramList[i]);
				if(typeSpecSame){
					fprintf(error, "Line# %d: Redefinition of parameter '%s'\n", line_count-1, paramList[i]->getName().c_str());
					error_count++;
				}
				else{
					fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count-1, paramList[i]->getName().c_str());
					error_count++;
				}
			}
	}
	paramList.clear();
}

void addToparamList(string type, SymbolInfo* symbol){
	SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), type , symbol->getLine(), symbol->getIsPointer());
	newSymbol->arrSize = symbol->arrSize;
	newSymbol->global = symbol->global;
	newSymbol->offset = symbol->offset;
	paramList.push_back(newSymbol);
}

void funcDec(SymbolInfo* typeSpec, SymbolInfo* symbol){
	string type = typeSpec->childList[0]->getType();
	SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), type , symbol->getLine(), symbol->getIsPointer());
	newSymbol->setIsFunction(true);
	bool inserted = table.Insert(newSymbol);
	if(!inserted){
		bool typeSame = table.SymbolTypeSame(newSymbol);
		if(!typeSame){
			fprintf(error, "Line# %d: '%s' redeclared as different kind of symbol\n", line_count, newSymbol->getName().c_str());
			error_count++;
		}
		else{
			SymbolInfo* func = table.LookUp(newSymbol->getName());
			bool sameSpec = table.typeSpecifierSame(newSymbol);
			if(!sameSpec){
				fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count, newSymbol->getName().c_str());
				error_count++;
			}
			else{
				bool sameLi =  func->fh->sameParamList(paramType);
				if(!sameLi){
					cout << "hello\n";
					fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count, newSymbol->getName().c_str());
					error_count++;
				}
			}
		}
	}
	else{
		newSymbol->fh->isDeclared = true;
		for(int  i = 0; i < paramType.size(); i++){
			newSymbol->fh->paramList.push_back(paramType[i]);
		}
	}
	paramType.clear();
	paramList.clear();
}

void funcDef(SymbolInfo* typeSpec, SymbolInfo* symbol){
	string type = typeSpec->childList[0]->getType();
	SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), type , symbol->getLine(), symbol->getIsPointer());
	newSymbol->setIsFunction(true);
	bool inserted = table.Insert(newSymbol);
	if(!inserted){
		bool typeSame = table.SymbolTypeSame(newSymbol);
		if(!typeSame){
			fprintf(error, "Line# %d: '%s' redeclared as different kind of symbol\n", line_count, newSymbol->getName().c_str());
			error_count++;
		}
		else{
			SymbolInfo* func = table.LookUp(newSymbol->getName());
			bool sameSpec = table.typeSpecifierSame(newSymbol);
			if(!sameSpec){
				fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count, newSymbol->getName().c_str());
				error_count++;
			}
			else{
				bool sameLi =  func->fh->sameParamList(paramType);
				if(!sameLi){
					fprintf(error, "Line# %d: Conflicting types for '%s'\n", line_count, newSymbol->getName().c_str());
					error_count++;
				}
				else{
					func->fh->isDefined = true;
				}
			}
		}
	}
	else{
		newSymbol->fh->isDefined = true;
		for(int  i = 0; i < paramType.size(); i++){
			newSymbol->fh->paramList.push_back(paramType[i]);
			cout << newSymbol->name << endl;
			cout << paramList[i]->name  << " " << paramList[i]->type << "\n";
			newSymbol->fh->parameters.push_back(new SymbolInfo(paramList[i]));
			cout << newSymbol->fh->parameters[i]->name  << " " << newSymbol->fh->parameters[i]->type << "\n";
		}
	}
	paramType.clear();
}

void enterScopeAndAdd(){
	table.EnterScope();
	insertParamList();
}

void printRule(SymbolInfo* s){
	fprintf(tablelog,"%s : ", s->type.c_str());
	for(int i  = 0; i < s->childList.size(); i++){
	fprintf(tablelog,"%s ", s->childList[i]->type.c_str());
	}
	fprintf(tablelog,"\n");
}

void arrayIndexError(){

}

void print_parsetree(int space, SymbolInfo* s) {
	for(int i=0; i<space; i++){
        fprintf(parseFile, " ");
	}
	fprintf(parseFile, "%s : ", s->type.c_str());

	for(int i=0; i<s->childList.size(); i++) {
		fprintf(parseFile, "%s ", s->childList[i]->type.c_str());
	}

	if(s->childList.size() == 0){
		fprintf(parseFile, "%s", s->name.c_str());
		fprintf(parseFile, "\t<Line: %d>", s->start);
	}
	else{
		fprintf(parseFile, "\t<Line: %d-%d>", s->start, s->end);
	}

	fprintf(parseFile, "\n");
	fflush(parseFile);
	
	for(int i=0; i<s->childList.size(); i++){
		print_parsetree(space + 1, s->childList[i]);
	}
}
%}

%union{
	SymbolInfo* symbol;
}

%token<symbol> IF ELSE RETURN PRINTLN FOR WHILE INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON ID INT FLOAT VOID CONST_INT LOGICOP RELOP ADDOP MULOP CONST_FLOAT
%token LOWER_THAN_ELSE

%type<symbol> start program unit variable var_declaration type_specifier func_declaration func_definition parameter_list arguments argument_list declaration_list
%type<symbol> expression factor unary_expression term simple_expression rel_expression statement statements compound_statement logic_expression expression_statement

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		$$ = new SymbolInfo("start", "start");
		$$->addChild($1);
		$$->changeLine();
		print_parsetree(0, $$);
		printRule($$);
		fflush(parseFile);
		fclose(parseFile);
		start($$);
	}
	;

program : program unit {
		$$ = new SymbolInfo("program", "program");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		printRule($$);
	}
	| unit {
		$$ = new SymbolInfo("program", "program");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	;
	
unit : var_declaration {
		$$ = new SymbolInfo("unit", "unit");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
    }
    | func_declaration{
		$$ = new SymbolInfo("unit", "unit");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| func_definition{
		$$ = new SymbolInfo("unit", "unit");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN {funcDec($1, $2);} SEMICOLON{
		$$ = new SymbolInfo("func_declaration", "func_declaration");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($7);
		$$->changeLine();
		printRule($$);
	}
	| type_specifier ID LPAREN RPAREN {funcDec($1, $2);} SEMICOLON{
		$$ = new SymbolInfo("func_declaration", "func_declaration");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($6);
		$$->changeLine();
		printRule($$);
	}
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {funcDef($1, $2);} compound_statement{
		$$ = new SymbolInfo("func_definition", "func_definition");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($7);
		$$->changeLine();
		printRule($$);
		globalFunctions.push_back($$);
	}
	| type_specifier ID LPAREN RPAREN {{funcDef($1, $2);}} compound_statement{
		$$ = new SymbolInfo("func_definition", "func_definition");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($6);
		$$->changeLine();
		printRule($$);
		globalFunctions.push_back($$);
	}
 	;				

parameter_list  : parameter_list COMMA type_specifier ID{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		string type = $3->childList[0]->getType();
		addToparamList(type, $4);
		paramType.push_back($3->childList[0]->getType());
		$$->changeLine();
		printRule($$);
	}
	| parameter_list COMMA type_specifier{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3); // used in function declaration
		paramType.push_back($3->childList[0]->getType());
		$$->changeLine();
		printRule($$);
	}
	| type_specifier ID{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1);
		$$->addChild($2);
		string type = $1->childList[0]->getType();
		addToparamList(type, $2);
		paramType.push_back($1->childList[0]->getType());
		$$->changeLine();	
		printRule($$);	
	}
	| type_specifier{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1); // used in function declaration
		paramType.push_back($1->childList[0]->getType());
		$$->changeLine();
		printRule($$);
	}
 	;
	
compound_statement : LCURL {enterScopeAndAdd();} statements RCURL{ 
		$$ = new SymbolInfo("compound_statement", "compound_statement");
		$$->addChild($1); // here we are
		$$->addChild($3);
		$$->addChild($4);
		$$->changeLine();
		printRule($$);
		table.PrintAllScopeTable(tablelog);
		table.ExitScope();
	}
 	| LCURL {table.EnterScope();} RCURL{
		$$ = new SymbolInfo("compound_statement", "compound_statement");
		$$->addChild($1);
		$$->addChild($3);
		$$->changeLine();
		printRule($$);
		table.PrintAllScopeTable(tablelog);
		table.ExitScope();
	}
 	;
 		    
var_declaration : type_specifier declaration_list SEMICOLON { 
		$$ = new SymbolInfo("var_declaration", "var_declaration");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		string type = $1->childList[0]->getType();
		insertIntoTable(type);
		$$->changeLine();
		printRule($$);
	}
 	;
 		 
type_specifier	: INT{
		$$ = new SymbolInfo("type_specifier", "type_specifier");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
 	| FLOAT{
		$$ = new SymbolInfo("type_specifier", "type_specifier");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
 	| VOID{
		$$ = new SymbolInfo("type_specifier", "type_specifier");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
 	;
 		
declaration_list : declaration_list COMMA ID{
		$$ = new SymbolInfo("declaration_list", "declaration_list");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		idList.push_back($3);
		$$->changeLine();
		printRule($$);
		if(table.getScoptableNumber() == 1){
			$3->global = true;
			global.push_back($3);
		}
	}
 	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE{
		$$ = new SymbolInfo("declaration_list", "declaration_list");
		$$->addChild($1);
		$$->addChild($2);
		$3->setIsPointer(true);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
		$3->arrSize = stoi($5->getName());
		if(table.getScoptableNumber() == 1){
			$3->global = true;
			global.push_back($3);
		}
		idList.push_back($3);
		$$->changeLine();
		printRule($$);
	}
	| ID{
		$$ = new SymbolInfo("declaration_list", "declaration_list");
		$$->addChild($1);
		idList.push_back($1);
		$$->changeLine();
		printRule($$);
		if(table.getScoptableNumber() == 1){
			$1->global = true;
			global.push_back($1);
		}
	}
 	| ID LSQUARE CONST_INT RSQUARE{
		$$ = new SymbolInfo("declaration_list", "declaration_list");
		$1->setIsPointer(true);
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$1->arrSize = stoi($3->getName());
		fprintf(testing, "Hello arrSize %d", $1->arrSize);
		if(table.getScoptableNumber() == 1){
			$1->global = true;
			global.push_back($1);
		}
		idList.push_back($1);
		$$->changeLine();
		printRule($$);
	}
 	;
 		  
statements : statement{
		$$ = new SymbolInfo("statements", "statements");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| statements statement{
		$$ = new SymbolInfo("statements", "statements");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		printRule($$);
	}
	;
	   
statement : var_declaration{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| expression_statement{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| compound_statement{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
		$$->addChild($7);
		$$->changeLine();
		printRule($$);
	}
	| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->changeLine();
		printRule($$);
	}
	| IF LPAREN expression RPAREN statement ELSE statement{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
		$$->addChild($7);
		$$->changeLine();
		printRule($$);
	}
	| WHILE LPAREN expression RPAREN statement{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->changeLine();
		printRule($$);
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON{
		cout << "IN PARSER PRINTLN\n";
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->changeLine();
		SymbolInfo* symbol = table.LookUp($3->getName());
		if(symbol == NULL){
			fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, $3->getName().c_str());
			error_count++;
		}
		printRule($$);
	}
	| RETURN expression SEMICOLON{
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		printRule($$);
	}
	;
	  
expression_statement : SEMICOLON {
		$$ = new SymbolInfo("expression_statement", "expression_statement");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}		
	| expression SEMICOLON {
		$$ = new SymbolInfo("expression_statement", "expression_statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		printRule($$);
	}
	;
	  
variable : ID {
		$$ = new SymbolInfo("variable", "variable");
		$$->addChild($1);
		$$->changeLine();
		if(!insideFunction){
			if(indexNotFloat){
			helperFunction($1);
		}
		else{
			SymbolInfo* symbol = table.LookUp($1->getName());
			if(symbol == NULL){
				fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, $1->getName().c_str());
				error_count++;
			}
		}
		}
		printRule($$);

		indexNotFloat = false;
        recursiveIndexCount = 0;
	}		
	| ID LSQUARE {setIndexNotFloat($1);} expression RSQUARE {
		$$ = new SymbolInfo("variable", "variable");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($4);
		$$->addChild($5);
		$$->changeLine();
		if(arrayIndexConstFloat){
		fprintf(error, "Line# %d: Array subscript is not an integer\n", line_count);
		error_count++;
		arrayIndexConstFloat = false;
		indexNotFloat = false;
        recursiveIndexCount = 0;
		}
		printRule($$);
	}
	;
	 
expression : logic_expression{
		$$ = new SymbolInfo("expression", "expression");
		$$->addChild($1);
		$$->changeLine();
		if(funcVoidError){
			SymbolInfo* symbol = table.LookUp(forFuncVoidError->getName());
			if(symbol == NULL){
			fprintf(error, "Line# %d: Undeclared function '%s'\n", line_count, forFuncVoidError->getName().c_str());
			error_count++;
			}
			delete forFuncVoidError;
			funcVoidError = false;
		}
		printRule($$);
 	}	
	| variable ASSIGNOP logic_expression {
		$$ = new SymbolInfo("expression", "expression");
		$$->addChild($1); // here error 1
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		printRule($$);
	}	
	;
			
logic_expression : rel_expression {
		$$ = new SymbolInfo("logic_expression", "logic_expression");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}	
	| rel_expression LOGICOP rel_expression {
		$$ = new SymbolInfo("logic_expression", "logic_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		printRule($$);
	}	
	;
			
rel_expression	: simple_expression {
		$$ = new SymbolInfo("rel_expression", "rel_expression");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| simple_expression RELOP simple_expression	{
		$$ = new SymbolInfo("rel_expression", "rel_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		printRule($$);
	}
	;
				
simple_expression : term {
		$$ = new SymbolInfo("simple_expression", "simple_expression");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| simple_expression ADDOP term {
		$$ = new SymbolInfo("simple_expression", "simple_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		printRule($$);
	}
	;
					
term :	unary_expression{
		$$ = new SymbolInfo("term", "term");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
    |  term {divbyzero = true;} MULOP unary_expression{
		$$ = new SymbolInfo("term", "term");
		$$->addChild($1);
		$$->addChild($3);
		$$->addChild($4);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		if($3->getName() == "%"){
			if(reducedToFloat != 0){
				fprintf(error, "Line# %d: Operands of modulus must be integers\n", line_count);
				error_count++;
			}
			if(flagzero){
				fprintf(error, "Line# %d: Warning: division by zero i=0f=1Const=0\n", line_count);
				error_count++;
			}
		}
		if($3->getName() == "/"){
			if(flagzero){
				fprintf(error, "Line# %d: Warning: division by zero i=0f=1Const=0\n", line_count);
				error_count++;
			}
		}
		printRule($$);
		reducedToFloat = 0;
		flagzero = false;
		divbyzero = false;
	}
    ;

unary_expression : ADDOP unary_expression {
		$$ = new SymbolInfo("unary_expression", "unary_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		printRule($$);
	} 
	| NOT unary_expression {
		$$ = new SymbolInfo("unary_expression", "unary_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		if(funcVoidError){
		callingFunctionError(forFuncVoidError);
		}
		printRule($$);
	}
	| factor {
		$$ = new SymbolInfo("unary_expression", "unary_expression");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	;
	
factor	: variable {
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		if(funcarglist){
			SymbolInfo* symbol = table.LookUp($1->childList[0]->getName());
			if(symbol == NULL){
				fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, $1->childList[0]->getName().c_str());
				error_count++;
			}
			else{
				SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), symbol->getType());
				argType.push_back(newSymbol);
			}
		}
		$$->changeLine();
		printRule($$);
	}
	| ID {funcarglist = true; insideFunction = true;} LPAREN argument_list RPAREN{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->changeLine();
		// handleArgError = true;
		funcVoidError = true;
		forFuncVoidError = new SymbolInfo($1->getName(), $1->getType());
		checkFoargTypeError($1);
		funcarglist = false;
		printRule($$);
	}
	| LPAREN expression RPAREN{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		printRule($$);
	}
	| CONST_INT {
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		if(divbyzero){
			if($1->getName() == "0")
			flagzero = true;
		}
		if(funcarglist){
			SymbolInfo* newSymbol = new SymbolInfo($1->getName(), "INT");
			argType.push_back(newSymbol);
		}
		$$->changeLine();
		printRule($$);
	}
	| CONST_FLOAT{
		$$ = new SymbolInfo("factor", "factor");
		if(indexNotFloat){
			arrayIndexConstFloat = true;
		}
		$$->addChild($1);
		$$->changeLine();
		if(funcarglist){
			SymbolInfo* newSymbol = new SymbolInfo($1->getName(), "FLOAT");
				argType.push_back(newSymbol);
		}
		reducedToFloat++;
		printRule($$);
	}
	| variable INCOP{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		if(funcarglist){
			SymbolInfo* symbol = table.LookUp($1->childList[0]->getName());
			if(symbol == NULL){
				fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, $1->childList[0]->getName().c_str());
				error_count++;
			}
			else{
				SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), symbol->getType());
				argType.push_back(newSymbol);
			}
		}
		printRule($$);
	} 
	| variable DECOP{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		if(funcarglist){
			SymbolInfo* symbol = table.LookUp($1->childList[0]->getName());
			if(symbol == NULL){
				fprintf(error, "Line# %d: Undeclared variable '%s'\n", line_count, $1->childList[0]->getName().c_str());
				error_count++;
			}
			else{
				SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), symbol->getType());
				argType.push_back(newSymbol);
			}
		}
		printRule($$);
	}
	;
	
argument_list : arguments{
		$$ = new SymbolInfo("argument_list", "argument_list");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| {$$ = new SymbolInfo("argument_list", "argument_list");}
	;
	
arguments : arguments COMMA logic_expression{
		$$ = new SymbolInfo("arguments", "arguments");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		printRule($$);
	}
	| logic_expression{
		$$ = new SymbolInfo("arguments", "arguments");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	;
 

%%
int main(int argc,char *argv[])
{
	table.EnterScope();
	FILE* fp = fopen("input.c", "r");
	tokenout = fopen("tokenout.txt", "w");
	logout = fopen("logout.txt", "w");
	parseFile = fopen("parsetree.txt", "w");
	tablelog = fopen("log.txt", "w");
	error = fopen("error.txt", "w");
	yyin = fp;
	yyparse();
	table.PrintAllScopeTable(tablelog);
	fprintf(tablelog, "Total Lines: %d\n", line_count);
	fprintf(tablelog, "Total Errors: %d", error_count);


	fclose(fp);
	fclose(tokenout);
	fclose(logout);
	fclose(tablelog);
	fclose(error);
	
	return 0;
}

