=begin

At all times, the Forth interpreter maintains a stack of values.
The program will keep reading lines from standard input. 
Each line is split into words and stored in a list named "word_list".
The "word_list" acts as a list of pending commands. 
The Forth interpreter also maintains a dictionary to store user-defined new words.
When the new word is encountered in the word_list, it will be replaced by its definition.
Moreover, the Forth interpreter maintains another dictionary named "heap", to keep track of heap memory address.
Users can name constants and save values in the heap memory through variables.

=end

class String
    # helper function
    def is_integer?
        self.to_i.to_s == self
    end
end

class Forth
    attr_reader :word_list, :stack, :dictionary, :heap

    def initialize
        @word_list = []
        @stack = MyStack.new()
        @dictionary = {}
        @heap = {}
    end

    def eval
        is_exit = false  # A variable to track if the "exit" command is received. 
        is_str = false   # A variable to track if a string is received. 
        get_name = false # A varaible to track if ":" is received.
        new_word = ""    # A variable to store the name of the new word
        get_def = false  # A variable to track if the user is defining a new word.
        if_received = false  # A variable to track if "if" is received.
        else_received = false  # A variable to track if "else" is received.
        enter_if = false  # A variable to check if TOS is -1.
        is_begin = false  # A variable to track if "begin" is received.
        is_until = false  # A variable to track if "until" is received.
        begin_num = 0     # number of words in the body of the begin loop.
        is_do = false     # A variable to track if "do" is received.
        is_loop = false   # A variable to track if "loop" is received.
        loop_counter = 0  
        start_index = 0   # A variable to store the start of the loop counter 
        end_index = 0     # A variable to store the end of the loop counter.
        do_num = 0        # Number of words in the body of the do loop.
        get_const_name = false   # A variable to track if "constant" is received.
        mem_address = 1000       # A variable to track the memory address.
        get_var_name = false     # A variable to track if "variable" is received. 

        while true 
            @word_list = STDIN.gets.strip.split(" ")

            # for each words in the input line
            while @word_list.size>0
                top = @word_list.shift

                if is_until
                    begin_num = begin_num -1
                end

                if is_loop
                    do_num = do_num -1
                end

                if get_name
                    # get the name of the new word and store it in the dictionary
                    new_word = top.downcase
                    dictionary[new_word] = []
                    get_name = false
                    get_def = true
                elsif top == ";"
                    get_def = false
                elsif get_def
                    # get the definition (a collection of other words) of the new word
                    dictionary[new_word].push(top.downcase)

                elsif get_const_name
                    dictionary[top.downcase] = @stack.top
                    @stack = @stack.pop
                    get_const_name = false
                elsif get_var_name
                    dictionary[top.downcase] = mem_address
                    mem_address = mem_address + 1
                    get_var_name = false

                # handle the begin loop 
                elsif top.downcase == "until"
                    is_begin = false
                    if @stack.top == 0
                        is_until = true
                        begin_num = dictionary["begin"].size
                        # append the body of the loop to the front of the @word_list
                        new_word_list = dictionary["begin"] + @word_list
                        @word_list = new_word_list
                    end
                elsif is_begin
                    # store the body of the loop in the dictionary
                    dictionary["begin"].push(top.downcase)
                elsif top.downcase == "begin"
                    if @stack.top != 0 &&  @stack.top != 1
                        puts "Error: Wrong usage of \"begin\""
                        @stack = "Error"
                    end
                    is_begin = true
                    dictionary["begin"] = []
                
                #  handle the do loop
                elsif top.downcase == "i" && is_loop
                    @stack.push(loop_counter)
                elsif top.downcase == "loop"
                    is_do = false
                    is_loop = true
                    loop_counter = start_index - 1
                    do_num = 0
                elsif is_do
                    # store the body of the loop in the dictionary
                    dictionary["do"].push(top.downcase)
                elsif top.downcase == "do"
                    if @stack.stack.size < 2
                        puts "Error: Stack underflow"
                        # signal error
                        @stack = "Error"
                    else
                        start_index = @stack.top
                        @stack = @stack.pop
                        end_index = @stack.top
                        @stack = @stack.pop
                        dictionary["do"] = []
                        is_do = true
                    end
                
                # handle the if ... else ... then 
                elsif top.downcase == "then"
                    # reset if_received
                    if_received = false
                    # reset else_received
                    else_received = false
                    # reset enter_if
                    enter_if = false
                elsif top.downcase == "else"
                    else_received = true
                    # reset if_received
                    if_received = false
                elsif else_received == true && enter_if == true
                    # ignore the words after "else" until "then" is received
                elsif if_received == true && enter_if == false
                    # ignore the words after "if" until "else" or "then" is received
                
                # handle the strings
                elsif top == "\""
                    is_str = false
                elsif is_str
                    print top
                    print " "

                elsif top.is_integer? 
                    top = top.to_i
                    @stack = @stack.push(top)
                elsif top.downcase == "exit"
                    is_exit = true
                    # if "exit" is received, stop reading the line
                    break
                elsif dictionary.key?(top.downcase) 
                    # if the word is a user-defined new word
                    if dictionary[top.downcase].kind_of?(Array)
                        # append the definition of the defined new word to the front of the @word_list
                        new_word_list = dictionary[top.downcase] + @word_list
                        @word_list = new_word_list
                    # else if the word is a constant or a variable
                    else
                        @stack.stack.push dictionary[top.downcase]
                    end
                elsif top == "+"
                    @stack = @stack.plus
                elsif top == "-"
                    @stack = @stack.minus
                elsif top == "*"
                    @stack = @stack.multiply
                elsif top == "/"
                    @stack = @stack.divide
                elsif top.downcase == "mod"
                    @stack = @stack.mod
                elsif top.downcase == "dup"
                    @stack = @stack.dup
                elsif top.downcase == "swap"
                    @stack = @stack.swap
                elsif top.downcase == "drop"
                    @stack = @stack.drop
                elsif top.downcase == "dump"
                    @stack = @stack.dump
                elsif top.downcase == "over"
                    @stack = @stack.over
                elsif top.downcase == "rot"
                    @stack = @stack.rot
                elsif top == "."
                    @stack = @stack.dot
                elsif top.downcase == "emit"
                    @stack = @stack.emit
                elsif top.downcase == "cr"
                    puts ""
                elsif top == "="
                    @stack = @stack.eql
                elsif top == "<"
                    @stack = @stack.less
                elsif top == ">"
                    @stack = @stack.larger
                elsif top.downcase == "and"
                    @stack = @stack.and
                elsif top.downcase == "or"
                    @stack = @stack.or
                elsif top.downcase == "xor"
                    @stack = @stack.xor
                elsif top.downcase == "invert"
                    @stack = @stack.invert
                elsif top.downcase == ".\""
                    is_str = true
                # check if the user is defining a new word
                elsif top.downcase == ":"
                    get_name = true
                elsif top.downcase == "if"
                    if_received = true
                    if @stack.top == -1
                        @stack = @stack.pop
                        enter_if = true
                    elsif @stack.top == 0
                        @stack = @stack.pop
                        enter_if = false
                    else
                        puts "Error: Wrong usage of \"if\""
                        @stack = "Error"
                    end
                elsif top.downcase == "constant"
                    if @stack.stack.size < 1
                        puts "Error: Stack underflow"
                        # signal error
                        @stack = "Error"
                    end
                    get_const_name = true
                elsif top.downcase == "variable"
                    get_var_name = true
                elsif top.downcase == "cell"
                    @stack = @stack.cell
                elsif top.downcase == "allot"
                    allot_size = @stack.top
                    @stack = @stack.pop
                    mem_address = mem_address + allot_size
                elsif top.downcase == "!"
                    if @stack.stack.size < 2
                        puts "Error: Stack underflow"
                        # signal error
                        @stack = "Error"
                    end
                    store_address = @stack.top
                    @stack = @stack.pop
                    store_val = @stack.top
                    @stack = @stack.pop
                    heap[store_address] = store_val
                elsif top.downcase == "@"
                    get_address = @stack.top
                    @stack = @stack.pop
                    @stack.push(heap[get_address])
                else
                    print "Error: Unknown word \""
                    print top.downcase
                    puts "\""
                    # signal error
                    @stack = "Error"
                end
                
                # if error, stop reading the line
                break if @stack == "Error"
                
                # finished one begin loop and determine if another loop is needed
                if is_until && begin_num == 0
                    if @stack.top == 0
                        @stack = @stack.pop
                        begin_num = dictionary["begin"].size
                        # append the body of the loop to the front of the @word_list
                        new_word_list = dictionary["begin"] + @word_list
                        @word_list = new_word_list
                    else
                        is_until = false
                        @stack = @stack.pop
                    end
                end

                # finished one do loop and determine if another loop is needed
                if is_loop && do_num == 0
                    loop_counter = loop_counter + 1
                    if loop_counter < end_index
                        do_num = dictionary["do"].size
                        # append the body of the loop to the front of the @word_list
                        new_word_list = dictionary["do"] + @word_list
                        @word_list = new_word_list
                    else
                        is_loop = false
                    end
                end

            end

            # if error, exit the program
            break if @stack == "Error"
            # if "exit" command received, exit the program
            break if is_exit == true

            puts "ok"         
        end
    end
end


class MyStack
    attr_reader :stack

    def initialize
        @stack = []
    end

    def push(x)
        @stack.push x
        self
    end

    def pop
        @stack.pop
        self
    end

    # a helper function to get the top of the stack
    def top
        temp = @stack.pop
        @stack.push(temp)
        temp
    end

    #  Adds the top two stack values and then push the result back to the stack.
    def plus
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            
            sum = a.to_i + b.to_i
            @stack.push(sum)
            self
        end
    end

    #  Substracts the top two stack values and then push the result back to the stack.
    def minus
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            
            difference = a - b
            @stack.push(difference)
            self
        end
    end

    #  Multiplies the top two stack values and then push the result back to the stack.
    def multiply
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            
            product = a * b
            @stack.push(product)
            self
        end
    end

    #  Divides the top two stack values and then push the result back to the stack.
    def divide
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            
            quotient = a / b
            @stack.push(quotient)
            self
        end
    end

    # Calculates the division remainder for the top two stack values 
    # and then push the result back to the stack
    def mod
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            
            modulo = a % b
            @stack.push(modulo)
            self
        end
    end

    # Duplicates the TOS (Top of Stack)
    def dup
        if @stack.size < 1
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            a = @stack.pop
            @stack.push(a)
            @stack.push(a)
            self
        end
    end

    # Swaps the first two elements on the TOS
    def swap
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            @stack.push(b)
            @stack.push(a)
            self
        end
    end

    # Pops the TOS and discards it,
    def drop
        if @stack.size < 1
            puts "Error: Empty Stack"
            # return error
            "Error"
        else
            @stack.pop
            self
        end
    end

    # Prints the stack without modifying it
    def dump
        print "["
        print @stack.join(", ")
        puts "]"
        self
    end

    # Takes the second element from the stack and copies it to the TOS
    def over
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop

            @stack.push(a)
            @stack.push(b)
            @stack.push(a)
            self
        end
    end

    # Rotates the top three elements of the stack
    def rot
        if @stack.size < 3
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            c = @stack.pop
            b = @stack.pop
            a = @stack.pop

            @stack.push(b)
            @stack.push(c)
            @stack.push(a)
            self
        end
    end

    # Pops the TOS and prints the value as an integer
    def dot
        if @stack.size < 1
            puts "Error: Empty stack"
            # return error
            "Error"
        else
            a = @stack.pop
            print a
            print " "
            self
        end
    end

    # Pops the TOS and prints the value as an ASCII character
    def emit
        if @stack.size < 1
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            a = @stack.pop
            print a.chr
            print " "
            self
        end
    end

    # Pop two elements from the TOS and 
    # push -1 to the TOS if the first element is equal to the second element;
    # otherwise, 0 is pushed to the TOS,
    def eql
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            if a == b
                @stack.push(-1)
            else
                @stack.push(0)
            end
            self
        end
    end

    # Pop two elements from the TOS and 
    # push -1 to the TOS if the first element is less than the second element;
    # otherwise, 0 is pushed to the TOS,
    def less
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            if a < b
                @stack.push(-1)
            else
                @stack.push(0)
            end
            self
        end
    end

    # Pop two elements from the TOS and 
    # push -1 to the TOS if the first element is larger than the second element;
    # otherwise, 0 is pushed to the TOS,
    def larger
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            if a > b
                @stack.push(-1)
            else
                @stack.push(0)
            end
            self
        end
    end

    # Pop two elements from the TOS and 
    # push back bitwise and of the first and second elements to the TOS
    def and
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            @stack.push(a & b)
            self
        end
    end

    # Pop two elements from the TOS and 
    # push back bitwise or of the first and second elements to the TOS
    def or
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            @stack.push(a | b)
            self
        end
    end

    # Pop two elements from the TOS and 
    # push back bitwise xor of the first and second elements to the TOS
    def xor
        if @stack.size < 2
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            b = @stack.pop
            a = @stack.pop
            @stack.push(a ^ b)
            self
        end
    end

    # Pops a value from the TOS and pushes its bitwise negation (inversion) back
    def invert
        if @stack.size < 1
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            a = @stack.pop
            @stack.push(~ a)
            self
        end
    end

    # multiplies the TOS with the cell width (which will always be 1, in this implementation)
    def cell
        if @stack.size < 1
            puts "Error: Stack underflow"
            # return error
            "Error"
        else
            a = @stack.pop
            a = a * 1
            @stack.push(a)
            self
        end
    end

end


a = Forth.new().eval