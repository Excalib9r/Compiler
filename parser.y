%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <string>
#include <vector>
#include "1905080_SymbolTable.cpp"
#include "SymbolInfo.cpp"

using namespace std;

int yyparse(void);
int yylex(void);

FILE* parseFile;
FILE* tokenout;
FILE* logout;
FILE* tablelog;
FILE* error;

vector<SymbolInfo*> idList;
vector<SymbolInfo*> paramList;
SymbolTable table;

extern int line_count;
extern int error_count;
extern FILE *yyin;


void yyerror(char *s)
{
	fprintf(error, "Line# %d: %s\n", line_count, s);
}

void insertIntoTable(string type){
	if(idList.empty()){
		return;
	}
	for(int i = 0; i < idList.size(); i++){
		SymbolInfo* newSymbol = new SymbolInfo(idList[i]->getName(), type , idList[i]->getLine(), idList[i]->getIsPointer());
		table.Insert(newSymbol);
	}
	idList.clear();
}

void insertParamList(){
	for(int i = 0; i < paramList.size(); i++){
		table.Insert(paramList[i]);
	}
	paramList.clear();
}

void addToparamList(string type, SymbolInfo* symbol){
	SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), type , symbol->getLine(), symbol->getIsPointer());
	paramList.push_back(newSymbol);
}

void funcDef(SymbolInfo* typeSpec, SymbolInfo* symbol){
	string type = typeSpec->childList[0]->getType();
	SymbolInfo* newSymbol = new SymbolInfo(symbol->getName(), type , symbol->getLine(), symbol->getIsPointer());
	newSymbol->setIsFunction(true);
	table.Insert(newSymbol);
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
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
		$$ = new SymbolInfo("func_declaration", "func_declaration");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->addChild($6);
		$$->changeLine();
		printRule($$);
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON{
		$$ = new SymbolInfo("func_declaration", "func_declaration");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
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
		$$->changeLine();
		printRule($$);
	}
	| parameter_list COMMA type_specifier{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3); // used in function declaration
		$$->changeLine();
		printRule($$);
	}
	| type_specifier ID{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1);
		$$->addChild($2);
		string type = $1->childList[0]->getType();
		addToparamList(type, $2);
		$$->changeLine();	
		printRule($$);	
	}
	| type_specifier{
		$$ = new SymbolInfo("parameter_list", "parameter_list");
		$$->addChild($1); // used in function declaration
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
		insertParamList();
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
	}
 	| ID LSQUARE CONST_INT RSQUARE{
		$$ = new SymbolInfo("declaration_list", "declaration_list");
		$1->setIsPointer(true);
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
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
		$$ = new SymbolInfo("statement", "statement");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->addChild($5);
		$$->changeLine();
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
		printRule($$);
	}		
	| ID LSQUARE expression RSQUARE {
		$$ = new SymbolInfo("variable", "variable");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->changeLine();
		printRule($$);
	}
	;
	 
expression : logic_expression{
		$$ = new SymbolInfo("expression", "expression");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
 	}	
	| variable ASSIGNOP logic_expression {
		$$ = new SymbolInfo("expression", "expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
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
		printRule($$);
	}
	;
					
term :	unary_expression{
		$$ = new SymbolInfo("term", "term");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
    |  term MULOP unary_expression{
		$$ = new SymbolInfo("term", "term");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->changeLine();
		printRule($$);
	}
    ;

unary_expression : ADDOP unary_expression {
		$$ = new SymbolInfo("unary_expression", "unary_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		printRule($$);
	} 
	| NOT unary_expression {
		$$ = new SymbolInfo("unary_expression", "unary_expression");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
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
		$$->changeLine();
		printRule($$);
	}
	| ID LPAREN argument_list RPAREN{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
		$$->changeLine();
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
		$$->changeLine();
		printRule($$);
	}
	| CONST_FLOAT{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
	| variable INCOP{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		printRule($$);
	} 
	| variable DECOP{
		$$ = new SymbolInfo("factor", "factor");
		$$->addChild($1);
		$$->addChild($2);
		$$->changeLine();
		printRule($$);
	}
	;
	
argument_list : arguments{
		$$ = new SymbolInfo("argument_list", "argument_list");
		$$->addChild($1);
		$$->changeLine();
		printRule($$);
	}
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
	FILE* fp = fopen("noerror.c", "r");
	tokenout = fopen("tokenout.txt", "w");
	logout = fopen("logout.txt", "w");
	parseFile = fopen("parsetree.txt", "w");
	tablelog = fopen("log.txt", "w");
	error = fopen("error.txt", "w");
	yyin = fp;
	yyparse();
	fprintf(tablelog, "Total Lines: %d\n", line_count);
	fprintf(tablelog, "Total Errors: %d", error_count);


	fclose(fp);
	fclose(parseFile);
	fclose(tokenout);
	fclose(logout);
	fclose(tablelog);
	fclose(error);
	
	return 0;
}

