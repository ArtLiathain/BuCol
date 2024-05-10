/* Limited sentence recognizer */
%{
#include <stdio.h>
#include <string.h>
#include <math.h>

#define MAX_SYMBOLS 1000

extern int yylex();
extern int yylineno;
void yyerror(const char *s);
int errCount = 0;

typedef struct {
    char identifier[100];
    int value;
    int maxLen;
} Symbol;

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

int symbolExists(char* identifier) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].identifier, identifier) == 0) {
            return 1;
        }
    }
    return 0; 
}

void addSymbol(char* identifier, int maxLen) {
    if (symbolExists(identifier) == 1){
        char * errorMessage [100];
        int temp = snprintf(errorMessage, 100, "Cannot duplicate variable names %s\n", identifier);
        yyerror(errorMessage);
        return;
    }
    for (int i = 1; i < strlen(identifier)-1; i++){
        if (identifier[i-1] == 'X' && identifier[i] == 'X'){
            yyerror("Cannot have contigious X in variable declaration\n");
            return;
        }
    }
    strcpy(symbolTable[symbolCount].identifier, identifier);
    symbolTable[symbolCount].value = 0;
    symbolTable[symbolCount].maxLen = maxLen;
    symbolCount++;
}

int getSymbolValue(char* identifier) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].identifier, identifier) == 0) {
            return symbolTable[i].value;
        }
    }
    return -1; 
}


int updateSymbolValue(char* identifier, int value) {
    char errorMessage [200];
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].identifier, identifier) == 0) {
            if(value >= pow(10,symbolTable[i].maxLen)){
                snprintf(errorMessage,200, "Number too big %d for %s for max length %.2lf\n", value,identifier, pow(10,symbolTable[i].maxLen));
                yyerror(errorMessage);
                return -1;
            }
            symbolTable[i].value = value;
            return 0;
        }
    }
    
    return -1;
}



%}
%union {
    int intValue;
    char* strValue;
}
%token <intValue> VARALLOCATION INPUT NUMBER
%token <strValue> IDENTIFIER
%type <intValue> value
%type <strValue> validIdentifier errorOperation
%token BEGINING NEWLINE BODY ADD MOVE TO END PRINT SEMICOLON WORD
%%

file: BEGINING lineEnd declarations BODY lineEnd maincontent END lineEnd
lineEnd: NEWLINE 
    | {yyerror("Line end missing on line above");}
declarations : declaration declarations 
    | declaration
    |
    ; 


declaration:  VARALLOCATION IDENTIFIER lineEnd {   
    addSymbol($2, $1);
}

maincontent : operations lineEnd maincontent 
    | operations lineEnd 
    | 

operations : addition 
    | move 
    | input 
    | print 
    | errorOperation {
    char * errorMessage[100];
    int temp = snprintf(errorMessage, 100, "Operation %s not correctly declared", $1) ;
    yyerror(errorMessage);}

errorOperation: addErrors {$$="ADD";}
    | moveErrors {$$="MOVE";}
    | printErrors {$$="PRINT";}
    | inputErrors {$$="INPUT";} 
    | TO {$$="TO";} 

addErrors: ADD value TO 
    | ADD TO NUMBER 
    | ADD TO validIdentifier  
    | ADD value validIdentifier  
    | ADD value 
    | ADD TO 
    | ADD

moveErrors: MOVE value TO 
    | MOVE TO NUMBER    
    | MOVE TO validIdentifier 
    | MOVE value validIdentifier 
    | MOVE value 
    | MOVE TO 
    | MOVE

printErrors: PRINT printables TO 
    | PRINT TO printables 
    | PRINT printables SEMICOLON 
    | PRINT SEMICOLON printables 
    | PRINT TO 
    | PRINT NUMBER 
    | PRINT

inputErrors: INPUT multipleIdentifiers TO 
    | INPUT TO multipleIdentifiers 
    | INPUT multipleIdentifiers SEMICOLON 
    | INPUT SEMICOLON multipleIdentifiers 
    | INPUT TO 
    | INPUT NUMBER | INPUT

addition : ADD value TO validIdentifier {updateSymbolValue($4, getSymbolValue($4) + $2);}

move : MOVE value TO validIdentifier {updateSymbolValue($4, $2);}
input : INPUT multipleIdentifiers
multipleIdentifiers: multipleIdentifiers SEMICOLON validIdentifier 
    | validIdentifier
value : validIdentifier { $$ = getSymbolValue($1); } 
    | NUMBER { $$ = $1; }
print : PRINT printables 
printables : validIdentifier SEMICOLON printables 
    | WORD SEMICOLON printables 
    | validIdentifier 
    | WORD  
validIdentifier : IDENTIFIER {
    if(symbolExists($1) == 1) {$$ = $1;} 
    else {char errorMessage [100]; 
    int temp = snprintf(errorMessage, 100, "Identifier %s not declared", $1);
    yyerror(errorMessage);};}
%%

extern FILE *yyin;

int main(int argc, char *argv[]){

    yyparse();
    if(errCount > 0) {
        printf("%d Errors to fix\n", errCount);
    }
    else {
        printf("Working code\n");
    }
    return 0;
}

void yyerror(const char *s)
{
    errCount++;
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
}
