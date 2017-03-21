![Build status](https://travis-ci.org/hubertekvall/rockit.svg?branch=master)
# quickscript

## What it is
*quickscript* is a easy way to "scriptify" a certain set of functions.
This can be useful for configuration files or for writing command consoles
in games or other applications that have a need for fast iteration times.


## Todo
- Can only handle static or module level functions right now
- Improve error handling, it shouldn't crash when given faulty input
- Basic arithmetic
- Optimizations


## How to use
You will need:
- [dmd](https://dlang.org/)
- [dub](https://code.dlang.org/download)

Clone this repository and run "dub test" to see if it works as it should.
Compile times can be a bit long because this project uses [pegged](https://github.com/PhilippeSigaud/Pegged/)
as a dependency.


```D
import quickscript.machine, std.stdio;


int square(int x){
  auto value = x*x;
  writeln("Squared: ", value);
  return value; 
}

//  Register the functions you wanna use in your script with a comma-separated argument list
registerFunctions!(square);


/*  
    Give the runtime a string containing your script.
    Basic syntax: FunctionIdentifier Arguments
    Functions are executed from left-to-right taking the previous output as input if available.
    After the execution a Variant is returned containing the value at the top of the stack
*/    
auto value = run("square 32 square");

//  To extract the value from this Variant
int myInt = value.get!int;

// Just to be sure
assert(myInt == square(square(32)));
```