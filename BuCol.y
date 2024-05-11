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
// Add a symbol but omit contigious X and also omit duplicates
void addSymbol(char* identifier, int maxLen) {
    if (symbolExists(identifier) == 1){
        char * errorMessage [100];
        int temp = snprintf(errorMessage, 100, "Cannot duplicate variable names %s\n", identifier);
        yyerrorToCall(errorMessage);
        return;
    }
    for (int i = 1; i < strlen(identifier)-1; i++){
        if (identifier[i-1] == 'X' && identifier[i] == 'X'){
            yyerrorToCall("Cannot have contigious X in variable declaration\n");
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

int getSymbolCapacity(char* identifier) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].identifier, identifier) == 0) {
            return pow(10,symbolTable[i].maxLen);
        }
    }
    return -1; 
}
//Edit the value of a variable does a check to see if the value is larger than the max length
int updateSymbolValue(char* identifier, int value) {
    char errorMessage [200];
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].identifier, identifier) == 0) {
            if(value >= pow(10,symbolTable[i].maxLen)){
                snprintf(errorMessage,200, "Number %d too big for %s for max length %.2lf", value,identifier, pow(10,symbolTable[i].maxLen));
                yyerrorToCall(errorMessage);
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
//Log errors but continue if . is ommitted
lineEnd: NEWLINE 
    | {yyerrorToCall("Line end missing on line above");}
declarations : declaration declarations 
    | declaration
    |
//Add Variable to symbol table
declaration:  VARALLOCATION IDENTIFIER lineEnd {addSymbol($2, $1);}
    | IDENTIFIER lineEnd {yyerrorToCall("Identifier with no capacity declared");}
//Infinite operations amount
maincontent : operations lineEnd maincontent 
    | operations lineEnd 
    | 
//All operations with error modes
operations : addition 
    | move 
    | input 
    | print 
    | errorOperation {
    char * errorMessage[100];
    int temp = snprintf(errorMessage, 100, "Operation %s not correctly declared", $1) ;
    yyerrorToCall(errorMessage);}

addition : ADD value TO validIdentifier {updateSymbolValue($4, getSymbolValue($4) + $2);}

move : MOVE validIdentifier TO validIdentifier {
    //Code specifically ckecking if the the maxlength is larger for on eover the other ignoring the operation then
    if(getSymbolCapacity($2) > getSymbolCapacity($4)){
        char errorMessage[200];
        int temp = snprintf(errorMessage, 199, "Operation MOVE has %s with a larger capacity than %s trying to move values into it", $2, $4) ;
        yyerrorToCall(errorMessage);
        //check if the value of the moving cariable is smaller than the capacity of the reciever and if so continue
        if(getSymbolValue($2) <  getSymbolCapacity($4)){
            updateSymbolValue($4, getSymbolValue($2));
        }
    }
    else{
        updateSymbolValue($4, getSymbolValue($2));
    }
    }  
    | MOVE value TO validIdentifier {updateSymbolValue($4, $2);}
input : INPUT multipleIdentifiers
//Infinite amount of identifiers for INPUT
multipleIdentifiers: multipleIdentifiers SEMICOLON validIdentifier 
    | validIdentifier
    
print : PRINT printables 
//Infinite amount of prints
printables : validIdentifier SEMICOLON printables 
    | WORD SEMICOLON printables 
    | validIdentifier 
    | WORD  
//Return a numeric value
value : validIdentifier {$$ = getSymbolValue($1);} 
    | NUMBER { $$ = $1; }
// To check identifiers exist
validIdentifier : IDENTIFIER {
    if(symbolExists($1) == 1) {$$ = $1;} 
    else {char errorMessage [100]; 
    int temp = snprintf(errorMessage, 100, "Identifier %s not declared", $1);
    yyerrorToCall(errorMessage);};}
// All below to have better error handling
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
%%

extern FILE *yyin;

int main(int argc, char *argv[]){

    yyparse();
    if(errCount > 0) {
        printf("%d Errors to fix\n", errCount);
    }
    else {
        printf("Correctly formed code\n");
    }
    return 0;
}

void yyerror(const char *s)
{
    errCount++;
    fprintf(stderr, "Unrecognisable Catastrophic Error at line %d: %s\n", yylineno, s);
}

void yyerrorToCall(const char *s)
{
    errCount++;
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
}