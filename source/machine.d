module quickscript.machine;
import std.array, std.algorithm, std.variant;
import std.stdio, std.traits, std.conv : to;
import quickscript.parser;








    

static void registerFunctions(A...)(){
    foreach(fun; A){
        static assert(isFunction!(fun));
        // Create a delegate as a wrapper around the function 
   
        funcType dg = delegate(){
            Variant returnValue;

            // Will generate a "get" call with the right type
            static if(is(ReturnType!fun == void)){ 
                mixin(ParameterMixin!(fun, Parameters!fun));
            }
            else {
                returnValue = mixin(ParameterMixin!(fun, Parameters!fun));
            }

            return returnValue;
        };

        functionTable[__traits(identifier, fun)] = dg;
    }
}

template ParameterMixin(alias fun, P...){
    static if(P.length > 0){
        string build(){
            string buffer = __traits(identifier, fun) ~ "(popStack!" ~ P[0].stringof;
            foreach(p; P[1..$]){
                buffer ~= ", popStack!" ~ p.stringof ;
            }
            return buffer ~ ");";
        }
        const char[] ParameterMixin = build();
    }

    else const char[] ParameterMixin = "fun();";
}










// Pop from the stack and return as correct type
private static T popStack(T)(){
    Variant value = stack.back;
    stack.popBack;
    return value.get!T();
}


// Stack and function table
alias funcType = Variant delegate();
private static funcType[string] functionTable;
private static Variant[] stack;







// Instruction generation
private static Variant[] toPostFix(ParseTree pt){
    Variant[] buffer;

    foreach(child; pt.children){
        buffer ~= toPostFix(child);
    }

    switch(pt.name){
        case "QuickParse.Unsigned":
            buffer ~= Variant(to!uint(pt.matches[0]));
        break;

        case "QuickParse.Integer":
            buffer ~= Variant(to!int(pt.matches[0]));
        break;

        case "QuickParse.Floating":
            buffer ~= Variant(to!double(pt.matches[0]));
        break;

        case "QuickParse.String":
            buffer ~= Variant(pt.matches[0]);
        break;

        case "QuickParse.FunctionCall":
             buffer ~= Variant(functionTable[pt.matches[0]]);
        break;

        default:
        break;
    }

    return buffer;
}







static void run(string script){
    import std.exception : collectException;
    Variant[] instructions;
    try{
        instructions = QuickParse(script).toPostFix;
        foreach(i; instructions){
            if(i.type == typeid(funcType)){
                i();
            }
            else{
                stack ~= i;
            }
        }
        
    } catch(Exception e){
        writeln(e);
    }
}





version(unittest){
    void Foo(int x){
        writeln(x);
    }
    void Bar(string y){
        writeln(y);
    }

    void FooBar(double z){
        writeln("FooBar");
    }
}

unittest{
    registerFunctions!(Foo, Bar, FooBar);

    run("Foo 45 Bar 'Hello' FooBar ");
}