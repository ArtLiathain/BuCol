%{
    #include "parsing.tab.h"
%}

%%

[\t ]+ /* ignore whitespace */ ;
"cat" |
"dog" |
"mouse" return(NOUN);
"ate" |
"hit" return(VERB);
"the" |
"a" return(ARTICLE);
[a-zA-Z]+  | 
. return(0);
%%

int yywrap() {
    return 1;
}