%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include "SymbolInfo.cpp"
#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;
void yyerror(char *);

// extern FILE *tablelog;
extern FILE *tokenout;
extern FILE* tablelog;

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


%}

WHITESPACE [ \t\f\r\v]+
DIGIT [0-9]
NUMBER [0-9]*([0-9]\.?|\.[0-9])[0-9]*([Ee][-+]?[0-9]+)? 
ILLFORMED_NUMBER [0-9]*([0-9]\.?|\.[0-9])[0-9]*([Ee][-+]?[0-9.]+\.[0-9])
IDENTIFIER [_A-Za-z][_A-Za-z0-9]*
NEWLINE \n

%%

{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <IF> Lexeme %s found\n", line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "IF", line_count);
			return IF;
		}

"else"	{
			fprintf(tokenout,"<ELSE, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <FOR> Lexeme %s found\n",line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "ELSE", line_count);
			return ELSE;
		}
		
"for"	{
			fprintf(tokenout,"<FOR, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <FOR> Lexeme %s found\n",line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "FOR", line_count);
			return FOR;
		}

"while"	{
			fprintf(tokenout,"<WHILE, %s>\n",yytext);
			fprintf(tablelog,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "WHILE", line_count);
			return WHILE;
		}

"do"	{
			fprintf(tokenout,"<DO, %s>\n",yytext);
			fprintf(tablelog,"Line# %d: Token <DO> Lexeme %s found\n",line_count, yytext);
		}

"break"	{
			fprintf(tokenout,"<BREAK, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count, yytext);
		}

"int"	{
			fprintf(tokenout,"<INT, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <INT> Lexeme %s found\n",line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "INT", line_count);
			return INT;
		}

"char"	{
			fprintf(tokenout,"<CHAR, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <CHAR> Lexeme %s found\n", line_count, yytext);
		}

"float"	{
			fprintf(tokenout,"<FLOAT, %s>\n",  yytext);
			fprintf(tablelog,"Line# %d: Token <FLOAT> Lexeme %s found\n", line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "FLOAT", line_count);
			return FLOAT;
		}

"double"    {
			    fprintf(tokenout,"<DOUBLE, %s>\n",  yytext);
			    fprintf(tablelog,"Line# %d: Token <DOUBLE> Lexeme %s found\n", line_count, yytext);
		    }	

"void"	{
			fprintf(tokenout,"<VOID, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <VOID> Lexeme %s found\n",line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "VOID", line_count);
			return VOID;
		}

"return"	{
			fprintf(tokenout,"<RETURN, %s>\n",yytext);
			fprintf(tablelog,"Line# %d: Token <RETURN> Lexeme %s found\n", line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RETURN", line_count);
			return RETURN;
		}

"switch"	{
			fprintf(tokenout,"<SWITCH, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <SWITCH> Lexeme %s found\n",    line_count, yytext);  
		}

"case"	{
			fprintf(tokenout,"<CASE, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <CASE> Lexeme %s found\n", line_count, yytext);
		}

"default"	{
			fprintf(tokenout,"<DEFAU   %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <DEFAULT> Lexeme %s found\n",    line_count, yytext); 
		}

"continue"	{
			fprintf(tokenout,"<CONTINUE, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <CONTINUE> Lexeme %s found\n",    line_count, yytext);  
		}

"println"  {
			fprintf(tokenout,"<PRINTLN, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <PRINTLN> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "PRINTLN", line_count);
			return PRINTLN;
		}

"+"	{
			fprintf(tokenout,"<ADDOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <ADDOP> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "ADDOP", line_count);
			return ADDOP;  
		}

"-"	{
			fprintf(tokenout,"<ADDOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <ADDOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "ADDOP", line_count);
			return ADDOP;
		}

"*"	{
			fprintf(tokenout,"<MULOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <MULOP> Lexeme %s found\n", line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "MULOP", line_count);
			return MULOP;
		}

"/"	{
			fprintf(tokenout,"<MULOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <MULOP> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "MULOP", line_count);
			return MULOP;
		}

"%"	{
			fprintf(tokenout,"<MULOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <MULOP> Lexeme %s found\n", line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "MULOP", line_count);
			return MULOP;	  
		}

"++"	{
			fprintf(tokenout,"<INCOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <INCOP> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "INCOP", line_count);
			return INCOP;	  
		}

"--"	{
			fprintf(tokenout,"<DECOP, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <DECOP> Lexeme %s found\n", line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "DECOP", line_count);
			return DECOP;  
		}

"<" 	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RELOP", line_count);
			return RELOP;  
		}

"<="	{
			fprintf(tokenout,"<RELOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <RELOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RELOP", line_count);
			return RELOP;  
		}

">" 	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <RELOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RELOP", line_count);
			return RELOP;
		}

">="	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <RELOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RELOP", line_count);
			return RELOP; 
		}

"=="	{
			fprintf(tokenout,"<RELOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <RELOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RELOP", line_count);
			return RELOP;  
		}

"!="	{
			fprintf(tokenout,"<RELOP, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <RELOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RELOP", line_count);
			return RELOP; 
		}

"=" 	{
			fprintf(tokenout,"<ASSIGNOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "ASSIGNOP", line_count);
			return ASSIGNOP;
		}

"&&"	{
			fprintf(tokenout,"<LOGICOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <LOGICOP> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "LOGICOP", line_count);
			return LOGICOP;
		}

"||"	{
			fprintf(tokenout,"<LOGICOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <LOGICOP> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "LOGICOP", line_count);
			return LOGICOP;
		}

"&" 	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <BITOP> Lexeme %s found\n",   line_count, yytext);  
		}

"|" 	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <BITOP> Lexeme %s found\n",    line_count, yytext);	  
		}

"^" 	{
			fprintf(tokenout,"<BITOP, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <BITOP> Lexeme %s found\n",    line_count, yytext);	  
		}

"<<"	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <BITOP> Lexeme %s found\n",    line_count, yytext);	  
		}

">>"	{
			fprintf(tokenout,"<BITOP, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <BITOP> Lexeme %s found\n",    line_count, yytext);
		}

"!" 	{
			fprintf(tokenout,"<NOT, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <NOT> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "NOT", line_count);
			return NOT;   
		}

"(" 	{
			fprintf(tokenout,"<LPAREN, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <LPAREN> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "LPAREN", line_count);
			return LPAREN;   
		}

")" 	{
			fprintf(tokenout,"<RPAREN, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <RPAREN> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RPAREN", line_count);
			return RPAREN; 
		}

"{" 	{
			fprintf(tokenout,"<LCURL, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <LCURL> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "LCURL", line_count);
			return LCURL; 
		}

"}" 	{
			fprintf(tokenout,"<RCURL, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <RCURL> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RCURL", line_count);
			return RCURL; 	  
		}

"["  	{
			fprintf(tokenout,"<LSQUARE, %s>\n",   yytext);
			fprintf(tablelog,"Line# %d: Token <LSQUARE> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "LSQUARE", line_count);
			return LSQUARE; 
		}

"]"	   {
			fprintf(tokenout,"<RSQUARE, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <RSQUARE> Lexeme %s found\n",    line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "RSQUARE", line_count);
			return RSQUARE;  
		}

","	    {
			fprintf(tokenout,"<COMMA, %s>\n", yytext);
			fprintf(tablelog,"Line# %d: Token <COMMA> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "COMMA", line_count);
			return COMMA; 
		}

";"	    {
			fprintf(tokenout,"<SEMICOLON, %s>\n",    yytext);
			fprintf(tablelog,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",   line_count, yytext);
			yylval.symbol = new SymbolInfo(yytext, "SEMICOLON", line_count);
			return SEMICOLON;   
		}

{WHITESPACE}  {

			}


{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n", yytext);
				fprintf(tablelog,"Line# %d: Token <CONST_INT> Lexeme %s found\n", line_count,yytext);
				yylval.symbol = new SymbolInfo(yytext, "CONST_INT", line_count);
			    return CONST_INT;    
			}


{NUMBER}    {
	            fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
			    fprintf(tablelog,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			    yylval.symbol = new SymbolInfo(yytext, "CONST_FLOAT", line_count);
			    return CONST_FLOAT;   
            }

{IDENTIFIER}   {
                    fprintf(tokenout,"<ID, %s>\n", yytext);
			        fprintf(tablelog,"Line# %d: Token <ID> Lexeme %s found\n", line_count,yytext);
					yylval.symbol = new SymbolInfo(yytext, "ID", line_count);
			        return ID; 
                }

'[ -~]{-}[\'\"\n\t\\\a\f\r\b\v\0]'  {
	                                    char ch = yytext[1];
	                                    fprintf(tokenout,"<CONST_CHAR, %c>\n" ,ch);
			                            fprintf(tablelog,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n", line_count,ch);   
		                            }

'\\[\'\"nt\\afrbv0]'   {
	char ch  = asciiVaule(yytext[2]);
	printf("%c", yytext[2]);
	fprintf(tokenout,"<CONST_CHAR, %c>\n" ,ch);
	fprintf(tablelog,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n", line_count,ch);
	}
			
[0-9.]* {
	fprintf(tablelog, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);
}

{ILLFORMED_NUMBER}  {
	fprintf(tablelog, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext);
}

%%

int yywrap(void)
{
	return 1;
}