module quickscript.parser;
import quickscript.machine;
public import pegged.grammar;




mixin(grammar(`
QuickParse:
    Expression   <  FunctionCall*  
    FunctionCall <  identifier Primary?
    Primary      <  (Floating/Integer/String) Primary?
    Floating     <~ '-'? Integer ('.' Integer )
    Integer      <~ '-'? [0-9]+
    String       <~ :(doublequote/quote) ([spacing a-z A-Z 0-9])* :(doublequote/quote)
`));



