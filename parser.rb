class Parser
  
end

# JSON BNF
# <jsonExpr>  ::= "{" <string> ":" ( <jsonValue> | <jsonExpr> ) "}"
# <jsonValue> ::= <array> | <primary>
# <array>     ::= "[" <primary> ("," <primary>)* "]"
# <primary>   ::= STRING | NUMBER
