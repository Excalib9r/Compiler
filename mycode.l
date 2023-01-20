%option noyywrap

%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
// #include "y.tab.h"
#include "1905080_SymbolTable.cpp"

using namespace std;

int line_count=1;
int error_count=0;
int asciiVaule(char ch){
	if(ch == '\'')
	return 39;
	else if(ch == '\"')
	return 34;
	else if(ch =='0')
	return 0;
	else if(ch == 'n')
	return 10;
	else if(ch == 't')
	return 9;
	else if(ch == '\\')
	return 92;
	else if(ch == 'a')
	return 7;
	else if(ch == 'f')
	return 12;
	else if(ch == 'r')
	return 13;
	else if(ch == 'b')
	return 8;
	else if(ch == 'v')
	return 11;
	else return 0;
}

FILE *logout;
FILE *tokenout;

symbolTable st;

// extern double yylval;

%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NUMBER [[0-9]*\.?[0-9]+|[0-9]+\.][E(+|\-)?[0-9]+]?
IDENTIFIER [_A-Za-z][_A-Za-z0-9]*
NEWLINE \n

%%

{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <IF> Lexeme %s found\n", line_count, yytext);
		}

"else"	{
			fprintf(tokenout,"<ELSE, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <FOR> Lexeme %s found\n",line_count, yytext);
		}
		
"for"	{
			fprintf(tokenout,"<FOR, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <FOR> Lexeme %s found\n",line_count, yytext);
		}

"while"	{
			fprintf(tokenout,"<WHILE, %s>\n",yytext);
			fprintf(logout,"Line# %d: TOKEN <WHILE> Lexeme %s found\n",line_count, yytext);
		}

"do"	{
			fprintf(tokenout,"<DO, %s>\n",yytext);
			fprintf(logout,"Line# %d: TOKEN <DO> Lexeme %s found\n",line_count, yytext);
		}

"break"	{
			fprintf(tokenout,"<BREAK, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <BREAK> Lexeme %s found\n",line_count, yytext);
		}

"int"	{
			fprintf(tokenout,"<INT, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <INT> Lexeme %s found\n",line_count, yytext);
		}

"char"	{
			fprintf(tokenout,"<CHAR, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <CHAR> Lexeme %s found\n", line_count, yytext);
		}

"float"	{
			fprintf(tokenout,"<FLOAT, %s>\n",  yytext);
			fprintf(logout,"Line# %d: TOKEN <FLOAT> Lexeme %s found\n", line_count, yytext);
		}

"double"    {
			    fprintf(tokenout,"<DOUBLE, %s>\n",  yytext);
			    fprintf(logout,"Line# %d: TOKEN <DOUBLE> Lexeme %s found\n", line_count, yytext);
		    }	

"void"	{
			fprintf(tokenout,"<VOID, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <VOID> Lexeme %s found\n",line_count, yytext);
		}

"return"	{
			fprintf(tokenout,"<RETURN, %s>\n",yytext);
			fprintf(logout,"Line# %d: TOKEN <RETURN> Lexeme %s found\n", line_count, yytext);
		}

"switch"	{
			fprintf(tokenout,"<SWITCH, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <SWITCH> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"case"	{
			fprintf(tokenout,"<CASE, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <CASE> Lexeme %s found\n", line_count, yytext);
		}

"default"	{
			fprintf(tokenout,"<DEFAU   %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <DEFAULT> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"continue"	{
			fprintf(tokenout,"<CONTINUE, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <CONTINUE> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"+"	{
			fprintf(tokenout,"<ADDOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <ADDOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"-"	{
			fprintf(tokenout,"<ADDOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <ADDOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"*"	{
			fprintf(tokenout,"<MULOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <MULOP> Lexeme %s found\n", line_count, yytext);
		}

"/"	{
			fprintf(tokenout,"<MULOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <MULOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"%"	{
			fprintf(tokenout,"<MULOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <MULOP> Lexeme %s found\n", line_count, yytext);
			  
			  
		}

"++"	{
			fprintf(tokenout,"<INCOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <INCOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"--"	{
			fprintf(tokenout,"<INCOP, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <INCOP> Lexeme %s found\n", line_count, yytext);
			  
			  
		}

"<" 	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <RELOP> Lexeme %s found\n",line_count, yytext);
			  
		}

"<="	{
			fprintf(tokenout,"<RELOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <RELOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

">" 	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <RELOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

">="	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <RELOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"=="	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <RELOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"!="	{
			fprintf(tokenout,"<RELOP, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <RELOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"=" 	{
			fprintf(tokenout,"<ASSIGNOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <ASSIGNOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"&&"	{
			fprintf(tokenout,"<LOGICOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <LOGICOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"||"	{
			fprintf(tokenout,"<LOGICOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <LOGICOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"&" 	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <BITOP> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"|" 	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <BITOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"^" 	{
			fprintf(tokenout,"<BITOP, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <BITOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"<<"	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <BITOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

">>"	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <BITOP> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"!" 	{
			fprintf(tokenout,"<NOT, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <NOT> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

"(" 	{
			fprintf(tokenout,"<LPAREN, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <LPAREN> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

")" 	{
			fprintf(tokenout,"<RPAREN, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <RPAREN> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"{" 	{
			fprintf(tokenout,"<LCURL, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <LCURL> Lexeme %s found\n",    line_count, yytext);
			st.EnterScope();
			  
			  
		}

"}" 	{
			fprintf(tokenout,"<RCURL, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <RCURL> Lexeme %s found\n",   line_count, yytext);
			st.ExitScope();	  
		}

"["  	{
			fprintf(tokenout,"<LSQUARE, %s>\n",   yytext);
			fprintf(logout,"Line# %d: TOKEN <LSQUARE> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

"]"	   {
			fprintf(tokenout,"<RSQUARE, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <RSQUARE> Lexeme %s found\n",    line_count, yytext);
			  
			  
		}

","	    {
			fprintf(tokenout,"<COMMA, %s>\n", yytext);
			fprintf(logout,"Line# %d: TOKEN <COMMA> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

";"	    {
			fprintf(tokenout,"<SEMICOLON, %s>\n",    yytext);
			fprintf(logout,"Line# %d: TOKEN <SEMICOLON> Lexeme %s found\n",   line_count, yytext);
			  
			  
		}

{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n", yytext);
				fprintf(logout,"Line# %d: TOKEN <CONST_INT> Lexeme %s found\n", line_count,yytext);
				  
			      
			}


{NUMBER}    {
	            fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
			    fprintf(logout,"Line# %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			      
			      
            }

{IDENTIFIER}   {
                    fprintf(tokenout,"<ID, %s>\n", yytext);
			        fprintf(logout,"Line# %d: TOKEN <ID> Lexeme %s found\n", line_count,yytext);
			        bool inserted = st.Insert(string(yytext), "ID");
					if(inserted != true){
						fprintf(logout,"        %s already exists in the current ScopTable\n", yytext);
					}
					st.PrintAllScopeTable(logout);
                }

'[ -~]{-}[\'\"\n\t\\\a\f\r\b\v\0]'  {
	                                    char ch = yytext[1];
	                                    fprintf(tokenout,"<CONST_CHAR, %c>\n" ,ch);
			                            fprintf(logout,"Line# %d: TOKEN <CONST_CHAR> Lexeme %c found\n", line_count,ch);   
		                            }

'\\[\'\"nt\\afrbv0]'   {
	char ch  = asciiVaule(yytext[2]);
	printf("%c", yytext[2]);
	fprintf(tokenout,"<CONST_CHAR, %c>\n" ,ch);
	fprintf(logout,"Line# %d: TOKEN <CONST_CHAR> Lexeme %c found\n", line_count,ch);
	}
			
[0-9.]* {
	fprintf(logout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);
}

[[0-9]*\.?[0-9]+|[0-9]+\.][E(+|\-)?[0-9.]+\.[0-9]]  {
	fprintf(logout, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext);
}

[0-9.]+[_A-Za-z]+[0-9.]*[_A-Za-z]*  {
	fprintf(logout, "Error at line %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n", line_count, yytext);
}

''  {
	fprintf(logout, "Error at line %d: EMPTY_CONST_CHAR %s\n", line_count, yytext);
}

'  {
	fprintf(logout, "Error at line %d: UNFINISHED_CONST_CHAR %s\n", line_count, yytext);
}

'[[[ -~]{-}[\'\"\n\t\\\a\f\r\b\v\0]]+] {
	fprintf(logout, "Error at line %d: UNFINISHED_CONST_CHAR %s\n", line_count, yytext);

}




%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	st.EnterScope();

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
