# Forth Interpreter
An implementation of an interpreter for Forth using Ruby. Forth is a stack-oriented programming language. At all times, the Forth interpreter maintains a stack of values and a dictionary of words. The Interpreter keeps track of values and words. All values are either integers or strings, while the words describe what to do with the values and can affect the stack.


The interpreter will keep reading lines from standard input. Each lines is a set of words separated by one or more whitespaces. Words are case-insensitive. If the line was evaluated successfully, the interpreter prints "ok". Otherwise, an error message is displayed and the program will exit immediately. 

# Supported words

- **+**, **-**, **\***, **/** and **MOD\:** add, subtract, multiply, divide and calculate the division remainder, respectively, for the top two stack values and then push the result back to the stack.
- **DUP\:** duplicates the TOS
- **SWAP\:** swaps the first two elements on the top of the stack (TOS)
- **DROP\:** pops the TOS and discards it
- **DUMP\:** prints the stack without modifying it
- **OVER\:** takes the second element from the stack and copies it to the TOS
- **ROT\:** rotates the top three elements of the stack
- **.&ensp;\:** pops the TOS and prints the value as an integer
- **EMIT\:** pops the TOS and prints the value as an ASCII character
- **CR\:** prints a newline
- **=**, **<** and **>\:** all pop two elements from the TOS and push -1 to the TOS if the first element is equal, smaller than, or greater than the second element, respectively; otherwise, 0 is pushed to the TOS
- **AND**, **OR** and **XOR\:** pop two elements from the TOS and push back bitwise and, or and xor, respectively, of the first and second elements to the TOS
- **INVERT\:** pops a value from the TOS and pushes its bitwise negation (inversion) back
- **."&ensp;\:** indicates the beginning of a string that is terminated by a subsequent word that ends with **"**
- **EXIT\:** terminates the program. 


User can also define new words which a new word is just a collection of other words and values. A definition starts with the word **:** and is followed by the name of the new word. Afterwards, the definition follows until a **;** word is encountered.  For example,
```
: neg 0 SWAP - ;                (input)
ok                              (output)
5 neg .                         (input)
-5 ok                           (output)
```

The interpreter supports control structure statement **IF <true> (ELSE <false>) THEN**, that executes the <true> block if the TOS is -1; else if the TOS is 0 then the <false> block is executed if it exists. In either case, the execution continues after **THEN**. For example,
```
6 8 -1 if ." <true> block is executed " else ." <false> block is executed " Then dump                (input)
<true> block is executed                                                                             (output)
[6, 8]
ok                                                                                                   
```
  
The intereter also supports **BEGIN <body> UNTIL** and **DO <body> LOOP**. In **BEGIN** loops, the loop body <body> is executed until the **UNTIL** encounters a non-zero value at the TOS. For example,
```
0 begin dup . 1 + dup 10 > until                (input)
0 1 2 3 4 5 6 7 8 9 10 ok                       (output)
```
  
For **DO** loops, **DO** pops two values from the stack: begin and end. It sets a loop counter to begin and repeats the loop body while incrementing the counter until it reaches end (similar to Python’s for i in range(begin, end)). The counter can be accessed within the loop by the word ***I*** that pushes the current counter to the TOS.
```
10 0 do i . loop                      (input)
0 1 2 3 4 5 6 7 8 9 ok                (output)
```

Note: **;** does not necessarily have to end on the line where **:** began. Same goes for **THEN/UNTIL/LOOP**, and the corresponding **IF/BEGIN/DO**. Also, ***I*** returns an error outside the DO...LOOP construct.
  
  
Inaddition, the interpreter allows users to name constants and save values in the heap memory through variables.
- **VARIABLE \<name\>** defines the variable name. name then becomes a word that pushes its heap memory address to the TOS. In the implementation, the addresses starts at 1000.
- **\<name\> !** pops the TOS and stores the popped value in the name’s location at the heap.
- **\<name\> @** pushes the value stored in the name’s location to the TOS.
- **\<value\> CONSTANT \<name\>** defines the constant name that points to value. 
- **ALLOT** pops a value n from the TOS and reserves a contiguous block of size n in the current location of the heap. It is always used in conjunction with CELLS which multiplies the TOS with the cell width (in the implementation, the cell width is set to always be 1). ALLOT is useful for creating contiguous arrays.

**Examples**

```
: ? @ . ;                             (input) (A helper that prints the value stored in the variable’s location)
ok                                    (output)
10 numbers 0 CELLS + !                (input)
ok                                    (output)      
20 numbers 1 CELLS + !                (input)
ok                                    (output)
30 numbers 2 CELLS + !                (input)
ok                                    (output)
40 numbers 3 CELLS + !                (input)
ok                                    (output)
2 CELLS numbers + ?                   (input)
30 ok                                 (output)
3 CONSTANT third                      (input)
ok                                    (output)
third CELLS numbers + ?               (input)
40 ok                                 (output)
```
