# Bucol flex and parser
-----
Bucol is a highly cross functional performant language used from things like banking to launching rockets, turing complete there is nothing it can't do.

## Features
A state of the **Art**(Ba dum tss) parser. This parser can not only identify when when your code is not properly formed but count the number of errors in your code and give error messages sepcific to what you did wrong. It can keep a running total of the value of variables and will remind the user if even adding to a variable will make it go over its limit.
An example error
```
Syntax Error at line 4: Line end missing on line above
Syntax Error at line 7: Line end missing on line above
Syntax Error at line 13: Operation MOVE not correctly declared
Syntax Error at line 15: Line end missing on line above
Syntax Error at line 15: Operation ADD not correctly declared
5 Errors to fix
```
I will admit there is a small line number issue with missing . but other than that it works well.


### To Run
To run this all you need to do is
```
flex -io del.yy.c BuCol.l && bison -d BuCol.y && gcc -o BuCol.out del.yy.c BuCol.tab.c -lm && rm BuCol.tab.* && rm del.yy.c && cat BuCol.txt | ./BuCol.out
```
This will compile and automatically put the file BuCol.txt to be parsed if you want to parse different files 
```
cat $filename | ./BuCol.out
```