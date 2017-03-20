module quickscript.parser;
import std.stdio;
public import pegged.grammar;




mixin(grammar(`
QuickParse:
    Script       <  Expression* 
    Expression   <  FunctionCall*  
    FunctionCall <  identifier Primary*
    Primary      <  (Floating/Unsigned/Integer/String)
    Floating     <~ '-'? Integer ('.' Integer )
    Unsigned     <~ '-' Integer
    Integer      <~ [0-9]+
    String       <~ :(doublequote/quote) ([spacing a-z A-Z 0-9])* :(doublequote/quote)
`));




