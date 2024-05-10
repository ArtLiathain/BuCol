%{
    #include "BuCol.tab.h"
    int yywrap() {return 1;}
%}
%%

[\t ]+ ;
"BEGINING" {return(BEGINING);}
"BODY" {return(BODY);}
"ADD" {return(ADD);}
"MOVE" {return(MOVE);}
"INPUT" {return(INPUT);}
"TO" {return(TO);}
"PRINT" {return(PRINT);}
"END" {return(END);}
";" {return(SEMICOLON);}
"." {return(NEWLINE);}
\"[^\n\r\"]*\" {return(WORD);}
[0-9]+ {yylval.intValue = atoi(yytext); return(NUMBER);}
[X]+ {yylval.intValue=yyleng ;return(VARALLOCATION); }
[a-zA-Z-][A-Za-z0-9-]* {yylval.strValue = strdup(yytext); return(IDENTIFIER); }
\n { yylineno++; }
. {}
%%
