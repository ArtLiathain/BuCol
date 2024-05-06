/* Limited sentence recognizer */
%{
#include <stdio.h>
extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}

%token NOUN VERB ARTICLE

%%
sentence: ARTICLE NOUN VERB ARTICLE NOUN { printf("Is a valid Sentence!\n"); }
        | ARTICLE NOUN VERB NOUN        { printf("Is a valid Sentence!\n"); }
        ;

%%

extern FILE *yyin;

int main()
{
    do {
        yyparse();
    }while(!feof(yylineno));
    yyparse();
}

void yyerror(const char *s)
{
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
}