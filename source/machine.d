module quickscript.machine;
import std.array, std.meta, std.algorithm, std.variant;
import std.stdio, std.traits, std.conv : to;
import quickscript.parser;




// Stack and function table
alias funcType = Variant delegate();
private static funcType[string] functionTable;
private static Variant[] stack;

private static T popStack(T)() {
    Variant value = stack.back;
    stack.popBack;
    return value.get!T();
}



static Variant run(string script) {
    Variant[] instructions = QuickParse(script).toPostFix;
    stack = [];

    foreach (i; instructions) {
        if (i.type == typeid(funcType)) {
            stack ~= i();
        }
        else {
            stack ~= i;
        }
    }

    if(stack.length) return stack.back;
    else return Variant();
}


// Instruction generation
private static Variant[] toPostFix(ParseTree pt) {
    Variant[] buffer;

    foreach (child; pt.children) {
        buffer ~= toPostFix(child);
    }

    switch (pt.name) {
            case "QuickParse.Primary":
                auto type = pt.children[0].name;
                if(type == "QuickParse.Integer")        buffer ~= Variant(to!int(pt.matches[0]));
                else if(type == "QuickParse.Floating")  buffer ~= Variant(to!double(pt.matches[0]));
                else if(type == "QuickParse.Unsigned")  buffer ~= Variant(to!uint(pt.matches[0]));
                else if(type == "QuickParse.String")    buffer ~= Variant(pt.matches[0]);
            break;

            case "QuickParse.FunctionCall":
                if (pt.matches[0] in functionTable)
                    buffer ~= Variant(functionTable[pt.matches[0]]);
            break;

            default:
            break;
    }

    return buffer;
}




static void registerFunctions(F...)(){
    foreach(f; F){
        register!(f);
    }
}

static void register(alias func)() {
    static assert(isFunction!(func));
    auto name = __traits(identifier, func);
    const char[] pmixin = buildParameters!func;

    funcType dg = delegate() {
        static if (!is(ReturnType!func == void))
            return Variant(mixin(pmixin));
        else {
            (mixin(pmixin));
            return Variant();
        }
    };

    functionTable[name] = dg;
}

static auto buildParameters(alias func)(){
    string buf = "func(";
    foreach(i,t; Parameters!func){
        if(i > 0) buf ~= ", popStack!" ~ t.stringof;
             else buf ~= "popStack!" ~ t.stringof;
    }
    return buf ~ ")";
}















version (unittest) {
    int square(int x){
        auto value = x*x;
        writeln("Squared: ", value);
        return value; 
    }

}

unittest {
    registerFunctions!(square);
    auto value = run("square 32 square");
    int myInt = value.get!int;
    assert(myInt == square(square(32)));
}
